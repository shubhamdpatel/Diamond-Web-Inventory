using DiamondWebInventory.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DiamondWebInventory.Controllers
{
    public class HomeController : Controller
    {
        AppDataContext db = new AppDataContext();
        public ActionResult Index()
        {
            ViewBag.Title = "Home Page";

            return base.View();
        }
        public ActionResult Aboutus()
        {
            ViewBag.Title = "About Us";

            return View();
        }
        public ActionResult ContactUs()
        {
            ViewBag.Title = "Contact Us";

            return View();
        }
        [HttpPost]
        public JsonResult SendMessage(ConactModel reqConactModel)/*Send Message By User from ContactUs Form*/
        {
            string Name = reqConactModel.Name;
            string Email = reqConactModel.Email;
            string CSubject = reqConactModel.Subject;
            string YourMessage = reqConactModel.YourMessage;

            string retVal = "", retValMsg = "";
            //ConactModel objClientpsMassModel = db.getPassword(reqConactModel);
            if (reqConactModel != null)
            {
                //Password = objClientpsMassModel.Password;
                retVal = "Success";
                retValMsg = "";
            }
            else
            {
                retVal = "Failed";
                retValMsg = "Invalid Email";
            }

            if (retVal == "Success")
            {
                string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                string Admin = (ConfigurationManager.AppSettings.Get("FromEmail"));
                string Subject = "New Contact - " + CompanyName;
                string strbody = "<h2>Contact Details :</h2><br>Name : " + Name + "<br>Email Id : " + Email + "<br>Subject : " + CSubject + "<br>Message : " + YourMessage;
                string ToEmail = Admin;

                string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                CommonMethod.MailSend(ToEmail, Subject, strbody, false, true, true);
            }
            else
            {

            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, reqConactModel }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Blog()
        {
            ViewBag.Title = "Blog";
            return View();
        }
        public ActionResult Product()
        {
            ViewBag.Title = "Product";
            return View();
        }
        public ActionResult WizardRegistration()
        {
            ViewBag.Title = "Reg";
            return View();
        }


        #region Login
        public ActionResult Registration()
        {
            return base.View();
        }
        public ActionResult EditUserData(int ClientCd)
        {
            ClientMasterModel objClientMasterModel = new ClientMasterModel();
            List<ClientMasterModel> lstClientMasterModel = new List<ClientMasterModel>();
            List<ddlmodel> lstddlmodel = new List<ddlmodel>();
            lstddlmodel.Add(new ddlmodel { Name = "Mr.", val = "Mr." });
            lstddlmodel.Add(new ddlmodel { Name = "Mrs.", val = "Mrs." });
            lstddlmodel.Add(new ddlmodel { Name = "Miss.", val = "Miss." });
            ViewBag.TitleList = lstddlmodel;
            List<ddlmodel> lstBussinessTypeList = new List<ddlmodel>();
            lstBussinessTypeList.Add(new ddlmodel { Name = "WHOLESELLER", val = "WHOLESELLER" });
            lstBussinessTypeList.Add(new ddlmodel { Name = "MANUFACTURER", val = "MANUFACTURER" });
            lstBussinessTypeList.Add(new ddlmodel { Name = "RETAILER", val = "RETAILER" });
            lstBussinessTypeList.Add(new ddlmodel { Name = "OTHER", val = "OTHER" });
            ViewBag.BussinessTypeList = lstBussinessTypeList;
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = " AND ClientCd='" + ClientCd + "' ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;  
            reqRequestParam.pageno = 1;
            lstClientMasterModel = db.getClientMasterList(reqRequestParam);
            objClientMasterModel = lstClientMasterModel[0];
            return View(objClientMasterModel);

        }
        public JsonResult GetClientData(ClientMasterModel reqClientMasterModel)
        {
            List<ClientMasterModel> lstClientMasterModel = new List<ClientMasterModel>();
            RequestParam reqRequestParam = new RequestParam();
            var ClientCd = Session["ClientCd"];
            reqRequestParam.whereClause = " AND ClientCd=" + ClientCd + " ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstClientMasterModel = db.getClientMasterList(reqRequestParam);
            return Json(new { lstClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult SaveClientMasterModel(ClientMasterModel reqClientMasterModel)
        {

            if (reqClientMasterModel.ClientCd != null && reqClientMasterModel.ClientCd != 0)
            {
                reqClientMasterModel.Title = reqClientMasterModel.Title;
                reqClientMasterModel.FirstName = reqClientMasterModel.FirstName;
                reqClientMasterModel.LastName = reqClientMasterModel.LastName;
                reqClientMasterModel.BussinessType = reqClientMasterModel.BussinessType;
                reqClientMasterModel.CompanyNm = reqClientMasterModel.CompanyNm;
                reqClientMasterModel.Designation = reqClientMasterModel.Designation;
                reqClientMasterModel.ReferenceThrough = reqClientMasterModel.ReferenceThrough;
                reqClientMasterModel.Birthdate = reqClientMasterModel.Birthdate;
                reqClientMasterModel.Address = reqClientMasterModel.Address;
                reqClientMasterModel.City = reqClientMasterModel.City;
                reqClientMasterModel.State = reqClientMasterModel.State;
                reqClientMasterModel.Zipcode = reqClientMasterModel.Zipcode;
                reqClientMasterModel.Phone_No = reqClientMasterModel.Phone_No;
                reqClientMasterModel.Mobile_No = reqClientMasterModel.Mobile_No;
                reqClientMasterModel.Website = reqClientMasterModel.Website;
                reqClientMasterModel.IsDeleted = false;
                reqClientMasterModel.UpdatedDate = DateTime.Now;
                db.CrudClientMasterModel(reqClientMasterModel, "EditProfile");
            }
            else
            {
                //string Status = "No";
                //ClientMasterModel objClientMasterModel = new ClientMasterModel();
                //objClientMasterModel.EmailID1 = reqClientMasterModel.EmailID1;
                //objClientMasterModel.Password = reqClientMasterModel.Password;
                //objClientMasterModel.Title = reqClientMasterModel.Title;
                //objClientMasterModel.FirstName = reqClientMasterModel.FirstName;
                //objClientMasterModel.LastName = reqClientMasterModel.LastName;
                //objClientMasterModel.LastLoginDate = reqClientMasterModel.LastLoginDate;
                //objClientMasterModel.BussinessType = reqClientMasterModel.BussinessType;
                //objClientMasterModel.CompanyNm = reqClientMasterModel.CompanyNm;
                //objClientMasterModel.Designation = reqClientMasterModel.Designation;
                //objClientMasterModel.ReferenceThrough = reqClientMasterModel.ReferenceThrough;
                //objClientMasterModel.Birthdate = reqClientMasterModel.Birthdate;
                //objClientMasterModel.Address = reqClientMasterModel.Address;
                //objClientMasterModel.City = reqClientMasterModel.City;
                //objClientMasterModel.State = reqClientMasterModel.State;
                //objClientMasterModel.Zipcode = reqClientMasterModel.Zipcode;
                //objClientMasterModel.Phone_No = reqClientMasterModel.Phone_No;
                //objClientMasterModel.Mobile_No = reqClientMasterModel.Mobile_No;
                //objClientMasterModel.Website = reqClientMasterModel.Website;
                //objClientMasterModel.Status = Status;
                //objClientMasterModel.IsDeleted = false;
                //objClientMasterModel.InsertedDate = DateTime.Now;
                //db.CrudClientMasterModel(objClientMasterModel, "INSERT");

            }
            return Json(new { reqClientMasterModel }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Login()
        {
            return View();
        }
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("index");
        }
        public JsonResult LoginData(ClientMasterModel reqClientMasterModel)
        {
            string retVal = "", retValMsg = "";
            ClientMasterModel objClientMasterModel = db.getLoginData(reqClientMasterModel);

            if (objClientMasterModel != null)
            {
                string status = objClientMasterModel.Status;
                if (status == "Yes")
                {
                    Session["EmailID1"] = objClientMasterModel.EmailID1.ToString();
                    Session["Password"] = objClientMasterModel.Password.ToString();
                    Session["LoginName"] = objClientMasterModel.LoginName;
                    Session["ClientCd"] = objClientMasterModel.ClientCd;
                    retVal = "Success";
                    retValMsg = "";
                }
                else
                {
                    retVal = "Failed";
                    retValMsg = "Your are not approval, Please contact to administrator";
                }
            }
            else
            {
                retVal = "Failed";
                retValMsg = "Invalid Email Or Password";
            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, objClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetPassword(ClientMasterModel reqClientMassModel)
        {
            string Password = string.Empty;
            string Username = string.Empty;
            string retVal = "", retValMsg = "";
            ClientMasterModel objClientpsMassModel = db.getPassword(reqClientMassModel);
            if (objClientpsMassModel != null)
            {
                Password = objClientpsMassModel.Password;
                retVal = "Success";
                retValMsg = "";
            }
            else
            {
                retVal = "Failed";
                retValMsg = "Invalid Email";
            }

            if (!string.IsNullOrEmpty(Password))
            {
                string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                string Subject = CompanyName;
                string strbody = "Hi User, You Are Password Is " + Password;
                string ToEmail = (objClientpsMassModel.EmailID1);

                string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                CommonMethod.MailSend(ToEmail, Subject, strbody, false, true, true);
            }
            else
            {

            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, objClientpsMassModel }, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region Inventory
        public ActionResult LiveInventory()
        {
            if (Session["EmailID1"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Login");
            }
        }
        public JsonResult GetCrietariaData(ProcmasModel reqProcmasModel)
        {
            List<ProcmasModel> lstProcmasModel = new List<ProcmasModel>();
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = "And IsActive = " + 1 + "";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 100;
            reqRequestParam.pageno = 1;
            lstProcmasModel = db.getProcmasList(reqRequestParam);
            return Json(new { lstProcmasModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetInventoryData(StoneListModel reqProductModel)
        {
            List<StoneListModel> lstInventoryModel = new List<StoneListModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqProductModel.SHAPE))
            {
                whereClause = " AND SHAPE IN( '" + reqProductModel.SHAPE.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CERTIFICATE))
            {

                whereClause = whereClause + " AND CERTIFICATE IN( '" + reqProductModel.CERTIFICATE.Replace(",", "',\'") + "' )";
            }
            if (reqProductModel.FromCTS != null && reqProductModel.ToCTS != null)
            {
                whereClause = whereClause + "And CTS BETWEEN'" + reqProductModel.FromCTS + "' AND '" + reqProductModel.ToCTS + "'";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CUT))
            {
                whereClause = whereClause + " AND CUT IN( '" + reqProductModel.CUT.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.POLISH))
            {
                whereClause = whereClause + " AND POLISH IN( '" + reqProductModel.POLISH.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.SYM))
            {
                whereClause = whereClause + " AND SYM IN( '" + reqProductModel.SYM.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.COLOR))
            {
                whereClause = whereClause + " AND COLOR IN( '" + reqProductModel.COLOR.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CLARITY))
            {
                whereClause = whereClause + " AND CLARITY IN( '" + reqProductModel.CLARITY.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.FLOURENCE))
            {
                whereClause = whereClause + " AND FLOURENCE IN( '" + reqProductModel.FLOURENCE.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.FL_COLOR))
            {
                whereClause = whereClause + " AND FL_COLOR IN( '" + reqProductModel.FL_COLOR.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.LOCATION))
            {
                whereClause = whereClause + " AND LOCATION IN( '" + reqProductModel.LOCATION.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.HA))
            {
                whereClause = whereClause + " AND HA IN( '" + reqProductModel.HA.Replace(",", "',\'") + "' )";
            }
            if (!string.IsNullOrEmpty(reqProductModel.STONEID))
            {
                whereClause = whereClause + "And UPPER(STONEID)=UPPER('" + reqProductModel.STONEID + "') ";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CERTNO))
            {
                whereClause = whereClause + " AND UPPER(CERTNO)=UPPER('" + reqProductModel.CERTNO + "')";
            }
            if (reqProductModel.FromPrice != null && reqProductModel.ToPrice != null)
            {
                whereClause = whereClause + "And RAPARATE BETWEEN '" + reqProductModel.FromPrice + "' AND '" + reqProductModel.ToPrice + "'";
            }
            if (reqProductModel.FromAmt != null && reqProductModel.ToAmt != null)
            {
                whereClause = whereClause + "And COSTAMT_FC BETWEEN '" + reqProductModel.FromAmt + "' AND '" + reqProductModel.ToAmt + "'";
            }
            if (reqProductModel.FromDisc != null && reqProductModel.ToDisc != null)
            {
                whereClause = whereClause + "And COSTDISC_FC BETWEEN'" + reqProductModel.FromDisc + "' AND '" + reqProductModel.ToDisc + "'";
            }
            if (reqProductModel.LEGEND1 != null)
            {
                whereClause = whereClause + "And UPPER(LEGEND1)=UPPER('" + reqProductModel.LEGEND1 + "') ";
            }
            if (reqProductModel.LEGEND3 != null)
            {
                whereClause = whereClause + "And UPPER(LEGEND3)=UPPER('" + reqProductModel.LEGEND3 + "') ";
            }
            int Pageno = 1;
            if (reqProductModel.pageno > 1)
            {
                Pageno = reqProductModel.pageno;
            }
            //int Pagesize = 10;
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 1000;
            reqRequestParam.pageno = Pageno;
            //reqRequestParam.SC_Status = "B";
            //reqRequestParam.SC_CUR_STATUS = "I";
            lstInventoryModel = db.getStoneList(reqRequestParam);

            //var paggedData = Pagination.PagedResult(lstInventoryModel,Pageno, Pagesize);
            return Json(new { lstInventoryModel }, JsonRequestBehavior.AllowGet);
            //return PartialView(lstInventoryModel);
        }
        [HttpGet]
        public ActionResult DiamondDetails(string STONEID)
        {
            StoneListModel objInventoryModel = new StoneListModel();
            List<StoneListModel> lstProductModel = new List<StoneListModel>();
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = " AND STONEID='" + STONEID + "' ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstProductModel = db.getStoneList(reqRequestParam);
            objInventoryModel = lstProductModel[0];
            return View(objInventoryModel);
        }
        //public ActionResult ExportToExcel()
        //{
        //    StoneListModel ObjProjectModel = new StoneListModel();

        //    RequestParam reqRequestParam = new RequestParam();
        //    reqRequestParam.whereClause = "";
        //    reqRequestParam.orderByClause = "";
        //    reqRequestParam.PageSize = 1000;
        //    reqRequestParam.pageno = 1;
        //    DataTable dt = AppDataContext.getInventoryListData(reqRequestParam);

        //    var grid = new GridView();
        //    grid.DataSource = dt;
        //    grid.DataBind();
        //    grid.HeaderRow.Style.Add("background-color", "#FFFFFF");
        //    foreach (TableCell TableCell in grid.HeaderRow.Cells)
        //    {
        //        TableCell.Style["background-color"] = "#8EBAFF";
        //    }
        //    //foreach(GridViewRow GridRow in grid.Rows)
        //    //{
        //    //    GridRow.BackColor = System.Drawing.Color.White;
        //    //    foreach (TableCell GridTableCell in GridRow.Cells)
        //    //    {
        //    //        GridTableCell.Style["background-color"] = "#8EBAFF";
        //    //    }
        //    //}
        //    // grid.HeaderStyle.BackColor = System.Drawing.Color.Blue;
        //    //grid.BackColor = System.Drawing.Color.Yellow; //<--- Set Background Color Of all Excel seet --->

        //    Response.ClearContent();
        //    Response.Buffer = true;
        //    Response.AddHeader("content-disposition", "attachment; filename=InventoryData.xls");
        //    Response.ContentType = "application/ms-excel";

        //    Response.Charset = "";
        //    StringWriter sw = new StringWriter();
        //    HtmlTextWriter htw = new HtmlTextWriter(sw);

        //    grid.RenderControl(htw);

        //    Response.Output.Write(sw.ToString());
        //    Response.Flush();
        //    Response.End();

        //    return View("MyView");
        //}
        #endregion

        #region Cart & Buy
        public ActionResult CartPage()
        {
            return View();
        }
        public JsonResult GetCartdataList(ShoppingCartModel reqShoppingCart)
        {
            List<ShoppingCartModel> lstShoppingCart = new List<ShoppingCartModel>();
            RequestParam reqRequestParam = new RequestParam();
            var SC_Clientcd = Session["ClientCd"];
            string whereClause = string.Empty;
            if (SC_Clientcd != null)
            {
                whereClause = " AND SC_Clientcd = '" + SC_Clientcd + "' ";
            }
            if (reqShoppingCart.SC_Status != null)
            {
                whereClause = whereClause + " AND SC_Status = '" + reqShoppingCart.SC_Status + "' ";
            }
            if (reqShoppingCart.SC_CUR_STATUS != null)
            {
                whereClause = whereClause + " AND SC_CUR_STATUS = '" + reqShoppingCart.SC_CUR_STATUS + "' ";
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstShoppingCart = db.getShoppingCartList(reqRequestParam);
            return Json(new { lstShoppingCart }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public ActionResult AddToCartBuy(ShoppingCartModel reqShoppingCart, string Flag)
        {
            string retVal = "", retValMsg = "";
            ShoppingCartModel objShoppingCart = new ShoppingCartModel();

            var SC_Clientcd = Session["ClientCd"];
            var stoneid = reqShoppingCart.SC_stoneid;
            string[] SC_stoneid = stoneid.Split(',');//string[] SC_stoneid=['A0001','A0002','A0003']
            for (int i = 0; i < SC_stoneid.Length; i++)
            {
                retVal = "";
                if (string.IsNullOrEmpty(retVal))
                {
                    objShoppingCart.SC_stoneid = SC_stoneid[i];
                    objShoppingCart.SC_Clientcd = Convert.ToInt32(SC_Clientcd);
                    retVal = db.CrudShopingCart(objShoppingCart, Flag);
                }
                if (retVal == "-1")
                {
                    retValMsg = "This stone is alreday in your cart";
                    break;
                }
                else if (retVal == "1")
                {
                    retValMsg = "Add into cart, Please check it ?";
                }
                else if (retVal == "0")
                {
                    retValMsg = "Out Of Stock ?";
                }
                else if (retVal == "2")
                {
                    retValMsg = "Add into Buy, Please check it ?";
                }
            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, reqShoppingCart }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult DeleteToCartBuy(ShoppingCartModel reqShoppingCart, string Flag)
        {
            string retVal = "";
            ShoppingCartModel objShoppingCart = new ShoppingCartModel();

            var SC_Clientcd = Session["ClientCd"];
            //var SC_Clientcd = Session["ClientCd"];
            var stoneid = reqShoppingCart.SC_stoneid;
            string[] SC_stoneid = stoneid.Split(',');
            for (int i = 0; i < SC_stoneid.Length; i++)
            {
                retVal = "";
                if (string.IsNullOrEmpty(retVal))
                {
                    objShoppingCart.SC_stoneid = SC_stoneid[i];
                    objShoppingCart.SC_Clientcd = Convert.ToInt32(SC_Clientcd);
                    retVal = db.CrudShopingCart(objShoppingCart, Flag);
                }
            }
            //    if (reqShoppingCart.SC_stoneid != null)
            //{
            //    reqShoppingCart.SC_Clientcd = Convert.ToInt32(SC_Clientcd);
            //    retVal = db.CrudShopingCart(reqShoppingCart, Flag);
            //}
            return Json(new { reqShoppingCart, retVal = retVal }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult BuyPage()
        {
            return View();
        }
        public JsonResult GetBuydataList(ShoppingCartModel reqShoppingCart)
        {
            List<ShoppingCartModel> lstBuyShoppingCart = new List<ShoppingCartModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            var SC_Clientcd = Session["ClientCd"];
            if (SC_Clientcd != null)
            {
                whereClause = " AND SC_Clientcd = '" + SC_Clientcd + "' ";
            }
            if (reqShoppingCart.SC_CUR_STATUS != null)
            {
                whereClause = whereClause + " AND SC_CUR_STATUS = '" + reqShoppingCart.SC_CUR_STATUS + "' ";
            }
            if (reqShoppingCart.SC_Status != null)
            {
                whereClause = whereClause + " AND SC_Status = '" + reqShoppingCart.SC_Status + "' ";
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstBuyShoppingCart = db.getShoppingCartList(reqRequestParam);
            return Json(new { lstBuyShoppingCart }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult AddToBuy(ShoppingCartModel reqShoppingCart)
        {
            if (reqShoppingCart.SC_stoneid != null)
            {
                db.CrudShopingCart(reqShoppingCart, "BUY");
            }
            return Json(new { reqShoppingCart }, JsonRequestBehavior.AllowGet);

        }
        public JsonResult ConfirmMessage(ClientMasterModel reqClientMassModel)
        {
            string retVal = "", retValMsg = "";
            if (reqClientMassModel.EmailID1 != null)
            {
                retVal = "Success";
                retValMsg = "";
            }
            else
            {
                retVal = "Failed";
                retValMsg = "Invalid Email";
            }

            if (retVal == "Success")
            {
                string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                //string bccEmail = (ConfigurationManager.AppSettings.Get("bccEmail"));
                string Subject = CompanyName;
                string strbody = "Thank You For Buying Stone.";
                string ToEmail = (reqClientMassModel.EmailID1);
                //string BccEmail = bccEmail;

                string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                CommonMethod.MailSend(ToEmail, Subject, strbody, true, true, false);
            }
            else
            {

            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, reqClientMassModel }, JsonRequestBehavior.AllowGet);
        }
        #endregion
    }
}

