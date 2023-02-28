DECLARE
				@idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


INSERT INTO [LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('AML',2,49)
SET @idField = SCOPE_IDENTITY()
INSERT INTO [LP_Log].[ErrorType] (errorType,Description,idTransactionType) VALUES('REJECTED','Transaction was rejected',2)
SET @idErrorType = SCOPE_IDENTITY()
INSERT INTO [LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Rejected by AML')	