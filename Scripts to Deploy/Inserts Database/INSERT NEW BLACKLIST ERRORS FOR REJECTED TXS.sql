DECLARE
				@idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


SET @idErrorType = (SELECT idErrorType FROM [LP_Log].[ErrorType] WHERE errorType = 'REJECTED')

INSERT INTO [LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('ERROR_REJECTED_SENDER_BLACKLISTED',2,49)
SET @idField = SCOPE_IDENTITY()
INSERT INTO [LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Sender is in the blacklist')	
INSERT INTO [LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('ERROR_REJECTED_BENEFICIARY_BLACKLISTED',2,49)
SET @idField = SCOPE_IDENTITY()
INSERT INTO [LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Beneficiary is in the blacklist')	
INSERT INTO [LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('ERROR_AMOUNT_EXCEEDS_BENEFICIARY_MAX_LIMIT',2,49)
SET @idField = SCOPE_IDENTITY()
INSERT INTO [LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Beneficiary exceeds monthly amount')	