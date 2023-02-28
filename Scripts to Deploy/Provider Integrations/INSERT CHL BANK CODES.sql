BEGIN TRAN
DECLARE @idCountryChile			[LP_Common].[LP_I_UNIQUE_IDENTIFIER_INT]

set @idCountryChile = (SELECT idCountry FROM LP_Location.Country Where ISO3166_1_ALFA003 = 'CHL')

INSERT INTO [LP_Configuration].[BankCode] ([Code], [Name], [Description], [idCountry], [Active], [SubCode])
VALUES
('001', 'Banco de Chile','Banco de Chile', @idCountryChile,1,'')
,('009', 'Banco Internacional','Banco Internacional', @idCountryChile,1,'')
,('014', 'Scotiabank Chile','Scotiabank Chile', @idCountryChile,1,'')
,('016', 'Banco de crédito e inversiones (BCI)','Banco de crédito e inversiones (BCI)', @idCountryChile,1,'')
,('027', 'Banco Corpbanca','Banco Corpbanca', @idCountryChile,1,'')
,('028', 'Banco Bice','Banco Bice', @idCountryChile,1,'')
,('031', 'HSBC Bank Chile','HSBC Bank Chile', @idCountryChile,1,'')
,('037', 'Banco Santander Chile','Banco Santander Chile', @idCountryChile,1,'')
,('039', 'Itaú Corpbanca','Itaú Corpbanca', @idCountryChile,1,'')
,('049', 'Banco Security','Banco Security', @idCountryChile,1,'')
,('051', 'Banco Falabella','Banco Falabella', @idCountryChile,1,'')
,('053', 'Banco Ripley','Banco Ripley', @idCountryChile,1,'')
,('054', 'Rabobank Chile','Rabobank Chile', @idCountryChile,1,'')
,('055', 'Banco Consorcio','Banco Consorcio', @idCountryChile,1,'')
,('056', 'Banco Penta','Banco Penta', @idCountryChile,1,'')
,('057', 'Banco Paris','Banco Paris', @idCountryChile,1,'')
,('504', 'Banco Bilbao Vizcaya Argentaria Chile (BBVA)','Banco Bilbao Vizcaya Argentaria Chile (BBVA)', @idCountryChile,1,'')
,('059', 'Banco BTG Pactual Chile','Banco BTG Pactual Chile', @idCountryChile,1,'')

COMMIT