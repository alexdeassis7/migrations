BEGIN TRAN;

-- CAMBIAR ESTO SI SE COPIA A OTRO PAIS ----

DECLARE @PAIS				VARCHAR(MAX)	= 'PARAGUAY';			-- Ej. EJEMPLO PARAGUAY
DECLARE @CODE				VARCHAR(10)		= 'ITAUPYG';			-- Ej. ABC
DECLARE @NAME				VARCHAR(60)		= 'Banco Itau';			-- Ej. Banco ABC
DECLARE @LONG_DESCRIPTION	VARCHAR(60)		= 'Banco Itau Paraguay'; 

-- FIN DE AREA DE CAMBIOS

---  CONSTANTES / GLOBALES
DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT];	-- TRANSACTION TYPE PROVIDER
DECLARE @ACTIVE_CONST BIT = 1;										-- SETEO DE ACTIVO A 1 (TRUE)
DECLARE @idCountry INT;												-- CODIGO DE PAIS QUE TOMA DE LA VARIABLE @PAIS





BEGIN TRY
	
	-- BUSCAMOS EL ID DE PAIS
	SET @idCountry=(SELECT TOP(1)[idCountry] FROM [LP_Location].[Country]  WHERE [Name]=@PAIS AND [Active]=@ACTIVE_CONST ORDER BY idCountry);

	IF @idCountry IS NULL
	THROW 50000, 'THE COUNTRY DOES NOT EXIST OR HAS A TYPO', 1;

	IF EXISTS(SELECT TOP (1) Code FROM LP_Configuration.[Provider] WHERE Code = @CODE ORDER BY Code)
	BEGIN	
		DECLARE @ERROR VARCHAR(max) = CONCAT('Provider with code: ', @CODE, ' already Exist');
		THROW 50000, @ERROR , 1;
	END

    -- TABLA PROVIDER
    INSERT INTO LP_Configuration.[Provider]([Code], [Name], [Description], [idCountry], Active)
    VALUES(
	@CODE, --esto ponemos codigo a nuestro gusto tratando que sea unico como "ITAUBR"
    @NAME, -- Esto es Nombre
    @LONG_DESCRIPTION, -- Esto es la Descripcion LARGA
	@idCountry, -- PAIS
	@ACTIVE_CONST   -- SETEAMOS COMO ACTIVO
	);

    SET @idProvider=SCOPE_IDENTITY();

    -- SETEO DE Transaction Type Provider 
    INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
    VALUES(2, @idProvider, @ACTIVE_CONST);

    DECLARE @idPayWayService AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT];
    SET @idPayWayService=(SELECT TOP(1)[idPayWayService]
                          FROM [LP_Configuration].[PayWayServices]
                          WHERE Code='BANKDEPO' AND idCountry=@idCountry
                          ORDER BY idPayWayService);

	-- ProviderPayWayServices
    INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
    VALUES(@idProvider, @idPayWayService, @ACTIVE_CONST);

	-- STATUS Type
    DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT];
    SET @idInternalStatusType=(SELECT TOP(1)idInternalStatusType
                               FROM [LP_Configuration].[InternalStatusType]
                               WHERE Code='SCM' AND idCountry=@idCountry
                               ORDER BY idInternalStatusType);
	
	-- SETEO DE Estados Internos
    INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
    VALUES
		(@idProvider, @idCountry, @ACTIVE_CONST, 'RECI', 'RECIBIDO', 'RECIBIDO', @idInternalStatusType, 0, 0),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'PEND', 'PENDIENTE', 'PENDIENTE', @idInternalStatusType, 0, 0),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'EXECUTED', 'Tx ejecutada.', 'Tx ejecutada.', @idInternalStatusType, 0, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'REJECTED', 'Tx rechazada.', 'Tx rechazada.', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNA0011', 'Alta exitosa', 'Alta exitosa.', @idInternalStatusType, 0, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNA0803', 'Modificacion exitosa', 'Modificacion exitosa', @idInternalStatusType, 0, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0010', 'Error con el codigo bancario', 'Error con el codigo bancario', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0022', 'Cuenta inexistente', 'Cuenta inexistente', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0047', 'Asunto invalido', 'Asunto invalido', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0081', 'Cod aba/bic erroneo', 'Cod aba/bic erroneo', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0082', 'Divisa invalida', 'Divisa invalida', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0083', 'Asunto invalido', 'Asunto invalido', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0212', 'Monto con formato erroneo', 'Monto con formato erroneo', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0316', 'Formato cta invalido', 'Formato cta invalido', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0552', 'Monto en ceros', 'Monto en ceros', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'KNE0818', 'Error con el registro', 'Registro ya existe', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'CNE1202', 'Cuenta no valida', 'Cuenta no valida', @idInternalStatusType, 1, 1),
        (@idProvider, @idCountry, @ACTIVE_CONST, 'CNE1225', 'Divisa no permitida en el lote', 'Divisa no permitida en el lote', @idInternalStatusType, 1, 1);

    -- NUEVOS ESTADOS DE ERROR MAPEADOS A INTERNAL ERRORS
    DECLARE @idLPInternalError AS INT;
    
	--RECEIVED
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='100';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE [Code] IN ('RECI')AND idCountry=@idCountry AND idProvider=@idProvider;

    --IN PROGRESS
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='200';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('PEND');

    --EXECUTED
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='300';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
	SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('EXECUTED', 'KNA0011', 'KNA0803');

    --ERROR_BANK _ACCOUNT_INCORRECT
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='700';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('KNE0010', 'KNE0022', 'KNE0316', 'CNE1202');

    --ERROR_BANNK_ACCOUNT_CLOSED
    SELECT @idLPInternalError=idLPInternalError  FROM [LP_Configuration].[LPInternalError] WHERE Code='701';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_AMOUNT_INCORRECT
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='702';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('KNE0212', 'KNE0552');

    --ERROR_BANK_INVALID
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='703';
	
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_BENEFICIARY_DOCUMENT_ID_INVALID
    SELECT @idLPInternalError=idLPInternalError  FROM [LP_Configuration].[LPInternalError] WHERE Code='705';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_BENEFICIARY_NAME_INCORRECT
    SELECT @idLPInternalError=idLPInternalError  FROM [LP_Configuration].[LPInternalError] WHERE Code='706';
	
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_BANK_PROCESSING
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='707';

    INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('KNE0047', 'KNE0081', 'KNE0083', 'KNE0818');

    --ERROR_INVALID_DATE
    SELECT @idLPInternalError=idLPInternalError  FROM [LP_Configuration].[LPInternalError] WHERE Code='708';

    INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_ACCOUNT_TYPE_INCORRECT
    SELECT @idLPInternalError=idLPInternalError  FROM [LP_Configuration].[LPInternalError] WHERE Code='709';
	
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('AP', 'HW');

    --ERROR_ACCOUNT_TYPE_NOT_MATCH_BENEFICIARY_DOCUMENT
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='710';
	
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('REJECTED');

    --ERROR_ACCOUNT_OF_OTHER_CURRENCY
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='715';

    INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider=@idProvider AND [Code] IN ('KNE0082', 'CNE1225');

    --ERROR_ACCOUNT_OF_OTHER_CURRENCY
    SELECT @idLPInternalError=idLPInternalError FROM [LP_Configuration].[LPInternalError] WHERE Code='718';
    
	INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
    SELECT idInternalStatus, @idLPInternalError
    FROM LP_Configuration.InternalStatus
    WHERE idProvider= @idProvider AND [Code] IN ('REJECTED');
    
	PRINT 'Finalizado'
	COMMIT TRAN;

END TRY
BEGIN CATCH

    PRINT 'Saliendo, ocurrio un error';
	SELECT ERROR_MESSAGE() AS ErrorMessage;
	ROLLBACK TRAN;

END CATCH;