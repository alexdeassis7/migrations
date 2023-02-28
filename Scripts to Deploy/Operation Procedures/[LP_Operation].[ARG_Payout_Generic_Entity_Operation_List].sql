

/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_Generic_Entity_Operation_List]    Script Date: 3/24/2020 7:10:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter PROCEDURE [LP_Operation].[ARG_Payout_Generic_Entity_Operation_List]
                                      (
                                        @customer       VARCHAR(12)
                                        ,@JSON          [LP_Common].[LP_F_VMAX]
                                      )
AS
BEGIN
  --DECLARE
  --  @customer VARCHAR(12)
  --  , @JSON   [LP_Common].[LP_F_VMAX]

  --SET @customer = '000001500001'
  --SET @JSON = '{"payout_id":946, "transaction_id":0,"site_transaction_id":null,"date_from":"20191211","date_to":"20191227","ErrorRow":{"Errors":[],"HasError":false}}'
  ----88157

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- turn it on

  DECLARE
    @qtyAccount       [LP_Common].[LP_F_INT]
    , @idEntityAccount    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @Message        [LP_Common].[LP_F_DESCRIPTION]
    , @Status       [LP_Common].[LP_F_BOOL]
    , @transLot       [LP_Common].[LP_F_INT]
    , @JSON_Result      XML
    , @MerchantName     [LP_Common].[LP_F_DESCRIPTION]

    , @date_from      [LP_Common].[LP_A_DB_INSDATETIME]
    , @date_to        [LP_Common].[LP_A_DB_INSDATETIME]
    , @payout_id      BIGINT
    , @transaction_id   BIGINT
    , @site_transaction_id  [LP_Common].[LP_F_DESCRIPTION]
    , @idEntityUser     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

    ,@idCountry       [LP_Common].[LP_F_INT]

  SELECT
    @date_from        = CAST(JSON_VALUE(@JSON, '$.date_from') AS VARCHAR(8))
    ,@date_to       = CAST(JSON_VALUE(@JSON, '$.date_to') AS VARCHAR(8))
    ,@payout_id       = CAST(JSON_VALUE(@JSON, '$.payout_id') AS BIGINT)
    ,@transaction_id    = CAST(JSON_VALUE(@JSON, '$.transaction_id') AS BIGINT)
    ,@site_transaction_id = CAST(JSON_VALUE(@JSON, '$.merchant_id') AS VARCHAR(60))


  IF(@date_from IS NULL AND @date_to IS NOT NULL)
    SET @date_to = NULL

  IF(@date_from IS NOT NULL AND @date_to IS NULL)
    SET @date_from = NULL

  IF((@date_from IS NOT NULL AND @date_to IS NOT NULL) AND (@date_from = @date_to))
    SET @date_to = DATEADD(DAY, 1, @date_to)


  SET @idCountry = ( SELECT [idCountry] FROM  [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = 'ARG' ) 

  SELECT  @qtyAccount = COUNT([idEntityAccount]), @idEntityAccount = MAX([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [Identification] = @customer AND [Active] = 1

  SET @idEntityUser = ( SELECT [idEntityUser] FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @customer AND [Active] = 1 AND [idCountry] = @idCountry)

  IF(@qtyAccount = 1)
  BEGIN 

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
                                      AND ( [T].[idTransaction] = @transaction_id  OR ( @transaction_id =0 ) )
                                      AND ( [TRD].[InternalDescription] = @site_transaction_id OR ( @site_transaction_id IS NULL ) )
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
                        [TL1].[idTransactionLot] = @payout_id   OR ( @payout_id =0  )
                        )
                        AND
                        (
                        [T1].[idTransaction] = @transaction_id  OR ( @transaction_id =0 )
                        )
                        AND
                        (
                        ( [TRD1].[InternalDescription] = @site_transaction_id  ) OR ( @site_transaction_id IS NULL )
                        )
                        AND
                        (
                        --( ( [T1].[TransactionDate] >= @date_from ) OR ( @date_from  IS NULL ) ) AND ( ( [T1].[TransactionDate] <= @date_to ) OR ( @date_to IS NULL ) )
                        cast(T1.TransactionDate as date) BETWEEN @date_from AND @date_to OR (@date_from IS NULL AND @date_to IS NULL)
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
  END
  ELSE
  BEGIN
    SET @Status = 0
    SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
  END 
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- turn it on
END
GO


