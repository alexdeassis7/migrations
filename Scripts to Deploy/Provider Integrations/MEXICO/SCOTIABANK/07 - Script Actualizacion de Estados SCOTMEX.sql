USE LocalPaymentPROD

Declare @DescriptionReturned VARCHAR(500) = (Select top 1 Description from Lp_configuration.internalstatus where code = 'RETURNED')
Declare @DescriptionRecalled VARCHAR(500) = (Select top 1 Description from Lp_configuration.internalstatus where code = 'RECALLED')
Declare @DescriptionOnHold VARCHAR(500) = (Select top 1 Description from Lp_configuration.internalstatus where code = 'OnHold')

DECLARE @idProvider INT = (SELECT DISTINCT [idProvider] FROM [LP_Configuration].[Provider] WHERE Code = 'SCOTMEX' AND [Active] = 1)
DECLARE @idCountry INT = (SELECT DISTINCT [idCountry] FROM [LP_Location].[Country] WHERE Code = 'MXN' AND [Active] = 1)
DECLARE @idInternalStatusType INT = (Select DISTINCT idInternalStatusType from [LP_Configuration].[InternalStatusType]  WHERE idCountry = @idCountry)

IF NOT EXISTS(Select * from [LP_Configuration].INTERNALSTATUS WHERE idProvider = @idProvider AND CODE = 'RECALLED')
BEGIN 
	INSERT INTO [LP_Configuration].[InternalStatus]
	([Code]
	,[Name]
	,[Description]
	,[idProvider]
	,[idCountry]
	,[Active]
	,[OP_InsDateTime]
	,[OP_UpdDateTime]
	,[DB_InsDateTime]
	,[DB_UpdDateTime]
	,[idInternalStatusType]
	,[isError]
	,[FinalStatus])
	VALUES
	('RECALLED'
	,@DescriptionRecalled 
	,@DescriptionRecalled
	,@idProvider
	,@idCountry
	,1
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,@idInternalStatusType
	,1
	,1)
END 
IF NOT EXISTS(Select * from [LP_Configuration].INTERNALSTATUS WHERE idProvider = @idProvider AND CODE = 'RETURNED')
BEGIN 
	INSERT INTO [LP_Configuration].[InternalStatus]
	([Code]
	,[Name]
	,[Description]
	,[idProvider]
	,[idCountry]
	,[Active]
	,[OP_InsDateTime]
	,[OP_UpdDateTime]
	,[DB_InsDateTime]
	,[DB_UpdDateTime]
	,[idInternalStatusType]
	,[isError]
	,[FinalStatus])
	VALUES
	('RETURNED'
	,@DescriptionReturned
	,@DescriptionReturned
	,@idProvider
	,@idCountry
	,1
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,@idInternalStatusType
	,1
	,1)
END 
 
IF NOT EXISTS(Select * from [LP_Configuration].INTERNALSTATUS WHERE idProvider = @idProvider AND CODE = 'OnHold')
BEGIN 
	INSERT INTO [LP_Configuration].[InternalStatus]
	([Code]
	,[Name]
	,[Description]
	,[idProvider]
	,[idCountry]
	,[Active]
	,[OP_InsDateTime]
	,[OP_UpdDateTime]
	,[DB_InsDateTime]
	,[DB_UpdDateTime]
	,[idInternalStatusType]
	,[isError]
	,[FinalStatus])
	VALUES
	('OnHold'
	,@DescriptionOnHold
	,@DescriptionOnHold
	,@idProvider
	,@idCountry
	,1
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,GETDATE()
	,@idInternalStatusType
	,1
	,1)
END 

--- Rejected ---
IF NOT EXISTS(Select * from [LP_Configuration].INTERNALSTATUS WHERE idProvider = @idProvider AND CODE = 'REJECTED' AND [Name] = 'Rechazado 700')
BEGIN 
DECLARE @LastIdGenerated INT 
-- Si existe alguna relacion para el CODE REJECTED se proceden a eliminar 
Delete FROM LP_Configuration.LPInternalStatusClient Where idInternalStatus in (
Select idInternalStatus from LP_Configuration.InternalStatus Where idProvider = @idProvider AND Code = 'REJECTED'
) 

DECLARE status_cursor CURSOR FOR 
-- Selecciona todos los Codigos de Error menos los indicados (300,100,200,400)
Select idLPInternalError, Code from LP_Configuration.LPInternalError where Code not in (300
,100
,200
,400)

DECLARE @idLPInternalError INT 
DECLARE @Code INT -- Code de Error para Descripcion

OPEN status_cursor

FETCH NEXT FROM status_cursor into @idLPInternalError, @Code

WHILE @@FETCH_STATUS = 0
BEGIN
---------------------------------------------------------------------------------------------------------------------
-- BEGIN PROCESS INSERT NEW STATUS 700 BASED
---------------------------------------------------------------------------------------------------------------------
	INSERT INTO [LP_Configuration].[InternalStatus]
           ([Code]
           ,[Name]
           ,[Description]
           ,[idProvider]
           ,[idCountry]
           ,[Active]
           ,[OP_InsDateTime]
           ,[OP_UpdDateTime]
           ,[DB_InsDateTime]
           ,[DB_UpdDateTime]
           ,[idInternalStatusType]
           ,[isError]
           ,[FinalStatus])
     VALUES
           ('REJECTED' 
           ,'Rechazado ' + CAST(@Code AS varchar)
           ,'Rechazado ' + CAST(@Code AS varchar)
           ,@idProvider
           ,@idCountry
           ,1
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,@idInternalStatusType
           ,1
           ,1)

		set @LastIdGenerated = SCOPE_IDENTITY()
---------------------------------------------------------------------------------------------------------------------
-- END PROCESS INSERT NEW STATUS 700 BASED
---------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------
-- BEGIN PROCESS INSERT RELATED ERROR FOR THE STATUS 
---------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT * FROM [LP_Configuration].[LPInternalStatusClient] WHERE [idInternalStatus] = @LastIdGenerated AND [idLPInternalError] = @idLPInternalError)
		BEGIN

			INSERT INTO [LP_Configuration].[LPInternalStatusClient]
					   ([idInternalStatus]
					   ,[idLPInternalError])
				 VALUES
					   (@LastIdGenerated,
					   @idLPInternalError)
---------------------------------------------------------------------------------------------------------------------
-- END PROCESS INSERT RELATED ERROR FOR THE STATUS 
---------------------------------------------------------------------------------------------------------------------
END 

FETCH NEXT FROM status_cursor into @idLPInternalError, @Code
END 

CLOSE status_cursor

DEALLOCATE status_cursor
END 



