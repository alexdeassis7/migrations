-- ================================================
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Alfredo Severo
-- Create date: 30/05/2022
-- Description:	Obtiene el ultimo valor del Internal Batch Id
-- =============================================

CREATE FUNCTION [LP_Operation].[fnGetLastInternalBatchNumberByProviderId](@providerId INT)
RETURNS INT
AS BEGIN
    DECLARE @BatchId INT;
    DECLARE @currentDate DATE=GETDATE();
    
	SELECT @BatchId=BatchNumber
    FROM [LP_Operation].[ProviderInternalBatch]
    WHERE ProviderId=@providerId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    
	IF(@BatchId IS NULL)
	BEGIN
        INSERT INTO LP_Operation.ProviderInternalBatch(BatchNumber, ProviderId, LastUpdatedAt)
        VALUES(
			1, -- BatchNumber - int
			@providerId, -- ProviderId - int
			GETDATE() -- LastUpdatedAt - datetime
        );
        
		SELECT @BatchId=BatchNumber
        FROM LP_Operation.ProviderInternalBatch
        WHERE ProviderId=@providerId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    END;
    ELSE 
	BEGIN
        UPDATE LP_Operation.ProviderInternalBatch
        SET BatchNumber=@BatchId+1
        WHERE ProviderId=@providerId AND CAST(LastUpdatedAt AS DATE)=@currentDate;
    
		SELECT @BatchId=BatchNumber
        FROM LP_Operation.ProviderInternalBatch
        WHERE ProviderId=@providerId AND CAST(LastUpdatedAt AS DATE)=@currentDate;

    END;

    RETURN @BatchId;
END;
GO

