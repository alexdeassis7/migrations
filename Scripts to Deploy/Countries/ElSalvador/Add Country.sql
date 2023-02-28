DECLARE @currencyId INT;
DECLARE @countryId INT;


SET @currencyId = (
  SELECT [idCurrencyType]
  FROM [LocalPaymentProd].[LP_Configuration].[CurrencyType]
  WHERE Code = 'USD'
)

SET @countryId = (SELECT [idCountry]
FROM [LocalPaymentProd].[LP_Location].[Country]
  WHERE Name = 'El Salvador'
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
('1', 'Banco Popular', 'Banco Popular', @countryId, 1, '', ''),
('2', 'Banco del Progreso', 'Banco del Progreso', @countryId, 1, '', ''),
('3', 'Banco BHD León', 'Banco BHD León', @countryId, 1, '', ''),
('4', 'Banco de Reservas', 'Banco de Reservas', @countryId, 1, '', ''),
('6', 'Banco Santa Cruz', 'Banco Santa Cruz', @countryId, 1, '', ''),
('7', 'Citibank', 'Citibank', @countryId, 1, '', ''),
('8', 'Scotiabank', 'Scotiabank', @countryId, 1, '', ''),
('9', 'Asoc. Popular', 'Asoc. Popular', @countryId, 1, '', ''),
('10', 'Banco López de Haro', 'Banco López de Haro', @countryId, 1, '', ''),
('11', 'Banco BDI', 'Banco BDI', @countryId, 1, '', ''),
('12', 'Banco Promerica', 'Banco Promerica', @countryId, 1, '', ''),
('13', 'Banco Vimenca', 'Banco Vimenca', @countryId, 1, '', ''),
('14', 'Banco Caribe', 'Banco Caribe', @countryId, 1, '', ''),
('15', 'Asoc. Cibao', 'Asoc. Cibao', @countryId, 1, '', ''),
('16', 'Banco de las Americas', 'Banco de las Americas', @countryId, 1, '', ''),
('17', 'Banesco (Banco Multiple)', 'Banesco (Banco Multiple)', @countryId, 1, '', ''),
('18', 'Banco de Ahorro y Credito Ademi', 'Banco de Ahorro y Credito Ademi', @countryId, 1, '', ''),
('19', 'Asoc. La Nacional', 'Asoc. La Nacional', @countryId, 1, '', ''),
('21', 'Banco Multiple Lafise', 'Banco Multiple Lafise', @countryId, 1, '', ''),
('23', 'Banco Empire', 'Banco Empire', @countryId, 1, '', ''),
('24', 'Bellbank', 'Bellbank', @countryId, 1, '', ''),
('25', 'Banco Atlántico', 'Banco Atlántico', @countryId, 1, '', ''),
('26', 'Banco Unión', 'Banco Unión', @countryId, 1, '', ''),
('28', 'Banco Multiple Activo', 'Banco Multiple Activo', @countryId, 1, '', '')


INSERT INTO [LP_Entity].[EntityIdentificationType]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idCountry]
           ,[Active])
     VALUES
           ('DUI'
           ,'Documento Unico de Identidad'
           ,'Documento Unico de Identidad'
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
           ('CR'
           ,'Carnet de Residencia'
           ,'Carnet de Residencia'
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
