SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		Alfredo Severo
-- Create date: 07/06/2022
-- Description:	Removes all Empty Spaces, Unexpected characters and returns just A-Z and 0-9
-- =============================================
CREATE FUNCTION LP_Common.fnNormalizeToAlphaNumeric
(
    @accountNumber VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

    DECLARE @normalized VARCHAR(MAX);

    -- Here the characters to replace
    DECLARE @charsToReplace VARCHAR(MAX) = ';,.-/_*[]{}`!="?+()*&%$#!@`|^~'
    --PRINT LEN(@charsToReplace)
    --PRINT LEN(@accountNumber)


    SET @normalized = TRIM(REPLACE(TRANSLATE(@accountNumber, @charsToReplace, REPLICATE(CHAR(32), LEN(@charsToReplace))), ' ', ''));

    --Return the result of the function
    RETURN @normalized;

-- FOR DEBUG
--SELECT @normalized
END;
GO