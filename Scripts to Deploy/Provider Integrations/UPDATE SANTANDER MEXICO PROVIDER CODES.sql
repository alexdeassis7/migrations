BEGIN TRAN

DECLARE @idCountry			        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idCurrencyType		        [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idProvider                 [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idInternalStatusType       [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT],
        @idPayWayService            [LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

SET @idCountry = (SELECT idCountry FROM LP_Location.Country WHERE ISO3166_1_ALFA003 = 'MEX')
SET @idCurrencyType = (SELECT idCurrencyType FROM LP_Configuration.CurrencyType WHERE Code = 'MXN')
SET @idProvider = (SELECT idProvider FROM [LP_Configuration].[Provider] WHERE idCountry = @idCountry and Code = 'SRM')
SET @idInternalStatusType = (SELECT idInternalStatusType FROM [LP_Configuration].[InternalStatusType] WHERE idCountry = @idCountry AND Code = 'SCM')
SET @idPayWayService = (SELECT idPayWayService FROM [LP_Configuration].[PayWayServices] WHERE idCountry = @idCountry AND Code = 'BANKDEPO')

--- UPDATE
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANCO' WHERE [Code] = '001'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANAM' WHERE [Code] = '002'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BCEXT' WHERE [Code] = '006'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BOBRA' WHERE [Code] = '009'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BACOM' WHERE [Code] = '012'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANME' WHERE [Code] = '014'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BEJER' WHERE [Code] = '019'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BITAL' WHERE [Code] = '021'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAJIO' WHERE [Code] = '030'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAIXE' WHERE [Code] = '032'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BINBU' WHERE [Code] = '036'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BINTE' WHERE [Code] = '037'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'MIFEL' WHERE [Code] = '042'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'COMER' WHERE [Code] = '044'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANRE' WHERE [Code] = '058'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BINVE' WHERE [Code] = '059'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANSI' WHERE [Code] = '060'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAFIR' WHERE [Code] = '062'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BBANO' WHERE [Code] = '072'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'ABNBA' WHERE [Code] = '102'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'AMEX' WHERE [Code] = '103'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAMSA' WHERE [Code] = '106'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'TOKYO' WHERE [Code] = '108'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'CHASE' WHERE [Code] = '110'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'CMCA' WHERE [Code] = '112'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'DRESD' WHERE [Code] = '113'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'INGBA' WHERE [Code] = '116'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'DEUTB' WHERE [Code] = '124'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'CRESU' WHERE [Code] = '126'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAZTE' WHERE [Code] = '127'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BAUTO' WHERE [Code] = '128'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BARCL' WHERE [Code] = '129'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BCOMP' WHERE [Code] = '130'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'FAMSA' WHERE [Code] = '131'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'MULTI' WHERE [Code] = '132'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'PRUDE' WHERE [Code] = '133'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BWALL' WHERE [Code] = '134'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'NAFIN' WHERE [Code] = '135'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'REGIO' WHERE [Code] = '136'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'COPEL' WHERE [Code] = '137'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'AMIGO' WHERE [Code] = '138'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'UBSBA' WHERE [Code] = '139'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'FACIL' WHERE [Code] = '140'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'VOLKS' WHERE [Code] = '141'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'CONSU' WHERE [Code] = '143'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BBASE' WHERE [Code] = '145'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40147' WHERE [Code] = '147'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90148' WHERE [Code] = '148'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90150' WHERE [Code] = '150'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40151' WHERE [Code] = '151'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40152' WHERE [Code] = '152'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40154' WHERE [Code] = '154'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40155' WHERE [Code] = '155'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40156' WHERE [Code] = '156'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40157' WHERE [Code] = '157'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40158' WHERE [Code] = '158'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '40160' WHERE [Code] = '160'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'BANSE' WHERE [Code] = '166'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = 'HIFED' WHERE [Code] = '168'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90600' WHERE [Code] = '600'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90601' WHERE [Code] = '601'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90602' WHERE [Code] = '602'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90605' WHERE [Code] = '605'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90606' WHERE [Code] = '606'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90607' WHERE [Code] = '607'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90608' WHERE [Code] = '608'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90610' WHERE [Code] = '610'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90613' WHERE [Code] = '613'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90614' WHERE [Code] = '614'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90615' WHERE [Code] = '615'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90616' WHERE [Code] = '616'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90617' WHERE [Code] = '617'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90618' WHERE [Code] = '618'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90619' WHERE [Code] = '619'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90620' WHERE [Code] = '620'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90621' WHERE [Code] = '621'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90622' WHERE [Code] = '622'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90623' WHERE [Code] = '623'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90626' WHERE [Code] = '626'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90627' WHERE [Code] = '627'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90628' WHERE [Code] = '628'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90629' WHERE [Code] = '629'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90630' WHERE [Code] = '630'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90631' WHERE [Code] = '631'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90632' WHERE [Code] = '632'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90633' WHERE [Code] = '633'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90634' WHERE [Code] = '634'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90636' WHERE [Code] = '636'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90637' WHERE [Code] = '637'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90638' WHERE [Code] = '638'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90640' WHERE [Code] = '640'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90642' WHERE [Code] = '642'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90646' WHERE [Code] = '646'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90647' WHERE [Code] = '647'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90648' WHERE [Code] = '648'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90649' WHERE [Code] = '649'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90651' WHERE [Code] = '651'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90652' WHERE [Code] = '652'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90653' WHERE [Code] = '653'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90655' WHERE [Code] = '655'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90656' WHERE [Code] = '656'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90659' WHERE [Code] = '659'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90670' WHERE [Code] = '670'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90677' WHERE [Code] = '677'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90680' WHERE [Code] = '680'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90683' WHERE [Code] = '683'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90684' WHERE [Code] = '684'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90685' WHERE [Code] = '685'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90686' WHERE [Code] = '686'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90689' WHERE [Code] = '689'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90901' WHERE [Code] = '901'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90902' WHERE [Code] = '902'  AND [idCountry] = @idCountry; 
UPDATE [LP_Configuration].[BankCode] SET [SubCode] = '90903' WHERE [Code] = '903'  AND [idCountry] = @idCountry; 

INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('146','BICENTENARIO','  BICENTENARIO', @idCountry, 1, 'BICEN');

-- CONFIG PayOut

INSERT INTO LP_Configuration.TransactionTypeProvider([idTransactionType], [idProvider], [Active])
VALUES (2,@idProvider, 1);

INSERT INTO LP_Configuration.ProviderPayWayServices(idProvider, idPayWayService, Active)
VALUES (@idProvider,@idPayWayService,1);

ROLLBACK