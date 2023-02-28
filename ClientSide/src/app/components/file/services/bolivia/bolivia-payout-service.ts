export class BoliviaService {
    providers = {
    'BGBOL': function (datos, idLotOut, provider) {
        if (datos.Status && datos.ExcelRows > 0) {
            this.downloadStatus = "OK";
            let PayoutFilesCount = 1;
            let fileTotal = 1;
            let fileRows = datos.ExcelRows;
        let filename = 'PO_' + provider + '_' + idLotOut + '_' + new Date(Date.now()).toISOString().replace(/-|T.*/g, '') + idLotOut + '.xls';

            PayoutFilesCount++;

        var a = document.createElement('a');
        a.href = "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," + datos.FileBase64_ExcelFileOut;
        a.download = filename;
        a.click();
          }
    },
    'ES_UN_EJEMPLO': function (datos, idLotOut) {
        if (datos.Status && datos.ExcelRows > 0) {
            this.downloadStatus = "OK";
            let PayoutFilesCount = 1;
            let fileTotal = 1;
            let fileRows = datos.ExcelRows;

        // RESOLVE
            PayoutFilesCount++;
          }
    },
  };

  public ProcessPayout(provider, datos, idLotOut): void {
    this.providers[provider](datos, idLotOut, provider);
  }
}