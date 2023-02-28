CREATE OR ALTER PROCEDURE [LP_Filter].[GetClientReportData]
                        (
                          @Customer [LP_Common].[LP_F_C50]
                        )
AS
BEGIN

  DECLARE
    @RESP           XML
    , @Start          [LP_Common].[LP_A_OP_INSDATETIME]
    , @PreviousStart      [LP_Common].[LP_A_OP_INSDATETIME]
    , @PreviousEnd        [LP_Common].[LP_A_OP_INSDATETIME]
    , @OP           [LP_Common].[LP_F_VMAX]
    , @idEntityUser       [LP_Common].[LP_F_INT]
    , @idEntityType       [LP_Common].[LP_F_INT]
    , @idAdminType        [LP_Common].[LP_F_INT]
    , @Merchant         [LP_Common].[LP_F_VMAX]
    , @Gross          [LP_Common].[LP_F_DECIMAL]
    , @TXS            [LP_Common].[LP_F_INT]
    , @PreviousGross      [LP_Common].[LP_F_DECIMAL]
    , @PreviousTxs        [LP_Common].[LP_F_INT]
    , @GrossVar         [LP_Common].[LP_F_DECIMAL]
    , @txsVar         [LP_Common].[LP_F_DECIMAL]
    , @idStatus         [LP_Common].[LP_F_INT]
    , @CurrencyTypeClient   [LP_Common].[LP_F_INT]
    , @CurrencyTypeLP     [LP_Common].[LP_F_INT]
	, @idTransactionTypePO	[LP_Common].[LP_F_INT]
	, @idTransactionTypePI	[LP_Common].[LP_F_INT]


  DECLARE @Report TABLE 
  (
    [Merchant]          [LP_Common].[LP_F_VMAX]
    , [Gross]         [LP_Common].[LP_F_DECIMAL]        NULL
    , [txsQuantity]       [LP_Common].[LP_F_INT]
    , [GrossVariation]      [LP_Common].[LP_F_DECIMAL]        NULL
    , [txsQuantityVariation]  [LP_Common].[LP_F_DECIMAL]        NULL
  )

  -- Tabla para mostrar balance de cuenta con comisiones incluidas
  -- actualmente aplica para Thunes ARG y Thunes COL
  DECLARE @AccountsWithoutCommission TABLE
  (
  [idEntityUser] [LP_Common].[LP_F_INT]
  )

  INSERT INTO @AccountsWithoutCommission (idEntityUser)
  SELECT idEntityUser
  FROM [LP_Entity].[EntityUser]
  WHERE LastName LIKE '%payoneer%' OR LastName = 'Thunes Mexico' OR LastName = 'Thunes Chile CLP'

  SET @idTransactionTypePI = (SELECT idTransactionType FROM LP_Configuration.TransactionType WHERE Code = 'PAYIN')
  SET @idTransactionTypePO = (SELECT idTransactionType FROM LP_Configuration.TransactionType WHERE Code = 'PODEPO')


  SELECT
    @idEntityUser = [EU].[idEntityUser]
    , @idEntityType = [EU].[idEntityType]
  FROM
    [LP_Entity].[EntityUser]              [EU]
      INNER JOIN [LP_Security].[EntityAccount]    [EA]  ON [EA].[idEntityUser]  = [EU].[idEntityUser]
  WHERE
    [EU].[Active] = 1
    AND [EA].[Active] = 1
    AND [EA].[UserSiteIdentification] = @customer

  SET @idAdminType = ( SELECT [idEntityType] FROM [LP_Entity].[EntityType] WHERE [Code] = 'Admin' AND [Active] = 1 )

  BEGIN TRY

    IF (@idEntityUser IS NOT NULL)
    BEGIN

      IF (@idEntityType <> @idAdminType)
      BEGIN

        SET @Merchant = ( SELECT [FirstName] FROM [LP_Entity].[EntityUser] WHERE [idEntityUser] = @idEntityUser )

        --select @CurrencyTypeClient = ece.IdCurrencyTypeClient,
        --    @CurrencyTypeLP = ece.idCurrencyTypeLP
        --from [LP_Entity].EntityCurrencyExchange ece
        --where idEntityUser = @idEntityUser


        SET @RESP = CAST((
        SELECT 
          [EA].[UserSiteIdentification]
      , [EU].[LastName]
	  , [C].[Name] AS [CountryName]
	  , [C].[ISO3166_1_ALFA003] AS [CountryCode]
          , [EU].[idEntityUser]
      , cc.[Code] AS [CurrencyCode]
          , ISNULL((
        SELECT CASE WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0
          THEN
          CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
          THEN
            ROUND([BalanceClientWithOutCommission], 2) 
          ELSE
            ROUND([BalanceLPWithOutCommission], 2)
          END
          ELSE
          CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
          THEN
            ROUND([BalanceClient], 2) 
          ELSE
            ROUND([BalanceLP], 2)
          END
          END
              FROM (
              SELECT TOP 1 [idWallet], [BalanceClientWithOutCommission], [BalanceClient], [BalanceLPWithOutCommission], [BalanceLP] 
              FROM [LP_Operation].[Wallet] 
              WHERE 
                [idEntityUser] = [EU].[idEntityUser] 
              ORDER BY 1 DESC
             ) a
           ), 0) SaldoActual
           , ISNULL((
            SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy]/100))), 2), 0)
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) AmtInProgressPO
		, ISNULL((
			SELECT CASE WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0 
					THEN ROUND(SUM(ISNULL([TD].[LocalTax], 0)), 2)
					ELSE 
					ROUND(SUM(ISNULL([TD].[Commission_With_VAT], 0) + ISNULL([TD].[LocalTax], 0)), 2)
					END
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser]  and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] IN (3,1)
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) CommTaxesInProgressPO
			, ISNULL((
			SELECT case 
				WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0 
				THEN 
					IIF(
						ece.IdCurrencyTypeClient = ece.idCurrencyTypeLP, 
						ROUND(SUM(ISNULL([TD].[LocalTax], 0) * ([CE].[value]*(1+[CB].[Base_Sell]/100))), 2),
						ROUND(SUM(ISNULL([TD].[LocalTax], 0)), 2)
						)
					
				when ece.IdCurrencyTypeClient = ece.idCurrencyTypeLP
				then ROUND(SUM((ISNULL([TD].[Commission_With_VAT],0) + ISNULL([TD].[LocalTax], 0)) * ([CE].[value]*(1+[CB].[Base_Sell]/100))), 2)
				else ROUND(SUM(ISNULL([TD].[Commission_With_VAT],0) + ISNULL([TD].[LocalTax], 2)), 2)
					
                end
            FROM  [LP_Operation].[Transaction] [T]    
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            -- LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [CE].[  -- [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]

            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser]  and ece.Active = 1
			LEFT JOIN [LP_Configuration].[CurrencyExchange] CE ON CE.CurrencyBase = 2493 AND CE.CurrencyTo = ECE.idCurrencyTypeLP AND CE.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) CommTaxesInProgressPI
        , ISNULL((
            SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1+[CB].[Base_Sell]/100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) AmtInProgressPI
        , ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] on [T].[idTransaction] = [TD].[idTransaction]
		  INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
		  INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 3
          ),0) cntInProgressPO
        ,ISNULL((
          SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy] /100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idcurrencyExchange] = [CE].[idCurrencyExchange] 
          LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
          LEFT JOIN [LP_Common].[Status] [ST] ON [ST].idStatus = [T].idStatus 
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [ST].[Code] = 'OnHold'
           ),0) AmtOnHoldPO
        ,ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] on [T].[idTransaction] = [TD].[idTransaction]
		      INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
		      INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO 
          LEFT JOIN [LP_Common].[Status] [ST] ON [ST].idStatus = [T].idStatus 
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [ST].[Code] = 'OnHold'
          ),0) cntOnHoldPO
        ,ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] on [T].[idTransaction] = [TD].[idTransaction]
		  INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
		  INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 3
          ),0) cntInProgressPI
        , ISNULL((
          SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy] /100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idcurrencyExchange] = [CE].[idCurrencyExchange] 
          LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 1
           ),0) AmtReceived
        , ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser]
            AND [T].[idStatus] = 1),0) cntReceived
        FROM 
			[LP_Security].EntityAccount [EA]
			inner join [LP_Security].[EntityAccountUser] [EAU] on [EAU].[idEntityAccount] = [EA].[idEntityAccount]
			inner join [LP_Entity].EntityUser [EU] on  [EAU].[idEntityUser] = [EU].[idEntityUser]
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
        WHERE 
           [EA].[UserSiteIdentification] = @Customer
        ORDER BY
          [EU].[LastName] FOR JSON PATH) AS XML)

      END
    ELSE
      BEGIN
        SET @RESP = CAST((
        SELECT 
      [EU].[LastName]
	  , [C].[Name] AS [CountryName]
	  , [C].[ISO3166_1_ALFA003] AS [CountryCode]
      , cc.[Code] AS [CurrencyCode]
          , [EU].[idEntityUser]
          , (
        SELECT CASE WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0
          THEN
          CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
          THEN
            ROUND([BalanceClientWithOutCommission], 2) 
          ELSE
            ROUND([BalanceLPWithOutCommission], 2)
          END
          ELSE
          CASE WHEN ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
          THEN
            ROUND([BalanceClient], 2) 
          ELSE
            ROUND([BalanceLP], 2)
          END
          END
              FROM (
              SELECT TOP 1 [idWallet], [BalanceClientWithOutCommission], [BalanceClient], [BalanceLPWithOutCommission], [BalanceLP] 
              FROM [LP_Operation].[Wallet] 
              WHERE 
                [idEntityUser] = [EU].[idEntityUser] 
              ORDER BY 1 DESC
             ) a
           ) SaldoActual
           , ISNULL((
            SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy]/100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) AmtInProgressPO

			, ISNULL((
			SELECT CASE 
					WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0 
					THEN ROUND(SUM(ISNULL([TD].[LocalTax], 0)), 2)
					ELSE ROUND(SUM(ISNULL([TD].[Commission_With_VAT], 0) + ISNULL([TD].[LocalTax], 0)), 2) END
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] IN (3,1)
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) CommTaxesInProgressPO
			, ISNULL((
			SELECT case WHEN (SELECT COUNT(1) FROM @AccountsWithoutCommission WHERE idEntityUser = [EU].[idEntityUser]) > 0 
				THEN 
					IIF(
						ece.IdCurrencyTypeClient = ece.idCurrencyTypeLP, 
						ROUND(SUM(ISNULL([TD].[LocalTax], 0) * ([CE].[value]*(1+[CB].[Base_Sell]/100))), 2),
						ROUND(SUM(ISNULL([TD].[LocalTax], 0)), 2)
						)
				when ece.IdCurrencyTypeClient = ece.idCurrencyTypeLP
                then ROUND(SUM((ISNULL([TD].[Commission_With_VAT],0) + ISNULL([TD].[LocalTax], 0)) * ([CE].[value]*(1+[CB].[Base_Sell]/100))), 2)
                else ROUND(SUM(ISNULL([TD].[Commission_With_VAT],0) + ISNULL([TD].[LocalTax], 2)), 2)
                end
            FROM  [LP_Operation].[Transaction] [T]    
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            -- LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [CE].[  -- [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]

            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			LEFT JOIN [LP_Configuration].[CurrencyExchange] CE ON CE.CurrencyBase = 2493 AND CE.CurrencyTo = ECE.idCurrencyTypeLP AND CE.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ),0) CommTaxesInProgressPI
        , ISNULL((
            SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1+[CB].[Base_Sell]/100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) AmtInProgressPI
        , ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] on [T].[idTransaction] = [TD].[idTransaction]
		  INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
		  INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePO
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 3
          ), 0) cntInProgressPO
        ,ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] on [T].[idTransaction] = [TD].[idTransaction]
		  INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
		  INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = @idTransactionTypePI
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 3
          ),0) cntInProgressPI
        , ISNULL((
          SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy]/100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idcurrencyExchange] = [CE].[idCurrencyExchange]
          LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [T].[idStatus] = 1
           ),0) AmtReceived
        , ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser]
            AND [T].[idStatus] = 1), 0) cntReceived
        , ISNULL((
          SELECT case when ece.IdCurrencyTypeClient <> ece.idCurrencyTypeLP
                then ISNULL(ROUND(SUM([GrossAmount]/([CE].[value]*(1-[CB].[Base_Buy]/100))), 2), 0) 
                else ISNULL(ROUND(SUM([GrossAmount]), 2), 0)
                end 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idcurrencyExchange] = [CE].[idCurrencyExchange]
          LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
          LEFT JOIN [LP_Common].[Status] [ST] ON [ST].idStatus = [T].idStatus 
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser] 
            AND [ST].[Code] = 'OnHold'
           ),0) AmtOnHoldPO
        , ISNULL((
          SELECT COUNT(1) 
          FROM  [LP_Operation].[Transaction] [T]
          LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
          LEFT JOIN [LP_Common].[Status] [ST] ON [ST].idStatus = [T].idStatus 
          WHERE 
            [T].[idEntityUser] = [EU].[idEntityUser]
            AND [ST].[Code] = 'OnHold'), 0) cntOnHoldPO
        FROM 
			[LP_Security].EntityAccount [EA]
			inner join [LP_Security].[EntityAccountUser] [EAU] on [EAU].[idEntityAccount] = [EA].[idEntityAccount]
			inner join [LP_Entity].EntityUser [EU] on  [EAU].[idEntityUser] = [EU].[idEntityUser]
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser]  and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Location].[Country] [C] ON [C].[idCountry] = [EU].[idCountry]
		WHERE 
          [EAU].[idEntityAccount] = [EA].[idEntityAccount]
          AND [EAU].[idEntityUser] = [EU].[idEntityUser]
		  AND [EU].[idEntityType] <> @idAdminType
      GROUP BY [EU].[LastName], cc.[Code],[EU].[idEntityUser],cc.[idCurrencyType],[ECE].[IdCurrencyTypeClient],[ECE].[idCurrencyTypeLP], [C].[Name], [C].[ISO3166_1_ALFA003]
        ORDER BY [C].[ISO3166_1_ALFA003], [EU].[LastName] FOR JSON PATH) AS XML)
      END
    END
    ELSE 
    BEGIN
      SET @RESP = 'USER ERROR'
    END

  END TRY 
  BEGIN CATCH

     SELECT @RESP = ERROR_MESSAGE() 

  END CATCH

  SELECT @RESP


END
