BEGIN
   IF NOT EXISTS (SELECT * FROM [LP_Configuration].[InternalStatus]
					WHERE Code = 'D87')
   BEGIN
	  INSERT INTO [LP_Configuration].[InternalStatus] (Code, Name, Description, idProvider, idCountry, Active, idInternalStatusType, isError, FinalStatus)
	  VALUES('D87','MONTO EXCEDE LIMITE DEL BENEFICIARIO','MONTO EXCEDE LIMITE DEL BENEFICIARIO',9,49,1,6,1,1)
   END
END