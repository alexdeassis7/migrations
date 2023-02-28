DECLARE @newIdTransactionType AS INT

INSERT INTO LP_Configuration.TransactionType([Code], [Name], [Description], [idCountry], [Active], [idTransactionGroup])
VALUES ('ReceivedCo', 'Received Commission', 'Received Commission', 1, 1, 10);

SET @newIdTransactionType = @@IDENTITY

INSERT INTO LP_Configuration.[TransactionTypeProvider](idTransactionType, idProvider, Active)
VALUES (@newIdTransactionType, 8, 1)

DECLARE @newIdPayWayService AS INT

INSERT INTO LP_Configuration.[PayWayServices]([Code], [Name], [Description], [idCountry], [Active])
VALUES('ReceivedCo', 'Received Commission', 'Received Commission', 1, 1)

SET @newIdPayWayService = @@IDENTITY

INSERT INTO LP_Configuration.[ProviderPayWayServices](idProvider, idPayWayService, Active)
VALUES (8, @newIdPayWayService, 1)
