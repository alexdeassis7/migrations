--USE [master]
--GO
  
--ALTER DATABASE [LocalPaymentProd] SET ONLINE
--GO

begin tran

IF OBJECT_ID('tempdb..#entUsers') IS NOT NULL
    DROP TABLE #entUsers

IF OBJECT_ID('tempdb..#pwds') IS NOT NULL
    DROP TABLE #pwds

declare
@idEntityAccount			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
@identification nvarchar(200) = '000003000001'

select @idEntityAccount = idEntityAccount from LP_Security.EntityAccount where Identification = @identification

delete from LP_Operation.[TransactionCertificates] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)

delete from LP_Operation.TransactionPayinDetail where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Retentions_ARG.[TransactionCertificateProcess] where idTransactionCertificate in
(
	select idTransactionCertificate from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser inner join
	LP_Retentions_ARG.[TransactionCertificate] tr on tr.idTransaction = t.idTransaction
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Retentions_ARG.[TransactionCertificate] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.TransactionInternalStatus where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.TransactionEntitySubMerchant where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)

delete from LP_Operation.[TransactionLot] where idTransactionLot in
(
	select tl.idTransactionLot from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser inner join
	LP_Operation.[TransactionLot] tl on t.idTransactionLot = tl.idTransactionLot
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_CustomerInformation.TransactionCustomerInfomation where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.[TransactionDescription] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.[TransactionFromTo] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.[TransactionRecipientDetail] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_Operation.[TransactionDetail] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)
delete from LP_DataValidation.ClientIdentificationOperation where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)

delete from LP_Operation.TransactionCollectedAndPaidStatus where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)

delete from LP_Operation.[TransactionProvider] where idTransaction in
(
	select idTransaction from
	lp_security.entityaccountuser ac inner join 
	LP_Operation.[Transaction] t on t.idEntityUser = ac.idEntityUser
	where ac.idEntityAccount = @idEntityAccount
)

delete from LP_Retentions.WhiteListRetentionType where idEntitySubMerchant in
(
	select idEntitySubMerchant 
		from lp_security.entityaccountuser ea inner join
		LP_Entity.EntitySubMerchant es on ea.idEntityUser = es.idEntityUser
	where ea.identityaccount = @idEntityAccount
)

delete from LP_Retentions_ARG.Reg830_Merchant where idEntitySubMerchant in
(
	select idEntitySubMerchant 
		from lp_security.entityaccountuser ea inner join
		LP_Entity.EntitySubMerchant es on ea.idEntityUser = es.idEntityUser
	where ea.identityaccount = @idEntityAccount
)

delete from lp_log.RejectedTxs where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from lp_log.Rejectedpayins where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from LP_Operation.Wallet where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from LP_Operation.[Transaction] where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)
delete from LP_Configuration.CurrencyBase where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)
delete from LP_Entity.EntityUserTransactionType where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)


delete from LP_Entity.EntitySubMerchant where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)
delete from LP_Entity.EntityCurrencyExchange where idEntityUser in
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from LP_Entity.EntityMerchant where idEntityMerchant in
(
	select eu.idEntityMerchant from lp_security.entityaccountuser ea
	inner join LP_Entity.EntityUser eu on ea.idEntityUser = eu.idEntityUser
	where identityaccount = @idEntityAccount
)

delete from LP_Log.[Login] where identityuser in 
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from LP_Security.EntityApiCredential where identityuser in 
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

select idEntityPassword into #pwds from lp_security.EntityAccountPassword where identityaccount = @idEntityAccount

delete from LP_Configuration.VariableValue where idEntityUser in 
(
	select identityuser from lp_security.entityaccountuser where identityaccount = @idEntityAccount
)

delete from LP_Operation.TransactionFromTo where ToIdEntityAccount = @idEntityAccount

delete from LP_Operation.TransactionFromTo where FromIdEntityAccount = @idEntityAccount

delete from LP_Security.EntityAccountPassword where idEntityAccount = @idEntityAccount 

select identityuser into #entUsers from lp_security.entityaccountuser where identityaccount = @idEntityAccount

delete from LP_Security.EntityPassword where idEntityPassword in 
(
	select * from  #pwds
)

delete from LP_Security.EntityAccountUser where idEntityAccount = @idEntityAccount 

delete from LP_Security.EntityAccount where idEntityAccount = @idEntityAccount 
go

delete from lp_Entity.EntityUser where identityuser in 
(
	select * from #entUsers
)


rollback tran