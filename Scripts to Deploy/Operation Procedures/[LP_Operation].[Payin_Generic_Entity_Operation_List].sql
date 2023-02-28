SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [LP_Operation].[Payin_Generic_Entity_Operation_List]
                                      (
                                        @customer       VARCHAR(12)
                                        ,@JSON          [LP_Common].[LP_F_VMAX]
										,@countryCode	[LP_Common].[LP_F_C3]
                                      )
AS
BEGIN

  DECLARE
    @qtyAccount       [LP_Common].[LP_F_INT]
    , @idEntityAccount    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
    , @Message        [LP_Common].[LP_F_DESCRIPTION]
    , @Status       [LP_Common].[LP_F_BOOL]
    , @transLot       [LP_Common].[LP_F_INT]
    , @JSON_Result      XML
    , @MerchantName     [LP_Common].[LP_F_DESCRIPTION]

    , @date_from      [LP_Common].[LP_A_DB_INSDATETIME]
    , @date_to        [LP_Common].[LP_A_DB_INSDATETIME]
    , @payin_id      BIGINT
    , @merchant_id  [LP_Common].[LP_F_DESCRIPTION]
    , @idEntityUser     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

    ,@idCountry       [LP_Common].[LP_F_INT]

  SELECT
    @date_from        = CAST(JSON_VALUE(@JSON, '$.date_from') AS VARCHAR(8))
    ,@date_to       = CAST(JSON_VALUE(@JSON, '$.date_to') AS VARCHAR(8))
    ,@payin_id       = CAST(JSON_VALUE(@JSON, '$.payin_id') AS BIGINT)
    ,@merchant_id = CAST(JSON_VALUE(@JSON, '$.merchant_id') AS VARCHAR(60))


  IF(@date_from IS NULL AND @date_to IS NOT NULL)
    SET @date_to = NULL

  IF(@date_from IS NOT NULL AND @date_to IS NULL)
    SET @date_from = NULL

  IF((@date_from IS NOT NULL AND @date_to IS NOT NULL) AND (@date_from = @date_to))
    SET @date_to = DATEADD(DAY, 1, @date_to)


  SET @idCountry = ( SELECT [idCountry] FROM  [LP_Location].[Country] WHERE [ISO3166_1_ALFA003] = @countryCode ) 

  SELECT  @qtyAccount = COUNT([idEntityAccount]), @idEntityAccount = MAX([idEntityAccount]) FROM [LP_Security].[EntityAccount] WHERE [Identification] = @customer AND [Active] = 1

  SET @idEntityUser = ( SELECT [idEntityUser] FROM [LP_Security].[EntityApiCredential] WHERE [Identification] = @customer AND [Active] = 1 AND [idCountry] = @idCountry)

  IF(@qtyAccount = 1)
  BEGIN 

  SET @MerchantName = (SELECT [LastName] FROM [LP_Entity].[EntityUser] WHERE [idEntityUser] = @idEntityUser )

    SET @JSON_Result = 
              (
                SELECT
                  CAST
                  (
                    (
                      SELECT
                        [payin_id]			= [T1].[idTransaction],
						[transaction_date]	= ISNULL(CONVERT(VARCHAR(8), [T1].[TransactionDate], 112), ''),
						[Status]			= [STAT].[Code],
						[status_detail]		= CASE 
												WHEN [STAT].[Code] = 'InProgress' THEN 'The payin is being processed.'
												WHEN [STAT].[Code] = 'Executed' THEN 'Successfully executed'
												ELSE 'The payin request has expired'
											  END,
						[Amount]			= REPLACE(CAST(CONVERT(DECIMAL(18,2), [TD].[GrossAmount]) AS VARCHAR(18)), '.', ''),
						[Currency]			= [CT].[Code],
						[payment_method_code] = [TPD].[PaymentMethodCode],
						[merchant_id]		= [TPD].[MerchantId],
						[payer_name]			= [TPD].[PayerName],
						[payer_document_number] = [TPD].[PayerDocumentNumber],
						[payer_account_number] = [TPD].[PayerAccountNumber],
						[submerchant_code]	= [ESM].[SubMerchantIdentification],
						[reference_code]	= [TK].[ReferenceCode],
						[payer_email]		= [TPD].[PayerEmail],
						[payer_phone_number] = [TPD].[PayerPhoneNumber]

                      FROM
                        LP_Operation.TransactionLot                 [TL1]
						INNER join LP_Operation.[Transaction]             [T1]    ON T1.idTransactionLot=TL1.idTransactionLot
						INNER join LP_Operation.[TransactionDetail]             [TD]    ON TD.idTransaction = T1.idTransaction
						INNER JOIN [LP_Operation].[TransactionPayinDetail] [TPD]	ON [TPD].[idTransaction] = [T1].[idTransaction]
						INNER JOIN [LP_Common].[Status]			[STAT]		ON	[STAT].[idStatus]				= [T1].[idStatus]
						INNER JOIN [LP_Entity].[EntityUser]             [EU1]   ON [EU1].[idEntityUser]         = [T1].[idEntityUser]
						LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]				[TESM]		ON	[TESM].[idTransaction]			= [T1].[idTransaction]
						LEFT JOIN [LP_Entity].[EntitySubMerchant]							[ESM]		ON	[TESM].[idEntitySubMerchant]	= [ESM].[idEntitySubMerchant]
						INNER JOIN [LP_Location].[Country]              [C1]      ON [C1].[idCountry]           = [EU1].[idCountry]
						INNER JOIN [LP_Common].[Status]               [STATL1]    ON [STATL1].[idStatus]          = [TL1].[idStatus]
						inner join [LP_Security].[entityaccountUser] eacu on eacu.idEntityUser = [T1].idEntityUser and eacu.idEntityAccount = @idEntityAccount
						INNER JOIN [LP_Configuration].[CurrencyType] [CT] ON [CT].[idCurrencyType] = [T1].[CurrencyTypeClient]
						INNER JOIN [LP_Operation].[Ticket] [TK] ON [TK].[idTransaction] = [T1].[idTransaction]
                      WHERE
                        (
                        [T1].[idTransaction] = @payin_id  OR ( @payin_id =0 )
                        )
                        AND
                        (
                        ( [TPD].[MerchantId] = @merchant_id  ) OR ( @merchant_id IS NULL )
                        )
                        AND
                        (
                        cast(T1.TransactionDate as date) BETWEEN @date_from AND @date_to OR (@date_from IS NULL AND @date_to IS NULL)
                        )
                        AND [C1].[idCountry] =  @idCountry
                      
                      FOR JSON PATH
                    ) 
                    AS XML
                  )
              )

    SELECT @JSON_Result
  END
  ELSE
  BEGIN
    SET @Status = 0
    SET @Message = 'CLIENTE INEXISTENTE. VERFIQUE SU CUSTOMER_ID'
  END 
END
GO


