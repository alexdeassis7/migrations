
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [LP_Operation].[MEX_Payout_MIFEL_Bank_Operation_Upload_PreRegister]
                                      (
                                        @BankPreRegisterLot           VARCHAR(6)
                                        , @accountWithErrors       VARCHAR(MAX)
                                        , @TransactionMechanism   [LP_Common].[LP_F_BOOL]
                                      )
AS
BEGIN
	
	DECLARE @txsWithErrors AS TABLE (idTransaction INT)
	DECLARE 
		@idStatusRejected       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idBankPreRegisterLot [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @TransactionDate        [LP_Common].[LP_A_OP_INSDATETIME]
		, @CurrencyClose        [LP_Common].[LP_F_INT]
		, @idCurrencyClient       [LP_Common].[LP_F_INT]
		, @idEntityUser         [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idCountry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		, @idProvider			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		

  BEGIN TRY

	SET @idStatusRejected = [LP_Operation].[fnGetIdStatusByCode]('Rejected')
	SET @idBankPreRegisterLot = CAST(@BankPreRegisterLot AS BIGINT)
	SET @TransactionDate = GETDATE()
	SET @idCountry = [LP_Location].fnGetIdCountyByCountryCode('MXN')
	SET @idProvider = (SELECT idProvider FROM LP_Configuration.[Provider] WHERE Code = 'MIFEL' )

	SELECT TOP 1
		@idEntityUser = idEntityUser
	FROM 
		[LP_Operation].[Transaction]
	WHERE idTransaction in (
		SELECT idTransaction 
		FROM LP_Operation.BankPreRegisterTransaction
		WHERE idBankPreRegisterLot = @idBankPreRegisterLot
	)

	SELECT
		@idCurrencyClient = [ECE].[idCurrencyTypeClient]
	FROM
		[LP_Entity].[EntityCurrencyExchange] [ECE]
	WHERE
		[ECE].[idEntityUser] = @idEntityUser
	AND [ECE].[Active] = 1

	SET @CurrencyClose = ( SELECT [CE].[idCurrencyExchange] FROM [LP_Configuration].[CurrencyExchange] [CE] WHERE [CE].[Active] = 1 AND [CE].[ActionType] = 'A' AND [CE].[CurrencyTo] = @idCurrencyClient )
	
	BEGIN TRAN
		-- GET ID TRANSACTION WITH ERRORS
		INSERT INTO @txsWithErrors(idTransaction)
		SELECT [BT].[idTransaction]
		FROM [LP_Operation].[BankPreRegisterTransaction] [BT]
		INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON [TRD].[idTransaction] = [BT].[idTransaction]
		WHERE [TRD].[RecipientAccountNumber] IN (
			SELECT CAST(value AS VARCHAR) FROM STRING_SPLIT(@accountWithErrors, ',')
		)
		AND [BT].idBankPreRegisterLot = @idBankPreRegisterLot


		-- SET TXS TO APPROVED EXCEPT THOSE WITH ERRORS
		UPDATE [LP_Operation].[BankPreRegisterTransaction]
		SET Approved = 1
		WHERE [idBankPreRegisterLot] = @idBankPreRegisterLot
		AND [idTransaction] NOT IN (SELECT [idTransaction] FROM @txsWithErrors)

		-- UPDATE PRE REGISTER LOT STATUS
		UPDATE [LP_Operation].[BankPreRegisterLot]
		SET 
			[Status] = 2, -- Verified
			[OP_UpdDateTime] = @TransactionDate,
			[DB_UpdDateTime] = @TransactionDate
		WHERE idBankPreRegisterLot = @idBankPreRegisterLot

		-- UPDATE TXS WITH ERRORS TO REJECTED
		UPDATE  [LP_Operation].[Transaction]
          SET   
            [idStatus]          = @idStatusRejected
            ,[ProcessedDate]      = @TransactionDate
            ,[idCurrencyExchangeClosed] = @CurrencyClose
          WHERE 
            [idTransaction] IN (SELECT idTransaction FROM @txsWithErrors)

          UPDATE  [LP_Operation].[TransactionDetail]
          SET   
            [idStatus] = @idStatusRejected
                
          WHERE 
            [idTransaction] IN (SELECT idTransaction FROM @txsWithErrors)

          UPDATE  [LP_Operation].[TransactionRecipientDetail]
          SET   
            [idStatus] = @idStatusRejected
          WHERE 
            [idTransaction]  IN (SELECT idTransaction FROM @txsWithErrors)
     

          UPDATE  [LP_Operation].[TransactionInternalStatus]
          SET   
            [idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'ACCERROR', 'SCM')
          WHERE 
            [idTransaction] IN (SELECT idTransaction FROM @txsWithErrors)
	COMMIT TRAN

	SELECT
            [Ticket]            = [T].[Ticket]
            , [TransactionDate]       = CONVERT(DATETIME2, [T2].[TransactionDate], 1)
            , [Amount]            = [T2].[GrossValueLP]
            , [Currency]          = [CT].[Code]
            , [LotNumber]         = [TL].[LotNumber]
            , [LotCode]           = [TL].[LotCode]
            , [Recipient]         = [TRD].[Recipient]
            , [RecipientId]         = [TRD].[RecipientCUIT]
            , [RecipientAccountNumber]    = [TRD].[RecipientAccountNumber]
            , [AcreditationDate]      = CONVERT(DATETIME2, [TRD].[TransactionAcreditationDate], 1)
            , [Description]         = [TRD].[Description]
            , [InternalDescription]     = [TRD].[InternalDescription]
            , [ConceptCode]         = [TRD].[ConceptCode]
            , [BankAccountType]       = [BAT].[Code]
            , [EntityIdentificationType]  = [EIT].[Code]
            , [InternalStatus]        = [IS].[Code]
            , [InternalStatusDescription] = [IS].[Description]
            , [idEntityUser]        = @idEntityUser
            , [idTransaction]       = [T].[idTransaction]
			, [StatusCode]      = [S].[Code]
          FROM
            [LP_Operation].[Ticket]                   [T]
              INNER JOIN [LP_Operation].[Transaction]         [T2]  ON [T].[idTransaction]          = [T2].[idTransaction]
              INNER JOIN [LP_Operation].[TransactionDetail]     [TD]  ON [T2].[idTransaction]         = [TD].[idTransaction]
              INNER JOIN [LP_Operation].[TransactionRecipientDetail]  [TRD] ON [T2].[idTransaction]         = [TRD].[idTransaction]
              INNER JOIN [LP_Operation].[TransactionLot]        [TL]  ON [T2].[idTransactionLot]        = [TL].[idTransactionLot]
              INNER JOIN [LP_Operation].[TransactionInternalStatus] [TIS] ON [T2].[idTransaction]         = [TIS].[idTransaction]
              INNER JOIN [LP_Configuration].[InternalStatus]      [IS]  ON [TIS].[idInternalStatus]       = [IS].[idInternalStatus]
              INNER JOIN [LP_Configuration].[CurrencyType]      [CT]  ON [T2].[CurrencyTypeLP]        = [CT].[idCurrencyType]
              INNER JOIN [LP_Configuration].[CurrencyType]      [CT2] ON [TRD].[idCurrencyType]       = [CT2].[idCurrencyType]
              INNER JOIN [LP_Configuration].[BankAccountType]     [BAT] ON [TRD].[idBankAccountType]      = [BAT].[idBankAccountType]
              INNER JOIN [LP_Entity].[EntityIdentificationType]   [EIT] ON [TRD].[idEntityIdentificationType] = [EIT].[idEntityIdentificationType]
        INNER JOIN [LP_Common].[Status]           [S]  ON [S].[idStatus] = [T2].[idStatus]
          WHERE
            [T].[idTransaction] IN (SELECT idTransaction FROM [LP_Operation].[BankPreRegisterTransaction] WHERE idBankPreRegisterLot = @idBankPreRegisterLot)
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK TRAN
    
		DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
		--DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
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
