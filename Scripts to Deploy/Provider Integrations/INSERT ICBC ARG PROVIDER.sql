BEGIN TRAN

DECLARE @idCountry			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idCurrencyType		   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idProvider			   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idPayWayService	   [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
		@idInternalStatusType  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'ARG')
SET @idCurrencyType = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType where Code = 'ARS')

INSERT INTO LP_Configuration.[Provider] ([Code], [Name], [Description], [idCountry], Active)
VALUES (
	'ICBC',
	'Banco ICBC',
	'Industrial Commercial Bank of China S.A',
	@idCountry,
	1
)

SET @idProvider = SCOPE_IDENTITY()  

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2, @idProvider, 1)

SET @idPayWayService = (SELECT idPayWayService FROM [LP_Configuration].[PayWayServices] WHERE idCountry = @idCountry AND Code = 'BANKDEPO')

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (
	@idProvider,
	@idPayWayService,
	1
)

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountry AND Code = 'SCM')

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES 
(@idProvider, @idCountry, 1, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
(@idProvider, @idCountry, 1, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'STATUSNFDB', 'Status not found in database.', 'Status not found in database.', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'RETURNED','The payout has been returned','The payout has been returned', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'RECALLED','The payout has been recalled','The payout has been recalled', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OnHold','Waiting for authentication','Waiting for authentication', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
(@idProvider, @idCountry, 1, '1PP001', 'ERROR TIPO DE REGISTRO', 'ERROR TIPO DE REGISTRO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP019', 'CUENTA ERRONEA', 'CUENTA ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP020', 'PARTICIPE DE CTA NO ENCONTRADO', 'PARTICIPE DE CTA NO ENCONTRADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP023', 'FECHA DE PAGO ERRONEA', 'FECHA DE PAGO ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP024', 'MONEDA ERRONEA', 'MONEDA ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP025', 'ORDENANTE INEXISTENTE', 'ORDENANTE INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP026', 'LISTA DUPLICADA', 'LISTA DUPLICADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP027', 'ITEM NO NUMERICO', 'ITEM NO NUMERICO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP028', 'NRO. DE BENEF NO NUMERICO', 'NRO. DE BENEF NO NUMERICO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP029', 'NOMBRE DE BENEF SIN INFORMAR', 'NOMBRE DE BENEF SIN INFORMAR',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP030', 'IMPORTE DE PAGO ERRONEO', 'IMPORTE DE PAGO ERRONEO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP031', 'FECHA DE PAGO DEL ITEM ERRONEA', 'FECHA DE PAGO DEL ITEM ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP032', 'FORMA DE PAGO DEL ITEM ERRONEA', 'FORMA DE PAGO DEL ITEM ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '1PP999', 'ERROR DE DATOS', 'ERROR DE DATOS',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE000', 'CUENTA INEXISTENTE', 'CUENTA INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0002', 'CREDITO RECHAZADO', 'CREDITO RECHAZADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0007', 'OPERACION IMPROCEDENTE', 'OPERACION IMPROCEDENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0038', 'CUENTA NO EXISTE EN TABLA', 'CUENTA NO EXISTE EN TABLA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0060', 'CUENTA PRECANCELADA', 'CUENTA PRECANCELADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0181', 'CUENTA BLOQUEADA', 'CUENTA BLOQUEADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0182', 'OPERACION REINTEGRO CON CUENTA EN ESTADO NO NORMAL', 'OPERACION REINTEGRO CON CUENTA EN ESTADO NO NORMAL',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0251', 'INDICADOR DE ORIGEN NO CORRECTO', 'INDICADOR DE ORIGEN NO CORRECTO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0254', 'ENTIDAD ERRONEA O NO INFORMADA', 'ENTIDAD ERRONEA O NO INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0255', 'OFICINA ERRONEA O NO INFORMADA', 'OFICINA ERRONEA O NO INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0256', 'FECHA ERRONEA O NO INFORMADA', 'FECHA ERRONEA O NO INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0257', 'HORA ERRONEA O NO INFORMADA', 'HORA ERRONEA O NO INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0258', 'IMPORTE ERRONEO O NO INFORMADO', 'IMPORTE ERRONEO O NO INFORMADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0259', 'CODIGO ERRONEO O NO INFORMADO', 'CODIGO ERRONEO O NO INFORMADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0265', 'EL IMPORTE ACTUAL SUPERO AL IMPORTE ORIGINAL', 'EL IMPORTE ACTUAL SUPERO AL IMPORTE ORIGINAL',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0500', 'CUENTA NO INFORMADA', 'CUENTA NO INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0503', 'SITUACION DE LA CUENTA NO NORMAL', 'SITUACION DE LA CUENTA NO NORMAL',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0506', 'NO ADMITE DOMICILIACIONES ESTE PRODUCTO', 'NO ADMITE DOMICILIACIONES ESTE PRODUCTO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0515', 'SALDO INSUFICIENTE', 'SALDO INSUFICIENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE0517', 'EL CARGO NO SUPERA EL MINIMO A CARGAR', 'EL CARGO NO SUPERA EL MINIMO A CARGAR',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1425', 'SE DEBE INGRESAR AL MENOS UN INDICADOR DE IMPUESTO A COB', 'SE DEBE INGRESAR AL MENOS UN INDICADOR DE IMPUESTO A COB',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1550', 'CENTRO ORIGEN/DESTINO INVALIDO', 'CENTRO ORIGEN/DESTINO INVALIDO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1552', 'NO SE DEBEN INFORMAR SIMULTANEAMENTE CODIGO DE OPERACION', 'NO SE DEBEN INFORMAR SIMULTANEAMENTE CODIGO DE OPERACION',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1553', 'DEBE INFORMAR CODIGO DE OPERACION O EVENTO', 'DEBE INFORMAR CODIGO DE OPERACION O EVENTO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1600', 'FECHA DE OPERACION INVALIDA', 'FECHA DE OPERACION INVALIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1601', 'FECHA CONTABLE INVALIDA', 'FECHA CONTABLE INVALIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1602', 'FECHA VALOR INVALIDA', 'FECHA VALOR INVALIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1715', 'ENTIDAD ASOCIADA INVALIDA', 'ENTIDAD ASOCIADA INVALIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1716', 'INVALIDA LA CUENTA ASOCIADA', 'INVALIDA LA CUENTA ASOCIADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1717', 'INVALIDO EL CENTRO ASOCIADO', 'INVALIDO EL CENTRO ASOCIADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1740', 'NO SE ENCUENTRA EL CLIENTE ASOCIADO A LA CUENTA', 'NO SE ENCUENTRA EL CLIENTE ASOCIADO A LA CUENTA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE1833', 'NO SE PERMITE SALDO DEUDOR EN CAJAS DE AHORRO', 'NO SE PERMITE SALDO DEUDOR EN CAJAS DE AHORRO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE2040', 'CUENTA EMBARGADA', 'CUENTA EMBARGADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBGE2041', 'SALDO INSUFICENTE EN DIAS ANTERIORES', 'SALDO INSUFICENTE EN DIAS ANTERIORES',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0200', 'EL CODIGO NO ES NUMERICO', 'EL CODIGO NO ES NUMERICO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0202', 'INDICADOR DE FUNCION INCORRECTO', 'INDICADOR DE FUNCION INCORRECTO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0203', 'CODIGO INEXISTENTE', 'CODIGO INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0204', 'EL IMPORTE NO VIENE INFORMADO', 'EL IMPORTE NO VIENE INFORMADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0205', 'LA FECHA OPERACION NO ESTA INFORMADA', 'LA FECHA OPERACION NO ESTA INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0206', 'LA HORA OPERACION NO ESTA INFORMADA', 'LA HORA OPERACION NO ESTA INFORMADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0207', 'FECHA VALOR NO VIENE INFORMADA (ES REQUERIDA)', 'FECHA VALOR NO VIENE INFORMADA (ES REQUERIDA)',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0208', 'FECHA OPERACION INCORRECTA', 'FECHA OPERACION INCORRECTA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0209', 'EL CODIGO ESTA BLOQUEADO', 'EL CODIGO ESTA BLOQUEADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0210', 'LOS CODIGOS DE INGRESO ESTAN BLOQUEADOS', 'LOS CODIGOS DE INGRESO ESTAN BLOQUEADOS',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0211', 'LOS CODIGOS DE REINTEGRO ESTAN BLOQUEADOS', 'LOS CODIGOS DE REINTEGRO ESTAN BLOQUEADOS',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0212', 'EL IMPORTE ES NEGATIVO (CODIGO DE INGRESO)', 'EL IMPORTE ES NEGATIVO (CODIGO DE INGRESO)',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0213', 'EL IMPORTE ES POSITIVO (CODIGO DE REINTEGRO)', 'EL IMPORTE ES POSITIVO (CODIGO DE REINTEGRO)',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0214', 'EL CODIGO ESTA INACTIVO', 'EL CODIGO ESTA INACTIVO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0215', 'LA FECHA VALOR ESTA FUERA DE LIMITES', 'LA FECHA VALOR ESTA FUERA DE LIMITES',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0217', 'LAS OBSERVACIONES NO VIENE INFORMADAS (SON REQUERIDAS)', 'LAS OBSERVACIONES NO VIENE INFORMADAS (SON REQUERIDAS)',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0218', 'LOS CODIGOS DE LA BASE DE DATOS NO SON SECUENCIALES', 'LOS CODIGOS DE LA BASE DE DATOS NO SON SECUENCIALES',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0219', 'CODIGO CUENTA CLIENTE NO VIENE INFORMADO', 'CODIGO CUENTA CLIENTE NO VIENE INFORMADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBLE0220', 'LA FECHA-VALOR ASUMIDA NO COINCIDE CON LA FECHA-VALOR', 'LA FECHA-VALOR ASUMIDA NO COINCIDE CON LA FECHA-VALOR',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPBRE0018', 'PRODUCTO INEXISTENTE', 'PRODUCTO INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR02', 'CUENTA CERRADA O SUSPENDIDA', 'CUENTA CERRADA O SUSPENDIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR03', 'CUENTA INEXISTENTE', 'CUENTA INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR04', 'NUMERO DE CUENTA INVALIDOS', 'NUMERO DE CUENTA INVALIDOS',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR07', 'SOLICITUD DE LA ENTIDAD ORIGINANTE', 'SOLICITUD DE LA ENTIDAD ORIGINANTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR08', 'ORDEN DE NO PAGAR', 'ORDEN DE NO PAGAR',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR10', 'FALTA DE FONDOS', 'FALTA DE FONDOS',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR13', 'SUCURSAL/ENTIDAD/DESTINO INEXISTENTE', 'SUCURSAL/ENTIDAD/DESTINO INEXISTENTE',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR14', 'IDENTIFICACION DEL CLIENTE EN LA EMPRESA ERRONEO', 'IDENTIFICACION DEL CLIENTE EN LA EMPRESA ERRONEO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR15', 'BAJA DE SERVICIO', 'BAJA DE SERVICIO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR17', 'ERROR DE FORMATO', 'ERROR DE FORMATO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR18', 'FECHA DE COMPENSACION ERRONEA', 'FECHA DE COMPENSACION ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR19', 'IMPORTE ERRONEO', 'IMPORTE ERRONEO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR20', 'MONEDA DISTINTA A LA DE LA CUENTA DE DEBITO', 'MONEDA DISTINTA A LA DE LA CUENTA DE DEBITO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR23', 'SUCURSAL NO HABILITADA', 'SUCURSAL NO HABILITADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR24', 'TRANSACCION DUPLICADA', 'TRANSACCION DUPLICADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR29', 'REVERSION YA EFECTUADA', 'REVERSION YA EFECTUADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR34', 'CLIENTE NO ADHERIDO', 'CLIENTE NO ADHERIDO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR75', 'FECHA INVALIDA', 'FECHA INVALIDA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR86', 'IDENTIFICACION DE LA EMPRESA ERRONEA', 'IDENTIFICACION DE LA EMPRESA ERRONEA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR90', 'TRX NO CORRESPONDE, NO EXISTE LA TRX ORIGINAL', 'TRX NO CORRESPONDE, NO EXISTE LA TRX ORIGINAL',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPR95', 'REVERSA DE RECEPTORA FUERA DE TERMINO', 'REVERSA DE RECEPTORA FUERA DE TERMINO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, '9PPREC', 'RECHAZO CUENTA EMBARGADA', 'RECHAZO CUENTA EMBARGADA',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP01001 ', 'NO SE INFORMARON TODOS LOS CAMPOS.', 'NO SE INFORMARON TODOS LOS CAMPOS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP01002 ', 'ERROR EN DB AL ACTUALIZAR MAESTRO.', 'ERROR EN DB AL ACTUALIZAR MAESTRO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP01003 ', 'ERROR EN DB AL INSERTAR ADJUNO DE ITEM.', 'ERROR EN DB AL INSERTAR ADJUNO DE ITEM.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP01004 ', 'EL ITEM SE INSERTO EN FORMA PARCIAL.', 'EL ITEM SE INSERTO EN FORMA PARCIAL.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02001 ', 'LA FORMA DE PAGO ES INVALIDA.', 'LA FORMA DE PAGO ES INVALIDA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02002 ', 'EL CODIGO DE MONEDA ES INVALIDO.', 'EL CODIGO DE MONEDA ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02003 ', 'EL MONTO DE ITEM ES', 'EL MONTO DE ITEM ES',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02004 ', 'INVALIDO. LA FECHA DE PAGO ES INVALIDA.', 'INVALIDO. LA FECHA DE PAGO ES INVALIDA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02005 ', 'EL COMPROBANTE ES INVALIDO.', 'EL COMPROBANTE ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02006 ', 'EL TIPO DE CUENTA NO ES VALIDO.', 'EL TIPO DE CUENTA NO ES VALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02007 ', 'EL NUMERO DE CUENTA ES INVALIDO.', 'EL NUMERO DE CUENTA ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02008 ', 'LA CUENTA NO ES VALIDA. %S', 'LA CUENTA NO ES VALIDA. %S',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02009 ', 'LA CUENTA NO ES VALIDA PARA EL TIPO DE ORDENANTE.', 'LA CUENTA NO ES VALIDA PARA EL TIPO DE ORDENANTE.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02010 ', 'UN ORDENANTE ABIERTO NO PUEDE TENER LISTAS.', 'UN ORDENANTE ABIERTO NO PUEDE TENER LISTAS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02011 ', 'EL NOMBRE DEL BENEFICIARIO NO PUEDE ESTAR VACIO.', 'EL NOMBRE DEL BENEFICIARIO NO PUEDE ESTAR VACIO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02012 ', 'EL TIPO DE DOCUMENTO DEL BENEFICIARIO ES INVALIDO.', 'EL TIPO DE DOCUMENTO DEL BENEFICIARIO ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02013 ', 'EL NUMERO DE DOCUMENTO DEL BENEFICIARIO ES INVALIDO.', 'EL NUMERO DE DOCUMENTO DEL BENEFICIARIO ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02014 ', 'EL NUMERO DE PROVEEDOR NO ES VALIDO.', 'EL NUMERO DE PROVEEDOR NO ES VALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02015 ', 'EL DOMICILIO NO PUEDE SER VACIO ', 'EL DOMICILIO NO PUEDE SER VACIO ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02016 ', 'LA LOCALIDAD NO PUEDE SER VACIA ', 'LA LOCALIDAD NO PUEDE SER VACIA ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02017 ', 'EL CODIGO POSTAL NO PUEDE SER VACIO ', 'EL CODIGO POSTAL NO PUEDE SER VACIO ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02018 ', 'EL TELEFONO NO ES VALIDO ', 'EL TELEFONO NO ES VALIDO ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02019 ', 'EL CODIGO DE MONEDA DEL ITEM NO COINCIDE CON EL DE LA LISTA.', 'EL CODIGO DE MONEDA DEL ITEM NO COINCIDE CON EL DE LA LISTA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02020 ', 'LA ALTURA DEL DOMICILIO NO ES VALIDA ', 'LA ALTURA DEL DOMICILIO NO ES VALIDA ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02021 ', 'EL CODIGO DE PROVINCIA NO PUEDE SER VACII ', 'EL CODIGO DE PROVINCIA NO PUEDE SER VACII ',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02022 ', 'EL TIPO DE DOCUMENTO DEL PROVEEDOR ORIGINAL ES INVALIDO.', 'EL TIPO DE DOCUMENTO DEL PROVEEDOR ORIGINAL ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02023 ', 'EL NUMERO DE DOCUMENTO DEL PROVEEDOR ORIGINAL ES INVALIDO.', 'EL NUMERO DE DOCUMENTO DEL PROVEEDOR ORIGINAL ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02024 ', 'EL TIPO DE DOCUMENTO DEL COBRADOR 1 ES INVALIDO.', 'EL TIPO DE DOCUMENTO DEL COBRADOR 1 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02025 ', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 1 ES INVALIDO.', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 1 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02026 ', 'EL TIPO DE DOCUMENTO DEL COBRADOR 2 ES INVALIDO.', 'EL TIPO DE DOCUMENTO DEL COBRADOR 2 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02027 ', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 2 ES INVALIDO.', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 2 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02028 ', 'EL TIPO DE DOCUMENTO DEL COBRADOR 3 ES INVALIDO.', 'EL TIPO DE DOCUMENTO DEL COBRADOR 3 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02029 ', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 3 ES INVALIDO.', 'EL NUMERO DE DOCUMENTO DEL COBRADOR 3 ES INVALIDO.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02030 ', 'LA FECHA DE PAGO DEL ITEM NO ES VALIDA.', 'LA FECHA DE PAGO DEL ITEM NO ES VALIDA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02037 ', 'ESTA INTENTANDO INSERTAR UN ITEM CON FECHA VENCIDA.', 'ESTA INTENTANDO INSERTAR UN ITEM CON FECHA VENCIDA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02038 ', 'LOS DATOS DEL ITEM NO SON VALIDOS PARA EL TIPO DE ORDENANTE.', 'LOS DATOS DEL ITEM NO SON VALIDOS PARA EL TIPO DE ORDENANTE.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02039 ', 'LOS DATOS DEL PROVEEDOR ORIGINAL ESTAN INCOMPLETOS.', 'LOS DATOS DEL PROVEEDOR ORIGINAL ESTAN INCOMPLETOS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02040 ', 'LOS DATOS DEL COBRADOR 1 ORIGINAL ESTAN INCOMPLETOS.', 'LOS DATOS DEL COBRADOR 1 ORIGINAL ESTAN INCOMPLETOS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02041 ', 'LOS DATOS DEL COBRADOR 2 ORIGINAL ESTAN INCOMPLETOS.', 'LOS DATOS DEL COBRADOR 2 ORIGINAL ESTAN INCOMPLETOS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02042 ', 'LOS DATOS DEL COBRADOR 3 ORIGINAL ESTAN INCOMPLETOS.', 'LOS DATOS DEL COBRADOR 3 ORIGINAL ESTAN INCOMPLETOS.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02052 ', 'CODIGO DE SUCURSAL INEXISTENTE.', 'CODIGO DE SUCURSAL INEXISTENTE.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02053 ', 'CODIGO DE BANCO INVALIDO EN CBU.', 'CODIGO DE BANCO INVALIDO EN CBU.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP02090 ', '%S CONTIENE UN VALOR INVALIDO', '%S CONTIENE UN VALOR INVALIDO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP03001 ', 'ERROR AL OBTENER DATOS A PARTIR DE LA CUENTA.', 'ERROR AL OBTENER DATOS A PARTIR DE LA CUENTA.',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'UPLPP04000 ', 'LONGITUD DE LINEA EXCEDE MAXIMO ESPECIFICADO', 'LONGITUD DE LINEA EXCEDE MAXIMO ESPECIFICADO',  @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'AML', 'Rejected by AML', 'Rejected by AML', @idInternalStatusType, 1, 1),
(@idProvider, @idCountry, 1, 'OK', 'El archivo se recibio exitosamente', 'El archivo se recibio exitosamente', @idInternalStatusType, 0, 0)

DECLARE @idLPInternalError INT
-- EXECUTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '300'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('EXECUTED')

-- RECEIVED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '100'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE [Code] IN ('RECI') AND idProvider = @idProvider

-- IN PROGRESS
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '200'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('PEND')

--REJECTED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('REJECTED','1PP999','9PPR08','9PPR10','9PPREC')

--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('1PP019','9PPR03','9PPBGE000','9PPBGE2040')

--ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('1PP030','9PPBGE0258','9PPBLE0204','9PPR19','UPLPP02003','9PPBLE0212','9PPBLE0213')

--ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('UPLPP02053')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('UPLPP02012','UPLPP02013','UPLPP02022','UPLPP02023','UPLPP02024','UPLPP02025','UPLPP02026','UPLPP02027','UPLPP02028','UPLPP02029')

--ERROR BENEFICIARY NAME INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('1PP029','UPLPP02011')

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('9PPBGE0002')

--ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('1PP023','1PP031', '9PPBGE0256', '9PPBGE1600', '9PPBGE1601', '9PPBGE1602', '9PPBLE0207', '9PPBLE0208','9PPR75','UPLPP02004','UPLPP02030','UPLPP02037')

--ERROR ACCOUNT TYPE INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('UPLPP02006')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('UPLPP02012','UPLPP02013','UPLPP02022','UPLPP02023','UPLPP02024','UPLPP02025','UPLPP02026','UPLPP02027','UPLPP02028','UPLPP02029')

--ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('1PP024','9PPR20','UPLPP02002')


--REJECTED BY AML
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '718'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('AML')

ROLLBACK