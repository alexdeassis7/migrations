BEGIN TRAN
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns 
--  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[Transaction]') 
--         AND name = 'idLotOut'
--)
--BEGIN
--	ALTER TABLE [LP_Operation].[Transaction]
--		ADD [idLotOut]					[LP_Common].[LP_F_INT] NULL
--		, [lotOutDate]					[LP_Common].[LP_A_OP_INSDATETIME] NULL
--END
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns 
--  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[Transaction]') 
--         AND name = 'ReferenceTransaction'
--)
--BEGIN
--	ALTER TABLE [LP_Operation].[Transaction]
--		ADD [ReferenceTransaction]					VARCHAR(120) NULL
--END
--COMMIT
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Operation].[Transaction]') 
         AND name = 'ExpirationDate'
)
BEGIN
	ALTER TABLE [LP_Operation].[Transaction]
		ADD [ExpirationDate]					DATETIME NULL
END
COMMIT