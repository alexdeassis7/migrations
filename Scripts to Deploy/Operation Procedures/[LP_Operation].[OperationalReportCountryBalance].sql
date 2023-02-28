CREATE OR ALTER PROCEDURE [LP_Operation].[OperationalReportCountryBalance] (@country_code [LP_Common].[LP_F_C3])
AS 
BEGIN

DECLARE @TempTable AS TABLE (
	idRow INT IDENTITY(1, 1), 
	LastName varchar(150), 
	Code VARCHAR(3), 
	Balance DECIMAL(18,2), 
	TxsInProgress DECIMAL(18,2), 
	LocalTaxes DECIMAL(18,2), 
	Commissions DECIMAL(18,2),
	FinalBalance DECIMAL(18,2),
	Wires	DECIMAL(18, 2),
	OpFee	DECIMAL(13, 2),
	TxInProgressCount INT,
	FxInicio DECIMAL(13,6),
	FxCierre DECIMAL(13,6),
	FxVar DECIMAL(13,6),
	Fecha DATE
)

INSERT INTO @TempTable(LastName, Code, Balance, TxsInProgress, LocalTaxes, Commissions, Wires, TxInProgressCount, OpFee, FxInicio, FxCierre)
SELECT 
	[EU].[LastName], 
	[CT].[Code],
	ISNULL((SELECT CASE WHEN [EU].CommissionDeductsFromOtherAccount > 0
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
           ), 0) Balance,
		ISNULL((
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
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = (
				SELECT idTransactionType
				FROM LP_Configuration.TransactionType
				WHERE Code = 'PODEPO'
			)
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) TxsInProgress,
			ISNULL((
			SELECT ROUND(SUM(ISNULL([TD].[LocalTax], 0)), 2)
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser]  and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = (
				SELECT idTransactionType
				FROM LP_Configuration.TransactionType
				WHERE Code = 'PODEPO'
			)
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) LocalTaxes,

			ISNULL((
			SELECT CASE WHEN [EU].[CommissionDeductsFromOtherAccount] = 0 
					THEN ROUND(SUM(ISNULL([TD].[Commission_With_VAT], 0)), 2)
					ELSE 0.00
					END
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser]  and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = (
				SELECT idTransactionType
				FROM LP_Configuration.TransactionType
				WHERE Code = 'PODEPO'
			)
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] IN (3,1)
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) Commissions,
			ISNULL((
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
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = (
				SELECT idTransactionType
				FROM LP_Configuration.TransactionType
				WHERE Code = 'AddBalance'
			)
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 4
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) Wires,
			ISNULL((
            SELECT COUNT(1)
            FROM  [LP_Operation].[Transaction] [T]        
            LEFT JOIN [LP_Operation].[TransactionDetail] [TD] ON [T].[idTransaction] = [TD].[idTransaction]
            LEFT JOIN [LP_Configuration].[CurrencyExchange] [CE] ON [T].[idCurrencyExchange] = [CE].[idCurrencyExchange]
            LEFT JOIN [LP_Configuration].[CurrencyBase] [CB] on [T].idCurrencyBase = [CB].idCurrencyBase
			inner join [LP_Entity].EntityCurrencyExchange ece on ece.identityuser = [EU].[idEntityUser] and ece.Active = 1
			inner join [LP_Configuration].[CurrencyType] cc on cc.idCurrencyType = ece.IdCurrencyTypeClient
			INNER JOIN [LP_Operation].[TransactionProvider] [TP] ON [TP].[idTransaction] = [T].[idTransaction]
			INNER JOIN [LP_Configuration].[TransactionTypeProvider] [TTP] ON [TTP].[idProvider] = [TP].[idProvider] AND [TTP].[idTransactionType] = (
				SELECT idTransactionType
				FROM LP_Configuration.TransactionType
				WHERE Code = 'PODEPO'
			)
            WHERE 
              [T].[idEntityUser] = [EU].[idEntityUser] 
              AND [T].[idStatus] = 3
			group by
			ece.IdCurrencyTypeClient, ece.idCurrencyTypeLP
            ), 0) TxsInProgressCount,
			[EU].[CommissionValue] AS OpFee,
			(
				SELECT Top 1 Value 
				FROM LP_Configuration.CurrencyExchange
				WHERE CurrencyTo = [ECE].idCurrencyTypeLP
				AND CAST(OP_InsDateTime AS DATE) = CAST('20210215' AS DATE)
				ORDER BY OP_InsDateTime ) AS FxInicio,
			(
				SELECT Top 1 Value 
				FROM LP_Configuration.CurrencyExchange
				WHERE CurrencyTo = [ECE].idCurrencyTypeLP
				AND CAST(OP_InsDateTime AS DATE) = CAST('20210215' AS DATE)
				ORDER BY OP_InsDateTime DESC ) AS FxCierre
FROM LP_Entity.EntityUser [EU] 
INNER JOIN LP_Entity.EntityCurrencyExchange [ECE] ON [ECE].[idEntityUser] = [EU].[idEntityUser]
INNER JOIN LP_Configuration.CurrencyType [CT] ON [CT].[idCurrencyType] = [ECE].idCurrencyTypeClient
INNER JOIN LP_Location.Country [C] ON [C].[idCountry] = [EU].idCountry
WHERE 
	[C].ISO3166_1_ALFA003 = @country_code 
AND [EU].[LastName] NOT LIKE '%payin%'
AND [EU].[idEntityType] = 2 -- USER TYPE MERCHANT
ORDER BY Code ASC


-- UPDATING FINAL BALANCE
UPDATE @TempTable 
SET FinalBalance = Balance - TxsInProgress - LocalTaxes - Commissions,
	FxVar = (FxCierre - FxInicio) / FxInicio * 100

-- GENERATING SUBTOTALS BY CURRENCIES
INSERT INTO @TempTable(LastName, Balance, Code, TxsInProgress, LocalTaxes, Commissions, FinalBalance)
SELECT 'TOTAL ' + Code, SUM(Balance), Code, SUM(TxsInProgress), SUM(LocalTaxes), SUM(Commissions), SUM(FinalBalance)
FROM @TempTable
GROUP BY GROUPING SETS(Code)
ORDER BY Code

-- GRAND TOTAL IS ONLY CALCULATED IF THERE ARE MORE THAT ONE CURRENCY TYPES
IF (SELECT COUNT(DISTINCT Code) FROM @TempTable) > 1 
BEGIN
	-- GET LAST FX VALUE
	DECLARE @FxValue DECIMAL(13,2)
	SELECT @FxValue = [Value]
	FROM [LP_Configuration].[CurrencyExchange]
	WHERE CurrencyBase = 2493 
	AND CurrencyTo = (
		SELECT idCurrencyType 
		FROM LP_Configuration.CurrencyType 
		WHERE Code = (SELECT DISTINCT Code FROM @TempTable WHERE Code != 'USD')
	)
	AND Active = 1

	DECLARE @BalanceUsd DECIMAL(13,2)
	DECLARE @BalanceLocalCurrency DECIMAL(13,2)
	DECLARE @FinalBalanceUsd DECIMAL(13,2)
	DECLARE @FinalBalanceLocalCurrency DECIMAL(13,2)

	SELECT @BalanceUsd = SUM(Balance), @FinalBalanceUsd = SUM(FinalBalance)
	FROM @TempTable
	WHERE LastName LIKE '%TOTAL%' AND Code = 'USD'

	SELECT @BalanceLocalCurrency = SUM(Balance), @FinalBalanceLocalCurrency = SUM(FinalBalance)
	FROM @TempTable
	WHERE LastName LIKE '%TOTAL%' AND Code <> 'USD'

	INSERT INTO @TempTable(LastName, Balance, Code, TxsInProgress, LocalTaxes, Commissions, FinalBalance)
	SELECT 'TOTAL GRAL', @BalanceUsd + (@BalanceLocalCurrency / @FxValue), 'USD', 0, 0, 0, @FinalBalanceUsd + (@FinalBalanceLocalCurrency / @FxValue)

END

-- UPDATING FECHA
UPDATE @TempTable SET Fecha = CAST(GETDATE() AS DATE)
WHERE idRow = (SELECT MIN(idRow) FROM @TempTable WHERE TxsInProgress <> 0 OR FinalBalance <> 0)

SELECT	
	Fecha,
	LastName AS Pasivos,
	Code AS Moneda,
	Balance AS [Saldo Inicial],
	TxsInProgress AS Pagos,
	LocalTaxes AS Localtax,
	Commissions,
	Wires,
	FinalBalance AS [Saldo Final],
	FxInicio AS [FX INICIO],
	FxCierre AS [FX CIERRE],
	FxVar AS [Variacion FX (%)],
	TxInProgressCount,
	OpFee
FROM @TempTable
WHERE TxsInProgress <> 0 OR FinalBalance <> 0
ORDER BY Code, idRow


END -- END SP