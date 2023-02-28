SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Alfredo Severo
-- Create date: 30/05/2022
-- Description:	Obtiene el ultimo valor del Internal Batch Id
-- =============================================

CREATE PROCEDURE [LP_Operation].[GetLastInternalBatchNumberByProviderId]
(
	@ProviderId INT,
	@NextBatchId INT OUTPUT
)
AS BEGIN
    DECLARE @BatchId INT;
    DECLARE @currentDate DATE=GETDATE();

	SELECT @BatchId=BatchNumber
    FROM [LP_Operation].[ProviderInternalBatch]
    WHERE ProviderId=@ProviderId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    
	IF(@BatchId IS NULL)
	BEGIN
        INSERT INTO LP_Operation.ProviderInternalBatch(BatchNumber, ProviderId, LastUpdatedAt)
        VALUES(
			1, -- BatchNumber - int
			@ProviderId, -- ProviderId - int
			GETDATE() -- LastUpdatedAt - datetime
        );
        
		SELECT @NextBatchId=BatchNumber
        FROM LP_Operation.ProviderInternalBatch
        WHERE ProviderId=@ProviderId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    END;
    ELSE 
	BEGIN
        UPDATE LP_Operation.ProviderInternalBatch
        SET BatchNumber=@BatchId+1
        WHERE ProviderId=@ProviderId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    
		SELECT @NextBatchId=BatchNumber
        FROM LP_Operation.ProviderInternalBatch
        WHERE ProviderId=@ProviderId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    END;
END;
GO