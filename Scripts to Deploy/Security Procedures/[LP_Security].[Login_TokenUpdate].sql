GO
/****** Object:  StoredProcedure [LP_Security].[Login_TokenUpdate]    Script Date: 16/08/2021 19:23:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [LP_Security].[Login_TokenUpdate]
														(
															@Identification			[LP_Common].[LP_F_C100]
															, @App					[LP_Common].[LP_F_BOOL]
															, @JWT_Token			[LP_Common].[LP_F_VMAX]
														)
		AS
		BEGIN

			DECLARE
				@idEntityUser				[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idEntityAccount			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]
				, @idEntityApiCredential	[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

			IF(@App = 1)
			BEGIN

				SELECT
					@idEntityUser = [idEntityUser]
					, @idEntityAccount = [idEntityAccount]
				FROM
					[LP_Security].[EntityAccount]
				WHERE
					[UserSiteIdentification] = @Identification

				--UPDATE [LP_Log].[Login]
				--SET
				--	[Token] = @JWT_Token
				--WHERE
				--	[idEntityUser] = @idEntityUser
				--	AND [idEntityAccount] = @idEntityAccount
				--	AND [LogOutDateTime] IS NULL

			END
			ELSE
			BEGIN

				SELECT
					@idEntityUser = [idEntityUser]
					, @idEntityApiCredential = [idEntityApiCredential]
				FROM
					[LP_Security].[EntityApiCredential]
				WHERE
					[Identification] = @Identification

				--UPDATE [LP_Log].[Login]
				--SET
				--	[Token] = @JWT_Token
				--WHERE
				--	[idEntityUser] = @idEntityUser
				--	AND [idEntityApiCredential] = @idEntityApiCredential
				--	AND [LogOutDateTime] IS NULL

			END

		END
		
		
		