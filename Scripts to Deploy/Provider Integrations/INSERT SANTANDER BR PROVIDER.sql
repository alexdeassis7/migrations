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
(@idProvider, 31, 1, '00',LEFT('Crédito ou Débito Efetivado',60),LEFT('Crédito ou Débito Efetivado',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, '01',LEFT('Insuficiência de Fundos - Débito Não Efetuado',60),LEFT('Insuficiência de Fundos - Débito Não Efetuado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '02',LEFT('Crédito ou Débito Cancelado pelo Pagador/Credor',60),LEFT('Crédito ou Débito Cancelado pelo Pagador/Credor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '03',LEFT('Débito Autorizado pela Agência - Efetuado',60),LEFT('Débito Autorizado pela Agência - Efetuado',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'AA',LEFT('Controle Inválido',60),LEFT('Controle Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AB',LEFT('Tipo de Operação Inválido',60),LEFT('Tipo de Operação Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AC',LEFT('Tipo de Serviço Inválido',60),LEFT('Tipo de Serviço Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AD',LEFT('Forma de Lançamento Inválida',60),LEFT('Forma de Lançamento Inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AE',LEFT('Tipo/Número de Inscrição Inválido',60),LEFT('Tipo/Número de Inscrição Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AF',LEFT('Código de Convênio Inválido',60),LEFT('Código de Convênio Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AG',LEFT('Agência/Conta Corrente/DV Inválido',60),LEFT('Agência/Conta Corrente/DV Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AH',LEFT('Nº Seqüencial do Registro no Lote Inválido',60),LEFT('Nº Seqüencial do Registro no Lote Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AI',LEFT('Código de Segmento de Detalhe Inválido',60),LEFT('Código de Segmento de Detalhe Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AJ',LEFT('Tipo de Movimento Inválido',60),LEFT('Tipo de Movimento Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AK',LEFT('Código da Câmara de Compensação do Banco Favorecido/Depositário Inválido',60),LEFT('Código da Câmara de Compensação do Banco Favorecido/Depositário Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AL',LEFT('Código do Banco Favorecido, Instituição de Pagamento ou Depositário Inválido',60),LEFT('Código do Banco Favorecido, Instituição de Pagamento ou Depositário Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AM',LEFT('Agência Mantenedora da Conta Corrente do Favorecido Inválida',60),LEFT('Agência Mantenedora da Conta Corrente do Favorecido Inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AN',LEFT('Conta Corrente/DV/Conta de Pagamento do Favorecido Inválido',60),LEFT('Conta Corrente/DV/Conta de Pagamento do Favorecido Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AO',LEFT('Nome do Favorecido Não Informado',60),LEFT('Nome do Favorecido Não Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AP',LEFT('Data Lançamento Inválido',60),LEFT('Data Lançamento Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AQ',LEFT('Tipo/Quantidade da Moeda Inválido',60),LEFT('Tipo/Quantidade da Moeda Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AR',LEFT('Valor do Lançamento Inválido',60),LEFT('Valor do Lançamento Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AS',LEFT('Aviso ao Favorecido - Identificação Inválida',60),LEFT('Aviso ao Favorecido - Identificação Inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AT',LEFT('Tipo/Número de Inscrição do Favorecido Inválido',60),LEFT('Tipo/Número de Inscrição do Favorecido Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AU',LEFT('Logradouro do Favorecido Não Informado',60),LEFT('Logradouro do Favorecido Não Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AV',LEFT('Nº do Local do Favorecido Não Informado',60),LEFT('Nº do Local do Favorecido Não Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AW',LEFT('Cidade do Favorecido Não Informada',60),LEFT('Cidade do Favorecido Não Informada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AX',LEFT('CEP/Complemento do Favorecido Inválido',60),LEFT('CEP/Complemento do Favorecido Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AY',LEFT('Sigla do Estado do Favorecido Inválida',60),LEFT('Sigla do Estado do Favorecido Inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AZ',LEFT('Código/Nome do Banco Depositário Inválido',60),LEFT('Código/Nome do Banco Depositário Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BA',LEFT('Código/Nome da Agência Depositária Não Informado',60),LEFT('Código/Nome da Agência Depositária Não Informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BB',LEFT('Seu Número Inválido',60),LEFT('Seu Número Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BC',LEFT('Nosso Número Inválido',60),LEFT('Nosso Número Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BD',LEFT('Inclusão Efetuada com Sucesso',60),LEFT('Inclusão Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BE',LEFT('Alteração Efetuada com Sucesso',60),LEFT('Alteração Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BF',LEFT('Exclusão Efetuada com Sucesso',60),LEFT('Exclusão Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BG',LEFT('Agência/Conta Impedida Legalmente',60),LEFT('Agência/Conta Impedida Legalmente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BH',LEFT('Empresa não pagou salário',60),LEFT('Empresa não pagou salário',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BI',LEFT('Falecimento do mutuário',60),LEFT('Falecimento do mutuário',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BJ',LEFT('Empresa não enviou remessa do mutuário',60),LEFT('Empresa não enviou remessa do mutuário',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BK',LEFT('Empresa não enviou remessa no vencimento',60),LEFT('Empresa não enviou remessa no vencimento',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BL',LEFT('Valor da parcela inválida',60),LEFT('Valor da parcela inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BM',LEFT('Identificação do contrato inválida',60),LEFT('Identificação do contrato inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BN',LEFT('Operação de Consignação Incluída com Sucesso',60),LEFT('Operação de Consignação Incluída com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BO',LEFT('Operação de Consignação Alterada com Sucesso',60),LEFT('Operação de Consignação Alterada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BP',LEFT('Operação de Consignação Excluída com Sucesso',60),LEFT('Operação de Consignação Excluída com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BQ',LEFT('Operação de Consignação Liquidada com Sucesso',60),LEFT('Operação de Consignação Liquidada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BR',LEFT('Reativação Efetuada com Sucesso',60),LEFT('Reativação Efetuada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'BS',LEFT('Suspensão Efetuada com Sucesso',60),LEFT('Suspensão Efetuada com Sucesso',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'CA',LEFT('Código de Barras - Código do Banco Inválido',60),LEFT('Código de Barras - Código do Banco Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CB',LEFT('Código de Barras - Código da Moeda Inválido',60),LEFT('Código de Barras - Código da Moeda Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CC',LEFT('Código de Barras - Dígito Verificador Geral Inválido',60),LEFT('Código de Barras - Dígito Verificador Geral Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CD',LEFT('Código de Barras - Valor do Título Inválido',60),LEFT('Código de Barras - Valor do Título Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CE',LEFT('Código de Barras - Campo Livre Inválido',60),LEFT('Código de Barras - Campo Livre Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CF',LEFT('Valor do Documento Inválido',60),LEFT('Valor do Documento Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CG',LEFT('Valor do Abatimento Inválido',60),LEFT('Valor do Abatimento Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CH',LEFT('Valor do Desconto Inválido',60),LEFT('Valor do Desconto Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CI',LEFT('Valor de Mora Inválido',60),LEFT('Valor de Mora Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CJ',LEFT('Valor da Multa Inválido',60),LEFT('Valor da Multa Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CK',LEFT('Valor do IR Inválido',60),LEFT('Valor do IR Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CL',LEFT('Valor do ISS Inválido',60),LEFT('Valor do ISS Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CM',LEFT('Valor do IOF Inválido',60),LEFT('Valor do IOF Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CN',LEFT('Valor de Outras Deduções Inválido',60),LEFT('Valor de Outras Deduções Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CO',LEFT('Valor de Outros Acréscimos Inválido',60),LEFT('Valor de Outros Acréscimos Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CP',LEFT('Valor do INSS Inválido',60),LEFT('Valor do INSS Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HA',LEFT('Lote Não Aceito',60),LEFT('Lote Não Aceito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HB',LEFT('Inscrição da Empresa Inválida para o Contrato',60),LEFT('Inscrição da Empresa Inválida para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HC',LEFT('Convênio com a Empresa Inexistente/Inválido para o Contrato',60),LEFT('Convênio com a Empresa Inexistente/Inválido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HD',LEFT('Agência/Conta Corrente da Empresa Inexistente/Inválido para o Contrato',60),LEFT('Agência/Conta Corrente da Empresa Inexistente/Inválido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HE',LEFT('Tipo de Serviço Inválido para o Contrato',60),LEFT('Tipo de Serviço Inválido para o Contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HF',LEFT('Conta Corrente da Empresa com Saldo Insuficiente',60),LEFT('Conta Corrente da Empresa com Saldo Insuficiente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HG',LEFT('Lote de Serviço Fora de Seqüência',60),LEFT('Lote de Serviço Fora de Seqüência',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HH',LEFT('Lote de Serviço Inválido',60),LEFT('Lote de Serviço Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HI',LEFT('Arquivo não aceito',60),LEFT('Arquivo não aceito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HJ',LEFT('Tipo de Registro Inválido',60),LEFT('Tipo de Registro Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HK',LEFT('Código Remessa / Retorno Inválido',60),LEFT('Código Remessa / Retorno Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HL',LEFT('Versão de layout inválida',60),LEFT('Versão de layout inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HM',LEFT('Mutuário não identificado',60),LEFT('Mutuário não identificado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HN',LEFT('Tipo do beneficio não permite empréstimo',60),LEFT('Tipo do beneficio não permite empréstimo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HO',LEFT('Beneficio cessado/suspenso',60),LEFT('Beneficio cessado/suspenso',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HP',LEFT('Beneficio possui representante legal',60),LEFT('Beneficio possui representante legal',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HQ',LEFT('Beneficio é do tipo PA (Pensão alimentícia)',60),LEFT('Beneficio é do tipo PA (Pensão alimentícia)',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HR',LEFT('Quantidade de contratos permitida excedida',60),LEFT('Quantidade de contratos permitida excedida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HS',LEFT('Beneficio não pertence ao Banco informado',60),LEFT('Beneficio não pertence ao Banco informado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HT',LEFT('Início do desconto informado já ultrapassado',60),LEFT('Início do desconto informado já ultrapassado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HU',LEFT('Número da parcela inválida',60),LEFT('Número da parcela inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HV',LEFT('Quantidade de parcela inválida',60),LEFT('Quantidade de parcela inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HW',LEFT('Margem consignável excedida para o mutuário dentro do prazo do contrato',60),LEFT('Margem consignável excedida para o mutuário dentro do prazo do contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HX',LEFT('Empréstimo já cadastrado',60),LEFT('Empréstimo já cadastrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HY',LEFT('Empréstimo inexistente',60),LEFT('Empréstimo inexistente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HZ',LEFT('Empréstimo já encerrado',60),LEFT('Empréstimo já encerrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H1',LEFT('Arquivo sem trailer',60),LEFT('Arquivo sem trailer',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H2',LEFT('Mutuário sem crédito na competência',60),LEFT('Mutuário sem crédito na competência',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H3',LEFT('Não descontado – outros motivos',60),LEFT('Não descontado – outros motivos',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H4',LEFT('Retorno de Crédito não pago',60),LEFT('Retorno de Crédito não pago',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H5',LEFT('Cancelamento de empréstimo retroativo',60),LEFT('Cancelamento de empréstimo retroativo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H6',LEFT('Outros Motivos de Glosa',60),LEFT('Outros Motivos de Glosa',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H7',LEFT('Margem consignável excedida para o mutuário acima do prazo do contrato',60),LEFT('Margem consignável excedida para o mutuário acima do prazo do contrato',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H8',LEFT('Mutuário desligado do empregador',60),LEFT('Mutuário desligado do empregador',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'H9',LEFT('Mutuário afastado por licença',60),LEFT('Mutuário afastado por licença',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IA',LEFT('Primeiro nome do mutuário diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benefício',60),LEFT('Primeiro nome do mutuário diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benefício',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IB',LEFT('Benefício suspenso/cessado pela APS ou Sisobi',60),LEFT('Benefício suspenso/cessado pela APS ou Sisobi',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IC',LEFT('Benefício suspenso por dependência de cálculo',60),LEFT('Benefício suspenso por dependência de cálculo',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ID',LEFT('Benefício suspenso/cessado pela inspetoria/auditoria',60),LEFT('Benefício suspenso/cessado pela inspetoria/auditoria',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IE',LEFT('Benefício bloqueado para empréstimo pelo beneficiário',60),LEFT('Benefício bloqueado para empréstimo pelo beneficiário',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IF',LEFT('Benefício bloqueado para empréstimo por TBM',60),LEFT('Benefício bloqueado para empréstimo por TBM',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IG',LEFT('Benefício está em fase de concessão de PA ou desdobramento',60),LEFT('Benefício está em fase de concessão de PA ou desdobramento',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IH',LEFT('Benefício cessado por óbito',60),LEFT('Benefício cessado por óbito',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'II',LEFT('Benefício cessado por fraude',60),LEFT('Benefício cessado por fraude',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IJ',LEFT('Benefício cessado por concessão de outro benefício',60),LEFT('Benefício cessado por concessão de outro benefício',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IK',LEFT('Benefício cessado: estatutário transferido para órgão de origem',60),LEFT('Benefício cessado: estatutário transferido para órgão de origem',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IL',LEFT('Empréstimo suspenso pela APS',60),LEFT('Empréstimo suspenso pela APS',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IM',LEFT('Empréstimo cancelado pelo banco',60),LEFT('Empréstimo cancelado pelo banco',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IN',LEFT('Crédito transformado em PAB',60),LEFT('Crédito transformado em PAB',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IO',LEFT('Término da consignação foi alterado',60),LEFT('Término da consignação foi alterado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IP',LEFT('Fim do empréstimo ocorreu durante período de suspensão ou concessão',60),LEFT('Fim do empréstimo ocorreu durante período de suspensão ou concessão',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IQ',LEFT('Empréstimo suspenso pelo banco',60),LEFT('Empréstimo suspenso pelo banco',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IR',LEFT('Não averbação de contrato – quantidade de parcelas/competências informadas ultrapassou a data limite da extinção de cota do dependente titular de benefícios',60),LEFT('Não averbação de contrato – quantidade de parcelas/competências informadas ultrapassou a data limite da extinção de cota do dependente titular de benefícios',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'TA',LEFT('Lote Não Aceito - Totais do Lote com Diferença',60),LEFT('Lote Não Aceito - Totais do Lote com Diferença',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YA',LEFT('Título Não Encontrado',60),LEFT('Título Não Encontrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YB',LEFT('Identificador Registro Opcional Inválido',60),LEFT('Identificador Registro Opcional Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YC',LEFT('Código Padrão Inválido',60),LEFT('Código Padrão Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YD',LEFT('Código de Ocorrência Inválido',60),LEFT('Código de Ocorrência Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YE',LEFT('Complemento de Ocorrência Inválido',60),LEFT('Complemento de Ocorrência Inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'YF',LEFT('Alegação já Informada',60),LEFT('Alegação já Informada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZB',LEFT('Divergência entre o primeiro e último nome do beneficiário versus primeiro e último nome na Receita Federal',60),LEFT('Divergência entre o primeiro e último nome do beneficiário versus primeiro e último nome na Receita Federal',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZC',LEFT('Confirmação de Antecipação de Valor',60),LEFT('Confirmação de Antecipação de Valor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZD',LEFT('Antecipação parcial de valor',60),LEFT('Antecipação parcial de valor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZE',LEFT('Título bloqueado na base',60),LEFT('Título bloqueado na base',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZF',LEFT('Sistema em contingência – título valor maior que referência',60),LEFT('Sistema em contingência – título valor maior que referência',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZG',LEFT('Sistema em contingência – título vencido',60),LEFT('Sistema em contingência – título vencido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZH',LEFT('Sistema em contingência – título indexado',60),LEFT('Sistema em contingência – título indexado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZI',LEFT('Beneficiário divergente',60),LEFT('Beneficiário divergente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZJ',LEFT('Limite de pagamentos parciais excedido',60),LEFT('Limite de pagamentos parciais excedido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ZK',LEFT('Boleto já liquidado',60),LEFT('Boleto já liquidado',60), @idInternalStatusType, 1, 1)

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