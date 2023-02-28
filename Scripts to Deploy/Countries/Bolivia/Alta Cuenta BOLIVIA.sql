
GO
DECLARE @return_value INT;
EXEC @return_value=[LP_Filter].[AddClientFull] 
@JSON='{"MerchantName":"LPBoliviaTest","SubMerchantName":"LPBoliviaTest","ApiPassword":"wxj890s_XNv9"
,"WebPassword":"Mario",
"Identification":"000002300001",
"Mail":"lp_bolivia@localpayment.com",
"FxPeriod":"1",
"Countries":["ARG","BRA","COL","CHL","ECU","PER","URY","MEX","PYG","BOB"],
"DataCountries":[
{"CountryName":"ARG","CountryDisplay":"Argentina","CurrencyAccount":"USD","CommisionValue":"0.5","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPARG"},
{"CountryName":"BRA","CountryDisplay":"Brasil","CurrencyAccount":"USD","CommisionValue":"0.5","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPBRA"},
{"CountryName":"COL","CountryDisplay":"Colombia","CurrencyAccount":"USD","CommisionValue":"1","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPCOL"},
{"CountryName":"CHL","CountryDisplay":"Chile","CurrencyAccount":"USD","CommisionValue":"1","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPCHL"},
{"CountryName":"ECU","CountryDisplay":"Ecuador","CurrencyAccount":"USD","CommisionValue":"2","CommissionCurrency":"USD","Spread":"0","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPECU"},
{"CountryName":"PER","CountryDisplay":"Peru","CurrencyAccount":"USD","CommisionValue":"1","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPPER"},
{"CountryName":"URY","CountryDisplay":"Uruguay","CurrencyAccount":"USD","CommisionValue":"2","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPURY"},
{"CountryName":"MEX","CountryDisplay":"Mexico","CurrencyAccount":"USD","CommisionValue":"0.5","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPMEX"},
{"CountryName":"PRY","CountryDisplay":"Paraguay","CurrencyAccount":"USD","CommisionValue":"0.5","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPPYG"}]
{"CountryName":"BOL","CountryDisplay":"Bolivia","CurrencyAccount":"USD","CommisionValue":"0.5","CommissionCurrency":"USD","Spread":"2","AfipRetention":"0","ArbaRetention":"0","LocalTax":"%","Alias":"LPCOINPBOB"}]
}';

SELECT 'Return Value'=@return_value;
GO