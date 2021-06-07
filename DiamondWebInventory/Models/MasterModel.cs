using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace DiamondWebInventory.Models
{
    public class MasterModel
    {
    }
    public class AdminModel
    {
        public int? Id { get; set; }
        public string Name { get; set; }
        public string Email_Id { get; set; }
        public string Password { get; set; }
        public string User_Profile_Image { get; set; }
    }
    public class ConactModel
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public string Subject { get; set; }
        public string YourMessage { get; set; }
    }
    public class BannerModel
    {
        public int Id { get; set; }
        [Required]
        public string Title { get; set; }
        [Required]
        public string ImageType { get; set; }
        [Required]
        public string ClickUrl { get; set; }
        public Nullable<Boolean> IsActive { get; set; }
        public Nullable<Boolean> IsDeleted { get; set; }
        public DateTime InsertedDate { get; set; }
        public DateTime UpdatedDate { get; set; }
        public int pageno { get; set; }
        public int TotalRecords { get; set; }
        public string Status { get; set; }
    }
    public class ProcmasModel
    {
        public int Id { get; set; }
        public string Procgroup { get; set; }
        public Decimal Proccd { get; set; }
        public string Procnm { get; set; }
        public string Shortnm { get; set; }
        public Decimal Ord { get; set; }
        //public string Status { get; set; }
        public string Fancy_Color_Status { get; set; }
        public Boolean IsChangeable { get; set; }
        public string Fancy_Color { get; set; }
        public string Fancy_Intensity { get; set; }
        public string Fancy_Overtone { get; set; }
        public string F_CTS { get; set; }
        public string T_CTS { get; set; }
        public Nullable<Boolean> IsDeleted { get; set; }
        public DateTime InsertedDate { get; set; }
        public DateTime UpdatedDate { get; set; }
        public Nullable<Boolean> IsActive { get; set; }

        public int pageno { get; set; }
        public int TotalRecords { get; set; }
        public string Status1 { get; set; }


    }
    public class ddlmodel
    {
        public string Name { get; set; }
        public string val { get; set; }
    }
    public class ClientMasterModel
    {
        public string RequestMail { get; set; }

        public int ClientCd { get; set; }
        public string LoginName { get; set; }
        public string Password { get; set; }
        public string Title { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime Birthdate { get; set; }
        public string CompanyNm { get; set; }
        public string Designation { get; set; }
        public string Terms { get; set; }
        public Decimal CreditDays { get; set; }
        public Decimal Commission { get; set; }
        public Decimal Brokerage { get; set; }
        public Decimal PriceDiscount { get; set; }
        public Decimal Discount { get; set; }
        public string PriceFormat { get; set; }
        public string TaxDetails { get; set; }
        public string ReferenceFrom { get; set; }
        public string ReferenceThrough { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Zipcode { get; set; }
        public string Countrycd { get; set; }
        public string Phone_Countrycd { get; set; }
        public string Phone_STDcd { get; set; }
        public string Phone_No { get; set; }
        public string Phone_Countrycd2 { get; set; }
        public string Phone_STDCd2 { get; set; }
        public string Phone_No2 { get; set; }
        public string Fax_Countrycd { get; set; }
        public string Fax_STDCd { get; set; }
        public string Fax_No { get; set; }
        public string Mobile_CountryCd { get; set; }
        public string Mobile_No { get; set; }
        public string EmailID1 { get; set; }
        public string EmailID2 { get; set; }
        public string EmailID3 { get; set; }
        public string All_EmailId { get; set; }
        public string Website { get; set; }
        public string BussinessType { get; set; }
        public DateTime InsertedDate { get; set; }
        public Decimal CreatedBy { get; set; }
        public DateTime UpdatedDate { get; set; }
        public Decimal UpdatedBy { get; set; }
        public string ApproveStatus { get; set; }
        public DateTime ApproveStatusOn { get; set; }
        public Decimal ApproveStatusBy { get; set; }
        public DateTime StatusUpdatedOn { get; set; }
        public Decimal StatusUpdatedBy { get; set; }
        public string Status { get; set; }
        public string WholeStockAccess { get; set; }
        public string BankDetails { get; set; }
        public string RoutingDetails { get; set; }
        public int Handle_Location { get; set; }
        public int Smid { get; set; }
        public string EmailStatus { get; set; }
        public DateTime LastLoginDate { get; set; }
        public string SkypeId { get; set; }
        public string QQId { get; set; }
        public string EmailSubscr { get; set; }
        public DateTime EmailSubscrDate { get; set; }
        public int UtypeId { get; set; }
        public string UserRights { get; set; }
        public string UploadInventory { get; set; }
        public string Show_HoldedStock { get; set; }
        public DateTime LoginMailAlertOn { get; set; }
        public string Show_CertImage { get; set; }
        public string App_Id { get; set; }
        public string App_Pwd { get; set; }
        public string WeChatId { get; set; }
        public int Client_Grade { get; set; }
        public int WatchList_Priority { get; set; }
        public string ShipmentType { get; set; }
        public string SecurityPin { get; set; }
        public Decimal Online_ClientCd { get; set; }
        public Decimal Online_SellerCd { get; set; }
        public Nullable<Boolean> IsActive { get; set; }
        public Nullable<Boolean> IsDeleted { get; set; }

        public string strBirthdate { get; set; }
        public string strInsertedDate { get; set; }
        public string strUpdatedDate { get; set; }
        public string strApproveStatusOn { get; set; }
        public string strStatusUpdatedOn { get; set; }
        public string strLastLoginDate { get; set; }
        public string strEmailSubscrDate { get; set; }
        public string strLoginMailAlertOn { get; set; }

        public int pageno { get; set; }
        public int TotalRecords { get; set; }
        public string Status1 { get; set; }


    }
    public class StoneListModel
    {
        public string Range { get; set; }
        public int Id { get; set; }
        public decimal? COMPCD { get; set; }

        public string STONEID { get; set; }
        public string SHAPE { get; set; }

        public decimal? CTS { get; set; }
        public decimal? FromCTS { get; set; }
        public decimal? ToCTS { get; set; }

        public string COLOR { get; set; }

        public string CLARITY { get; set; }

        public string CUT { get; set; }

        public string POLISH { get; set; }

        public string SYM { get; set; }

        public string FLOURENCE { get; set; }

        public string FL_COLOR { get; set; }

        public string INCLUSION { get; set; }

        public string HA { get; set; }

        public string LUSTER { get; set; }

        public string GIRDLE { get; set; }

        public string GIRDLE_CONDITION { get; set; }

        public string CULET { get; set; }

        public string MILKY { get; set; }

        public string SHADE { get; set; }

        public string NATTS { get; set; }

        public string NATURAL { get; set; }

        public decimal? DEPTH { get; set; }

        public decimal? DIATABLE { get; set; }

        public decimal? LENGTH { get; set; }

        public decimal? WIDTH { get; set; }

        public decimal? PAVILION { get; set; }

        public decimal? CROWN { get; set; }

        public decimal? PAVANGLE { get; set; }

        public decimal? CROWNANGLE { get; set; }

        public decimal? HEIGHT { get; set; }

        public decimal? PAVHEIGHT { get; set; }

        public decimal? CROWNHEIGHT { get; set; }

        public string MEASUREMENT { get; set; }

        public decimal? RATIO { get; set; }

        public string PAIR { get; set; }

        public decimal? STAR_LENGTH { get; set; }

        public decimal? LOWER_HALF { get; set; }

        public string KEY_TO_SYMBOL { get; set; }

        public string REPORT_COMMENT { get; set; }

        public string CERTIFICATE { get; set; }
        public string CERTNO { get; set; }

        public decimal? RAPARATE { get; set; }
        public decimal? FromPrice { get; set; }
        public decimal? ToPrice { get; set; }

        public decimal? RAPAAMT { get; set; }

        public DateTime CURDATE { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }

        public string LOCATION { get; set; }

        public string LEGEND1 { get; set; }

        public string LEGEND2 { get; set; }

        public string LEGEND3 { get; set; }

        public decimal? ASKRATE_FC { get; set; }

        public decimal? ASKDISC_FC { get; set; }

        public decimal? ASKAMT_FC { get; set; }

        public decimal? COSTRATE_FC { get; set; }

        public decimal? COSTDISC_FC { get; set; }
        public decimal? FromDisc { get; set; }
        public decimal? ToDisc { get; set; }


        public decimal? COSTAMT_FC { get; set; }
        public decimal? FromAmt { get; set; }
        public decimal? ToAmt { get; set; }


        public decimal? WEB_CLIENTID { get; set; }

        public string wl_rej_status { get; set; }

        public string GIRDLEPER { get; set; }

        public decimal? DIA { get; set; }

        public string COLORDESC { get; set; }

        public string BARCODE { get; set; }

        public string INSCRIPTION { get; set; }

        public string NEW_CERT { get; set; }

        public string MEMBER_COMMENT { get; set; }

        public int? UPLOADCLIENTID { get; set; }

        public DateTime REPORT_DATE { get; set; }

        public DateTime NEW_ARRI_DATE { get; set; }

        public string TINGE { get; set; }

        public string EYE_CLN { get; set; }

        public string TABLE_INCL { get; set; }

        public string SIDE_INCL { get; set; }

        public string TABLE_BLACK { get; set; }

        public string SIDE_BLACK { get; set; }

        public string TABLE_OPEN { get; set; }

        public string SIDE_OPEN { get; set; }

        public string PAV_OPEN { get; set; }

        public string EXTRA_FACET { get; set; }

        public string INTERNAL_COMMENT { get; set; }

        public string POLISH_FEATURES { get; set; }

        public string SYMMETRY_FEATURES { get; set; }

        public string GRAINING { get; set; }

        public string IMG_URL { get; set; }

        public string RATEDISC { get; set; }

        public string GRADE { get; set; }

        public string CLIENT_LOCATION { get; set; }

        public string ORIGIN { get; set; }

        public string BGM { get; set; }

        public string strCURDATE { get; set; }
        public string strREPORT_DATE { get; set; }
        public string strNEW_ARRI_DATE { get; set; }

        public int pageno { get; set; }
        public int TotalRecords { get; set; }



    }
    public class ShoppingCartModel
    {
        public int SC_Id { get; set; }

        public string SC_stoneid { get; set; }

        public int? SC_Clientcd { get; set; }

        public string SC_Status { get; set; }

        public DateTime? SC_Date { get; set; }

        public DateTime? SC_MemoDate { get; set; }

        public DateTime? SC_delete_date { get; set; }

        public decimal? sc_offerrate { get; set; }

        public decimal? sc_offerdisc { get; set; }

        public string sc_rej_status { get; set; }

        public string SC_PROCESSEES { get; set; }

        public string SC_CUR_STATUS { get; set; }

        public string isMailed { get; set; }

        public DateTime? sc_mail_date { get; set; }

        public decimal? orderno { get; set; }

        public string SC_SHAPE { get; set; }

        public decimal? SC_CTS { get; set; }

        public string SC_COLOR { get; set; }

        public string SC_CLARITY { get; set; }

        public string SC_CUT { get; set; }

        public string SC_POLISH { get; set; }

        public string SC_SYM { get; set; }

        public string SC_FLOURENCE { get; set; }

        public string SC_FL_COLOR { get; set; }

        public string SC_INCLUSION { get; set; }

        public string SC_HA { get; set; }

        public string SC_LUSTER { get; set; }

        public string SC_GIRDLE { get; set; }

        public string SC_GIRDLE_CONDITION { get; set; }

        public string SC_CULET { get; set; }

        public string SC_MILKY { get; set; }

        public string SC_SHADE { get; set; }

        public string SC_NATTS { get; set; }

        public string SC_NATURAL { get; set; }

        public decimal? SC_DEPTH { get; set; }

        public decimal? SC_DIATABLE { get; set; }

        public decimal? SC_LENGTH { get; set; }

        public decimal? SC_WIDTH { get; set; }

        public decimal? SC_PAVILION { get; set; }

        public decimal? SC_CROWN { get; set; }

        public decimal? SC_PAVANGLE { get; set; }

        public decimal? SC_CROWNANGLE { get; set; }

        public decimal? SC_HEIGHT { get; set; }

        public decimal? SC_PAVHEIGHT { get; set; }

        public decimal? SC_CROWNHEIGHT { get; set; }

        public string SC_MEASUREMENT { get; set; }

        public decimal? SC_RATIO { get; set; }

        public string SC_PAIR { get; set; }

        public decimal? SC_STAR_LENGTH { get; set; }

        public decimal? SC_LOWER_HALF { get; set; }

        public string SC_KEY_TO_SYMBOL { get; set; }

        public string SC_REPORT_COMMENT { get; set; }

        public string SC_CERTIFICATE { get; set; }

        public string SC_CERTNO { get; set; }

        public decimal? SC_RAPARATE { get; set; }

        public decimal? SC_RAPAAMT { get; set; }

        public DateTime? SC_CURDATE { get; set; }

        public string SC_LOCATION { get; set; }

        public string SC_LEGEND1 { get; set; }

        public string SC_LEGEND2 { get; set; }

        public string SC_LEGEND3 { get; set; }

        public decimal? SC_ASKRATE_FC { get; set; }

        public decimal? SC_ASKDISC_FC { get; set; }

        public decimal? SC_ASKAMT_FC { get; set; }

        public decimal? SC_COSTRATE_FC { get; set; }

        public decimal? SC_COSTDISC_FC { get; set; }

        public decimal? SC_COSTAMT_FC { get; set; }

        public string SC_GIRDLEPER { get; set; }

        public decimal? SC_DIA { get; set; }

        public string SC_COLORDESC { get; set; }

        public string SC_BARCODE { get; set; }

        public string SC_INSCRIPTION { get; set; }

        public string SC_NEW_CERT { get; set; }

        public string SC_MEMBER_COMMENT { get; set; }

        public int? SC_UPLOADCLIENTID { get; set; }

        public DateTime? SC_REPORT_DATE { get; set; }

        public DateTime? SC_NEW_ARRI_DATE { get; set; }

        public string SC_TINGE { get; set; }

        public string SC_EYE_CLN { get; set; }

        public string SC_TABLE_INCL { get; set; }

        public string SC_SIDE_INCL { get; set; }

        public string SC_TABLE_BLACK { get; set; }

        public string SC_SIDE_BLACK { get; set; }

        public string SC_TABLE_OPEN { get; set; }

        public string SC_SIDE_OPEN { get; set; }

        public string SC_PAV_OPEN { get; set; }

        public string SC_EXTRA_FACET { get; set; }

        public string SC_INTERNAL_COMMENT { get; set; }

        public string SC_POLISH_FEATURES { get; set; }

        public string SC_SYMMETRY_FEATURES { get; set; }

        public string SC_GRAINING { get; set; }

        public string SC_IMG_URL { get; set; }

        public string SC_RATEDISC { get; set; }

        public string SC_GRADE { get; set; }

        public string SC_CLIENT_LOCATION { get; set; }

        public string SC_ORIGIN { get; set; }

        public string BUY_REQID { get; set; }

        public string ERP_PROFORMA_ID { get; set; }

        public string ERP_INVOICE_ID { get; set; }

        public DateTime? ERP_INVOICE_DATE { get; set; }

        public string FirstName { get; set; }
        public string EmailID1 { get; set; }

        public int pageno { get; set; }
        public int TotalRecords { get; set; }

    }

    public class Pager
    {
        public Pager(int totalItems, int? page, int pageSize = 10)
        {
            // Total Paging need to show
            int _totalPages = (int)Math.Ceiling((decimal)totalItems / (decimal)pageSize);
            //Current Page
            int _currentPage = page != null ? (int)page : 1;
            //Paging to be starts with
            int _startPage = _currentPage - 5;
            //Paging to be end with
            int _endPage = _currentPage + 4;
            if (_startPage <= 0)
            {
                _endPage -= (_startPage - 1);
                _startPage = 1;
            }
            if (_endPage > _totalPages)
            {
                _endPage = _totalPages;
                if (_endPage > 10)
                {
                    _startPage = _endPage - 9;
                }
            }
            //Setting up the properties
            TotalItems = totalItems;
            CurrentPage = _currentPage;
            PageSize = pageSize;
            TotalPages = _totalPages;
            StartPage = _startPage;
            EndPage = _endPage;
        }
        public int TotalItems { get; set; }
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
        public int StartPage { get; set; }
        public int EndPage { get; set; }
    }

}



