DECLARE
				@idField				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idErrorType			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]


INSERT INTO [LocalPaymentProd].[LP_Log].[Field] (Name,idTransactionType,idCountry) VALUES ('SenderBlackListed',2,49)
SET @idField = SCOPE_IDENTITY()
INSERT INTO [LocalPaymentProd].[LP_Log].[ErrorType] (errorType,Description,idTransactionType) VALUES('REJECTED','Transaction was rejected',2)
SET @idErrorType = SCOPE_IDENTITY()
INSERT INTO [LocalPaymentProd].[LP_Log].[FieldErrorType] (idField,idErrorType,Description) VALUES (@idField,@idErrorType,'Sender is in the blacklist')	