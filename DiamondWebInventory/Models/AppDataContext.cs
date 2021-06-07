using DiamondWebInventory.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace DiamondWebInventory.Models
{
    #region Connection/Bind
    public class AppDataContext : DbContext
    {
        public static string _DBHost = ConfigurationManager.AppSettings["_DBHost"];
        public static string _DbUser = ConfigurationManager.AppSettings["_DbUser"];
        public static string _DbPassword = ConfigurationManager.AppSettings["_DbPassword"];
        public static string _DbName = ConfigurationManager.AppSettings["_DbName"];
        public static string Conn = "Data Source=" + _DBHost + ";Initial Catalog=" + _DbName + ";Persist Security Info=True;User ID=" + _DbUser + ";Password=" + _DbPassword + "";
        public AppDataContext()
            : base(Conn)
        {

        }
        #endregion
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            Database.SetInitializer<AppDataContext>(null);
            base.OnModelCreating(modelBuilder);
        }

        #region Admin / Client Login
        //<----------------Client Login Start------------>
        public ClientMasterModel getLoginData(ClientMasterModel reqAdminLoginData)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("EmailID1", reqAdminLoginData.EmailID1.handleDBNull()));
            list.Add(new SqlParameter("Password", reqAdminLoginData.Password.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ClientMasterModel>("spValidLogin".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
        }
        //<----------------client Login End------------>
        //<----------------Admin Login Start------------>
        public AdminModel getAdminLoginData(AdminModel reqAdminLoginData)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("Email_Id", reqAdminLoginData.Email_Id.handleDBNull()));
            list.Add(new SqlParameter("Password", reqAdminLoginData.Password.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<AdminModel>("spValidAdmin".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
        }
        //<----------------Admin Login End------------>
        #endregion

        #region Banner
        //<------------Banner Crud Operation Start---------->
        public List<BannerModel> getBannerList(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<BannerModel>("BannerList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public string CrudBanner(BannerModel reqBannerModel, string FLAG = "")
        {
            string value = "0";
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("Id", reqBannerModel.Id.handleDBNull()));
            list.Add(new SqlParameter("Title", reqBannerModel.Title.handleDBNull()));
            list.Add(new SqlParameter("ImageType", reqBannerModel.ImageType.handleDBNull()));
            list.Add(new SqlParameter("ClickUrl", reqBannerModel.ClickUrl.handleDBNull()));
            list.Add(new SqlParameter("IsActive", reqBannerModel.IsActive.handleDBNull()));
            //list.Add(new SqlParameter("IsDeleted", reqBannerModel.IsDeleted.handleDBNull()));
            //list.Add(new SqlParameter("InsertedDate", reqBannerModel.InsertedDate.handleDBNull()));
            //list.Add(new SqlParameter("UpdatedDate", reqBannerModel.UpdatedDate.handleDBNull()));
            list.Add(new SqlParameter("FLAG", FLAG));
            SqlParameter sqlParameter = new SqlParameter("RETURNVAL", SqlDbType.NVarChar, 500);
            sqlParameter.Value = value;
            sqlParameter.Direction = ParameterDirection.Output;
            list.Add(sqlParameter);
            new AppDataContext().Database.SqlQuery<object>("SpBannerCrud".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
            return Convert.ToString(sqlParameter.Value);
        }
        //<------------Banner Crud Operation End---------->
        //<------------ Crud Operation Start---------->
        #endregion

        #region Procmas
        public List<ProcmasModel> getProcmasList(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ProcmasModel>("SpProcmasList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public string CrudProcmas(ProcmasModel regProcmasModel, string FLAG = "")
        {
            string value = "0";
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("Id", regProcmasModel.Id.handleDBNull()));
            list.Add(new SqlParameter("Procgroup", regProcmasModel.Procgroup.handleDBNull()));
            list.Add(new SqlParameter("Proccd", regProcmasModel.Proccd.handleDBNull()));
            list.Add(new SqlParameter("Procnm", regProcmasModel.Procnm.handleDBNull()));
            list.Add(new SqlParameter("Shortnm", regProcmasModel.Shortnm.handleDBNull()));
            list.Add(new SqlParameter("Ord", regProcmasModel.Ord.handleDBNull()));
            //list.Add(new SqlParameter("Status", regProcmasModel.Status.handleDBNull()));
            //list.Add(new SqlParameter("Fancy_Color_Status", regProcmasModel.Fancy_Color_Status.handleDBNull()));
            //list.Add(new SqlParameter("IsChangeable", regProcmasModel.IsChangeable.handleDBNull()));
            //list.Add(new SqlParameter("Fancy_Color", regProcmasModel.Fancy_Color.handleDBNull()));
            //list.Add(new SqlParameter("Fancy_Intensity", regProcmasModel.Fancy_Intensity.handleDBNull()));
            //list.Add(new SqlParameter("Fancy_Overtone", regProcmasModel.Fancy_Overtone.handleDBNull()));
            //list.Add(new SqlParameter("F_CTS", regProcmasModel.F_CTS.handleDBNull()));
            //list.Add(new SqlParameter("T_CTS", regProcmasModel.T_CTS.handleDBNull()));
            list.Add(new SqlParameter("IsActive", regProcmasModel.IsActive.handleDBNull()));
            list.Add(new SqlParameter("FLAG", FLAG));
            SqlParameter sqlParameter = new SqlParameter("RETURNVAL", SqlDbType.NVarChar, 500);
            sqlParameter.Value = value;
            sqlParameter.Direction = ParameterDirection.Output;
            list.Add(sqlParameter);
            new AppDataContext().Database.SqlQuery<object>("SpProcmasCrud".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
            return Convert.ToString(sqlParameter.Value);
        }
        //<------------ Crud Operation End---------->
        #endregion

        #region Client Master
        //Client Master Crud Start
        public List<ClientMasterModel> getClientMasterList(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ClientMasterModel>("SpClientMasterList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public string CrudClientMasterModel(ClientMasterModel regClientMasterModel, string FLAG = "")
        {
            string value = "0";
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("ClientCd", regClientMasterModel.ClientCd.handleDBNull()));
            list.Add(new SqlParameter("LoginName", regClientMasterModel.LoginName.handleDBNull()));
            list.Add(new SqlParameter("Password", regClientMasterModel.Password.handleDBNull()));
            list.Add(new SqlParameter("Title", regClientMasterModel.Title.handleDBNull()));
            list.Add(new SqlParameter("FirstName", regClientMasterModel.FirstName.handleDBNull()));
            list.Add(new SqlParameter("LastName", regClientMasterModel.LastName.handleDBNull()));
            list.Add(new SqlParameter("ReferenceThrough", regClientMasterModel.ReferenceThrough.handleDBNull()));
            list.Add(new SqlParameter("Birthdate", Helper.handleDBNullDate(regClientMasterModel.Birthdate.ToString())));
            list.Add(new SqlParameter("CompanyNm", regClientMasterModel.CompanyNm.handleDBNull()));
            list.Add(new SqlParameter("Designation", regClientMasterModel.Designation.handleDBNull()));
            list.Add(new SqlParameter("Discount", regClientMasterModel.Discount.handleDBNull()));
            list.Add(new SqlParameter("Address", regClientMasterModel.Address.handleDBNull()));
            list.Add(new SqlParameter("City", regClientMasterModel.City.handleDBNull()));
            list.Add(new SqlParameter("State", regClientMasterModel.State.handleDBNull()));
            list.Add(new SqlParameter("Zipcode", regClientMasterModel.Zipcode.handleDBNull()));
            list.Add(new SqlParameter("Phone_No", regClientMasterModel.Phone_No.handleDBNull()));
            list.Add(new SqlParameter("Mobile_No", regClientMasterModel.Mobile_No.handleDBNull()));
            list.Add(new SqlParameter("EmailID1", regClientMasterModel.EmailID1.handleDBNull()));
            list.Add(new SqlParameter("Website", regClientMasterModel.Website.handleDBNull()));
            list.Add(new SqlParameter("BussinessType", regClientMasterModel.BussinessType.handleDBNull()));
            list.Add(new SqlParameter("Status", regClientMasterModel.Status.handleDBNull()));
            list.Add(new SqlParameter("Show_CertImage", regClientMasterModel.Show_CertImage.handleDBNull()));
            list.Add(new SqlParameter("FLAG", FLAG));
            SqlParameter sqlParameter = new SqlParameter("RETURNVAL", SqlDbType.NVarChar, 500);
            sqlParameter.Value = value;
            sqlParameter.Direction = ParameterDirection.Output;
            list.Add(sqlParameter);
            new AppDataContext().Database.SqlQuery<object>("SpClientMasterCrud".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
            return Convert.ToString(sqlParameter.Value);
        }

        // Client MAster End
        #endregion

        #region Registration
        public ClientMasterModel getPassword(ClientMasterModel reqClientLoginData)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("Email", reqClientLoginData.RequestMail.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ClientMasterModel>("spGetPassword".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
        }
        #endregion

        #region Product

        public List<StoneListModel> getStoneList(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            //list.Add(new SqlParameter("SC_Status", reqRequestParam.SC_Status.handleDBNull()));
            //list.Add(new SqlParameter("SC_CUR_STATUS", reqRequestParam.SC_CUR_STATUS.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<StoneListModel>("SpStoneList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public string CrudImportProduct(StoneListModel reqProductModel, string FLAG = "")
        {
            string value = "0";
            List<SqlParameter> list = new List<SqlParameter>();
            //list.Add(new SqlParameter("Id", reqStudentModel.Id.handleDBNull()));
            list.Add(new SqlParameter("COMPCD", reqProductModel.COMPCD.handleDBNull()));
            list.Add(new SqlParameter("STONEID", reqProductModel.STONEID.handleDBNull()));
            list.Add(new SqlParameter("SHAPE", reqProductModel.SHAPE.handleDBNull()));
            list.Add(new SqlParameter("CTS", reqProductModel.CTS.handleDBNull()));
            list.Add(new SqlParameter("COLOR", reqProductModel.COLOR.handleDBNull()));
            list.Add(new SqlParameter("CLARITY", reqProductModel.CLARITY.handleDBNull()));
            list.Add(new SqlParameter("CUT", reqProductModel.CUT.handleDBNull()));
            list.Add(new SqlParameter("POLISH", reqProductModel.POLISH.handleDBNull()));
            list.Add(new SqlParameter("SYM", reqProductModel.SYM.handleDBNull()));
            list.Add(new SqlParameter("FLOURENCE", reqProductModel.FLOURENCE.handleDBNull()));
            list.Add(new SqlParameter("FL_COLOR", reqProductModel.FL_COLOR.handleDBNull()));
            list.Add(new SqlParameter("INCLUSION", reqProductModel.INCLUSION.handleDBNull()));
            list.Add(new SqlParameter("HA", reqProductModel.HA.handleDBNull()));
            list.Add(new SqlParameter("LUSTER", reqProductModel.LUSTER.handleDBNull()));
            list.Add(new SqlParameter("GIRDLE", reqProductModel.GIRDLE.handleDBNull()));
            list.Add(new SqlParameter("GIRDLE_CONDITION", reqProductModel.GIRDLE_CONDITION.handleDBNull()));
            list.Add(new SqlParameter("CULET", reqProductModel.CULET.handleDBNull()));
            list.Add(new SqlParameter("MILKY", reqProductModel.MILKY.handleDBNull()));
            list.Add(new SqlParameter("SHADE", reqProductModel.SHADE.handleDBNull()));
            list.Add(new SqlParameter("NATTS", reqProductModel.NATTS.handleDBNull()));
            list.Add(new SqlParameter("NATURAL", reqProductModel.NATURAL.handleDBNull()));
           // list.Add(new SqlParameter("DEPTH", reqProductModel.NATURAL.handleDBNull()));
            list.Add(new SqlParameter("DIATABLE", reqProductModel.DIATABLE.handleDBNull()));
            list.Add(new SqlParameter("LENGTH", reqProductModel.LENGTH.handleDBNull()));
            list.Add(new SqlParameter("WIDTH", reqProductModel.WIDTH.handleDBNull()));
            list.Add(new SqlParameter("PAVILION", reqProductModel.PAVILION.handleDBNull()));
            list.Add(new SqlParameter("CROWN", reqProductModel.CROWN.handleDBNull()));
            list.Add(new SqlParameter("PAVANGLE", reqProductModel.PAVANGLE.handleDBNull()));
            list.Add(new SqlParameter("CROWNANGLE", reqProductModel.CROWNANGLE.handleDBNull()));
            list.Add(new SqlParameter("HEIGHT", reqProductModel.HEIGHT.handleDBNull()));
            list.Add(new SqlParameter("PAVHEIGHT", reqProductModel.PAVHEIGHT.handleDBNull()));
            list.Add(new SqlParameter("CROWNHEIGHT", reqProductModel.CROWNHEIGHT.handleDBNull()));
            list.Add(new SqlParameter("MEASUREMENT", reqProductModel.MEASUREMENT.handleDBNull()));
            list.Add(new SqlParameter("RATIO", reqProductModel.RATIO.handleDBNull()));
            list.Add(new SqlParameter("PAIR", reqProductModel.PAIR.handleDBNull()));
            list.Add(new SqlParameter("STAR_LENGTH", reqProductModel.STAR_LENGTH.handleDBNull()));
            list.Add(new SqlParameter("LOWER_HALF", reqProductModel.LOWER_HALF.handleDBNull()));
            list.Add(new SqlParameter("KEY_TO_SYMBOL", reqProductModel.KEY_TO_SYMBOL.handleDBNull()));
            list.Add(new SqlParameter("REPORT_COMMENT", reqProductModel.REPORT_COMMENT.handleDBNull()));
            list.Add(new SqlParameter("CERTIFICATE", reqProductModel.CERTIFICATE.handleDBNull()));
            list.Add(new SqlParameter("CERTNO", reqProductModel.CERTNO.handleDBNull()));
            list.Add(new SqlParameter("RAPARATE", reqProductModel.RAPARATE.handleDBNull()));
            list.Add(new SqlParameter("RAPAAMT", reqProductModel.RAPAAMT.handleDBNull()));
            list.Add(new SqlParameter("CURDATE", reqProductModel.CURDATE.handleDBNull()));
            list.Add(new SqlParameter("LOCATION", reqProductModel.LOCATION.handleDBNull()));
            list.Add(new SqlParameter("LEGEND1", reqProductModel.LEGEND1.handleDBNull()));
            list.Add(new SqlParameter("LEGEND2", reqProductModel.LEGEND2.handleDBNull()));
            list.Add(new SqlParameter("LEGEND3", reqProductModel.LEGEND3.handleDBNull()));
            list.Add(new SqlParameter("ASKRATE_FC", reqProductModel.ASKRATE_FC.handleDBNull()));
            list.Add(new SqlParameter("ASKDISC_FC", reqProductModel.ASKDISC_FC.handleDBNull()));
            list.Add(new SqlParameter("ASKAMT_FC", reqProductModel.ASKAMT_FC.handleDBNull()));
            list.Add(new SqlParameter("COSTRATE_FC", reqProductModel.COSTRATE_FC.handleDBNull()));
            list.Add(new SqlParameter("COSTDISC_FC", reqProductModel.COSTDISC_FC.handleDBNull()));
            list.Add(new SqlParameter("COSTAMT_FC", reqProductModel.COSTAMT_FC.handleDBNull()));
            list.Add(new SqlParameter("WEB_CLIENTID", reqProductModel.WEB_CLIENTID.handleDBNull()));
            list.Add(new SqlParameter("wl_rej_status", reqProductModel.wl_rej_status.handleDBNull()));
            list.Add(new SqlParameter("GIRDLEPER", reqProductModel.GIRDLEPER.handleDBNull()));
            list.Add(new SqlParameter("DIA", reqProductModel.DIA.handleDBNull()));
            list.Add(new SqlParameter("COLORDESC", reqProductModel.COLORDESC.handleDBNull()));
            list.Add(new SqlParameter("BARCODE", reqProductModel.BARCODE.handleDBNull()));
            list.Add(new SqlParameter("INSCRIPTION", reqProductModel.INSCRIPTION.handleDBNull()));
            list.Add(new SqlParameter("NEW_CERT", reqProductModel.NEW_CERT.handleDBNull()));
            list.Add(new SqlParameter("MEMBER_COMMENT", reqProductModel.MEMBER_COMMENT.handleDBNull()));
            list.Add(new SqlParameter("UPLOADCLIENTID", reqProductModel.UPLOADCLIENTID.handleDBNull()));
            list.Add(new SqlParameter("REPORT_DATE", reqProductModel.REPORT_DATE.handleDBNull()));
            list.Add(new SqlParameter("NEW_ARRI_DATE", reqProductModel.NEW_ARRI_DATE.handleDBNull()));
            list.Add(new SqlParameter("TINGE", reqProductModel.TINGE.handleDBNull()));
            list.Add(new SqlParameter("EYE_CLN", reqProductModel.EYE_CLN.handleDBNull()));
            list.Add(new SqlParameter("TABLE_INCL", reqProductModel.TABLE_INCL.handleDBNull()));
            list.Add(new SqlParameter("SIDE_INCL", reqProductModel.SIDE_INCL.handleDBNull()));
            list.Add(new SqlParameter("TABLE_BLACK", reqProductModel.TABLE_BLACK.handleDBNull()));
            list.Add(new SqlParameter("SIDE_BLACK", reqProductModel.SIDE_BLACK.handleDBNull()));
            list.Add(new SqlParameter("TABLE_OPEN", reqProductModel.TABLE_OPEN.handleDBNull()));
            list.Add(new SqlParameter("SIDE_OPEN", reqProductModel.SIDE_OPEN.handleDBNull()));
            list.Add(new SqlParameter("PAV_OPEN", reqProductModel.PAV_OPEN.handleDBNull()));
            list.Add(new SqlParameter("EXTRA_FACET", reqProductModel.EXTRA_FACET.handleDBNull()));
            list.Add(new SqlParameter("INTERNAL_COMMENT", reqProductModel.INTERNAL_COMMENT.handleDBNull()));
            list.Add(new SqlParameter("POLISH_FEATURES", reqProductModel.POLISH_FEATURES.handleDBNull()));
            list.Add(new SqlParameter("SYMMETRY_FEATURES", reqProductModel.SYMMETRY_FEATURES.handleDBNull()));
            list.Add(new SqlParameter("GRAINING", reqProductModel.GRAINING.handleDBNull()));
            list.Add(new SqlParameter("IMG_URL", reqProductModel.IMG_URL.handleDBNull()));
            list.Add(new SqlParameter("RATEDISC", reqProductModel.RATEDISC.handleDBNull()));
            list.Add(new SqlParameter("GRADE", reqProductModel.GRADE.handleDBNull()));
            list.Add(new SqlParameter("CLIENT_LOCATION", reqProductModel.CLIENT_LOCATION.handleDBNull()));
            list.Add(new SqlParameter("ORIGIN", reqProductModel.ORIGIN.handleDBNull()));
            list.Add(new SqlParameter("BGM", reqProductModel.BGM.handleDBNull()));
            list.Add(new SqlParameter("FLAG", FLAG));
            SqlParameter sqlParameter = new SqlParameter("RETURNVAL", SqlDbType.NVarChar, 500);
            sqlParameter.Value = value;
            sqlParameter.Direction = ParameterDirection.Output;
            list.Add(sqlParameter);
            new AppDataContext().Database.SqlQuery<object>("SpStoneListCrud".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
            return Convert.ToString(sqlParameter.Value);
        }
        public static DataTable ExportData(RequestParam reqRequestParam, string Flag)
        {

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(Conn))
            {
                string spName = "";
                if (Flag == "Banner")
                {
                    spName = "BannerList";
                }
                else if (Flag == "Procmos")
                {
                    spName = "SpProcmasList";
                }
                else if (Flag == "Client")
                {
                    spName = "SpClientMasterList";
                }
                else if (Flag == "Stone")
                {
                    spName = "SpStoneList";
                }
                else if (Flag == "Order")
                {
                    spName = "SpOrderList";
                }
                //string spName = "BannerList";
                using (SqlCommand cmd = new SqlCommand("dbo." + spName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("whereclause", reqRequestParam.whereClause.handleDBNull());
                    cmd.Parameters.AddWithValue("orderby", reqRequestParam.orderByClause.handleDBNull());
                    cmd.Parameters.AddWithValue("pagesize", Convert.ToInt32(reqRequestParam.PageSize).handleDBNull());
                    cmd.Parameters.AddWithValue("pageno", Convert.ToInt32(reqRequestParam.pageno).handleDBNull());

                    if (con.State == ConnectionState.Closed)
                    {
                        con.Open();
                    }
                    DataSet ds = new DataSet();
                    SqlDataAdapter loAdapter = new SqlDataAdapter();
                    loAdapter.SelectCommand = cmd;
                    loAdapter.Fill(ds);
                    dt = ds.Tables[0];
                }
            }
            return dt;
        }
        public static DataTable getInventoryListData(RequestParam reqRequestParam)
        {

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(Conn))
            {
                string spName = "SpStoneList";
                using (SqlCommand cmd = new SqlCommand("dbo." + spName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("whereclause", reqRequestParam.whereClause.handleDBNull());
                    cmd.Parameters.AddWithValue("orderby", reqRequestParam.orderByClause.handleDBNull());
                    cmd.Parameters.AddWithValue("pagesize", Convert.ToInt32(reqRequestParam.PageSize).handleDBNull());
                    cmd.Parameters.AddWithValue("pageno", Convert.ToInt32(reqRequestParam.pageno).handleDBNull());

                    if (con.State == ConnectionState.Closed)
                    {
                        con.Open();
                    }
                    DataSet ds = new DataSet();
                    SqlDataAdapter loAdapter = new SqlDataAdapter();
                    loAdapter.SelectCommand = cmd;
                    loAdapter.Fill(ds);
                    dt = ds.Tables[0];
                }
            }
            return dt;
        }
        public string CrudShopingCart(ShoppingCartModel reqShoppingCart, string Flag)

        {
            string value = "0";
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("SC_Id", reqShoppingCart.SC_Id.handleDBNull()));
            list.Add(new SqlParameter("SC_stoneid", reqShoppingCart.SC_stoneid.handleDBNull()));
            list.Add(new SqlParameter("SC_Clientcd", reqShoppingCart.SC_Clientcd.handleDBNull()));
            list.Add(new SqlParameter("SC_Status", reqShoppingCart.SC_Status.handleDBNull()));
            list.Add(new SqlParameter("SC_CUR_STATUS", reqShoppingCart.SC_CUR_STATUS.handleDBNull()));
            list.Add(new SqlParameter("FLAG", Flag));
            SqlParameter sqlParameter = new SqlParameter("RETURNVAL", SqlDbType.NVarChar, 500);
            sqlParameter.Value = value;
            sqlParameter.Direction = ParameterDirection.Output;
            list.Add(sqlParameter);
            new AppDataContext().Database.SqlQuery<object>("SpShoppingCartCrud".getSql(list), list.Cast<object>().ToArray()).FirstOrDefault();
            return Convert.ToString(sqlParameter.Value);
        }
        #endregion


        public List<ShoppingCartModel> getShoppingCartList(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ShoppingCartModel>("SpShoppingCartList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public List<ShoppingCartModel> getOrderListData(RequestParam reqRequestParam)
        {
            List<SqlParameter> list = new List<SqlParameter>();
            list.Add(new SqlParameter("whereclause", reqRequestParam.whereClause.handleDBNull()));
            list.Add(new SqlParameter("orderby", reqRequestParam.orderByClause.handleDBNull()));
            list.Add(new SqlParameter("pagesize", reqRequestParam.PageSize.handleDBNull()));
            list.Add(new SqlParameter("pageno", reqRequestParam.pageno.handleDBNull()));
            return new AppDataContext().Database.SqlQuery<ShoppingCartModel>("SpOrderList".getSql(list), list.Cast<object>().ToArray()).ToList();
        }
        public string GetDateHandle(DateTime reqDate)
        {
            string strDate = "";
            if (reqDate != null)
            {
                strDate = reqDate.ToString("dd/MM/yyyy");
            }
            if (strDate == "01-01-1900")
            {
                strDate = "";
            }
            if (strDate == "01-01-0001")
            {
                strDate = "";
            }
            return strDate;
        }

    }
    public class RequestParam
    {
        public string whereClause { get; set; }
        public string orderByClause { get; set; }
        public int? PageSize { get; set; }
        public int? pageno { get; set; }
    }
}
