begin tran
/******************************************************************************
 BBVA FRANCES
******************************************************************************/
DECLARE @idProvider INT,
		@idCountry INT,
		@idInternalStatusType INT

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'ARS'
SELECT @idProvider = idProvider FROM LP_Configuration.Provider WHERE Code = 'BBBVA' and idCountry = @idCountry

-- SELECT @idCountry, @idProvider

SELECT @idInternalStatusType = idInternalStatusType FROM LP_Configuration.InternalStatusType
Where idCountry = @idCountry and Code = 'SCM'


INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'QC', 'NO INFORMA CBU PARA ABONO', 'NO INFORMA CBU PARA ABONO', @idInternalStatusType, 1, 1), -- 700

(@idProvider, @idCountry, 1, 'QM', 'CUENTA PROVEEDOR INEXISTENTE EN BBVA', 'CUENTA PROVEEDOR INEXISTENTE EN BBVA', @idInternalStatusType, 1, 1), -- 701
(@idProvider, @idCountry, 1, 'QN', 'CUENTA PROVEEDOR INACTIVA', 'CUENTA PROVEEDOR INACTIVA', @idInternalStatusType, 1, 1), -- 701

(@idProvider, @idCountry, 1, 'OI', 'IMPORTE INVALIDO EN COMPROB. DETALLE', 'IMPORTE INVALIDO EN COMPROB. DETALLE', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'O4', 'IMPORTE DE PAGO INVALIDO', 'IMPORTE DE PAGO INVALIDO', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'OM', 'IMPORTE INVALIDO EN RET-ESPECIALES', 'IMPORTE INVALIDO EN RET-ESPECIALES', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'OS', 'IMPORTE-COMPRB. INVALIDO EN DETALLE IB.', 'IMPORTE-COMPRB. INVALIDO EN DETALLE IB.', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'OU', 'ALICTA/IMPORTE INVALIDO EN DETALLE IB.', 'ALICTA/IMPORTE INVALIDO EN DETALLE IB.', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'QB', 'DIFIEREN IMPORTES - TOTAL A PAGAR', 'DIFIEREN IMPORTES - TOTAL A PAGAR', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'Q1', 'ALICTA/IMPORTE INVALIDO EN RTVS.', 'ALICTA/IMPORTE INVALIDO EN RTVS.', @idInternalStatusType, 1, 1), -- 702
(@idProvider, @idCountry, 1, 'OZ', 'IMPORTE-COMPRB. INVALIDO EN DETALLE RTVS.', 'IMPORTE-COMPRB. INVALIDO EN DETALLE RTVS.', @idInternalStatusType, 1, 1), -- 702

(@idProvider, @idCountry, 1, 'O0', 'ORDEN DE PAGO DUPLICADA', 'ORDEN DE PAGO DUPLICADA', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O1', 'REGISTRO DE PAGO DUPLICADO', 'REGISTRO DE PAGO DUPLICADO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O2', 'NUMERO DE MINUTA INVALIDO', 'NUMERO DE MINUTA INVALIDO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O5', 'NO INFORMA NUMERO DE ORDEN CASH', 'NO INFORMA NUMERO DE ORDEN CASH', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O6', 'MARCA ACREDITA SUSPENSO INVALIDA', 'MARCA ACREDITA SUSPENSO INVALIDA', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O7', 'MARCA PERMITE FINANCIACION INVALIDA', 'MARCA PERMITE FINANCIACION INVALIDA', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'O8', 'MARCA CLIENTE AJENO INVALIDA', 'MARCA CLIENTE AJENO INVALIDA', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OB', 'CENTRO DE ENTREGA INVALIDO', 'CENTRO DE ENTREGA INVALIDO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OC', 'FORMA DE PAGO INVALIDA EN PAGO', 'FORMA DE PAGO INVALIDA EN PAGO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OD', 'DISPON-PAGO INVALIDO EN PAGO', 'DISPON-PAGO INVALIDO EN PAGO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OE', 'FIRMANTE NO AUTORIZADO - SUPERA IMPORTE', 'FIRMANTE NO AUTORIZADO - SUPERA IMPORTE', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OF', 'NO EXISTE O.P PARA DETALLE DE PAGO', 'NO EXISTE O.P PARA DETALLE DE PAGO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OJ', 'IMPUESTO INVALIDO EN COMPROB. DETALLE', 'IMPUESTO INVALIDO EN COMPROB. DETALLE', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OK', 'COD.RET INVALIDO EN RET-ESPECIALES', 'COD.RET INVALIDO EN RET-ESPECIALES', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'ON', 'NRO-CERT-RET-IB NO INFORMADO', 'NRO-CERT-RET-IB NO INFORMADO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OO', 'COD.PROVINCIA IB. INVALIDA', 'COD.PROVINCIA IB. INVALIDA', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OP', 'NRO. IB. NO INFORMADO', 'NRO. IB. NO INFORMADO', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'OQ', 'FALTA CABECERA DE IB.', 'FALTA CABECERA DE IB.', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'QD', 'NO PERMITE TRANSFERENCIA OTROS BANCOS', 'NO PERMITE TRANSFERENCIA OTROS BANCOS', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'Q0', 'BASE IMPBLE. INVALIDA EN DETALLE RTVS.', 'BASE IMPBLE. INVALIDA EN DETALLE RTVS.', @idInternalStatusType, 1, 1), -- 703
(@idProvider, @idCountry, 1, 'Q2', '(DB/CR) INVALIDO EN RTVS.', '(DB/CR) INVALIDO EN RTVS.', @idInternalStatusType, 1, 1), -- 703

(@idProvider, @idCountry, 1, '99', 'DOCUMENTO ERRONEO', 'DOCUMENTO ERRONEO', @idInternalStatusType, 1, 1), -- 705
(@idProvider, @idCountry, 1, 'O3', 'NUMERO DE BENEFICIARIO INVALIDO', 'NUMERO DE BENEFICIARIO INVALIDO', @idInternalStatusType, 1, 1), -- 705

(@idProvider, @idCountry, 1, 'OH', '(DB/CR) INVALIDO EN COMPROB. DETALLE', '(DB/CR) INVALIDO EN COMPROB. DETALLE', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'OT', 'BASE IMPBLE. INVALIDA EN DETALLE IB.', 'BASE IMPBLE. INVALIDA EN DETALLE IB.', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'OV', '(DB/CR) INVALIDO EN DETALLE IB.', '(DB/CR) INVALIDO EN DETALLE IB.', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'OW', 'COD.RETENCION INVALIDO EN RTVS.', 'COD.RETENCION INVALIDO EN RTVS.', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'OX', 'NRO. CERTIFICADO INVALIDO EN RTVS.', 'NRO. CERTIFICADO INVALIDO EN RTVS.', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'QA', 'FALTAN PARAMETROS DE CONTRATO', 'FALTAN PARAMETROS DE CONTRATO', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'QP', 'NO INFORMA RETENCION DE GANANCIAS', 'NO INFORMA RETENCION DE GANANCIAS', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'QQ', 'NO INFORMA RETENCION DE IVA', 'NO INFORMA RETENCION DE IVA', @idInternalStatusType, 1, 1), -- 707
(@idProvider, @idCountry, 1, 'QR', 'RETENCION SIN DETALLE DE IMPORTE - RTVS', 'RETENCION SIN DETALLE DE IMPORTE - RTVS', @idInternalStatusType, 1, 1), -- 707

(@idProvider, @idCountry, 1, 'OG', 'FECHA INVALIDA EN COMPROB. DETALLE', 'FECHA INVALIDA EN COMPROB. DETALLE', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'Q5', 'FECHA DE PAGO INVALIDA', 'FECHA DE PAGO INVALIDA', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'Q6', 'FECHA PAGO MENOR A FECHA PROCESO', 'FECHA PAGO MENOR A FECHA PROCESO', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'Q7', 'FECHA PAGO SUPERA 360 DIAS', 'FECHA PAGO SUPERA 360 DIAS', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'Q8', 'FECHA EMISION MAYOR A FECHA PAGO', 'FECHA EMISION MAYOR A FECHA PAGO', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'Q9', 'FECHA ENTREGA MAYOR A FECHA PAGO', 'FECHA ENTREGA MAYOR A FECHA PAGO', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'OL', 'FECHA INVALIDA EN RET-ESPECIALES', 'FECHA INVALIDA EN RET-ESPECIALES', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'OR', 'FECHA INVALIDA EN DETALLE IB.', 'FECHA INVALIDA EN DETALLE IB.', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'OY', 'FECHA INVALIDA EN RTVS.', 'FECHA INVALIDA EN RTVS.', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'QS', 'FECHA DE ENTREGA INVALIDA', 'FECHA DE ENTREGA INVALIDA', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'QT', 'FECHA ENTREGA MENOR A FECHA PROCESO', 'FECHA ENTREGA MENOR A FECHA PROCESO', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'QU', 'FECHA ENTREGA SUPERA 360 DIAS', 'FECHA ENTREGA SUPERA 360 DIAS', @idInternalStatusType, 1, 1), -- 708
(@idProvider, @idCountry, 1, 'QV', 'FECHA EMISION MAYOR A FECHA ENTREGA', 'FECHA EMISION MAYOR A FECHA ENTREGA', @idInternalStatusType, 1, 1), -- 708

(@idProvider, @idCountry, 1, 'Q4', 'DIFIERE NRO. DE BENEFICIARIO', 'DIFIERE NRO. DE BENEFICIARIO', @idInternalStatusType, 1, 1), -- 710
(@idProvider, @idCountry, 1, 'Q3', 'REGISTRO DE BENEFICIARIO DUPLICADO', 'REGISTRO DE BENEFICIARIO DUPLICADO', @idInternalStatusType, 1, 1), -- 710

(@idProvider, @idCountry, 1, 'QE', 'SUPERA LIMITE DE PAGO PARA ABONO', 'SUPERA LIMITE DE PAGO PARA ABONO', @idInternalStatusType, 1, 1), -- 712
(@idProvider, @idCountry, 1, 'QJ', 'SUPERA LIMITE DE PAGO PARA CHEQUE', 'SUPERA LIMITE DE PAGO PARA CHEQUE', @idInternalStatusType, 1, 1), -- 712
(@idProvider, @idCountry, 1, 'QK', 'SUPERA LIMITE DE PAGO CHEQUE A LA ORDEN', 'SUPERA LIMITE DE PAGO CHEQUE A LA ORDEN', @idInternalStatusType, 1, 1), -- 712

(@idProvider, @idCountry, 1, 'QF', 'NO PERMITE FINANCIACION AUTOMATICA', 'NO PERMITE FINANCIACION AUTOMATICA', @idInternalStatusType, 1, 1), -- 713
(@idProvider, @idCountry, 1, 'QG', 'NO PERMITE CHEQUES AL DIA', 'NO PERMITE CHEQUES AL DIA', @idInternalStatusType, 1, 1), -- 713
(@idProvider, @idCountry, 1, 'QH', 'NO PERMITE CHEQUES CRUZADOS', 'NO PERMITE CHEQUES CRUZADOS', @idInternalStatusType, 1, 1), -- 713
(@idProvider, @idCountry, 1, 'QI', 'NO PERMITE CHEQUES NO A LA ORDEN', 'NO PERMITE CHEQUES NO A LA ORDEN', @idInternalStatusType, 1, 1) -- 713


-- ERROR_ACCOUNT_INCORRECT
DECLARE @idLPInternalError as INT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QC')

-- 701
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QM', 'QN')


-- ERROR_AMOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OI', 'O4', 'OM', 'OS', 'OU', 'QB', 'Q1', 'OZ')

-- ERROR_BANK_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('O0', 'O1', 'O2', 'O5', 'O6', 'O7', 'O8', 'OB', 'OC', 'OD', 'OE', 'OF', 'OJ', 'OK', 'ON', 'OO', 'OP', 'OQ', 'QD', 'Q0', 'Q2')


-- ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('O3')

-- ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OH', 'OT', 'OV', 'OW', 'OX', 'QA', 'QP', 'QQ', 'QR')

-- ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('OG', 'Q5', 'Q6', 'Q7', 'Q8', 'Q9', 'OL', 'OR', 'OY', 'QS', 'QT', 'QU', 'QV')

-- ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('Q4','Q3')

-- ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '712'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QE','QJ','QK')

-- ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '713'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('QF', 'QG', 'QH', 'QI')




/******************************************************************************
 BANCO GALICIA
******************************************************************************/


SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'ARS'
SELECT @idProvider = idProvider FROM LP_Configuration.Provider WHERE Code = 'BGALICIA' and idCountry = @idCountry

-- SELECT * FROM LP_Configuration.InternalStatus where idProvider = 4 ORDER BY CODE

-- ERROR_ACCOUNT_INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('25','04','22','24','29','33','47','32','45','37')


-- 701
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('06', '07', '08', '09', '10', '05')

-- 702
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('03', '26', '44')

-- 703
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('02', '14', '49', '20', '35', '56')

-- 705
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('23')

-- 706
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('30','27')

-- 707
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('46','28','65')

-- 708
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('16', '13', '18', '17', '11', '12', '19', '31', '15')

-- 710
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('43', '27', '28', '42')

-- 713
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '713'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('34', '65')

-- 715
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('21')


/******************************************************************************
 SUPERVIELLE
******************************************************************************/
SELECT @idProvider = idProvider FROM LP_Configuration.Provider WHERE Code = 'BSPVIELLE' and idCountry = @idCountry

-- 700
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('36')


-- 707
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('14', '15', '18', '20', '50', '51', '52', '56', '57', '60', '62')

-- 709
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('35', '54')


commit tran