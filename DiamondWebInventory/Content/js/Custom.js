var mController = "/Admin";
var HomeController = "/Home";

function Showloader() {
    $("#loaderWrapper").show();
    $("#loaderWrapper").fadeIn(100);
}
function Hideloader() {
    $("#loaderWrapper").fadeOut(100);
}

function AdminLogin() {
    var postdata = {
        Email_Id: $("#txtEmail_Id").val(),
        Password: $("#txtPassword").val()
    }
    $.ajax({
        url: mController + '/AdminLoginData',
        type: 'POST',
        data: postdata,
        async: false,
        success: function (data) {
            console.log(data)
            if (data.retVal == "Success") {
                window.location.href = "/admin/dashboard";
            }
            else {
                $("#errormsg").text(data.retValMsg);
            }
        }
    });
}

SliderDataList()
function SliderDataList() {
    $.ajax({
        url: mController + '/GetBannerData',
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);

            var response = data.lstBannerModel;
            var html = "";
            var html = "";
            $("#SliderData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    if (response[i].IsActive == true) {
                        html += '<li><img src="/UploadImage/' + response[i].ImageType + ' "/></li>';
                    }
                }
                $("#SliderData").append(html);
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });

}

function GetBannerListData(pageno) {
    var reqBannerModel = {
        Title: $("#txtSearchTitle").val(),
        pageno: pageno
    }
    $.ajax({
        url: mController + '/GetBannerData',
        data: reqBannerModel,
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.lstBannerModel;
            var html = "";
            $("#BaneerListData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    html += "<tr>";
                    html += "<td>" + response[i].Title + "</td>";
                    html += '<td><img src="/UploadImage/' + response[i].ImageType + ' " height="80px" width="100px" style="padding-right:10px"/></td>';
                    html += "<td>" + response[i].ClickUrl + "</td>";
                    html += "<td>" + response[i].Status + "</td>";
                    html += "<td><a href='#' onclick='OpenEditForm(" + response[i].Id + ")'>Edit</a>&nbsp;<a href='#' onclick='DeleteBanner(" + response[i].Id + ")'>Delete</a></td>";
                    html += "</tr>";
                }
                $("#BaneerListData").append(html);
                BannerPagination(10, Totalrecord);
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function OpenBannerAddForm() {
    $("#hdnBannerId").val('');
    $("#BannerModel :input").val('');
    $("#BannerModel").modal("show");
}
function BannerPagination(pagesize, totalrecord) {
    pageSize = pagesize;
    var pageCount = totalrecord / pageSize;
    $("#pagenation").empty();
    for (var i = 0 ; i < pageCount; i++) {
        var index = i + 1;
        $("#pagenation").append('<li><a href="#" class="page-link" onclick="GetBannerListData(' + index + ')">' + index + '</a></li> ');
    }
    $("#TotalRecords").text('Total Records :' + totalrecord);
    $("#pagenation li").first().find("a").addClass("current");
}
function InsertBanner() {
    $("#BannerForm").validate({
        rules: {
            txtTitle: {
                required: true
            },
            //Imagefile: {
            //    required: true
            //},
            txtClickUrl: {
                required: true,
            },
            //},
            //messages: {
            //    txtTitle: {
            //        required: "This field is required",
            //    },
            //    //Imagefile: {
            //    //    required: "Choose image file",
            //    //},
            //    txtClickUrl: {
            //        required: "This field is required",
            //    },
        }, submitHandler: function (form) {
            if (window.FormData !== undefined) {

                var fileUpload = $("#Imagefile").get(0);
                var files = fileUpload.files;

                // Create FormData object
                var fileData = new FormData();

                // Looping over all files and add it to FormData object
                for (var i = 0; i < files.length; i++) {
                    fileData.append(files[i].name, files[i]);
                }

                // Adding one more key to FormData object
                //fileData.append('username', ‘Manas’);
                fileData.append('Id', $("#hdnBannerId").val());
                fileData.append('Title', $("#txtTitle").val());
                fileData.append('ClickUrl', $("#txtClickUrl").val());
                fileData.append('IsActive', $("#chkIsActive").is(":checked"));
                $.ajax(
                {
                    url: mController + '/SaveBanner',
                    contentType: false,
                    processData: false,
                    data: fileData,
                    type: 'POST',
                    success: function (data) {
                        console.log(data)
                        $("#BannerModel").modal("hide");
                        GetBannerListData();
                    },
                    error: function (err) {
                        alert(err.statusText);
                    }
                });
            } else {
                alert("FormData is not supported.");
            }
        }
    });
}
function OpenEditForm(id) {
    $.ajax({
        url: mController + '/GetBannerManageData',
        data: 'id=' + $.trim(id),
        type: 'POST',
        async: true,
        //beforeSend: function () {
        //    Showloader();
        //},
        success: function (data) {
            console.log(data);
            var response = data.objBannerModel;
            var Title = response.Title;
            var ImageType = response.ImageType;
            var ClickUrl = response.ClickUrl;
            var IsActive = response.IsActive;
            $("#hdnBannerId").val(response.Id);
            $("#txtTitle").val(Title);
            $("#Imagefile").val('');
            $("#txtClickUrl").val(ClickUrl);
            if (IsActive == true) {
                $("#chkIsActive").prop('checked', true);
            } else {
                $("#chkIsActive").prop('checked', false);
            }
            $("#BannerModel").modal("show");
        },
        error: function () {
        },
        //complete: function () {
        //    Hideloader();
        //}
    });
}
function DeleteBanner(id) {
    var reqBanner = {
        Id: id
    }
    if (confirm("If you want to delete this row ?")) {
        $.ajax({
            url: mController + '/DeleteBanner',
            data: reqBanner,
            type: 'POST',
            success: function (data) {
                console.log(data);
                $("#BannerModel").modal("hide");
                GetBannerListData();
            },
            error: function () {
                console.log("error");
            },
        });
    }
}
function BannerResetData() {
    $(".criteria :input").val('');
    GetBannerListData();
}

function GetProcmasListData(pageno) {
    var reqProcmas = {
        Procgroup: $("#txtSearchProcgroup").val(),
        Procnm: $("#txtSearchProcnm").val(),
        pageno: pageno,
    }
    $.ajax({
        url: mController + '/GetProcmasData',
        data: reqProcmas,
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.lstProcmasModel;
            var html = "";
            $("#ProcmasListData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    html += "<tr>";
                    html += "<td>" + response[i].Procgroup + "</td>";
                    html += "<td>" + response[i].Proccd + "</td>";
                    html += "<td>" + response[i].Procnm + "</td>";
                    html += "<td>" + response[i].Shortnm + "</td>";
                    html += "<td>" + response[i].Ord + "</td>";
                    html += "<td>" + response[i].Status1 + "</td>";
                    html += "<td><a href='#' onclick='OpenEditProcmasForm(" + response[i].Id + ")'>Edit</a>&nbsp;<a href='#' onclick='DeleteProcmas(" + response[i].Id + ")'>Delete</a></td>";
                    html += "</tr>";
                }
                $("#ProcmasListData").append(html);
                ProcmasrPagination(10, Totalrecord);
            }
        },
        error: function () {

        },
        complete: function () {
            Hideloader();
        }
    });
}
function OpenProcmasAddForm() {
    $("#hdnProcmasId").val('');
    $("#ProcmasModel :input").val('');
    $("#ProcmasModel").modal("show");
}
function ProcmasrPagination(pagesize, totalrecord) {
    pageSize = pagesize;
    var pageCount = totalrecord / pageSize;
    $("#pagenation").empty();
    for (var i = 0 ; i < pageCount; i++) {
        var indx = i + 1;
        $("#pagenation").append('<li><a href="#" class="page-link" onclick="GetProcmasListData(' + indx + ')">' + indx + '</a></li> ');
    }
    $("#TotalRecords").text('Total Records :' + totalrecord);
    $("#pagenation li").first().find("a").addClass("current");
}
function SaveProcmas() {
    $("#Procmos").validate({
        rules: {
            txtProcgroup: {
                required: true
            },
            txtProccd: {
                required: true
            },
            txtProcnm: {
                required: true
            },
            txtShortnm: {
                required: true
            },
            txtOrder: {
                required: true
            },

        },
        //messages: {
        //    txtProcgroup: {
        //        required: "The field is required",
        //    },
        //    txtProccd: {
        //        required: "The field is required",
        //    },
        //    txtProcnm: {
        //        required: "The field is required",
        //    },
        //    txtShortnm: {
        //        required: "The field is required",
        //    },
        //    txtOrder: {
        //        required: "The field is required",
        //    },
        //},
        submitHandler: function (form) {
            var ProcmasData = {
                Id: $("#hdnProcmasId").val(),
                Procgroup: $("#txtProcgroup").val(),
                Proccd: $("#txtProccd").val(),
                Procnm: $("#txtProcnm").val(),
                Shortnm: $("#txtShortnm").val(),
                Ord: $("#txtOrder").val(),
                // Status: $("#txtStatus").val(),
                Fancy_Color_Status: $("#txtFancy_Color_Status").val(),
                IsChangeable: $("#txtIsChangeable").val(),
                Fancy_Color: $("#txtFancy_Color").val(),
                Fancy_Intensity: $("#txtFancy_Intensity").val(),
                Fancy_Overtone: $("#txtFancy_Overtone").val(),
                F_CTS: $("#txtF_CTS").val(),
                T_CTS: $("#txtT_CTS").val(),
                IsActive: $("#chkIsActive").is(":checked")
            }
            $.ajax({
                url: mController + '/SaveProcmas',
                data: ProcmasData,
                type: 'POST',
                crossDomain: true,
                dataType: 'json',
                ContentType: 'application/x-www-form-urlencoded',
                async: true,
                success: function (data) {
                    console.log(data);
                    $("#ProcmasModel").modal("hide");
                    GetProcmasListData();
                },
                error: function () {
                    console.log("error");
                },
            });
        }
    })
}
function OpenEditProcmasForm(id) {
    $.ajax({
        url: mController + '/GetProcmasManageData',
        data: 'id=' + $.trim(id),
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.objProcmasModel;
            var Procgroup = response.Procgroup;
            var Proccd = response.Proccd;
            var Procnm = response.Procnm;
            var Shortnm = response.Shortnm;
            var Ord = response.Ord;
            var IsActive = response.IsActive;
            $("#hdnProcmasId").val(response.Id);
            $("#txtProcgroup").val(Procgroup);
            $("#txtProccd").val(Proccd);
            $("#txtProcnm").val(Procnm);
            $("#txtShortnm").val(Shortnm);
            $("#txtOrder").val(Ord);

            if (IsActive == true) {
                $("#chkIsActive").prop('checked', true);
            } else {
                $("#chkIsActive").prop('checked', false);
            }
            $("#ProcmasModel").modal("show");
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function DeleteProcmas(id) {
    var reqProcmas = {
        Id: id,
    }
    if (confirm("If you want to delete this row ?")) {
        $.ajax({
            url: mController + '/DeleteProcmas',
            data: reqProcmas,
            type: 'POST',
            success: function (data) {
                console.log(data);
                $("#ProcmasModel").modal("hide");
                GetProcmasListData();
            },
            error: function () {
                console.log("error");
            },
        });
    }
}
function ProcmasResetData() {
    $(".criteria :input").val('');
    GetProcmasListData();
}

function GetClientMasterListData(pageno) {
    var reqClientMaster = {
        FirstName: $("#txtSearchFirstName").val(),
        EmailID1: $("#txtSearchEmail").val(),
        Status: $("#txtSearchStatus").val(),
        pageno: pageno,
    }
    $.ajax({
        url: mController + '/GetClientMasterData',
        data: reqClientMaster,
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.lstClientMasterModel;
            var html = "";
            $("#ClientMasterData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    html += "<tr>";
                    html += "<td>" + response[i].ClientCd + "</td>";
                    html += "<td>" + response[i].LoginName + "</td>";
                    html += "<td>" + response[i].Password + "</td>";
                    html += "<td>" + response[i].Title + "</td>";
                    html += "<td>" + response[i].FirstName + "</td>";
                    html += "<td>" + response[i].LastName + "</td>";
                    html += "<td>" + response[i].strBirthdate + "</td>";
                    html += "<td>" + response[i].CompanyNm + "</td>";
                    html += "<td>" + response[i].Designation + "</td>";
                    html += "<td>" + response[i].Terms + "</td>";
                    html += "<td>" + response[i].CreditDays + "</td>";
                    html += "<td>" + response[i].Commission + "</td>";
                    html += "<td>" + response[i].Brokerage + "</td>";
                    html += "<td>" + response[i].PriceDiscount + "</td>";
                    html += "<td>" + response[i].Discount + "</td>";
                    html += "<td>" + response[i].PriceFormat + "</td>";
                    html += "<td>" + response[i].TaxDetails + "</td>";
                    html += "<td>" + response[i].ReferenceFrom + "</td>";
                    html += "<td>" + response[i].ReferenceThrough + "</td>";
                    html += "<td>" + response[i].Address + "</td>";
                    html += "<td>" + response[i].City + "</td>";
                    html += "<td>" + response[i].State + "</td>";
                    html += "<td>" + response[i].Zipcode + "</td>";
                    html += "<td>" + response[i].Countrycd + "</td>";
                    html += "<td>" + response[i].Phone_Countrycd + "</td>";
                    html += "<td>" + response[i].Phone_STDcd + "</td>";
                    html += "<td>" + response[i].Phone_No + "</td>";
                    html += "<td>" + response[i].Phone_Countrycd2 + "</td>";
                    html += "<td>" + response[i].Phone_STDCd2 + "</td>";
                    html += "<td>" + response[i].Phone_No2 + "</td>";
                    html += "<td>" + response[i].Fax_Countrycd + "</td>";
                    html += "<td>" + response[i].Fax_STDCd + "</td>";
                    html += "<td>" + response[i].Fax_No + "</td>";
                    html += "<td>" + response[i].Mobile_CountryCd + "</td>";
                    html += "<td>" + response[i].Mobile_No + "</td>";
                    html += "<td>" + response[i].EmailID1 + "</td>";
                    html += "<td>" + response[i].EmailID2 + "</td>";
                    html += "<td>" + response[i].EmailID3 + "</td>";
                    html += "<td>" + response[i].All_EmailId + "</td>";
                    html += "<td>" + response[i].Website + "</td>";
                    html += "<td>" + response[i].BussinessType + "</td>";
                    html += "<td>" + response[i].strInsertedDate + "</td>";
                    html += "<td>" + response[i].CreatedBy + "</td>";
                    html += "<td>" + response[i].strUpdatedDate + "</td>";
                    html += "<td>" + response[i].UpdatedBy + "</td>";
                    html += "<td>" + response[i].ApproveStatus + "</td>";
                    html += "<td>" + response[i].strApproveStatusOn + "</td>";
                    html += "<td>" + response[i].ApproveStatusBy + "</td>";
                    html += "<td>" + response[i].strStatusUpdatedOn + "</td>";
                    html += "<td>" + response[i].StatusUpdatedBy + "</td>";
                    html += "<td>" + response[i].Status + "</td>";
                    html += "<td>" + response[i].WholeStockAccess + "</td>";
                    html += "<td>" + response[i].BankDetails + "</td>";
                    html += "<td>" + response[i].RoutingDetails + "</td>";
                    html += "<td>" + response[i].Handle_Location + "</td>";
                    html += "<td>" + response[i].Smid + "</td>";
                    html += "<td>" + response[i].EmailStatus + "</td>";
                    html += "<td>" + response[i].strLastLoginDate + "</td>";
                    html += "<td>" + response[i].SkypeId + "</td>";
                    html += "<td>" + response[i].QQId + "</td>";
                    html += "<td>" + response[i].EmailSubscr + "</td>";
                    html += "<td>" + response[i].strEmailSubscrDate + "</td>";
                    html += "<td>" + response[i].UtypeId + "</td>";
                    html += "<td>" + response[i].UserRights + "</td>";
                    html += "<td>" + response[i].UploadInventory + "</td>";
                    html += "<td>" + response[i].Show_HoldedStock + "</td>";
                    html += "<td>" + response[i].strLoginMailAlertOn + "</td>";
                    html += "<td>" + response[i].Show_CertImage + "</td>";
                    html += "<td>" + response[i].App_Id + "</td>";
                    html += "<td>" + response[i].App_Pwd + "</td>";
                    html += "<td>" + response[i].WeChatId + "</td>";
                    html += "<td>" + response[i].Client_Grade + "</td>";
                    html += "<td>" + response[i].WatchList_Priority + "</td>";
                    html += "<td>" + response[i].ShipmentType + "</td>";
                    html += "<td>" + response[i].SecurityPin + "</td>";
                    html += "<td>" + response[i].Online_ClientCd + "</td>";
                    html += "<td>" + response[i].Online_SellerCd + "</td>";
                    html += "<td>" + response[i].Status1 + "</td>";
                    html += "<td>" + response[i].IsDeleted + "</td>";
                    html += "<td><a href='#' onclick='OpenEditClientMasterForm(" + response[i].ClientCd + ")'>Edit</a>&nbsp;<a href='#' onclick='DeleteClientMaster(" + response[i].ClientCd + ")'>Delete</a></td>";
                    html += "</tr>";
                }
                $("#ClientMasterData").append(html);

                ClientMasterPagination(10, Totalrecord);
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function OpenClientMasteAddForm() {
    $("#hdnClientMasteId").val('');
    $("#ClientMasterModel :input").val('');
    $("#ClientMasterModel").modal("show");
}
function SaveClientmaster() {
    $("#ClientMasterForm").validate({
        rules: {
            txtLoginName: {
                required: true
            },
            txtPassword: {
                required: true
            },
            txtTitle: {
                required: true
            },
            txtFirstname: {
                required: true
            },
            txtLastname: {
                required: true
            },
            txtBirthDate: {
                required: true
            },
            txtCompnyName: {
                required: true
            },
            txtDesignation: {
                required: true
            },
            txtDiscount: {
                required: true
            },
            txtAddress: {
                required: true
            },
            txtCity: {
                required: true
            },
            txtState: {
                required: true
            },
            txtZipcode: {
                required: true
            },
            txtPhone_No: {
                required: true
            },
            txtMobile_No: {
                required: true
            },
            txtEmailID1: {
                required: true
            },
            txtWebsite: {
                required: true
            },
            txtBusiness_Type: {
                required: true
            },
            txtShow_CertImage: {
                required: true
            },
            txtStatus: {
                required: true
            }
        }, submitHandler: function (form) {
            var ProcmasData = {
                clientcd: $("#hdnClientMasteId").val(),
                loginname: $("#txtLoginName").val(),
                password: $("#txtPassword").val(),
                title: $("#txtTitle").val(),
                firstname: $("#txtFirstname").val(),
                lastname: $("#txtLastname").val(),
                birthdate: $("#txtBirthDate").val(),
                companynm: $("#txtCompnyName").val(),
                designation: $("#txtDesignation").val(),
                discount: $("#txtDiscount").val(),
                address: $("#txtAddress").val(),
                city: $("#txtCity").val(),
                state: $("#txtState").val(),
                zipcode: $("#txtZipcode").val(),
                phone_no: $("#txtPhone_No").val(),
                mobile_no: $("#txtMobile_No").val(),
                emailid1: $("#txtEmailID1").val(),
                website: $("#txtWebsite").val(),
                bussinesstype: $("#txtBusiness_Type").val(),
                show_certimage: $("#txtShow_CertImage").val(),
                status: $("#txtStatus").val()
            }

            $.ajax({
                url: mController + '/SaveClientMasterModel',
                data: ProcmasData,
                type: 'post',
                beforeSend: function () {
                    Showloader();
                },
                success: function (data) {
                    console.log(data);
                    $("#ClientMasterModel").modal("hide");
                    GetClientMasterListData();
                },
                error: function () {
                    console.log("error");
                },
                complete: function () {
                    Hideloader();
                }
            });
        }
    })
}
function ClientMasterPagination(pagesize, totalrecord) {
    pageSize = pagesize;
    var pageCount = totalrecord / pageSize;
    $("#pagenation").empty();
    for (var i = 0 ; i < pageCount; i++) {
        var indx = i + 1;
        $("#pagenation").append('<li><a href="#" class="page-link" onclick="GetClientMasterListData(' + indx + ')">' + indx + '</a></li> ');
    }
    $("#TotalRecords").text('Total Records :' + totalrecord);
    $("#pagenation li").first().find("a").addClass("current");
}
function OpenEditClientMasterForm(ClientCd) {
    $("#hdnLoginName").removeClass("d-none");
    $(".Hide4Upadte").addClass("d-none");

    $.ajax({
        url: mController + '/GetCLientMasterManageData',
        data: 'ClientCd=' + $.trim(ClientCd),
        type: 'POST',
        async: true,
        //beforeSend: function () {
        //    Showloader();
        //},
        success: function (data) {
            console.log(data);
            var response = data.objClientMasterModel;
            var LoginName = response.EmailID1;
            var Password = response.Password;
            var Title = response.Title;
            var FirstName = response.FirstName;
            var LastName = response.LastName;
            var strBirthdate = response.strBirthdate;
            var CompanyNm = response.CompanyNm;
            var Designation = response.Designation;
            var Discount = response.Discount;
            var Address = response.Address;
            var City = response.City;
            var State = response.State;
            var Zipcode = response.Zipcode;
            var Phone_No = response.Phone_No;
            var Mobile_No = response.Mobile_No;
            var EmailID1 = response.EmailID1;
            var Website = response.Website;
            var BussinessType = response.BussinessType;
            var Status = response.Status;
            var Show_CertImage = response.Show_CertImage;
            var ReferenceThrough = response.ReferenceThrough;
            $("#hdnClientMasteId").val(response.ClientCd);
            $("#txtLoginName").val(LoginName);
            $("#txtPassword").val(Password);
            $("#txtTitle").val(Title);
            $("#txtFirstname").val(FirstName);
            $("#txtLastname").val(LastName);
            $("#txtBirthDate").val(strBirthdate);
            $("#txtCompnyName").val(CompanyNm);
            $("#txtDesignation").val(Designation);
            $("#txtDiscount").val(Discount);
            $("#txtAddress").val(Address);
            $("#txtCity").val(City);
            $("#txtState").val(State);
            $("#txtZipcode").val(Zipcode);
            $("#txtPhone_No").val(Phone_No);
            $("#txtMobile_No").val(Mobile_No);
            $("#txtEmailID1").val(EmailID1);
            $("#txtWebsite").val(Website);
            $("#txtBusiness_Type").val(BussinessType);
            $("#txtStatus").val(Status);
            $("#txtReferenceThrough").val(ReferenceThrough);
            $("#txtShow_CertImage").val(Show_CertImage);

            $("#ClientMasterModel").modal("show");
        },
        error: function () {
        },
        //complete: function () {
        //    Hideloader();
        //}
    });
}
function DeleteClientMaster(ClientCd) {
    var reqClientMaster = {
        ClientCd: ClientCd,
    }
    if (confirm("If you want to delete this row ?")) {
        $.ajax({
            url: mController + '/DeleteClientMaster',
            data: reqClientMaster,
            type: 'POST',
            success: function (data) {
                console.log(data);
                //$("#ProjectModal").modal("hide");
                GetClientMasterListData();
            },
            error: function () {
                console.log("error");
            },
        });
    }
}
function ClientMasterResetData() {
    $(".criteria :input").val('');
    GetClientMasterListData();
}

function GetProductListData(pageno) {
    var reqProduct = {
        STONEID: $("#txtSearchStoneId").val(),
        CERTIFICATE: $("#txtSearchCertificate").val(),
        CERTNO: $("#txtSearchCertificateNo").val(),
        SHAPE: $("#txtSearchShape").val(),
        COLOR: $("#txtSearchColor").val(),
        CLARITY: $("#txtSearchClarity").val(),
        FromCTS: $("#FromSearchCaret").val(),
        ToCTS: $("#ToSearchCaret1").val(),
        pageno: pageno,
    }
    $.ajax({
        url: mController + '/GetProductData',
        data: reqProduct,
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.lstProductModel;
            var html = "";
            $("#ProductData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    html += "<tr>";
                    html += "<td>" + response[i].COMPCD + "</td>";
                    html += "<td>" + response[i].STONEID + "</td>";
                    html += "<td>" + response[i].SHAPE + "</td>";
                    html += "<td>" + response[i].CTS + "</td>";
                    html += "<td>" + response[i].COLOR + "</td>";
                    html += "<td>" + response[i].CLARITY + "</td>";
                    html += "<td>" + response[i].CUT + "</td>";
                    html += "<td>" + response[i].POLISH + "</td>";
                    html += "<td>" + response[i].SYM + "</td>";
                    html += "<td>" + response[i].FLOURENCE + "</td>";
                    html += "<td>" + response[i].FL_COLOR + "</td>";
                    html += "<td>" + response[i].INCLUSION + "</td>";
                    html += "<td>" + response[i].HA + "</td>";
                    html += "<td>" + response[i].LUSTER + "</td>";
                    html += "<td>" + response[i].GIRDLE + "</td>";
                    html += "<td>" + response[i].GIRDLE_CONDITION + "</td>";
                    html += "<td>" + response[i].CULET + "</td>";
                    html += "<td>" + response[i].MILKY + "</td>";
                    html += "<td>" + response[i].SHADE + "</td>";
                    html += "<td>" + response[i].NATTS + "</td>";
                    html += "<td>" + response[i].NATURAL + "</td>";
                    html += "<td>" + response[i].DEPTH + "</td>";
                    html += "<td>" + response[i].DIATABLE + "</td>";
                    html += "<td>" + response[i].LENGTH + "</td>";
                    html += "<td>" + response[i].WIDTH + "</td>";
                    html += "<td>" + response[i].PAVILION + "</td>";
                    html += "<td>" + response[i].CROWN + "</td>";
                    html += "<td>" + response[i].PAVANGLE + "</td>";
                    html += "<td>" + response[i].CROWNANGLE + "</td>";
                    html += "<td>" + response[i].HEIGHT + "</td>";
                    html += "<td>" + response[i].PAVHEIGHT + "</td>";
                    html += "<td>" + response[i].CROWNHEIGHT + "</td>";
                    html += "<td>" + response[i].MEASUREMENT + "</td>";
                    html += "<td>" + response[i].RATIO + "</td>";
                    html += "<td>" + response[i].PAIR + "</td>";
                    html += "<td>" + response[i].STAR_LENGTH + "</td>";
                    html += "<td>" + response[i].LOWER_HALF + "</td>";
                    html += "<td>" + response[i].KEY_TO_SYMBOL + "</td>";
                    html += "<td>" + response[i].REPORT_COMMENT + "</td>";
                    html += "<td>" + response[i].CERTIFICATE + "</td>";
                    html += "<td>" + response[i].CERTNO + "</td>";
                    html += "<td>" + response[i].RAPARATE + "</td>";
                    html += "<td>" + response[i].RAPAAMT + "</td>";
                    html += "<td>" + response[i].strCURDATE + "</td>";
                    html += "<td>" + response[i].LOCATION + "</td>";
                    html += "<td>" + response[i].LEGEND1 + "</td>";
                    html += "<td>" + response[i].LEGEND2 + "</td>";
                    html += "<td>" + response[i].LEGEND3 + "</td>";
                    html += "<td>" + response[i].ASKRATE_FC + "</td>";
                    html += "<td>" + response[i].ASKDISC_FC + "</td>";
                    html += "<td>" + response[i].ASKAMT_FC + "</td>";
                    html += "<td>" + response[i].COSTRATE_FC + "</td>";
                    html += "<td>" + response[i].COSTDISC_FC + "</td>";
                    html += "<td>" + response[i].COSTAMT_FC + "</td>";
                    html += "<td>" + response[i].WEB_CLIENTID + "</td>";
                    html += "<td>" + response[i].wl_rej_status + "</td>";
                    html += "<td>" + response[i].GIRDLEPER + "</td>";
                    html += "<td>" + response[i].DIA + "</td>";
                    html += "<td>" + response[i].COLORDESC + "</td>";
                    html += "<td>" + response[i].BARCODE + "</td>";
                    html += "<td>" + response[i].INSCRIPTION + "</td>";
                    html += "<td>" + response[i].NEW_CERT + "</td>";
                    html += "<td>" + response[i].MEMBER_COMMENT + "</td>";
                    html += "<td>" + response[i].UPLOADCLIENTID + "</td>";
                    html += "<td>" + response[i].strREPORT_DATE + "</td>";
                    html += "<td>" + response[i].strNEW_ARRI_DATE + "</td>";
                    html += "<td>" + response[i].TINGE + "</td>";
                    html += "<td>" + response[i].EYE_CLN + "</td>";
                    html += "<td>" + response[i].TABLE_INCL + "</td>";
                    html += "<td>" + response[i].SIDE_INCL + "</td>";
                    html += "<td>" + response[i].TABLE_BLACK + "</td>";
                    html += "<td>" + response[i].SIDE_BLACK + "</td>";
                    html += "<td>" + response[i].TABLE_OPEN + "</td>";
                    html += "<td>" + response[i].SIDE_OPEN + "</td>";
                    html += "<td>" + response[i].PAV_OPEN + "</td>";
                    html += "<td>" + response[i].EXTRA_FACET + "</td>";
                    html += "<td>" + response[i].INTERNAL_COMMENT + "</td>";
                    html += "<td>" + response[i].POLISH_FEATURES + "</td>";
                    html += "<td>" + response[i].SYMMETRY_FEATURES + "</td>";
                    html += "<td>" + response[i].GRAINING + "</td>";
                    html += "<td>" + response[i].IMG_URL + "</td>";
                    html += "<td>" + response[i].RATEDISC + "</td>";
                    html += "<td>" + response[i].GRADE + "</td>";
                    html += "<td>" + response[i].CLIENT_LOCATION + "</td>";
                    html += "<td>" + response[i].ORIGIN + "</td>";
                    html += "<td>" + response[i].BGM + "</td>";
                    //html += "<td><a href='#' onclick='OpenEditClientMasterForm(" + response[i].ClientCd + ")'>Edit</a>&nbsp;<a href='#' onclick='DeleteClientMaster(" + response[i].ClientCd + ")'>Delete</a></td>";
                    html += "</tr>";
                }
                $("#ProductData").append(html);

                ProductPagination(10, Totalrecord);
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function ProductResetData() {
    $(".criteria :input").val('');
    GetProductListData();
}
function ProductPagination(pagesize, totalrecord) {
    pageSize = pagesize;

    var pageCount = totalrecord / pageSize;
    $("#pagenation").empty();
    for (var i = 0 ; i < pageCount; i++) {
        var index = i + 1;
        $("#pagenation").append('<li><a href="#" class="page-link" onclick="GetProductListData(' + index + ')">' + index + '</a></li> ');
    }
    $("#TotalRecords").text('Total Records :' + totalrecord);
    $("#pagenation li").first().find("a").addClass("current");
}
function SaveImportProduct() {
    $("#").validate({
        rules: {
            UploadFile: {
                required: true
            }
        }, submitHandler: function (form) {
        }
    });
}

function GetOrderListData(pageno) {
    var reqData = {
        FirstName: $("#txtSearchName").val(),
        pageno: pageno,
    }
    $.ajax({
        url: mController + '/GetOrderListData',
        data: reqData,
        type: 'POST',
        async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            var response = data.lstShoppingCartModel;
            var html = "";
            $("#OrderListData").empty();
            if (response.length > 0) {
                var Totalrecord = response[0].TotalRecords;
                for (var i = 0; i < response.length; i++) {
                    html += "<tr>";
                    html += "<td>" + response[i].FirstName + "</td>";
                    html += "<td>" + response[i].EmailID1 + "</td>";
                    html += "<td>" + response[i].SC_stoneid + "</td>";
                    html += "<td><a href='#' onclick='ConfirmMessage(\"" + response[i].EmailID1 + "\")'>Confirm</a></td>";
                    html += "</tr>";
                }
                $("#OrderListData").append(html);
                OrderListPagination(10, Totalrecord);
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function OrderResetData() {
    $(".criteria :input").val('');
    GetOrderListData();
}
function ConfirmMessage(emailId) {
    var sendmail = {
        EmailID1: emailId,
    }
    $.ajax({
        url: HomeController + '/ConfirmMessage',
        data: sendmail,
        type: 'POST',
        //async: true,
        beforeSend: function () {
            Showloader();
        },
        success: function (data) {
            console.log(data);
            if (data.retVal == "Success") {
                swal("The email has been sent.", "Click Ok To Continue", "success");
            }
            else {
                swal("Email Not Sent !", "Click Ok To Continue", "error");
            }
        },
        error: function () {
        },
        complete: function () {
            Hideloader();
        }
    });
}
function OrderListPagination(pagesize, totalrecord) {
    pageSize = pagesize;
    var pageCount = totalrecord / pageSize;
    $("#pagenation").empty();
    for (var i = 0 ; i < pageCount; i++) {
        var index = i + 1;
        $("#pagenation").append('<li><a href="#" class="page-link" onclick="GetOrderListData(' + index + ')">' + index + '</a></li> ');
    }
    $("#TotalRecords").text('Total Records :' + totalrecord);
    $("#pagenation li").first().find("a").addClass("current");
}


function Login() {
    $("#LoginForm").validate({
        rules: {
            txtEmailID1: {
                required: true
            },
            txtPassword: {
                required: true
            },
        }, submitHandler: function (form) {
            var postdata = {
                EmailID1: $("#txtEmailID1").val(),
                Password: $("#txtPassword").val()
            }
            $.ajax({
                url: HomeController + '/LoginData',
                type: 'POST',
                data: postdata,
                async: false,
                success: function (data) {

                    console.log(data)
                    if (data.retVal == "Success") {
                        window.location.href = "/home/index";
                    }
                    else {
                        $("#errormsg").text(data.retValMsg);
                    }

                }
            });
        }
    })
}
function getPassword() {
    $("#Forgotpwdform").validate({
        rules: {
            txtPsEmail: {
                required: true
            }
        }, submitHandler: function (form) {
            var postdata = {
                RequestMail: $("#txtPsEmail").val(),
            }
            $.ajax({
                url: HomeController + '/GetPassword',
                type: 'POST',
                data: postdata,
                async: false,
                beforeSend: function () {
                    Showloader();
                },
                success: function (data) {
                    console.log(data)
                    if (data.retVal == "Success") {
                        $(".criteria :input").val('');
                        data.retValMsg = "Your Password Is Sent To Your Mail, Please check For Password";
                        $("#Password").text(data.retValMsg);
                        $("#Errormsg").text('');
                    }
                    else {
                        $("#Password").text('');
                        $("#Errormsg").text(data.retValMsg);
                    }
                },
                complete: function () {
                    Hideloader();
                }
            });
        }
    });
}
function SaveRegistration() {
    $("#RegForm").validate({
        rules: {
            txtEmailID1: {
                required: true
            },
            txtPassword: {
                required: true
            },
            txtconfirmPwd: {
                required: true,
                minlength: 8,
                equalTo: "#txtPassword"
            },
            txtTitle: {
                required: true
            },
            txtFirstname: {
                required: true
            },
            txtLastname: {
                required: true
            },
            txtBusiness_Type: {
                required: true
            },
            txtCompnyName: {
                required: true
            },
            txtDesignation: {
                required: true
            },

            //txtReferenceThrough: {
            //    required: true
            //},
            txtBirthDate: {
                required: true
            },
            txtAddress: {
                required: true
            },
            txtCity: {
                required: true
            },
            txtState: {
                required: true
            },
            txtZipcode: {
                required: true,
                minlength: 6
            },
            txtPhone_No: {
                required: true
            },
            txtMobile_No: {
                required: true,
                minlength: 10
            },
            //txtWebsite: {
            //    required: true
            //},
        },
        messages: {
            //    txtEmailID1: {
            //        required: "Enter Email Id",
            //    },
            txtPassword: {
                required: "Enter password Minmum 8 charcter",
            },
            txtconfirmPwd: "Password does not match",
            //txtTitle: {
            //    required: "Select Your Title",
            //},
            //    txtFirstname: {
            //        required: "Enter Your FirstName Id",
            //    },
            //    txtLastname: {
            //        required: "Enter Your LastName",
            //    },
            //    txtBusiness_Type: {
            //        required: "Select Your Business_Type",
            //    },
            //    txtCompnyName: {
            //        required: "Enter Your CompnyName",
            //    },
            //    txtDesignation: {
            //        required: "Enter Your Designation",
            //    },
            //    //txtReferenceThrough: {
            //    //    required: "Enter Your Designation",
            //    //},
            //    txtBirthDate: {
            //        required: "Enter Your BirthDate",
            //    },
            //    txtAddress: {
            //        required: "Enter Your Address",
            //    },
            //    txtCity: {
            //        required: "Enter Your City",
            //    },
            //    txtState: {
            //        required: "Enter Your State",
            //    },
            //    txtZipcode: {
            //        required: "Enter Your Zipcode",
            //    },
            //    txtPhone_No: {
            //        required: "Enter Your Phone No.",
            //    },
            //    txtMobile_No: {
            //        required: "Enter Your Mobile No.",
            //    },
            //txtWebsite: {
            //    required: "Enter Your Website",
            //},

        }, submitHandler: function (form) {
            //$scope.UserName = $scope.loginInfo.UserName;//$scope.userEmailId;
            var ClientData = {
                EmailID1: $("#txtEmailID1").val(),
                Password: $("#txtPassword").val(),
                Title: $("#txtTitle").val(),
                FirstName: $("#txtFirstname").val(),
                LastName: $("#txtLastname").val(),
                BussinessType: $("#txtBusiness_Type").val(),
                CompanyNm: $("#txtCompnyName").val(),
                Designation: $("#txtDesignation").val(),
                ReferenceThrough: $("#txtReferenceThrough").val(),
                Birthdate: $("#txtBirthDate").val(),
                Address: $("#txtAddress").val(),
                City: $("#txtCity").val(),
                State: $("#txtState").val(),
                Zipcode: $("#txtZipcode").val(),
                Phone_No: $("#txtPhone_No").val(),
                Mobile_No: $("#txtMobile_No").val(),
                Website: $("#txtWebsite").val()
            };
            $.ajax({
                url: mController + '/SaveClientMasterModel',
                data: ClientData,
                type: 'POST',
                crossDomain: true,
                dataType: 'json',
                ContentType: 'application/x-www-form-urlencoded',
                async: true,
                //beforeSend: function () {
                //    Showloader();
                //},
                success: function (data) {
                    console.log(data);
                    alert("Thank You For Registration");
                    window.location.href = "/home/login";
                },
                error: function () {
                    console.log("error");
                },
                //complete: function () {
                //    Hideloader();
                //}
            });
        }
    });
}
function SaveClienData() {
    $("#EditUserForm").validate({
        rules: {
            drdTitle: {
                required: true
            },
            txtFirstname: {
                required: true
            },
            txtLastname: {
                required: true
            },
            drdBusiness_Type: {
                required: true
            },
            txtCompnyName: {
                required: true
            },
            txtDesignation: {
                required: true
            },
            txtReferenceThrough: {
                required: true
            },
            txtBirthDate: {
                required: true
            },
            txtAddress: {
                required: true
            },
            txtCity: {
                required: true
            },
            txtState: {
                required: true
            },
            txtZipcode: {
                required: true
            },
            txtPhone_No: {
                required: true
            },
            txtMobile_No: {
                required: true
            },
            txtWebsite: {
                required: true
            },
        }, submitHandler: function (form) {
            var ProcmasData = {
                clientcd: $("#hdnClientId").val(),
                title: $("#drdTitle").val(),
                firstname: $("#txtFirstname").val(),
                lastname: $("#txtLastname").val(),
                bussinesstype: $("#drdBusiness_Type").val(),
                companynm: $("#txtCompnyName").val(),
                designation: $("#txtDesignation").val(),
                referencethrough: $("#txtReferenceThrough").val(),
                birthdate: $("#txtBirthDate").val(),
                address: $("#txtAddress").val(),
                city: $("#txtCity").val(),
                state: $("#txtState").val(),
                zipcode: $("#txtZipcode").val(),
                phone_no: $("#txtPhone_No").val(),
                mobile_no: $("#txtMobile_No").val(),
                website: $("#txtWebsite").val(),
            }
            $.ajax({
                url: HomeController + '/SaveClientMasterModel',
                data: ProcmasData,
                type: 'post',
                success: function (data) {
                    console.log(data);
                    swal("Update Successfully", "Click Ok To Continue", "success");
                },
                error: function () {
                    console.log("error");
                },
            });
        }
    })
}
function SendFeedback() {
    $("#contactForm").validate({
        rules: {
            txtname: {
                required: true
            },
            txtemail: {
                required: true
            },
            txtsubject: {
                required: true
            },
            //txtmessage: {
            //    required: true
            //},
        }, submitHandler: function (form) {
            var SendFeedback = {
                Name: $("#txtname").val(),
                Email: $("#txtemail").val(),
                Subject: $("#txtsubject").val(),
                YourMessage: $("#txtmessage").val(),
            }
            $.ajax({
                url: HomeController + '/SendMessage',
                data: SendFeedback,
                type: 'POST',
                success: function (data) {
                    if (retVal = "Success") {
                        swal(" Your message was sent successfully! I will be in touch as soon as I can.", "Click Ok To Continue", "success");
                        $("#contactRow :input").val('');
                    }
                    else {
                        swal("Something went wrong, try refreshing and submitting the form again.", "Click Ok To Continue", "error");
                    }
                },
                error: function () {
                    console.log("error");
                },
            });
        }
    })

}
/*Inventory - Client Side*/

/* Crietarea Page Validation for Textbox*/
(function ($) {
    $.fn.inputFilter = function (inputFilter) {
        return this.on("input keydown keyup mousedown mouseup select contextmenu drop", function () {
            if (inputFilter(this.value)) {
                this.oldValue = this.value;
                this.oldSelectionStart = this.selectionStart;
                this.oldSelectionEnd = this.selectionEnd;
            } else if (this.hasOwnProperty("oldValue")) {
                this.value = this.oldValue;
                this.setSelectionRange(this.oldSelectionStart, this.oldSelectionEnd);
            } else {
                this.value = "";
            }
        });
    };
}(jQuery));
$(document).ready(function () {
    $("#SearchFromCarat").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchToCarat").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchFromPrice").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchToPrice").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchFromAmt").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchToAmt").inputFilter(function (value) {
        return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchFromDisc").inputFilter(function (value) {
        return /^\d*[.,]?\d*$/.test(value);
        //return /^-?\d*[.,]?\d*$/.test(value);
    });
    $("#SearchToDisc").inputFilter(function (value) {
        return /^\d*[.,]?\d*$/.test(value);
        //return /^-?\d*[.,]?\d*$/.test(value);
    });
});

/*---------------------------------------------------------------------------------------------------------------------*/
var app = angular.module('LiveInvApp', ['ui.bootstrap']);
app.controller('LiveInvCtrl', function ($scope, $http) {

    LiveInventoryData();

    function LiveInventoryData() {
        $.ajax({
            url: HomeController + '/GetCrietariaData',
            type: 'POST',
            async: true,
            beforeSend: function () {
                Showloader();
            },
            success: function (data) {
                console.log(data);
                var response = data.lstProcmasModel;
                var html = "";
                if (response.length > 0) {
                    $scope.lstProcmasModel = response;
                    console.log(response);
                    $scope.$apply();
                }
            },
            error: function () {
            },
            complete: function () {
                Hideloader();
            }
        });

    }

    $scope.addremoveclass = function (divId, obj) {
        addremoveclass(divId, obj)
    }
    function addremoveclass(divId, obj) {
        var val = obj.Procnm;
        var divActive = $("#" + divId + " #" + val).hasClass("Active");
        if (divActive == true) {
            $("#" + divId + " #" + val).removeClass("Active");
        }
        else {
            $("#" + divId + " #" + val).addClass("Active");
        }
    }

    $scope.SpecialAddremoveclass = function (divId, obj) {
        SpecialAddremoveclass(divId, obj)
    }
    function SpecialAddremoveclass(divId, obj) {
        var val = obj.Procnm;
        if (val == "3EX+") {
            var divActive = ($("#Cut_Section #EX").hasClass("Active") || $("#Polish_Section #EX").hasClass("Active") || $("#Symmetry_SectionPolish_Section #EX").hasClass("Active"));
            if (divActive == true) {
                $("#Cut_Section").find('div[data-value="EX"]').removeClass("Active");
                $("#Polish_Section").find('div[data-value="EX"]').removeClass("Active");
                $("#Symmetry_Section").find('div[data-value="EX"]').removeClass("Active");
            }
            else {
                $("#Cut_Section").find('div[data-value="EX"]').addClass("Active");
                $("#Polish_Section").find('div[data-value="EX"]').addClass("Active");
                $("#Symmetry_Section").find('div[data-value="EX"]').addClass("Active");
            }
        }
        else if (val == "3VG+") {
            var divActive = ($("#Cut_Section #VG").hasClass("Active") || $("#Polish_Section #VG").hasClass("Active") || $("#Symmetry_SectionPolish_Section #VG").hasClass("Active"));
            if (divActive == true) {
                $("#Cut_Section").find('div[data-value="VG"]').removeClass("Active");
                $("#Polish_Section").find('div[data-value="VG"]').removeClass("Active");
                $("#Symmetry_Section").find('div[data-value="VG"]').removeClass("Active");
            }
            else {
                $("#Cut_Section").find('div[data-value="VG"]').addClass("Active");
                $("#Polish_Section").find('div[data-value="VG"]').addClass("Active");
                $("#Symmetry_Section").find('div[data-value="VG"]').addClass("Active");
            }
        }
    }

    $scope.GetInventoryListData = function (pageno) {
        HideShow('submit');
        GetInventoryListData(pageno);
    }
    function GetInventoryListData(pageno) {
        var retVal = [];
        var shapediv = $("#Shape_Section div.Active");
        for (var i = 0; i < shapediv.length; i++) {
            var divCheckClass = true;
            var divValue = $(shapediv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                retVal.push(divValue);
            }
            console.log(retVal);
        }

        var LabVal = [];
        var Labdiv = $("#Lab_Section div.Active");
        for (var i = 0; i < Labdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Labdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                LabVal.push(divValue);
            }
            console.log(LabVal);
        }

        var CutVal = [];
        var Cutdiv = $("#Cut_Section div.Active");
        for (var i = 0; i < Cutdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Cutdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                CutVal.push(divValue);
            }
            console.log(CutVal);
        }

        var PolishVal = [];
        var Polishdiv = $("#Polish_Section div.Active");
        for (var i = 0; i < Polishdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Polishdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                PolishVal.push(divValue);
            }
            console.log(PolishVal);
        }

        var SymmetryVal = [];
        var Symmetrydiv = $("#Symmetry_Section div.Active");
        for (var i = 0; i < Symmetrydiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Symmetrydiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                SymmetryVal.push(divValue);
            }
            console.log(SymmetryVal);
        }

        var ColorVal = [];
        var Colordiv = $("#Color_Section div.Active");
        for (var i = 0; i < Colordiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Colordiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                ColorVal.push(divValue);
            }
            console.log(ColorVal);
        }

        var ClarityVal = [];
        var Claritydiv = $("#Clarity_Section div.Active");
        for (var i = 0; i < Claritydiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Claritydiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                ClarityVal.push(divValue);
            }
            console.log(ClarityVal);
        }

        var Fl_IntVal = [];
        var Fl_Intdiv = $("#Fl_Intensity_Section div.Active");
        for (var i = 0; i < Fl_Intdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Fl_Intdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                Fl_IntVal.push(divValue);
            }
            console.log(Fl_IntVal);
        }

        var Fl_ColVal = [];
        var Fl_Coldiv = $("#Fl_Color_Section div.Active");
        for (var i = 0; i < Fl_Coldiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Fl_Coldiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                Fl_ColVal.push(divValue);
            }
            console.log(Fl_ColVal);
        }

        var LocationVal = [];
        var Locationdiv = $("#Location_Section div.Active");
        for (var i = 0; i < Locationdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(Locationdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                LocationVal.push(divValue);
            }
            console.log(LocationVal);
        }

        var HAVal = [];
        var HAdiv = $("#H_A_Section div.Active");
        for (var i = 0; i < HAdiv.length; i++) {
            var divCheckClass = true;
            var divValue = $(HAdiv[i]).attr("data-value");
            if (divCheckClass == false && divValue != null) {

            }
            else if (divCheckClass == true && divValue != null) {
                HAVal.push(divValue);
            }
            console.log(HAVal);
        }

        var reqInventory = {
            SHAPE: retVal.toString(),
            CERTIFICATE: LabVal.toString(),
            FromCTS: $("#SearchFromCarat").val(),
            ToCTS: $("#SearchToCarat").val(),
            CUT: CutVal.toString(),
            POLISH: PolishVal.toString(),
            SYM: SymmetryVal.toString(),
            COLOR: ColorVal.toString(),
            CLARITY: ClarityVal.toString(),
            FLOURENCE: Fl_IntVal.toString(),
            FL_COLOR: Fl_ColVal.toString(),
            HA: HAVal.toString(),
            LOCATION: LocationVal.toString(),
            STONEID: $("#SearchStoneId").val(),
            CERTNO: $("#SearchCertiNo").val(),
            FromPrice: $("#SearchFromPrice").val(),
            ToPrice: $("#SearchToPrice").val(),
            FromAmt: $("#SearchFromAmt").val(),
            ToAmt: $("#SearchToAmt").val(),
            FromDisc: $("#SearchFromDisc").val(),
            ToDisc: $("#SearchToDisc").val(),
            LEGEND1: $("#Status").val(),
            LEGEND3: $("#Status1").val(),
            pageno: pageno,
        }

        $.ajax({
            url: HomeController + '/GetInventoryData',
            data: reqInventory,
            type: 'POST',
            async: true,
            beforeSend: function () {
                Showloader();
            },
            success: function (data) {
                console.log(data);
                var response = data.lstInventoryModel;
                if (response.length > 0) {
                    $scope.lstInventoryModel = response;

                    var Totalrecord = response[0].TotalRecords;
                    var pageno = response[0].pageno;
                    //InvPagination(10, Totalrecord, pageno,$scope);
                    $scope.InvPagination(10, Totalrecord, $scope);
                    ////$http.get('/Home/GetInventoryData', { params: { Pageno: pageno, pageSize: $scope.pageSize } }).then(function (response) {
                    ////    $scope.Items = response.data.Data;
                    ////    // $scope.PaggingTemplate(response.data.TotalPages, response.data.CurrentPage);
                    ////})

                    //InventoryPagination(10, Totalrecord, pageno);
                        console.log(response);
                        $scope.$apply();
                }
            },
            error: function () {

            },
            complete: function () {
                Hideloader();
            }
        });
    }

    $scope.InvPagination = function (PageSize, Totalrecord) {
        console.log("InvPagination");
        console.log(PageSize);
        console.log(Totalrecord);

        $scope.viewby = PageSize;
        $scope.totalItems = Totalrecord;
        $scope.currentPage = 1;
        $scope.itemsPerPage = $scope.viewby;
        $scope.maxSize = 5; //Number of pager buttons to show

        $scope.setPage = function (PageNo) {
            $scope.currentPage = PageNo;
        };

        $scope.pageChanged = function () {
            console.log('Page changed to: ' + $scope.currentPage);
        };

        $scope.setItemsPerPage = function (num) {
            $scope.itemsPerPage = num;
            $scope.currentPage = 1; //reset to first page
        }
    }

    $scope.InventoryClear = function () {
        InventoryClear();
    }
    function InventoryClear() {
        $("#Shape_Section").find("div.Active").removeClass("Active");
        $("#Lab_Section").find("div.Active").removeClass("Active");
        $("#SearchFromCarat:input").val('');
        $("#SearchToCarat:input").val('');
        $("#Cut_Section").find("div.Active").removeClass("Active");
        $("#Polish_Section").find("div.Active").removeClass("Active");
        $("#Symmetry_Section").find("div.Active").removeClass("Active");
        $("#Color_Section").find("div.Active").removeClass("Active");
        $("#Clarity_Section").find("div.Active").removeClass("Active");
        $("#Fl_Intensity_Section").find("div.Active").removeClass("Active");
        $("#Fl_Color_Section").find("div.Active").removeClass("Active");
        $("#SearchStoneId:input").val('');
        $("#SearchCertiNo:input").val('');
        $("#Special_Section").find("div.Active").removeClass("Active");
        $("#SearchFromPrice:input").val('');
        $("#SearchToPrice:input").val('');
        $("#SearchFromAmt:input").val('');
        $("#SearchToAmt:input").val('');
        $("#SearchFromDisc:input").val('');
        $("#SearchToDisc:input").val('');
        $("#Status:input").val('');
        $("#Status1:input").val('');
        $("#Location_Section").find("div.Active").removeClass("Active");
        $("#H_A_Section").find("div.Active").removeClass("Active");

    }

    $scope.RefreshInvPage = function () {
        RefreshInvPage();
    }
    function RefreshInvPage() {
        location.reload();
    }

    $(document).ready(function () {
        $("#checkAll").click(function () {
            $('input:checkbox').not(this).prop('checked', this.checked);
        });
    })

    var stonearr = [];
    $scope.StoneCheck = function (obj) {
        debugger
        var Data = obj.STONEID;
        if ($("#chk_" + Data).prop("checked")) {
            stonearr.push(Data);
        } else {
            stonearr = $.grep(stonearr, function (value) {
                return value != Data;
            });
        }
        console.log(stonearr);

    }

    $scope.GetStoneID = function (obj) {
        var Data = obj.SC_stoneid;
        if ($("#chk_" + Data).prop("checked")) {
            stonearr.push(Data);
        } else {
            stonearr = $.grep(stonearr, function (value) {
                return value != Data;
            });
        }
        console.log(stonearr);
    }

    GetCartdataList();
    function GetCartdataList() {
        var reqdata = {
            SC_Status: "I",
            SC_CUR_STATUS: "I",
        }
        $.ajax({
            url: HomeController + '/GetCartdataList',
            data: reqdata,
            type: 'GET',
            async: true,
            beforeSend: function () {
                Showloader();
            },
            success: function (data) {
                console.log(data);
                var response = data.lstShoppingCart;
                $scope.lstShoppingCart = response;
                console.log(response);
                $scope.$apply();
            },
            error: function () {

            },
            complete: function () {
                Hideloader();
            }
        });
    }

    $scope.AddToCartBuy = function (flag) {
        var stonedata = {
            SC_stoneid: stonearr.toString(),
            Flag: flag,
        }
        $.ajax({
            url: HomeController + '/AddToCartBuy',
            data: stonedata,
            type: 'POST',
            async: true,
            //beforeSend: function () {
            //    Showloader();
            //},
            success: function (data) {
                console.log(data);
                if (data.retVal == "-1") {
                    swal("Alreday Exists", "Stone is alreday in your cart.", "warning");
                    stonearr = [];
                }
                else if (data.retVal == "1") {
                    swal("Add Into Cart.", "Click Ok To Continue", "success");
                    GetInventoryListData();
                    GetCartdataList();
                    stonearr = [];
                }
                else if (data.retVal == "2") {
                    swal("Add Into Buy", "Click Ok To Continue", "success");
                    GetInventoryListData();
                    GetBuydataList();
                    GetCartdataList();
                    stonearr = [];
                }
                else {
                    swal("Out Of Stock", "Try Next Time!,Continue", "warning");
                    GetInventoryListData();
                    GetCartdataList();
                    stonearr = [];
                }
            },
            error: function () {
            },
            //complete: function () {
            //    Hideloader();
            //} 
        });
    }

    GetBuydataList();
    function GetBuydataList() {
        var reqdata = {
            SC_Status: "B",
            SC_CUR_STATUS: "I",
        }

        $.ajax({
            url: HomeController + '/GetBuydataList',
            data: reqdata,
            type: 'GET',
            async: true,
            beforeSend: function () {
                Showloader();
            },
            success: function (data) {
                console.log(data);
                var response = data.lstBuyShoppingCart;
                $scope.lstBuyShoppingCart = response;
                console.log(response);
                $scope.$apply();
            },
            error: function () {

            },
            complete: function () {
                Hideloader();
            }
        });
    }

    $scope.DeleteToCartBuy = function (flag) {
        debugger;
        var stonedata = {
            SC_stoneid: stonearr.toString(),
            Flag: flag,
        }
        if (confirm("If you want to delete this Stone :- '" + stonearr + "' ?")) {
            $.ajax({
                url: HomeController + '/DeleteToCartBuy',
                data: stonedata,
                type: 'POST',
                async: true,
                //beforeSend: function () {
                //    Showloader();
                //},
                success: function (data) {
                    console.log(data);
                    swal("Deleted!", "Your imaginary file has been deleted.", "success");
                    if (data.retVal == '3') {
                        GetCartdataList();
                        stonearr = [];
                    }
                    else if (data.retVal == '4') {
                        GetBuydataList();
                        stonearr = [];
                    }

                },
                error: function () {
                },
                //complete: function () {
                //    Hideloader();
                //} 
            });
        }
    }

    function GetClientListData() {
        $.ajax({
            url: HomeController + '/GetClientData',
            data: null,
            type: 'POST',
            async: true,
            //beforeSend: function () {
            //    Showloader();
            //},
            success: function (data) {
                console.log(data);
                var response = data.lstClientMasterModel;

                if (response.length > 0) {
                    $scope.lstClientMasterModel = response;
                    console.log(response);
                    $scope.$apply();
                }
            },
            error: function () {
            },
            //complete: function () {
            //    Hideloader();
            //} 
        });
    }
});

function HideShow(val) {
    if (val == "modify") {
        $("#SearchCriteria_Section").show();
        $("#InventoryData").hide();
    } else if (val == "submit") {
        $("#SearchCriteria_Section").hide();
        $("#InventoryData").show();
    }
}

function Loginform() {
    $("#Loginhdn").removeClass('hidden');
    $("#Forgothdn").addClass('hidden')

}
function ForgotForm() {

    $("#Forgothdn").removeClass('hidden')
    $("#Loginhdn").addClass('hidden');


}