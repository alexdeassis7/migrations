CREATE OR ALTER PROCEDURE [LP_Configuration].[GetBlackList]
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- turn it on
	
	DECLARE @JSON XML

	SET @JSON	=
				(
					SELECT
						CAST
						(
							(
								SELECT [BeneficiaryName],[AccountNumber],[DocumentId],[isSender] FROM [LP_Configuration].[BlackList]
								FOR JSON PATH
							) AS XML
						)
				)

	SELECT @JSON

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- turn it off
END