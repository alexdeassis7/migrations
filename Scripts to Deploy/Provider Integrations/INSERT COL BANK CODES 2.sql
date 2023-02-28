BEGIN TRAN
DECLARE @idCountry			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountry = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'COL')

INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('1010', 'HSBC','HONG KONG AND SHANGHAI BANKING CORPORATION LIMITED', @idCountry,1,'1010')
,('1076', 'COOPCENTRAL','COOPCENTRAL', @idCountry,1,'0076')
,('1084', 'GESTION Y CONTACTO','GESTION Y CONTACTO', @idCountry,1,'0084')
,('1086', 'ASOPAGOS','ASOPAGOS', @idCountry,1,'0086')
,('1087', 'FEDECAJAS','FEDECAJAS', @idCountry,1,'0087')
,('1088', 'SIMPLE','SIMPLE', @idCountry,1,'0088')
,('1089', 'ENLACE OPERATIVO','ENLACE OPERATIVO', @idCountry,1,'0089')
,('1090', 'CORFICOLOMBIANA','CORFICOLOMBIANA', @idCountry,1,'0090')
,('1683', 'DGCPTN','DGCPTN', @idCountry,1,'0683')
,('1066', 'CORFINSURA','CORFINSURA', @idCountry,1,'0066')

ROLLBACK