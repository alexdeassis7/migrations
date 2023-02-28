begin tran

declare  @idEntityUserUry     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@merchantMexico nvarchar(255) = 'Payoneer Mexico',
@merchantMexicoId     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCountryMexico      [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idCurrencyTypeMexico   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryMexico = 150
set @idCurrencyTypeMexico = 2446

insert into LP_Entity.EntityMerchant
([Description], idEntityBusinessNameType, Active)
values (@merchantMexico, 1, 1)

set @merchantMexicoId = SCOPE_IDENTITY()  

insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values (@merchantMexico, @merchantMexico, 'danielra@payoneer.com', '', '', 2, 4,@merchantMexicoId , 4, 1, @idCountryMexico, '', 'LPPAYMXN',1)

set @idEntityUserUry =  SCOPE_IDENTITY() 

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserUry, 17, 1)

insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserUry, @idCurrencyTypeMexico, 2446, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (@idCurrencyTypeMexico, @idCountryMexico, 2, @idEntityUserUry, 0.18, 0.18, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, @idCountryMexico, 2, @idEntityUserUry, 0.18, 0.18, 1, 1)

----CROSS ---

SELECT @entityAccountId = [idEntityAccount]
FROM [LP_Security].[EntityAccount]
WHERE [Identification] = '000001500001'

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserUry, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000001500001', 'EAQP#UMX2', @idEntityUserUry, @idCountryMexico, 1)



select @idEntityUserUry = idEntityUser from LP_Entity.EntityUser where LastName = 'Payoneer Mexico'

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
select Description, SubMerchantIdentification,@idEntityUserUry,0,0,1,SubMerchantCode,SubMerchantAddress,0,IsCorporate,'0.180000',CommissionCurrencyPO from LP_Entity.EntitySubMerchant where idEntityUser = 16 
--values ('Airbnb', 'Airbnb', @idEntityUserUry, 0, 0, 1, '', '', 0, 1,'1.300000',2493)


-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
  'MIFEL',
  'MIFEL',
  'MIFEL',
  @idCountryMexico,
  1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[PayWayServices] ([Code], [Name], [Description], [idCountry], [Active])
VALUES (
  'BANKDEPO',
  'Depósito Bancario',
  'Depósito Bancario',
  @idCountryMexico,
  1
)

SET @idPayWayService = SCOPE_IDENTITY()  

SELECT @idProvider = idProvider FROM LP_Configuration.[Provider] WHERE [idCountry] = @idCountryMexico

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
  @idProvider,
  @idPayWayService,
  1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[InternalStatusType](Code, [Name], [Description], [Active], [idCountry], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime])
VALUES('SCM', 'State Codes of Movements', 'State Codes of Movements', 1, @idCountryMexico, GETDATE(), GETDATE(), GETDATE(), GETDATE())
SET @idInternalStatusType = SCOPE_IDENTITY()  


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountryMexico, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryMexico, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryMexico, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, '1', 'Recibido', 'El archivo se cargo exitosamente y se encuentra formado en', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, '2', 'Cargado', 'El archivo se cargo exitosamente por un usuario adicional', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, '3', 'Procesado', 'El archivo ya fue tomado por el proceso .BAT y no pu.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountryMexico, 1, '4', 'No procesa', 'Fallo la ejecucion del archivo', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryMexico, 1, '5', 'Aplicado e', 'Todas las operaciones dentro del archivo se aplicaron.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryMexico, 1, '6', 'Aplicado p', 'Fallo la ejecucion de algunas operaciones dentro del archiv', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryMexico, 1, '7', 'Rechazado', 'El usuario autorizador, rechazo la ejecucion del archivo.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryMexico, 1, '8', 'Cancelado', 'El mismo usuario que cargo el archivo, detuvo la.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountryMexico, 1, 'ACCERROR', 'Account Er', 'Falló la validación de la cuenta.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountryMexico, 1, 'SUC', 'Executed', 'Tx ejecutada.', @idInternalStatusType, 0, 1)

-- Payment Type
INSERT INTO [LP_Configuration].[PaymentType]([Code], [Name], [Description], [idCountry], [Active], [CatalogValue])
VALUES(
  'SUPPLIERS',
  'Pago a Proveedores',
  'Pago a Proveedores',
  @idCountryMexico,
  1,
  2
)


INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('002','BANAMEX','  Banco Nacional de México', @idCountryMexico, 1, ''),
('006','BANCOMEXT','  Banco Nacional de Comercio Exterior', @idCountryMexico, 1, ''),
('009','BANOBRAS',' Banco Nacional de Obras y Servicios Públicos', @idCountryMexico, 1, ''),
('012','BBVA BANCOMER','  BBVA Bancomer', @idCountryMexico, 1, ''),
('014','SANTANDER','  Banco Santander (México)', @idCountryMexico, 1, ''),
('019','BANJERCITO',' Banco Nacional del Ejército', @idCountryMexico, 1, ''),
('021','HSBC',' HSBC México', @idCountryMexico, 1, ''),
('030','BAJIO','  Banco del Bajío', @idCountryMexico, 1, ''),
('032','IXE','  IXE Banco', @idCountryMexico, 1, ''),
('036','INBURSA','  Banco Inbursa', @idCountryMexico, 1, ''),
('037','INTERACCIONES','  Banco Interacciones', @idCountryMexico, 1, ''),
('042','MIFEL','  Banca Mifel', @idCountryMexico, 1, ''),
('044','SCOTIABANK',' Scotiabank Inverlat', @idCountryMexico, 1, ''),
('058','BANREGIO',' Banco Regional de Monterrey', @idCountryMexico, 1, ''),
('059','INVEX','  Banco Invex', @idCountryMexico, 1, ''),
('060','BANSI','  Bansi', @idCountryMexico, 1, ''),
('062','AFIRME',' Banca Afirme', @idCountryMexico, 1, ''),
('072','BANORTE','  Banco Mercantil del Norte', @idCountryMexico, 1, ''),
('102','THE ROYAL BANK',' The Royal Bank of Scotland México', @idCountryMexico, 1, ''),
('103','AMERICAN EXPRESS',' American Express Bank (México)', @idCountryMexico, 1, ''),
('106','BAMSA','  Bank of America México', @idCountryMexico, 1, ''),
('108','TOKYO','  Bank of Tokyo-Mitsubishi UFJ (México)', @idCountryMexico, 1, ''),
('110','JP MORGAN','  Banco J.P. Morgan', @idCountryMexico, 1, ''),
('112','BMONEX',' Banco Monex', @idCountryMexico, 1, ''),
('113','VE POR MAS',' Banco Ve Por Mas', @idCountryMexico, 1, ''),
('116','ING','  ING Bank (México)', @idCountryMexico, 1, ''),
('124','DEUTSCHE BANK','  Deutsche Bank México', @idCountryMexico, 1, ''),
('126','CREDIT SUISSE','  Banco Credit Suisse (México)', @idCountryMexico, 1, ''),
('127','AZTECA',' Banco Azteca', @idCountryMexico, 1, ''),
('128','AUTOFIN','  Banco Autofin México', @idCountryMexico, 1, ''),
('129','BARCLAYS',' Barclays Bank México', @idCountryMexico, 1, ''),
('130','COMPARTAMOS','  Banco Compartamos', @idCountryMexico, 1, ''),
('131','BANCO FAMSA','  Banco Ahorro Famsa', @idCountryMexico, 1, ''),
('132','BMULTIVA',' Banco Multiva', @idCountryMexico, 1, ''),
('133','ACTINVER',' Banco Actinver', @idCountryMexico, 1, ''),
('134','WAL-MART',' Banco Wal-Mart de México Adelante', @idCountryMexico, 1, ''),
('135','NAFIN','  Nacional Financiera', @idCountryMexico, 1, ''),
('136','INTERBANCO',' Inter Banco', @idCountryMexico, 1, ''),
('137','BANCOPPEL','  BanCoppel', @idCountryMexico, 1, ''),
('138','ABC CAPITAL','  ABC Capital', @idCountryMexico, 1, ''),
('139','UBS BANK',' UBS Bank México', @idCountryMexico, 1, ''),
('140','CONSUBANCO',' Consubanco', @idCountryMexico, 1, ''),
('141','VOLKSWAGEN',' Volkswagen Bank', @idCountryMexico, 1, ''),
('143','CIBANCO','  CIBanco', @idCountryMexico, 1, ''),
('145','BBASE','  Banco Base', @idCountryMexico, 1, ''),
('156','SABADELL',' Banco de Sabadell', @idCountryMexico, 1, ''),
('166','BANSEFI','  Banco del Ahorro Nacional y Servicios Financieros', @idCountryMexico, 1, ''),
('168','HIPOTECARIA FEDERAL','  Sociedad Hipotecaria Federal', @idCountryMexico, 1, ''),
('600','MONEXCB','  Monex Casa de Bolsa', @idCountryMexico, 1, ''),
('601','GBM','  GBM Grupo Bursátil Mexicano', @idCountryMexico, 1, ''),
('602','MASARI',' Masari Casa de Bolsa', @idCountryMexico, 1, ''),
('605','VALUE','  Value', @idCountryMexico, 1, ''),
('606','ESTRUCTURADORES','  Estructuradores del Mercado de Valores Casa de Bolsa', @idCountryMexico, 1, ''),
('607','TIBER','  Casa de Cambio Tiber', @idCountryMexico, 1, ''),
('608','VECTOR',' Vector Casa de Bolsa', @idCountryMexico, 1, ''),
('610','B&B','  B y B', @idCountryMexico, 1, ''),
('614','ACCIVAL','  Acciones y Valores Banamex', @idCountryMexico, 1, ''),
('615','MERRILL LYNCH','  Merrill Lynch México', @idCountryMexico, 1, ''),
('616','FINAMEX','  Casa de Bolsa Finamex', @idCountryMexico, 1, ''),
('617','VALMEX',' Valores Mexicanos Casa de Bolsa', @idCountryMexico, 1, ''),
('618','UNICA','  Unica Casa de Cambio', @idCountryMexico, 1, ''),
('619','MAPFRE',' MAPFRE Tepeyac', @idCountryMexico, 1, ''),
('620','PROFUTURO','  Profuturo G.N.P.', @idCountryMexico, 1, ''),
('621','CB ACTINVER','  Actinver Casa de Bolsa', @idCountryMexico, 1, ''),
('622','OACTIN',' OPERADORA ACTINVER', @idCountryMexico, 1, ''),
('623','SKANDIA','  Skandia Vida', @idCountryMexico, 1, ''),
('626','CBDEUTSCHE',' Deutsche Securities', @idCountryMexico, 1, ''),
('627','ZURICH',' Zurich Compañía de Seguros', @idCountryMexico, 1, ''),
('628','ZURICHVI',' Zurich Vida', @idCountryMexico, 1, ''),
('629','SU CASITA','  Hipotecaria Su Casita', @idCountryMexico, 1, ''),
('630','CB INTERCAM','  Intercam Casa de Bolsa', @idCountryMexico, 1, ''),
('631','CI BOLSA',' CI Casa de Bolsa', @idCountryMexico, 1, ''),
('632','BULLTICK CB','  Bulltick Casa de Bolsa', @idCountryMexico, 1, ''),
('633','STERLING',' Sterling Casa de Cambio', @idCountryMexico, 1, ''),
('634','FINCOMUN',' Fincomún', @idCountryMexico, 1, ''),
('636','HDI SEGUROS','  HDI Seguros', @idCountryMexico, 1, ''),
('637','ORDER','  Order Express Casa de Cambio', @idCountryMexico, 1, ''),
('638','AKALA','  Akala', @idCountryMexico, 1, ''),
('640','CB JPMORGAN','  J.P. Morgan Casa de Bolsa', @idCountryMexico, 1, ''),
('642','REFORMA','  Operadora de Recursos Reforma', @idCountryMexico, 1, ''),
('646','STP','  Sistema de Transferencias y Pagos STP', @idCountryMexico, 1, ''),
('647','TELECOMM',' Telecomunicaciones de México', @idCountryMexico, 1, ''),
('648','EVERCORE',' Evercore Casa de Bolsa', @idCountryMexico, 1, ''),
('649','SKANDIA','  Skandia Operadora de Fondos', @idCountryMexico, 1, ''),
('651','SEGMTY',' Seguros Monterrey New York Life', @idCountryMexico, 1, ''),
('652','ASEA',' Solución Asea', @idCountryMexico, 1, ''),
('653','KUSPIT',' Kuspit Casa de Bolsa', @idCountryMexico, 1, ''),
('655','SOFIEXPRESS','  J.P. SOFIEXPRESS', @idCountryMexico, 1, ''),
('656','UNAGRA',' UNAGRA', @idCountryMexico, 1, ''),
('659','OPCIONES EMPRESARIALES DEL NOROESTE','  OPCIONES EMPRESARIALES DEL NORESTE', @idCountryMexico, 1, ''),
('670','LIBERTAD',' Libertad Servicios Financieros', @idCountryMexico, 1, ''),
('901','CLS','  Cls Bank International', @idCountryMexico, 1, ''),
('902','INDEVAL','  SD. Indeval', @idCountryMexico, 1, '')

-- BANK ACCOUNT TYPE
INSERT [LP_Configuration].[BankAccountType] ([Code], [Name], [Description], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idCountry]) 
VALUES (
  N'A', 
  N'CA', 
  N'Caja de Ahorro', 
  1,
  GETDATE(),
  GETDATE(),
  GETDATE(),
  GETDATE(),
  @idCountryMexico
)

INSERT [LP_Configuration].[BankAccountType] ([Code], [Name], [Description], [Active], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime], [idCountry]) 
VALUES (
  N'C', 
  N'CC', 
  N'Cuenta Corriente', 
  1,
  GETDATE(),
  GETDATE(),
  GETDATE(),
  GETDATE(),
  @idCountryMexico
)


-- Identification type
INSERT INTO [LP_Entity].[EntityIdentificationType]([Code], [Name], [Description], [idCountry], [Active])
VALUES ('RFC', 'CREGISTRO FEDERAL DEL CONTRIBUYENTE', 'REGISTRO FEDERAL DEL CONTRIBUYENTE', @idCountryMexico, 1)

-- TICKET ALTERNATIVE COLUMN
ALTER TABLE LP_Operation.Ticket ADD TicketAlternative7 VARCHAR(7)



CREATE TABLE [LP_Operation].[BankPreRegisterLot] (
  idBankPreRegisterLot LP_Common.LP_I_UNIQUE_IDENTIFIER_INT IDENTITY(1,1) PRIMARY KEY,
  [Status] LP_Common.LP_F_INT NOT NULL DEFAULT 1,
  OP_InsDateTime LP_Common.LP_A_OP_INSDATETIME NOT NULL DEFAULT GETDATE(),
  OP_UpdDateTime LP_Common.LP_A_OP_UPDDATETIME NOT NULL DEFAULT GETDATE(),
  DB_InsDateTime LP_Common.LP_A_DB_INSDATETIME NOT NULL DEFAULT GETDATE(),
  DB_UpdDateTime LP_Common.LP_A_DB_UPDDATETIME NOT NULL DEFAULT GETDATE()
)

CREATE TABLE [LP_Operation].[BankPreRegisterTransaction] (
  [idBankPreRegisterTransaction] LP_Common.LP_I_UNIQUE_IDENTIFIER_INT IDENTITY(1,1) PRIMARY KEY,
  [idBankPreRegisterLot] LP_Common.LP_F_INT NOT NULL,
  [idTransaction] LP_Common.LP_F_INT NOT NULL,
  [Approved] BIT NOT NULL
)

-- LP INTERNAL ERRORS
-- ERROR_ACCOUNT_INCORRECT
DECLARE @idLPInternalError as INT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('ACCERROR')

CREATE TABLE [LP_Operation].[BankPreRegisterBankAccount] (
  idBankPreRegisterBankAccount LP_Common.LP_I_UNIQUE_IDENTIFIER_INT IDENTITY(1,1) PRIMARY KEY,
  AccountNumber VARCHAR(18) UNIQUE,
  AccountAlias VARCHAR(15),
  idBankPreRegisterLot INT,
  Deleted TINYINT DEFAULT 0
)

rollback tran
-- commit tran
