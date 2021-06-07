
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DiamondWebInventory.Models;
using System.Reflection;
using System.IO;
using static System.Net.WebRequestMethods;
using System.Configuration;
using System.Data.OleDb;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DiamondWebInventory.Controllers
{
    public class AdminController : Controller
    {
        AppDataContext db = new AppDataContext();
        // GET: Admin
        public ActionResult Index()
        {
            return View();
        }

        #region Admin
        [HttpGet]
        public ActionResult Dashboard()
        {
            if (Session["Email_Id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
        }
        [HttpPost]
        public JsonResult AdminLoginData(AdminModel reqAdminModel)
        {
            string retVal = "", retValMsg = "";
            AdminModel objAdminMassModel = db.getAdminLoginData(reqAdminModel);
            if (objAdminMassModel != null)
            {
                Session["Email_Id"] = objAdminMassModel.Email_Id.ToString();
                Session["Password"] = objAdminMassModel.Password.ToString();
                Session["Name"] = objAdminMassModel.Name.ToString();
                Session["User_Profile_Image"] = objAdminMassModel.User_Profile_Image.ToString();
                retVal = "Success";
                retValMsg = "";
            }
            else
            {
                retVal = "Failed";
                retValMsg = "Invalid Email Or Password";
            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, objAdminMassModel }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult LogOut()
        {
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index");
        }


        #endregion

        #region Banner
        public ActionResult Banner()
        {
            if (Session["Email_Id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
            //return View();
        }
        public ActionResult Demo_Banner()
        {
            return View();
        }
        [HttpPost]
        public JsonResult GetBannerData(BannerModel reqBannerModel)
        {
            List<BannerModel> lstBannerModel = new List<BannerModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqBannerModel.Title))
            {
                whereClause = " AND UPPER(Title)=UPPER('" + reqBannerModel.Title + "') ";
            }
            int pageno = 1;
            if (reqBannerModel.pageno > 1)
            {
                pageno = reqBannerModel.pageno;
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = pageno;
            lstBannerModel = db.getBannerList(reqRequestParam);
            return Json(new { lstBannerModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetBannerManageData(int? id)
        {
            BannerModel objBannerModel = new BannerModel();
            List<BannerModel> lstBannerModel = new List<BannerModel>();
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = " AND Id=" + id + " ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstBannerModel = db.getBannerList(reqRequestParam);
            objBannerModel = lstBannerModel[0];
            return Json(new { objBannerModel }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult SaveBanner(BannerModel reqBannerModel)
        {
            if (reqBannerModel.Id != null && reqBannerModel.Id != 0)
            {
                string fname = "";
                if (Request.Files.Count > 0)
                {
                    try
                    {
                        HttpFileCollectionBase files = Request.Files;
                        for (int i = 0; i < files.Count; i++)
                        {
                            HttpPostedFileBase file = files[i];

                            if (Request.Browser.Browser.ToUpper() == "IE" || Request.Browser.Browser.ToUpper() == "INTERNETEXPLORER")
                            {
                                string[] testfiles = file.FileName.Split(new char[] { '\\' });
                                fname = testfiles[testfiles.Length - 1];
                            }
                            else
                            {
                                fname = file.FileName;
                            }
                            var path = Path.Combine(Server.MapPath("~/UploadImage/"), fname);
                            file.SaveAs(path);
                        }
                    }
                    catch (Exception ex)
                    {
                        return Json("Error occurred. Error details: " + ex.Message);
                    }
                    //objBanner.ImageType = fname;
                    reqBannerModel.ImageType = fname;
                }
                else
                {
                    //return Json("No files selected.");
                }
                reqBannerModel.IsDeleted = false;
                reqBannerModel.UpdatedDate = DateTime.Now;
                db.CrudBanner(reqBannerModel, "UPDATE");
            }
            else
            {
                string Id = Request.Form["Id"];
                string Title = Request.Form["Title"];
                string ClickUrl = Request.Form["ClickUrl"];
                string IsActive = Request.Form["IsActive"];

                BannerModel objBanner = new BannerModel();
                string fname = "";
                if (Request.Files.Count > 0)
                {
                    try
                    {
                        HttpFileCollectionBase files = Request.Files;
                        for (int i = 0; i < files.Count; i++)
                        {
                            HttpPostedFileBase file = files[i];

                            if (Request.Browser.Browser.ToUpper() == "IE" || Request.Browser.Browser.ToUpper() == "INTERNETEXPLORER")
                            {
                                string[] testfiles = file.FileName.Split(new char[] { '\\' });
                                fname = testfiles[testfiles.Length - 1];
                            }
                            else
                            {
                                fname = file.FileName;
                            }
                            var path = Path.Combine(Server.MapPath("~/UploadImage/"), fname);
                            file.SaveAs(path);
                        }
                    }
                    catch (Exception ex)
                    {
                        return Json("Error occurred. Error details: " + ex.Message);
                    }
                    objBanner.ImageType = fname;
                }
                else
                {
                    return Json("No files selected.");
                }
                objBanner.Title = reqBannerModel.Title;
                objBanner.ClickUrl = reqBannerModel.ClickUrl;
                objBanner.IsActive = reqBannerModel.IsActive;
                db.CrudBanner(objBanner, "INSERT");
            }
            return Json(new { reqBannerModel }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult DeleteBanner(BannerModel reqDeleteBanner)
        {
            if (reqDeleteBanner.Id != null)
            {
                db.CrudBanner(reqDeleteBanner, "DELETE");
            }
            return Json(new { reqDeleteBanner }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Procmas
        public ActionResult Procmas()
        {
            if (Session["Email_Id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
        }
        public JsonResult GetProcmasData(ProcmasModel reqProcmasModel)
        {
            List<ProcmasModel> lstProcmasModel = new List<ProcmasModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqProcmasModel.Procgroup))
            {
                whereClause = " AND UPPER(Procgroup)=UPPER('" + reqProcmasModel.Procgroup + "') ";
            }
            if (!string.IsNullOrEmpty(reqProcmasModel.Procnm))
            {
                whereClause = whereClause + " AND UPPER(Procnm)=UPPER('" + reqProcmasModel.Procnm + "') ";
            }
            int pageno = 1;
            if (reqProcmasModel.pageno > 1)
            {
                pageno = reqProcmasModel.pageno;
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = pageno;
            lstProcmasModel = db.getProcmasList(reqRequestParam);
            return Json(new { lstProcmasModel }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult SaveProcmas(ProcmasModel reqProcmasModel)
        {
            if (reqProcmasModel.Id != null && reqProcmasModel.Id != 0)
            {
                reqProcmasModel.Proccd = Convert.ToDecimal(reqProcmasModel.Proccd);
                reqProcmasModel.Ord = Convert.ToDecimal(reqProcmasModel.Ord);
                reqProcmasModel.IsDeleted = false;
                reqProcmasModel.UpdatedDate = DateTime.Now;
                db.CrudProcmas(reqProcmasModel, "UPDATE");
            }
            else
            {
                ProcmasModel objProcmas = new ProcmasModel();
                objProcmas.Procgroup = reqProcmasModel.Procgroup;
                objProcmas.Proccd = Convert.ToDecimal(reqProcmasModel.Proccd);
                objProcmas.Procnm = reqProcmasModel.Procnm;
                objProcmas.Shortnm = reqProcmasModel.Shortnm;
                objProcmas.Ord = Convert.ToDecimal(reqProcmasModel.Ord);
                //objProcmas.Fancy_Color_Status = reqProcmasModel.Fancy_Color_Status;
                //objProcmas.IsChangeable = reqProcmasModel.IsChangeable;
                //objProcmas.Fancy_Color = reqProcmasModel.Fancy_Color;
                //objProcmas.Fancy_Intensity = reqProcmasModel.Fancy_Intensity;
                //objProcmas.Fancy_Overtone = reqProcmasModel.Fancy_Overtone;
                //objProcmas.F_CTS = reqProcmasModel.F_CTS;
                //objProcmas.T_CTS = reqProcmasModel.T_CTS;
                objProcmas.IsActive = reqProcmasModel.IsActive;
                //db.Students.Add(objStudent);
                //db.SaveChanges();
                db.CrudProcmas(objProcmas, "INSERT");

            }
            return Json(new { reqProcmasModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetProcmasManageData(int? id)
        {
            ProcmasModel objProcmasModel = new ProcmasModel();
            List<ProcmasModel> lstProcmasModel = new List<ProcmasModel>();
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = " AND Id=" + id + " ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstProcmasModel = db.getProcmasList(reqRequestParam);
            objProcmasModel = lstProcmasModel[0];
            return Json(new { objProcmasModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult DeleteProcmas(ProcmasModel reqProcmasModel)
        {
            if (reqProcmasModel.Id != null)
            {

                db.CrudProcmas(reqProcmasModel, "DELETE");

            }
            return Json(new { reqProcmasModel }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Client Master
        public ActionResult ClientMaster()
        {
            if (Session["Email_id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
        }
        public JsonResult GetClientMasterData(ClientMasterModel reqClientMasterModel)
        {
            List<ClientMasterModel> lstClientMasterModel = new List<ClientMasterModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqClientMasterModel.FirstName))
            {
                whereClause = " AND UPPER(FirstName)=UPPER('" + reqClientMasterModel.FirstName + "')";
            }
            if (!string.IsNullOrEmpty(reqClientMasterModel.EmailID1))
            {
                whereClause = whereClause + " AND UPPER(EmailID1)=UPPER('" + reqClientMasterModel.EmailID1 + "')";
            }
            if (!string.IsNullOrEmpty(reqClientMasterModel.Status))
            {
                whereClause = whereClause + " AND UPPER(Status)=UPPER('" + reqClientMasterModel.Status + "')";
            }
            int pageno = 1;
            if (reqClientMasterModel.pageno > 1)
            {
                pageno = reqClientMasterModel.pageno;
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = pageno;
            lstClientMasterModel = db.getClientMasterList(reqRequestParam);
            for (int i = 0; i < lstClientMasterModel.Count; i++)
            {
                lstClientMasterModel[i].strBirthdate = db.GetDateHandle(lstClientMasterModel[i].Birthdate);
                lstClientMasterModel[i].strInsertedDate = db.GetDateHandle(lstClientMasterModel[i].InsertedDate);
                lstClientMasterModel[i].strUpdatedDate = db.GetDateHandle(lstClientMasterModel[i].UpdatedDate);
                lstClientMasterModel[i].strApproveStatusOn = db.GetDateHandle(lstClientMasterModel[i].ApproveStatusOn);
                lstClientMasterModel[i].strStatusUpdatedOn = db.GetDateHandle(lstClientMasterModel[i].StatusUpdatedOn);
                lstClientMasterModel[i].strLastLoginDate = db.GetDateHandle(lstClientMasterModel[i].LastLoginDate);
                lstClientMasterModel[i].strEmailSubscrDate = db.GetDateHandle(lstClientMasterModel[i].EmailSubscrDate);
                lstClientMasterModel[i].strLoginMailAlertOn = db.GetDateHandle(lstClientMasterModel[i].LoginMailAlertOn);
            }
            return Json(new { lstClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult GetCLientMasterManageData(int? ClientCd)
        {
            ClientMasterModel objClientMasterModel = new ClientMasterModel();
            List<ClientMasterModel> lstClientMasterModel = new List<ClientMasterModel>();
            RequestParam reqRequestParam = new RequestParam();
            //var ClientCd=Session["ClientCd"];
            reqRequestParam.whereClause = " AND ClientCd=" + ClientCd + " ";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = 1;
            lstClientMasterModel = db.getClientMasterList(reqRequestParam);
            lstClientMasterModel[0].strBirthdate = db.GetDateHandle(lstClientMasterModel[0].Birthdate);
            objClientMasterModel = lstClientMasterModel[0];
            return Json(new { objClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult SaveClientMasterModel(ClientMasterModel reqClientMasterModel)
        {
            string retVal = "", retValMsg = "";
            if (reqClientMasterModel.ClientCd != null && reqClientMasterModel.ClientCd != 0)
            {
                reqClientMasterModel.Discount = Convert.ToDecimal(reqClientMasterModel.Discount);
                reqClientMasterModel.IsDeleted = false;
                reqClientMasterModel.UpdatedDate = DateTime.Now;
                db.CrudClientMasterModel(reqClientMasterModel, "UPDATE");

                if (reqClientMasterModel.Status == "Yes")
                {
                    if (reqClientMasterModel.EmailID1 != null)
                    {
                        string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                        string Subject = CompanyName;
                        string strbody = reqClientMasterModel.Title + " " + reqClientMasterModel.FirstName + " " + reqClientMasterModel.LastName + ", You are Eligibal for login<br>Click Here For <a href='http://localhost:55330/home/login'>Login</p>";
                        string ToEmail = reqClientMasterModel.EmailID1;

                        string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                        CommonMethod.MailSend(ToEmail, Subject, strbody, false, true, true);
                    }
                    else
                    {
                        //retVal = "Failed";
                        retValMsg = "Email Id Not Found!";
                    }
                }
            }
            else
            {
                string Status = "No";
                ClientMasterModel objClientMasterModel = new ClientMasterModel();
                objClientMasterModel.EmailID1 = reqClientMasterModel.EmailID1;
                objClientMasterModel.Password = reqClientMasterModel.Password;
                objClientMasterModel.Title = reqClientMasterModel.Title;
                objClientMasterModel.FirstName = reqClientMasterModel.FirstName;
                objClientMasterModel.LastName = reqClientMasterModel.LastName;
                objClientMasterModel.LastLoginDate = reqClientMasterModel.LastLoginDate;
                objClientMasterModel.BussinessType = reqClientMasterModel.BussinessType;
                objClientMasterModel.CompanyNm = reqClientMasterModel.CompanyNm;
                objClientMasterModel.Designation = reqClientMasterModel.Designation;
                objClientMasterModel.ReferenceThrough = reqClientMasterModel.ReferenceThrough;
                objClientMasterModel.Birthdate = reqClientMasterModel.Birthdate;
                objClientMasterModel.Address = reqClientMasterModel.Address;
                objClientMasterModel.City = reqClientMasterModel.City;
                objClientMasterModel.State = reqClientMasterModel.State;
                objClientMasterModel.Zipcode = reqClientMasterModel.Zipcode;
                objClientMasterModel.Phone_No = reqClientMasterModel.Phone_No;
                objClientMasterModel.Mobile_No = reqClientMasterModel.Mobile_No;
                objClientMasterModel.Website = reqClientMasterModel.Website;
                objClientMasterModel.Status = Status;
                objClientMasterModel.IsDeleted = false;
                objClientMasterModel.InsertedDate = DateTime.Now;
                db.CrudClientMasterModel(objClientMasterModel, "INSERT");

                if (ConfigurationManager.AppSettings.Get("FromEmail") != null)
                {
                    retVal = "Success";
                    retValMsg = "";
                }
                else
                {
                    retVal = "Failed";
                    retValMsg = "Invalid Email";
                }

                if (reqClientMasterModel.EmailID1 != null)
                {
                    string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                    string Subject = CompanyName;
                    string strbody = "Thank You For Registration " + reqClientMasterModel.Title + " " + reqClientMasterModel.FirstName + " " + reqClientMasterModel.LastName;
                    string ToEmail = reqClientMasterModel.EmailID1;

                    string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                    CommonMethod.MailSend(ToEmail, Subject, strbody, false, true, true);
                }
                else
                {
                    //retVal = "Failed";
                    retValMsg = "Email Id Not Found!";
                }
                if (retVal == "Success")
                {
                    string CompanyName = (ConfigurationManager.AppSettings.Get("CompanyName"));
                    string Admin = (ConfigurationManager.AppSettings.Get("FromEmail"));
                    string Subject = CompanyName;
                    string strbody = "Please Give The Permission to " + reqClientMasterModel.Title + " " + reqClientMasterModel.FirstName + " " + reqClientMasterModel.LastName + " for login.<br>Email Id is : " + reqClientMasterModel.EmailID1 + "<br><a href='http://localhost:55330/admin/clientmaster'>AdminPanel</a>";
                    string ToEmail = Admin;

                    string InfoMail = (ConfigurationManager.AppSettings.Get("InfoMail"));
                    CommonMethod.MailSend(ToEmail, Subject, strbody, false, true, true);
                }
                else
                {

                }
            }
            return Json(new { retVal = retVal, retValMsg = retValMsg, reqClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult DeleteClientMaster(ClientMasterModel reqClientMasterModel)
        {
            if (reqClientMasterModel.ClientCd != null)
            {
                //reqClientMasterModel.StartDate = DateTime.Now;
                //reqClientMasterModel.EndDate = DateTime.Now;
                //reqClientMasterModel.DeadlineDate = DateTime.Now;
                db.CrudClientMasterModel(reqClientMasterModel, "DELETE");

            }
            return Json(new { reqClientMasterModel }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Product
        public ActionResult StoneList()
        {
            if (Session["Email_Id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
            //return View();
        }
        public JsonResult GetProductData(StoneListModel reqProductModel)
        {
            List<StoneListModel> lstProductModel = new List<StoneListModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqProductModel.STONEID))
            {
                whereClause = " AND UPPER(STONEID)=UPPER('" + reqProductModel.STONEID + "')";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CERTIFICATE))
            {
                whereClause = whereClause + " AND UPPER(CERTIFICATE)=UPPER('" + reqProductModel.CERTIFICATE + "')";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CERTNO))
            {
                whereClause = whereClause + " AND UPPER(CERTNO)=UPPER('" + reqProductModel.CERTNO + "')";
            }
            if (!string.IsNullOrEmpty(reqProductModel.SHAPE))
            {
                whereClause = whereClause + " AND UPPER(SHAPE)=UPPER('" + reqProductModel.SHAPE + "')";
            }
            if (!string.IsNullOrEmpty(reqProductModel.COLOR))
            {
                whereClause = whereClause + " AND UPPER(COLOR)=UPPER('" + reqProductModel.COLOR + "')";
            }
            if (!string.IsNullOrEmpty(reqProductModel.CLARITY))
            {
                whereClause = whereClause + " AND UPPER(CLARITY)=UPPER('" + reqProductModel.CLARITY + "')";
            }
            if (reqProductModel.FromCTS != null && reqProductModel.ToCTS != null)
            {
                whereClause = whereClause + " AND CTS BETWEEN '" + reqProductModel.FromCTS + "' AND '" + reqProductModel.ToCTS + "'";
            }
            int pageno = 1;
            if (reqProductModel.pageno > 1)
            {
                pageno = reqProductModel.pageno;
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = pageno;
            lstProductModel = db.getStoneList(reqRequestParam);
            for (int i = 0; i < lstProductModel.Count; i++)
            {
                lstProductModel[i].strCURDATE = db.GetDateHandle(lstProductModel[i].CURDATE);
                lstProductModel[i].strREPORT_DATE = db.GetDateHandle(lstProductModel[i].REPORT_DATE);
                lstProductModel[i].strNEW_ARRI_DATE = db.GetDateHandle(lstProductModel[i].NEW_ARRI_DATE);
            }
            return Json(new { lstProductModel }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Import Product
        public ActionResult SaveImportProduct()
        {
            if (Session["Email_Id"] != null)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
            //return View();
        }
        [HttpPost]
        public JsonResult SaveImportProduct(HttpPostedFileBase UploadFile)
        {
            string res = "";
            List<StoneListModel> ExistproductList = new List<StoneListModel>();
            //if (!Request.IsAuthenticated)
            //{
            //    res = "invaliduser";
            //}
            //else
            //{
            if (!Directory.Exists("~/images/"))
            {
                Directory.CreateDirectory(Server.MapPath("~/images/"));
            }
            if (!Directory.Exists("~/images/temp/"))
            {
                Directory.CreateDirectory(Server.MapPath("~/images/temp/"));
            }

            #region Upload Excel
            string sTempDir = Server.MapPath("~/images/temp/");
            if (ModelState.IsValid)
            {
                if (Request.Files["UploadFile"].ContentLength > 0)
                {
                    var file = Request.Files[0];

                    if (file != null && file.ContentLength > 0)
                    {
                        string[] AllowedFileExtensions = new string[] { ".xls", ".xlsx" };

                        if (!AllowedFileExtensions.Contains(file.FileName.Substring(file.FileName.LastIndexOf('.'))))
                        {
                            ModelState.AddModelError(string.Empty, "Please upload file in " + string.Join(", ", AllowedFileExtensions) + " format !");
                            //return View();
                            //return Json(new { res = res }, JsonRequestBehavior.AllowGet);
                        }
                        string sFileName = Path.GetFileName(file.FileName);
                        string sFilePath = Path.Combine(Server.MapPath("~/images/temp/"), sFileName);
                        file.SaveAs(sFilePath);

                        try
                        {
                            string sConnectionString;
                            string[] worksheetnames;

                            if (!Directory.Exists(sTempDir))
                            {
                                Directory.CreateDirectory(sTempDir);
                            }

                            sFilePath = sTempDir + Path.DirectorySeparatorChar + sFileName;

                            sConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + sFilePath + ";Extended Properties=Excel 12.0;";

                            string strFileType = Path.GetExtension(sFileName).ToLower();

                            //Connection String to Excel Workbook
                            if (strFileType.Trim() == ".xls")
                            {
                                sConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + sFilePath + ";Extended Properties=\"Excel 8.0;HDR=Yes;IMEX=2\"";
                            }
                            else if (strFileType.Trim() == ".xlsx")
                            {
                                sConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + sFilePath + ";Extended Properties=\"Excel 12.0;HDR=Yes;IMEX=2\"";
                            }

                            using (OleDbConnection conn = new OleDbConnection(sConnectionString))
                            {
                                conn.Open();
                                using (DataTable dt = conn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null))
                                {
                                    worksheetnames = new String[dt.Rows.Count];

                                    int j = 0;
                                    foreach (DataRow row in dt.Rows)
                                    {
                                        worksheetnames[j++] = row["TABLE_NAME"].ToString();
                                    }
                                }
                                conn.Close();
                            }
                            using (OleDbDataAdapter myCommand = new OleDbDataAdapter(
                                            "SELECT * FROM [" + worksheetnames[0] + "]", sConnectionString))
                            {
                                using (DataSet myDataSet = new DataSet())
                                {
                                    myCommand.Fill(myDataSet, "data");


                                    foreach (DataRow row in myDataSet.Tables["data"].Rows)
                                    {
                                        //if (row["STONEID"].ToString().Trim() == "")
                                        //{
                                        //    continue;
                                        //}
                                        //if (ExistproductList.Count > 0) { continue; }
                                        int COMPCD = 1;
                                        string STONEID = Convert.ToString(row["STONEID"]).Trim();
                                        string SHAPE = Convert.ToString(row["SHAPE"]).Trim();
                                        decimal CTS = Convert.ToDecimal(row["CTS"]);
                                        string COLOR = Convert.ToString(row["COLOR"]).Trim();
                                        string CLARITY = Convert.ToString(row["CLARITY"]).Trim();
                                        string CUT = Convert.ToString(row["CUT"]).Trim();
                                        string POLISH = Convert.ToString(row["POLISH"]).Trim();
                                        string SYM = Convert.ToString(row["SYM"]).Trim();
                                        string FLOURENCE = Convert.ToString(row["FLOURENCE"]).Trim();
                                        string FL_COLOR = Convert.ToString(row["FL_COLOR"]).Trim();
                                        string INCLUSION = Convert.ToString(row["INCLUSION"]).Trim();
                                        string HA = Convert.ToString(row["HA"]).Trim();
                                        string LUSTER = Convert.ToString(row["LUSTER"]).Trim();
                                        string GIRDLE = Convert.ToString(row["GIRDLE"]).Trim();
                                        string GIRDLE_CONDITION = Convert.ToString(row["GIRDLE_CONDITION"]).Trim();
                                        string CULET = Convert.ToString(row["CULET"]).Trim();
                                        string MILKY = Convert.ToString(row["MILKY"]).Trim();
                                        string SHADE = Convert.ToString(row["SHADE"]).Trim();
                                        string NATTS = Convert.ToString(row["NATTS"]).Trim();
                                        string NATURAL = Convert.ToString(row["NATURAL"]).Trim();
                                        //decimal DEPTH = Convert.ToDecimal(row["DEPTH"]);
                                        decimal DIATABLE = Convert.ToDecimal(row["DIATABLE"]);
                                        decimal LENGTH = Convert.ToDecimal(row["LENGTH"]);
                                        decimal WIDTH = Convert.ToDecimal(row["WIDTH"]);
                                        decimal PAVILION = Convert.ToDecimal(row["PAVILION"]);
                                        decimal CROWN = Convert.ToDecimal(row["CROWN"]);
                                        decimal PAVANGLE = Convert.ToDecimal(row["PAVANGLE"]);
                                        decimal CROWNANGLE = Convert.ToDecimal(row["CROWNANGLE"]);
                                        decimal HEIGHT = Convert.ToDecimal(row["HEIGHT"]);
                                        decimal PAVHEIGHT = Convert.ToDecimal(row["PAVHEIGHT"]);
                                        decimal CROWNHEIGHT = Convert.ToDecimal(row["CROWNHEIGHT"]);
                                        string MEASUREMENT = Convert.ToString(row["MEASUREMENT"]).Trim();
                                        decimal RATIO = Convert.ToDecimal(row["RATIO"]);
                                        string PAIR = Convert.ToString(row["PAIR"]).Trim();
                                        decimal STAR_LENGTH = Convert.ToDecimal(row["STAR_LENGTH"]);
                                        decimal LOWER_HALF = Convert.ToDecimal(row["LOWER_HALF"]);
                                        string KEY_TO_SYMBOL = Convert.ToString(row["KEY_TO_SYMBOL"]).Trim();
                                        string REPORT_COMMENT = Convert.ToString(row["REPORT_COMMENT"]).Trim();
                                        string CERTIFICATE = Convert.ToString(row["CERTIFICATE"]).Trim();
                                        string CERTNO = Convert.ToString(row["CERTNO"]).Trim();
                                        decimal RAPARATE = Convert.ToDecimal(row["RAPARATE"]);
                                        decimal RAPAAMT = Convert.ToDecimal(row["RAPAAMT"]);
                                        DateTime CURDATE = Convert.ToDateTime(row["CURDATE"]);
                                        string LOCATION = Convert.ToString(row["LOCATION"]).Trim();
                                        string LEGEND1 = Convert.ToString(row["LEGEND1"]).Trim();
                                        string LEGEND2 = Convert.ToString(row["LEGEND2"]).Trim();
                                        string LEGEND3 = Convert.ToString(row["LEGEND3"]).Trim();
                                        decimal ASKRATE_FC = Convert.ToDecimal(row["ASKRATE_FC"]);
                                        decimal ASKDISC_FC = Convert.ToDecimal(row["ASKDISC_FC"]);
                                        decimal ASKAMT_FC = Convert.ToDecimal(row["ASKAMT_FC"]);
                                        decimal COSTRATE_FC = Convert.ToDecimal(row["COSTRATE_FC"]);
                                        decimal COSTDISC_FC = Convert.ToDecimal(row["COSTDISC_FC"]);
                                        decimal COSTAMT_FC = Convert.ToDecimal(row["COSTAMT_FC"]);
                                        decimal WEB_CLIENTID = Convert.ToDecimal(row["WEB_CLIENTID"]);
                                        string wl_rej_status = Convert.ToString(row["wl_rej_status"]).Trim();
                                        string GIRDLEPER = Convert.ToString(row["GIRDLEPER"]).Trim();
                                        decimal DIA = Convert.ToDecimal(row["DIA"]);
                                        string COLORDESC = Convert.ToString(row["COLORDESC"]).Trim();
                                        string BARCODE = Convert.ToString(row["BARCODE"]).Trim();
                                        string INSCRIPTION = Convert.ToString(row["INSCRIPTION"]).Trim();
                                        string NEW_CERT = Convert.ToString(row["NEW_CERT"]).Trim();
                                        string MEMBER_COMMENT = Convert.ToString(row["MEMBER_COMMENT"]).Trim();
                                        int UPLOADCLIENTID = Convert.ToInt32(row["UPLOADCLIENTID"]);
                                        DateTime REPORT_DATE = Convert.ToDateTime(row["REPORT_DATE"]);
                                        DateTime NEW_ARRI_DATE = Convert.ToDateTime(row["NEW_ARRI_DATE"]);
                                        string TINGE = Convert.ToString(row["TINGE"]).Trim();
                                        string EYE_CLN = Convert.ToString(row["EYE_CLN"]).Trim();
                                        string TABLE_INCL = Convert.ToString(row["TABLE_INCL"]).Trim();
                                        string SIDE_INCL = Convert.ToString(row["SIDE_INCL"]).Trim();
                                        string TABLE_BLACK = Convert.ToString(row["TABLE_BLACK"]).Trim();
                                        string SIDE_BLACK = Convert.ToString(row["SIDE_BLACK"]).Trim();
                                        string TABLE_OPEN = Convert.ToString(row["TABLE_OPEN"]).Trim();
                                        string SIDE_OPEN = Convert.ToString(row["SIDE_OPEN"]).Trim();
                                        string PAV_OPEN = Convert.ToString(row["PAV_OPEN"]).Trim();
                                        string EXTRA_FACET = Convert.ToString(row["EXTRA_FACET"]).Trim();
                                        string INTERNAL_COMMENT = Convert.ToString(row["INTERNAL_COMMENT"]).Trim();
                                        string POLISH_FEATURES = Convert.ToString(row["POLISH_FEATURES"]).Trim();
                                        string SYMMETRY_FEATURES = Convert.ToString(row["SYMMETRY_FEATURES"]).Trim();
                                        string GRAINING = Convert.ToString(row["GRAINING"]).Trim();
                                        string IMG_URL = Convert.ToString(row["IMG_URL"]).Trim();
                                        string RATEDISC = Convert.ToString(row["RATEDISC"]).Trim();
                                        string GRADE = Convert.ToString(row["GRADE"]).Trim();
                                        string CLIENT_LOCATION = Convert.ToString(row["CLIENT_LOCATION"]).Trim();
                                        string ORIGIN = Convert.ToString(row["ORIGIN"]).Trim();
                                        string BGM = Convert.ToString(row["BGM"]).Trim();

                                        if (!string.IsNullOrEmpty(STONEID))

                                        {
                                            StoneListModel objTemp = new StoneListModel();
                                            objTemp.COMPCD = COMPCD;
                                            objTemp.STONEID = STONEID;
                                            objTemp.SHAPE = SHAPE;
                                            objTemp.CTS = CTS;
                                            objTemp.COLOR = COLOR;
                                            objTemp.CLARITY = CLARITY;
                                            objTemp.CUT = CUT;
                                            objTemp.POLISH = POLISH;
                                            objTemp.SYM = SYM;
                                            objTemp.FLOURENCE = FLOURENCE;
                                            objTemp.FL_COLOR = FL_COLOR;
                                            objTemp.INCLUSION = INCLUSION;
                                            objTemp.HA = HA;
                                            objTemp.LUSTER = LUSTER;
                                            objTemp.GIRDLE = GIRDLE;
                                            objTemp.GIRDLE_CONDITION = GIRDLE_CONDITION;
                                            objTemp.CULET = CULET;
                                            objTemp.MILKY = MILKY;
                                            objTemp.SHADE = SHADE;
                                            objTemp.NATTS = NATTS;
                                            objTemp.NATURAL = NATURAL;
                                            //objTemp.DEPTH = DEPTH;
                                            objTemp.DIATABLE = DIATABLE;
                                            objTemp.LENGTH = LENGTH;
                                            objTemp.WIDTH = WIDTH;
                                            objTemp.PAVILION = PAVILION;
                                            objTemp.CROWN = CROWN;
                                            objTemp.PAVANGLE = PAVANGLE;
                                            objTemp.CROWNANGLE = CROWNANGLE;
                                            objTemp.HEIGHT = HEIGHT;
                                            objTemp.PAVHEIGHT = PAVHEIGHT;
                                            objTemp.CROWNHEIGHT = CROWNHEIGHT;
                                            objTemp.MEASUREMENT = MEASUREMENT;
                                            objTemp.RATIO = RATIO;
                                            objTemp.PAIR = PAIR;
                                            objTemp.STAR_LENGTH = STAR_LENGTH;
                                            objTemp.LOWER_HALF = LOWER_HALF;
                                            objTemp.KEY_TO_SYMBOL = KEY_TO_SYMBOL;
                                            objTemp.REPORT_COMMENT = REPORT_COMMENT;
                                            objTemp.CERTIFICATE = CERTIFICATE;
                                            objTemp.CERTNO = CERTNO;
                                            objTemp.RAPARATE = RAPARATE;
                                            objTemp.RAPAAMT = RAPAAMT;
                                            objTemp.CURDATE = CURDATE;
                                            objTemp.LOCATION = LOCATION;
                                            objTemp.LEGEND1 = LEGEND1;
                                            objTemp.LEGEND2 = LEGEND2;
                                            objTemp.LEGEND3 = LEGEND3;
                                            objTemp.ASKRATE_FC = ASKRATE_FC;
                                            objTemp.ASKDISC_FC = ASKDISC_FC;
                                            objTemp.ASKAMT_FC = ASKAMT_FC;
                                            objTemp.COSTRATE_FC = COSTRATE_FC;
                                            objTemp.COSTDISC_FC = COSTDISC_FC;
                                            objTemp.COSTAMT_FC = COSTAMT_FC;
                                            objTemp.WEB_CLIENTID = WEB_CLIENTID;
                                            objTemp.wl_rej_status = wl_rej_status;
                                            objTemp.GIRDLEPER = GIRDLEPER;
                                            objTemp.DIA = DIA;
                                            objTemp.COLORDESC = COLORDESC;
                                            objTemp.BARCODE = BARCODE;
                                            objTemp.INSCRIPTION = INSCRIPTION;
                                            objTemp.NEW_CERT = NEW_CERT;
                                            objTemp.MEMBER_COMMENT = MEMBER_COMMENT;
                                            objTemp.UPLOADCLIENTID = UPLOADCLIENTID;
                                            objTemp.REPORT_DATE = REPORT_DATE;
                                            objTemp.NEW_ARRI_DATE = NEW_ARRI_DATE;
                                            objTemp.TINGE = TINGE;
                                            objTemp.EYE_CLN = EYE_CLN;
                                            objTemp.TABLE_INCL = TABLE_INCL;
                                            objTemp.SIDE_INCL = SIDE_INCL;
                                            objTemp.TABLE_BLACK = TABLE_BLACK;
                                            objTemp.SIDE_BLACK = SIDE_BLACK;
                                            objTemp.TABLE_OPEN = TABLE_OPEN;
                                            objTemp.SIDE_OPEN = SIDE_OPEN;
                                            objTemp.PAV_OPEN = PAV_OPEN;
                                            objTemp.EXTRA_FACET = EXTRA_FACET;
                                            objTemp.INTERNAL_COMMENT = INTERNAL_COMMENT;
                                            objTemp.POLISH_FEATURES = POLISH_FEATURES;
                                            objTemp.SYMMETRY_FEATURES = SYMMETRY_FEATURES;
                                            objTemp.GRAINING = GRAINING;
                                            objTemp.IMG_URL = IMG_URL;
                                            objTemp.RATEDISC = RATEDISC;
                                            objTemp.GRADE = GRADE;
                                            objTemp.CLIENT_LOCATION = CLIENT_LOCATION;
                                            objTemp.ORIGIN = ORIGIN;
                                            objTemp.BGM = BGM;
                                            db.CrudImportProduct(objTemp, "INSERT");
                                            //return Json(new { reqProjectModel }, JsonRequestBehavior.AllowGet);
                                        }
                                        //string[] strcatname = CategoryName.ToString().Split(",".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);

                                        //foreach (var loitem in strcatname)
                                        //{
                                        //    var checkCategoryNameIsExists = db.CategoryMasters.FirstOrDefault(x => x.CategoryName == loitem.ToString().Trim() && (x.IsDeleted ?? false) == false);

                                        //    if (checkCategoryNameIsExists != null)
                                        //    {
                                        //        //var checkProductIsExists = db.ProductMasters.FirstOrDefault(x => x.ProductCode == ProductCode && (x.IsDeleted ?? false) == false);
                                        //        var checkProductIsExists = (from p in db.ProductMasters
                                        //                                    join pcb in db.ProductCategoryBindings on p.ProductId equals pcb.ProductId
                                        //                                    where pcb.CategoryId == checkCategoryNameIsExists.CategoryId && p.ProductCode == ProductCode && (p.IsDeleted ?? false) == false
                                        //                                    select p).FirstOrDefault();
                                        //        if (checkProductIsExists != null)
                                        //        {
                                        //            ExistproductList ObjExistproductList = new ExistproductList();
                                        //            ObjExistproductList.ProductCode = checkProductIsExists.ProductCode;
                                        //            ObjExistproductList.CategoryName = checkCategoryNameIsExists.CategoryName;
                                        //            ExistproductList.Add(ObjExistproductList);
                                        //            ////checkProductIsExists.CatalogueId = checkCatalogueIsExists.CatalogueId;
                                        //            //checkProductIsExists.ProductCode = Convert.ToString(row["ProductCode"]).Trim();
                                        //            //checkProductIsExists.ProductName = Convert.ToString(row["ProductName"]).Trim();
                                        //            //checkProductIsExists.Description = Convert.ToString(row["ProductDetail"]).Trim();
                                        //            //checkProductIsExists.IsActive = Convert.ToBoolean((row["IsFreezed"].ToString()) == "Y");
                                        //            //checkProductIsExists.MarketPrice = Convert.ToDecimal(row["MarketPrice"].ToString());
                                        //            //checkProductIsExists.DiscountPercent = Convert.ToDecimal(row["DiscountPercent"].ToString());
                                        //            //checkProductIsExists.OfferPrice = (Convert.ToDecimal(row["MarketPrice"].ToString()) * (100 - Convert.ToDecimal(row["DiscountPercent"].ToString())) / 100);
                                        //            //checkProductIsExists.AvailableQuantity = Convert.ToDecimal(row["AvailableQuantity"].ToString());
                                        //            //checkProductIsExists.MinOrderQuantity = Convert.ToDecimal(row["MinOrderQuantity"].ToString());
                                        //            //checkProductIsExists.ImageName = Convert.ToString(row["ImageName"]).Trim();
                                        //            //string colorname = "";
                                        //            //colorname = row["ColorName"].ToString().ToLower();
                                        //            //var locolor = (from c in db.ColorMasters
                                        //            //               where c.ColorName.ToLower() == colorname
                                        //            //               select c).FirstOrDefault();
                                        //            //if (locolor != null)
                                        //            //{
                                        //            //    checkProductIsExists.ColorId = CommonMethods.SB_TryParseInt32(locolor.ColorId.ToString());
                                        //            //}
                                        //            //else
                                        //            //{
                                        //            //    checkProductIsExists.ColorId = 0;
                                        //            //}
                                        //            //checkProductIsExists.UpdatedAt = DateTime.Now;
                                        //            //db.SaveChanges();
                                        //            #region ProductBinding
                                        //            ////LaxmiTatkal.Models.ProductCategoryBinding objBindPro = new LaxmiTatkal.Models.ProductCategoryBinding();
                                        //            //int catid = 0;
                                        //            //Int32.TryParse(checkCategoryNameIsExists.CategoryId.ToString(), out catid);
                                        //            //var objBindPro = (from pcb in db.ProductCategoryBindings
                                        //            //                  join p in db.ProductMasters on pcb.ProductId equals p.ProductId
                                        //            //                  join c in db.CategoryMasters on pcb.CategoryId equals c.CategoryId
                                        //            //                  where pcb.CategoryId == catid
                                        //            //                  select pcb).FirstOrDefault();
                                        //            //if (objBindPro != null)
                                        //            //{
                                        //            //    objBindPro.ProductId = CommonMethods.SB_TryParseInt32(checkProductIsExists.ProductId.ToString());
                                        //            //    objBindPro.CategoryId = CommonMethods.SB_TryParseInt32(checkCategoryNameIsExists.CategoryId.ToString());
                                        //            //    db.ProductCategoryBindings.Add(objBindPro);
                                        //            //    db.SaveChanges();
                                        //            //}
                                        //            #endregion
                                        //            ////ModelState.Clear();
                                        //        }
                                        //        else
                                        //        {
                                        //            //ProductMaster objProductMaster = new ProductMaster();
                                        //            ////objProductMaster.CatalogueId = checkCatalogueIsExists.CatalogueId;
                                        //            //objProductMaster.ProductCode = Convert.ToString(row["ProductCode"]).Trim();
                                        //            //objProductMaster.ProductName = Convert.ToString(row["ProductName"]).Trim();
                                        //            //objProductMaster.Description = Convert.ToString(row["ProductDetail"]).Trim();
                                        //            //objProductMaster.IsActive = Convert.ToBoolean((row["IsFreezed"].ToString()) == "Y");
                                        //            //objProductMaster.MarketPrice = Convert.ToDecimal(row["MarketPrice"].ToString());
                                        //            //objProductMaster.DiscountPercent = Convert.ToDecimal(row["DiscountPercent"].ToString());
                                        //            //objProductMaster.OfferPrice = (Convert.ToDecimal(row["MarketPrice"].ToString()) * (100 - Convert.ToDecimal(row["DiscountPercent"].ToString())) / 100);
                                        //            //objProductMaster.AvailableQuantity = Convert.ToDecimal(row["AvailableQuantity"].ToString());
                                        //            //objProductMaster.MinOrderQuantity = Convert.ToDecimal(row["MinOrderQuantity"].ToString());
                                        //            //objProductMaster.ImageName = Convert.ToString(row["ImageName"]).Trim();
                                        //            //objProductMaster.UpdatedById = 007;
                                        //            //string colorname = "";
                                        //            //colorname = row["ColorName"].ToString().ToLower();
                                        //            //var locolor = (from c in db.ColorMasters
                                        //            //               where c.ColorName.ToLower() == colorname
                                        //            //               select c).FirstOrDefault();
                                        //            ////int colorid = 0;
                                        //            ////Int32.TryParse(locolor.ColorId, out colorid);
                                        //            //if (locolor != null)
                                        //            //{
                                        //            //    objProductMaster.ColorId = CommonMethods.SB_TryParseInt32(locolor.ColorId.ToString());
                                        //            //}
                                        //            //else
                                        //            //{
                                        //            //    objProductMaster.ColorId = 0;
                                        //            //}
                                        //            //objProductMaster.InsertedAt = DateTime.Now;
                                        //            //db.ProductMasters.Add(objProductMaster);
                                        //            //db.SaveChanges();
                                        //            #region ProductBinding
                                        //            //LaxmiTatkal.Models.ProductCategoryBinding objBindPro = new LaxmiTatkal.Models.ProductCategoryBinding();
                                        //            //objBindPro.ProductId = objProductMaster.ProductId;
                                        //            //objBindPro.CategoryId = checkCategoryNameIsExists.CategoryId;
                                        //            //db.ProductCategoryBindings.Add(objBindPro);
                                        //            //db.SaveChanges();
                                        //            ////ModelState.Clear();
                                        //            #endregion

                                        //            //ProductMaster objProductMaster = new ProductMaster();
                                        //            ////objProductMaster.CatalogueId = checkCatalogueIsExists.CatalogueId;
                                        //            //objProductMaster.ProductCode = Convert.ToString(ProductCode).Trim();
                                        //            //objProductMaster.FolderNo = Convert.ToString(row["FolderNo"]).Trim();
                                        //            //objProductMaster.ProductName = Convert.ToString(row["Name"]).Trim();
                                        //            //objProductMaster.Fabric = Convert.ToString(row["Fabric"]).Trim();
                                        //            //objProductMaster.FabricPartyName = Convert.ToString(row["FabricPartyName"]).Trim();
                                        //            //objProductMaster.Material = Convert.ToString(row["Material"]).Trim();
                                        //            //objProductMaster.FabDensityType = Convert.ToString(row["FabDensityType"]).Trim();
                                        //            //objProductMaster.Width = Convert.ToDecimal(row["Width"]);
                                        //            //objProductMaster.Height = Convert.ToDecimal(row["Height"]);
                                        //            //objProductMaster.Measurement = Convert.ToString(row["Measurement"]).Trim();
                                        //            //objProductMaster.Description = Convert.ToString(row["Description"]).Trim();
                                        //            //objProductMaster.ColorName = Convert.ToString(row["Color"]).Trim();
                                        //            //objProductMaster.ColorCode = Convert.ToString(row["ColorCode"]).Trim();


                                        //            //decimal BaseFabRate = 0, EmbRate = 0, HandWork = 0, Khatli = 0, Stone = 0, Moti = 0, Flower = 0;
                                        //            //decimal SolderCut = 0, HandPrint = 0, DigitalPrint = 0, PositionPrint = 0, MarketPrice = 0, DiscountPer = 0;
                                        //            //decimal.TryParse(row["BaseFabRate"].ToString(), out BaseFabRate);
                                        //            //decimal.TryParse(row["EmbRate"].ToString(), out EmbRate);
                                        //            //decimal.TryParse(row["HandWork"].ToString(), out HandWork);
                                        //            //decimal.TryParse(row["Khatli"].ToString(), out Khatli);
                                        //            //decimal.TryParse(row["Stone"].ToString(), out Stone);
                                        //            //decimal.TryParse(row["Moti"].ToString(), out Moti);
                                        //            //decimal.TryParse(row["Flower"].ToString(), out Flower);
                                        //            //decimal.TryParse(row["SolderCut"].ToString(), out SolderCut);
                                        //            //decimal.TryParse(row["HandPrint"].ToString(), out HandPrint);
                                        //            //decimal.TryParse(row["DigitalPrint"].ToString(), out DigitalPrint);
                                        //            //decimal.TryParse(row["PositionPrint"].ToString(), out PositionPrint);
                                        //            //objProductMaster.BaseFabRate = Convert.ToDecimal(BaseFabRate);
                                        //            //objProductMaster.EmbRate = Convert.ToDecimal(EmbRate);
                                        //            //objProductMaster.HandWork = Convert.ToDecimal(HandWork);
                                        //            //objProductMaster.Khatli = Convert.ToDecimal(Khatli);
                                        //            //objProductMaster.Stone = Convert.ToDecimal(Stone);
                                        //            //objProductMaster.Moti = Convert.ToDecimal(Moti);
                                        //            //objProductMaster.Flower = Convert.ToDecimal(Flower);
                                        //            //objProductMaster.SolderCut = Convert.ToDecimal(SolderCut);
                                        //            //objProductMaster.HandPrint = Convert.ToDecimal(HandPrint);
                                        //            //objProductMaster.DigitalPrint = Convert.ToDecimal(DigitalPrint);
                                        //            //objProductMaster.PositionPrint = Convert.ToDecimal(PositionPrint);
                                        //            //decimal CostRate = BaseFabRate + EmbRate + HandWork + Khatli + Stone + Moti + Flower + SolderCut + HandPrint + DigitalPrint + PositionPrint;
                                        //            //objProductMaster.CostRate = Convert.ToDecimal(CostRate);
                                        //            //decimal.TryParse(row["MarketPrice"].ToString(), out MarketPrice);
                                        //            //decimal.TryParse(row["DiscountPer"].ToString(), out DiscountPer);
                                        //            //objProductMaster.MarketPrice = Convert.ToDecimal(MarketPrice);
                                        //            //objProductMaster.DiscountPercent = Convert.ToDecimal(DiscountPer);
                                        //            //objProductMaster.OfferPrice = (Convert.ToDecimal(MarketPrice) * (100 - Convert.ToDecimal(DiscountPer)) / 100);

                                        //            //decimal ShowRoomQTY = 0, GodownQTY = 0, JOBWORKQTY = 0;

                                        //            ////decimal.TryParse(row["ShowRoomQTY"].ToString(), out ShowRoomQTY);
                                        //            ////decimal.TryParse(row["GodownQTY"].ToString(), out GodownQTY);
                                        //            ////decimal.TryParse(row["JOBWORKQTY"].ToString(), out JOBWORKQTY);
                                        //            ////objProductMaster.ShowRoomQTY = ShowRoomQTY;
                                        //            ////objProductMaster.GodownQTY = GodownQTY;
                                        //            ////objProductMaster.JOBWORKQTY = JOBWORKQTY;
                                        //           // objProductMaster.ColorCode = Convert.ToString(row["ColorCode"]).Trim();
                                        //            ////string colorname = "";
                                        //            ////colorname = row["ColorName"].ToString().ToLower();
                                        //            ////var locolor = (from c in db.ColorMasters
                                        //            ////               where c.ColorName.ToLower() == colorname
                                        //            ////               select c).FirstOrDefault();
                                        //            //////int colorid = 0;
                                        //            //////Int32.TryParse(locolor.ColorId, out colorid);
                                        //            ////if (locolor != null)
                                        //            ////{
                                        //            ////    objProductMaster.ColorId = CommonMethods.SB_TryParseInt32(locolor.ColorId.ToString());
                                        //            ////}
                                        //            ////else
                                        //            ////{
                                        //            ////    objProductMaster.ColorId = 0;
                                        //            ////}

                                        //            ////objProductMaster.IsActive = Convert.ToBoolean(row["Status"]);
                                        //            ////objProductMaster.IsDeleted = false;
                                        //            ////objProductMaster.STOCKFLAG = "STOCK";
                                        //            ////objProductMaster.PROCESS = "OPENING_STOCK";
                                        //            ////if (Session["RegisterMas"] != null)
                                        //            ////{
                                        //            ////    UserMaster objUserMaster = (UserMaster)Session["RegisterMas"];
                                        //            ////    objProductMaster.EUSER = objUserMaster.UserName;
                                        //            ////    objProductMaster.UpdatedById = Convert.ToInt32(objUserMaster.UserId);
                                        //            ////}
                                        //            ////objProductMaster.InsertedAt = DateTime.Now;
                                        //            ////db.ProductMasters.Add(objProductMaster);
                                        //            ////db.SaveChanges();
                                        //            #region Images
                                        //            //int Productid = objProductMaster.ProductId;
                                        //            //ProductImage objProductImage = new ProductImage();
                                        //            //objProductImage.ProductId = Productid;
                                        //            //objProductImage.ImageName = Convert.ToString(row["DefaultImage"]).Trim();
                                        //            //objProductImage.IsDefault = true;
                                        //            //db.ProductImages.Add(objProductImage);
                                        //            //db.SaveChanges();
                                        //            //string lsOtherImages = Convert.ToString(row["OtherImages"]).Trim();
                                        //            //if (!string.IsNullOrEmpty(lsOtherImages))
                                        //            //{
                                        //            //    string[] lsOtherImagesArr = lsOtherImages.Split(',');
                                        //            //    for (int i = 0; i < lsOtherImagesArr.Length; i++)
                                        //            //    {
                                        //            //        ProductImage objOtherProductImage = new ProductImage();
                                        //            //        objOtherProductImage.ProductId = Productid;
                                        //            //        objOtherProductImage.ImageName = Convert.ToString(lsOtherImagesArr[i]).Trim();
                                        //            //        objOtherProductImage.IsDefault = false;
                                        //            //        db.ProductImages.Add(objOtherProductImage);
                                        //            //        db.SaveChanges();
                                        //            //    }
                                        //            //}
                                        //            #endregion
                                        //            #region ProductBinding
                                        //            //LaxmiTatkal.Models.ProductCategoryBinding objBindPro = new LaxmiTatkal.Models.ProductCategoryBinding();
                                        //            //objBindPro.ProductId = objProductMaster.ProductId;
                                        //            //objBindPro.CategoryId = checkCategoryNameIsExists.CategoryId;
                                        //            //db.ProductCategoryBindings.Add(objBindPro);
                                        //            //db.SaveChanges();
                                        //            //ModelState.Clear();
                                        //            #endregion
                                        //        }
                                        //    }
                                        //    else
                                        //    {
                                        //        throw new Exception("Invalid CategoryName !");
                                        //    }
                                        //}
                                    }

                                }


                                System.IO.File.Delete(sFilePath);
                                //res = "Product uploaded successfully..";
                                if (ExistproductList.Count > 0)
                                {
                                    res = "Productexsist";
                                }
                                else
                                {
                                    res = "success";
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            res = ex.Message.ToString();
                            //ViewBag.HTMLclass = "error";
                        }
                    }
                    else
                    {
                        res = "Please select file...";
                        //ModelState.AddModelError(string.Empty, "Please select file...");
                    }
                }
                else
                {
                    res = "Please select file...";
                    //ModelState.AddModelError(string.Empty, "Please select file...");
                }
            }
            #endregion

            //}
            return Json(new { res = res, ExistproductList }, JsonRequestBehavior.AllowGet);

        }

        #endregion

        #region OrderList
        public ActionResult OrderList()
        {
            return View();
        }
        public JsonResult GetOrderListData(ShoppingCartModel reqShoppingCartModel)
        {
            List<ShoppingCartModel> lstShoppingCartModel = new List<ShoppingCartModel>();
            RequestParam reqRequestParam = new RequestParam();
            string whereClause = string.Empty;
            if (!string.IsNullOrEmpty(reqShoppingCartModel.FirstName))
            {
                whereClause = " AND UPPER(FirstName)=UPPER('" + reqShoppingCartModel.FirstName + "')";
            }
            int pageno = 1;
            if (reqShoppingCartModel.pageno > 1)
            {
                pageno = reqShoppingCartModel.pageno;
            }
            reqRequestParam.whereClause = whereClause;
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 10;
            reqRequestParam.pageno = pageno;
            lstShoppingCartModel = db.getOrderListData(reqRequestParam);
            return Json(new { lstShoppingCartModel }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult ExportDataToExcel(string Flag)
        {
            RequestParam reqRequestParam = new RequestParam();
            reqRequestParam.whereClause = "";
            reqRequestParam.orderByClause = "";
            reqRequestParam.PageSize = 1000;
            reqRequestParam.pageno = 1;
            DataTable dt = AppDataContext.ExportData(reqRequestParam, Flag);

            var grid = new GridView();
            grid.DataSource = dt;
            grid.DataBind();
            grid.HeaderRow.Style.Add("background-color", "#FFFFFF");
            foreach (TableCell TableCell in grid.HeaderRow.Cells)
            {
                TableCell.Style["background-color"] = "#8EBAFF";
            }
            //foreach(GridViewRow GridRow in grid.Rows)
            //{
            //    GridRow.BackColor = System.Drawing.Color.White;
            //    foreach (TableCell GridTableCell in GridRow.Cells)
            //    {
            //        GridTableCell.Style["background-color"] = "#8EBAFF";
            //    }
            //}
            // grid.HeaderStyle.BackColor = System.Drawing.Color.Blue;
            //grid.BackColor = System.Drawing.Color.Yellow; //<--- Set Background Color Of all Excel seet --->

            Response.ClearContent();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment; filename=" + Flag + "ListData.xls");
            Response.ContentType = "application/ms-excel";

            Response.Charset = "";
            StringWriter sw = new StringWriter();
            HtmlTextWriter htw = new HtmlTextWriter(sw);

            grid.RenderControl(htw);

            Response.Output.Write(sw.ToString());
            Response.Flush();
            Response.End();

            return View("MyView");
        }
        #endregion

        public ActionResult UploadImage()
        {
            return View();
        }
        [HttpPost]
        public ActionResult UploadFiles()
        {
            // Checking no of files injected in Request object  
            if (Request.Files.Count > 0)
            {
                try
                {
                    //  Get all files from Request object  
                    HttpFileCollectionBase files = Request.Files;
                    for (int i = 0; i < files.Count; i++)
                    {
                        //string path = AppDomain.CurrentDomain.BaseDirectory + "Uploads/";  
                        //string filename = Path.GetFileName(Request.Files[i].FileName);  

                        HttpPostedFileBase file = files[i];
                        string fname;

                        // Checking for Internet Explorer  
                        if (Request.Browser.Browser.ToUpper() == "IE" || Request.Browser.Browser.ToUpper() == "INTERNETEXPLORER")
                        {
                            string[] testfiles = file.FileName.Split(new char[] { '\\' });
                            fname = testfiles[testfiles.Length - 1];
                        }
                        else
                        {
                            fname = file.FileName;
                        }

                        // Get the complete folder path and store the file inside it.  
                        fname = Path.Combine(Server.MapPath("~/UploadImage/"), fname);
                        file.SaveAs(fname);
                    }
                    // Returns message that successfully uploaded  
                    return Json("File Uploaded Successfully!");
                }
                catch (Exception ex)
                {
                    return Json("Error occurred. Error details: " + ex.Message);
                }
            }
            else
            {
                return Json("No files selected.");
            }
        }

    }

}

