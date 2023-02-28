-- 136 Banco Ganadero

DECLARE @currencyId INT;
DECLARE @countryId INT;
DECLARE @idProvider INT;


SET @currencyId =
(
    SELECT [idCurrencyType]
    FROM [LocalPaymentPROD].[LP_Configuration].[CurrencyType]
    WHERE Code = 'BOB'
);

SET @idProvider =
(
	SELECT idProvider
	FROM LP_Configuration.Provider 
	WHERE [Code] ='BGBOL'
)


SET @countryId =
(
    SELECT [idCountry]
    FROM [LocalPaymentPROD].[LP_Location].[Country]
    WHERE Name = 'BOLIVIA (PLURINATIONAL STATE OF)'
);

SELECT @countryId, 'country'
SELECT @idProvider, 'provider'
SELECT @currencyId, 'currency'


INSERT LP_Configuration.BankCode_Lookup(
BankCode, CustomBankCode, idCountry, idProvider, Active, OP_InsDateTime, OP_UpdDateTime, DB_InsDateTime, DB_UpdDateTime
)
VALUES
 ('001', '1003', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('002', '1001', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('003', '1005', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('004', '1008', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('005', '1009', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('006', '1014', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('007', '1016', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('008', '1017', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('009', '0', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('010', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('011', '75001', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('012', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('013', '75003', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('014', '3047', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('015', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('016', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('017', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('018', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('019', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('020', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('021', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('022', '3001', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('023', '3002', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('024', '3003', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('025', '3005', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('026', '3006', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('027', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('028', '3010', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('029', '3011', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('030', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('031', '3015', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('032', '3016', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('033', '3021', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('034', '3022', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('035', '3025', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('036', '3026', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('037', '3029', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('038', '3030', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('039', '3048', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('040', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('041', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('042', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('043', 'DESACTIVADO', @countryId, @idProvider,0, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('044', '74003', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('045', '1033', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('046', '1035', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('047', '74002', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('049', '1034', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('050', '27002', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('051', '3004', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('052', '1007', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('053', '53001', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('054', '53002', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('055', '0', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
,('056', '1005', @countryId, @idProvider,1, DEFAULT, DEFAULT, DEFAULT, DEFAULT)