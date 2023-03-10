ALTER PROCEDURE [LP_Retentions_ARG].[SaveRetentionFile]
														(  @JSON						NVARCHAR(MAX)
														   , @idProcess					BIGINT
														   , @retentionCode				LP_Common.LP_F_CODE
														   , @idTransactionCertificate	BIGINT				 )

AS
BEGIN

--DECLARE @JSON NVARCHAR(MAX)
--SET @JSON = '{"idTransaction":150,"file_bytes":"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NDEwMDcyMDA2MjAwNjEwMDUyMDA2NTAwNzQwMDY1MDA2ZTAwNzQwMDY5MDA2ZjAwNmUwMDQzMDA2NTAwNzIwMDc0MDA2OTAwNjYwMDY5MDA2MzAwNjEwMDc0MDA2NT4NCi9BdXRob3IgPD4NCi9TdWJqZWN0IDw+DQovQ3JlYXRvciAoTWljcm9zb2Z0IFJlcG9ydGluZyBTZXJ2aWNlcyAxNS4wLjAuMCkNCi9Qcm9kdWNlciAoTWljcm9zb2Z0IFJlcG9ydGluZyBTZXJ2aWNlcyBQREYgUmVuZGVyaW5nIEV4dGVuc2lvbiAxNS4wLjAuMCkNCi9DcmVhdGlvbkRhdGUgKEQ6MjAxOTA4MzAxMTM3NTItMDMnMDAnKQ0KPj4NCmVuZG9iag0KeHJlZg0KMCA5DQowMDAwMDAwMDAwIDY1NTM1IGYNCjAwMDAwMDAwMTAgMDAwMDAgbg0KMDAwMDAwMTI4MSAwMDAwMCBuDQowMDAwMDAxNDU3IDAwMDAwIG4NCjAwMDAwMDE1NTggMDAwMDAgbg0KMDAwMDAwMDA2NSAwMDAwMCBuDQowMDAwMDAxNjYwIDAwMDAwIG4NCjAwMDAwMDE3MjIgMDAwMDAgbg0KMDAwMDAwMTc3NCAwMDAwMCBuDQp0cmFpbGVyIDw8IC9TaXplIDkgL1Jvb3QgNyAwIFIgL0luZm8gOCAwIFIgPj4NCnN0YXJ0eHJlZg0KMjEwMA0KJSVFT0Y=","file_name":"nombre archivo"}'
--DECLARE @idProcess BIGINT
--SET @idProcess = 46
--DECLARE @retentionCode LP_Common.LP_F_CODE 
--set @retentionCode = 'RET-ARBA'

	DECLARE @bytes varbinary(max), @name varchar(max), @id BIGINT

	SELECT
		@bytes = [file_bytes]
		, @name = [file_name]
		, @id = [id]
	FROM OPENJSON(@JSON)
	WITH
	(		
		[file_bytes]	VARBINARY(MAX) '$.file_bytes',
		[file_name]		VARCHAR(120) '$.file_name',
		[id]			BIGINT '$.idTransaction'
	)
	AS [DATA]

	DECLARE @idFileType LP_Common.LP_I_UNIQUE_IDENTIFIER_INT

	SET @idFileType = ( SELECT idFileType 
						FROM [LP_Configuration].[FileType] 
						WHERE Code = @retentionCode )

	UPDATE [LP_Retentions_ARG].[TransactionCertificate] SET [CertificateDate]= GETDATE(), [FileBytes]= @bytes, [FileName]=@name where idTransaction = @id AND idFileType = @idFileType

	INSERT INTO [LP_Retentions_ARG].TransactionCertificateProcess (idTransactionCertificate, idRetentionCertificate)
	VALUES (@idTransactionCertificate, @idProcess)
END

