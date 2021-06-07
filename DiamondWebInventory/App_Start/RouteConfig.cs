using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace DiamondWebInventory
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "DiamondDetails",
                url: "Home/DiamondDetails/{STONEID}",
                defaults: new { controller = "Home", action = "DiamondDetails", STONEID = UrlParameter.Optional }
            );
            routes.MapRoute(
                name: "EditUserData",
                url: "Home/EditUserData/{ClientCd}",
                defaults: new { controller = "Home", action = "EditUserData", ClientCd = UrlParameter.Optional }
            );
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
           // routes.MapRoute(
           //    name: "Default",
           //    url: "{controller}/{action}/{id}",
           //    defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
           //);
        }
    }
}
