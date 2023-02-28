--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns 
--  WHERE  object_id = OBJECT_ID(N'[LP_Security].[EntityAccount]') 
--         AND name = 'publicKey'
--)
--BEGIN
--	  ALTER TABLE [LP_Security].[EntityAccount]
--		ADD [publicKey]					VARCHAR(MAX) NULL ,
--		 [privateKey]				VARCHAR(MAX) NULL
--END

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Security].[EntityAccount]') 
         AND name = 'HMACKey'
)
BEGIN
	  ALTER TABLE [LP_Security].[EntityAccount]
		ADD [HMACKey]					VARCHAR(MAX) NULL
END

