DECLARE @currencyId INT;
DECLARE @countryId INT;


SET @currencyId = (
  SELECT [idCurrencyType]
  FROM [LocalPaymentProd].[LP_Configuration].[CurrencyType]
  WHERE Code = 'PEN'
)

SET @countryId = (SELECT [idCountry]
FROM [LocalPaymentProd].[LP_Location].[Country]
  WHERE Name = 'PERU'
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
           ('001', 'BANCO CENTRAL DE RESERVA DEL PERU', 'BANCO CENTRAL DE RESERVA DEL PERU', @countryId, 1, '', ''),
			('002', 'BANCO DE CREDITO DEL PERU (BCP)', 'BANCO DE CREDITO DEL PERU (BCP)', @countryId, 1, '', ''),
			('003', 'BANCO INTERNACIONAL DEL PERU (INTERBANK)', 'BANCO INTERNACIONAL DEL PERU (INTERBANK)', @countryId, 1, '', ''),
			('007', 'CITIBANK DEL PERU S.A.', 'CITIBANK DEL PERU S.A.', @countryId, 1, '', ''),
			('009', 'BANCO SCOTIABANK PERU', 'BANCO SCOTIABANK PERU', @countryId, 1, '', ''),
			('011', 'BANCO BBVA CONTINENTAL PERU', 'BANCO BBVA CONTINENTAL PERU', @countryId, 1, '', ''),
			('018', 'BANCO DE LA NACION', 'BANCO DE LA NACION', @countryId, 1, '', ''),
			('023', 'BANCO DE COMERCIO', 'BANCO DE COMERCIO', @countryId, 1, '', ''),
			('035', 'BANCO PICHINCHA', 'BANCO PICHINCHA', @countryId, 1, '', ''),
			('038', 'BANCO INTERAMERICANO DE FINANZAS', 'BANCO INTERAMERICANO DE FINANZAS', @countryId, 1, '', ''),
			('043', 'CREDISCOTIA FINANCIERA S.', 'CREDISCOTIA FINANCIERA S.', @countryId, 1, '', ''),
			('049', 'MI BANCO', 'MI BANCO', @countryId, 1, '', ''),
			('051', 'AGROBANCO', 'AGROBANCO', @countryId, 1, '', ''),
			('053', 'BANCO GNB PERU SA', 'BANCO GNB PERU SA', @countryId, 1, '', ''),
			('054', 'BANCO FALABELLA', 'BANCO FALABELLA', @countryId, 1, '', ''),
			('055', 'BANCO RIPLEY', 'BANCO RIPLEY', @countryId, 1, '', ''),
			('056', 'BANCO SANTANDER PERU S.A.', 'BANCO SANTANDER PERU S.A.', @countryId, 1, '', ''),
			('058', 'BANCO AZTECA DEL PERU, S.A.', 'BANCO AZTECA DEL PERU, S.A.', @countryId, 1, '', ''),
			('059', 'CRAC CAT SA', 'CRAC CAT SA', @countryId, 1, '', ''),
			('060', 'ICBC PERU BANK', 'ICBC PERU BANK', @countryId, 1, '', ''),
			('061', 'JP MORGAN BANCO DE INVERSION', 'JP MORGAN BANCO DE INVERSION', @countryId, 1, '', '')


INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('DNI'
           ,'Documento nacional de identidad'
           ,'Documento nacional de identidad'
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
           ('CE'
           ,'Carnet de extranjeria'
           ,'Carnet de extranjeria'
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

INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('Passport'
           ,'Pasaporte'
           ,'Pasaporte'
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
           ('M'
		   ,'CM'
           ,'Cuenta Maestra'
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
