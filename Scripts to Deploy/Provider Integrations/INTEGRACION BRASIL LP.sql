begin tran

declare  @idEntityUserBra			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@idEntityUserCol			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityAccountId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@merchantBrasil nvarchar(255) = 'PMI Brasil',
@merchantBrasilId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@entityPasswordId			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

insert into LP_Entity.EntityMerchant
([Description], idEntityBusinessNameType, Active)
values (@merchantBrasil, 1, 1)

set @merchantBrasilId = SCOPE_IDENTITY()  

insert into LP_Entity.EntityUser
(LastName, FirstName, MailAccount, TelephoneNumber, MobileNumber, idEntityType, idEntityIdentificationType, idEntityMerchant, idEntityAdress, Active, idCountry, AccountNumberLP, MerchantAlias, fxPeriod)
values (@merchantBrasil, @merchantBrasil, 'alex@pmi-americas.com', '', '', 2, 4,@merchantBrasilId , 4, 1, 31, '', 'LPPMIBRA',1)

set @idEntityUserBra =  SCOPE_IDENTITY() 

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 2, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 15, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 16, 1)

insert into [LP_Entity].[EntityUserTransactionType]
(idEntityUser, idTransactionType, Active)
values(@idEntityUserBra, 17, 1)

insert into LP_Entity.EntityCurrencyExchange
(idEntityUser, idCurrencyTypeLP, idCurrencyTypeClient, Active, Version)
values (@idEntityUserBra, 2363, 2493, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2363, 31, 2, @idEntityUserBra, 1.00, 1.00, 1, 1)

insert into [LP_Configuration].[CurrencyBase]
(idCurrencyType, idCountry, idUnit, idEntityUser, Base_Sell, Base_Buy, Active, Version)
values (2493, 31, 2, @idEntityUserBra, 1.00, 1.00, 1, 1)

----CROSS ---

SELECT @entityAccountId = [idEntityAccount]
FROM [LP_Security.EntityAccount]
WHERE [Identification] = '000002300001'

GO

insert into LP_Security.EntityAccountUser
(idEntityAccount, idEntityUser, Active)
values (@entityAccountId, @idEntityUserBra, 1)

insert into LP_Security.EntityApiCredential
(Identification, ApiKey, idEntityUser, idCountry, Active)
values ('000002300001', 'EACP#RPIM1', @idEntityUserBra, 31, 1)

-- insert into LP_Security.EntityPassword values ('EAC0002000','PMITEST123',GETDATE(),1,1,GETUTCDATE()
--            ,GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())

-- set @entityPasswordId = SCOPE_IDENTITY()

-- insert into LP_Security.EntityAccountPassword values(@entityAccountId,@entityPasswordId,1,GETUTCDATE(),GETUTCDATE()
--            ,GETDATE()
--            ,GETDATE())




select @idEntityUserBra = idEntityUser from LP_Entity.EntityUser where LastName = 'PMI Brasil'

insert into LP_Entity.EntitySubMerchant
(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
values ('CTV', 'CTV', @idEntityUserBra, 0, 0, 1, '', '', 0, 1,'1.300000',2493)



-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'FASTCASH',
	'FastCash',
	'FastCash',
	31,
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
	31,
	1
)

SET @idPayWayService = SCOPE_IDENTITY()  

SELECT @idProvider = idProvider FROM LP_Configuration.[Provider] WHERE Code = 'FASTCASH'

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO [LP_Configuration].[InternalStatusType](Code, [Name], [Description], [Active], [idCountry], [OP_InsDateTime], [OP_UpdDateTime], [DB_InsDateTime], [DB_UpdDateTime])
VALUES('SCM', 'State Codes of Movements', 'State Codes of Movements', 1, 31, GETDATE(), GETDATE(), GETDATE(), GETDATE())
SET @idInternalStatusType = SCOPE_IDENTITY()  


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, 31, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0)

-- BankBranch column
ALTER TABLE [LP_Operation].[TransactionRecipientDetail] 
ADD [BankBranch] LP_Common.LP_F_C10 NULL

-- Payment Type
INSERT INTO [LP_Configuration].[PaymentType]([Code], [Name], [Description], [idCountry], [Active], [CatalogValue])
VALUES(
	'SUPPLIERS',
	'Pago a Proveedores',
	'Pago a Proveedores',
	31,
	1,
	2
)


INSERT INTO [LP_Configuration].[BankCode] ([Name], [Description], [Code], [idCountry], [Active], [SubCode])
VALUES
('Banco ABC Brasil S.A.','Banco ABC Brasil S.A.', '246', 31, 1, ''),
('Banco Agiplan S.A.', 'Banco Agiplan S.A.', '121', 31, 1, ''),
('Banco Bmg S.A.', 'Banco Bmg S.A.', '318', 31, 1, ''),
('Banco Bonsucesso S.A.', 'Banco Bonsucesso S.A.', '218', 31, 1, ''),
('Banco Bradesco S.A.', 'Banco Bradesco S.A.', '237', 31, 1, ''),
('Banco C6 S.A.', 'Banco C6 S.A.', '336', 31, 1, ''),
('Banco Citibank', 'Banco Citibank', '745', 31, 1, ''),
('Banco Cooperativo do Brasil S.A. - BANCOOB', 'Banco Cooperativo do Brasil S.A. - BANCOOB', '756', 31, 1, ''),
('Banco Cooperativo Sicredi S.A.', 'Banco Cooperativo Sicredi S.A.', '748', 31, 1, ''),
('Banco da Amazonia S.A.', 'Banco da Amazonia S.A.', '003', 31, 1, ''),
('Banco Daycoval S.A.', 'Banco Daycoval S.A.', '707', 31, 1, ''),
('Banco de Brasilia S.A. - BRB', 'Banco de Brasilia S.A. - BRB', '070', 31, 1, ''),
('Banco do Brasil S.A.', 'Banco do Brasil S.A.', '001', 31, 1, ''),
('Banco do Estado de Sergipe S.A. - BANESE', 'Banco do Estado de Sergipe S.A. - BANESE', '047', 31, 1, ''),
('Banco do Estado do Para S.A. - BANPARA', 'Banco do Estado do Para S.A. - BANPARA', '037', 31, 1, ''),
('Banco do Estado do Rio Grande do Sul S.A. - BANRISUL', 'Banco do Estado do Rio Grande do Sul S.A. - BANRISUL', '041', 31, 1, ''),
('Banco do Nordeste do Brasil S.A.', 'Banco do Nordeste do Brasil S.A.', '004', 31, 1, ''),
('Banco Inter', 'Banco Inter', '077', 31, 1, ''),
('Banco Mercantil do Brasil S.A.', 'Banco Mercantil do Brasil S.A.', '389', 31, 1, ''),
('Banco Modal S.A.', 'Banco Modal S.A.', '746', 31, 1, ''),
('Banco Neon', 'Banco Neon', '735', 31, 1, ''),
('Banco Original', 'Banco Original', '212', 31, 1, ''),
('Banco Panamericano S.A.', 'Banco Panamericano S.A.', '623', 31, 1, ''),
('Banco Safra S.A.', 'Banco Safra S.A.', '422', 31, 1, ''),
('Banco Santander Brasil S.A.', 'Banco Santander Brasil S.A.', '033', 31, 1, ''),
('Banco Sofisa', 'Banco Sofisa', '637', 31, 1, ''),
('Banco Votorantim S.A.', 'Banco Votorantim S.A.', '655', 31, 1, ''),
('Banestes S.A. Banco do Estado do Espirito Santo', 'Banestes S.A. Banco do Estado do Espirito Santo', '021', 31, 1, ''),
('Caixa Economica Federal - CEF', 'Caixa Economica Federal - CEF', '104', 31, 1, ''),
('Citibank N.A.', 'Citibank N.A.', '477', 31, 1, ''),
('Confederacao Nacional das Cooperativas Centrais Unicreds', 'Confederacao Nacional das Cooperativas Centrais Unicreds', '136', 31, 1, ''),
('Cooperativa Central de Credito Urbano - CECRED', 'Cooperativa Central de Credito Urbano - CECRED', '085', 31, 1, ''),
('HSBC Bank Brasil S.A. - Banco Multiplo', 'HSBC Bank Brasil S.A. - Banco Multiplo', '399', 31, 1, ''),
('Itau Unibanco S.A.', 'Itau Unibanco S.A.', '341', 31, 1, ''),
('Nu Pagamentos (Nubank)', 'Nu Pagamentos (Nubank)', '260', 31, 1, ''),
('Pagseguro Internet S.A', 'Pagseguro Internet S.A', '290', 31, 1, ''),
('Unicred Norte do Parana', 'Unicred Norte do Parana', '084', 31, 1, ''),
('BANCO NACIONAL DE DESENVOLVIMENTO ECONOMICO E SOCIAL', 'BANCO NACIONAL DE DESENVOLVIMENTO ECONOMICO E SOCIAL', '007', 31, 1, ''),
('CREDICOAMO CREDITO RURAL COOPERATIVA', 'CREDICOAMO CREDITO RURAL COOPERATIVA', '010', 31, 1, ''),
('CREDIT SUISSE HEDGING-GRIFFO CORRETORA DE VALORES S.A', 'CREDIT SUISSE HEDGING-GRIFFO CORRETORA DE VALORES S.A', '011', 31, 1, ''),
('Banco Inbursa S.A.', 'Banco Inbursa S.A.', '012', 31, 1, ''),
('STATE STREET BRASIL S.A. – BANCO COMERCIAL', 'STATE STREET BRASIL S.A. – BANCO COMERCIAL', '014', 31, 1, ''),
('UBS Brasil Corretora de Câmbio Títulos e Valores Mobiliários', 'UBS Brasil Corretora de Câmbio Títulos e Valores Mobiliários', '015', 31, 1, ''),
('BNY Mellon Banco S.A.', 'BNY Mellon Banco S.A.', '017', 31, 1, ''),
('Banco Tricury S.A.', 'Banco Tricury S.A.', '018', 31, 1, ''),
('Banco Bandepe S.A.', 'Banco Bandepe S.A.', '024', 31, 1, ''),
('Banco Alfa S.A.', 'Banco Alfa S.A.', '025', 31, 1, ''),
('Banco Itaú Consignado S.A.', 'Banco Itaú Consignado S.A.', '029', 31, 1, ''),
('Banco Bradesco BBI S.A.', 'Banco Bradesco BBI S.A.', '036', 31, 1, ''),
('Banco Cargill S.A.', 'Banco Cargill S.A.', '040', 31, 1, ''),
('Hipercard Banco Múltiplo S.A.', 'Hipercard Banco Múltiplo S.A.', '062', 31, 1, ''),
('Banco Bradescard S.A.', 'Banco Bradescard S.A.', '063', 31, 1, ''),
('GOLDMAN SACHS DO BRASIL BANCO MULTIPLO S.A.', 'GOLDMAN SACHS DO BRASIL BANCO MULTIPLO S.A.', '064', 31, 1, ''),
('Banco AndBank (Brasil) S.A.', 'Banco AndBank (Brasil) S.A.', '065', 31, 1, ''),
('BANCO MORGAN STANLEY S.A.', 'BANCO MORGAN STANLEY S.A.', '066', 31, 1, ''),
('Banco Crefisa S.A.', 'Banco Crefisa S.A.', '069', 31, 1, ''),
('Banco J. Safra S.A.', 'Banco J. Safra S.A.', '074', 31, 1, ''),
('Banco ABN Amro S.A.', 'Banco ABN Amro S.A.', '075', 31, 1, ''),
('Banco KDB do Brasil S.A.', 'Banco KDB do Brasil S.A.', '076', 31, 1, ''),
('Haitong Banco de Investimento do Brasil S.A.', 'Haitong Banco de Investimento do Brasil S.A.', '078', 31, 1, ''),
('Banco Original do Agronegócio S.A.', 'Banco Original do Agronegócio S.A.', '079', 31, 1, ''),
('BancoSeguro S.A.', 'BancoSeguro S.A.', '081', 31, 1, ''),
('BANCO TOPÁZIO S.A.', 'BANCO TOPÁZIO S.A.', '082', 31, 1, ''),
('Banco da China Brasil S.A.', 'Banco da China Brasil S.A.', '083', 31, 1, ''),
('Banco Finaxis S.A.', 'Banco Finaxis S.A.', '094', 31, 1, ''),
('Travelex Banco de Câmbio S.A.', 'Travelex Banco de Câmbio S.A.', '095', 31, 1, ''),
('Banco B3 S.A.', 'Banco B3 S.A.', '096', 31, 1, ''),
('Banco Bocom BBM S.A.', 'Banco Bocom BBM S.A.', '107', 31, 1, ''),
('Banco Western Union do Brasil S.A.', 'Banco Western Union do Brasil S.A.', '119', 31, 1, ''),
('BANCO RODOBENS S.A.', 'BANCO RODOBENS S.A.', '120', 31, 1, ''),
('Banco Bradesco BERJ S.A.', 'Banco Bradesco BERJ S.A.', '122', 31, 1, ''),
('Banco Woori Bank do Brasil S.A.', 'Banco Woori Bank do Brasil S.A.', '124', 31, 1, ''),
('Plural S.A. Banco Múltiplo', 'Plural S.A. Banco Múltiplo', '125', 31, 1, ''),
('BR Partners Banco de Investimento S.A.', 'BR Partners Banco de Investimento S.A.', '126', 31, 1, ''),
('MS Bank S.A. Banco de Câmbio', 'MS Bank S.A. Banco de Câmbio', '128', 31, 1, ''),
('UBS Brasil Banco de Investimento S.A.', 'UBS Brasil Banco de Investimento S.A.', '129', 31, 1, ''),
('ICBC do Brasil Banco Múltiplo S.A.', 'ICBC do Brasil Banco Múltiplo S.A.', '132', 31, 1, ''),
('Intesa Sanpaolo Brasil S.A. - Banco Múltiplo', 'Intesa Sanpaolo Brasil S.A. - Banco Múltiplo', '139', 31, 1, ''),
('BEXS BANCO DE CÂMBIO S/A', 'BEXS BANCO DE CÂMBIO S/A', '144', 31, 1, ''),
('Commerzbank Brasil S.A. - Banco Múltiplo', 'Commerzbank Brasil S.A. - Banco Múltiplo', '163', 31, 1, ''),
('Banco Olé Bonsucesso Consignado S.A.', 'Banco Olé Bonsucesso Consignado S.A.', '169', 31, 1, ''),
('Banco Itaú BBA S.A.', 'Banco Itaú BBA S.A.', '184', 31, 1, ''),
('Banco BTG Pactual S.A.', 'Banco BTG Pactual S.A.', '208', 31, 1, ''),
('Banco Arbi S.A.', 'Banco Arbi S.A.', '213', 31, 1, ''),
('Banco John Deere S.A.', 'Banco John Deere S.A.', '217', 31, 1, ''),
('BANCO CRÉDIT AGRICOLE BRASIL S.A.', 'BANCO CRÉDIT AGRICOLE BRASIL S.A.', '222', 31, 1, ''),
('Banco Fibra S.A.', 'Banco Fibra S.A.', '224', 31, 1, ''),
('Banco Cifra S.A.', 'Banco Cifra S.A.', '233', 31, 1, ''),
('BANCO CLASSICO S.A.', 'BANCO CLASSICO S.A.', '241', 31, 1, ''),
('Banco Máxima S.A.', 'Banco Máxima S.A.', '243', 31, 1, ''),
('Banco Investcred Unibanco S.A.', 'Banco Investcred Unibanco S.A.', '249', 31, 1, ''),
('BCV - BANCO DE CRÉDITO E VAREJO S.A.', 'BCV - BANCO DE CRÉDITO E VAREJO S.A.', '250', 31, 1, ''),
('Bexs Corretora de Câmbio S/A', 'Bexs Corretora de Câmbio S/A', '253', 31, 1, ''),
('PARANÁ BANCO S.A.', 'PARANÁ BANCO S.A.', '254', 31, 1, ''),
('MONEYCORP BANCO DE CÂMBIO S.A.', 'MONEYCORP BANCO DE CÂMBIO S.A.', '259', 31, 1, ''),
('Banco Fator S.A.', 'Banco Fator S.A.', '265', 31, 1, ''),
('BANCO CEDULA S.A.', 'BANCO CEDULA S.A.', '266', 31, 1, ''),
('HSBC BRASIL S.A. - BANCO DE INVESTIMENTO', 'HSBC BRASIL S.A. - BANCO DE INVESTIMENTO', '269', 31, 1, ''),
('Banco de la Nacion Argentina', 'Banco de la Nacion Argentina', '300', 31, 1, ''),
('BPP Instituição de Pagamento S.A.', 'BPP Instituição de Pagamento S.A.', '301', 31, 1, ''),
('China Construction Bank (Brasil) Banco Múltiplo S/A', 'China Construction Bank (Brasil) Banco Múltiplo S/A', '320', 31, 1, ''),
('BANCO BARI DE INVESTIMENTOS E FINANCIAMENTOS S.A.', 'BANCO BARI DE INVESTIMENTOS E FINANCIAMENTOS S.A.', '330', 31, 1, ''),
('Banco Digio S.A.', 'Banco Digio S.A.', '335', 31, 1, ''),
('Banco XP S.A.', 'Banco XP S.A.', '348', 31, 1, ''),
('BANCO SOCIETE GENERALE BRASIL S.A.', 'BANCO SOCIETE GENERALE BRASIL S.A.', '366', 31, 1, ''),
('Banco Mizuho do Brasil S.A.', 'Banco Mizuho do Brasil S.A.', '370', 31, 1, ''),
('BANCO J.P. MORGAN S.A.', 'BANCO J.P. MORGAN S.A.', '376', 31, 1, ''),
('Banco Bradesco Financiamentos S.A.', 'Banco Bradesco Financiamentos S.A.', '394', 31, 1, ''),
('BANCO CAPITAL S.A.', 'BANCO CAPITAL S.A.', '412', 31, 1, ''),
('Banco MUFG Brasil S.A.', 'Banco MUFG Brasil S.A.', '456', 31, 1, ''),
('Banco Sumitomo Mitsui Brasileiro S.A.', 'Banco Sumitomo Mitsui Brasileiro S.A.', '464', 31, 1, ''),
('Banco Caixa Geral - Brasil S.A.', 'Banco Caixa Geral - Brasil S.A.', '473', 31, 1, ''),
('Banco ItauBank S.A.', 'Banco ItauBank S.A.', '479', 31, 1, ''),
('DEUTSCHE BANK S.A. - BANCO ALEMAO', 'DEUTSCHE BANK S.A. - BANCO ALEMAO', '487', 31, 1, ''),
('JPMorgan Chase Bank National Association', 'JPMorgan Chase Bank National Association', '488', 31, 1, ''),
('ING Bank N.V.', 'ING Bank N.V.', '492', 31, 1, ''),
('Banco Credit Suisse (Brasil) S.A.', 'Banco Credit Suisse (Brasil) S.A.', '505', 31, 1, ''),
('Banco Luso Brasileiro S.A.', 'Banco Luso Brasileiro S.A.', '600', 31, 1, ''),
('Banco Industrial do Brasil S.A.', 'Banco Industrial do Brasil S.A.', '604', 31, 1, ''),
('Banco VR S.A.', 'Banco VR S.A.', '610', 31, 1, ''),
('Banco Paulista S.A.', 'Banco Paulista S.A.', '611', 31, 1, ''),
('Banco Guanabara S.A.', 'Banco Guanabara S.A.', '612', 31, 1, ''),
('Omni Banco S.A.', 'Omni Banco S.A.', '613', 31, 1, ''),
('BANCO FICSA S.A.', 'BANCO FICSA S.A.', '626', 31, 1, ''),
('Banco Smartbank S.A.', 'Banco Smartbank S.A.', '630', 31, 1, ''),
('Banco Rendimento S.A.', 'Banco Rendimento S.A.', '633', 31, 1, ''),
('BANCO TRIANGULO S.A.', 'BANCO TRIANGULO S.A.', '634', 31, 1, ''),
('Banco Pine S.A.', 'Banco Pine S.A.', '643', 31, 1, ''),
('Itaú Unibanco Holding S.A.', 'Itaú Unibanco Holding S.A.', '652', 31, 1, ''),
('BANCO INDUSVAL S.A.', 'BANCO INDUSVAL S.A.', '653', 31, 1, ''),
('BANCO A.J. RENNER S.A.', 'BANCO A.J. RENNER S.A.', '654', 31, 1, ''),
('Banco Ourinvest S.A.', 'Banco Ourinvest S.A.', '712', 31, 1, ''),
('Banco Cetelem S.A.', 'Banco Cetelem S.A.', '739', 31, 1, ''),
('BANCO RIBEIRAO PRETO S.A.', 'BANCO RIBEIRAO PRETO S.A.', '741', 31, 1, ''),
('Banco Semear S.A.', 'Banco Semear S.A.', '743', 31, 1, ''),
('Banco Rabobank International Brasil S.A.', 'Banco Rabobank International Brasil S.A.', '747', 31, 1, ''),
('Scotiabank Brasil S.A. Banco Múltiplo', 'Scotiabank Brasil S.A. Banco Múltiplo', '751', 31, 1, ''),
('Banco BNP Paribas Brasil S.A.', 'Banco BNP Paribas Brasil S.A.', '752', 31, 1, ''),
('Novo Banco Continental S.A. - Banco Múltiplo', 'Novo Banco Continental S.A. - Banco Múltiplo', '753', 31, 1, ''),
('Banco Sistema S.A.', 'Banco Sistema S.A.', '754', 31, 1, ''),
('Bank of America Merrill Lynch Banco Múltiplo S.A.', 'Bank of America Merrill Lynch Banco Múltiplo S.A.', '755', 31, 1, ''),
('BANCO KEB HANA DO BRASIL S.A.', 'BANCO KEB HANA DO BRASIL S.A.', '757', 31, 1, '')

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
  31
)
GO
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
  31
)
GO


-- Identification type
INSERT INTO [LP_Entity].[EntityIdentificationType]([Code], [Name], [Description], [idCountry], [Active])
VALUES (
  'CI',
  'Cedula de Identidad',
  'Cedula de Identidad',
  31,
  1
)

commit