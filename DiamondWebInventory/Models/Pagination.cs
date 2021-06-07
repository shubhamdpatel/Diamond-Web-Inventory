using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static DiamondWebInventory.Models.Helper;

namespace DiamondWebInventory.Models
{
    public static class Pagination
    {
        public static PagedData<T> PagedResult<T>(this List<T> list, int Pageno, int Pagesize) where T : class
        {
            var result = new PagedData<T>();
            result.Data = list.Skip(Pagesize * (Pageno - 1)).Take(Pagesize).ToList();
            result.TotalPages = Convert.ToInt32(Math.Ceiling((double)list.Count() / Pagesize));
            result.CurrentPage = Pageno;
            return result;
        }
    }
}