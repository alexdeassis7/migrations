begin tran
/******************************************************************************
 BANCOLOMBIA
******************************************************************************/
DECLARE @idProvider INT,
		@idCountry INT,
		@idInternalStatusType INT,
		@idLPInternalError as INT

SELECT @idCountry = idCountry FROM LP_Location.Country Where Code= 'COP'
SELECT @idProvider = idProvider FROM LP_Configuration.Provider WHERE Code = 'BCOLOMBIA' and idCountry = @idCountry

-- SELECT Code, Name, idInternalStatusType, * FROM LP_Configuration.InternalStatus [IS] where idProvider = 9 ORDER BY [IS].Code

SELECT @idInternalStatusType = idInternalStatusType FROM LP_Configuration.InternalStatusType
Where idCountry = @idCountry and Code = 'SCM'

-- 700
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '700'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D06', 'D07', 'D34', 'RC2', 'RC5', 'R03', 'R08', 'R13', 'R15', 'P09', 'D49', 'D53')


-- 701
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D08', 'D10', 'D31', 'M05', 'M06', 'RC1', 'RC6', 'R07', 'R09', 'R11', 'R12', 'R14', 'R16')

-- 702
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D24')


-- 705
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D25', 'D39', 'D41', 'M09', 'R04', 'R21', 'R23', 'C25')

-- 706
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D21')

-- 707
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('A02', 'C24', 'P30', 'P36', 'C11', 'D32', 'D33', 'D42', 'M07', 'A04', 'C03', 'C04', 'C27', 'C16', 'C26')

-- 710
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D11', 'D18')


-- 712
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '712'


INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider AND idInternalStatusType = @idInternalStatusType
AND [Code] IN ('D87')

commit tran