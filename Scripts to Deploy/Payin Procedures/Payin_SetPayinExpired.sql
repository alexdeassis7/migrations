/****** Object:  StoredProcedure [LP_Operation].[Set_Payin_Expired]    Script Date: 9/5/2020 11:13:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [LP_Operation].[Payin_Set_Expired]
as
BEGIN

Declare @ExpiredStatus int = (SELECT [LP_Operation].[fnGetIdStatusByCode]('Expired'))

IF(OBJECT_ID('tempdb..#idTransactionsToExpire') IS NOT NULL)
BEGIN 
	DROP TABLE #idTransactionsToExpire 
END

	BEGIN TRY

		select 
			t.idTransaction 
		into 
			#idTransactionsToExpire 
		from 
			lp_operation.[Transaction] t
		INNER JOIN 
			LP_Operation.TransactionPayinDetail tpi on t.idTransaction = tpi.idTransaction
		WHERE
			t.idStatus = 3 --InProgress
			and tpi.ExpirationDate <= GETDATE()

		BEGIN TRANSACTION

			update LP_Operation.TransactionPayinDetail 
				set ExpirationDate  = GETUTCDATE()
			where idTransaction in (select * from #idTransactionsToExpire)

			update LP_Operation.[Transaction]
				set IdStatus = @ExpiredStatus
			where idTransaction in (select * from #idTransactionsToExpire)

			---
					
			UPDATE 
				tl
			SET 
				tl.idStatus = @ExpiredStatus
			FROM 
				LP_Operation.[TransactionLot] tl
			INNER JOIN
				LP_Operation.[Transaction] t on tl.idTransactionLot = t.idTransactionLot
			WHERE
				t.idTransaction in (select * from #idTransactionsToExpire)

				---

			UPDATE  LP_Operation.[TransactionDetail] 
			SET 
				idStatus = @ExpiredStatus 
			WHERE
				idTransaction in (select * from #idTransactionsToExpire)

				---
			UPDATE  [TIS]
			SET 
				idInternalStatus = (select idInternalStatus from LP_Configuration.InternalStatus  where code = 'EXPIRED' and idProvider = [TTP].[idProvider])
			FROM [LP_Operation].[TransactionInternalStatus] [TIS]
			INNER JOIN [LP_Operation].[Transaction] [T] ON [T].[idTransaction] = [TIS].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idTransactionTypeProvider] = [T].[idTransactionTypeProvider]
			INNER JOIN #idTransactionsToExpire [TE] ON [TE].[idTransaction] = [TIS].[idTransaction]

		COMMIT

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN


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

