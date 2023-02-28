CREATE OR ALTER PROCEDURE [LP_Operation].[RevertDownload]
                                      (
                                        @json			VARCHAR(MAX)
										,@country_code		VARCHAR(10)
                                      )
AS
BEGIN

  BEGIN TRY

    DECLARE
        @idStatusReceived       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
		,@idCountry	INT
		,@idProvider INT
		DECLARE @TempTxsToMove AS TABLE (idTransaction INT)

		SET @idStatusReceived = [LP_Operation].[fnGetIdStatusByCode]('Received')
		SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )
		SET @idProvider = (SELECT TOP(1) [P].[idProvider] FROM [LP_Configuration].[Provider] [P]
							INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [P].[idProvider]
							INNER JOIN [LP_Configuration].[TransactionType] [TT] ON [TT].[idTransactionType] = [TTP].[idTransactionType]
							WHERE [TT].[Code] = 'PODEPO' AND [P].[idCountry] = @idCountry)

		INSERT INTO @TempTxsToMove
		SELECT idTransaction FROM [LP_Operation].[Ticket] WHERE Ticket IN (SELECT value FROM OPENJSON(@json, '$') as Tickets)
 

          BEGIN TRANSACTION
			UPDATE	[LP_Operation].[TransactionLot]
			SET		[idStatus] = @idStatusReceived
			WHERE	[idTransactionLot] IN(SELECT [idTransactionLot] FROM [LP_Operation].[Transaction] WHERE [idTransaction] IN (SELECT [idTransactionLot] FROM @TempTxsToMove))

			UPDATE  [LP_Operation].[Transaction]
			SET   [idStatus] = @idStatusReceived
			WHERE [idTransaction] IN(SELECT [idTransaction] FROM @TempTxsToMove)

			UPDATE  [LP_Operation].[TransactionRecipientDetail]
			SET   [idStatus] = @idStatusReceived
			WHERE [idTransaction] IN(SELECT [idTransaction] FROM @TempTxsToMove)

			UPDATE  [LP_Operation].[TransactionDetail]
			SET   [idStatus] = @idStatusReceived
			WHERE [idTransaction] IN(SELECT [idTransaction] FROM @TempTxsToMove)

			UPDATE  [LP_Operation].[TransactionInternalStatus]
			SET   [idInternalStatus] = [LP_Operation].[fnGetIdInternalStatusByCodeCatalogCountryProvider](@idCountry, @idProvider, 'RECI', 'SCM')
			WHERE [idTransaction] IN(SELECT [idTransaction] FROM @TempTxsToMove)

          COMMIT TRAN

          SELECT CAST ((SELECT
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
            , [idEntityUser]        = T2.idEntityUser
            , [idTransaction]       = T2.idTransaction
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
			[T2].[idTransaction] IN (SELECT [idTransaction] FROM @TempTxsToMove)
			FOR JSON PATH) AS XML)

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0    

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
