IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[Ticket]') 
         AND name = 'ReferenceCode'
)
BEGIN
	ALTER TABLE [LP_Operation].[Ticket]
		ADD [ReferenceCode]					varchar(8) NULL
END