USE [LocalPaymentPROD]
GO

/****** Object:  StoredProcedure [LP_Operation].[MEX_ListPayOutsSabadell]    Script Date: 7/3/2022 17:08:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER     PROCEDURE [LP_Operation].[MEX_ListPayOutsSabadell]
													(
														 @json			[LP_Common].[LP_F_VMAX]
														, @country_code	[LP_Common].[LP_F_C3]
													)
AS
	BEGIN
		DECLARE @idCountry	INT
		SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @country_code AND [Active] = 1 )

		DECLARE @idPaymentType INT
		SET @idPaymentType = (SELECT [idPaymentType] FROM [LP_Configuration].[PaymentType] WHERE [CatalogValue] = CAST(JSON_VALUE(@JSON, '$.PaymentType') AS VARCHAR(1))  AND [idCountry] = @idCountry  AND [Active] = 1 ) 

		DECLARE @Amount [LP_Common].[LP_F_DECIMAL]
		SET @Amount = ( SELECT [LP_Common].[fnConvertIntToExtendedDecimalAmount](CAST(JSON_VALUE(@JSON, '$.amount') AS BIGINT) ) )

		DECLARE @idMerchant INT
		SET @idMerchant = CAST(JSON_VALUE(@JSON, '$.idMerchant') AS INT )

		DECLARE @idSubMerchant INT
		SET @idSubMerchant = CAST(JSON_VALUE(@JSON, '$.idSubMerchant') AS INT )

		DECLARE @dateTo	[LP_Common].[LP_A_DB_INSDATETIME]
		SET @dateTo =  CAST(JSON_VALUE(@JSON, '$.dateTo') AS DATETIME )

		DECLARE @internalFiles	INT
		SET @internalFiles =  CAST(JSON_VALUE(@JSON, '$.internalFiles') AS INT )
		
		DECLARE @bankInclude VARCHAR(MAX)
		SET @bankInclude =   CAST(JSON_QUERY(@JSON, '$.bankIncludes') AS VARCHAR(MAX) )
		IF @bankInclude is not null BEGIN
			SET @bankInclude= REPLACE (@bankInclude, '[','');
			SET @bankInclude= REPLACE (@bankInclude, ']','');
			SET @bankInclude= REPLACE (@bankInclude,  '"','');
		END 
		print '@bankInclude: '
	    print @bankInclude

		DECLARE @bankExclude VARCHAR(MAX)
		SET @bankExclude =  CAST(JSON_QUERY(@JSON, '$.bankExcludes') AS VARCHAR(MAX) )
		IF @bankExclude is not null BEGIN
			SET @bankExclude= REPLACE (@bankExclude, '[','');
			SET @bankExclude= REPLACE (@bankExclude, ']','');
			SET @bankExclude= REPLACE (@bankExclude,  '"','');
		END 
		print '@bankExclude: '
		print  @bankExclude


		DECLARE @RESP xml


		DECLARE @TempPayoutBody TABLE
			(
				[idx]							INT IDENTITY (1,1)
				,[LotNumber]						VARCHAR(MAX)
				,[Ticket]							VARCHAR(MAX)
				,[TransactionDate]					VARCHAR(MAX)
				,[InternalDescription]				VARCHAR(MAX)
				,[LastName]							VARCHAR(MAX)
				,[SubMerchantIdentification]		VARCHAR(MAX)
				,[GrossValueClient]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdings]					[LP_Common].[LP_F_DECIMAL]
				,[TaxWithholdingsARBA]				[LP_Common].[LP_F_DECIMAL]
				,[NetAmount]						[LP_Common].[LP_F_DECIMAL]
				,[LocalTax]							[LP_Common].[LP_F_DECIMAL]
				,[ToProcess]						[LP_Common].[LP_F_BOOL] NULL
				,[Repeated]							[LP_Common].[LP_F_BOOL] DEFAULT(0)
				,[HistoricalyRepetead]				[LP_Common].[LP_F_BOOL] DEFAULT(0)
				,[idTransaction]					BIGINT
				,[rowNumber]						INT
			)
		
		INSERT INTO @TempPayoutBody ([LotNumber],[Ticket],[TransactionDate],[InternalDescription],[LastName],[SubMerchantIdentification],[GrossValueClient],[TaxWithholdings],[TaxWithholdingsARBA],[NetAmount],[LocalTax],[ToProcess],[idTransaction])
		SELECT [TL].[LotNumber]
					,[T2].[Ticket]
					,[T].[TransactionDate]
					,[TRD].[InternalDescription]
					,[EU].[LastName]
					,[ESM].[SubMerchantIdentification]
					,[T].[GrossValueClient]
					,[TD].[TaxWithholdings]
					,[TD].[TaxWithholdingsARBA] 
					,[TD].[NetAmount]
					,[TD].[LocalTax]
					, 0
					,[T].[idTransaction]
				FROM
					[LP_Operation].[Transaction]									[T]
						INNER JOIN	[LP_Operation].[TransactionLot]					[TL]	ON	[T].[idTransactionLot]				= [TL].[idTransactionLot]
						INNER JOIN	[LP_Operation].[TransactionRecipientDetail]		[TRD]	ON	[T].[idTransaction]					= [TRD].[idTransaction]
						INNER JOIN	[LP_Operation].[TransactionDetail]				[TD]	ON	[T].[idTransaction]					= [TD].[idTransaction]
						INNER JOIN	[LP_Configuration].[BankAccountType]			[BAT]	ON	[TRD].[idBankAccountType]			= [BAT].[idBankAccountType] 
																							AND [BAT].[idCountry]					= @idCountry
						INNER JOIN	[LP_Operation].[Ticket]							[T2]	ON	[T].[idTransaction]					= [T2].[idTransaction]
						INNER JOIN  [LP_Configuration].[BankCode]					[BC]	ON	[BC].[idBankCode]					= [TRD].[idBankCode]
						INNER JOIN  [LP_Entity].[EntityUser]						[EU]	ON  [T].[idEntityUser]					= [EU].[idEntityUser]
						INNER JOIN [LP_Common].[Status]								[ST]	ON	[ST].idStatus = [T].[idStatus]
						LEFT JOIN  [LP_Entity].[EntityIdentificationType]			[EIT]	ON	[EIT].[idEntityIdentificationType]	= [TRD].[idEntityIdentificationType]
						 LEFT JOIN	[LP_Operation].[TransactionEntitySubMerchant]	[TESM]	ON	[TESM].[idTransaction]				= [T].[idTransaction]
						 LEFT JOIN	[LP_Entity].[EntitySubMerchant]					[ESM]	ON	[ESM].[idEntitySubMerchant]			= [TESM].[idEntitySubMerchant]

				WHERE
					[TRD].[idPaymentType] = @idPaymentType
					AND [ST].Code = 'Received'
					AND ( [ESM].[idEntityUser] = @idMerchant OR @idMerchant IS NULL )
					AND ( [T].[TransactionDate] <= @dateTo OR @dateTo IS NULL )
					AND ( [ESM].[idEntitySubMerchant] = @idSubMerchant OR @idSubMerchant IS NULL)
					AND [TD].[NetAmount] > 0
					AND (BC.Code in (SELECT value FROM STRING_SPLIT ( @bankInclude , ',') ) or @bankInclude IS NULL)
					AND (BC.Code not in (SELECT value FROM STRING_SPLIT ( @bankExclude , ',') ) or @bankExclude IS NULL)
					
		if(@internalFiles > 0)
		BEGIN
			DELETE [TEMP]
			FROM @TempPayoutBody [TEMP]
			INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD]  ON [TRD].[idTransaction] = [TEMP].[idTransaction]
			WHERE LEFT([TRD].[RecipientAccountNumber], 3) != '156'
		END
		ELSE
		BEGIN
			DELETE [TEMP]
			FROM @TempPayoutBody [TEMP]
			INNER JOIN [LP_Operation].[TransactionRecipientDetail] [TRD]  ON [TRD].[idTransaction] = [TEMP].[idTransaction]
			WHERE LEFT([TRD].[RecipientAccountNumber], 3) = '156'
		END

		--IF(@operationType = 1) -- Received
		--BEGIN
		--	DELETE [TEMP]
		--	FROM @TempPayoutBody [TEMP]
		--	INNER JOIN LP_Operation.BankPreRegisterTransaction BT ON BT.idTransaction = TEMP.idTransaction
		--END
		--ELSE IF(@operationType = 2) -- Approveds
		--BEGIN
		--	DELETE [TEMP]
		--	FROM @TempPayoutBody [TEMP]
		--	LEFT JOIN LP_Operation.BankPreRegisterTransaction BT ON BT.idTransaction = [TEMP].idTransaction
		--	LEFT JOIN LP_Operation.BankPreRegisterLot BL ON BL.idBankPreRegisterLot = BT.idBankPreRegisterLot
		--	WHERE BL.[Status] = 1 OR BL.idBankPreRegisterLot IS NULL
		--END
		--ELSE IF (@operationType = 3) -- Pending approval
		--BEGIN
		--	DELETE [TEMP]
		--	FROM @TempPayoutBody [TEMP]
		--	INNER JOIN LP_Operation.BankPreRegisterTransaction BT ON BT.idTransaction = TEMP.idTransaction
		--	INNER JOIN LP_Operation.BankPreRegisterLot BL ON BL.idBankPreRegisterLot = BT.idBankPreRegisterLot AND BL.[Status] = 2
		--END
		
		
		/* FILTERING PAYOUTS BY AMOUNT BLOCK: INI */  

			DECLARE
				@qtyRowsTemp BIGINT
				, @idxRowsTemp BIGINT
				, @ActualAmount DECIMAL(18, 6)
				, @Acum DECIMAL(18, 6)

			SET @Acum = 0

			SET @idxRowsTemp = 1	
			SET @qtyRowsTemp = (SELECT COUNT(*) FROM @TempPayoutBody)
			
			DECLARE @id INT
			SET @id = 0
			UPDATE @TempPayoutBody SET @id = rowNumber = @id + 1

			IF(@qtyRowsTemp > 0 AND @Amount IS NOT NULL)
			BEGIN
				WHILE(@idxRowsTemp <= @qtyRowsTemp)
					BEGIN
						SELECT @ActualAmount = [NetAmount] FROM @TempPayoutBody WHERE [rowNumber] = @idxRowsTemp ORDER BY rowNumber ASC

						SET @Acum = @Acum + @ActualAmount

						IF( ( @Acum <= @Amount ) OR  ( @Amount IS NULL) )  
							BEGIN
								UPDATE @TempPayoutBody SET [ToProcess] = 1 WHERE [rowNumber] = @idxRowsTemp
								
							END
						ELSE
							BEGIN
								SET @Acum = @Acum - @ActualAmount
							END

						SET @idxRowsTemp = @idxRowsTemp + 1
					END
			END
			ELSE 
			BEGIN
				UPDATE @TempPayoutBody SET [ToProcess] = 1
			END

			DELETE FROM @TempPayoutBody WHERE [ToProcess] = 0


			/* FILTERING PAYOUTS TO PROCESS BY AMOUNT BLOCK: FIN */


			/* FILTERING REPEATED / UNIQUE AMOUNTS: INI*/

			--DECLARE @NotRepeatedAmountRowsSet AS TABLE (Amount DECIMAL(18,2))
			--DECLARE @RepeatedAmountRowsSet AS TABLE (Amount DECIMAL(18,2))
			--DECLARE @UniqueRepeatedAmountRowsSet AS TABLE (idTransaction BIGINT)

			---- GETING UNIQUE AMOUNT TXS
			--INSERT INTO @NotRepeatedAmountRowsSet(Amount)
			--SELECT [TEMP].[NetAmount]
			--FROM @TempPayoutBody [TEMP]
			--GROUP BY 
			--	[TEMP].[NetAmount]
			--HAVING
			--	COUNT(*) = 1

			---- GETING REPEATED AMOUNT TXS
			--INSERT INTO @RepeatedAmountRowsSet(Amount)
			--SELECT [TEMP].[NetAmount]
			--FROM @TempPayoutBody [TEMP]
			--GROUP BY 
			--	[NetAmount]
			--HAVING
			--	COUNT(*) > 1

			---- GETTING MIN ID OF REPEATED AMOUNTS
			--INSERT INTO @UniqueRepeatedAmountRowsSet(idTransaction)
			--select min([TEMP].idtransaction)
			--FROM @TempPayoutBody [TEMP]
			--inner join @RepeatedAmountRowsSet rr on rr.Amount = [TEMP].[NetAmount]
			--group by rr.Amount

			--IF(@includeDuplicateAmounts = 0)
			--BEGIN
			--	DELETE FROM @TempPayoutBody
			--	WHERE [idTransaction] NOT IN (
			--		SELECT idTransaction FROM @TempPayoutBody TEMP
			--		INNER JOIN @NotRepeatedAmountRowsSet RR ON RR.Amount = TEMP.NetAmount
			--	) AND idTransaction NOT IN (
			--		SELECT idTransaction FROM @UniqueRepeatedAmountRowsSet
			--	)
			--END

			/* FILTERING REPEATED / UNIQUE AMOUNTS: FIN*/

			/* CHECKING REPEATED TICKETS IN PAYOUTS BLOCK: INI */ 
			;WITH Duplicates AS
			(
				SELECT
					Ticket,
					RowNum = ROW_NUMBER() OVER (PARTITION BY Ticket ORDER BY idx)
				FROM
					@TempPayoutBody
			)
			UPDATE @TempPayoutBody
			SET Repeated = 1
			FROM Duplicates d
			INNER JOIN @TempPayoutBody t ON t.Ticket = d.Ticket
			WHERE d.Ticket = t.Ticket
			AND d.RowNum > 1
			/* CHECKING REPEATED TICKETS IN PAYOUTS BLOCK: FIN */

			/* CHECKING HISTORIC REPEATED TICKETS IN PAYOUTS BLOCK: INI */ 
			;WITH Duplicates AS
			(
				SELECT
					[Ticket],
					RowNum = ROW_NUMBER() OVER (PARTITION BY [Ticket] ORDER BY [idTicket])
				FROM
				   [LP_Operation].[Ticket]
			)
			UPDATE @TempPayoutBody
			SET HistoricalyRepetead = 1
			FROM Duplicates d
			INNER JOIN @TempPayoutBody t ON t.Ticket = d.Ticket
			WHERE d.Ticket = t.Ticket
			AND d.RowNum > 1
			/* CHECKING HISTORIC REPEATED TICKETS IN PAYOUTS BLOCK: FIN */

			SET @RESP = (SELECT CAST ((SELECT [LotNumber]
					,[Ticket]
					,[TransactionDate]
					,[InternalDescription]
					,[LastName]
					,[SubMerchantIdentification]
					,[GrossValueClient]
					,[TaxWithholdings]
					,[TaxWithholdingsARBA] 
					,[LocalTax]
					,[NetAmount]
					,[Repeated]
					,[HistoricalyRepetead]
					FROM @TempPayoutBody
					FOR JSON PATH) AS XML)
					)
		
		SELECT @RESP
END
GO


