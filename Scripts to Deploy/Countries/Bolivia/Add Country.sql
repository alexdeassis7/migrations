DECLARE @currencyId INT;
DECLARE @countryId INT;


SET @currencyId =
(
    SELECT [idCurrencyType]
    FROM [LocalPaymentPROD].[LP_Configuration].[CurrencyType]
    WHERE Code = 'BOB'
);

SET @countryId =
(
    SELECT [idCountry]
    FROM [LocalPaymentPROD].[LP_Location].[Country]
    WHERE Name = 'BOLIVIA (PLURINATIONAL STATE OF)'
);

INSERT INTO LP_Location.CountryCurrency
(
    idCountry,
    idCurrencyType,
    Active
)
VALUES
(@countryId, @currencyId, 1);

DROP TABLE [LP_Configuration].[BankCode_Lookup]
 

INSERT INTO [LP_Configuration].[BankCode]
(
    [Code],
    [Name],
    [Description],
    [idCountry],
    [Active],
    [SubCode],
    [SubCode2]
)
VALUES
('001', 'Banco Mercantil', 'Banco Mercantil', @countryId, 1, '', ''),
('002', 'Banco Nacional de Bolivia', 'Banco Nacional de Bolivia', @countryId, 1, '', ''),
('003', 'Banco de Cr�dito de Bolivia', 'Banco de Cr�dito de Bolivia', @countryId, 1, '', ''),
('004', 'Banco Do Brasil', 'Banco Do Brasil', @countryId, 1, '', ''),
('005', 'Banco BISA', 'Banco BISA', @countryId, 1, '', ''),
('006', 'Banco Uni�n', 'Banco Uni�n', @countryId, 1, '', ''),
('007', 'Banco Econ�mico', 'Banco Econ�mico', @countryId, 1, '', ''),
('008', 'Banco Solidario', 'Banco Solidario', @countryId, 1, '', ''),
('009', 'Banco Ganadero', 'Banco Ganadero', @countryId, 1, '', ''),
('010', 'Banco Los Andes Pro Credit', 'Banco Los Andes Pro Credit', @countryId, 0, '', ''),		-- DESACTIVADO  X DEFECTO
('011', 'Mutual la Primera', 'Mutual la Primera', @countryId, 1, '', ''),
('012', 'Mutual Guapay', 'Mutual Guapay', @countryId, 0, '', ''),								-- DESACTIVADO  X DEFECTO
('013', 'Mutual la Promotora', 'Mutual la Promotora', @countryId, 1, '', ''),
('014', 'Mutual el Progreso', 'Mutual el Progreso', @countryId, 1, '', ''),
('015', 'Mutual La Plata', 'Mutual La Plata', @countryId, 0, '', ''),							-- DESACTIVADO  X DEFECTO
('016', 'Mutual Potos�', 'Mutual Potos�', @countryId, 0, '', ''),								-- DESACTIVADO  X DEFECTO
('017', 'Mutual la Tarija', 'Mutual la Tarija', @countryId, 0, '', ''),							-- DESACTIVADO  X DEFECTO
('018', 'Mutual Paititi', 'Mutual Paititi', @countryId, 0, '', ''),								-- DESACTIVADO  X DEFECTO
('019', 'Mutual del Pueblo', 'Mutual del Pueblo', @countryId, 0, '', ''),						-- DESACTIVADO  X DEFECTO
('020', 'Mutual Pando', 'Mutual Pando', @countryId, 0, '', ''),									-- DESACTIVADO  X DEFECTO
('021', 'Mutual Manutata', 'Mutual Manutata', @countryId, 0, '', ''),							-- DESACTIVADO  X DEFECTO
('022', 'Cooperativa Jes�s Nazareno', 'Cooperativa Jes�s Nazareno', @countryId, 1, '', ''),
('023', 'Cooperativa San Martin', 'Cooperativa San Martin', @countryId, 1, '', ''),
('024', 'Cooperativa F�tima', 'Cooperativa F�tima', @countryId, 1, '', ''),
('025', 'Cooperativa San Pedro', 'Cooperativa San Pedro', @countryId, 1, '', ''),
('026', 'Cooperativa Loyola', 'Cooperativa Loyola', @countryId, 1, '', ''),
('027', 'Cooperativa Hospicio', 'Cooperativa Hospicio', @countryId, 0, '', ''),					-- DESACTIVADO  X DEFECTO
('028', 'Cooperativa San Antonio', 'Cooperativa San Antonio', @countryId, 1, '', ''),
('029', 'Cooperativa PIO X', 'Cooperativa PIO X', @countryId, 1, '', ''),
('030', 'Cooperativa Incahuassi', 'Cooperativa Incahuassi', @countryId, 0, '', ''),				-- DESACTIVADO  X DEFECTO
('031', 'Cooperativa Quillacollo', 'Cooperativa Quillacollo', @countryId, 1, '', ''),
('032', 'Cooperativa San Jose de Punata', 'Cooperativa San Jose de Punata', @countryId, 1, '', ''),
('033', 'Cooperativa Trinidad', 'Cooperativa Trinidad', @countryId, 1, '', ''),
('034', 'Cooperativa Comarapa', 'Cooperativa Comarapa', @countryId, 1, '', ''),
('035', 'Cooperativa San Mateo', 'Cooperativa San Mateo', @countryId, 1, '', ''),
('036', 'Cooperativa El Chorolque', 'Cooperativa El Chorolque', @countryId, 1, '', ''),
('037', 'Cooperativa Educadores Gran Chaco', 'Cooperativa Educadores Gran Chaco', @countryId, 1, '', ''),
('038', 'Cooperativa Catedral', 'Cooperativa Catedral', @countryId, 1, '', ''),
('039', 'Magisterio Rural', 'Magisterio Rural', @countryId, 1, '', ''),
('040', 'Cooperativa San Joaqu�n', 'Cooperativa San Joaqu�n', @countryId, 0, '', ''),						-- DESACTIVADO  X DEFECTO
('041', 'Cooperativa Trapetrol Oriente', 'Cooperativa Trapetrol Oriente', @countryId, 0, '', ''),			-- DESACTIVADO  X DEFECTO
('042', 'Nacional Financiera Boliviana SAN', 'Nacional Financiera Boliviana SAN', @countryId, 0, '', ''),	-- DESACTIVADO  X DEFECTO
('043', 'Financiera Acceso La Paz', 'Financiera Acceso La Paz', @countryId, 0, '', ''),						-- DESACTIVADO  X DEFECTO
('044', 'Fondo Financiero de la Comunidad', 'Fondo Financiero de la Comunidad', @countryId, 0, '', ''),		-- DESACTIVADO  X DEFECTO
('045', 'Banco FIE', 'Banco FIE', @countryId, 1, '', ''),
('046', 'Banco Fassil', 'Banco Fassil', @countryId, 1, '', ''),
('047', 'Banco Ecofuturo', 'Banco Ecofuturo', @countryId, 1, '', ''),
('049', 'Banco Fortaleza', 'Banco Fortaleza', @countryId, 1, '', ''),
('050', 'Institucion Financiera de Desarrollo', 'Institucion Financiera de Desarrollo', @countryId, 1, '', ''),
('051', 'Cooperativa La Merced', 'Cooperativa La Merced', @countryId, 1, '', ''),
('052', 'Banco de la Nacion Argentina', 'Banco de la Nacion Argentina', @countryId, 1, '', ''),
('053', 'Tigo Money (billetera movil)', 'Tigo Money (billetera movil)', @countryId, 1, '', ''),
('054', 'Billetera M�vil de Entel', 'Billetera M�vil de Entel', @countryId, 1, '', ''),
('055', 'Yolo pago (billetera movil del BGA)', 'Yolo pago (billetera movil del BGA)', @countryId, 1, '', ''),
('056', 'Soli (billetera movil del BCP)', 'Soli (billetera movil del BCP)', @countryId, 1, '', '');



INSERT INTO [LP_Entity].[EntityIdentificationType]
(
    [Code],
    [Name],
    [Description],
    [idCountry],
    [Active]
)
VALUES
('CI', 'Cedula de Identidad', 'Cedula de Identidad', @countryId, 1);

INSERT INTO [LP_Entity].[EntityIdentificationType]
(
    [Code],
    [Name],
    [Description],
    [idCountry],
    [Active]
)
VALUES
('CIE', 'Cedula de Identidad de Extranjero', 'Cedula de Identidad de Extranjero', @countryId, 1);

INSERT INTO [LP_Entity].[EntityIdentificationType]
(
    [Code],
    [Name],
    [Description],
    [idCountry],
    [Active]
)
VALUES
('NIT', 'Numero de Identificacion Tributaria', 'Numero de Identificacion Tributaria', @countryId, 1);


INSERT INTO [LP_Configuration].[InternalStatusType]
(
    [Code],
    [Name],
    [Description],
    [Active],
    [OP_InsDateTime],
    [OP_UpdDateTime],
    [DB_InsDateTime],
    [DB_UpdDateTime],
    [idCountry]
)
VALUES
('SCM', 'State Codes of Movements', 'State Codes of Movements', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(),
 @countryId);

INSERT INTO [LP_Configuration].[BankAccountType]
(
    [Code],
    [Name],
    [Description],
    [Active],
    [OP_InsDateTime],
    [OP_UpdDateTime],
    [DB_InsDateTime],
    [DB_UpdDateTime],
    [idCountry]
)
VALUES
('A', 'CA', 'Caja de Ahorro', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @countryId);


INSERT INTO [LP_Configuration].[BankAccountType]
(
    [Code],
    [Name],
    [Description],
    [Active],
    [OP_InsDateTime],
    [OP_UpdDateTime],
    [DB_InsDateTime],
    [DB_UpdDateTime],
    [idCountry]
)
VALUES
('C', 'CC', 'Cuenta Corriente', 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), @countryId);

INSERT INTO [LP_Configuration].[PaymentType]
(
    [Code],
    [Name],
    [Description],
    [idCountry],
    [Active],
    [OP_InsDateTime],
    [OP_UpdDateTime],
    [DB_InsDateTime],
    [DB_UpdDateTime],
    [CatalogValue]
)
VALUES
('SUPPLIERS', 'Pago a Proveedores', 'Pago a Proveedores', @countryId, 1, GETDATE(), GETDATE(), GETDATE(), GETDATE(), 2);
