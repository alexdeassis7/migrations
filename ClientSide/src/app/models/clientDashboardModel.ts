
export class ClientDashboardData {

  CountryName             :string;
  CountryCode             :string;
  LastName                :string;
  CurrencyCode            :string;
  SaldoActual             :number;
  AmtInProgressPO         :number;
  cntInProgressPO         :number;
  AmtInProgressPI         :number;
  cntInProgressPI         :number;
  AmtReceived             :number;
  AmtOnHoldPO             :number;
  cntReceived             :number;
  cntOnHoldPO             :number;
  CommTaxesInProgressPI   :number;
  CommTaxesInProgressPO   :number;


  constructor(_listMain: any) {
    this.CountryName              =     _listMain.CountryName                     || null;
    this.CountryCode              =     _listMain.CountryCode                     || null;
    this.LastName                 =     _listMain.LastName                        || null;
    this.CurrencyCode             =     _listMain.CurrencyCode                    || null;
    this.SaldoActual              =     _listMain.SaldoActual                     || null;
    this.AmtInProgressPO          =     _listMain.AmtInProgressPO                 || null;
    this.cntInProgressPO          =     _listMain.cntInProgressPO                 || null;
    this.AmtInProgressPI          =     _listMain.AmtInProgressPI                 || null;
    this.cntInProgressPI          =     _listMain.cntInProgressPI                 || null;
    this.AmtReceived              =     _listMain.AmtReceived                     || null;
    this.AmtOnHoldPO              =     _listMain.AmtOnHoldPO                     || null;
    this.cntReceived              =     _listMain.cntReceived                     || null;
    this.cntOnHoldPO              =     _listMain.cntOnHoldPO                     || null;
    this.CommTaxesInProgressPI    =     _listMain.CommTaxesInProgressPI           || null;
    this.CommTaxesInProgressPO    =     _listMain.CommTaxesInProgressPO           || null;
  }
}
