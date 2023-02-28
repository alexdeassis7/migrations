begin tran
-- TRANSACTION TYPE PROVIDER
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
'ITAUBRPIX',--esto ponemos codigo a nuestro gusto tratando que sea unico como "ITAUBR"
'Banco Itau Pix',
'Banco Itau Pix',
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
(@idProvider, 31, 1, '00',LEFT('Pagamento Efetuado',60),LEFT('Pagamento Efetuado',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'AE',LEFT('Data De Pagamento Alterada',60),LEFT('Data De Pagamento Alterada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AG',LEFT('Numero Do Lote Invalido',60),LEFT('Numero Do Lote Invalido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AH',LEFT('N� Seq�encial do Registro no Lote Inv�lido',60),LEFT('N� Seq�encial do Registro no Lote Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AI',LEFT('Producto Demostrativo de Pagamento Nao Contratado',60),LEFT('Producto Demostrativo de Pagamento Nao Contratado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AJ',LEFT('Tipo de Movimento Inv�lido',60),LEFT('Tipo de Movimento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AL',LEFT('C�digo do Banco Favorecido Inv�lido',60),LEFT('C�digo do Banco Favorecido Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AM',LEFT('Ag�ncia do Favorecido Inv�lida',60),LEFT('Ag�ncia do Favorecido Inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AN',LEFT('Conta Corrente do Favorecido Inv�lido / Conta Investimento Extinta EM 30/04/2011',60),LEFT('Conta Corrente do Favorecido Inv�lido / Conta Investimento Extinta EM 30/04/2011',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AO',LEFT('Nome do Favorecido N�o Inv�lido',60),LEFT('Nome do Favorecido N�o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AP',LEFT('Data Lan�amento Inv�lido / Data de Validade / Hora de Lanzamento / Arrecadacao / Apuracao Invalida',60),LEFT('Data Lan�amento Inv�lido / Data de Validade / Hora de Lanzamento / Arrecadacao / Apuracao Invalida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AQ',LEFT('Quantidade de Registros Maior Que 999999',60),LEFT('Quantidade de Registros Maior Que 999999',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AR',LEFT('Valor Arrencadao / Lan�amento Inv�lido',60),LEFT('Valor Arrencadao / Lan�amento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BC',LEFT('Nosso N�mero Inv�lido',60),LEFT('Nosso N�mero Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BD',LEFT('Pagamento Agendado',60),LEFT('Pagamento Agendado',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BE',LEFT('Pagamento Agendado Con forma alterada Para OP',60),LEFT('Pagamento Agendado Con forma alterada Para OP',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BI',LEFT('cnpj/cpf do beneficiário inválido no segmento j-52 ou b inválido',60),LEFT('cnpj/cpf do beneficiário inválido no segmento j-52 ou b inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BL',LEFT('Valor da parcela inv�lida',60),LEFT('Valor da parcela inv�lida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CD',LEFT('cnpj / cpf informado divergente do cadastrado',60),LEFT('cnpj / cpf informado divergente do cadastrado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CE',LEFT('pagamento cancelado',60),LEFT('pagamento cancelado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CF',LEFT('Valor do Documento Inv�lido',60),LEFT('Valor do Documento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CG',LEFT('Valor do Abatimento Inv�lido',60),LEFT('Valor do Abatimento Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CH',LEFT('Valor do Desconto Inv�lido',60),LEFT('Valor do Desconto Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CI',LEFT('cnpj / cpf / identificador / inscrição estadual / inscrição no cad / icms',60),LEFT('cnpj / cpf / identificador / inscrição estadual / inscrição no cad / icms',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CJ',LEFT('Valor da Multa Inv�lido',60),LEFT('Valor da Multa Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CK',LEFT('Tipo de inscrição inválida',60),LEFT('Tipo de inscrição inválida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CL',LEFT('Valor do INSS Inv�lido',60),LEFT('Valor do INSS Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CM',LEFT('valor do cofins inválido',60),LEFT('valor do cofins inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CN',LEFT('conta não cadastrada',60),LEFT('conta não cadastrada',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CO',LEFT('valor de outras entidades inválido',60),LEFT('valor de outras entidades inválido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CP',LEFT('confirmação de op cumprida',60),LEFT('confirmação de op cumprida',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CQ',LEFT('soma das faturas difere do pagamento',60),LEFT('soma das faturas difere do pagamento',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CR',LEFT('VALOR DO CSLL INVÁLIDO',60),LEFT('VALOR DO CSLL INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'CS',LEFT('DATA DE VENCIMENTO DA FATURA INVÁLIDA',60),LEFT('DATA DE VENCIMENTO DA FATURA INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DA',LEFT('NÚMERO DE DEPEND. SALÁRIO FAMILIA INVALIDO',60),LEFT('NÚMERO DE DEPEND. SALÁRIO FAMILIA INVALIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DB',LEFT('NÚMERO DE HORAS SEMANAIS INVÁLIDO',60),LEFT('NÚMERO DE HORAS SEMANAIS INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DC',LEFT('SALÁRIO DE CONTRIBUIÇÃO INSS INVÁLIDO',60),LEFT('SALÁRIO DE CONTRIBUIÇÃO INSS INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DD',LEFT('SALÁRIO DE CONTRIBUIÇÃO FGTS INVÁLIDO',60),LEFT('SALÁRIO DE CONTRIBUIÇÃO FGTS INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DE',LEFT('VALOR TOTAL DOS PROVENTOS INVÁLIDO',60),LEFT('VALOR TOTAL DOS PROVENTOS INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DF',LEFT('VALOR TOTAL DOS DESCONTOS INVÁLIDO',60),LEFT('VALOR TOTAL DOS DESCONTOS INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DG',LEFT('VALOR LÍQUIDO NÃO NUMÉRICO',60),LEFT('VALOR LÍQUIDO NÃO NUMÉRICO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DH',LEFT('VALOR LIQ. INFORMADO DIFERE DO CALCULADO',60),LEFT('VALOR LIQ. INFORMADO DIFERE DO CALCULADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DI',LEFT('VALOR DO SALÁRIO-BASE INVÁLIDO',60),LEFT('VALOR DO SALÁRIO-BASE INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DJ',LEFT('BASE DE CÁLCULO IRRF INVÁLIDA',60),LEFT('BASE DE CÁLCULO IRRF INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DK',LEFT('BASE DE CÁLCULO FGTS INVÁLIDA',60),LEFT('BASE DE CÁLCULO FGTS INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DL',LEFT('FORMA DE PAGAMENTO INCOMPATÍVEL COM HOLERITE',60),LEFT('FORMA DE PAGAMENTO INCOMPATÍVEL COM HOLERITE',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DM',LEFT('E-MAIL DO FAVORECIDO INVÁLIDO',60),LEFT('E-MAIL DO FAVORECIDO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'DV',LEFT('DOC / TED DEVOLVIDO PELO BANCO FAVORECIDO',60),LEFT('DOC / TED DEVOLVIDO PELO BANCO FAVORECIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D0',LEFT('FINALIDADE DO HOLERITE INVÁLIDA',60),LEFT('FINALIDADE DO HOLERITE INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D1',LEFT('MÊS DE COMPETENCIA DO HOLERITE INVÁLIDA',60),LEFT('MÊS DE COMPETENCIA DO HOLERITE INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D2',LEFT('DIA DA COMPETENCIA DO HOLETITE INVÁLIDA',60),LEFT('DIA DA COMPETENCIA DO HOLETITE INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D3',LEFT('CENTRO DE CUSTO INVÁLIDO',60),LEFT('CENTRO DE CUSTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D4',LEFT('CAMPO NUMÉRICO DA FUNCIONAL INVÁLIDO',60),LEFT('CAMPO NUMÉRICO DA FUNCIONAL INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D5',LEFT('DATA INÍCIO DE FÉRIAS NÃO NUMÉRICA',60),LEFT('DATA INÍCIO DE FÉRIAS NÃO NUMÉRICA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D6',LEFT('DATA INÍCIO DE FÉRIAS INCONSISTENTE',60),LEFT('DATA INÍCIO DE FÉRIAS INCONSISTENTE',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D7',LEFT('DATA FIM DE FÉRIAS NÃO NUMÉRICO',60),LEFT('DATA FIM DE FÉRIAS NÃO NUMÉRICO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D8',LEFT('DATA FIM DE FÉRIAS INCONSISTENTE',60),LEFT('DATA FIM DE FÉRIAS INCONSISTENTE',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'D9',LEFT('NÚMERO DE DEPENDENTES IR INVÁLIDO',60),LEFT('NÚMERO DE DEPENDENTES IR INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'EM',LEFT('CONFIRMAÇÃO DE OP EMITIDA',60),LEFT('CONFIRMAÇÃO DE OP EMITIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'EX',LEFT('DEVOLUÇÃO DE OP NÃO SACADA PELO FAVORECIDO',60),LEFT('DEVOLUÇÃO DE OP NÃO SACADA PELO FAVORECIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'E0',LEFT('TIPO DE MOVIMENTO HOLERITE INVÁLIDO',60),LEFT('TIPO DE MOVIMENTO HOLERITE INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'E1',LEFT('VALOR 01 DO HOLERITE / INFORME INVÁLIDO',60),LEFT('VALOR 01 DO HOLERITE / INFORME INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'E2',LEFT('VALOR 02 DO HOLERITE / INFORME INVÁLIDO',60),LEFT('VALOR 02 DO HOLERITE / INFORME INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'E3',LEFT('VALOR 03 DO HOLERITE / INFORME INVÁLIDO',60),LEFT('VALOR 03 DO HOLERITE / INFORME INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'E4',LEFT('VALOR 04 DO HOLERITE / INFORME INVÁLIDO',60),LEFT('VALOR 04 DO HOLERITE / INFORME INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'FC',LEFT('PAGAMENTO EFETUADO ATRAVÉS DE FINANCIAMENTO COMPROR',60),LEFT('PAGAMENTO EFETUADO ATRAVÉS DE FINANCIAMENTO COMPROR',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'FD',LEFT('PAGAMENTO EFETUADO ATRAVÉS DE FINANCIAMENTO DESCOMPROR',60),LEFT('PAGAMENTO EFETUADO ATRAVÉS DE FINANCIAMENTO DESCOMPROR',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HÁ',LEFT('ERRO NO LOTE',60),LEFT('ERRO NO LOTE',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'HM',LEFT('ERRO NO REGISTRO HEADER DE ARQUIVO',60),LEFT('ERRO NO REGISTRO HEADER DE ARQUIVO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IB',LEFT('VALOR DO DOCUMENTO INVÁLIDO',60),LEFT('VALOR DO DOCUMENTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IC',LEFT('VALOR DO ABATIMENTO INVÁLIDO',60),LEFT('VALOR DO ABATIMENTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ID',LEFT('VALOR DO DESCONTO INVÁLIDO',60),LEFT('VALOR DO DESCONTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IE',LEFT('VALOR DA MORA INVÁLIDO',60),LEFT('VALOR DA MORA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IF',LEFT('VALOR DA MULTA INVÁLIDO',60),LEFT('VALOR DA MULTA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IG',LEFT('VALOR DA DEDUÇÃO INVÁLIDO',60),LEFT('VALOR DA DEDUÇÃO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IH',LEFT('VALOR DO ACRÉSCIMO INVÁLIDO',60),LEFT('VALOR DO ACRÉSCIMO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'II',LEFT('DATA DE VENCIMENTO INVÁLIDA / QR CODE EXPIRADO',60),LEFT('DATA DE VENCIMENTO INVÁLIDA / QR CODE EXPIRADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IJ',LEFT('COMPETÊNCIA / PERÍODO REFERÊNCIA / PARCELA INVÁLIDA',60),LEFT('COMPETÊNCIA / PERÍODO REFERÊNCIA / PARCELA INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IK',LEFT('TRIBUTO NÃO LIQUIDÁVEL VIA SISPAG OU NÃO CONVENIADO COM ITAÚ',60),LEFT('TRIBUTO NÃO LIQUIDÁVEL VIA SISPAG OU NÃO CONVENIADO COM ITAÚ',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IL',LEFT('CÓDIGO DE PAGAMENTO / EMPRESA /RECEITA INVÁLIDO',60),LEFT('CÓDIGO DE PAGAMENTO / EMPRESA /RECEITA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IM',LEFT('TIPO X FORMA NÃO COMPATÍVEL',60),LEFT('TIPO X FORMA NÃO COMPATÍVEL',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IN',LEFT('BANCO/AGÊNCIA NÃO CADASTRADOS',60),LEFT('BANCO/AGÊNCIA NÃO CADASTRADOS',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IO',LEFT('DAC / VALOR / COMPETÊNCIA / IDENTIFICADOR DO LACRE INVÁLIDO / IDENTIFICAÇÃO DO QR CODE INVÁLIDO',60),LEFT('DAC / VALOR / COMPETÊNCIA / IDENTIFICADOR DO LACRE INVÁLIDO / IDENTIFICAÇÃO DO QR CODE INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IP',LEFT('DAC DO CÓDIGO DE BARRAS INVÁLIDO / ERRO NA VALIDAÇÃO DO QR CODE',60),LEFT('DAC DO CÓDIGO DE BARRAS INVÁLIDO / ERRO NA VALIDAÇÃO DO QR CODE',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IQ',LEFT('DÍVIDA ATIVA OU NÚMERO DE ETIQUETA INVÁLIDO',60),LEFT('DÍVIDA ATIVA OU NÚMERO DE ETIQUETA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IR',LEFT('PAGAMENTO ALTERADO',60),LEFT('PAGAMENTO ALTERADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IS',LEFT('CONCESSIONÁRIA NÃO CONVENIADA COM ITAÚ',60),LEFT('CONCESSIONÁRIA NÃO CONVENIADA COM ITAÚ',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IT',LEFT('VALOR DO TRIBUTO INVÁLIDO',60),LEFT('VALOR DO TRIBUTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IU',LEFT('VALOR DA RECEITA BRUTA ACUMULADA INVÁLIDO',60),LEFT('VALOR DA RECEITA BRUTA ACUMULADA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IV',LEFT('NÚMERO DO DOCUMENTO ORIGEM / REFERÊNCIA INVÁLIDO',60),LEFT('NÚMERO DO DOCUMENTO ORIGEM / REFERÊNCIA INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'IX',LEFT('CÓDIGO DO PRODUTO INVÁLIDO',60),LEFT('CÓDIGO DO PRODUTO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'LA',LEFT('DATA DE PAGAMENTO DE UM LOTE ALTERADA',60),LEFT('DATA DE PAGAMENTO DE UM LOTE ALTERADA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'LC',LEFT('LOTE DE PAGAMENTOS CANCELADO',60),LEFT('LOTE DE PAGAMENTOS CANCELADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NA',LEFT('PAGAMENTO CANCELADO POR FALTA DE AUTORIZAÇÃO',60),LEFT('PAGAMENTO CANCELADO POR FALTA DE AUTORIZAÇÃO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NB',LEFT('IDENTIFICAÇÃO DO TRIBUTO INVÁLIDA',60),LEFT('IDENTIFICAÇÃO DO TRIBUTO INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NC',LEFT('EXERCÍCIO (ANO BASE) INVÁLIDO',60),LEFT('EXERCÍCIO (ANO BASE) INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'ND',LEFT('CÓDIGO RENAVAM NÃO ENCONTRADO/INVÁLIDO',60),LEFT('CÓDIGO RENAVAM NÃO ENCONTRADO/INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NE',LEFT('UF INVÁLIDA',60),LEFT('UF INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NF',LEFT('CÓDIGO DO MUNICÍPIO INVÁLIDO',60),LEFT('CÓDIGO DO MUNICÍPIO INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NG',LEFT('PLACA INVÁLIDA',60),LEFT('PLACA INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NH',LEFT('OPÇÃO/PARCELA DE PAGAMENTO INVÁLIDA',60),LEFT('OPÇÃO/PARCELA DE PAGAMENTO INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NI',LEFT('TRIBUTO JÁ FOI PAGO OU ESTÁ VENCIDO',60),LEFT('TRIBUTO JÁ FOI PAGO OU ESTÁ VENCIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'NR',LEFT('OPERAÇÃO NÃO REALIZADA',60),LEFT('OPERAÇÃO NÃO REALIZADA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'PD',LEFT('AQUISIÇÃO CONFIRMADA (EQUIVALE A OCORRÊNCIA 02 NO LAYOUT DE RISCO SACADO)',60),LEFT('AQUISIÇÃO CONFIRMADA (EQUIVALE A OCORRÊNCIA 02 NO LAYOUT DE RISCO SACADO)',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'RJ',LEFT('REGISTRO REJEITADO',60),LEFT('REGISTRO REJEITADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'RS',LEFT('PAGAMENTO DISPONÍVEL PARA ANTECIPAÇÃO NO RISCO SACADO – MODALIDADE RISCO SACADO PÓS AUTORIZADO',60),LEFT('PAGAMENTO DISPONÍVEL PARA ANTECIPAÇÃO NO RISCO SACADO – MODALIDADE RISCO SACADO PÓS AUTORIZADO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'SS',LEFT('PAGAMENTO CANCELADO POR INSUFICIÊNCIA DE SALDO / LIMITE DIÁRIO DE PAGTO EXCEDIDO',60),LEFT('PAGAMENTO CANCELADO POR INSUFICIÊNCIA DE SALDO / LIMITE DIÁRIO DE PAGTO EXCEDIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'TA',LEFT('LOTE NÃO ACEITO - TOTAIS DO LOTE COM DIFERENÇA',60),LEFT('LOTE NÃO ACEITO - TOTAIS DO LOTE COM DIFERENÇA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'TI',LEFT('TITULARIDADE INVÁLIDA',60),LEFT('TITULARIDADE INVÁLIDA',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'X1',LEFT('FORMA INCOMPATÍVEL COM LAYOUT 010',60),LEFT('FORMA INCOMPATÍVEL COM LAYOUT 010',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'X2',LEFT('NÚMERO DA NOTA FISCAL INVÁLIDO',60),LEFT('NÚMERO DA NOTA FISCAL INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'X3',LEFT('IDENTIFICADOR DE NF/CNPJ INVÁLIDO',60),LEFT('IDENTIFICADOR DE NF/CNPJ INVÁLIDO',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'X4',LEFT('FORMA 32 INVÁLIDA',60),LEFT('FORMA 32 INVÁLIDA',60), @idInternalStatusType, 1, 1),





















(@idProvider, 31, 1, '01',LEFT('Insufici�ncia de Fundos - D�bito N�o Efetuado',60),LEFT('Insufici�ncia de Fundos - D�bito N�o Efetuado',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '02',LEFT('Cr�dito ou D�bito Cancelado pelo Pagador/Credor',60),LEFT('Cr�dito ou D�bito Cancelado pelo Pagador/Credor',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, '03',LEFT('D�bito Autorizado pela Ag�ncia - Efetuado',60),LEFT('D�bito Autorizado pela Ag�ncia - Efetuado',60), @idInternalStatusType, 0, 0),
(@idProvider, 31, 1, 'AA',LEFT('Controle Inv�lido',60),LEFT('Controle Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AB',LEFT('Tipo de Opera��o Inv�lido',60),LEFT('Tipo de Opera��o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AC',LEFT('Tipo de Servi�o Inv�lido',60),LEFT('Tipo de Servi�o Inv�lido',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'AD',LEFT('Forma de Lan�amento Inv�lida',60),LEFT('Forma de Lan�amento Inv�lida',60), @idInternalStatusType, 1, 1),

(@idProvider, 31, 1, 'AF',LEFT('C�digo de Conv�nio Inv�lido',60),LEFT('C�digo de Conv�nio Inv�lido',60), @idInternalStatusType, 1, 1),




(@idProvider, 31, 1, 'AK',LEFT('C�digo da C�mara de Compensa��o do Banco Favorecido/Deposit�rio Inv�lido',60),LEFT('C�digo da C�mara de Compensa��o do Banco Favorecido/Deposit�rio Inv�lido',60), @idInternalStatusType, 1, 1),







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


(@idProvider, 31, 1, 'BF',LEFT('Exclus�o Efetuada com Sucesso',60),LEFT('Exclus�o Efetuada com Sucesso',60), @idInternalStatusType, 0, 1),
(@idProvider, 31, 1, 'BG',LEFT('Ag�ncia/Conta Impedida Legalmente',60),LEFT('Ag�ncia/Conta Impedida Legalmente',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BH',LEFT('Empresa n�o pagou sal�rio',60),LEFT('Empresa n�o pagou sal�rio',60), @idInternalStatusType, 1, 1),

(@idProvider, 31, 1, 'BJ',LEFT('Empresa n�o enviou remessa do mutu�rio',60),LEFT('Empresa n�o enviou remessa do mutu�rio',60), @idInternalStatusType, 1, 1),
(@idProvider, 31, 1, 'BK',LEFT('Empresa n�o enviou remessa no vencimento',60),LEFT('Empresa n�o enviou remessa no vencimento',60), @idInternalStatusType, 1, 1),

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
AND [Code] IN ('AR','BL','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ')


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


--ROLLBACK
COMMIT