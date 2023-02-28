begin tran

declare @idProvider as int
declare @idCountry as int

set @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'ARS' AND [Active] = 1)

select @idProvider = idProvider
from LP_Configuration.Provider where Code = 'BSPVIELLE' and idCountry = @idCountry

UPDATE LP_Configuration.[InternalStatus] SET isError = 1 
WHERE Code = 'REJECTED' 
AND	[idProvider] = @idProvider
AND	[idCountry] = @idCountry



-- Bank Error Codes
INSERT INTO LP_Configuration.[InternalStatus] (Code, Name, Description, idProvider, idCountry, Active, idInternalStatusType, isError, FinalStatus)
VALUES
('14', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('15', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('18', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('20', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('50', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('51', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('52', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('60', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('62', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('35', 'Cuenta inexistente', 'Cuenta inexistente', 10, 1, 1, 3, 1, 1),
('36', 'CBU inválida - Banco erróneo', 'CBU inválida - Banco erróneo', 10, 1, 1, 3, 1, 1),
('54', 'Todos los errores', 'Todos los errores', 10, 1, 1, 3, 1, 1),
('56', 'Cuenta inexistente', 'Cuenta inexistente', 10, 1, 1, 3, 1, 1),
('57', 'Concepto de acreditación inválido', 'Concepto de acreditación inválido', 10, 1, 1, 3, 1, 1)


commit tran

