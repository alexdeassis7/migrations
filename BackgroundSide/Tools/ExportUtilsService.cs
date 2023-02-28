using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;

using Newtonsoft.Json;

using Tools.Dto;
using Tools.LocalPayment.Tools;

namespace Tools
{
    public class ExportUtilsService
    {
        private readonly ExcelService _excelService;
        private readonly DataService _dataService;
        public ExportUtilsService()
        {
            _dataService = new DataService();
            _excelService = new ExcelService();
        }

        public string ExportarListado(string path, Export ex, bool formatCurrency = false)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            var spOrViewName = !ex.IsSP ? $"vw{ex.Name}" : ex.Name;
            ex.Name = spOrViewName;

            var dataSet = _dataService.GetData(ex);
            var fileName = $"{(!string.IsNullOrEmpty(ex.FileName) ? ex.FileName : ex.Name)}.xlsx";

            _excelService.Export(dataSet, path, fileName, formatCurrency);

            var absolutePath = Path.Combine(path, fileName);

            var docBytes = System.IO.File.ReadAllBytes(absolutePath);

            var excelBase64 = Convert.ToBase64String(docBytes);
            return excelBase64;
        }

        public ListadoGenericDto GetListado(Export ex)
        {
            var result = new ListadoGenericDto();

            var spOrViewName = !ex.IsSP ? $"vw{ex.Name}" : ex.Name;
            ex.Name = spOrViewName;

            var dataSet = _dataService.GetData(ex);

            if (dataSet.Tables.Count > 0)
            {
                foreach (DataColumn col in dataSet.Tables[0].Columns)
                {
                    result.Columns.Add(new ColumnTypeDto { Name = col.ColumnName, Type = col.DataType.Name });
                }

                result.TableData = JsonConvert.SerializeObject(dataSet, Formatting.Indented);
            }

            return result;
        }

        public string ExportarPath(string path, Export ex, List<string> sheetNames = null)
        {
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            var spOrViewName = !ex.IsSP ? $"vw{ex.Name}" : ex.Name;
            ex.Name = spOrViewName;

            var dataSet = _dataService.GetData(ex);
            var datasetIsEmpty = !dataSet.Tables.Cast<DataTable>().Any(x => x.DefaultView.Count > 0);
            var fileName = $"{(!string.IsNullOrEmpty(ex.FileName) ? ex.FileName : ex.Name)}.xlsx";

            _excelService.ExportTabs(dataSet, path, fileName, sheetNames);

            var absolutePath = Path.Combine(path, fileName);

            return datasetIsEmpty ? "0" : absolutePath;
        }
    }
}
