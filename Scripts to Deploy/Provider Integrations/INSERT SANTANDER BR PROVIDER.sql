begin tran
-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'SANTBR',
	'Banco Santander',
	'Banco Santander',
	31,
	1
)

set @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idPayWayService = (SELECT [idPayWayService] FROM [LP_Configuration].[PayWayServices] where Code = 'BANKDEPO' AND idCountry = 31)

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = 31)


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, 31, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, '00',LEFT('Cr�dito ou D�bito Efetivado',60),LEFT('Cr�dito ou D�bito Efetivado',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, '01',LEFT('Insufici�ncia de Fundos - D�bito N�o Efetuado',60),LEFT('Insufici�ncia de Fundos - D�bito N�o Efetuado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '02',LEFT('Cr�dito ou D�bito Cancelado pelo Pagador/Credor',60),LEFT('Cr�dito ou D�bito Cancelado pelo Pagador/Credor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '03',LEFT('D�bito Autorizado pela Ag�ncia - Efetuado',60),LEFT('D�bito Autorizado pela Ag�ncia - Efetuado',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'AA',LEFT('Controle Inv�lido',60),LEFT('Controle Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AB',LEFT('Tipo de Opera��o Inv�lido',60),LEFT('Tipo de Opera��o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AC',LEFT('Tipo de Servi�o Inv�lido',60),LEFT('Tipo de Servi�o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AD',LEFT('Forma de Lan�amento Inv�lida',60),LEFT('Forma de Lan�amento Inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AE',LEFT('Tipo/N�mero de Inscri��o Inv�lido',60),LEFT('Tipo/N�mero de Inscri��o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AF',LEFT('C�digo de Conv�nio Inv�lido',60),LEFT('C�digo de Conv�nio Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AG',LEFT('Ag�ncia/Conta Corrente/DV Inv�lido',60),LEFT('Ag�ncia/Conta Corrente/DV Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AH',LEFT('N� Seq�encial do Registro no Lote Inv�lido',60),LEFT('N� Seq�encial do Registro no Lote Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AI',LEFT('C�digo de Segmento de Detalhe Inv�lido',60),LEFT('C�digo de Segmento de Detalhe Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AJ',LEFT('Tipo de Movimento Inv�lido',60),LEFT('Tipo de Movimento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AK',LEFT('C�digo da C�mara de Compensa��o do Banco Favorecido/Deposit�rio Inv�lido',60),LEFT('C�digo da C�mara de Compensa��o do Banco Favorecido/Deposit�rio Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AL',LEFT('C�digo do Banco Favorecido, Institui��o de Pagamento ou Deposit�rio Inv�lido',60),LEFT('C�digo do Banco Favorecido, Institui��o de Pagamento ou Deposit�rio Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AM',LEFT('Ag�ncia Mantenedora da Conta Corrente do Favorecido Inv�lida',60),LEFT('Ag�ncia Mantenedora da Conta Corrente do Favorecido Inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AN',LEFT('Conta Corrente/DV/Conta de Pagamento do Favorecido Inv�lido',60),LEFT('Conta Corrente/DV/Conta de Pagamento do Favorecido Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AO',LEFT('Nome do Favorecido N�o Informado',60),LEFT('Nome do Favorecido N�o Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AP',LEFT('Data Lan�amento Inv�lido',60),LEFT('Data Lan�amento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AQ',LEFT('Tipo/Quantidade da Moeda Inv�lido',60),LEFT('Tipo/Quantidade da Moeda Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AR',LEFT('Valor do Lan�amento Inv�lido',60),LEFT('Valor do Lan�amento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AS',LEFT('Aviso ao Favorecido - Identifica��o Inv�lida',60),LEFT('Aviso ao Favorecido - Identifica��o Inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AT',LEFT('Tipo/N�mero de Inscri��o do Favorecido Inv�lido',60),LEFT('Tipo/N�mero de Inscri��o do Favorecido Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AU',LEFT('Logradouro do Favorecido N�o Informado',60),LEFT('Logradouro do Favorecido N�o Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AV',LEFT('N� do Local do Favorecido N�o Informado',60),LEFT('N� do Local do Favorecido N�o Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AW',LEFT('Cidade do Favorecido N�o Informada',60),LEFT('Cidade do Favorecido N�o Informada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AX',LEFT('CEP/Complemento do Favorecido Inv�lido',60),LEFT('CEP/Complemento do Favorecido Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AY',LEFT('Sigla do Estado do Favorecido Inv�lida',60),LEFT('Sigla do Estado do Favorecido Inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AZ',LEFT('C�digo/Nome do Banco Deposit�rio Inv�lido',60),LEFT('C�digo/Nome do Banco Deposit�rio Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BA',LEFT('C�digo/Nome da Ag�ncia Deposit�ria N�o Informado',60),LEFT('C�digo/Nome da Ag�ncia Deposit�ria N�o Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BB',LEFT('Seu N�mero Inv�lido',60),LEFT('Seu N�mero Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BC',LEFT('Nosso N�mero Inv�lido',60),LEFT('Nosso N�mero Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BD',LEFT('Inclus�o Efetuada com Sucesso',60),LEFT('Inclus�o Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BE',LEFT('Altera��o Efetuada com Sucesso',60),LEFT('Altera��o Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BF',LEFT('Exclus�o Efetuada com Sucesso',60),LEFT('Exclus�o Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BG',LEFT('Ag�ncia/Conta Impedida Legalmente',60),LEFT('Ag�ncia/Conta Impedida Legalmente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BH',LEFT('Empresa n�o pagou sal�rio',60),LEFT('Empresa n�o pagou sal�rio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BI',LEFT('Falecimento do mutu�rio',60),LEFT('Falecimento do mutu�rio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BJ',LEFT('Empresa n�o enviou remessa do mutu�rio',60),LEFT('Empresa n�o enviou remessa do mutu�rio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BK',LEFT('Empresa n�o enviou remessa no vencimento',60),LEFT('Empresa n�o enviou remessa no vencimento',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BL',LEFT('Valor da parcela inv�lida',60),LEFT('Valor da parcela inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BM',LEFT('Identifica��o do contrato inv�lida',60),LEFT('Identifica��o do contrato inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BN',LEFT('Opera��o de Consigna��o Inclu�da com Sucesso',60),LEFT('Opera��o de Consigna��o Inclu�da com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BO',LEFT('Opera��o de Consigna��o Alterada com Sucesso',60),LEFT('Opera��o de Consigna��o Alterada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BP',LEFT('Opera��o de Consigna��o Exclu�da com Sucesso',60),LEFT('Opera��o de Consigna��o Exclu�da com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BQ',LEFT('Opera��o de Consigna��o Liquidada com Sucesso',60),LEFT('Opera��o de Consigna��o Liquidada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BR',LEFT('Reativa��o Efetuada com Sucesso',60),LEFT('Reativa��o Efetuada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BS',LEFT('Suspens�o Efetuada com Sucesso',60),LEFT('Suspens�o Efetuada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'CA',LEFT('C�digo de Barras - C�digo do Banco Inv�lido',60),LEFT('C�digo de Barras - C�digo do Banco Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CB',LEFT('C�digo de Barras - C�digo da Moeda Inv�lido',60),LEFT('C�digo de Barras - C�digo da Moeda Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CC',LEFT('C�digo de Barras - D�gito Verificador Geral Inv�lido',60),LEFT('C�digo de Barras - D�gito Verificador Geral Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CD',LEFT('C�digo de Barras - Valor do T�tulo Inv�lido',60),LEFT('C�digo de Barras - Valor do T�tulo Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CE',LEFT('C�digo de Barras - Campo Livre Inv�lido',60),LEFT('C�digo de Barras - Campo Livre Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CF',LEFT('Valor do Documento Inv�lido',60),LEFT('Valor do Documento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CG',LEFT('Valor do Abatimento Inv�lido',60),LEFT('Valor do Abatimento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CH',LEFT('Valor do Desconto Inv�lido',60),LEFT('Valor do Desconto Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CI',LEFT('Valor de Mora Inv�lido',60),LEFT('Valor de Mora Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CJ',LEFT('Valor da Multa Inv�lido',60),LEFT('Valor da Multa Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CK',LEFT('Valor do IR Inv�lido',60),LEFT('Valor do IR Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CL',LEFT('Valor do ISS Inv�lido',60),LEFT('Valor do ISS Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CM',LEFT('Valor do IOF Inv�lido',60),LEFT('Valor do IOF Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CN',LEFT('Valor de Outras Dedu��es Inv�lido',60),LEFT('Valor de Outras Dedu��es Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CO',LEFT('Valor de Outros Acr�scimos Inv�lido',60),LEFT('Valor de Outros Acr�scimos Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CP',LEFT('Valor do INSS Inv�lido',60),LEFT('Valor do INSS Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HA',LEFT('Lote N�o Aceito',60),LEFT('Lote N�o Aceito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HB',LEFT('Inscri��o da Empresa Inv�lida para o Contrato',60),LEFT('Inscri��o da Empresa Inv�lida para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HC',LEFT('Conv�nio com a Empresa Inexistente/Inv�lido para o Contrato',60),LEFT('Conv�nio com a Empresa Inexistente/Inv�lido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HD',LEFT('Ag�ncia/Conta Corrente da Empresa Inexistente/Inv�lido para o Contrato',60),LEFT('Ag�ncia/Conta Corrente da Empresa Inexistente/Inv�lido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HE',LEFT('Tipo de Servi�o Inv�lido para o Contrato',60),LEFT('Tipo de Servi�o Inv�lido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HF',LEFT('Conta Corrente da Empresa com Saldo Insuficiente',60),LEFT('Conta Corrente da Empresa com Saldo Insuficiente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HG',LEFT('Lote de Servi�o Fora de Seq��ncia',60),LEFT('Lote de Servi�o Fora de Seq��ncia',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HH',LEFT('Lote de Servi�o Inv�lido',60),LEFT('Lote de Servi�o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HI',LEFT('Arquivo n�o aceito',60),LEFT('Arquivo n�o aceito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HJ',LEFT('Tipo de Registro Inv�lido',60),LEFT('Tipo de Registro Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HK',LEFT('C�digo Remessa / Retorno Inv�lido',60),LEFT('C�digo Remessa / Retorno Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HL',LEFT('Vers�o de layout inv�lida',60),LEFT('Vers�o de layout inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HM',LEFT('Mutu�rio n�o identificado',60),LEFT('Mutu�rio n�o identificado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HN',LEFT('Tipo do beneficio n�o permite empr�stimo',60),LEFT('Tipo do beneficio n�o permite empr�stimo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HO',LEFT('Beneficio cessado/suspenso',60),LEFT('Beneficio cessado/suspenso',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HP',LEFT('Beneficio possui representante legal',60),LEFT('Beneficio possui representante legal',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HQ',LEFT('Beneficio � do tipo PA (Pens�o aliment�cia)',60),LEFT('Beneficio � do tipo PA (Pens�o aliment�cia)',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HR',LEFT('Quantidade de contratos permitida excedida',60),LEFT('Quantidade de contratos permitida excedida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HS',LEFT('Beneficio n�o pertence ao Banco informado',60),LEFT('Beneficio n�o pertence ao Banco informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HT',LEFT('In�cio do desconto informado j� ultrapassado',60),LEFT('In�cio do desconto informado j� ultrapassado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HU',LEFT('N�mero da parcela inv�lida',60),LEFT('N�mero da parcela inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HV',LEFT('Quantidade de parcela inv�lida',60),LEFT('Quantidade de parcela inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HW',LEFT('Margem consign�vel excedida para o mutu�rio dentro do prazo do contrato',60),LEFT('Margem consign�vel excedida para o mutu�rio dentro do prazo do contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HX',LEFT('Empr�stimo j� cadastrado',60),LEFT('Empr�stimo j� cadastrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HY',LEFT('Empr�stimo inexistente',60),LEFT('Empr�stimo inexistente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HZ',LEFT('Empr�stimo j� encerrado',60),LEFT('Empr�stimo j� encerrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H1',LEFT('Arquivo sem trailer',60),LEFT('Arquivo sem trailer',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H2',LEFT('Mutu�rio sem cr�dito na compet�ncia',60),LEFT('Mutu�rio sem cr�dito na compet�ncia',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H3',LEFT('N�o descontado � outros motivos',60),LEFT('N�o descontado � outros motivos',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H4',LEFT('Retorno de Cr�dito n�o pago',60),LEFT('Retorno de Cr�dito n�o pago',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H5',LEFT('Cancelamento de empr�stimo retroativo',60),LEFT('Cancelamento de empr�stimo retroativo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H6',LEFT('Outros Motivos de Glosa',60),LEFT('Outros Motivos de Glosa',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H7',LEFT('Margem consign�vel excedida para o mutu�rio acima do prazo do contrato',60),LEFT('Margem consign�vel excedida para o mutu�rio acima do prazo do contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H8',LEFT('Mutu�rio desligado do empregador',60),LEFT('Mutu�rio desligado do empregador',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H9',LEFT('Mutu�rio afastado por licen�a',60),LEFT('Mutu�rio afastado por licen�a',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IA',LEFT('Primeiro nome do mutu�rio diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benef�cio',60),LEFT('Primeiro nome do mutu�rio diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benef�cio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IB',LEFT('Benef�cio suspenso/cessado pela APS ou Sisobi',60),LEFT('Benef�cio suspenso/cessado pela APS ou Sisobi',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IC',LEFT('Benef�cio suspenso por depend�ncia de c�lculo',60),LEFT('Benef�cio suspenso por depend�ncia de c�lculo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ID',LEFT('Benef�cio suspenso/cessado pela inspetoria/auditoria',60),LEFT('Benef�cio suspenso/cessado pela inspetoria/auditoria',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IE',LEFT('Benef�cio bloqueado para empr�stimo pelo benefici�rio',60),LEFT('Benef�cio bloqueado para empr�stimo pelo benefici�rio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IF',LEFT('Benef�cio bloqueado para empr�stimo por TBM',60),LEFT('Benef�cio bloqueado para empr�stimo por TBM',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IG',LEFT('Benef�cio est� em fase de concess�o de PA ou desdobramento',60),LEFT('Benef�cio est� em fase de concess�o de PA ou desdobramento',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IH',LEFT('Benef�cio cessado por �bito',60),LEFT('Benef�cio cessado por �bito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'II',LEFT('Benef�cio cessado por fraude',60),LEFT('Benef�cio cessado por fraude',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IJ',LEFT('Benef�cio cessado por concess�o de outro benef�cio',60),LEFT('Benef�cio cessado por concess�o de outro benef�cio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IK',LEFT('Benef�cio cessado: estatut�rio transferido para �rg�o de origem',60),LEFT('Benef�cio cessado: estatut�rio transferido para �rg�o de origem',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IL',LEFT('Empr�stimo suspenso pela APS',60),LEFT('Empr�stimo suspenso pela APS',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IM',LEFT('Empr�stimo cancelado pelo banco',60),LEFT('Empr�stimo cancelado pelo banco',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IN',LEFT('Cr�dito transformado em PAB',60),LEFT('Cr�dito transformado em PAB',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IO',LEFT('T�rmino da consigna��o foi alterado',60),LEFT('T�rmino da consigna��o foi alterado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IP',LEFT('Fim do empr�stimo ocorreu durante per�odo de suspens�o ou concess�o',60),LEFT('Fim do empr�stimo ocorreu durante per�odo de suspens�o ou concess�o',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IQ',LEFT('Empr�stimo suspenso pelo banco',60),LEFT('Empr�stimo suspenso pelo banco',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IR',LEFT('N�o averba��o de contrato � quantidade de parcelas/compet�ncias informadas ultrapassou a data limite da extin��o de cota do dependente titular de benef�cios',60),LEFT('N�o averba��o de contrato � quantidade de parcelas/compet�ncias informadas ultrapassou a data limite da extin��o de cota do dependente titular de benef�cios',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'TA',LEFT('Lote N�o Aceito - Totais do Lote com Diferen�a',60),LEFT('Lote N�o Aceito - Totais do Lote com Diferen�a',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YA',LEFT('T�tulo N�o Encontrado',60),LEFT('T�tulo N�o Encontrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YB',LEFT('Identificador Registro Opcional Inv�lido',60),LEFT('Identificador Registro Opcional Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YC',LEFT('C�digo Padr�o Inv�lido',60),LEFT('C�digo Padr�o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YD',LEFT('C�digo de Ocorr�ncia Inv�lido',60),LEFT('C�digo de Ocorr�ncia Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YE',LEFT('Complemento de Ocorr�ncia Inv�lido',60),LEFT('Complemento de Ocorr�ncia Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YF',LEFT('Alega��o j� Informada',60),LEFT('Alega��o j� Informada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZB',LEFT('Diverg�ncia entre o primeiro e �ltimo nome do benefici�rio versus primeiro e �ltimo nome na Receita Federal',60),LEFT('Diverg�ncia entre o primeiro e �ltimo nome do benefici�rio versus primeiro e �ltimo nome na Receita Federal',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZC',LEFT('Confirma��o de Antecipa��o de Valor',60),LEFT('Confirma��o de Antecipa��o de Valor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZD',LEFT('Antecipa��o parcial de valor',60),LEFT('Antecipa��o parcial de valor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZE',LEFT('T�tulo bloqueado na base',60),LEFT('T�tulo bloqueado na base',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZF',LEFT('Sistema em conting�ncia � t�tulo valor maior que refer�ncia',60),LEFT('Sistema em conting�ncia � t�tulo valor maior que refer�ncia',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZG',LEFT('Sistema em conting�ncia � t�tulo vencido',60),LEFT('Sistema em conting�ncia � t�tulo vencido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZH',LEFT('Sistema em conting�ncia � t�tulo indexado',60),LEFT('Sistema em conting�ncia � t�tulo indexado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZI',LEFT('Benefici�rio divergente',60),LEFT('Benefici�rio divergente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZJ',LEFT('Limite de pagamentos parciais excedido',60),LEFT('Limite de pagamentos parciais excedido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZK',LEFT('Boleto j� liquidado',60),LEFT('Boleto j� liquidado',60), @idInternalStatusType, 1, 1)

-- NUEVOS ESTADOS DE ERROR MAPEADOS A INTERNAL ERRORS
DECLARE @idLPInternalError as INT

 --RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idCountry = 31 AND idProvider = @idProvider

--IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('PEND')

 --EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('EXECUTED','00','BD','BE','BF','BQ')

 --ERROR_BANK _ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AN','BA','BB','BJ','BK','BM','CC','CD','CE','HA','HB','HC','HD','HE','HT','HU','HV','HX','HY','HZ','H1','H2','H3','H4','H5','H6','H7','H8','H9','TA','YA','YB','YC','YD','YE','YF','ZC','ZD','ZE','ZF','ZG','ZH','ZJ','ZK')

 --ERROR_BANNK_ACCOUNT_CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('BG','BI', 'IB','IC','ID','IE','IF','IG','IH','II','IJ','IK','IL','IM','IN','IO','IP','IQ','IR')

 --ERROR_AMOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AR','BL','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP')


 --ERROR_BANK_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AL','AZ','CA','HS')


 --ERROR_BANK_BRANCH_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '704'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AM','BA')


 --ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AS','AT','AU','AV','AW','AX','AY','CF')

 --ERROR_BENEFICIARY_NAME_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AO','ZB','ZI')

 --ERROR_BANK_PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('02','HG','HH','HI','HJ','HK','HL','HM','HN','HO','HP','HQ','HR')

 --ERROR_INVALID_DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AP','HW')

 --ERROR_ACCOUNT_NOT_MATCH_BENEFICIARY_NAME
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '711'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('IA')

 --ERROR_ACCOUNT_OF_OTHER_CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AQ','CB')

 --ERROR_LOW_BALANCE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '719'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('01','BH','HF')


ROLLBACK