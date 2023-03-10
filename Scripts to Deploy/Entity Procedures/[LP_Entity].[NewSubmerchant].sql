CREATE OR ALTER PROCEDURE [LP_Entity].[NewSubmerchant]
																	(
																		@idEntityUser		[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
																		@Submerchant		[LP_Common].[LP_F_DESCRIPTION]
																	)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @CommissionValue	[LP_Common].[LP_F_DECIMAL],
					@CommissionCurrency [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

			SELECT 
				@CommissionValue =  CommissionValue
				,@CommissionCurrency = CommissionCurrency
			FROM [LP_Entity].[EntityUser]
			WHERE idEntityUser = @idEntityUser

			INSERT INTO [LP_Entity].[EntitySubMerchant]
			(Description, SubMerchantIdentification, idEntityUser, isDefault, WithRetentions, Active, SubMerchantCode, SubMerchantAddress, WithRetentionsARBA, IsCorporate,CommissionValuePO, CommissionCurrencyPO)
			VALUES (@Submerchant, @Submerchant, @idEntityUser, 0, 0, 1, '', '', 0, 1,@CommissionValue,@CommissionCurrency)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
		DECLARE @ErrorState INT = ERROR_STATE()

		RAISERROR
				(
					@ErrorMessage,
					@ErrorSeverity,
					@ErrorState
				);
	END CATCH
END
