using System;
using System.Collections.Generic;
using System.Data;

namespace Tools
{
    public static class ExcelExtension
    {
        public static DataSet ToDataSet<T>(this List<T> list)
        {
            try
            {
                var elementType = typeof(T);
                var ds = new DataSet();
                var t = new DataTable();
                ds.Tables.Add(t);

                //add a column to table for each public property on T
                foreach (var propInfo in elementType.GetProperties())
                {
                    var colType = Nullable.GetUnderlyingType(propInfo.PropertyType) ?? propInfo.PropertyType;
                    t.Columns.Add(propInfo.Name, colType);
                }

                //go through each property on T and add each value to the table
                foreach (var item in list)
                {
                    var row = t.NewRow();

                    foreach (var propInfo in elementType.GetProperties())
                    {
                        row[propInfo.Name] = propInfo.GetValue(item, null) ?? DBNull.Value;
                    }

                    t.Rows.Add(row);
                }

                return ds;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }
    }
}
