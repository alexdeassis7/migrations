DECLARE @dollarId INT;
DECLARE @countryId INT;


SET @dollarId = (
  SELECT [idCurrencyType]
  FROM [LocalPaymentProd].[LP_Configuration].[CurrencyType]
  WHERE Code = 'PYG'
)

SET @countryId = (SELECT [idCountry]
FROM [LocalPaymentProd].[LP_Location].[Country]
  WHERE Name = 'PARAGUAY'
)

insert into LP_Location.CountryCurrency
(idCountry, idCurrencyType, Active)
values (@countryId, @dollarId, 1)

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
('1', 'BANCO AMAMBAY S.A.', 'BANCO AMAMBAY S.A.', @countryId, 1, '', ''),
('2', 'BANCO ATLAS S.A.', 'BANCO ATLAS S.A.', @countryId, 1, '', ''),
('3', 'BANCO BASA S.A', 'BANCO BASA S.A', @countryId, 1, '', ''),
('4', 'BANCO BILBAO VIZCAYA ARGENTARIA PARAGUAY S.A.', 'BANCO BILBAO VIZCAYA ARGENTARIA PARAGUAY S.A.', @countryId, 1, '', ''),
('5', 'BANCO BUSAIF S.A. DE INVERSION Y FOMENTO', 'BANCO BUSAIF S.A. DE INVERSION Y FOMENTO', @countryId, 1, '', ''),
('6', 'BANCO CENTRAL DEL PARAGUAY', 'BANCO CENTRAL DEL PARAGUAY', @countryId, 1, '', ''),
('7', 'BANCO COMERCIAL PARAGUAYO SA', 'BANCO COMERCIAL PARAGUAYO SA', @countryId, 1, '', ''),
('8', 'BANCO CONTINENTAL SAECA', 'BANCO CONTINENTAL SAECA', @countryId, 1, '', ''),
('9', 'BANCO CORPORACION S.A.', 'BANCO CORPORACION S.A.', @countryId, 1, '', ''),
('10', 'BANCO DE DESARROLLO DEL PARAGUAY S.A.', 'BANCO DE DESARROLLO DEL PARAGUAY S.A.', @countryId, 1, '', ''),
('11', 'BANCO DE INVERSIONES DEL PARAGUAY', 'BANCO DE INVERSIONES DEL PARAGUAY', @countryId, 1, '', ''),
('12', 'BANCO DE LA NACION ARGENTINA', 'BANCO DE LA NACION ARGENTINA', @countryId, 1, '', ''),
('13', 'BANCO DO BRASIL S.A.', 'BANCO DO BRASIL S.A.', @countryId, 1, '', ''),
('14', 'BANCO FAMILIAR S.A.E.C.A.', 'BANCO FAMILIAR S.A.E.C.A.', @countryId, 1, '', ''),
('15', 'BANCO FINAMERICA SAECA.', 'BANCO FINAMERICA SAECA.', @countryId, 1, '', ''),
('16', 'BANCO GENERAL S.A.', 'BANCO GENERAL S.A.', @countryId, 1, '', ''),
('17', 'BANCO GNB PARAGUAY S.A.', 'BANCO GNB PARAGUAY S.A.', @countryId, 1, '', ''),
('18', 'BANCO ITAPUA SAECA', 'BANCO ITAPUA SAECA', @countryId, 1, '', ''),
('19', 'BANCO ITAU PARAGUAY S.A.', 'BANCO ITAU PARAGUAY S.A.', @countryId, 1, '', ''),
('20', 'BANCO NACIONAL DE FOMENTO', 'BANCO NACIONAL DE FOMENTO', @countryId, 1, '', ''),
('21', 'BANCO NACIONAL DE TRABAJADORES', 'BANCO NACIONAL DE TRABAJADORES', @countryId, 1, '', ''),
('22', 'BANCO PARA LA COMERCIALIZACION Y LA PRODUCCION S.A', 'BANCO PARA LA COMERCIALIZACION Y LA PRODUCCION S.A', @countryId, 1, '', ''),
('23', 'BANCO PARAGUAYO ORIENTAL DE INVERSION Y FOMENTO S.A.', 'BANCO PARAGUAYO ORIENTAL DE INVERSION Y FOMENTO S.A.', @countryId, 1, '', ''),
('24', 'BANCO REGIONAL S.A.E.C.A.', 'BANCO REGIONAL S.A.E.C.A.', @countryId, 1, '', ''),
('25', 'Banco RIO S.A.E.C.A.', 'Banco RIO S.A.E.C.A.', @countryId, 1, '', ''),
('26', 'BOLPAR SOCIEDAD ANONIMA', 'BOLPAR SOCIEDAD ANONIMA', @countryId, 1, '', ''),
('27', 'BOLSA DE VALORES Y PRODUCTOS DE ASUNCION S.A.', 'BOLSA DE VALORES Y PRODUCTOS DE ASUNCION S.A.', @countryId, 1, '', ''),
('28', 'BRITISH AMERICAN TOBACCO PRODUCTORA DE CIGARILLOS S.A.', 'BRITISH AMERICAN TOBACCO PRODUCTORA DE CIGARILLOS S.A.', @countryId, 1, '', ''),
('29', 'CITIBANK N.A.', 'CITIBANK N.A.', @countryId, 1, '', ''),
('30', 'CRISOL Y ENCARNACIN FINANCIERA S.A.', 'CRISOL Y ENCARNACIN FINANCIERA S.A.', @countryId, 1, '', ''),
('31', 'FINANCIERA EL COMERCIO S.A.E.C.A.', 'FINANCIERA EL COMERCIO S.A.E.C.A.', @countryId, 1, '', ''),
('32', 'FINANCIERA EXPORTADORA PARAGUAYA S.A.', 'FINANCIERA EXPORTADORA PARAGUAYA S.A.', @countryId, 1, '', ''),
('33', 'FINANCIERA PARAGUAYO JAPONESA SAECA', 'FINANCIERA PARAGUAYO JAPONESA SAECA', @countryId, 1, '', ''),
('34', 'FONPLATA', 'FONPLATA', @countryId, 1, '', ''),
('35', 'GRUPO INTERNACIONAL DE FINANZAS S.A .C.A.', 'GRUPO INTERNACIONAL DE FINANZAS S.A .C.A.', @countryId, 1, '', ''),
('36', 'HSBC BANK PARAGUAY SA', 'HSBC BANK PARAGUAY SA', @countryId, 1, '', ''),
('37', 'SUDAMERIS BANK S.A.E.C.A.', 'SUDAMERIS BANK S.A.E.C.A.', @countryId, 1, '', ''),
('38', 'SUMMA ASESORIES', 'SUMMA ASESORIES', @countryId, 1, '', ''),
('39', 'VISION BANCO S.A.E.C.A.', 'VISION BANCO S.A.E.C.A.', @countryId, 1, '', ''),
('40', 'FINLANTINA S.A DE FINANZAS', 'FINLANTINA S.A DE FINANZAS', @countryId, 1, '', '')


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
