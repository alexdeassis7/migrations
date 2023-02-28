--begin tran
DECLARE @currencyId INT;
DECLARE @countryId INT;


SET @currencyId = (
  SELECT [idCurrencyType]
  FROM [LocalPaymentProd].[LP_Configuration].[CurrencyType]
  WHERE Code = 'PYG'
)

SET @countryId = (SELECT [idCountry]
FROM [LocalPaymentProd].[LP_Location].[Country]
  WHERE Name = 'PARAGUAY'
)

--insert into LP_Location.CountryCurrency
--(idCountry, idCurrencyType, Active)
--values (@countryId, @dollarId, 1)

INSERT INTO [LP_Configuration].[BankCode] VALUES
('003', 'BCP', 'BCP', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('004', 'VISION BANCO SAECA', 'VISION BANCO SAECA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('005', 'BANCO REGIONAL SAECA', 'BANCO REGIONAL SAECA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('006', 'SUDAMERIS BANK', 'SUDAMERIS BANK', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('007', 'BANCO BASA S.A.', 'BANCO BASA S.A.', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('008', 'MINISTERIO DE HACIENDA', 'MINISTERIO DE HACIENDA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('009', 'BANCOP', 'BANCOP', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('010', 'BANCO NACIONAL DE FOMENTO', 'BANCO NACIONAL DE FOMENTO', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('011', 'BANCO DO BRASIL SA', 'BANCO DO BRASIL SA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('012', 'BANCO RIO', 'BANCO RIO', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('013', 'BANCO FAMILIAR SAECA', 'BANCO FAMILIAR SAECA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('014', 'BANCO DE LA NACION ARGENTINA', 'BANCO DE LA NACION ARGENTINA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('015', 'BANCO ATLAS S.A.', 'BANCO ATLAS S.A.', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('017', 'BANCO ITAU', 'BANCO ITAU', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('020', 'BANCO CONTINENTAL SAECA', 'BANCO CONTINENTAL SAECA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('021', 'FINANCIERA EL COMERCIO', 'FINANCIERA EL COMERCIO', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('022', 'CRISOL Y ENCARNACION FINANCIERA', 'CRISOL Y ENCARNACION FINANCIERA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('023', 'FINLATINA S.A. DE FINANZAS', 'FINLATINA S.A. DE FINANZAS', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('024', 'FINANCIERA PARAGUAYO JAPONESA', 'FINANCIERA PARAGUAYO JAPONESA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('025', 'FINANCIERA EXPORTADORA PARAGUAYA S.A.', 'FINANCIERA EXPORTADORA PARAGUAYA S.A.', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('027', 'INTERFISA', 'INTERFISA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('028', 'SOLAR AHORRO Y FINANZAS SAECA', 'SOLAR AHORRO Y FINANZAS SAECA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('029', 'TU FINANCIERA', 'TU FINANCIERA', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('030', 'AFD', 'AFD', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('039', 'BID', 'BID', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('040', 'FIC S.A. DE FINANZAS', 'FIC S.A. DE FINANZAS', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('041', 'AFD NEGOCIOS FIDUCIARIOS', 'AFD NEGOCIOS FIDUCIARIOS', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('042', 'Fondo de la Garantia de Depositos', 'Fondo de la Garantia de Depositos', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('060', 'GNB Fusion', 'GNB Fusion', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('065', 'CITIBANK', 'CITIBANK', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')
INSERT INTO [LP_Configuration].[BankCode] VALUES
('070', 'GNB PARAGUAY S.A.', 'GNB PARAGUAY S.A.', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), '', '')



INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('CI'
           ,'Cedula de Identidad'
           ,'Cedula de Identidad'
           ,@countryId
           ,1
           )

INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('RUC'
           ,'Registro Unico de Contribuyentes'
           ,'Registro Unico de Contribuyentes'
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

		   --rollback