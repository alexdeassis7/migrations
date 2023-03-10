CREATE OR ALTER PROCEDURE [LP_Operation].[CreateReferenceNumber](
	@referenciasID [LP_Operation].[Referencias_Id] READONLY
)						
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	DECLARE @idTransaction INT;
	DECLARE @idCountry INT;
	DECLARE @referenceCode varchar(8);
	DECLARE @newReferenceCode varchar(8);
	BEGIN TRY
		BEGIN TRAN
		DECLARE reference_cursor CURSOR FOR
		SELECT idNew FROM @referenciasID

		OPEN reference_cursor
		FETCH NEXT FROM reference_cursor
		INTO @idTransaction
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SELECT @idCountry = EU.idCountry FROM [LP_Operation].[Transaction] T
			INNER JOIN [LP_Entity].[EntityUser] EU ON t.idEntityUser = EU.idEntityUser
			WHERE idCountry = 150 AND idTransaction = @idTransaction

			IF (@idCountry IS NOT NULL)
			BEGIN
				SELECT TOP(1) @referenceCode = LEFT(ISNULL([ReferenceCode],'0000000'),7)
				FROM [LP_Operation].[Ticket]
				ORDER BY [ReferenceCode] DESC

				SELECT @newReferenceCode = RIGHT('0000000' + CAST(@referenceCode + 1 AS VARCHAR),7) + '0'
				UPDATE [LP_Operation].[Ticket] SET [ReferenceCode] = @newReferenceCode WHERE idTransaction = @idTransaction
			END

			FETCH NEXT FROM reference_cursor
			INTO @idTransaction
		END   
		CLOSE reference_cursor;  
		DEALLOCATE reference_cursor;  

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN


		DECLARE @TicketErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @TicketErrorSeverity INT = ERROR_SEVERITY()
		DECLARE @TicketErrorState INT = ERROR_STATE()

		RAISERROR
				(
					@TicketErrorMessage,
					@TicketErrorSeverity,
					@TicketErrorState
				);
	END CATCH
END
