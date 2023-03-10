SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Operation].[CreateTicket](
	@qtyTickets	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
	@idxTicket	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
	@referenciasID [LP_Operation].[Referencias_Id] READONLY
)						
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	BEGIN TRY
		BEGIN TRAN
			DECLARE @Timestamp [LP_Common].[LP_F_C14]
			DECLARE @fxTicket  [LP_Common].[LP_F_C14]
			DECLARE @intTicket BIGINT

			SET @Timestamp = CAST(DATEDIFF(SECOND, '19700101', GETDATE()) AS VARCHAR(10))
			SET @fxTicket = [LP_Operation].[fnGetTicketForPayoutTransactionV2]()
			SET @intTicket = CAST(@fxTicket AS BIGINT)

			WHILE(@idxTicket <= @qtyTickets)
			BEGIN

				DECLARE @idTX	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				SET @idTX = (SELECT [idNew] FROM @referenciasID WHERE [IDX] = @idxTicket)
				
				INSERT INTO [LP_Operation].[Ticket] ( [Ticket],[idTransaction], [TicketDate] ) VALUES( CAST(@intTicket as varchar(14)), @idTX, @Timestamp )

				SET @intTicket = @intTicket + 1
				SET @idxTicket = @idxTicket + 1
			END
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
