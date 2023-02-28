DECLARE @currencyId INT;
DECLARE @countryId INT;


SET @currencyId = (
  SELECT [idCurrencyType]
  FROM [LocalPaymentProd].[LP_Configuration].[CurrencyType]
  WHERE Code = 'USD'
)

SET @countryId = (SELECT [idCountry]
FROM [LocalPaymentProd].[LP_Location].[Country]
  WHERE Name = 'PANAMA'
)

insert into LP_Location.CountryCurrency
(idCountry, idCurrencyType, Active)
values (@countryId, @currencyId, 1)

INSERT INTO [LP_Configuration].[BankCode]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active]
		   ,[SubCode]
		   ,[SubCode2]
           )
     VALUES
('1', 'BANCO NACIONAL DE PANAMA', 'BANCO NACIONAL DE PANAMA', @countryId, 1, '', ''),
('2', 'BANISTMO S.A.', 'BANISTMO S.A.', @countryId, 1, '', ''),
('3', 'CITIBANK', 'CITIBANK', @countryId, 1, '', ''),
('7', 'BANCO GENERAL', 'BANCO GENERAL', @countryId, 1, '', ''),
('18', 'DAVIVIENDA', 'DAVIVIENDA', @countryId, 1, '', ''),
('37', 'MULTIBANK', 'MULTIBANK', @countryId, 1, '', ''),
('40', 'TOWERBANK', 'TOWERBANK', @countryId, 1, '', ''),
('42', 'SCOTIABANK', 'SCOTIABANK', @countryId, 1, '', ''),
('51', 'BICSA', 'BICSA', @countryId, 1, '', ''),
('71', 'COOPERATIVA PROFESIONALES', 'COOPERATIVA PROFESIONALES', @countryId, 1, '', ''),
('77', 'CAJA DE AHORROS', 'CAJA DE AHORROS', @countryId, 1, '', ''),
('91', 'BANCO DEL PACÍFICO', 'BANCO DEL PACÍFICO', @countryId, 1, '', ''),
('106', 'METROBANK', 'METROBANK', @countryId, 1, '', ''),
('108', 'BANCO ALIADO', 'BANCO ALIADO', @countryId, 1, '', ''),
('110', 'CREDICORP BANK', 'CREDICORP BANK', @countryId, 1, '', ''),
('115', 'GLOBAL BANK', 'GLOBAL BANK', @countryId, 1, '', ''),
('116', 'BANK OF CHINA', 'BANK OF CHINA', @countryId, 1, '', ''),
('125', 'CANAL BANK', 'CANAL BANK', @countryId, 1, '', ''),
('138', 'BAC INTERNATIONAL BANK', 'BAC INTERNATIONAL BANK', @countryId, 1, '', ''),
('139', 'BCT BANK INTERNATIONAL', 'BCT BANK INTERNATIONAL', @countryId, 1, '', ''),
('147', 'MMG BANK', 'MMG BANK', @countryId, 1, '', ''),
('149', 'ST. GEORGES BANK', 'ST. GEORGES BANK', @countryId, 1, '', ''),
('150', 'BANCO AZTECA', 'BANCO AZTECA', @countryId, 1, '', ''),
('151', 'BANCO PICHINCHA PANAMA', 'BANCO PICHINCHA PANAMA', @countryId, 1, '', ''),
('156', 'BANCO DELTA', 'BANCO DELTA', @countryId, 1, '', ''),
('157', 'BANCO LAFISE', 'BANCO LAFISE', @countryId, 1, '', ''),
('158', 'BANESCO', 'BANESCO', @countryId, 1, '', ''),
('159', 'CAPITAL BANK', 'CAPITAL BANK', @countryId, 1, '', ''),
('161', 'BANISI', 'BANISI', @countryId, 1, '', ''),
('163', 'MERCANTIL BANK', 'MERCANTIL BANK', @countryId, 1, '', ''),
('165', 'BBP BANK', 'BBP BANK', @countryId, 1, '', ''),
('167', 'PRIVAL BANK', 'PRIVAL BANK', @countryId, 1, '', ''),
('170', 'UNI BANK & TRUST, INC.', 'UNI BANK & TRUST, INC.', @countryId, 1, '', ''),
('172', 'BANCO FICOHSA', 'BANCO FICOHSA', @countryId, 1, '', ''),
('175', 'BANCOLOMBIA', 'BANCOLOMBIA', @countryId, 1, '', ''),
('178', 'BI-BANK', 'BI-BANK', @countryId, 1, '', ''),
('250', 'COOPEDUC', 'COOPEDUC', @countryId, 1, '', ''),
('251', 'COOESAN', 'COOESAN', @countryId, 1, '', ''),
('252', 'CACECHI', 'CACECHI', @countryId, 1, '', ''),
('253', 'COEDUCO', 'COEDUCO', @countryId, 1, '', ''),
('254', 'COOPEVE', 'COOPEVE', @countryId, 1, '', ''),
('500', 'COOPERATIVA CRISTOBAL', 'COOPERATIVA CRISTOBAL', @countryId, 1, '', ''),
('501', 'EDIOACC', 'EDIOACC', @countryId, 1, '', ''),
('502', 'ECASESO', 'ECASESO', @countryId, 1, '', ''),
('503', 'COOPRAC, R.L.', 'COOPRAC, R.L.', @countryId, 1, '', '')


INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('CIP'
           ,'Cedula de Identidad Personal'
           ,'Cedula de Identidad Personal'
           ,@countryId
           ,1
           )

INSERT INTO [LP_Configuration].[InternalStatusType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[Active]
		   ,[OP_InsDateTime]
		   ,[OP_UpdDateTime]
           ,[DB_InsDateTime]
           ,[DB_UpdDateTime]
           ,[idCountry])
     VALUES
           ('SCM'
           ,'State Codes of Movements'
           ,'State Codes of Movements'
           ,1
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
           ,@countryId)

INSERT INTO [LP_Configuration].[BankAccountType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[Active]
		   ,[OP_InsDateTime]
		  ,[OP_UpdDateTime]
		  ,[DB_InsDateTime]
		  ,[DB_UpdDateTime]
           ,[idCountry])
     VALUES
           ('A'
		   ,'CA'
           ,'Caja de Ahorro'
           ,1
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
           ,@countryId)


INSERT INTO [LP_Configuration].[BankAccountType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[Active]
		   ,[OP_InsDateTime]
		  ,[OP_UpdDateTime]
		  ,[DB_InsDateTime]
		  ,[DB_UpdDateTime]
           ,[idCountry])
     VALUES
           ('C'
		   ,'CC'
           ,'Cuenta Corriente'
           ,1
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
           ,@countryId)

INSERT INTO [LP_Configuration].[PaymentType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active]
           ,[OP_InsDateTime]
           ,[OP_UpdDateTime]
           ,[DB_InsDateTime]
           ,[DB_UpdDateTime]
           ,[CatalogValue])
     VALUES
           ('SUPPLIERS'
           ,'Pago a Proveedores'
           ,'Pago a Proveedores'
           ,@countryId
           ,1
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
		   ,GETDATE()
           ,2)
