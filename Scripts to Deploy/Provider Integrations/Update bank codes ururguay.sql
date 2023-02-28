  BEGIN TRAN
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'BROUUYMMXXX' WHERE Code = 1001 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'BHUMMBUYXXX' WHERE Code = 1091 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'CFACUYMMXXX' WHERE Code = 1110 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'ITAUUYMMXXX' WHERE Code = 1113 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'COMEUYMMXXX' WHERE Code = 1128 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'BSCHUYMMXXX' WHERE Code = 1137 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'BBVAUYMMXXX' WHERE Code = 1153 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'BLICUYMMXXX' WHERE Code = 1157 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'SURIUYMMXXX' WHERE Code = 1162 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'CITIUYMMXXX' WHERE Code = 1205 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'NACNUYMMXXX' WHERE Code = 1246 AND idCountry = 244
  UPDATE [LP_Configuration].[BankCode] SET SubCode = 'PRBAUYMMXXX' WHERE Code = 1361 AND idCountry = 244


DECLARE @idProvider AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
SET @idProvider = (SELECT idProvider FROM LP_Configuration.Provider WHERE Code = 'BROU' AND idCountry = 244)
DECLARE @idInternalStatusType AS [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE Code = 'SCM' AND idCountry = 244)

INSERT INTO [LP_Configuration].[InternalStatus]([idProvider], [idCountry], [Active], [Code], [Name], [Description], [idInternalStatusType], [isError], [FinalStatus])
VALUES
(@idProvider, 244, 1, '701', 'ERROR BANK ACCOUNT CLOSED', 'ERROR BANK ACCOUNT CLOSED', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '702', 'ERROR AMOUNT INCORRECT', 'ERROR AMOUNT INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '703', 'ERROR BANK INVALID', 'ERROR BANK INVALID', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '705', 'ERROR BENEFICIARY DOCUMENT ID INVALID', 'ERROR BENEFICIARY DOCUMENT ID INVALID', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '706', 'ERROR BENEFICIARY NAME INCORRECT', 'ERROR BENEFICIARY NAME INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '707', 'ERROR BANK PROCESSING', 'ERROR BANK PROCESSING', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '708', 'ERROR INVALID DATE', 'ERROR INVALID DATE', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '709', 'ERROR ACCOUNT TYPE INCORRECT', 'ERROR ACCOUNT TYPE INCORRECT', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '710', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', 'ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT', @idInternalStatusType, 1, 1),
(@idProvider, 244, 1, '715', 'ERROR ACCOUNT OF OTHER CURRENCY', 'ERROR ACCOUNT OF OTHER CURRENCY', @idInternalStatusType, 1, 1)

DECLARE @idLPInternalError INT
--ERROR BANK ACCOUNT CLOSED
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '701'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('701')

--ERROR AMOUNT INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '702'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('702')

--ERROR BANK INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '703'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('703')

--ERROR BENEFICIARY DOCUMENT ID INVALID
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '705'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('705')

--ERROR BENEFICIARY NAME INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '706'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('706')

--ERROR BANK PROCESSING
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '707'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('707')

--ERROR INVALID DATE
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '708'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('708')

--ERROR ACCOUNT TYPE INCORRECT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '709'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('709')

--ERROR ACCOUNT NOT MATCH BENEFICIARY DOCUMENT
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '710'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('710')

--ERROR ACCOUNT OF OTHER CURRENCY
SELECT @idLPInternalError = idLPInternalError
FROM [LP_Configuration].[LPInternalError]
WHERE Code = '715'

INSERT INTO [LP_Configuration].[LPInternalStatusClient](idInternalStatus, idLPInternalError)
SELECT idInternalStatus, @idLPInternalError
FROM LP_Configuration.InternalStatus
WHERE idProvider = @idProvider
AND [Code] IN ('715')
ROLLBACK