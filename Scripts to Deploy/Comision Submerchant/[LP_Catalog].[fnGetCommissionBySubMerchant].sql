/****** Object:  UserDefinedFunction [LP_Catalog].[fnGetCommissionBySubMerchant]    Script Date: 28/2/2020 10:42:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [LP_Catalog].[fnGetCommissionBySubMerchant]
                            (
                              @idEntitySubMerchant     [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
                            )
RETURNS [LP_Common].[LP_F_DECIMAL]
AS
BEGIN
  
  DECLARE
    @result           [LP_Common].[LP_F_DECIMAL]
    , @Value          [LP_Common].[LP_F_DECIMAL]

  SELECT 
    @Value = ISNULL([SM].[CommissionValuePO], 0)
  FROM
    [LP_Entity].[EntitySubMerchant] [SM] (NOLOCK)
  WHERE
    [SM].[idEntitySubMerchant] = @idEntitySubMerchant

  SET @result = @Value

  RETURN @result
END
