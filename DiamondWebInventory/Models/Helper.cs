using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;

namespace DiamondWebInventory.Models
{
    public static class Helper
    {
        /// <summary>
        /// Handle the Database NULL Value for the Sql Value
        /// </summary>
        /// <param name="requestValue">object which may have DBNUll</param> 
        public static object handleDBNull(this object requestValue)
        {
            if (requestValue == null)
            {
                return DBNull.Value;
            }
            return requestValue;

        }
        public static object handleDBNullDate(this string requestValue)
        {
            if (string.IsNullOrEmpty(requestValue))
            {
                return SqlDateTime.Null;
            }
            else
            {
                requestValue = Convert.ToDateTime(requestValue).ToString("yyyy-MM-dd");
            }
            return requestValue;
        }
        /// <summary>
        /// Generate SQL Statement from all it's parameter and procedure name
        /// </summary>
        /// <param name="spName">Database procedure name</param>
        /// <param name="requestParameters">List of Sql Parameters</param>
        public static string getSql(this string spName, List<SqlParameter> requestParameters = null)
        {
            string SpParameter = string.Empty;
            if (requestParameters != null)
            {
                for (int Index = 0; Index < requestParameters.Count; Index++)
                {
                    if (Index > 0)
                    {
                        SpParameter += ", @" + requestParameters[Index].ParameterName;
                    }
                    else
                    {
                        SpParameter += " @" + requestParameters[Index].ParameterName;
                    }
                    if (requestParameters[Index].Direction == System.Data.ParameterDirection.Output)
                    {
                        SpParameter += " OUT ";
                    }
                }
            }
            string EXECString = "EXEC [" + spName + "]" + SpParameter;
            return EXECString;
        }

        public class PagedData<T> where T : class
        {
            public IEnumerable<T> Data { get; set; }
            public int TotalPages { get; set; }
            public int CurrentPage { get; set; }
        }
    }
}