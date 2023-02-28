DROP PROCEDURE IF EXISTS [LP_Operation].[TransactionCertificates_Create];
GO

CREATE PROCEDURE [LP_Operation].[TransactionCertificates_Create]
(
@JSON VARCHAR(MAX)
)
AS
	INSERT INTO LP_Operation.TransactionCertificates ([idTransaction],[CertificateFileBytes],[certificateNumber])
	SELECT * FROM OPENJSON(@JSON)
	WITH (   
              idTransaction  bigint '$.idTransaction' ,  
              data  varbinary(max) '$.data'  ,
			  certificateNumber bigint '$.certificateNumber'
			);
GO