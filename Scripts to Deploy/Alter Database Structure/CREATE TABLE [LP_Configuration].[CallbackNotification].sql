
CREATE TABLE [LP_Configuration].[CallbackNotification] (
	[idCallbackNotification] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) PRIMARY KEY,
	[idEntityUser] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[NotificationUrl] VARCHAR(255) NOT NULL,

)

CREATE TABLE [LP_Configuration].[CallbackNotificationParameter] (
	[idCallbackNotificationParameter] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] IDENTITY(1,1) PRIMARY KEY,
	[idCallbackNotification] [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NOT NULL,
	[ParameterName] VARCHAR(255) NOT NULL,
	[ParameterValue] VARCHAR(255) NOT NULL
)
