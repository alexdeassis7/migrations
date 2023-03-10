USE [LocalPaymentPROD]
GO
/****** Object:  StoredProcedure [LP_Filter].[AuditLogs]    Script Date: 26/07/2022 3:05:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [LP_Filter].[AuditLogs]
	-- Recibe 4 parametros
	@dateFrom varchar(50), -- Fecha Hasta
	@dateTo varchar(50), --Fecha Desde	
	@quantity int, -- Cantidad de registros
	@dataToSearch varchar(100) -- Dato a buscar
	
AS
BEGIN

SELECT @dataToSearch = REPLACE(@dataToSearch, ' ', '');

SELECT TOP (@quantity) *
FROM [LP_Log].[AuditLog] A
WHERE CONTAINS (A.[Message], @dataToSearch)
--and [A].[TimeStamp] BETWEEN @dateFrom and  @dateTo
and [A].[TimeStamp] >= @dateFrom and [A].[TimeStamp] <= @dateTo
ORDER BY A.id desc

END
