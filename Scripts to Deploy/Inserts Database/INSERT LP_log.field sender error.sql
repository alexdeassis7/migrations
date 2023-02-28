BEGIN TRAN
DECLARE
				@idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


INSERT INTO [LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('ERROR_AMOUNT_EXCEEDS_SENDER_MAX_LIMIT',2,49)
SET @idField = SCOPE_IDENTITY()
SET @idErrorType = (SELECT idErrorType FROM [LP_Log].[ErrorType] WHERE errorType = 'REJECTED')
INSERT INTO [LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Sender exceeds transaction limit')	
ROLLBACK