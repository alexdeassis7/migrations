BEGIN TRAN

DECLARE @idCountry      			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = ( SELECT [idCountry] FROM [LP_Location].[Country] WHERE [Code] = 'COP' AND [Active] = 1 )

IF COL_LENGTH('[LP_Configuration].[BankCode]','SubCode2') IS NULL
BEGIN
	ALTER TABLE [LP_Configuration].[BankCode] ADD SubCode2 VARCHAR(40) NOT NULL DEFAULT '00000000';
END

UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00540209' WHERE Code = '1052' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000040' WHERE Code = '1040' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000053' WHERE Code = '1053' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560007' WHERE Code = '1007' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001061' WHERE Code = '1061' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560013' WHERE Code = '1013' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560001' WHERE Code = '1001' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560032' WHERE Code = '1032' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560019' WHERE Code = '1009' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560019' WHERE Code = '1019' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000370' WHERE Code = '1370' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000292' WHERE Code = '1292' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000283' WHERE Code = '1283' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000066' WHERE Code = '1066' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001289' WHERE Code = '1289' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00589514' WHERE Code = '1051' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001062' WHERE Code = '1062' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000121' WHERE Code = '1121' AND idCountry = @idCountry;

UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001063' WHERE Code = '1063' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560012' WHERE Code = '1012' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560014' WHERE Code = '1014' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001064' WHERE Code = '1064' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560023' WHERE Code = '1023' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560060' WHERE Code = '1060' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560002' WHERE Code = '1002' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000058' WHERE Code = '1058' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001065' WHERE Code = '1065' AND idCountry = @idCountry;

UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001507' WHERE Code = '1507' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000067' WHERE Code = '1067' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560006' WHERE Code = '1006' AND idCountry = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001151' WHERE Code = '1151' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000551' WHERE Code = '1551' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00001303' WHERE Code = '1303' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000069' WHERE Code = '1069' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00000059' WHERE Code = '1059' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560047' WHERE Code = '1047' AND idCountry = @idCountry;
UPDATE [LP_Configuration].[BankCode] SET [SubCode2] = '00560031' WHERE Code = '1031' AND idCountry = @idCountry;

INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode], [SubCode2])
VALUES
('1558', 'BANCO CREDIFINANCIERA S.A.','BANCO CREDIFINANCIERA S.A.', @idCountry,1,'1558','00001558'),
('0000', 'BANCO DE LA REPUBLICA','BANCO DE LA REPUBLICA',@idCountry,1,'0000','00000000'),
('1042', 'BNP PARIBAS COLOMBIA','BNP PARIBAS COLOMBIA',@idCountry,1,'1042','00001042'),
('0083', 'COMPENSAR','COMPENSAR',@idCountry,1,'0083','00000083'),
('0550', 'DECEVAL S.A.','DECEVAL S.A.',@idCountry,1,'0550','00000550'),
('1502', 'FIDUCIARIA SKANDIA','FIDUCIARIA SKANDIA',@idCountry,1,'1502','00571502'),
('0041', 'JP MORGAN CORPORACION FINANCIERA','JP MORGAN CORPORACION FINANCIERA',@idCountry,1,'0041','00000041')

ROLLBACK