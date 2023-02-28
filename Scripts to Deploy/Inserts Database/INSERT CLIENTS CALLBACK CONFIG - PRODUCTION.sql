
BEGIN TRAN
-- INSERTING CLIENTS CALLBACK DATA

/* PAYONEER */
DECLARE @idCallbackNotification AS INT
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (12, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'ARG')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (16, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'COL')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (210, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'BRA')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (283, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'CHL')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (211, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'MEX')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (209, 'https://callbackapi.payoneer.com/api/Callbacks/v1/Notify/?apiKey=3bYns35FbFKmgTtyOsWI&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'URY')


/* NIUM */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (220, 'https://integrations.partners.instarem.com/prod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (221, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (223, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (222, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (318, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (319, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', 'jCJzAHO0Qu38WJcO5fdGZ7xxq74NcEAS5eAMJapu')

/* ARF */
--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (326, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (327, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (329, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (328, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (330, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (331, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* REMITEE */
--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (425, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (427, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (426, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (428, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (429, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* INSWITCH */
--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (474, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (475, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (477, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (476, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (478, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

--INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
--VALUES (479, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
----SET @idCallbackNotification = @@IDENTITY
----INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
----VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* EFX */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (367, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (368, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (369, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (370, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (371, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (372, 'https://partners.exchange4free.com/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')





/* THUNES */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (203, 'https://callback-mt.thunes.com/localpayment/argentina', 1);
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (331, 'https://callback-mt.thunes.com/localpayment/chile', 1);
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (360, 'https://callback-mt.thunes.com/localpayment/chile', 1);
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (204, 'https://callback-mt.thunes.com/localpayment/colombia', 1);
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (212, 'https://callback-mt.thunes.com/localpayment/mexico', 1);
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl, Signature)
VALUES (447, 'https://callback-mt.thunes.com/localpayment/uruguay', 1);
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

ROLLBACK