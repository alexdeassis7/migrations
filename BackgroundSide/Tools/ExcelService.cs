namespace Tools
{
    using Aspose.Cells;
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.IO;
    using System.Threading.Tasks;

    namespace LocalPayment.Tools
    {
        public sealed class ExcelService
        {
            public ExcelService() => SetupLicence();

            private void SetupLicence()
            {
                var cellsLicense = new License();
                var assemblyFolder = AppDomain.CurrentDomain.RelativeSearchPath;
                var licenceFilenamePath = Path.Combine(assemblyFolder, @"Aspose.Total.lic");
                var stream = new MemoryStream(System.IO.File.ReadAllBytes(licenceFilenamePath));
                cellsLicense.SetLicense(stream);
            }

            /// <summary>
            /// Export a given DataSet to a Excel File
            /// </summary>
            /// <param name="dataSet">DataSet object to export</param>
            /// <param name="folderNamePath">The path to the folder where the file will be stored.</param>
            /// <param name="fileName">The name of the file (if extension is not provided, will be defined as .xls)</param>
            /// <param name="formatCurrency">If parameter is true, the currency will be added on those fields where the type is numeric, otherwise no currency format will be set</param>
            /// <param name="overwrite">If parameter is true will remove a current existing file with same filename will be removed first, otherwise will not be verified (default behavior for legacy support)</param>
            public void Export(DataSet dataSet, string folderNamePath, string fileName, bool formatCurrency = false, bool overwrite = false)
            {
                var finalPath = folderNamePath + "\\" + fileName;

                var wb = new Workbook();

                if (overwrite && System.IO.File.Exists(finalPath))
                {
                    System.IO.File.Delete(finalPath);
                }

                var intSheet = 0;

                foreach (DataTable dt in dataSet.Tables)
                {
                    wb.Worksheets.Add();
                    var sheet = wb.Worksheets[intSheet];

                    var styleDate = wb.CreateStyle();

                    //Number 14 means Date format
                    styleDate.Number = 14;

                    var styleNumber = wb.CreateStyle();
                    styleNumber.Number = 1;

                    var styleDecimal = wb.CreateStyle();
                    styleDecimal.Number = 2;

                    if (formatCurrency)
                    {
                        styleDecimal.Number = 7;
                    }

                    var flagSpecial = new StyleFlag
                    {
                        NumberFormat = true
                    };

                    var intRow = 0;
                    var intCol = 0;

                    #region Titles
                    foreach (DataColumn column in dt.Columns)
                    {
                        var subtitleStyle = sheet.Cells[intRow, intCol].GetStyle();
                        subtitleStyle.Font.Name = "Arial";
                        subtitleStyle.Font.Size = 10;
                        subtitleStyle.Font.IsBold = true;

                        subtitleStyle.HorizontalAlignment = TextAlignmentType.Center;
                        subtitleStyle.Borders[BorderType.BottomBorder].LineStyle = CellBorderType.Medium;
                        subtitleStyle.Borders[BorderType.TopBorder].LineStyle = CellBorderType.Medium;

                        sheet.Cells[intRow, intCol].PutValue(column.ColumnName);
                        sheet.Cells[intRow, intCol].SetStyle(subtitleStyle);

                        if (column.DataType == typeof(DateTime))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDate, flagSpecial);
                        }
                        else if (column.DataType == typeof(decimal))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDecimal, flagSpecial);
                        }

                        intCol++;
                    }
                    #endregion
                    intRow++;

                    foreach (DataRow row in dt.Rows)
                    {
                        intCol = 0;
                        foreach (DataColumn column in dt.Columns)
                        {
                            sheet.Cells[intRow, intCol].PutValue(row[column]);

                            intCol++;
                        }
                        intRow++;
                    }

                    sheet.AutoFitColumns();
                    sheet.AutoFitRows();

                    intSheet++;
                }

                wb.Save(finalPath, SaveFormat.Xlsx);
            }

            public async Task<byte[]> ExportToByteArray(DataSet dataSet, string[] worksheetNames, bool formatCurrency = false)
            {
                var wb = new Workbook();

                var intSheet = 0;

                foreach (DataTable dt in dataSet.Tables)
                {
                    wb.Worksheets.Add();
                    var sheet = wb.Worksheets[intSheet];

                    if (worksheetNames != null && worksheetNames[intSheet] != null && !string.IsNullOrWhiteSpace(worksheetNames[intSheet]))
                        sheet.Name = worksheetNames[intSheet];

                    var styleDate = wb.CreateStyle();

                    //Number 14 means Date format
                    styleDate.Number = 14;

                    var styleNumber = wb.CreateStyle();
                    styleNumber.Number = 1;

                    var styleDecimal = wb.CreateStyle();
                    styleDecimal.Number = 2;

                    if (formatCurrency)
                    {
                        styleDecimal.Number = 2;
                    }

                    var flagSpecial = new StyleFlag
                    {
                        NumberFormat = true
                    };

                    var intRow = 0;
                    var intCol = 0;

                    #region Titles
                    foreach (DataColumn column in dt.Columns)
                    {
                        var subtitleStyle = sheet.Cells[intRow, intCol].GetStyle();
                        subtitleStyle.Font.Name = "Arial";
                        subtitleStyle.Font.Size = 10;
                        subtitleStyle.Font.IsBold = true;

                        //subtitleStyle.HorizontalAlignment = TextAlignmentType.Center;
                        //subtitleStyle.Borders[BorderType.BottomBorder].LineStyle = CellBorderType.Medium;
                        //subtitleStyle.Borders[BorderType.TopBorder].LineStyle = CellBorderType.Medium;

                        if (column.DataType == typeof(DateTime))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDate, flagSpecial);
                        }
                        else if (column.DataType == typeof(decimal))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDecimal, flagSpecial);
                        }

                        sheet.Cells[intRow, intCol].PutValue(column.ColumnName);
                        sheet.Cells[intRow, intCol].SetStyle(subtitleStyle);


                        intCol++;
                    }
                    #endregion
                    intRow++;

                    foreach (DataRow row in dt.Rows)
                    {
                        intCol = 0;
                        foreach (DataColumn column in dt.Columns)
                        {
                            sheet.Cells[intRow, intCol].PutValue(row[column]);

                            intCol++;
                        }
                        intRow++;
                    }

                    sheet.AutoFitColumns();
                    sheet.AutoFitRows();
                    sheet.Cells.DeleteBlankRows();

                    intSheet++;
                }

                var memoryStream = wb.SaveToStream();

                var bytes = new byte[memoryStream.Length];
                memoryStream.Seek(0, SeekOrigin.Begin);
                await memoryStream.ReadAsync(bytes, 0, bytes.Length);
                memoryStream.Dispose();
                return bytes;
            }

            // TODO: Document this (Reason for not refactor now): Task out of the scope
            public void ExportTabs(DataSet ds, string path, string name, List<string> sheetNames = null)
            {
                var finalPath = path + "\\" + name;
                var wb = new Workbook();
                wb.Worksheets.RemoveAt(0);

                var styleDate = wb.CreateStyle();

                //Number 14 means Date format
                styleDate.Number = 14;

                var styleNumber = wb.CreateStyle();
                styleNumber.Number = 1;

                var styleDecimal = wb.CreateStyle();
                styleNumber.Number = 2;

                var flagSpecial = new StyleFlag
                {
                    NumberFormat = true
                };

                var dataTableCount = 0;

                foreach (DataTable dt in ds.Tables)
                {
                    var intRow = 0;
                    var intCol = 0;
                    Worksheet sheet;

                    if (sheetNames != null)
                    {
                        sheet = wb.Worksheets.Add(sheetNames[dataTableCount]);
                    }
                    else
                    {
                        var index = wb.Worksheets.Add();
                        sheet = wb.Worksheets[index];
                    }

                    #region Titles

                    foreach (DataColumn column in dt.Columns)
                    {
                        var subtitleStyle = sheet.Cells[intRow, intCol].GetStyle();
                        subtitleStyle.Font.Name = "Arial";
                        subtitleStyle.Font.Size = 10;
                        subtitleStyle.Font.IsBold = true;

                        subtitleStyle.HorizontalAlignment = TextAlignmentType.Center;
                        subtitleStyle.Borders[BorderType.BottomBorder].LineStyle = CellBorderType.Medium;
                        subtitleStyle.Borders[BorderType.TopBorder].LineStyle = CellBorderType.Medium;

                        sheet.Cells[intRow, intCol].PutValue(column.ColumnName);
                        sheet.Cells[intRow, intCol].SetStyle(subtitleStyle);

                        if (column.DataType == typeof(DateTime))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDate, flagSpecial);
                        }
                        else if (column.DataType == typeof(decimal))
                        {
                            sheet.Cells.Columns[intCol].ApplyStyle(styleDecimal, flagSpecial);
                        }

                        intCol++;
                    }
                    #endregion
                    intRow++;

                    foreach (DataRow row in dt.Rows)
                    {
                        intCol = 0;

                        foreach (DataColumn column in dt.Columns)
                        {
                            sheet.Cells[intRow, intCol].PutValue(row[column]);
                            intCol++;
                        }

                        intRow++;
                    }

                    sheet.AutoFitColumns();
                    sheet.AutoFitRows();
                    dataTableCount++;
                }

                wb.Save(finalPath, SaveFormat.Xlsx);
            }
        }
    }
}
