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
           ('0001', 'BANCO CENTRAL', 'BANCO CENTRAL', @countryId, 1, '', ''),
			('0002', 'FOMENTO', 'FOMENTO', @countryId, 1, '', ''),
			('0010', 'PICHINCHA', 'PICHINCHA', @countryId, 1, '', ''),
			('0017', 'GUAYAQUIL', 'GUAYAQUIL', @countryId, 1, '', ''),
			('0019', 'TERRITORIAL', 'TERRITORIAL', @countryId, 1, '', ''),
			('0020', 'LLOYDS BANK', 'LLOYDS BANK', @countryId, 1, '', ''),
			('0024', 'CITIBANK', 'CITIBANK', @countryId, 1, '', ''),
			('0025', 'MACHALA', 'MACHALA', @countryId, 1, '', ''),
			('0026', 'UNIBANCO', 'UNIBANCO', @countryId, 1, '', ''),
			('0029', 'LOJA', 'LOJA', @countryId, 1, '', ''),
			('0030', 'PACIFICO', 'PACIFICO', @countryId, 1, '', ''),
			('0032', 'INTERNACIONAL', 'INTERNACIONAL', @countryId, 1, '', ''),
			('0034', 'AMAZONAS', 'AMAZONAS', @countryId, 1, '', ''),
			('0035', 'AUSTRO', 'AUSTRO', @countryId, 1, '', ''),
			('0036', 'PRODUBANCO', 'PRODUBANCO', @countryId, 1, '', ''),
			('0037', 'BOLIVARIANO', 'BOLIVARIANO', @countryId, 1, '', ''),
			('0039', 'COMERCIAL DE MANABI', 'COMERCIAL DE MANABI', @countryId, 1, '', ''),
			('0040', 'BANCO PROMERICA', 'BANCO PROMERICA', @countryId, 1, '', ''),
			('0042', 'RUMINAHUI', 'RUMINAHUI', @countryId, 1, '', ''),
			('0043', 'DEL LITORAL', 'DEL LITORAL', @countryId, 1, '', ''),
			('0045', 'SUDAMERICANO', 'SUDAMERICANO', @countryId, 1, '', ''),
			('0050', 'COFIEC', 'COFIEC', @countryId, 1, '', ''),
			('0059', 'SOLIDARIO', 'SOLIDARIO', @countryId, 1, '', ''),
			('0060', 'BANCO PROCREDIT', 'BANCO PROCREDIT', @countryId, 1, '', ''),
			('0062', 'BANCO CAPITAL S.A. CORFINSA', 'BANCO CAPITAL S.A. CORFINSA', @countryId, 1, '', ''),
			('0085', 'MUTUALISTA IMBABURA', 'MUTUALISTA IMBABURA', @countryId, 1, '', ''),
			('0086', 'MUTUALISTA PICHINCHA', 'MUTUALISTA PICHINCHA', @countryId, 1, '', ''),
			('0087', 'MUTUALISTA AMBATO', 'MUTUALISTA AMBATO', @countryId, 1, '', ''),
			('0088', 'MUTUALISTA AZUAY BAAZEC', 'MUTUALISTA AZUAY BAAZEC', @countryId, 1, '', ''),
			('0140', 'ECUATORIANO DE LA VIVIENDA', 'ECUATORIANO DE LA VIVIENDA', @countryId, 1, '', ''),
			('9964', 'FINANCIERA FINANCOOP', 'FINANCIERA FINANCOOP', @countryId, 1, '', ''),
			('9965', 'COOP. AHORRO Y CREDITO PROGRESO', 'COOP. AHORRO Y CREDITO PROGRESO', @countryId, 1, '', ''),
			('9966', 'DELBANK S.A.', 'DELBANK S.A.', @countryId, 1, '', ''),
			('9967', 'DINERS CLUB', 'DINERS CLUB', @countryId, 1, '', ''),
			('9968', 'PACIFICARD', 'PACIFICARD', @countryId, 1, '', ''),
			('9969', 'COOP. TULCAN', 'COOP. TULCAN', @countryId, 1, '', ''),
			('9970', 'COOP. PABLO MUNOZ VEGA', 'COOP. PABLO MUNOZ VEGA', @countryId, 1, '', ''),
			('9971', 'COOP. CALCETA LTDA.', 'COOP. CALCETA LTDA.', @countryId, 1, '', ''),
			('9972', 'COOP. CAMARA DE COMERCIO QUITO', 'COOP. CAMARA DE COMERCIO QUITO', @countryId, 1, '', ''),
			('9974', 'COOP. JUVENTUD ECUATORIANA PROGRESISTA LTDA.', 'COOP. JUVENTUD ECUATORIANA PROGRESISTA LTDA.', @countryId, 1, '', ''),
			('9975', 'COOP. AHO Y CREDITO 23 de JULIO', 'COOP. AHO Y CREDITO 23 de JULIO', @countryId, 1, '', ''),
			('9976', 'COOP. AHO Y CREDITO SANTA ANA', 'COOP. AHO Y CREDITO SANTA ANA', @countryId, 1, '', ''),
			('9977', 'COOP. ALIANZA DEL VALLE LTDA.', 'COOP. ALIANZA DEL VALLE LTDA.', @countryId, 1, '', ''),
			('9978', 'COOP AHO Y CREDITO DESARROLLO PUEBLOS', 'COOP AHO Y CREDITO DESARROLLO PUEBLOS', @countryId, 1, '', ''),
			('9979', 'COOP. RIOBAMBA', 'COOP. RIOBAMBA', @countryId, 1, '', ''),
			('9980', 'COOP. COMERCIO LTDA PORTOVIEJO', 'COOP. COMERCIO LTDA PORTOVIEJO', @countryId, 1, '', ''),
			('9981', 'COOP. CHONE LTDA.', 'COOP. CHONE LTDA.', @countryId, 1, '', ''),
			('9982', 'COOP. CACPECO', 'COOP. CACPECO', @countryId, 1, '', ''),
			('9983', 'COOP. ATUNTAQUI', 'COOP. ATUNTAQUI', @countryId, 1, '', ''),
			('9984', 'COOP. GUARANDA', 'COOP. GUARANDA', @countryId, 1, '', ''),
			('9985', 'COOP AHO Y CREDITO SANTA ROSA', 'COOP AHO Y CREDITO SANTA ROSA', @countryId, 1, '', ''),
			('9986', 'COOP. AHO Y CREDITO EL SAGRARIO', 'COOP. AHO Y CREDITO EL SAGRARIO', @countryId, 1, '', ''),
			('9987', 'COOP. OSCUS', 'COOP. OSCUS', @countryId, 1, '', ''),
			('9988', 'COOP. LA DOLOROSA', 'COOP. LA DOLOROSA', @countryId, 1, '', ''),
			('9989', 'COOP AHO Y CREDITO MANUEL GODOY', 'COOP AHO Y CREDITO MANUEL GODOY', @countryId, 1, '', ''),
			('9990', 'COOP. AHO Y CREDITO NACIONAL', 'COOP. AHO Y CREDITO NACIONAL', @countryId, 1, '', ''),
			('9991', 'COOP AHO Y CREDITO SAN JOSE', 'COOP AHO Y CREDITO SAN JOSE', @countryId, 1, '', ''),
			('9993', 'COOP. AHO Y CREDITO JARDIN AZUAYO', 'COOP. AHO Y CREDITO JARDIN AZUAYO', @countryId, 1, '', ''),
			('9994', 'COOP. COTOCOLLAO', 'COOP. COTOCOLLAO', @countryId, 1, '', ''),
			('9995', 'COOP. 29 DE OCTUBRE', 'COOP. 29 DE OCTUBRE', @countryId, 1, '', ''),
			('9997', 'COOP. PEQ. EMPRESA DE PASTAZA', 'COOP. PEQ. EMPRESA DE PASTAZA', @countryId, 1, '', ''),
			('9998', 'COOP. ANDALUCIA', 'COOP. ANDALUCIA', @countryId, 1, '', '')


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
