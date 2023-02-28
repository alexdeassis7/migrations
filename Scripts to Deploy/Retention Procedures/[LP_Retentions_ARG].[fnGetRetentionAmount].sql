/****** Object:  UserDefinedFunction [LP_Retentions_ARG].[fnGetRetentionAmount]    Script Date: 13/4/2020 17:23:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [LP_Retentions_ARG].[fnGetRetentionAmount](5693.900000,12,5,27936982587,'2019-08-12 17:47:47.8066667 +00:00',)
ALTER FUNCTION [LP_Retentions_ARG].[fnGetRetentionAmount]
                            (
                              @MONTOTRANS     [LP_Common].[LP_F_DECIMAL]
                              , @IDENTI     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

                              , @idSubMerchant  [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
                              , @ClienCUIT    [LP_Common].[LP_F_C11]
                              , @transactionDate  [LP_Common].[LP_A_OP_INSDATETIME]
                              , @idTransaction    [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
                            )
RETURNS LP_Common.LP_F_DECIMAL
AS
BEGIN

  /*MONOTRIBUTO NI
  IMP GANAN NI SELECT TOP 10 MonoTax,IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax='NI' AND IncomeTax='NI' ORDER BY IDREGISTEREDENTITIES DESC
  IMP GANAN   AC SELECT TOP 10 MonoTax,IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax='NI' AND IncomeTax='AC' ORDER BY IDREGISTEREDENTITIES DESC
  IMP GANAN   EX SELECT TOP 10 MonoTax,IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax='NI' AND IncomeTax='EX' ORDER BY IDREGISTEREDENTITIES DESC
  IMP GANAN   NC SELECT TOP 10 MonoTax,IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax='NI' AND IncomeTax='NC' ORDER BY IDREGISTEREDENTITIES DESC
  LETRA
  IMP GANAN NI SELECT  TOP 10  MonoTax, IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax<>'NI' AND IncomeTax='NI' ORDER BY IDREGISTEREDENTITIES DESC
  IMP GANAN AC SELECT   MonoTax, IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE IncomeTax='AC' ORDER BY IDREGISTEREDENTITIES DESC
  IMP GANAN EX -
  IMP GANAN NC SELECT  TOP 10  MonoTax, IncomeTax,CUIT,ALIAS FROM LP_Retentions_ARG.RegisteredEntities WHERE MonoTax<>'NI' AND IncomeTax='NC' ORDER BY IDREGISTEREDENTITIES DESC
  */

  DECLARE
    @IDENTUSER      LP_Common.LP_F_INT
    , @REG        LP_Common.LP_F_C2
    , @IncomeTax    LP_Common.LP_F_C2
    , @MonoTax      LP_Common.LP_F_C2
    , @MONTOCALC    LP_Common.LP_F_DECIMAL
    , @MONTOSET     LP_Common.LP_F_DECIMAL
    , @PORC_REG_NOINS LP_Common.LP_F_DECIMAL
    , @PORC_REG_INS   LP_Common.LP_F_DECIMAL
    , @MININMP_REG_INS  LP_Common.LP_F_DECIMAL
    , @RENTEN     LP_Common.LP_F_DECIMAL
    , @TAXHOLDACUM    LP_Common.LP_F_DECIMAL

  --SELECT @IDENTUSER=idEntityUser FROM LP_Security.EntityAccount WHERE Identification=@IDENTI  

  SELECT
    @REG        = [R].[REG]
    , @PORC_REG_NOINS = [R].[NOINSC]
    , @PORC_REG_INS   = [R].[INSC]
    , @MININMP_REG_INS  = [R].[MINNOIMP]
    , @MONTOSET     = 0
  FROM
    [LP_Retentions_ARG].[Reg830_Merchant]   [RM]
      LEFT JOIN [LP_Retentions_ARG].[Reg830]  [R]   ON [RM].[idReg] = [R].[idReg]
  WHERE
    [RM].[idEntitySubMerchant] = @idSubMerchant
    AND IdFileType=1

  SELECT
    @IncomeTax = [IncomeTax]
    , @MonoTax = [MonoTax]
  FROM
    [LP_Retentions_ARG].[RegisteredEntities]
  WHERE
    [CUIT] = @ClienCUIT

  IF(@MonoTax <> 'NI') -- En el caso de los monotributos, cuando se excede de su Monto de la tabla LP_Retentions_ARG.Monotax, le retengo el 28% de lo que transaccione. Acá acumula todos los regimenes. No distingue por regimenes
  BEGIN
    SELECT
      @MONTOCALC = ISNULL(SUM([TD].[GrossAmount]), 0) + @MONTOTRANS
    FROM
      [LP_Operation].[Transaction]                [T]
        LEFT JOIN [LP_Operation].[TransactionDetail]      [TD]  ON [T].[idTransaction] = [TD].[idTransaction] AND [TD].[Active] = 1
        LEFT JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON [T].[idTransaction] = [TRD].[idTransaction] AND [TRD].[Active] = 1
    WHERE
      --[T].[idStatus] IN(1, 3,  4) 
      [T].[idStatus]  <>  4
      AND [RecipientCUIT] = @ClienCUIT
      AND [TRD].[OP_InsDateTime] BETWEEN DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) AND DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, -1)
      AND [T].TransactionDate <=  @transactionDate
      AND [T].Active = 1
      AND [T].idTransaction < @idTransaction

    SELECT
      @TAXHOLDACUM = ISNULL(SUM([TD].[TaxWithholdings]), 0) 
    FROM
      [LP_Operation].[Transaction]                [T]
        LEFT JOIN [LP_Operation].[TransactionDetail]      [TD]  ON [T].[idTransaction] = [TD].[idTransaction] AND [TD].[Active] = 1
        LEFT JOIN [LP_Operation].[TransactionRecipientDetail] [TRD] ON [T].[idTransaction] = [TRD].[idTransaction] AND [TRD].[Active] = 1
    WHERE
      --[T].[idStatus] IN(1, 3,  4) 
      [T].[idStatus]  <>  4
      AND [T].[idEntityUser] = @IDENTI 
      AND [TRD].[RecipientCUIT] = @ClienCUIT 
      AND [TD].[OP_InsDateTime] BETWEEN DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0) AND DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) + 1, -1)
      AND [T].TransactionDate <=  @transactionDate
      AND [T].Active = 1
      AND [T].idTransaction < @idTransaction
    --SUMO TODOS LOS RETENIDO EN EL AÑO PARA RESTAR A LO QUE LE VOY A RETENER EN ESTE PAGO

    SELECT
      @MONTOSET = [MONTO]
    FROM
      [LP_Retentions_ARG].[Monotax]
    WHERE
      [Cate] = @MonoTax
      AND [idFileType]  = 1

    IF(@MONTOCALC > @MONTOSET)
    BEGIN
      SET @RENTEN = ((@MONTOCALC - @MONTOSET) * @PORC_REG_NOINS) - @TAXHOLDACUM
    END
    ELSE
    BEGIN
      SET @RENTEN = 0
    END

  END
  ELSE IF(@IncomeTax = 'AC') -- Responsable inscripto. Aquí al momento de transaccionar tengo en cuenta los montos no imponibles, y son por mes por regimen por cuit, y la acumulación la tengo que tener en cuenta por regimen por mes por cuit
  BEGIN     
    SELECT
      @MONTOCALC = ISNULL(SUM([TD].[GrossAmount]), 0) + @MONTOTRANS,
      @TAXHOLDACUM = ISNULL(SUM([TD].[TaxWithholdings]), 0)
    FROM
      [LP_Operation].[Transaction]                [T]
      LEFT JOIN [LP_Operation].[TransactionDetail]        [TD]  ON [T].[idTransaction] = [TD].[idTransaction]  AND [TD].[Active] = 1
      LEFT JOIN [LP_Operation].[TransactionRecipientDetail]   [TRD] ON [T].[idTransaction] = [TRD].[idTransaction] AND [TRD].[Active] = 1
      LEFT JOIN [LP_Operation].[TransactionEntitySubMerchant]   [TESM]  ON [T].[idTransaction] = [TESM].[idTransaction]

    WHERE
      [T].[idStatus] IN(1, 3,  4) 
      --[T].[idStatus]  <>  4
      AND [TESM].[idEntitySubMerchant] = @idSubMerchant

      AND [TRD].[RecipientCUIT] = @ClienCUIT
      AND [TRD].[OP_InsDateTime] BETWEEN DATEADD(MM, DATEDIFF(MM, 0, GETDATE()), 0) AND DATEADD(ms, -3, DATEADD(MM, DATEDIFF(MM, 0, GETDATE()) + 1, 0))
      AND [T].TransactionDate <=  @transactionDate
      AND [T].Active = 1
      AND [T].idTransaction < @idTransaction

    -- SI YA HAY RETENCION ACUMULADA, QUIERE DECIR QUE EL MINIMO NO IMPONIBLE FUE DEDUCIDO, POR LO TANTO DIRECTAMENTE RETENEMOS EL PORCENTAJE DEFINIDO
    IF(@TAXHOLDACUM > 0)
    BEGIN
      SET @RENTEN = @MONTOTRANS * @PORC_REG_INS
    END
    -- SI NO HAY RETENCION ACUMULADA
    ELSE
    BEGIN
      -- 1) SI EL MONTO ACUMULADO HASTA LA TX ACTUAL INCLUSIVE SUPERA EL MINIMO NO IMPONIBLE, LO DEDUCIMOS Y CALCULAMOS LA RETENCION EN BASE AL RESULTADO
      IF(@MONTOCALC > @MININMP_REG_INS)
      BEGIN
        SET @RENTEN = (@MONTOCALC - @MININMP_REG_INS) * @PORC_REG_INS
      END
      -- 2) SI EL MONTO ACUMULADO HASTA LA TX ACTUAL INCLUSIVE NO SUPERA EL MINIMO NO IMPONIBLE, NO APLICAMOS RETENCION
      ELSE
      BEGIN
        SET @RENTEN = 0
      END
    END
  END
  ELSE IF(@IncomeTax = 'EX') -- No le retengo nada
  BEGIN
    SET @RENTEN = 0
  END
  ELSE IF(@IncomeTax = 'NI' OR @IncomeTax = 'NC') -- Los no incriptos pagan el 28% sin importar el acumulado
  BEGIN
    SET @RENTEN = (@MONTOTRANS) * ISNULL(@PORC_REG_NOINS, 0.28)
  END
  ELSE
  BEGIN
    SET @RENTEN = ((@MONTOTRANS) * @PORC_REG_NOINS)
  END

  IF (@RENTEN < 0)
  BEGIN
    SET @RENTEN = 0
  END

  RETURN @RENTEN
END
