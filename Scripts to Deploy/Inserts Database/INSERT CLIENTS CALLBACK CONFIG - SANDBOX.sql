
BEGIN TRAN
-- INSERTING CLIENTS CALLBACK DATA

/* PAYONEER */
DECLARE @idCallbackNotification AS INT
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (12, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'ARG')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (16, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'COL')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (214, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'BRA')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (315, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'CHL')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (218, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'MEX')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (210, 'https://callbackapi.sandbox.payoneer.com/api/Callbacks/v1/Notify/?apiKey=yQGVpfhgUicsGTYM3eyQ&handlerName=LocalPayment&eventType=PaymentEvent&eventSubType=-1')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'CountryCode', 'URY')


/* NIUM */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (220, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (221, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (223, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (222, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (318, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (319, 'https://integrationspreprod.partners.instarem.com/preprod/localpayment/transactionStatus')
SET @idCallbackNotification = @@IDENTITY
INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

/* ARF */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (326, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (327, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (329, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (328, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (330, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (331, 'http://arf-institution-api-dev.arf.one/api/v1/institutions/localpayment/webhooks/transactions')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* REMITEE */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (425, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (427, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (426, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (428, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (429, 'http://remitee-integrations-localpayment-test.azurewebsites.net/api/webhook/complete')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* INSWITCH */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (474, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (475, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (477, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (476, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (478, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (479, 'https://connectgw-sbx.apps.ins.inswhub.com/partnergw/v1/localpayment/notification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



/* EFX */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (462, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (463, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (465, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (464, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (466, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (467, 'http://development.exchange4free.com:8100/v4/LocalPaymentNotification')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')





/* THUNES */
INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (205, 'https://callback-mt.pre.thunes.com/localpayment/argentina')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (431, 'https://callback-mt.pre.thunes.com/localpayment/chile')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (201, 'https://callback-mt.pre.thunes.com/localpayment/colombia')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')

INSERT INTO LP_Configuration.CallbackNotification(idEntityUser, NotificationUrl)
VALUES (219, 'https://callback-mt.pre.thunes.com/localpayment/mexico')
--SET @idCallbackNotification = @@IDENTITY
--INSERT INTO LP_Configuration.CallbackNotificationParameter(idCallbackNotification, ParameterName, ParameterValue)
--VALUES(@idCallbackNotification, 'x-api-key', '4TdnNW2xPT8VpaRj3lops1AWx9u1pQPp5QkWr3Ur')



ROLLBACK