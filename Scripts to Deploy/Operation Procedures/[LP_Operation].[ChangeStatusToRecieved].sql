CREATE OR ALTER PROCEDURE [LP_Operation].[ChangeStatusToRecieved]
                                      (
										@JSON					NVARCHAR(MAX)
                                        ,@countryCode			NVARCHAR(3)
										,@Identification		NVARCHAR(100)
                                      )
AS
BEGIN
BEGIN TRY
      DECLARE
		  @qtyAccount       [LP_Common].[LP_F_INT]
		, @idEntityAccount    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTicket           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransaction        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idTransactionLot       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        , @idStatusReceived       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idStatusOnHold		  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

        ,@idCountry           [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
        ,@idProvider          [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		,@Ticket			  VARCHAR(60)
        ,@DetailStatus        [LP_Common].[LP_F_CODE]
		,@CurrentStatus		  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @JSON_Result      XML
		, @idEntityUser     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @MerchantName     [LP_Common].[LP_F_DESCRIPTION]

	  DECLARE @ticketTable TABLE (
		ticket VARCHAR(60)
	  )

	  DECLARE @transactionIdTable TABLE (
		TransactionId [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
	  )

      SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @countryCode AND [Active] = 1)
      SET @idProvider = ( SELECT TOP(1)P.[idProvider] FROM [LP_Configuration].[Provider] P
							INNER JOIN [LP_Configuration].[ProviderPayWayServices] PPWS ON P.idProvider = PPWS.idProvider
							INNER JOIN [LP_Configuration].[PayWayServices] PWS On PWS.idPayWayService = PPWS.idPayWayService
							WHERE P.[idCountry] = @idCountry AND P.[Active] = 1 AND PWS.Code = 'BANKDEPO')

      SET @idStatusReceived = [LP_Operation].[fnGetIdStatusByCode]('Received')
	  SET @idStatusOnHold = [LP_Operation].[fnGetIdStatusByCode]('OnHold')

	  SELECT  @qtyAccount = COUNT([idEntityAccount]), @idEntityAccount = MAX([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [Identification] = @Identification AND [Active] = 1

	  SET @idEntityUser = ( SELECT [idEntityUser] FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @Identification AND [Active] = 1 AND [idCountry] = @idCountry)


	  INSERT INTO @ticketTable
	  SELECT * FROM OPENJSON(@JSON)
	  WITH (   
              Ticket   varchar(60) '$'  
			) ;

	BEGIN TRAN

	DECLARE payout_cursor CURSOR FORWARD_ONLY FOR
	SELECT ticket FROM  @ticketTable

	OPEN payout_cursor;
	FETCH NEXT FROM payout_cursor INTO @ticket

	WHILE @@FETCH_STATUS = 0
	BEGIN

			SELECT
					@idTicket						= NULL
					, @idTransaction				= NULL


      DECLARE @TxIdStatus [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
      SET @TxIdStatus = @idStatusReceived

	  SELECT
			@idTicket           = [T].[idTicket]
			, @idTransaction        = [T2].[idTransaction]
			, @idTransactionLot  = [TL].[idTransactionLot]
			, @CurrentStatus	 = [T2].[idStatus]
		  FROM
			[LP_Operation].[Ticket]                   [T]
			  INNER JOIN [LP_Operation].[Transaction]         [T2]  ON [T].[idTransaction]    = [T2].[idTransaction]
			  INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON [TRD].[idTransaction] = [T2].[idTransaction]
			  INNER JOIN [LP_Operation].[TransactionLot]        [TL]  ON [T2].[idTransactionLot]  = [TL].[idTransactionLot]
			  INNER JOIN [LP_Entity].[EntityUser]             [EU]    ON [EU].[idEntityUser]          = [T2].[idEntityUser]
			  inner join [LP_Security].[entityaccountUser] eacu on eacu.idEntityUser = [T2].idEntityUser and eacu.idEntityAccount = @idEntityAccount
		  WHERE
			[TRD].[InternalDescription] = @Ticket
		IF (@CurrentStatus = @idStatusOnHold AND @idTransaction IS NOT NULL)
		BEGIN
			UPDATE  [LP_Operation].[Transaction]
			SET   
			  [idStatus]          = @TxIdStatus
			WHERE 
			  [idTransaction] = @idTransaction

			UPDATE  [LP_Operation].[TransactionDetail]
			SET   
			  [idStatus] = @TxIdStatus
			WHERE 
			  [idTransaction] = @idTransaction

			UPDATE  [LP_Operation].[TransactionRecipientDetail]
			SET   
			  [idStatus] = @TxIdStatus
			WHERE 
			  [idTransaction] = @idTransaction

			UPDATE  [LP_Operation].[TransactionLot]
			SET   [idStatus] = @TxIdStatus
			WHERE [idTransactionLot] = @idTransactionLot

			UPDATE  [LP_Operation].[TransactionInternalStatus]
			SET   
			  [idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'RECI', 'SCM')
			WHERE 
			  [idTransaction] = @idTransaction

			INSERT INTO @transactionIdTable (TransactionId)
			VALUES(@idTransaction)
		END
	FETCH NEXT FROM payout_cursor INTO @ticket
	END
	
	CLOSE payout_cursor;

	DEALLOCATE payout_cursor;
	COMMIT

	SET @MerchantName = (SELECT [LastName] FROM [LP_Entity].[EntityUser] WHERE [idEntityUser] = @idEntityUser )

	SET @JSON_Result = 
              (
                SELECT
                  CAST
                  (
                    (
                      SELECT
                        [idTransactionLot]  = [TL1].[idTransactionLot]
                        , [TransactionType] = 'PAYOUT'
                        , [LotDate]     = CONVERT(VARCHAR(8), [TL1].[LotDate], 112)
                        , [GrossAmount]   = REPLACE(CAST(CONVERT(DECIMAL(18,2), [TL1].[GrossAmount]) AS VARCHAR(18)), '.', '')
                        , [NetAmount]   = REPLACE(CAST(CONVERT(DECIMAL(18,2), [TL1].[NetAmount]) AS VARCHAR(18)), '.', '')
                        , [Balance]     = REPLACE(CAST(CONVERT(DECIMAL(18,2), [TL1].[ACcountBalance]) AS VARCHAR(18)), '.', '')
                        , [idStatus]    = [TL1].[idStatus]
                        , [Status]      = [STATL1].[Code]
                        , [CustomerName]  = @MerchantName
                        , [Transactions]  =
                                  (
                                    SELECT  
                                      [idTransaction]                       = [T].[idTransaction]
                                      , [Value]                         = REPLACE(CAST(CONVERT(DECIMAL(18,2), [T].[GrossValueLP]) AS VARCHAR(18)), '.', '')
                                      , [idStatus]                        = [T].[idStatus]
                                      , [Status]                          = [STAT].[Code]
                                      , [StatusDetail]                      = ISNULL([LPIE].[Name], ISNULL([TDESC].[Description], [IS].[Description]))
                                      , [TransactionRecipientDetail.Recipient]          = [TRD].[Recipient]
                                      , [TransactionRecipientDetail.RecipientCUIT]        = [TRD].[RecipientCUIT]
                                      , [TransactionRecipientDetail.CBU]              = [TRD].[CBU]
                                      , [TransactionRecipientDetail.RecipientAccountNumber]   = [TRD].[RecipientAccountNumber]
                                      , [TransactionRecipientDetail.TransactionAcreditationDate]  = CONVERT(VARCHAR(8), [TRD].[TransactionAcreditationDate], 112)
                                      , [TransactionRecipientDetail.Description]          = [TRD].[Description]
                                      , [TransactionRecipientDetail.InternalDescription]      = [TRD].[InternalDescription]
                                      , [TransactionRecipientDetail.ConceptCode]          = [TRD].[ConceptCode]
                                      , [TransactionRecipientDetail.BankAccountType]        = [BAT].[Code]
                                      , [TransactionRecipientDetail.EntityIdentificationType]   = [EIT].[Code]
                                      , [TransactionRecipientDetail.CurrencyType]         = [CT].[Code]
                                      , [TransactionRecipientDetail.PaymentType]          = [PT].[Code]
                                      , [TransactionRecipientDetail.idTransaction]        = [TRD].[idTransaction]
                                      , [TransactionRecipientDetail.idStatus]           = [TRD].[idStatus]
                                      , [TransactionRecipientDetail.Status]                   = [STATRD].[Code]
									  , [TransactionRecipientDetail.RecipientPhoneNumber]                   = [TRD].[RecipientPhoneNumber]
                                      , [TransactionDetail.CreditTax]                         = 0 --[TD].[CreditTax]
                                      , [TransactionDetail.ExchangeRate]                      = REPLACE(CAST(CONVERT(DECIMAL(18,6), ([CE].[Value] * (100 - [CB].[Base_Sell]) / 100)) AS VARCHAR), '.', '')
                                      , [TransactionDetail.TaxWithholdings_Afip]              = REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[TaxWithholdings]) AS VARCHAR), '.', '')
                                      , [TransactionDetail.TaxWithholdings_Arba]              = REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[TaxWithholdingsARBA]) AS VARCHAR), '.', '')
                                      , [TransactionSubMerchantDetail.SubMerchantIdentification]  = [ESM].[SubMerchantIdentification]
                                      , [TransactionCustomerInformation.SenderName] = [TCI].SenderName
                                      , [TransactionCustomerInformation.SenderAddress] = [TCI].SenderAddress
                                      , [TransactionCustomerInformation.SenderState] = [TCI].SenderState
                                      , [TransactionCustomerInformation.SenderCountry] = [TCI].SenderCountry
                                      , [TransactionCustomerInformation.SenderTAXID] = [TCI].SenderTAXID
                                      , [TransactionCustomerInformation.SenderBirthDate] = [TCI].SenderBirthDate
                                      , [TransactionCustomerInformation.SenderEmail] = [TCI].SenderEmail
									  , [TransactionCustomerInformation.SenderPhoneNumber] = [TCI].SenderPhoneNumber
                                    FROM
                                      [LP_Operation].[Transaction]                  [T]
                                        INNER JOIN [LP_Entity].[EntityUser]             [EU]    ON [EU].[idEntityUser]          = [T].[idEntityUser]
                                        INNER JOIN [LP_Configuration].[TransactionTypeProvider]   [TTP]   ON [T].[idTransactionTypeProvider]    = [TTP].[idTransactionTypeProvider]
                                        LEFT JOIN [LP_Operation].[TransactionRecipientDetail]   [TRD]   ON [TRD].[idTransaction]        = [T].[idTransaction]
                                        LEFT JOIN [LP_Common].[Status]                [STAT]    ON [STAT].[idStatus]          = [T].[idStatus]
                                        LEFT JOIN [LP_Common].[Status]                [STATRD]  ON [STATRD].[idStatus]          = [TRD].[idStatus]
                                        LEFT JOIN [LP_Operation].[TransactionDetail]        [TD]    ON [TD].[IdTransaction]         = [T].[IdTransaction]
                                        LEFT JOIN [LP_Configuration].[BankAccountType]        [BAT]   ON [TRD].[idBankAccountType]      = [BAT].[idBankAccountType]
                                        LEFT JOIN [LP_Entity].[EntityIdentificationType]      [EIT]   ON [TRD].[idEntityIdentificationType] = [EIT].[idEntityIdentificationType]
                                        LEFT JOIN [LP_Configuration].[PaymentType]          [PT]    ON [TRD].[idPaymentType]        = [PT].[idPaymentType]
                                        LEFT JOIN [LP_Configuration].[CurrencyType]         [CT]    ON [TRD].[idCurrencyType]       = [CT].[idCurrencyType]
                                        LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]   [TESM]    ON [TESM].[idTransaction]       = [T].[idTransaction]
                                        LEFT JOIN [LP_Entity].[EntitySubMerchant]         [ESM]   ON [ESM].[idEntitySubMerchant]      = [TESM].[idEntitySubMerchant]
                                        LEFT JOIN [LP_Operation].[TransactionDescription]     [TDESC]   ON [T].[idTransaction]          = [TDESC].[idTransaction]
                                        LEFT JOIN [LP_Operation].[TransactionInternalStatus]    [TO]    ON [T].idTransaction          = [TO].[idTransaction]
                                        LEFT JOIN [LP_Configuration].[InternalStatus]       [IS]    ON [TO].idInternalStatus        = [IS].idInternalStatus
										LEFT JOIN [LP_Configuration].[LPInternalStatusClient] [LPIC]	ON [LPIC].[idInternalStatus] = [IS].idInternalStatus
										LEFT JOIN [LP_Configuration].[LPInternalError]		[LPIE]		ON [LPIE].[idLPInternalError] = [LPIC].[idLPInternalError]
                                        LEFT JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]  [TCI]   ON  [T].[idTransaction]         = [TCI].[idTransaction]
                                        INNER JOIN [LP_Configuration].[CurrencyExchange] [CE]       ON [CE].[idCurrencyExchange] = [T].[idCurrencyExchange]
                                        INNER JOIN [LP_Configuration].[CurrencyBase] [CB]           ON [CB].[idCurrencyBase] = [T].[idCurrencyBase]
                                    	inner join [LP_Security].[entityaccountUser] eacu on eacu.idEntityUser = [T].idEntityUser and eacu.idEntityAccount = @idEntityAccount
									WHERE
                                      T.IdTransactionLot=TL1.idTransactionLot   
                                      AND ( [T].[idTransaction] IN (SELECT TransactionId FROM @transactionIdTable))
                                    FOR JSON PATH
                                  )
                      FROM
                        LP_Operation.TransactionLot                 [TL1]
                          INNER join LP_Operation.[Transaction]             [T1]    ON T1.idTransactionLot=TL1.idTransactionLot
                          INNER JOIN [LP_Entity].[EntityUser]             [EU1]   ON [EU1].[idEntityUser]         = [T1].[idEntityUser]
                          INNER JOIN [LP_Location].[Country]              [C1]      ON [C1].[idCountry]           = [EU1].[idCountry]
                          INNER JOIN [LP_Operation].[TransactionRecipientDetail]    [TRD1]    ON [TRD1].[idTransaction]       = [T1].[idTransaction]
                          INNER JOIN [LP_Common].[Status]               [STATL1]    ON [STATL1].[idStatus]          = [TL1].[idStatus]
						  inner join [LP_Security].[entityaccountUser] eacu on eacu.idEntityUser = [T1].idEntityUser and eacu.idEntityAccount = @idEntityAccount
                      WHERE
                        (
						 [T1].[idTransaction] IN (SELECT TransactionId FROM @transactionIdTable)
                        )
                        AND [C1].[idCountry] =  @idCountry
                      GROUP BY
                        [TL1].[idTransactionLot]
                        , [TL1].[LotDate]
                        , [TL1].[GrossAmount]
                        , [TL1].[NetAmount]
                        , [TL1].[ACcountBalance]
                        , [TL1].[idStatus]
                        , [STATL1].[Code]
                      FOR JSON PATH
                    ) 
                    AS XML
                  )
              )

    SELECT @JSON_Result
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRAN

    --DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

    RAISERROR
        (
          @ErrorMessage,
          @ErrorSeverity,
          @ErrorState
        );
  END CATCH



END
