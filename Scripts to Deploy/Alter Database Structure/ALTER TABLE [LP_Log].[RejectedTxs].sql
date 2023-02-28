IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Log].[RejectedTxs]') 
         AND name = 'senderName'
)
BEGIN
	ALTER TABLE [LP_Log].[RejectedTxs]
		ADD [senderName]					[LP_Common].[LP_F_C150] NULL ,
		 [senderAddress]					[LP_Common].[LP_F_C150]	NULL ,
		 [senderCountry]					[LP_Common].[LP_F_C150]	NULL ,
		 [senderState]						[LP_Common].[LP_F_C150]	NULL ,
		 [senderTaxid]						[LP_Common].[LP_F_C150]	NULL ,
		 [senderBirthDate]					[LP_Common].[LP_F_C150]	NULL ,
		 [senderEmail]						[LP_Common].[LP_F_C150]	NULL
END