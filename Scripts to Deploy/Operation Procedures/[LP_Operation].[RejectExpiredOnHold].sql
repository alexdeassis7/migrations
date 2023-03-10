CREATE OR ALTER PROCEDURE [LP_Operation].[RejectExpiredOnHold]
as
BEGIN

Declare @ExpiredStatus int = (SELECT [LP_Operation].[fnGetIdStatusByCode]('Rejected'))

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
		WHERE
			t.idStatus = [LP_Operation].[fnGetIdStatusByCode]('OnHold') --InProgress
			and t.ExpirationDate < GETDATE()

		BEGIN TRANSACTION

        UPDATE  [LP_Operation].[Transaction]
        SET   
          [idStatus]          = @ExpiredStatus
        WHERE 
          [idTransaction] in (select * from #idTransactionsToExpire)

        UPDATE  [LP_Operation].[TransactionDetail]
        SET   
          [idStatus] = @ExpiredStatus
        WHERE 
          [idTransaction] in (select * from #idTransactionsToExpire)

        UPDATE  [LP_Operation].[TransactionRecipientDetail]
        SET   
          [idStatus] = @ExpiredStatus
        WHERE 
          [idTransaction] in (select * from #idTransactionsToExpire)

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

		  	UPDATE  [TIS]
			SET 
				idInternalStatus = (select idInternalStatus from LP_Configuration.InternalStatus  where code = 'REJECTED' and idProvider = [TTP].[idProvider])
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

