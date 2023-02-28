--BEGIN TRAN
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns 
--  WHERE  object_id = OBJECT_ID(N'[LP_Entity].[EntityUser]') 
--         AND name = 'CommissionValue'
--)
--BEGIN
--	ALTER TABLE [LP_Entity].[EntityUser]
--		ADD [CommissionValue]					[LP_Common].[LP_F_DECIMAL] NULL
--		,	[CommissionCurrency]				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT] NULL;

--	UPDATE EU 
--	SET EU.[CommissionValue] = ES.CommissionValuePO
--	, EU.[CommissionCurrency] = ES.CommissionCurrencyPO
--	FROM [LP_Entity].[EntityUser] EU
--	INNER JOIN [LP_Entity].[EntitySubMerchant] ES ON ES.idEntityUser = EU.idEntityUser
--END
--ROLLBACK

BEGIN TRAN
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[LP_Entity].[EntityUser]') 
         AND name = 'CommissionDeductsFromOtherAccount'
)
BEGIN
	ALTER TABLE [LP_Entity].[EntityUser]
		ADD [CommissionDeductsFromOtherAccount]	[LP_Common].[LP_F_BOOL] NOT NULL DEFAULT 0;

	UPDATE EU 
	SET EU.[CommissionDeductsFromOtherAccount] = 1
	FROM [LP_Entity].[EntityUser] EU
	Where EU.MerchantAlias IN ('LPAYARBA', 'LOCPACOL', 'LPPAYURY', 'LPAYBRA', 'LPPAYMXN', 'LPPAYCHL',  -- Payoneer ALL COUNTRIES
								'LPTHUMEX') -- THUNES MEXICO
	AND LastName NOT LIKE '%payin%'
	
END

ROLLBACK TRAN