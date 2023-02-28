DECLARE @idCountry INT
DECLARE @ERROR VARCHAR(max) 
DECLARE @CountryCode VARCHAR(MAX) = 'BOB'

SELECT @idCountry = idCountry FROM LP_Location.Country WHERE Code = @CountryCode

IF @idCountry IS NULL
BEGIN
		SET @ERROR = CONCAT('Country with Code: ', @CountryCode, ' DOES NOT EXIST');
		THROW 50001, @ERROR , 1;
END

IF EXISTS(SELECT TOP (1) Code FROM LP_Configuration.PayWayServices WHERE idCountry = @idCountry ORDER BY Code)
BEGIN	
	SET @ERROR  = CONCAT('Payway Service for the country with ID : ', @CountryCode, ' already Exist');
	THROW 50000, @ERROR , 1;
END

INSERT LP_Configuration.PayWayServices
(
	Code,
	[Name],
	[Description],
	idCountry,
	Active,
	OP_InsDateTime,
	OP_UpdDateTime,
	DB_InsDateTime,
	DB_UpdDateTime
)
VALUES
(   'BANKDEPO',				-- Code				- LP_F_CODE
	'Depósito Bancario',		-- Name				- LP_F_NAME
	'Depósito Bancario',		-- Description		- LP_F_DESCRIPTION
	@idCountry, 				-- idCountry		- LP_I_UNIQUE_IDENTIFIER_INT
	1,						-- Active			- LP_A_ACTIVE
	DEFAULT,					-- OP_InsDateTime	- LP_A_OP_INSDATETIME
	DEFAULT,					-- OP_UpdDateTime	- LP_A_OP_UPDDATETIME
	GETDATE(),				-- DB_InsDateTime	- LP_A_DB_INSDATETIME
	DEFAULT					-- DB_UpdDateTime	- LP_A_DB_UPDDATETIME
)