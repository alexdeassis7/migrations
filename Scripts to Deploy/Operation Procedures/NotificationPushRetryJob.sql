alter table LP_Operation.[Transaction]
 ADD NotificationPushDate datetime null

 alter table LP_Operation.[Transaction]
 ADD NotificationPushRetriesCount int not null default 0 with values
 
 update LP_Operation.[Transaction] set NotificationPushDate = OP_UpdDateTime


create procedure [LP_Operation].[Set_Notification_Push_Sent]
	@JSON	NVARCHAR(MAX)
as
UPDATE T
	SET NotificationPushDate = GETUTCDATE()
FROM 
	[LP_Operation].[Transaction] [T]
INNER JOIN 
	 OPENJSON(@JSON) as TransactionsToUpdate ON TransactionsToUpdate.value = [T].idTransaction
