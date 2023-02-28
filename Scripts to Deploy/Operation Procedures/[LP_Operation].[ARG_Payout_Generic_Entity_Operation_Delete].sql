/****** Object:  StoredProcedure [LP_Operation].[ARG_Payout_Generic_Entity_Operation_Delete]    Script Date: 6/3/2020 8:30:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [LP_Operation].[ARG_Payout_Generic_Entity_Operation_Delete]
																						(
																							@Customer				[LP_Common].[LP_F_C50]
																							, @JSON					NVARCHAR(MAX)
																							, @TransactionMechanism [LP_Common].[LP_F_BOOL]
																						)
		AS
		BEGIN

			BEGIN TRY

					IF OBJECT_ID('tempdb..#LotTrans') IS NOT NULL DROP TABLE #LotTrans

					DECLARE
						@idTransactionMechanism		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @qtyAccount				[LP_Common].[LP_F_INT]
						, @idEntityAccount			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @Message					[LP_Common].[LP_F_DESCRIPTION]
						, @Status					[LP_Common].[LP_F_BOOL]
						, @idCountry				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @StatusCanc				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @jsonResult				XML
						, @qtyRows					[LP_Common].[LP_F_INT]
						, @idxRows					[LP_Common].[LP_F_INT]
						, @idTransactionLot			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @idTransaction			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
						, @ValidOperation			[LP_Common].[LP_F_BOOL]

					CREATE TABLE #LotTrans
					(
						[idTransIntTemp]				INT IDENTITY(1,1)
						, [Transactions]				NVARCHAR(MAX)
						, [idTransactionLot]			VARCHAR(100)
						, [idTransaction]				VARCHAR(100)		
						, [StatusObservation]			VARCHAR(100)
					)

					/*--------------------INICIO HOTFIX 0033-----------------*/
					----CODIGO COMENTADO AQUÍ,  Y AGREGADO Y  MODFICADO MAS ABAJO
					--IF(@TransactionMechanism = 1)
					--BEGIN
					--	SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL')

					--	SELECT
					--		@idEntityUser		= [EU].[idEntityUser]
					--		, @idEntityAccount	= [EA].[idEntityUser]
					--	FROM
					--		[LP_Entity].[EntityUser]							[EU]
					--			INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser]	= [EU].[idEntityUser]
					--	WHERE
					--		[EU].[Active] = 1
					--		AND [EA].[Active] = 1
					--		AND [EA].[UserSiteIdentification] = @customer

					--	SET @qtyAccount = ( SELECT COUNT([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [UserSiteIdentification] = @Customer AND [Active] = 1 )
					--END	
					--ELSE
					--BEGIN
					--	SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_AUTO')

					--	SELECT
					--		@idEntityUser		= [EU].[idEntityUser]
					--		, @idEntityAccount	= [EA].[idEntityAccount]
					--	FROM
					--		[LP_Entity].[EntityUser]							[EU]
					--			INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
					--			INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser] = [EU].[idEntityUser]
					--	WHERE
					--		[EU].[Active] = 1
					--		AND [EAC].[Active] = 1
					--		AND [EA].[IsAdmin] = 1
					--		AND [EAC].[Identification] = @customer				

					--	SET @qtyAccount = ( SELECT COUNT([idEntityApiCredential]) FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @Customer AND [Active] = 1 )
					--END
					/*--------------------FIN HOTFIX 0033-----------------*/
					INSERT  INTO #LotTrans ([Transactions], [idTransaction], [idTransactionLot])
					SELECT * FROM OPENJSON(@JSON)
					WITH
					(		
						[Transactions]					NVARCHAR(MAX) AS JSON
					)
					AS [Lot]
					CROSS APPLY OPENJSON ([Lot].[Transactions])
					WITH
					(
						[idTransaction]					VARCHAR(100) '$.idTransaction',
						[idTransactionLot]				VARCHAR(100) '$.idTransactionLot'
					)AS [Transactions]


					/*-------------------INICIO HOTFIX 0033------------------*/
					
					   /*Seria necesario enviar por HEADER de API el cod de pais. Para salir del paso por el momento, se puede recuperar este por medio de la TX/Lote que se intenta eliminar*/
					
						DECLARE @country_code			[LP_Common].[LP_F_C3]

						SELECT TOP 1 @country_code= C.[ISO3166_1_ALFA003]  FROM #LotTrans LT
							LEFT JOIN LP_Operation.[Transaction] T ON T.idTransactionLot=LT.idTransactionLot
							LEFT JOIN [LP_Entity].[EntityUser] EU ON EU.idEntityUser=T.idEntityUser
							LEFT JOIN [LP_Location].Country C ON C.idCountry=EU.idCountry


						IF(@TransactionMechanism = 1)
						BEGIN
							SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_MANUAL')

							SELECT
								@idEntityUser		= [EU].[idEntityUser]
								, @idEntityAccount	= [EA].[idEntityUser]
							FROM
								[LP_Entity].[EntityUser]							[EU]
									INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser]	= [EU].[idEntityUser]
							WHERE
								[EU].[Active] = 1
								AND [EA].[Active] = 1
								AND [EA].[UserSiteIdentification] = @customer

							SET @qtyAccount = ( SELECT COUNT([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [UserSiteIdentification] = @Customer AND [Active] = 1 )
						END	
						ELSE
						BEGIN
							SET @idTransactionMechanism = (SELECT [idTransactionMechanism] FROM [LP_Configuration].[TransactionMechanism] WHERE [Code] = 'MEC_AUTO')

			IF @country_code='COL' OR @country_code = 'BRA' OR @country_code = 'URY' OR @country_code = 'MEX' OR @country_code = 'CHL'
				BEGIN
					SELECT
						@idEntityUser		= [EU].[idEntityUser]
						, @idEntityAccount	= [EA].[idEntityAccount]
					FROM
						[LP_Entity].[EntityUser]							[EU]
							INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
							INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[Identification] = [EAC].[Identification]
							INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EAC].[idCountry]
					WHERE
						[EU].[Active] = 1
						AND [EAC].[Active] = 1
						AND [EA].[Active] = 1
						AND [C].[Active] = 1
						AND [EA].[IsAdmin] = 1
						AND [EAC].[Identification] = @Customer
						AND [C].[ISO3166_1_ALFA003] = @country_code
				END
				ELSE
				BEGIN

					SELECT
						@idEntityUser		= [EU].[idEntityUser]
						, @idEntityAccount	= [EA].[idEntityAccount]
					FROM
						[LP_Entity].[EntityUser]							[EU]
							INNER JOIN [LP_Security].[EntityApiCredential]	[EAC]	ON [EAC].[idEntityUser]	= [EU].[idEntityUser]
							INNER JOIN [LP_Security].[EntityAccount]		[EA]	ON [EA].[idEntityUser] = [EU].[idEntityUser]
							INNER JOIN [LP_Location].[Country]				[C]		ON [C].[idCountry] = [EAC].[idCountry]
					WHERE
						[EU].[Active] = 1
						AND [EAC].[Active] = 1
						AND [EA].[Active] = 1
						AND [C].[Active] = 1
						AND [EA].[IsAdmin] = 1
						AND [EAC].[Identification] = @customer
						AND [C].[ISO3166_1_ALFA003] = @country_code

					--SET @qtyAccount = ( SELECT COUNT([idEntityApiCredential]) FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @Customer AND [Active] = 1 )

				END


					SET @qtyAccount =
									(
										SELECT
											COUNT([EAC].[idEntityApiCredential])
										FROM
											[LP_Security].[EntityApiCredential] [EAC]
												INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EAC].[idCountry]
										WHERE
											[EAC].[Active] = 1
											AND [C].[Active] = 1
											AND [EAC].[Identification] = @Customer
											AND [C].[ISO3166_1_ALFA003] = @country_code
									)
						END

					/*-------------------FIN HOTFIX 0033------------------*/

					SET @qtyRows		= (SELECT COUNT(*) FROM #LotTrans)
					SET @idXRows		= 1
					SET @ValidOperation	= 0


					IF(@qtyRows >= 1)
					BEGIN

						WHILE(@idxRows <= @qtyRows)
						BEGIN

							SET @idTransactionLot = (SELECT [idTransactionLot] FROM #LotTrans WHERE [idTransIntTemp] = @idxRows)
			
							/*--------------------INICIO HOTFIX 0033-----------------*/
							IF exists (SELECT idTransaction FROM #LotTrans WHERE [idTransaction] NOT IN(-1))
							BEGIN
							SET @idTransaction = (SELECT TOP 1 idTransaction FROM #LotTrans WHERE [idTransaction] NOT IN(-1))
							END
							ELSE
							BEGIN 
							SET @idTransaction = (SELECT TOP 1 [idTransaction] FROM [LP_Operation].[Transaction] WHERE [idTransactionLot] = @idTransactionLot AND Active=1)
							END
							/*--------------------FIN HOTFIX 0033-----------------*/

							IF([LP_Security].[fnGetValidEntityUSerOperation](@idTransaction, @idEntityUser) = 1)
							BEGIN
								SET @ValidOperation = 1
								--CONTINUE
							END
							ELSE
							BEGIN
								SET @ValidOperation = 0
								BREAK
							END

							SET @idxRows = @idxRows + 1
						END

					END
					ELSE
					BEGIN
						SET @Status = 0
						SET @Message = 'NO ROWS TO CANCEL.'
					END

					IF(@ValidOperation = 1)
					BEGIN

						SET @idCountry = [LP_Location].[fnGetIdCountyByidEntityUser](@idEntityUser)	

						IF(@qtyAccount = 1)
						BEGIN	

							SET @StatusCanc = (SELECT [idStatus] FROM [LP_Common].[Status] WHERE [Code] = 'Canceled' AND [Active] = 1)

							BEGIN TRANSACTION

							UPDATE #LotTrans
								SET [StatusObservation] =
														CASE
															WHEN [S].[Code] IN('Received') THEN 'OK'
															ELSE 'ERROR::STATUS'
														END
							FROM
								#LotTrans										[LT]
									INNER JOIN [LP_Operation].[Transaction]		[T]		ON ([T].[idTransaction]		= [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
									INNER JOIN [LP_Common].[Status]				[S]		ON [T].[idStatus]			= [S].[idStatus]
									INNER JOIN [LP_Operation].[TransactionLot]	[TL]	ON [LT].[idTransactionLot]	= [TL].[idTransactionLot]
							WHERE T.Active=1

						
							UPDATE #LotTrans SET [StatusObservation] = 'ERROR::NF' WHERE [StatusObservation] IS NULL

							/* UPDATE POR TRANSACCION */

							UPDATE [LP_Operation].[Transaction]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								#LotTrans [LT]
									INNER JOIN [LP_Operation].[Transaction] [T] ON [LT].[idTransaction] = [T].[idTransaction]
							WHERE
								[LT].[StatusObservation] = 'OK'
								AND [LT].[idTransaction] NOT IN(-1)

							/* UPDATE POR LOTE COMPLETO */
							UPDATE [LP_Operation].[Transaction]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								#LotTrans [LT]
									INNER JOIN [LP_Operation].[Transaction] [T] ON [LT].[idTransactionLot] = [T].[idTransactionLot]
							WHERE
								[LT].[StatusObservation] = 'OK'
								AND [LT].[idTransaction] IN(-1)

							UPDATE [LP_Operation].[TransactionLot]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								#LotTrans [LT]
									INNER JOIN [LP_Operation].[TransactionLot] [TL] ON [LT].[idTransactionLot] = [TL].[idTransactionLot]
							WHERE
								[LT].[StatusObservation] = 'OK'
								AND [LT].[idTransaction] IN(-1)

							/* UPDATE STATUS EN TABLAS RELACIONADAS */

							UPDATE [LP_Operation].[TransactionDetail]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionDetail]			[TD]		ON [T].[idTransaction]		= [TD].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_CustomerInformation].[TransactionCustomerInfomation]
							SET
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]											[T]
									INNER JOIN #LotTrans												[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_CustomerInformation].[TransactionCustomerInfomation]	[TCI]		ON [T].[idTransaction]		= [TCI].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionProvider]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionProvider]			[TP]		ON [T].[idTransaction]		= [TP].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionRecipientDetail]
							SET
								[idStatus] = @StatusCanc,
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionRecipientDetail]	[TRD]		ON [T].[idTransaction]		= [TRD].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionFromTo]
							SET
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionFromTo]			[TFT]		ON [T].[idTransaction]		= [TFT].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionInternalStatus]
							SET
								[Active] = 0,
								idInternalStatus = 437
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionInternalStatus]	[TIS]		ON [T].[idTransaction]		= [TIS].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[Ticket]
							SET
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]								[T]
									INNER JOIN #LotTrans									[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[Ticket]						[TIK]		ON [T].[idTransaction]		= [TIK].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionCollectedAndPaidStatus]
							SET
								[Active] = 0
							FROM
								[LP_Operation].[Transaction]										[T]
									INNER JOIN #LotTrans											[LT]		ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
									INNER JOIN [LP_Operation].[TransactionCollectedAndPaidStatus]	[TCPS]		ON [T].[idTransaction]		= [TCPS].[idTransaction]
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'

							UPDATE [LP_Operation].[TransactionEntitySubMerchant]
							SET
								[Active] = 0
							FROM
								[LP_Operation].[TransactionEntitySubMerchant]		[TESM]
									INNER JOIN [LP_Operation].[Transaction]			[T]		ON [T].[idTransaction]		= [TESM].[idTransaction]
									INNER JOIN #LotTrans							[LT]	ON [T].[idTransactionLot]	= [LT].[idTransactionLot]									
							WHERE
								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
								AND [LT].[StatusObservation] = 'OK'					

							/* RECALCULAR LOTE */

							UPDATE [LP_Operation].[TransactionLot]
							SET
								[GrossAmount]		= [SUMMARY].[GrossAmount]
								, [NetAmount]		= [SUMMARY].[NetAmount]
								, [AccountBalance]	= [SUMMARY].[AccountBalance]
							FROM
								[LP_Operation].[TransactionLot] [TL]
									INNER JOIN 
									(
										SELECT
											[idTransactionLot]	= [TL].[idTransactionLot]
											, [GrossAmount]		= SUM([TD].[GrossAmount])
											, [NetAmount]		= SUM([TD].[NetAmount])
											, [AccountBalance]	= NULL
										FROM
											#LotTrans													[LT]
												INNER JOIN [LP_Operation].[Transaction]					[T]			ON [T].[idTransactionLot]	= [LT].[idTransactionLot]
												INNER JOIN [LP_Operation].[TransactionLot]				[TL]		ON [T].[idTransactionLot]	= [TL].[idTransactionLot]
												INNER JOIN [LP_Operation].[TransactionDetail]			[TD]		ON [T].[idTransaction]		= [TD].[idTransaction]
										WHERE
											[LT].[StatusObservation] = 'OK'
											AND [T].[Active] = 1
										GROUP BY
											[TL].[idTransactionLot]	
									) [SUMMARY] ON [TL].idTransactionLot = [SUMMARY].idTransactionLot

							COMMIT TRAN

							/* SELECT FINAL */
							SET @jsonResult = 
											(
												SELECT
													CAST
													(
														(
															SELECT	
																[idTransactionLot]	= [TL].[idTransactionLot]
																, [idStatus]		= [TL].[idStatus]
																, [Status]			= [STL].[Code]
																, [Transactions]	= 
																					ISNULL
																					(
																						(
																							SELECT
																								[idTransaction]												= [T].[idTransaction]
																								, [idTransactionLot]										= [T].[idTransactionLot]
																								, [idStatus]												= [T].[idStatus]
																								, [Status]													= [STAT].[Code]
																								, [StatusObservation]										= [LTI].[StatusObservation]
																							FROM
																								[LP_Operation].[Transaction]								[T]
																									INNER JOIN [LP_Common].[Status]							[STAT]		ON [STAT].[idStatus]		= [T].[idStatus]
																									INNER JOIN #LotTrans									[LTI]		ON [T].[idTransactionLot]	= [LTI].[idTransactionLot]
																							WHERE
																								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
																							FOR JSON PATH
																						),
																						(
																							SELECT
																								[idTransaction]												= [LT].[idTransaction]
																								, [idTransactionLot]										= [LT].[idTransactionLot]
																								, [idStatus]												= 0
																								, [Status]													= ''
																								, [StatusObservation]										= [LT].[StatusObservation]
																							FOR JSON PATH
																						)  
																					)
															FROM
																#LotTrans										[LT]
																	LEFT JOIN [LP_Operation].[TransactionLot]	[TL]	ON [LT].[idTransactionLot]	= [TL].[idTransactionLot]
																	LEFT JOIN [LP_Common].[Status]				[STL]	ON [TL].[idStatus]			= [STL].[idStatus]
															FOR JSON PATH
														) 
													AS XML)
											)

							SELECT @jsonResult
						END
						ELSE
						BEGIN
							SET @Status = 0
							SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
						END

					END
					ELSE
					BEGIN

						UPDATE #LotTrans SET [StatusObservation] = 'ERROR::STATUS' WHERE [StatusObservation] IS NULL

						SET @jsonResult = 
											(
												SELECT
													CAST
													(
														(
															SELECT	
																[idTransactionLot]	= [TL].[idTransactionLot]
																, [idStatus]		= [TL].[idStatus]
																, [Status]			= [STL].[Code]
																, [Transactions]	= 
																					ISNULL
																					(
																						(
																							SELECT
																								[idTransaction]												= [T].[idTransaction]
																								, [idTransactionLot]										= [T].[idTransactionLot]
																								, [idStatus]												= [T].[idStatus]
																								, [Status]													= [STAT].[Code]
																								, [StatusObservation]										= [LTI].[StatusObservation]
																							FROM
																								[LP_Operation].[Transaction]								[T]
																									INNER JOIN [LP_Common].[Status]							[STAT]		ON [STAT].[idStatus]		= [T].[idStatus]
																									INNER JOIN #LotTrans									[LTI]		ON [T].[idTransactionLot]	= [LTI].[idTransactionLot]
																							WHERE
																								([T].[idTransaction] = [LT].[idTransaction] OR ([LT].[idTransaction] = -1)) AND [T].[idTransactionLot] = [LT].[idTransactionLot]
																							FOR JSON PATH
																						),
																						(
																							SELECT
																								[idTransaction]												= [LT].[idTransaction]
																								, [idTransactionLot]										= [LT].[idTransactionLot]
																								, [idStatus]												= 0
																								, [Status]													= ''
																								, [StatusObservation]										= [LT].[StatusObservation]
																							FOR JSON PATH
																						)  
																					)
															FROM
																#LotTrans										[LT]
																	LEFT JOIN [LP_Operation].[TransactionLot]	[TL]	ON [LT].[idTransactionLot]	= [TL].[idTransactionLot]
																	LEFT JOIN [LP_Common].[Status]				[STL]	ON [TL].[idStatus]			= [STL].[idStatus]
															FOR JSON PATH
														) 
													AS XML)
											)

							SELECT @jsonResult

						SET @Status = 0
						SET @Message = 'OPERATION INVALID. CLIENT HAS NOT EXECUTED THE UPDATE'
					END

					IF OBJECT_ID('tempdb..#LotTrans') IS NOT NULL DROP TABLE #LotTrans

			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN

				DECLARE @ErrorMessage NVARCHAR(4000) = 'INTERNAL ERROR'
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
		
		
		
