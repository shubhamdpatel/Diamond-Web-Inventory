USE [master]
GO
/****** Object:  Database [DiamondWebInventory]    Script Date: 06-Aug-20 03:45:39 AM ******/
CREATE DATABASE [DiamondWebInventory]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DiamondWebInventory', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\DiamondWebInventory.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DiamondWebInventory_log', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\DiamondWebInventory_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DiamondWebInventory] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DiamondWebInventory].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DiamondWebInventory] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET ARITHABORT OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [DiamondWebInventory] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DiamondWebInventory] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DiamondWebInventory] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DiamondWebInventory] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DiamondWebInventory] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DiamondWebInventory] SET  MULTI_USER 
GO
ALTER DATABASE [DiamondWebInventory] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DiamondWebInventory] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DiamondWebInventory] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DiamondWebInventory] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[BannerList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [BannerList] ' ','ORDER BY b.Id ASC',10,2
-- =============================================
CREATE PROCEDURE [dbo].[BannerList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.Id ASC'
	END
    
    SET @SQLStr ='
    select a.* from
	(select 
		ROW_NUMBER() OVER('+@orderby+') as rn
		  ,b.Id
		  ,ISNULL(b.[Title],'''') as [Title]
		  ,ISNULL(b.[ImageType],'''') as [ImageType]
		  ,ISNULL(b.[ClickUrl],'''') as [ClickUrl]
		  ,ISNULL(b.[IsActive],0) as IsActive
		  ,CASE WHEN IsActive=1 THEN ''Y'' WHEN IsActive=0 THEN ''N'' END Status
		  ,TotalRecords 
	  FROM [Banner] b
	  OUTER APPLY(select COUNT(c.Id) as TotalRecords FROM [Banner] c
	  where 1=1 '+@whereclause+' AND ISNULL(c.IsDeleted,0)=0)as c_count
	  WHERE 1=1 '+@whereclause+' AND ISNULL(b.IsDeleted,0)=0
	  ) as a
	 WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+'
	 '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	 SET @SQLStrCnt =' select 
							COUNT(b.Id) as Cnt 
							FROM [Banner] b
						   '+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END

 
GO
/****** Object:  StoredProcedure [dbo].[SpBannerCrud]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpBannerCrud] 12,'Shubham','s.jpg','http://shubham.com',1,'UpdateWithImage',''
-- =============================================
CREATE PROCEDURE [dbo].[SpBannerCrud]
	@Id int= '',
	@Title nvarchar(50)= '',
	@ImageType nvarchar(50)= '',
	@ClickUrl nvarchar(50) = '',
	@IsActive bit = 0,
	--@IsDeleted bit = 0,
	--@InsertedDate Datetime = 0,
	--@UpdatedDate Datetime = 0,
	@FLAG nvarchar(20) = 'INSERT',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
    
--------------------------------------------	
    --INSERT
--------------------------------------------
	--DECLARE @RETURNVAL nvarchar(50)
	IF @FLAG='INSERT'
	BEGIN 
		INSERT INTO Banner (Title,ImageType,ClickUrl,IsActive,IsDeleted,InsertedDate,UpdatedDate)
		VALUES (@Title,@ImageType,@ClickUrl,@IsActive,0,GETDATE(),null)
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	ELSE IF @FLAG='DELETE'
	BEGIN 
		UPDATE Banner SET IsDeleted=1 WHERE Id=@Id
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	Else IF @FLAG='UPDATE'
	BEGIN
		UPDATE Banner SET Title=@Title,ImageType=ISNULL(@ImageType,ImageType),ClickUrl=@ClickUrl,IsActive=@IsActive WHERE ID=@Id 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SpClientMasterCrud]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpClientMasterCrud] '97','','','Mrs.','Rachu','Patel',sbm,'1999','Nothing','hello',0,'Dindoli','Surat','Gujrat',394210,8899774455,8899775544,'','SBM.com','Web','','','EditProfile',''
-- =============================================
CREATE PROCEDURE [dbo].[SpClientMasterCrud]
	@ClientCd int= '',
	@LoginName varchar(100) = '',
	@Password varchar(100) = '',
	@Title varchar(5) = '',
	@FirstName varchar(50) = '',
	@LastName varchar(50) = '',
	@ReferenceThrough varchar(150) = '',
	@Birthdate datetime = '',
	@CompanyNm varchar(250) = '',
	@Designation varchar(100) = '',
	@Discount numeric(5,2) = '',
	@Address varchar(250) = '',
	@City varchar(50) = '',
	@State varchar(50) = '',
	@Zipcode varchar(10) = '',
	@Phone_No varchar(20) = '',
	@Mobile_No varchar(15) = '',
	@EmailID1 varchar(75) = '',
	@Website varchar(100) = '',
	@BussinessType varchar(150) = '',
	@Status varchar(10) = '',
	@Show_CertImage char(1) = '',
	@FLAG nvarchar(20) = '',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
    
--------------------------------------------	
    --INSERT
--------------------------------------------
	--DECLARE @RETURNVAL nvarchar(50)
	IF @FLAG='INSERT'
	BEGIN 
		INSERT INTO Clientmaster (EmailID1,Password,Title,FirstName,LastName,BussinessType,CompanyNm,Designation,ReferenceThrough,Birthdate,Address,City,State,Zipcode,Phone_No,Mobile_No,Website,Status,IsDeleted,InsertedDate,UpdatedDate)
		VALUES (@EmailID1,@Password,@Title,@FirstName,@LastName,@BussinessType,@CompanyNm,@Designation,@ReferenceThrough,@Birthdate,@Address,@City,@State,@Zipcode,@Phone_No,@Mobile_No,@Website,@Status,0,GETDATE(),null)
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	ELSE IF @FLAG='DELETE'
	BEGIN 
		UPDATE Clientmaster SET IsDeleted=1 WHERE ClientCd=@ClientCd 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	Else IF @FLAG='UPDATE'
	BEGIN
		UPDATE Clientmaster SET LoginName=@LoginName,Password=@Password,Title=@Title,FirstName=@FirstName,LastName=@LastName,Birthdate=@Birthdate,CompanyNm=@CompanyNm,Designation=@Designation,Discount=@Discount,Address=@Address,City=@City,State=@State,Zipcode=@Zipcode,Phone_No=@Phone_No,Mobile_No=@Mobile_No,EmailID1=@EmailID1,Website=@Website,BussinessType=@BussinessType,Status=@Status,Show_CertImage=@Show_CertImage WHERE ClientCd=@ClientCd 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	Else IF @FLAG='EditProfile'
	BEGIN
		UPDATE Clientmaster SET Title=@Title,FirstName=@FirstName,LastName=@LastName,Birthdate=@Birthdate,CompanyNm=@CompanyNm,Designation=@Designation,Address=@Address,City=@City,State=@State,Zipcode=@Zipcode,Phone_No=@Phone_No,Mobile_No=@Mobile_No,Website=@Website,BussinessType=@BussinessType,ReferenceThrough=@ReferenceThrough WHERE ClientCd=@ClientCd 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
END

GO
/****** Object:  StoredProcedure [dbo].[SpClientMasterList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpClientMasterList] 'And FirstName=''Shubham''','ORDER BY b.ClientCd ASC',10,1
-- =============================================
CREATE PROCEDURE [dbo].[SpClientMasterList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.ClientCd ASC'
	END
    
    SET @SQLStr ='select a.* from
	(select ROW_NUMBER() OVER('+@orderby+') as rn
,b.ClientCd ,ISNULL(b.[LoginName],'''') as [LoginName]
,ISNULL(b.[Password],'''') as [Password],ISNULL(b.[Title],'''') as [Title]
,ISNULL(b.[FirstName],'''') as [FirstName],ISNULL(b.[LastName],'''') as [LastName]
,ISNULL(b.[Birthdate],'''') as [Birthdate],ISNULL(b.[CompanyNm],'''') as [CompanyNm]
,ISNULL(b.[Designation],'''') as [Designation],ISNULL(b.[Terms],'''') as [Terms]
,ISNULL(b.[CreditDays],0) as [CreditDays],ISNULL(b.[Commission],0) as [Commission]
,ISNULL(b.[Brokerage],0) as [Brokerage],ISNULL(b.[PriceDiscount],0) as [PriceDiscount],ISNULL(b.[Discount],0) as [Discount]
,ISNULL(b.[PriceFormat],'''') as [PriceFormat],ISNULL(b.[TaxDetails],'''') as [TaxDetails]
,ISNULL(b.[ReferenceFrom],'''') as [ReferenceFrom],ISNULL(b.[ReferenceThrough],'''') as [ReferenceThrough]
,ISNULL(b.[Address],'''') as [Address],ISNULL(b.[City],'''') as [City]
,ISNULL(b.[State],'''') as [State],ISNULL(b.[Zipcode],'''') as [Zipcode]
,ISNULL(b.[Countrycd],'''') as [Countrycd],ISNULL(b.[Phone_Countrycd],'''') as [Phone_Countrycd]
,ISNULL(b.[Phone_STDcd],'''') as [Phone_STDcd],ISNULL(b.[Phone_No],'''') as [Phone_No]
,ISNULL(b.[Phone_Countrycd2],'''') as [Phone_Countrycd2],ISNULL(b.[Phone_STDCd2],'''') as [Phone_STDCd2]
,ISNULL(b.[Phone_No2],'''') as [Phone_No2],ISNULL(b.[Fax_Countrycd],'''') as [Fax_Countrycd]
,ISNULL(b.[Fax_STDCd],'''') as [Fax_STDCd],ISNULL(b.[Fax_No],'''') as [Fax_No]
,ISNULL(b.[Mobile_CountryCd],'''') as [Mobile_CountryCd],ISNULL(b.[Mobile_No],'''') as [Mobile_No]
,ISNULL(b.[EmailID1],'''') as [EmailID1],ISNULL(b.[EmailID2],'''') as [EmailID2]
,ISNULL(b.[EmailID3],'''') as [EmailID3],ISNULL(b.[All_EmailId],'''') as [All_EmailId]
,ISNULL(b.[Website],'''') as [Website],ISNULL(b.[BussinessType],'''') as [BussinessType]
,ISNULL(b.[InsertedDate],'''') as [InsertedDate],ISNULL(b.[CreatedBy],0) as [CreatedBy]
,ISNULL(b.[UpdatedDate],'''') as [UpdatedDate],ISNULL(b.[UpdatedBy],0) as [UpdatedBy]
,ISNULL(b.[ApproveStatus],'''') as [ApproveStatus],ISNULL(b.[ApproveStatusOn],'''') as [ApproveStatusOn]
,ISNULL(b.[Status],'''') as [Status],ISNULL(b.[WholeStockAccess],'''') as [WholeStockAccess]
,ISNULL(b.[ApproveStatusBy],0) as [ApproveStatusBy],ISNULL(b.[StatusUpdatedOn],'''') as [StatusUpdatedOn]
,ISNULL(b.[StatusUpdatedBy],0) as [StatusUpdatedBy],ISNULL(b.[BankDetails],'''') as [BankDetails]
,ISNULL(b.[RoutingDetails],'''') as [RoutingDetails],ISNULL(b.[Handle_Location],0) as [Handle_Location]
,ISNULL(b.[Smid],0) as [Smid],ISNULL(b.[EmailStatus],'''') as [EmailStatus],ISNULL(b.[LastLoginDate],'''') as [LastLoginDate]
,ISNULL(b.[SkypeId],'''') as [SkypeId],ISNULL(b.[QQId],'''') as [QQId]
,ISNULL(b.[EmailSubscr],'''') as [EmailSubscr],ISNULL(b.[EmailSubscrDate],'''') as [EmailSubscrDate]
,ISNULL(b.[UtypeId],0) as [UtypeId]
,ISNULL(b.[UserRights],'''') as [UserRights]
,ISNULL(b.[UploadInventory],'''') as [UploadInventory]
,ISNULL(b.[Show_HoldedStock],'''') as [Show_HoldedStock]
,ISNULL(b.[LoginMailAlertOn],'''') as [LoginMailAlertOn]
,ISNULL(b.[Show_CertImage],'''') as [Show_CertImage]
,ISNULL(b.[App_Id],'''') as [App_Id]
,ISNULL(b.[App_Pwd],'''') as [App_Pwd]
,ISNULL(b.[WeChatId],'''') as [WeChatId]
,ISNULL(b.[Client_Grade],0) as [Client_Grade]
,ISNULL(b.[WatchList_Priority],0) as [WatchList_Priority]
,ISNULL(b.[ShipmentType],'''') as [ShipmentType]
,ISNULL(b.[SecurityPin],0) as [SecurityPin]
,ISNULL(b.[Online_ClientCd],0) as [Online_ClientCd]
,ISNULL(b.[Online_SellerCd],0) as [Online_SellerCd]
,ISNULL(b.[IsActive],0) as [IsActive]
,ISNULL(b.[IsDeleted],0) as [IsDeleted]
,CASE WHEN IsActive=1 THEN ''Y'' WHEN IsActive=0 THEN ''N'' END Status1
,TotalRecords
FROM [Clientmaster] b OUTER APPLY(select COUNT(c.ClientCd) as TotalRecords FROM [Clientmaster] c
where 1=1 '+@whereclause+' AND ISNULL(c.IsDeleted,0)=0 AND ISNULL(c.IsActive,0)=1 ) as c_count
WHERE 1=1 '+@whereclause+' AND ISNULL(b.IsDeleted,0)=0 AND ISNULL(b.IsActive,0)=1 
) as a WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+' '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	 SET @SQLStrCnt =' select COUNT(b.ClientCd) as Cnt FROM [Clientmaster] b '--+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END
  
GO
/****** Object:  StoredProcedure [dbo].[spGetPassword]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [spGetPassword] 'shubhampatel1780@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[spGetPassword]
@Email nvarchar(50)
as
BEGIN
	If Exists(SELECT * FROM Clientmaster WHERE EmailID1=@Email)
	BEGIN
		SELECT EmailID1, Password FROM Clientmaster WHERE EmailID1=@Email 
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertShoppingCart]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext 'SpInsert_ShoppingCart'

Create PROCEDURE [dbo].[spInsertShoppingCart]  
@SC_stoneidS varchar(MAX),  
@SC_clientcd int,  
@SC_Status varchar(50),  
@sc_offerrate numeric(15,2)=NULL,  
@sc_offerdisc numeric(5,2)=NULL,
@ReturnVal VARCHAR(MAX) OUTPUT,
@RetOrderNo numeric(10) =null output,
@RetBuyReqId varchar(30) =null output,
@RetRefParams varchar(max) =null output
AS  
BEGIN  
 --SET NOCOUNT ON;  
 --/*------------------SHOPPINGCART INSERTION PROCESS BY CSV FROMATTED STONE VALUES------------------*/  
 DECLARE @SC_Date datetime, @ISHOLDBYREQUEST int, @SC_MemoDate datetime, @SC_delete_Date datetime,@HOLIDAYS INT,@SC_mail_Date datetime;  
 DECLARE @VSTONEID VARCHAR(30),@DELIMITER CHAR,@DELIMINDEX INT, @VSTONEIDLIST VARCHAR(MAX),@VHOLDSTATUS VARCHAR(5), @VBUYREQ_ID VARCHAR(30);  

 DECLARE @VSC_ID int, @SC_BUYREQ_HOURS NUMERIC(10);--02/09/2017 04:16
 SET @VSTONEIDLIST= @SC_stoneidS + ',';  
 SET @Delimiter=','  
 SET @DelimIndex = CHARINDEX(@Delimiter, @VSTONEIDLIST, 0)  
 SET @SC_Date = GetDate();  
 SET @SC_MemoDate = GetDate();  
 SET @ReturnVal ='';    

 IF @SC_Status in('B','I')  BEGIN
  --SELECT @VBUYREQ_ID = 'B'+right(replicate('0',3) + cast(BUYREQ_ID as varchar), 7) FROM MAX_BUYREQ_ID ;
  SELECT @VBUYREQ_ID = cast(BUYREQ_ID as varchar) FROM MAX_BUYREQ_ID ;
  UPDATE MAX_BUYREQ_ID SET BUYREQ_ID = BUYREQ_ID +1;
  set @RetBuyReqId =@VBUYREQ_ID;
 END;
 WHILE (@DelimIndex != 0) BEGIN  
-- SET @ReturnVal ='';
  SET @VSTONEID = SUBSTRING(@VSTONEIDLIST, 0, @DelimIndex)  
   
  BEGIN  
   IF @SC_Status='I' BEGIN  --'I' For Cart
    SELECT @SC_delete_Date =  getdate() + sc_delete_days  FROM SETTINGS  
    END  
   ELSE IF @SC_Status='B'  BEGIN  --'B' For Buy
    --SELECT @SC_delete_Date =  getdate() + scbr_delete_days  FROM SETTINGS  
       SELECT @SC_BUYREQ_HOURS = scbr_delete_days  FROM SETTINGS  
       SELECT @SC_delete_Date =  DATEADD(HH,@SC_BUYREQ_HOURS,getdate())   -----/* BY CLIENTREQUEST TO RELEASE BUY REQUEST EVERY 5 HOURS OF EACE REUQEST */
  /*---------------------------- GET HOLIDAY DAYS FROM HOLIDAY MASTER -------------------------------------------*/    
    declare @chk_sc_delete_date datetime                             --for indian timezone  
    set @chk_sc_delete_date =dateadd(mi,30,dateadd(hh,11,@SC_delete_Date))  
    SET @HOLIDAYS = DBO.GETHOLIDAYS(CONVERT(DATE,@chk_sc_delete_date,103))  
       SELECT @SC_delete_Date = dateadd(dd, @HOLIDAYS, @SC_delete_Date)  FROM SETTINGS
       Set @SC_mail_Date = dateadd(hh,-1,@SC_delete_Date)
   END
   ELSE IF @SC_Status='P'  BEGIN  --'P' For Bid
    SELECT @SC_delete_Date =  getdate() + BID_LIMIT_DAYS  FROM SETTINGS  
   END;    
   
    --IF @SC_Status<>'I' BEGIN  
       IF @SC_Status NOT IN('I','S') BEGIN  
          SELECT @VHOLDSTATUS=[dbo].[GetLegend3Status](@SC_clientcd,@VSTONEID,LEGEND3) FROM GRADDET WHERE STONEID=@VSTONEID
          select @ISHOLDBYREQUEST = count(1) from ShoppingCart WHERE SC_stoneid=@VSTONEID and (sc_status IN ('H','B')) AND SC_CUR_STATUS='I'
          IF @ISHOLDBYREQUEST > 0 OR @VHOLDSTATUS IN ('H','M','U','B') BEGIN    
              --goto BuyRequest          
              SET @VSTONEIDLIST  = SUBSTRING(@VSTONEIDLIST, @DelimIndex+1, LEN(@VSTONEIDLIST)-@DelimIndex);  
              SET @DelimIndex = CHARINDEX(@Delimiter, @VSTONEIDLIST, 0);  
              SET @ReturnVal = @ReturnVal + ',' + @VSTONEID;
              CONTINUE;
          END  
    END;
  END;  
      select @RetOrderNo = isnull(max(orderno+1),10000) from shoppingcart;
         IF @VSTONEID<>'' BEGIN  
              --IF EXISTS(SELECT SC_Id FROM ShoppingCart WHERE SC_clientcd=@SC_clientcd AND SC_stoneid=@VSTONEID AND SC_CUR_STATUS='I') BEGIN-- AND SC_Status='P') BEGIN
              IF EXISTS(SELECT SC_Id FROM ShoppingCart WHERE SC_clientcd=@SC_clientcd AND SC_stoneid=@VSTONEID AND SC_CUR_STATUS='I') BEGIN
                           UPDATE ShoppingCart SET SC_CUR_STATUS='O'--,SC_STATUS='O'
                           WHERE SC_stoneid=@VSTONEID AND SC_clientcd=@SC_clientcd AND SC_CUR_STATUS='I'
              END
               DECLARE @VPROCESS VARCHAR(30);

               SELECT @VPROCESS = CASE @SC_Status WHEN 'I' THEN 'CART' WHEN 'B' THEN 'BUY' WHEN 'P' THEN 'OFFERDISC' WHEN 'M' THEN 'MEMO' WHEN 'S' THEN 'SALE' END ;

               SELECT  @RetRefParams =isnull(@RetRefParams,'') + STONEID +',' + CONVERT(VARCHAR,CTS)
                           +','+ CONVERT(VARCHAR, case when @sc_offerdisc != 0 then @sc_offerdisc else ASKDISC_FC end)
                           +','+ CONVERT(VARCHAR, case when @sc_offerrate != 0 then @sc_offerrate else ASKRATE_FC end)
                           +','+ CONVERT(VARCHAR, (case when @sc_offerrate != 0 then @sc_offerrate * CTS else ASKAMT_FC end)) +'@'  FROM GRADDET WHERE STONEID = @VSTONEID ;

               INSERT INTO SHOPPINGCART (SC_stoneid, SC_clientcd, SC_Status, SC_Date, SC_MemoDate, SC_delete_Date, sc_offerrate, sc_offerdisc,SC_PROCESSEES,SC_CUR_STATUS,
                     orderno, SC_SHAPE, SC_CTS, SC_COLOR, SC_CLARITY, SC_CUT, SC_POLISH, SC_SYM, SC_FLOURENCE, SC_FL_COLOR, SC_INCLUSION, SC_HA,
                     SC_LUSTER, SC_GIRDLE, SC_GIRDLE_CONDITION, SC_CULET, SC_MILKY, SC_SHADE, SC_NATTS, SC_NATURAL, SC_DEPTH, SC_DIATABLE, SC_LENGTH,
                     SC_WIDTH, SC_PAVILION, SC_CROWN, SC_PAVANGLE, SC_CROWNANGLE, SC_HEIGHT, SC_PAVHEIGHT, SC_CROWNHEIGHT, SC_MEASUREMENT, SC_RATIO,
                     SC_PAIR, SC_STAR_LENGTH, SC_LOWER_HALF, SC_KEY_TO_SYMBOL, SC_REPORT_COMMENT, SC_CERTIFICATE, SC_CERTNO, SC_RAPARATE, SC_RAPAAMT,
                     SC_CURDATE, SC_LOCATION, SC_LEGEND1, SC_LEGEND2, SC_LEGEND3, SC_ASKRATE_FC, SC_ASKDISC_FC, SC_ASKAMT_FC, SC_COSTRATE_FC,
                     SC_COSTDISC_FC, SC_COSTAMT_FC, SC_GIRDLEPER, SC_DIA, SC_COLORDESC, SC_BARCODE, SC_INSCRIPTION, SC_NEW_CERT, SC_MEMBER_COMMENT,
                     SC_UPLOADCLIENTID, SC_REPORT_DATE, SC_NEW_ARRI_DATE, SC_TINGE, SC_EYE_CLN, SC_TABLE_INCL, SC_SIDE_INCL, SC_TABLE_BLACK,
                     SC_SIDE_BLACK, SC_TABLE_OPEN, SC_SIDE_OPEN, SC_PAV_OPEN, SC_EXTRA_FACET, SC_INTERNAL_COMMENT, SC_POLISH_FEATURES,
                     SC_SYMMETRY_FEATURES, SC_GRAINING, SC_IMG_URL, SC_RATEDISC, SC_GRADE, SC_CLIENT_LOCATION, SC_ORIGIN, BUY_REQID )
              SELECT @VSTONEID, @SC_clientcd, @SC_Status, @SC_Date, @SC_MemoDate, @SC_delete_Date, @sc_offerrate, @sc_offerdisc, @VPROCESS,'I',@RetOrderNo,
                     SHAPE, CTS, COLOR, CLARITY, CUT, POLISH, SYM, FLOURENCE, FL_COLOR, INCLUSION, HA, LUSTER, GIRDLE, GIRDLE_CONDITION, CULET,
                     MILKY, SHADE, NATTS, NATURAL, DEPTH, DIATABLE, LENGTH, WIDTH, PAVILION, CROWN, PAVANGLE, CROWNANGLE, HEIGHT, PAVHEIGHT,
                     CROWNHEIGHT, MEASUREMENT, RATIO, PAIR, STAR_LENGTH, LOWER_HALF, KEY_TO_SYMBOL, REPORT_COMMENT, CERTIFICATE, CERTNO, RAPARATE,
                     RAPAAMT, CURDATE, LOCATION, LEGEND1, LEGEND2, LEGEND3, ASKRATE_FC, ASKDISC_FC, ASKAMT_FC, COSTRATE_FC, COSTDISC_FC, COSTAMT_FC,
                     GIRDLEPER, DIA, COLORDESC, BARCODE, INSCRIPTION, NEW_CERT, MEMBER_COMMENT, UPLOADCLIENTID, REPORT_DATE, NEW_ARRI_DATE, TINGE,
                     EYE_CLN, TABLE_INCL, SIDE_INCL, TABLE_BLACK, SIDE_BLACK, TABLE_OPEN, SIDE_OPEN, PAV_OPEN, EXTRA_FACET,
                     INTERNAL_COMMENT, POLISH_FEATURES, SYMMETRY_FEATURES, GRAINING, IMG_URL, RATEDISC, GRADE, CLIENT_LOCATION, ORIGIN, @VBUYREQ_ID
               FROM GRADDET
               WHERE STONEID = @VSTONEID;
          END  
          ELSE BEGIN
                      UPDATE ShoppingCart SET SC_Status=@SC_Status,                            
                      sc_offerrate=@sc_offerrate,sc_offerdisc=@sc_offerdisc,SC_Date=@SC_Date,sc_delete_date=@sc_delete_date, SC_mail_Date=@SC_mail_Date
                      WHERE SC_stoneid=@VSTONEID AND SC_clientcd=@SC_clientcd AND SC_Status <> 'O'
          END  

          SET @VSTONEIDLIST  = SUBSTRING(@VSTONEIDLIST, @DelimIndex+1, LEN(@VSTONEIDLIST)-@DelimIndex);  
          SET @DelimIndex = CHARINDEX(@Delimiter, @VSTONEIDLIST, 0);  
       
  END;  
 END;

GO
/****** Object:  StoredProcedure [dbo].[SpOrderList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpOrderList] 'and FirstName=''Shubham''','ORDER BY b.SC_Id ASC',10,2
-- =============================================
CREATE PROCEDURE [dbo].[SpOrderList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.SC_Id ASC'
	END
    
    SET @SQLStr ='
    select a.* from
	(select 
		ROW_NUMBER() OVER('+@orderby+') as rn
		  ,b.SC_Id
		  ,ISNULL(u.[FirstName],'''') as [FirstName]
		  ,ISNULL(u.[EmailID1],'''') as [EmailID1]
		  ,ISNULL(b.[SC_stoneid],'''') as [SC_stoneid]
		  ,ISNULL(b.[SC_Clientcd],'''') as [SC_Clientcd]
		  ,ISNULL(b.[SC_Status],'''') as [SC_Status]
		  ,ISNULL(b.[SC_CUR_STATUS],'''') as [SC_CUR_STATUS]
		  ,ISNULL(b.[SC_SHAPE],'''') as [SC_SHAPE]
		  ,ISNULL(b.[SC_CTS],0) as [SC_CTS]
		  ,ISNULL(b.[SC_COLOR],'''') as [SC_COLOR]
		,ISNULL(b.[SC_CLARITY],'''') as [SC_CLARITY]
		,ISNULL(b.[SC_CUT],'''') as [SC_CUT]
		,ISNULL(b.[SC_POLISH],'''') as [SC_POLISH]
		,ISNULL(b.[SC_SYM],'''') as [SC_SYM]
		,ISNULL(b.[SC_FLOURENCE],'''') as [SC_FLOURENCE]
		,ISNULL(b.[SC_CERTNO],'''') as [SC_CERTNO]
		,ISNULL(b.[SC_RAPARATE],0) as [SC_RAPARATE]
		,ISNULL(b.[SC_RAPAAMT],0) as [SC_RAPAAMT]
		,ISNULL(b.[SC_DEPTH],0) as [SC_DEPTH]
		,ISNULL(b.[SC_DIATABLE],0) as [SC_DIATABLE]
		,ISNULL(b.[SC_MEASUREMENT],'''') as [SC_MEASUREMENT]
		,ISNULL(b.[SC_GIRDLE],'''') as [SC_GIRDLE]
		,ISNULL(b.[SC_LEGEND1],'''') as [SC_LEGEND1]
		,ISNULL(b.[SC_LEGEND2],'''') as [SC_LEGEND2]
		,ISNULL(b.[SC_LOCATION],'''') as [SC_LOCATION]
		,ISNULL(b.[SC_CERTIFICATE],'''') as [SC_CERTIFICATE]
		,TotalRecords
	  FROM [ShoppingCart] b
	  FULL OUTER JOIN [Clientmaster] u ON b.SC_Clientcd = u.ClientCd
	  OUTER APPLY(select COUNT(c.SC_Id) as TotalRecords FROM [ShoppingCart] c
	  JOIN [Clientmaster] u ON c.SC_Clientcd = u.ClientCd
	  where 1=1 '+@whereclause+' AND c.SC_Status=''B'' AND c.SC_CUR_STATUS=''I'') as c_count
	  WHERE 1=1 '+@whereclause+' AND b.SC_Status=''B'' AND b.SC_CUR_STATUS=''I''

	 ) as a
	 WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+'
	 '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	 SET @SQLStrCnt =' select 
							COUNT(b.SC_Id) as Cnt 
							FROM [ShoppingCart] b WHERE b.SC_Status=''B'' AND b.SC_CUR_STATUS=''I''
						   '--+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END

 
GO
/****** Object:  StoredProcedure [dbo].[SpProcmasCrud]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpProcmasCrud] 5,'Sparkle Web',1,'Mumbai','shubham',1,'y',1,'Red','Red','Red','Red','Red',1,'UPDATE',''
-- =============================================
CREATE PROCEDURE [dbo].[SpProcmasCrud]
	@Id int= '',
	@Procgroup varchar(20)= '',
	@Proccd numeric(10,0)= 0,
	@Procnm varchar(100) = '',
	@Shortnm varchar(100) = '',
	@Ord numeric(10,0) = 0,
	@IsActive bit = 0,
	--@IsDeleted bit = 0,
	--@InsertedDate Datetime = 0,
	--@UpdatedDate Datetime = 0,
	@FLAG nvarchar(10) = 'INSERT',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
    
--------------------------------------------	
    --INSERT'
--------------------------------------------
	--DECLARE @RETURNVAL nvarchar(50)
	IF @FLAG='INSERT'
	BEGIN 
		INSERT INTO Procmas (Procgroup,Proccd,Procnm,Shortnm,Ord,IsActive,IsDeleted,InsertedDate,UpdatedDate)
		VALUES (@Procgroup,@Proccd,@Procnm,@Shortnm,@Ord,@IsActive,0,GETDATE(),null)
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	ELSE IF @FLAG='DELETE'
	BEGIN 
		UPDATE Procmas SET IsDeleted=1 WHERE Id=@Id
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	Else IF @FLAG='UPDATE'
	BEGIN
		UPDATE Procmas SET Procgroup=@Procgroup,Proccd=@Proccd,Procnm=@Procnm,Shortnm=@Shortnm,Ord=@Ord,IsActive=@IsActive WHERE ID=@Id 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
END


GO
/****** Object:  StoredProcedure [dbo].[SpProcmasList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpProcmasList] '','ORDER BY b.Id ASC',10,1
-- =============================================
CREATE PROCEDURE [dbo].[SpProcmasList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.Id ASC'
	END
    
    SET @SQLStr ='
    select a.* from
	(select 
		ROW_NUMBER() OVER('+@orderby+') as rn
		  ,b.Id
		  ,ISNULL(b.[Procgroup],'''') as [Procgroup]
		  ,ISNULL(b.[Proccd],0)as [Proccd]
		  ,ISNULL(b.[Procnm],'''') as [Procnm]
		  ,ISNULL(b.[Shortnm],'''') as [Shortnm]
		  ,ISNULL(b.[Ord],0) as [Ord]
		  --,ISNULL(b.[Status],'''') as [Status]
		  ,ISNULL(b.[Fancy_Color_Status],'''') as [Fancy_Color_Status]
		  ,ISNULL(b.[IsChangeable],'''') as [IsChangeable]
		  ,ISNULL(b.[Fancy_Color],'''') as [Fancy_Color]
		  ,ISNULL(b.[Fancy_Intensity],'''') as [Fancy_Intensity]
		  ,ISNULL(b.[Fancy_Overtone],'''') as [Fancy_Overtone]
		  ,ISNULL(b.[F_CTS],'''') as [F_CTS]
		  ,ISNULL(b.[T_CTS],'''') as [T_CTS]
		  ,ISNULL(b.[IsActive],0) as [IsActive]
		  ,CASE WHEN IsActive=1 THEN ''Y'' WHEN IsActive=0 THEN ''N'' END Status1
		  ,TotalRecords
	  FROM [Procmas] b
	   OUTER APPLY(select COUNT(c.Id) as TotalRecords FROM [Procmas] c
	  where  1=1 '+@whereclause+' AND ISNULL(c.IsDeleted,0)=0 ) as c_count
	  WHERE 1=1 '+@whereclause+' AND ISNULL(b.IsDeleted,0)=0 
	 ) as a
	 WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+'
	 '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	 SET @SQLStrCnt =' select 
							COUNT(b.Id) as Cnt 
							FROM [Procmas] b
						   '+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END

 
GO
/****** Object:  StoredProcedure [dbo].[SpShoppingCartCrud]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpShoppingCartCrud] '','PA226110',93,'B','I','B',''
/*DECLARE @RETURNVAL nvarchar(100);
EXEC [SpShoppingCartCrud] '','PA226',97,'I','I','B',@RETURNVAL output
PRINT @RETURNVAL;*/
-- execute [SpShoppingCartCrud] 0,'PA226015',97,'','','CART',''
-- =============================================
CREATE PROCEDURE [dbo].[SpShoppingCartCrud]
	@SC_Id int= '',
	@SC_stoneid varchar(50)= '',
	@SC_Clientcd int= '',
	@SC_Status varchar(50)= '',
	@SC_CUR_STATUS char(1)= '',
	@FLAG nvarchar(15) = '',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
	SET @SC_Id = (SELECT MAX(SC_Id)+1 FROM ShoppingCart);
	--SET @SC_Status = 'I'
	--SET @SC_CUR_STATUS = 'I'
	IF @FLAG='CART' --INSERT	
	BEGIN
		IF EXISTS (SELECT * FROM ShoppingCart WHERE SC_stoneid=@SC_stoneid AND SC_Status='I' And SC_Clientcd=@SC_Clientcd )	
		BEGIN
			SET @RETURNVAL='-1'--Exists 
			RETURN @RETURNVAL
			--PRINT @RETURNVAL
		END	
		ELSE
		BEGIN
			SET @SC_Status = 'I'
			SET @SC_CUR_STATUS = 'I'
			SET IDENTITY_INSERT ShoppingCart ON
			INSERT INTO ShoppingCart (SC_Id,SC_stoneid,SC_Clientcd,SC_Status,SC_CUR_STATUS,SC_SHAPE,SC_CTS,SC_COLOR,SC_CLARITY,SC_CUT,SC_POLISH,SC_SYM,SC_FLOURENCE,
					SC_FL_COLOR,SC_INCLUSION,SC_HA,SC_LUSTER,SC_GIRDLE,SC_GIRDLE_CONDITION,SC_CULET,SC_MILKY,SC_SHADE,SC_NATTS,SC_NATURAL,SC_DEPTH,SC_DIATABLE,
					SC_LENGTH,SC_WIDTH,SC_PAVILION,SC_CROWN,SC_PAVANGLE,SC_CROWNANGLE,SC_HEIGHT,SC_PAVHEIGHT,SC_CROWNHEIGHT,SC_MEASUREMENT,SC_RATIO,SC_PAIR,
					SC_STAR_LENGTH,SC_LOWER_HALF,SC_KEY_TO_SYMBOL,SC_REPORT_COMMENT,SC_CERTIFICATE,SC_CERTNO,SC_RAPARATE,SC_RAPAAMT,SC_CURDATE,SC_LOCATION,
					SC_LEGEND1,SC_LEGEND2,SC_LEGEND3,SC_ASKRATE_FC,SC_ASKDISC_FC,SC_ASKAMT_FC,SC_COSTRATE_FC,SC_COSTDISC_FC,SC_COSTAMT_FC,SC_GIRDLEPER,SC_DIA,
					SC_COLORDESC,SC_BARCODE,SC_INSCRIPTION,SC_NEW_CERT,SC_MEMBER_COMMENT,SC_UPLOADCLIENTID,SC_REPORT_DATE,SC_NEW_ARRI_DATE,SC_TINGE,SC_EYE_CLN,
					SC_TABLE_INCL,SC_SIDE_INCL,SC_TABLE_BLACK,SC_SIDE_BLACK,SC_TABLE_OPEN,SC_SIDE_OPEN,SC_PAV_OPEN,SC_EXTRA_FACET,SC_INTERNAL_COMMENT,SC_POLISH_FEATURES,
					SC_SYMMETRY_FEATURES,SC_GRAINING,SC_IMG_URL,SC_RATEDISC,SC_GRADE,SC_CLIENT_LOCATION,SC_ORIGIN)
			SELECT @SC_Id,@SC_stoneid,@SC_Clientcd,@SC_Status,@SC_CUR_STATUS,SHAPE, CTS, COLOR, CLARITY, CUT, POLISH, SYM, FLOURENCE, FL_COLOR, INCLUSION, HA, LUSTER, GIRDLE, GIRDLE_CONDITION,
					CULET,MILKY, SHADE, NATTS, NATURAL, DEPTH, DIATABLE, LENGTH, WIDTH, PAVILION, CROWN, PAVANGLE, CROWNANGLE, HEIGHT, PAVHEIGHT,CROWNHEIGHT, MEASUREMENT, RATIO,
					PAIR, STAR_LENGTH, LOWER_HALF, KEY_TO_SYMBOL, REPORT_COMMENT, CERTIFICATE, CERTNO, RAPARATE,RAPAAMT, CURDATE, LOCATION, LEGEND1, LEGEND2, LEGEND3, ASKRATE_FC,
					ASKDISC_FC, ASKAMT_FC, COSTRATE_FC, COSTDISC_FC, COSTAMT_FC,GIRDLEPER, DIA, COLORDESC, BARCODE, INSCRIPTION, NEW_CERT, MEMBER_COMMENT, UPLOADCLIENTID,
					REPORT_DATE, NEW_ARRI_DATE, TINGE,EYE_CLN, TABLE_INCL, SIDE_INCL, TABLE_BLACK, SIDE_BLACK, TABLE_OPEN, SIDE_OPEN, PAV_OPEN, EXTRA_FACET,
                    INTERNAL_COMMENT, POLISH_FEATURES, SYMMETRY_FEATURES, GRAINING, IMG_URL, RATEDISC, GRADE, CLIENT_LOCATION, ORIGIN
			FROM GRADDET
			WHERE STONEID=@SC_stoneid
			SET @RETURNVAL='1'--'CART'
			RETURN @RETURNVAL
			SET IDENTITY_INSERT ShoppingCart OFF
		END	
	END	
	ELSE IF @FLAG='BUY'
	BEGIN
	IF EXISTS (SELECT * FROM ShoppingCart WHERE SC_stoneid=@SC_stoneid AND SC_Status='B')	
		BEGIN
			SET @RETURNVAL='0'--Out Of Stock  
			RETURN @RETURNVAL
			PRINT @RETURNVAL
		END	
		ELSE
		BEGIN
			SET @SC_Status = 'B'
			SET @SC_CUR_STATUS = 'I'
			SET IDENTITY_INSERT ShoppingCart ON
			INSERT INTO ShoppingCart (SC_Id,SC_stoneid,SC_Clientcd,SC_Status,SC_CUR_STATUS,SC_SHAPE,SC_CTS,SC_COLOR,SC_CLARITY,SC_CUT,SC_POLISH,SC_SYM,SC_FLOURENCE,
					SC_FL_COLOR,SC_INCLUSION,SC_HA,SC_LUSTER,SC_GIRDLE,SC_GIRDLE_CONDITION,SC_CULET,SC_MILKY,SC_SHADE,SC_NATTS,SC_NATURAL,SC_DEPTH,SC_DIATABLE,
					SC_LENGTH,SC_WIDTH,SC_PAVILION,SC_CROWN,SC_PAVANGLE,SC_CROWNANGLE,SC_HEIGHT,SC_PAVHEIGHT,SC_CROWNHEIGHT,SC_MEASUREMENT,SC_RATIO,SC_PAIR,
					SC_STAR_LENGTH,SC_LOWER_HALF,SC_KEY_TO_SYMBOL,SC_REPORT_COMMENT,SC_CERTIFICATE,SC_CERTNO,SC_RAPARATE,SC_RAPAAMT,SC_CURDATE,SC_LOCATION,
					SC_LEGEND1,SC_LEGEND2,SC_LEGEND3,SC_ASKRATE_FC,SC_ASKDISC_FC,SC_ASKAMT_FC,SC_COSTRATE_FC,SC_COSTDISC_FC,SC_COSTAMT_FC,SC_GIRDLEPER,SC_DIA,
					SC_COLORDESC,SC_BARCODE,SC_INSCRIPTION,SC_NEW_CERT,SC_MEMBER_COMMENT,SC_UPLOADCLIENTID,SC_REPORT_DATE,SC_NEW_ARRI_DATE,SC_TINGE,SC_EYE_CLN,
					SC_TABLE_INCL,SC_SIDE_INCL,SC_TABLE_BLACK,SC_SIDE_BLACK,SC_TABLE_OPEN,SC_SIDE_OPEN,SC_PAV_OPEN,SC_EXTRA_FACET,SC_INTERNAL_COMMENT,SC_POLISH_FEATURES,
					SC_SYMMETRY_FEATURES,SC_GRAINING,SC_IMG_URL,SC_RATEDISC,SC_GRADE,SC_CLIENT_LOCATION,SC_ORIGIN)
			SELECT @SC_Id,@SC_stoneid,@SC_Clientcd,@SC_Status,@SC_CUR_STATUS,SHAPE, CTS, COLOR, CLARITY, CUT, POLISH, SYM, FLOURENCE, FL_COLOR, INCLUSION, HA, LUSTER, GIRDLE, GIRDLE_CONDITION,
					CULET,MILKY, SHADE, NATTS, NATURAL, DEPTH, DIATABLE, LENGTH, WIDTH, PAVILION, CROWN, PAVANGLE, CROWNANGLE, HEIGHT, PAVHEIGHT,CROWNHEIGHT, MEASUREMENT, RATIO,
					PAIR, STAR_LENGTH, LOWER_HALF, KEY_TO_SYMBOL, REPORT_COMMENT, CERTIFICATE, CERTNO, RAPARATE,RAPAAMT, CURDATE, LOCATION, LEGEND1, LEGEND2, LEGEND3, ASKRATE_FC,
					ASKDISC_FC, ASKAMT_FC, COSTRATE_FC, COSTDISC_FC, COSTAMT_FC,GIRDLEPER, DIA, COLORDESC, BARCODE, INSCRIPTION, NEW_CERT, MEMBER_COMMENT, UPLOADCLIENTID,
					REPORT_DATE, NEW_ARRI_DATE, TINGE,EYE_CLN, TABLE_INCL, SIDE_INCL, TABLE_BLACK, SIDE_BLACK, TABLE_OPEN, SIDE_OPEN, PAV_OPEN, EXTRA_FACET,
                    INTERNAL_COMMENT, POLISH_FEATURES, SYMMETRY_FEATURES, GRAINING, IMG_URL, RATEDISC, GRADE, CLIENT_LOCATION, ORIGIN
			FROM GRADDET
			WHERE STONEID=@SC_stoneid
			SET @RETURNVAL='2'--'Buy'
			RETURN @RETURNVAL
			SET IDENTITY_INSERT ShoppingCart OFF
		END
	END	
	ELSE IF @FLAG='B'
	BEGIN 
		IF EXISTS (SELECT * FROM ShoppingCart WHERE SC_stoneid=@SC_stoneid AND SC_Status='B')	
		BEGIN
			SET @RETURNVAL='0'--Exists 
			RETURN @RETURNVAL
			PRINT @RETURNVAL
		END	
		ELSE
		BEGIN
			UPDATE ShoppingCart SET SC_Status='B' WHERE SC_stoneid=@SC_stoneid AND SC_CUR_STATUS='I' AND SC_Clientcd=@SC_Clientcd
			SET @RETURNVAL='2'--'BUY'
			RETURN @RETURNVAL
			PRINT @RETURNVAL
		END
	END	
	ELSE IF @FLAG='CARTDELETE'
	BEGIN 
		UPDATE ShoppingCart SET SC_CUR_STATUS='O' WHERE SC_stoneid=@SC_stoneid AND SC_Status='I' AND SC_Clientcd=@SC_Clientcd
		SET @RETURNVAL='3'
		RETURN @RETURNVAL
	END	
	ELSE IF @FLAG='BUYDELETE'
	BEGIN 
		UPDATE ShoppingCart SET SC_CUR_STATUS='O' WHERE SC_stoneid=@SC_stoneid AND SC_Status='B' AND SC_Clientcd=@SC_Clientcd
		SET @RETURNVAL='4'
		RETURN @RETURNVAL
	END	
END

GO
/****** Object:  StoredProcedure [dbo].[SpShoppingCartList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpShoppingCartList] '','ORDER BY b.SC_Id ASC',10,5
-- =============================================
CREATE PROCEDURE [dbo].[SpShoppingCartList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.SC_Id ASC'
	END
    
    SET @SQLStr ='
    select a.* from
	(select 
		ROW_NUMBER() OVER('+@orderby+') as rn
		  ,b.SC_Id
		  ,ISNULL(b.[SC_stoneid],'''') as [SC_stoneid]
		  ,ISNULL(b.[SC_Clientcd],'''') as [SC_Clientcd]
		  ,ISNULL(b.[SC_Status],'''') as [SC_Status]
		  ,ISNULL(b.[SC_CUR_STATUS],'''') as [SC_CUR_STATUS]
		  ,ISNULL(b.[SC_SHAPE],'''') as [SC_SHAPE]
		  ,ISNULL(b.[SC_CTS],0) as [SC_CTS]
		  ,ISNULL(b.[SC_COLOR],'''') as [SC_COLOR]
		,ISNULL(b.[SC_CLARITY],'''') as [SC_CLARITY]
		,ISNULL(b.[SC_CUT],'''') as [SC_CUT]
		,ISNULL(b.[SC_POLISH],'''') as [SC_POLISH]
		,ISNULL(b.[SC_SYM],'''') as [SC_SYM]
		,ISNULL(b.[SC_FLOURENCE],'''') as [SC_FLOURENCE]
		,ISNULL(b.[SC_CERTNO],'''') as [SC_CERTNO]
		,ISNULL(b.[SC_RAPARATE],0) as [SC_RAPARATE]
		,ISNULL(b.[SC_RAPAAMT],0) as [SC_RAPAAMT]
		,ISNULL(b.[SC_DEPTH],0) as [SC_DEPTH]
		,ISNULL(b.[SC_DIATABLE],0) as [SC_DIATABLE]
		,ISNULL(b.[SC_MEASUREMENT],'''') as [SC_MEASUREMENT]
		,ISNULL(b.[SC_GIRDLE],'''') as [SC_GIRDLE]
		,ISNULL(b.[SC_LEGEND1],'''') as [SC_LEGEND1]
		,ISNULL(b.[SC_LEGEND2],'''') as [SC_LEGEND2]
		,ISNULL(b.[SC_LOCATION],'''') as [SC_LOCATION]
		,ISNULL(b.[SC_CERTIFICATE],'''') as [SC_CERTIFICATE]
		,TotalRecords
	  FROM [ShoppingCart] b
	  OUTER APPLY(select COUNT(c.SC_Id) as TotalRecords FROM [ShoppingCart] c
	  where 1=1 '+@whereclause+') as c_count
	  WHERE 1=1 '+@whereclause+'

	 ) as a
	 WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+'
	 '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	 SET @SQLStrCnt =' select 
							COUNT(b.SC_Id) as Cnt 
							FROM [ShoppingCart] b
						   '+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END

 
GO
/****** Object:  StoredProcedure [dbo].[SpStoneList]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpStoneList] ' AND STONEID=''PH233067'' ','ORDER BY b.COMPCD ASC',10,1
-- execute [SpStoneList] '','ORDER BY b.COMPCD ASC',10,1
-- =============================================
CREATE PROCEDURE [dbo].[SpStoneList]
	@whereclause nvarchar(max)= '',
	@orderby nvarchar(max)= '',
	@pagesize int = 0,
	@pageno int = 0
	--@SC_Status varchar(50)='',
	--@SC_CUR_STATUS char(1)=''
	--@SC_Status varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		SET NOCOUNT ON;
--------------------------------------------
    DECLARE @StartPage INT = ((@pageno - 1) * @pagesize)+ 1
    DECLARE @EndPage INT = ((@pageno - 1) * @pagesize) + @pagesize
        
    DECLARE @SQLStr NVARCHAR(MAX) = ''
    DECLARE @SQLStrCnt NVARCHAR(MAX) = ''
	
	IF @orderby='' OR @orderby IS NULL
	BEGIN
	 SET @orderby='ORDER BY b.COMPCD ASC'
	END
    
    SET @SQLStr ='
select a.* from
(select 
ROW_NUMBER() OVER('+@orderby+') as rn
--,b.Id
--,ISNULL(s.[SC_Status],'''') as [SC_Status],ISNULL(s.[SC_CUR_STATUS],'''') as [SC_CUR_STATUS]
,ISNULL(b.[COMPCD],0) as [COMPCD],ISNULL(b.[STONEID],'''') as [STONEID]
,ISNULL(b.[SHAPE],'''') as [SHAPE],ISNULL(b.[CTS],0) as [CTS]
,ISNULL(b.[COLOR],'''') as [COLOR],ISNULL(b.[CLARITY],'''') as [CLARITY]
,ISNULL(b.[CUT],'''') as [CUT],ISNULL(b.[POLISH],'''') as [POLISH]
,ISNULL(b.[SYM],'''') as [SYM],ISNULL(b.[FLOURENCE],'''') as [FLOURENCE]
,ISNULL(b.[FL_COLOR],'''') as [FL_COLOR],ISNULL(b.[INCLUSION],'''') as [INCLUSION]
,ISNULL(b.[HA],0) as [HA],ISNULL(b.[LUSTER],'''') as [LUSTER]
,ISNULL(b.[GIRDLE],'''') as [GIRDLE],ISNULL(b.[GIRDLE_CONDITION],'''') as [GIRDLE_CONDITION]
,ISNULL(b.[CULET],'''') as [CULET],ISNULL(b.[MILKY],'''') as [MILKY]
,ISNULL(b.[SHADE],'''') as [SHADE],ISNULL(b.[NATTS],'''') as [NATTS]
,ISNULL(b.[NATURAL],'''') as [NATURAL],ISNULL(b.[DEPTH],0) as [DEPTH]
,ISNULL(b.[DIATABLE],0) as [DIATABLE],ISNULL(b.[LENGTH],0) as [LENGTH]
,ISNULL(b.[WIDTH],0) as [WIDTH],ISNULL(b.[PAVILION],0) as [PAVILION]
,ISNULL(b.[CROWN],0) as [CROWN],ISNULL(b.[PAVANGLE],0) as [PAVANGLE]
,ISNULL(b.[CROWNANGLE],0) as [CROWNANGLE],ISNULL(b.[HEIGHT],0) as [HEIGHT]
,ISNULL(b.[PAVHEIGHT],0) as [PAVHEIGHT],ISNULL(b.[CROWNHEIGHT],0) as [CROWNHEIGHT]
,ISNULL(b.[MEASUREMENT],'''') as [MEASUREMENT],ISNULL(b.[RATIO],0) as [RATIO]
,ISNULL(b.[PAIR],'''') as [PAIR],ISNULL(b.[STAR_LENGTH],0) as [STAR_LENGTH]
,ISNULL(b.[LOWER_HALF],0) as [LOWER_HALF],ISNULL(b.[KEY_TO_SYMBOL],'''') as [KEY_TO_SYMBOL]
,ISNULL(b.[REPORT_COMMENT],'''') as [REPORT_COMMENT],ISNULL(b.[CERTIFICATE],'''') as [CERTIFICATE]
,ISNULL(b.[CERTNO],'''') as [CERTNO],ISNULL(b.[RAPARATE],0) as [RAPARATE]
,ISNULL(b.[RAPAAMT],0) as [RAPAAMT],ISNULL(b.[CURDATE],'''') as [CURDATE]
,ISNULL(b.[LOCATION],'''') as [LOCATION],ISNULL(b.[LEGEND1],'''') as [LEGEND1]
,ISNULL(b.[LEGEND2],'''') as [LEGEND2],ISNULL(b.[LEGEND3],'''') as [LEGEND3]
,ISNULL(b.[ASKRATE_FC],0) as [ASKRATE_FC],ISNULL(b.[ASKDISC_FC],0) as [ASKDISC_FC]
,ISNULL(b.[ASKAMT_FC],0) as [ASKAMT_FC],ISNULL(b.[COSTRATE_FC],0) as [COSTRATE_FC]
,ISNULL(b.[COSTDISC_FC],0) as [COSTDISC_FC],ISNULL(b.[COSTAMT_FC],0) as [COSTAMT_FC]
,ISNULL(b.[WEB_CLIENTID],0) as [WEB_CLIENTID],ISNULL(b.[wl_rej_status],'''') as [wl_rej_status]
,ISNULL(b.[GIRDLEPER],'''') as [GIRDLEPER],ISNULL(b.[DIA],0) as [DIA]
,ISNULL(b.[COLORDESC],'''') as [COLORDESC],ISNULL(b.[BARCODE],'''') as [BARCODE]
,ISNULL(b.[INSCRIPTION],'''') as [INSCRIPTION],ISNULL(b.[NEW_CERT],'''') as [NEW_CERT]
,ISNULL(b.[MEMBER_COMMENT],'''') as [MEMBER_COMMENT],ISNULL(b.[UPLOADCLIENTID],0) as [UPLOADCLIENTID]
,ISNULL(b.[REPORT_DATE],'''') as [REPORT_DATE],ISNULL(b.[NEW_ARRI_DATE],'''') as [NEW_ARRI_DATE]
,ISNULL(b.[TINGE],'''') as [TINGE],ISNULL(b.[EYE_CLN],'''') as [EYE_CLN]
,ISNULL(b.[TABLE_INCL],'''') as [TABLE_INCL],ISNULL(b.[SIDE_INCL],'''') as [SIDE_INCL]
,ISNULL(b.[TABLE_BLACK],'''') as [TABLE_BLACK],ISNULL(b.[SIDE_BLACK],'''') as [SIDE_BLACK]
,ISNULL(b.[TABLE_OPEN],'''') as [TABLE_OPEN],ISNULL(b.[SIDE_OPEN],'''') as [SIDE_OPEN]
,ISNULL(b.[PAV_OPEN],'''') as [PAV_OPEN],ISNULL(b.[EXTRA_FACET],'''') as [EXTRA_FACET]
,ISNULL(b.[INTERNAL_COMMENT],'''') as [INTERNAL_COMMENT],ISNULL(b.[POLISH_FEATURES],'''') as [POLISH_FEATURES]
,ISNULL(b.[SYMMETRY_FEATURES],'''') as [SYMMETRY_FEATURES],ISNULL(b.[GRAINING],'''') as [GRAINING]
,ISNULL(b.[IMG_URL],'''') as [IMG_URL],ISNULL(b.[RATEDISC],'''') as [RATEDISC]
,ISNULL(b.[GRADE],'''') as [GRADE],ISNULL(b.[CLIENT_LOCATION],'''') as [CLIENT_LOCATION]
,ISNULL(b.[ORIGIN],'''') as [ORIGIN],ISNULL(b.[BGM],'''') as [BGM]
,TotalRecords
FROM [GRADDET] b
OUTER APPLY(select COUNT(c.COMPCD) as TotalRecords FROM [GRADDET] c
where STONEID NOT IN (SELECT SC_STONEID FROM ShoppingCart WHERE SC_Status=''B'' AND SC_CUR_STATUS=''I'' )  '+@whereclause+') as c_count
WHERE STONEID NOT IN (SELECT SC_STONEID FROM ShoppingCart WHERE SC_Status=''B'' AND SC_CUR_STATUS=''I'' ) '+@whereclause+'   
 
) as a
WHERE a.rn >= '+CONVERT(VARCHAR(5),@StartPage)+' AND a.rn <= '+CONVERT(VARCHAR(5),@EndPage)+'
	 '
	 PRINT(@SQLStr)
	 EXEC(@SQLStr)
	 
	  SET @SQLStrCnt =' select 
							COUNT(b.COMPCD) as Cnt 
							FROM [GRADDET] b WHERE STONEID NOT IN (SELECT SC_STONEID FROM ShoppingCart WHERE SC_Status=''B'' AND SC_CUR_STATUS=''I'' )
						   '+@whereclause+''
	 PRINT(@SQLStrCnt)
	 EXEC(@SQLStrCnt)
END

 
GO
/****** Object:  StoredProcedure [dbo].[SpStoneListCrud]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>																																				7n,2v,1n,5v,1i,2d,2v
-- execute [SpStoneListCrud] 1,'B2','Rouund',0.6,'H','vs1','vg','ex','ex','none','s','s','ha','s','STK-THK','FACETED','NONE','s','s','s','s','0.5','INSERT',''
-- =============================================
CREATE PROCEDURE [dbo].[SpStoneListCrud]
	@COMPCD numeric(5,0)= '',
	@STONEID nvarchar(30)= '',
	@SHAPE nvarchar(20) = '',
	@CTS decimal(10,2) = '',
	@COLOR nvarchar(10) = '',
	@CLARITY nvarchar(10) = '',
	@CUT nvarchar(20) = '',
	@POLISH nvarchar(20) = '',
	@SYM nvarchar(20) = '',
	@FLOURENCE nvarchar(20) = '',
	@FL_COLOR nvarchar(20) = '',
	@INCLUSION nvarchar(20) = '',
	@HA nvarchar(100) = '',
	@LUSTER nvarchar(20) = '',
	@GIRDLE nvarchar(20) = '',
	@GIRDLE_CONDITION nvarchar(20) = '',
	@CULET nvarchar(20) = '',
	@MILKY nvarchar(20) = '',
	@SHADE nvarchar(20) = '',
	@NATTS nvarchar(20) = '',
	@NATURAL nvarchar(20) = '',
	--@DEPTH numeric(5,2) ,
	@DIATABLE numeric(5,2) = '',
	@LENGTH numeric(5,2) = '',
	@WIDTH numeric(5,2) = '',
	@PAVILION numeric(5,2) = '',
	@CROWN numeric(5,2) = '',
	@PAVANGLE numeric(5,2) = '',
	@CROWNANGLE numeric(5,2) = '',
	@HEIGHT numeric(5,2) = '',
	@PAVHEIGHT numeric(5,2) = '',
	@CROWNHEIGHT numeric(5,2) = '',
	@MEASUREMENT nvarchar(20) = '',
	@RATIO numeric(5,2) = '',
	@PAIR nvarchar(10) = '',
	@STAR_LENGTH numeric(10,2) = '',
	@LOWER_HALF numeric(10,2) = '',
	@KEY_TO_SYMBOL nvarchar(300) = '',
	@REPORT_COMMENT nvarchar(300) = '',
	@CERTIFICATE nvarchar(20) = '',
	@CERTNO nvarchar(20) = '',
	@RAPARATE numeric(10,2) = '',
	@RAPAAMT numeric(14,2) = '',
	@CURDATE datetime = '',
	@LOCATION nvarchar(20) = '',
	@LEGEND1 nvarchar(20) = '',
	@LEGEND2 nvarchar(20) = '',
	@LEGEND3 nvarchar(20) = '',
	@ASKRATE_FC numeric(15,2) = '',
	@ASKDISC_FC numeric(15,2) = '',
	@ASKAMT_FC numeric(15,2) = '',
	@COSTRATE_FC numeric(15,2) = '',
	@COSTDISC_FC numeric(15,2) = '',
	@COSTAMT_FC numeric(15,2) = '',
	@WEB_CLIENTID numeric(10,0) = '', 
	@wl_rej_status nvarchar(50) = '',
	@GIRDLEPER nvarchar(20) = '',
	@DIA numeric(5,2) = '',
	@COLORDESC nvarchar(100) = '',
	@BARCODE nvarchar(30) = '',
	@INSCRIPTION nvarchar(20) = '',
	@NEW_CERT nvarchar(2) = '',
	@MEMBER_COMMENT nvarchar(300) = '',
	@UPLOADCLIENTID int = '',
	@REPORT_DATE datetime = '',
	@NEW_ARRI_DATE datetime = '',
	@TINGE nvarchar(20) = '',
	@EYE_CLN nvarchar(20) = '',
	@TABLE_INCL nvarchar(30) = '',
	@SIDE_INCL nvarchar(30) = '',
	@TABLE_BLACK nvarchar(30) = '',
	@SIDE_BLACK nvarchar(30) = '',
	@TABLE_OPEN nvarchar(30) = '',
	@SIDE_OPEN nvarchar(30) = '',
	@PAV_OPEN nvarchar(30) = '',
	@EXTRA_FACET nvarchar(30) = '',
	@INTERNAL_COMMENT nvarchar(500) = '',
	@POLISH_FEATURES nvarchar(500) = '',
	@SYMMETRY_FEATURES nvarchar(500) = '',
	@GRAINING nvarchar(20) = '',
	@IMG_URL nvarchar(500) = '',
	@RATEDISC nvarchar(20) = '',
	@GRADE nvarchar(30) = '',
	@CLIENT_LOCATION nvarchar(20) = '',
	@ORIGIN nvarchar(20) = '',
	@BGM char(1)='',
	@FLAG nvarchar(10) = '',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
    
--------------------------------------------	
    --INSERT
--------------------------------------------
	--SELECT * FROM Temp 
	If @FLAG='INSERT'
	BEGIN
		IF  EXISTS(SELECT STONEID FROM GRADDET WHERE STONEID=@STONEID)
		BEGIN 
			SET @RETURNVAL='-1'
			RETURN @RETURNVAL
		END
		ELSE 
		BEGIN
			INSERT INTO GRADDET (COMPCD,STONEID,SHAPE,CTS,COLOR,CLARITY,CUT,POLISH,SYM,FLOURENCE,FL_COLOR,INCLUSION,HA,LUSTER,GIRDLE,GIRDLE_CONDITION,
			CULET,MILKY,SHADE,NATTS,NATURAL,DIATABLE,LENGTH,WIDTH,PAVILION,CROWN,PAVANGLE,CROWNANGLE,HEIGHT,PAVHEIGHT,CROWNHEIGHT,MEASUREMENT,
			RATIO,PAIR,STAR_LENGTH,LOWER_HALF,KEY_TO_SYMBOL,REPORT_COMMENT,CERTIFICATE,CERTNO,RAPARATE,RAPAAMT,CURDATE,LOCATION,LEGEND1,LEGEND2,LEGEND3,
			ASKRATE_FC,ASKDISC_FC,ASKAMT_FC,COSTRATE_FC,COSTDISC_FC,COSTAMT_FC,WEB_CLIENTID,wl_rej_status,GIRDLEPER,DIA,COLORDESC,BARCODE,
			INSCRIPTION,NEW_CERT,MEMBER_COMMENT,UPLOADCLIENTID,REPORT_DATE,NEW_ARRI_DATE,TINGE,EYE_CLN,TABLE_INCL,SIDE_INCL,TABLE_BLACK,SIDE_BLACK,TABLE_OPEN,
			SIDE_OPEN,PAV_OPEN,EXTRA_FACET,INTERNAL_COMMENT,POLISH_FEATURES,SYMMETRY_FEATURES,GRAINING,IMG_URL,RATEDISC,GRADE,CLIENT_LOCATION,
			ORIGIN,BGM)
			
			VALUES (@COMPCD,@STONEID,@SHAPE,@CTS,@COLOR,@CLARITY,@CUT,@POLISH,@SYM,@FLOURENCE,@FL_COLOR,@INCLUSION,@HA,@LUSTER,@GIRDLE,@GIRDLE_CONDITION,
			@CULET,@MILKY,@SHADE,@NATTS,@NATURAL,@DIATABLE,@LENGTH,@WIDTH,@PAVILION,@CROWN,@PAVANGLE,@CROWNANGLE,@HEIGHT,@PAVHEIGHT,@CROWNHEIGHT,@MEASUREMENT,
		    @RATIO,@PAIR,@STAR_LENGTH,@LOWER_HALF,@KEY_TO_SYMBOL,@REPORT_COMMENT,@CERTIFICATE,@CERTNO,@RAPARATE,@RAPAAMT,@CURDATE,@LOCATION,@LEGEND1,@LEGEND2,@LEGEND3,
			@ASKRATE_FC,@ASKDISC_FC,@ASKAMT_FC,@COSTRATE_FC,@COSTDISC_FC,@COSTAMT_FC,@WEB_CLIENTID,@wl_rej_status,@GIRDLEPER,@DIA,@COLORDESC,@BARCODE,
			@INSCRIPTION,@NEW_CERT,@MEMBER_COMMENT,@UPLOADCLIENTID,@REPORT_DATE,@NEW_ARRI_DATE,@TINGE,@EYE_CLN,@TABLE_INCL,@SIDE_INCL,@TABLE_BLACK,@SIDE_BLACK,
			@TABLE_OPEN,@SIDE_OPEN,@PAV_OPEN,@EXTRA_FACET,@INTERNAL_COMMENT,@POLISH_FEATURES,@SYMMETRY_FEATURES,@GRAINING,@IMG_URL,@RATEDISC,@GRADE,@CLIENT_LOCATION,
			@ORIGIN,@BGM)
			
			SET @RETURNVAL='1'
			RETURN @RETURNVAL			 
		END
	END
END
--CAST(@DEPTH AS NUMERIC(5, 2)
GO
/****** Object:  StoredProcedure [dbo].[spValidAdmin]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [spValidAdmin] 'diamond@sparkleweb.com','123456'
-- =============================================
create PROCEDURE [dbo].[spValidAdmin]
@Email_Id nvarchar(50),
@Password nvarchar(50)
as
BEGIN
	If Exists(SELECT * FROM AdminLogin WHERE Email_Id=@Email_Id and Password=@Password)
	BEGIN
		SELECT * FROM AdminLogin WHERE Email_Id=@Email_Id and Password=@Password
	END
END

GO
/****** Object:  StoredProcedure [dbo].[spValidLogin]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [spValidLogin] 'shubhampatel1780@gmail.com','123123123'
-- =============================================
CREATE PROCEDURE [dbo].[spValidLogin]
@EmailID1 varchar(75),
@Password varchar(100)
as
BEGIN
	If Exists(SELECT ClientCd,EmailID1,Password,Status,LoginName FROM Clientmaster WHERE EmailID1=@EmailID1 and Password=@Password)
	BEGIN
		SELECT ClientCd,EmailID1,Password,Status,LoginName FROM Clientmaster WHERE EmailID1=@EmailID1 and Password=@Password
	END
END

GO
/****** Object:  Table [dbo].[AdminLogin]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdminLogin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Email_Id] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[User_Profile_Image] [nvarchar](max) NULL,
 CONSTRAINT [PK_AdminLogin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Banner]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Banner](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NULL,
	[ImageType] [nvarchar](50) NULL,
	[ClickUrl] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Banner] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Clientmaster]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Clientmaster](
	[ClientCd] [int] IDENTITY(1,1) NOT NULL,
	[LoginName] [varchar](100) NULL,
	[Password] [varchar](100) NULL,
	[Title] [varchar](5) NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Birthdate] [datetime] NULL,
	[CompanyNm] [varchar](250) NULL,
	[Designation] [varchar](100) NULL,
	[Terms] [varchar](50) NULL,
	[CreditDays] [numeric](5, 0) NULL,
	[Commission] [numeric](5, 2) NULL,
	[Brokerage] [numeric](5, 2) NULL,
	[PriceDiscount] [numeric](5, 2) NULL,
	[Discount] [numeric](5, 2) NULL,
	[PriceFormat] [char](10) NULL,
	[TaxDetails] [varchar](250) NULL,
	[ReferenceFrom] [varchar](150) NULL,
	[ReferenceThrough] [varchar](150) NULL,
	[Address] [varchar](250) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Zipcode] [varchar](10) NULL,
	[Countrycd] [varchar](20) NULL,
	[Phone_Countrycd] [varchar](10) NULL,
	[Phone_STDcd] [varchar](10) NULL,
	[Phone_No] [varchar](20) NULL,
	[Phone_Countrycd2] [varchar](10) NULL,
	[Phone_STDCd2] [varchar](10) NULL,
	[Phone_No2] [varchar](20) NULL,
	[Fax_Countrycd] [varchar](10) NULL,
	[Fax_STDCd] [varchar](10) NULL,
	[Fax_No] [varchar](20) NULL,
	[Mobile_CountryCd] [varchar](10) NULL,
	[Mobile_No] [varchar](15) NULL,
	[EmailID1] [varchar](75) NULL,
	[EmailID2] [varchar](75) NULL,
	[EmailID3] [varchar](75) NULL,
	[All_Emailid] [varchar](300) NULL,
	[Website] [varchar](100) NULL,
	[BussinessType] [varchar](150) NULL,
	[InsertedDate] [datetime] NULL,
	[CreatedBy] [numeric](10, 0) NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [numeric](10, 0) NULL,
	[ApproveStatus] [varchar](1) NULL,
	[ApproveStatusOn] [datetime] NULL,
	[ApproveStatusBy] [numeric](10, 0) NULL,
	[StatusUpdatedOn] [datetime] NULL,
	[StatusUpdatedBy] [numeric](10, 0) NULL,
	[Status] [varchar](10) NULL,
	[WholeStockAccess] [varchar](1) NULL,
	[BankDetails] [varchar](4000) NULL,
	[RoutingDetails] [varchar](4000) NULL,
	[Handle_Location] [int] NULL,
	[Smid] [int] NULL,
	[EmailStatus] [varchar](10) NULL,
	[LastLoginDate] [datetime] NULL,
	[SkypeId] [varchar](100) NULL,
	[QQId] [varchar](100) NULL,
	[EmailSubscr] [char](1) NULL,
	[EmailSubscrDate] [datetime] NULL,
	[UTypeID] [int] NULL,
	[UserRights] [varchar](1) NULL,
	[UploadInventory] [varchar](1) NULL,
	[Show_HoldedStock] [char](1) NULL,
	[LoginMailAlertOn] [date] NULL,
	[Show_CertImage] [char](1) NULL,
	[App_Id] [varchar](50) NULL,
	[App_Pwd] [varchar](50) NULL,
	[WeChatId] [nvarchar](200) NULL,
	[Client_Grade] [int] NULL,
	[WatchList_Priority] [int] NULL,
	[ShipmentType] [varchar](30) NULL,
	[SecurityPin] [varchar](4) NULL,
	[Online_ClientCd] [numeric](10, 0) NULL,
	[Online_SellerCd] [numeric](10, 0) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_CM_CLIENTCD] PRIMARY KEY CLUSTERED 
(
	[ClientCd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GRADDET]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GRADDET](
	[COMPCD] [numeric](5, 0) NULL,
	[STONEID] [varchar](30) NULL,
	[SHAPE] [varchar](20) NULL,
	[CTS] [decimal](10, 2) NULL,
	[COLOR] [varchar](10) NULL,
	[CLARITY] [varchar](10) NULL,
	[CUT] [varchar](20) NULL,
	[POLISH] [varchar](20) NULL,
	[SYM] [varchar](20) NULL,
	[FLOURENCE] [varchar](20) NULL,
	[FL_COLOR] [varchar](20) NULL,
	[INCLUSION] [varchar](20) NULL,
	[HA] [varchar](100) NULL,
	[LUSTER] [varchar](20) NULL,
	[GIRDLE] [varchar](20) NULL,
	[GIRDLE_CONDITION] [varchar](20) NULL,
	[CULET] [varchar](20) NULL,
	[MILKY] [varchar](20) NULL,
	[SHADE] [varchar](20) NULL,
	[NATTS] [varchar](20) NULL,
	[NATURAL] [varchar](20) NULL,
	[DEPTH] [numeric](5, 2) NULL,
	[DIATABLE] [numeric](5, 2) NULL,
	[LENGTH] [numeric](5, 2) NULL,
	[WIDTH] [numeric](5, 2) NULL,
	[PAVILION] [numeric](5, 2) NULL,
	[CROWN] [numeric](5, 2) NULL,
	[PAVANGLE] [numeric](5, 2) NULL,
	[CROWNANGLE] [numeric](5, 2) NULL,
	[HEIGHT] [numeric](5, 2) NULL,
	[PAVHEIGHT] [numeric](5, 2) NULL,
	[CROWNHEIGHT] [numeric](5, 2) NULL,
	[MEASUREMENT] [varchar](30) NULL,
	[RATIO] [numeric](5, 2) NULL,
	[PAIR] [varchar](10) NULL,
	[STAR_LENGTH] [numeric](10, 2) NULL,
	[LOWER_HALF] [numeric](10, 2) NULL,
	[KEY_TO_SYMBOL] [varchar](300) NULL,
	[REPORT_COMMENT] [varchar](300) NULL,
	[CERTIFICATE] [varchar](20) NULL,
	[CERTNO] [varchar](20) NULL,
	[RAPARATE] [numeric](10, 2) NULL,
	[RAPAAMT] [numeric](14, 2) NULL,
	[CURDATE] [datetime] NULL,
	[LOCATION] [varchar](20) NULL,
	[LEGEND1] [varchar](20) NULL,
	[LEGEND2] [varchar](20) NULL,
	[LEGEND3] [varchar](20) NULL,
	[ASKRATE_FC] [numeric](15, 2) NULL,
	[ASKDISC_FC] [numeric](15, 2) NULL,
	[ASKAMT_FC] [numeric](15, 2) NULL,
	[COSTRATE_FC] [numeric](15, 2) NULL,
	[COSTDISC_FC] [numeric](15, 2) NULL,
	[COSTAMT_FC] [numeric](15, 2) NULL,
	[WEB_CLIENTID] [numeric](10, 0) NULL,
	[wl_rej_status] [varchar](50) NULL,
	[GIRDLEPER] [varchar](20) NULL,
	[DIA] [numeric](5, 2) NULL,
	[COLORDESC] [varchar](100) NULL,
	[BARCODE] [varchar](30) NULL,
	[INSCRIPTION] [varchar](20) NULL,
	[NEW_CERT] [varchar](2) NULL,
	[MEMBER_COMMENT] [varchar](300) NULL,
	[UPLOADCLIENTID] [int] NULL,
	[REPORT_DATE] [datetime] NULL,
	[NEW_ARRI_DATE] [datetime] NULL,
	[TINGE] [varchar](20) NULL,
	[EYE_CLN] [varchar](20) NULL,
	[TABLE_INCL] [varchar](30) NULL,
	[SIDE_INCL] [varchar](30) NULL,
	[TABLE_BLACK] [varchar](30) NULL,
	[SIDE_BLACK] [varchar](30) NULL,
	[TABLE_OPEN] [varchar](30) NULL,
	[SIDE_OPEN] [varchar](30) NULL,
	[PAV_OPEN] [varchar](30) NULL,
	[EXTRA_FACET] [varchar](30) NULL,
	[INTERNAL_COMMENT] [varchar](500) NULL,
	[POLISH_FEATURES] [varchar](500) NULL,
	[SYMMETRY_FEATURES] [varchar](500) NULL,
	[GRAINING] [varchar](20) NULL,
	[IMG_URL] [varchar](500) NULL,
	[RATEDISC] [varchar](20) NULL,
	[GRADE] [varchar](30) NULL,
	[CLIENT_LOCATION] [varchar](20) NULL,
	[ORIGIN] [varchar](20) NULL,
	[BGM] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Procmas]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Procmas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Procgroup] [varchar](20) NULL,
	[Proccd] [numeric](10, 0) NULL,
	[Procnm] [varchar](100) NULL,
	[Shortnm] [varchar](100) NULL,
	[Ord] [numeric](10, 0) NULL,
	[Fancy_Color_Status] [varchar](1) NULL,
	[IsChangeable] [bit] NULL,
	[Fancy_Color] [nchar](10) NULL,
	[Fancy_Intensity] [nchar](10) NULL,
	[Fancy_Overtone] [nchar](10) NULL,
	[F_CTS] [nchar](10) NULL,
	[T_CTS] [nchar](10) NULL,
	[IsDeleted] [bit] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Procmas1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShoppingCart]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShoppingCart](
	[SC_Id] [int] IDENTITY(1,1) NOT NULL,
	[SC_stoneid] [varchar](50) NULL,
	[SC_Clientcd] [int] NULL,
	[SC_Status] [varchar](50) NULL,
	[SC_Date] [datetime] NULL,
	[SC_MemoDate] [datetime] NULL,
	[SC_delete_date] [datetime] NULL,
	[sc_offerrate] [numeric](15, 2) NULL,
	[sc_offerdisc] [numeric](5, 2) NULL,
	[sc_rej_status] [varchar](50) NULL,
	[SC_PROCESSEES] [varchar](20) NULL,
	[SC_CUR_STATUS] [char](1) NULL,
	[isMailed] [varchar](1) NULL,
	[sc_mail_date] [datetime] NULL,
	[orderno] [numeric](10, 0) NULL,
	[SC_SHAPE] [varchar](20) NULL,
	[SC_CTS] [decimal](10, 2) NULL,
	[SC_COLOR] [varchar](10) NULL,
	[SC_CLARITY] [varchar](10) NULL,
	[SC_CUT] [varchar](20) NULL,
	[SC_POLISH] [varchar](20) NULL,
	[SC_SYM] [varchar](20) NULL,
	[SC_FLOURENCE] [varchar](20) NULL,
	[SC_FL_COLOR] [varchar](20) NULL,
	[SC_INCLUSION] [varchar](20) NULL,
	[SC_HA] [varchar](100) NULL,
	[SC_LUSTER] [varchar](20) NULL,
	[SC_GIRDLE] [varchar](20) NULL,
	[SC_GIRDLE_CONDITION] [varchar](20) NULL,
	[SC_CULET] [varchar](20) NULL,
	[SC_MILKY] [varchar](20) NULL,
	[SC_SHADE] [varchar](20) NULL,
	[SC_NATTS] [varchar](20) NULL,
	[SC_NATURAL] [varchar](20) NULL,
	[SC_DEPTH] [numeric](5, 2) NULL,
	[SC_DIATABLE] [numeric](5, 2) NULL,
	[SC_LENGTH] [numeric](5, 2) NULL,
	[SC_WIDTH] [numeric](5, 2) NULL,
	[SC_PAVILION] [numeric](5, 2) NULL,
	[SC_CROWN] [numeric](5, 2) NULL,
	[SC_PAVANGLE] [numeric](5, 2) NULL,
	[SC_CROWNANGLE] [numeric](5, 2) NULL,
	[SC_HEIGHT] [numeric](5, 2) NULL,
	[SC_PAVHEIGHT] [numeric](5, 2) NULL,
	[SC_CROWNHEIGHT] [numeric](5, 2) NULL,
	[SC_MEASUREMENT] [varchar](30) NULL,
	[SC_RATIO] [numeric](5, 2) NULL,
	[SC_PAIR] [varchar](10) NULL,
	[SC_STAR_LENGTH] [numeric](10, 2) NULL,
	[SC_LOWER_HALF] [numeric](10, 2) NULL,
	[SC_KEY_TO_SYMBOL] [varchar](300) NULL,
	[SC_REPORT_COMMENT] [varchar](300) NULL,
	[SC_CERTIFICATE] [varchar](20) NULL,
	[SC_CERTNO] [varchar](20) NULL,
	[SC_RAPARATE] [numeric](10, 2) NULL,
	[SC_RAPAAMT] [numeric](14, 2) NULL,
	[SC_CURDATE] [datetime] NULL,
	[SC_LOCATION] [varchar](20) NULL,
	[SC_LEGEND1] [varchar](20) NULL,
	[SC_LEGEND2] [varchar](20) NULL,
	[SC_LEGEND3] [varchar](20) NULL,
	[SC_ASKRATE_FC] [numeric](15, 2) NULL,
	[SC_ASKDISC_FC] [numeric](15, 2) NULL,
	[SC_ASKAMT_FC] [numeric](15, 2) NULL,
	[SC_COSTRATE_FC] [numeric](15, 2) NULL,
	[SC_COSTDISC_FC] [numeric](15, 2) NULL,
	[SC_COSTAMT_FC] [numeric](15, 2) NULL,
	[SC_GIRDLEPER] [varchar](20) NULL,
	[SC_DIA] [numeric](5, 2) NULL,
	[SC_COLORDESC] [varchar](100) NULL,
	[SC_BARCODE] [varchar](30) NULL,
	[SC_INSCRIPTION] [varchar](20) NULL,
	[SC_NEW_CERT] [varchar](2) NULL,
	[SC_MEMBER_COMMENT] [varchar](300) NULL,
	[SC_UPLOADCLIENTID] [int] NULL,
	[SC_REPORT_DATE] [datetime] NULL,
	[SC_NEW_ARRI_DATE] [datetime] NULL,
	[SC_TINGE] [varchar](20) NULL,
	[SC_EYE_CLN] [varchar](20) NULL,
	[SC_TABLE_INCL] [varchar](30) NULL,
	[SC_SIDE_INCL] [varchar](30) NULL,
	[SC_TABLE_BLACK] [varchar](30) NULL,
	[SC_SIDE_BLACK] [varchar](30) NULL,
	[SC_TABLE_OPEN] [varchar](30) NULL,
	[SC_SIDE_OPEN] [varchar](30) NULL,
	[SC_PAV_OPEN] [varchar](30) NULL,
	[SC_EXTRA_FACET] [varchar](30) NULL,
	[SC_INTERNAL_COMMENT] [varchar](500) NULL,
	[SC_POLISH_FEATURES] [varchar](500) NULL,
	[SC_SYMMETRY_FEATURES] [varchar](500) NULL,
	[SC_GRAINING] [varchar](20) NULL,
	[SC_IMG_URL] [varchar](500) NULL,
	[SC_RATEDISC] [varchar](20) NULL,
	[SC_GRADE] [varchar](30) NULL,
	[SC_CLIENT_LOCATION] [varchar](20) NULL,
	[SC_ORIGIN] [varchar](20) NULL,
	[BUY_REQID] [varchar](30) NULL,
	[ERP_PROFORMA_ID] [varchar](50) NULL,
	[ERP_INVOICE_ID] [varchar](50) NULL,
	[ERP_INVOICE_DATE] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Temp]    Script Date: 06-Aug-20 03:45:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Temp](
	[COMPCD] [numeric](5, 0) NULL,
	[STONEID] [nvarchar](30) NULL,
	[SHAPE] [nvarchar](20) NULL,
	[CTS] [decimal](10, 2) NULL,
	[COLOR] [nvarchar](10) NULL,
	[CLARITY] [nvarchar](10) NULL,
	[CUT] [nvarchar](20) NULL,
	[POLISH] [nvarchar](20) NULL,
	[SYM] [nvarchar](20) NULL,
	[FLOURENCE] [nvarchar](20) NULL,
	[FL_COLOR] [nvarchar](20) NULL,
	[INCLUSION] [nvarchar](20) NULL,
	[HA] [nvarchar](100) NULL,
	[LUSTER] [nvarchar](20) NULL,
	[GIRDLE] [nvarchar](20) NULL,
	[GIRDLE_CONDITION] [nvarchar](20) NULL,
	[CULET] [nvarchar](20) NULL,
	[MILKY] [nvarchar](20) NULL,
	[SHADE] [nvarchar](20) NULL,
	[NATTS] [nvarchar](20) NULL,
	[NATURAL] [nvarchar](20) NULL,
	[DEPTH] [numeric](5, 2) NULL,
	[DIATABLE] [numeric](5, 2) NULL,
	[LENGTH] [numeric](5, 2) NULL,
	[WIDTH] [numeric](5, 2) NULL,
	[PAVILION] [numeric](5, 2) NULL,
	[CROWN] [numeric](5, 2) NULL,
	[PAVANGLE] [numeric](5, 2) NULL,
	[CROWNANGLE] [numeric](5, 2) NULL,
	[HEIGHT] [numeric](5, 2) NULL,
	[PAVHEIGHT] [numeric](5, 2) NULL,
	[CROWNHEIGHT] [numeric](5, 2) NULL,
	[MEASUREMENT] [nvarchar](30) NULL,
	[RATIO] [numeric](5, 2) NULL,
	[PAIR] [nvarchar](10) NULL,
	[STAR_LENGTH] [numeric](10, 2) NULL,
	[LOWER_HALF] [numeric](10, 2) NULL,
	[KEY_TO_SYMBOL] [nvarchar](300) NULL,
	[REPORT_COMMENT] [nvarchar](300) NULL,
	[CERTIFICATE] [nvarchar](20) NULL,
	[CERTNO] [nvarchar](20) NULL,
	[RAPARATE] [numeric](10, 2) NULL,
	[RAPAAMT] [numeric](14, 2) NULL,
	[CURDATE] [datetime] NULL,
	[LOCATION] [nvarchar](20) NULL,
	[LEGEND1] [nvarchar](20) NULL,
	[LEGEND2] [nvarchar](20) NULL,
	[LEGEND3] [nvarchar](20) NULL,
	[ASKRATE_FC] [numeric](15, 2) NULL,
	[ASKDISC_FC] [numeric](15, 2) NULL,
	[ASKAMT_FC] [numeric](15, 2) NULL,
	[COSTRATE_FC] [numeric](15, 2) NULL,
	[COSTDISC_FC] [numeric](15, 2) NULL,
	[COSTAMT_FC] [numeric](15, 2) NULL,
	[WEB_CLIENTID] [numeric](10, 0) NULL,
	[wl_rej_status] [nvarchar](50) NULL,
	[GIRDLEPER] [nvarchar](20) NULL,
	[DIA] [numeric](5, 2) NULL,
	[COLORDESC] [nvarchar](100) NULL,
	[BARCODE] [nvarchar](30) NULL,
	[INSCRIPTION] [nvarchar](20) NULL,
	[NEW_CERT] [nvarchar](2) NULL,
	[MEMBER_COMMENT] [nvarchar](300) NULL,
	[UPLOADCLIENTID] [int] NULL,
	[REPORT_DATE] [datetime] NULL,
	[NEW_ARRI_DATE] [datetime] NULL,
	[TINGE] [nvarchar](20) NULL,
	[EYE_CLN] [nvarchar](20) NULL,
	[TABLE_INCL] [nvarchar](30) NULL,
	[SIDE_INCL] [nvarchar](30) NULL,
	[TABLE_BLACK] [nvarchar](30) NULL,
	[SIDE_BLACK] [nvarchar](30) NULL,
	[TABLE_OPEN] [nvarchar](30) NULL,
	[SIDE_OPEN] [nvarchar](30) NULL,
	[PAV_OPEN] [nvarchar](30) NULL,
	[EXTRA_FACET] [nvarchar](30) NULL,
	[INTERNAL_COMMENT] [nvarchar](500) NULL,
	[POLISH_FEATURES] [nvarchar](500) NULL,
	[SYMMETRY_FEATURES] [nvarchar](500) NULL,
	[GRAINING] [nvarchar](20) NULL,
	[IMG_URL] [nvarchar](500) NULL,
	[RATEDISC] [nvarchar](20) NULL,
	[GRADE] [nvarchar](30) NULL,
	[CLIENT_LOCATION] [nvarchar](20) NULL,
	[ORIGIN] [nvarchar](20) NULL,
	[BGM] [char](1) NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Temp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[AdminLogin] ON 

INSERT [dbo].[AdminLogin] ([Id], [Name], [Email_Id], [Password], [User_Profile_Image]) VALUES (1, N'Shubham Patel', N'Sparkleweb@dp.com', N'123456', N'DSC_8620.jpg')
SET IDENTITY_INSERT [dbo].[AdminLogin] OFF
SET IDENTITY_INSERT [dbo].[Banner] ON 

INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (1, N'Slider 1', N'slider-3-1.jpg', N'http://Banner.com', 1, 0, CAST(0x0000ABE40109445A AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (2, N'Slider 2', N'slider-3-2.jpg', N'http://Banner.com', 1, 0, CAST(0x0000ABE4010962A8 AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (3, N'Slider 3', N'slider-3-3.jpg', N'http://Banner.com', 1, 0, CAST(0x0000ABE401097DD0 AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Banner] OFF
SET IDENTITY_INSERT [dbo].[Clientmaster] ON 

INSERT [dbo].[Clientmaster] ([ClientCd], [LoginName], [Password], [Title], [FirstName], [LastName], [Birthdate], [CompanyNm], [Designation], [Terms], [CreditDays], [Commission], [Brokerage], [PriceDiscount], [Discount], [PriceFormat], [TaxDetails], [ReferenceFrom], [ReferenceThrough], [Address], [City], [State], [Zipcode], [Countrycd], [Phone_Countrycd], [Phone_STDcd], [Phone_No], [Phone_Countrycd2], [Phone_STDCd2], [Phone_No2], [Fax_Countrycd], [Fax_STDCd], [Fax_No], [Mobile_CountryCd], [Mobile_No], [EmailID1], [EmailID2], [EmailID3], [All_Emailid], [Website], [BussinessType], [InsertedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [ApproveStatus], [ApproveStatusOn], [ApproveStatusBy], [StatusUpdatedOn], [StatusUpdatedBy], [Status], [WholeStockAccess], [BankDetails], [RoutingDetails], [Handle_Location], [Smid], [EmailStatus], [LastLoginDate], [SkypeId], [QQId], [EmailSubscr], [EmailSubscrDate], [UTypeID], [UserRights], [UploadInventory], [Show_HoldedStock], [LoginMailAlertOn], [Show_CertImage], [App_Id], [App_Pwd], [WeChatId], [Client_Grade], [WatchList_Priority], [ShipmentType], [SecurityPin], [Online_ClientCd], [Online_SellerCd], [IsActive], [IsDeleted]) VALUES (93, N'shubhampatel1780@gmail.com', N'123123123', N'Mr.', N'Shubham', N'Patel', CAST(0x00008E6400000000 AS DateTime), N'Diamond', N'DMD', NULL, NULL, NULL, NULL, NULL, CAST(0.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'Shubgham', N'74,Khodiyar Nagar-2, Navagam, Dindoli Road, Udhana, Surat - 394210', N'Surat', N'Gujarat', N'394210', NULL, NULL, NULL, N'07698340590', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'7698340590', N'shubhampatel1780@gmail.com', NULL, NULL, NULL, N'sbmdimaond.com', N'MANUFACTURER', CAST(0x0000AB94013A0976 AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Yes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
INSERT [dbo].[Clientmaster] ([ClientCd], [LoginName], [Password], [Title], [FirstName], [LastName], [Birthdate], [CompanyNm], [Designation], [Terms], [CreditDays], [Commission], [Brokerage], [PriceDiscount], [Discount], [PriceFormat], [TaxDetails], [ReferenceFrom], [ReferenceThrough], [Address], [City], [State], [Zipcode], [Countrycd], [Phone_Countrycd], [Phone_STDcd], [Phone_No], [Phone_Countrycd2], [Phone_STDCd2], [Phone_No2], [Fax_Countrycd], [Fax_STDCd], [Fax_No], [Mobile_CountryCd], [Mobile_No], [EmailID1], [EmailID2], [EmailID3], [All_Emailid], [Website], [BussinessType], [InsertedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [ApproveStatus], [ApproveStatusOn], [ApproveStatusBy], [StatusUpdatedOn], [StatusUpdatedBy], [Status], [WholeStockAccess], [BankDetails], [RoutingDetails], [Handle_Location], [Smid], [EmailStatus], [LastLoginDate], [SkypeId], [QQId], [EmailSubscr], [EmailSubscrDate], [UTypeID], [UserRights], [UploadInventory], [Show_HoldedStock], [LoginMailAlertOn], [Show_CertImage], [App_Id], [App_Pwd], [WeChatId], [Client_Grade], [WatchList_Priority], [ShipmentType], [SecurityPin], [Online_ClientCd], [Online_SellerCd], [IsActive], [IsDeleted]) VALUES (1123, N'shubhampatel1780@gmail.com', N'963963963', N'Mrs.', N'Sahaj', N'Patel', CAST(0x0000907D00000000 AS DateTime), N'SBM', N'Sbm', NULL, NULL, NULL, NULL, NULL, CAST(0.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'Shubham Patel', N'74,Khodiyar Nagar-2, Navagam, Dindoli Road, Udhana, Surat - 394210', N'Surat', N'Gujarat', N'394210', NULL, NULL, NULL, N'07698340590', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'07698340590', N'shubhampatel1780@gmail.com', NULL, NULL, NULL, N'Shubham.com', N'WHOLESELLER', CAST(0x0000ABEA00FBAEA5 AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Yes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[Clientmaster] ([ClientCd], [LoginName], [Password], [Title], [FirstName], [LastName], [Birthdate], [CompanyNm], [Designation], [Terms], [CreditDays], [Commission], [Brokerage], [PriceDiscount], [Discount], [PriceFormat], [TaxDetails], [ReferenceFrom], [ReferenceThrough], [Address], [City], [State], [Zipcode], [Countrycd], [Phone_Countrycd], [Phone_STDcd], [Phone_No], [Phone_Countrycd2], [Phone_STDCd2], [Phone_No2], [Fax_Countrycd], [Fax_STDCd], [Fax_No], [Mobile_CountryCd], [Mobile_No], [EmailID1], [EmailID2], [EmailID3], [All_Emailid], [Website], [BussinessType], [InsertedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [ApproveStatus], [ApproveStatusOn], [ApproveStatusBy], [StatusUpdatedOn], [StatusUpdatedBy], [Status], [WholeStockAccess], [BankDetails], [RoutingDetails], [Handle_Location], [Smid], [EmailStatus], [LastLoginDate], [SkypeId], [QQId], [EmailSubscr], [EmailSubscrDate], [UTypeID], [UserRights], [UploadInventory], [Show_HoldedStock], [LoginMailAlertOn], [Show_CertImage], [App_Id], [App_Pwd], [WeChatId], [Client_Grade], [WatchList_Priority], [ShipmentType], [SecurityPin], [Online_ClientCd], [Online_SellerCd], [IsActive], [IsDeleted]) VALUES (1124, N'patelshubhamd@gmail.com', N'123456789', N'Mr.', N'Shubham', N'Patel', CAST(0x00008E6400000000 AS DateTime), N'SBM', N'Sbm', NULL, NULL, NULL, NULL, NULL, CAST(0.00 AS Numeric(5, 2)), NULL, NULL, NULL, N'Shubham Patel', N'74,Khodiyar Nagar-2, Navagam, Dindoli Road, Udhana', N'Surat', N'Gujarat', N'394210', NULL, NULL, NULL, N'07698340590', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'07698340590', N'patelshubhamd@gmail.com', NULL, NULL, NULL, N'Shubham.com', N'MANUFACTURER', CAST(0x0000ABF800BB8E71 AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Yes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[Clientmaster] ([ClientCd], [LoginName], [Password], [Title], [FirstName], [LastName], [Birthdate], [CompanyNm], [Designation], [Terms], [CreditDays], [Commission], [Brokerage], [PriceDiscount], [Discount], [PriceFormat], [TaxDetails], [ReferenceFrom], [ReferenceThrough], [Address], [City], [State], [Zipcode], [Countrycd], [Phone_Countrycd], [Phone_STDcd], [Phone_No], [Phone_Countrycd2], [Phone_STDCd2], [Phone_No2], [Fax_Countrycd], [Fax_STDCd], [Fax_No], [Mobile_CountryCd], [Mobile_No], [EmailID1], [EmailID2], [EmailID3], [All_Emailid], [Website], [BussinessType], [InsertedDate], [CreatedBy], [UpdatedDate], [UpdatedBy], [ApproveStatus], [ApproveStatusOn], [ApproveStatusBy], [StatusUpdatedOn], [StatusUpdatedBy], [Status], [WholeStockAccess], [BankDetails], [RoutingDetails], [Handle_Location], [Smid], [EmailStatus], [LastLoginDate], [SkypeId], [QQId], [EmailSubscr], [EmailSubscrDate], [UTypeID], [UserRights], [UploadInventory], [Show_HoldedStock], [LoginMailAlertOn], [Show_CertImage], [App_Id], [App_Pwd], [WeChatId], [Client_Grade], [WatchList_Priority], [ShipmentType], [SecurityPin], [Online_ClientCd], [Online_SellerCd], [IsActive], [IsDeleted]) VALUES (1125, N'chhayadpatel616@gmail.com', N'123456789', N'Miss.', N'Chhaya', N'Patel', CAST(0x0000907D00000000 AS DateTime), N'Dimond', N'Make Be PErfect', NULL, NULL, NULL, NULL, NULL, CAST(0.00 AS Numeric(5, 2)), NULL, NULL, NULL, NULL, N'74,Khodiyar Nagar-2, Navagam, Dindoli Road, Udhana, Surat - 394210', N'Surat', N'Gujarat', N'394210', NULL, NULL, NULL, N'07698340590', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'07698340590', N'chhayadpatel616@gmail.com', NULL, NULL, NULL, N'Shubham.com', N'WHOLESELLER', CAST(0x0000ABF800BD59FC AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Yes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
SET IDENTITY_INSERT [dbo].[Clientmaster] OFF
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233067', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'H', N'VS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, N'Y', NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.28 AS Numeric(5, 2)), CAST(5.25 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.38 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.50 AS Numeric(5, 2)), N'  5.25 -  5.28 x  3.38', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud"', N'No Bgm/Eye Clean', N'GIA', N'6262417903', CAST(3600.00 AS Numeric(10, 2)), CAST(2160.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2484.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(1490.40 AS Numeric(15, 2)), CAST(2232.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(1339.20 AS Numeric(15, 2)), NULL, N'N', N'5', NULL, N'H', N'70070291', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, N'Test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'https://v360.in/DiamondView.aspx?cid=vnr&d=416.28P-32A', N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA224076', N'OVEL', CAST(0.34 AS Decimal(10, 2)), N'D', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.60 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(4.47 AS Numeric(5, 2)), CAST(4.45 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(36.00 AS Numeric(5, 2)), CAST(2.79 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  4.45 -  4.47 x  2.79', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Crystal"', N'No Bgm/Eye Clean', N'IGI', N'1186528532', CAST(2600.00 AS Numeric(10, 2)), CAST(884.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'SURAT', N'-', N'-', N'H', CAST(1794.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(609.96 AS Numeric(15, 2)), CAST(1612.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(548.08 AS Numeric(15, 2)), NULL, N'N', N'3', CAST(4.46 AS Numeric(5, 2)), N'D', N'70067597', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA226015', N'PRINCESS', CAST(0.50 AS Decimal(10, 2)), N'G', N'SI1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'Y', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.10 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.14 AS Numeric(5, 2)), CAST(5.13 AS Numeric(5, 2)), NULL, NULL, CAST(41.40 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.09 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.13 -  5.14 x  3.09', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud"', N'No Bgm/Eye Clean', N'HRD', N'2185538650', CAST(3100.00 AS Numeric(10, 2)), CAST(1550.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2166.28 AS Numeric(15, 2)), CAST(30.12 AS Numeric(15, 2)), CAST(1083.14 AS Numeric(15, 2)), CAST(1949.28 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(974.64 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'G', N'70067831', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'TP: MAIN', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH108056', N'ROUND', CAST(0.62 AS Decimal(10, 2)), N'H', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(5.49 AS Numeric(5, 2)), CAST(5.47 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  5.47 -  5.49 x  3.39', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Crystal', NULL, N'GIA', N'1248471062', CAST(3400.00 AS Numeric(10, 2)), CAST(2108.00 AS Numeric(14, 2)), CAST(0x0000A6F000000000 AS DateTime), N'INDIA', N'-', N'-', N'UP', CAST(2477.92 AS Numeric(15, 2)), CAST(27.12 AS Numeric(15, 2)), CAST(1536.31 AS Numeric(15, 2)), CAST(2239.92 AS Numeric(15, 2)), CAST(34.12 AS Numeric(15, 2)), CAST(1388.75 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.48 AS Numeric(5, 2)), N'H', N'70052301', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA226110', N'OVEL', CAST(0.70 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, N'N', NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.40 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.68 AS Numeric(5, 2)), CAST(5.63 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(62.30 AS Numeric(5, 2)), CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.53 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.63 -  5.68 x  3.53', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1268295994', CAST(5000.00 AS Numeric(10, 2)), CAST(3500.00 AS Numeric(14, 2)), CAST(0x0000A7BA00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2825.00 AS Numeric(15, 2)), CAST(43.50 AS Numeric(15, 2)), CAST(1977.50 AS Numeric(15, 2)), CAST(2475.00 AS Numeric(15, 2)), CAST(50.50 AS Numeric(15, 2)), CAST(1732.50 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.67 AS Numeric(5, 2)), N'F', N'70069409', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233315', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(59.70 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(5.18 AS Numeric(5, 2)), CAST(5.15 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.08 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.15 -  5.18 x  3.08', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud, Pinpoint"', N'No Bgm/Eye Clean', N'GIA', N'6262450948', CAST(4200.00 AS Numeric(10, 2)), CAST(2100.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2682.96 AS Numeric(15, 2)), CAST(36.12 AS Numeric(15, 2)), CAST(1341.48 AS Numeric(15, 2)), CAST(2388.96 AS Numeric(15, 2)), CAST(43.12 AS Numeric(15, 2)), CAST(1194.48 AS Numeric(15, 2)), NULL, N'N', N'3.50', NULL, N'F', N'70070928', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'MA308077', N'OVEL', CAST(0.60 AS Decimal(10, 2)), N'E', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'N', NULL, N'-', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.80 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.33 AS Numeric(5, 2)), CAST(5.29 AS Numeric(5, 2)), NULL, NULL, CAST(40.40 AS Numeric(5, 2)), CAST(38.00 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  5.29 -  5.33 x  3.39', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Cloud, Crystal, Indented Natural, Pinpoint"', NULL, N'IGI', N'7236339962', CAST(4400.00 AS Numeric(10, 2)), CAST(2640.00 AS Numeric(14, 2)), CAST(0x0000A67400000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1633.63 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1448.83 AS Numeric(15, 2)), NULL, N'N', N'4.50', CAST(5.30 AS Numeric(5, 2)), N'E', N'70037340', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198703', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH202116', N'OVEL', CAST(0.40 AS Decimal(10, 2)), N'G', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'Y', NULL, N'VTN - STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.20 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.72 AS Numeric(5, 2)), CAST(4.69 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(2.93 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  4.69 -  4.72 x  2.93', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Crystal, Indented Natural, Needle"', N'No Bgm/Eye Clean', N'HRD', N'6252974594', CAST(2900.00 AS Numeric(10, 2)), CAST(1160.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1899.50 AS Numeric(15, 2)), CAST(34.50 AS Numeric(15, 2)), CAST(759.80 AS Numeric(15, 2)), CAST(1696.50 AS Numeric(15, 2)), CAST(41.50 AS Numeric(15, 2)), CAST(678.60 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'G', N'70066811', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, N'UO', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH131041', N'OVEL', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS2', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.90 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(5.00 AS Numeric(5, 2)), CAST(4.97 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.19 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(14.50 AS Numeric(5, 2)), N'  4.97 -  5.00 x  3.19', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud, Crystal"', N'No Bgm/Eye Clean', N'IGI', N'2247958791', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A74100000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2199.44 AS Numeric(15, 2)), CAST(42.12 AS Numeric(15, 2)), CAST(1099.72 AS Numeric(15, 2)), CAST(1933.44 AS Numeric(15, 2)), CAST(49.12 AS Numeric(15, 2)), CAST(966.72 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(4.99 AS Numeric(5, 2)), N'F', N'70056880', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn1ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA191261', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS1', N'G', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'STK TO VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(66.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(4.90 AS Numeric(5, 2)), CAST(4.87 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(38.50 AS Numeric(5, 2)), CAST(3.23 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  4.87 -  4.90 x  3.23', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'Crystal', N'No Bgm/Eye Clean', N'HRD', N'1186436509', CAST(4200.00 AS Numeric(10, 2)), CAST(2100.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2136.96 AS Numeric(15, 2)), CAST(49.12 AS Numeric(15, 2)), CAST(1068.48 AS Numeric(15, 2)), CAST(1842.96 AS Numeric(15, 2)), CAST(56.12 AS Numeric(15, 2)), CAST(921.48 AS Numeric(15, 2)), NULL, N'N', N'6', CAST(4.88 AS Numeric(5, 2)), N'F', N'70065569', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', N'WHT: L.H.', N'PDV MM MB EF', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173059', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'E', N'SI1', N'EX', N'VG', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.00 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(5.12 AS Numeric(5, 2)), CAST(5.11 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(3.12 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.11 -  5.12 x  3.12', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'Crystal', NULL, N'GIA', N'5256393587', CAST(3400.00 AS Numeric(10, 2)), CAST(1700.00 AS Numeric(14, 2)), CAST(0x0000A77200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2103.92 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1051.96 AS Numeric(15, 2)), CAST(1865.92 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(932.96 AS Numeric(15, 2)), NULL, N'N', N'4', CAST(5.09 AS Numeric(5, 2)), N'E', N'70060956', N'YES', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'PIT: TABLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173643', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VVS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.20 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.09 AS Numeric(5, 2)), CAST(5.07 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.11 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.07 -  5.09 x  3.11', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'2185437124', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2389.44 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(1194.72 AS Numeric(15, 2)), CAST(2123.44 AS Numeric(15, 2)), CAST(44.12 AS Numeric(15, 2)), CAST(1061.72 AS Numeric(15, 2)), NULL, N'N', N'4.50', CAST(5.08 AS Numeric(5, 2)), N'H', N'70065432', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', N'WHT: GIRDLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_18', N'PEAR', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_22', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'MP491348', N'CUSHION', CAST(0.50 AS Decimal(10, 2)), N'L', N'VVS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.20 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.11 AS Numeric(5, 2)), CAST(5.06 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(33.50 AS Numeric(5, 2)), CAST(3.11 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.06 -  5.11 x  3.11', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Needle, Pinpoint"', NULL, N'GIA', N'5246495782', CAST(2000.00 AS Numeric(10, 2)), CAST(1000.00 AS Numeric(14, 2)), CAST(0x0000A6FE00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1180.00 AS Numeric(15, 2)), CAST(41.00 AS Numeric(15, 2)), CAST(590.00 AS Numeric(15, 2)), CAST(1040.00 AS Numeric(15, 2)), CAST(48.00 AS Numeric(15, 2)), CAST(520.00 AS Numeric(15, 2)), NULL, N'N', N'4.50', NULL, N'L', N'70054157', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198078', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA184438', N'EMARALD', CAST(0.51 AS Decimal(10, 2)), N'D', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.50 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.10 AS Numeric(5, 2)), CAST(5.08 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.18 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.08 -  5.10 x  3.18', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud"', NULL, N'GIA', N'1255680910', CAST(4400.00 AS Numeric(10, 2)), CAST(2244.00 AS Numeric(14, 2)), CAST(0x0000A77600000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1388.59 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1231.51 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.08 AS Numeric(5, 2)), N'D', N'70064325', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197764', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn 1 Ti 2', N'SCR: TABLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA135268', N'MARQUISE', CAST(0.50 AS Decimal(10, 2)), N'H', N'VVS1', N'VG', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.00 AS Numeric(5, 2)), CAST(4.98 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.20 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  4.98 -  5.00 x  3.20', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Pinpoint, Feather, Indented Natural, Surface Graining"', N'No Bgm/Eye Clean', N'GIA', N'2244904505', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A72900000000 AS DateTime), N'INDIA', N'-', N'-', N'H', CAST(2318.00 AS Numeric(15, 2)), CAST(39.00 AS Numeric(15, 2)), CAST(1159.00 AS Numeric(15, 2)), CAST(2052.00 AS Numeric(15, 2)), CAST(46.00 AS Numeric(15, 2)), CAST(1026.00 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(5.00 AS Numeric(5, 2)), N'H', N'70056026', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA125113', N'ROUND', CAST(0.31 AS Decimal(10, 2)), N'J', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(4.32 AS Numeric(5, 2)), CAST(4.30 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(2.67 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  4.30 -  4.32 x  2.67', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Feather, Needle"', NULL, N'GIA', N'6245720896', CAST(1600.00 AS Numeric(10, 2)), CAST(496.00 AS Numeric(14, 2)), CAST(0x0000A71500000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1216.00 AS Numeric(15, 2)), CAST(24.00 AS Numeric(15, 2)), CAST(376.96 AS Numeric(15, 2)), CAST(1104.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(342.24 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(4.31 AS Numeric(5, 2)), N'J', N'70055206', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173422', N'HEART', CAST(0.30 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.10 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(4.32 AS Numeric(5, 2)), CAST(4.30 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(41.80 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(2.63 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  4.30 -  4.32 x  2.63', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Needle, Feather"', N'No Bgm / Eye Clean', N'GIA', N'1255548672', CAST(2300.00 AS Numeric(10, 2)), CAST(690.00 AS Numeric(14, 2)), CAST(0x0000A76E00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1598.50 AS Numeric(15, 2)), CAST(30.50 AS Numeric(15, 2)), CAST(479.55 AS Numeric(15, 2)), CAST(1437.50 AS Numeric(15, 2)), CAST(37.50 AS Numeric(15, 2)), CAST(431.25 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'F', N'70062985', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'MS272326', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'D', N'VVS2', N'VG', N'EX', N'EX', N'FAINT', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.30 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(5.31 AS Numeric(5, 2)), CAST(5.27 AS Numeric(5, 2)), NULL, NULL, CAST(40.20 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.35 AS Numeric(5, 2)), CAST(42.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.27 -  5.31 x  3.35', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Pinpoint', NULL, N'GIA', N'2237432015', CAST(5200.00 AS Numeric(10, 2)), CAST(3120.00 AS Numeric(14, 2)), CAST(0x0000A67600000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(3113.76 AS Numeric(15, 2)), CAST(40.12 AS Numeric(15, 2)), CAST(1868.26 AS Numeric(15, 2)), CAST(2749.76 AS Numeric(15, 2)), CAST(47.12 AS Numeric(15, 2)), CAST(1649.86 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(5.29 AS Numeric(5, 2)), N'D', N'70039066', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198616', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH181133', N'RADIANT', CAST(0.60 AS Decimal(10, 2)), N'G', N'VVS1', N'EX', N'EX', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.30 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.39 AS Numeric(5, 2)), CAST(5.37 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.35 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  5.37 -  5.39 x  3.35', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Pinpoint, Extra Facet"', N'No Bgm / Eye Clean', N'GIA', N'7256488997', CAST(4200.00 AS Numeric(10, 2)), CAST(2520.00 AS Numeric(14, 2)), CAST(0x0000A76300000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2961.00 AS Numeric(15, 2)), CAST(29.50 AS Numeric(15, 2)), CAST(1776.60 AS Numeric(15, 2)), CAST(2667.00 AS Numeric(15, 2)), CAST(36.50 AS Numeric(15, 2)), CAST(1600.20 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.38 AS Numeric(5, 2)), N'G', N'70062344', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', N'TP: MAIN', N'SM EF', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233320', N'OTHER', CAST(0.50 AS Decimal(10, 2)), N'H', N'VS2', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.40 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.96 AS Numeric(5, 2)), CAST(4.92 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.18 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  4.92 -  4.96 x  3.18', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Crystal"', N'No Bgm/Eye Clean', N'GIA', N'7266450851', CAST(3400.00 AS Numeric(10, 2)), CAST(1700.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2261.00 AS Numeric(15, 2)), CAST(33.50 AS Numeric(15, 2)), CAST(1130.50 AS Numeric(15, 2)), CAST(2023.00 AS Numeric(15, 2)), CAST(40.50 AS Numeric(15, 2)), CAST(1011.50 AS Numeric(15, 2)), NULL, N'N', N'5.50', NULL, N'H', N'70070933', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA139388', N'ROUND', CAST(0.51 AS Decimal(10, 2)), N'E', N'VS1', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, NULL, NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.80 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.12 AS Numeric(5, 2)), CAST(5.10 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.21 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.10 -  5.12 x  3.21', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Pinpoint, Needle"', N'No Bgm/Eye Clean', N'GIA', N'2257108069', CAST(4400.00 AS Numeric(10, 2)), CAST(2244.00 AS Numeric(14, 2)), CAST(0x0000A73E00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2398.00 AS Numeric(15, 2)), CAST(45.50 AS Numeric(15, 2)), CAST(1222.98 AS Numeric(15, 2)), CAST(2090.00 AS Numeric(15, 2)), CAST(52.50 AS Numeric(15, 2)), CAST(1065.90 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.09 AS Numeric(5, 2)), N'E', N'70058087', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn1ti1', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH238062', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VS1', N'FR', N'EX', N'G', N'NONE', NULL, NULL, NULL, NULL, N'THK-VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(70.30 AS Numeric(5, 2)), CAST(53.00 AS Numeric(5, 2)), CAST(4.79 AS Numeric(5, 2)), CAST(4.78 AS Numeric(5, 2)), NULL, NULL, CAST(42.20 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.36 AS Numeric(5, 2)), CAST(45.00 AS Numeric(5, 2)), CAST(18.00 AS Numeric(5, 2)), N'  4.78 -  4.79 x  3.36', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Pinpoint"', NULL, N'GIA', N'7261425394', CAST(3600.00 AS Numeric(10, 2)), CAST(1800.00 AS Numeric(14, 2)), CAST(0x0000A7BC00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1890.00 AS Numeric(15, 2)), CAST(47.50 AS Numeric(15, 2)), CAST(945.00 AS Numeric(15, 2)), CAST(1638.00 AS Numeric(15, 2)), CAST(54.50 AS Numeric(15, 2)), CAST(819.00 AS Numeric(15, 2)), NULL, N'N', N'7', NULL, N'H', N'70070855', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'T/OC T/OCT', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA254001', N'ROUND', CAST(0.30 AS Decimal(10, 2)), N'D', N'SI2', N'G', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'THN-VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.60 AS Numeric(5, 2)), CAST(52.00 AS Numeric(5, 2)), CAST(4.18 AS Numeric(5, 2)), CAST(4.17 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(2.70 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  4.17 -  4.18 x  2.70', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Feather', N'No Bgm/Eye Clean', N'GIA', N'6262227899', CAST(2000.00 AS Numeric(10, 2)), CAST(600.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'H', CAST(1240.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(372.00 AS Numeric(15, 2)), CAST(1100.00 AS Numeric(15, 2)), CAST(45.00 AS Numeric(15, 2)), CAST(330.00 AS Numeric(15, 2)), NULL, N'N', N'6', CAST(4.17 AS Numeric(5, 2)), N'D', N'70068239', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2crown Hair Line Open Girdle Natural', N'WHT: L.H. TP: L.H.', N'T/OCT PDV CV PV ALN', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'DF38453', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'DF37928', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_32', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_36', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL)
INSERT [dbo].[GRADDET] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA152378', N'ROUND', CAST(0.33 AS Decimal(10, 2)), N'D', N'VVS1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.30 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(4.52 AS Numeric(5, 2)), CAST(4.50 AS Numeric(5, 2)), NULL, NULL, CAST(41.80 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(2.72 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  4.50 -  4.52 x  2.72', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Pinpoint, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1253220599', CAST(3100.00 AS Numeric(10, 2)), CAST(1023.00 AS Numeric(14, 2)), CAST(0x0000A74C00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2569.28 AS Numeric(15, 2)), CAST(17.12 AS Numeric(15, 2)), CAST(847.86 AS Numeric(15, 2)), CAST(2352.28 AS Numeric(15, 2)), CAST(24.12 AS Numeric(15, 2)), CAST(776.25 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(4.50 AS Numeric(5, 2)), N'D', N'70059525', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL)
SET IDENTITY_INSERT [dbo].[Procmas] ON 

INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (4, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Round', N'rn', CAST(1 AS Numeric(10, 0)), N'', 1, N'          ', N'          ', N'          ', N'          ', N'          ', 0, NULL, NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (5, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Ovel', N'sp', CAST(1 AS Numeric(10, 0)), N'', 1, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB8200F9D361 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (6, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Princess', N'0', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB8200FBE95E AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (7, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Pear', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB8200FD8770 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (8, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Cushion', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB820102C912 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (9, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Emarald', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB820111D9D7 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (10, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Marquise', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB820111D9D7 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (11, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Heart', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB820111D9D7 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (12, N'SHAPE', CAST(0 AS Numeric(10, 0)), N'Radiant', N'', CAST(1 AS Numeric(10, 0)), N'', 0, N'          ', N'          ', N'          ', N'          ', N'          ', 0, CAST(0x0000AB820111D9D7 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (16, N'CERTIFICATE', CAST(1 AS Numeric(10, 0)), N'GIA', N'0', CAST(2 AS Numeric(10, 0)), NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7011CA33D AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (19, N'CERTIFICATE', CAST(1 AS Numeric(10, 0)), N'IGI', N'1', CAST(3 AS Numeric(10, 0)), NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7011CA33D AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (20, N'CERTIFICATE', CAST(1 AS Numeric(10, 0)), N'HRD', N'1', CAST(2 AS Numeric(10, 0)), NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7011CA33D AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (21, N'CARAT', CAST(2 AS Numeric(10, 0)), N'0', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701276DA6 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (22, N'CARAT', CAST(2 AS Numeric(10, 0)), N'4.39', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701276DA6 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (23, N'CARAT', CAST(2 AS Numeric(10, 0)), N'8.78', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701276DA6 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (24, N'CARAT', CAST(2 AS Numeric(10, 0)), N'13.16', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701276DA6 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (25, N'CARAT', CAST(2 AS Numeric(10, 0)), N'17.55', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701276DA6 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (26, N'CUT', CAST(3 AS Numeric(10, 0)), N'EX', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (27, N'CUT', CAST(3 AS Numeric(10, 0)), N'VG', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (28, N'CUT', CAST(3 AS Numeric(10, 0)), N'G', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (29, N'CUT', CAST(3 AS Numeric(10, 0)), N'FR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (30, N'CUT', CAST(3 AS Numeric(10, 0)), N'POOR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (31, N'COLOR', CAST(4 AS Numeric(10, 0)), N'D', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (32, N'COLOR', CAST(4 AS Numeric(10, 0)), N'F', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (33, N'COLOR', CAST(4 AS Numeric(10, 0)), N'E', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (34, N'COLOR', CAST(4 AS Numeric(10, 0)), N'H', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (35, N'COLOR', CAST(4 AS Numeric(10, 0)), N'J', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (36, N'COLOR', CAST(4 AS Numeric(10, 0)), N'K', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (37, N'COLOR', CAST(4 AS Numeric(10, 0)), N'L', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (38, N'COLOR', CAST(4 AS Numeric(10, 0)), N'M', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (39, N'COLOR', CAST(4 AS Numeric(10, 0)), N'N', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012AC0E0 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (40, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'FL', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (41, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'F', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (42, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'VVS1', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (43, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'VVS2', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (44, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'VS1', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (45, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'VS2', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (46, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'SI1', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (47, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'SI2', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (48, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'I1', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (49, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'I2', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (50, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'None', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (51, N'CLARITY', CAST(5 AS Numeric(10, 0)), N'Other', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012B8987 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (52, N'POLISH', CAST(6 AS Numeric(10, 0)), N'EX', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012C8D68 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (53, N'POLISH', CAST(6 AS Numeric(10, 0)), N'VG', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (54, N'POLISH', CAST(6 AS Numeric(10, 0)), N'G', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (55, N'POLISH', CAST(6 AS Numeric(10, 0)), N'FR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (56, N'POLISH', CAST(6 AS Numeric(10, 0)), N'POOR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (57, N'SYMMETRY', CAST(7 AS Numeric(10, 0)), N'EX', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012C8D68 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (58, N'SYMMETRY', CAST(7 AS Numeric(10, 0)), N'VG', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (59, N'SYMMETRY', CAST(7 AS Numeric(10, 0)), N'G', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (60, N'SYMMETRY', CAST(7 AS Numeric(10, 0)), N'FR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (61, N'SYMMETRY', CAST(7 AS Numeric(10, 0)), N'POOR', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA7012A0555 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (73, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'None', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (74, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Faint', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (75, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Medium', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (76, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Strong', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (77, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Very Strong', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (78, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Slight', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (79, N'FL_INTENSITY', CAST(8 AS Numeric(10, 0)), N'Very Slight', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (80, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Black', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (81, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'White', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (82, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Pink', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (83, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Red', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (84, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Yellow', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (85, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Blue', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (86, N'Fl_COLOR', CAST(9 AS Numeric(10, 0)), N'Green', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (87, N'PRICE', CAST(0 AS Numeric(10, 0)), N'0', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (88, N'PRICE', CAST(0 AS Numeric(10, 0)), N'250', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (89, N'PRICE', CAST(0 AS Numeric(10, 0)), N'500', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (90, N'PRICE', CAST(0 AS Numeric(10, 0)), N'750', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (91, N'PRICE', CAST(0 AS Numeric(10, 0)), N'1000', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701304385 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (92, N'SPECIAL', CAST(10 AS Numeric(10, 0)), N'3EX+', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701356684 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (93, N'SPECIAL', CAST(10 AS Numeric(10, 0)), N'3VG+', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701356684 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (94, N'SPECIAL', CAST(10 AS Numeric(10, 0)), N'3VG', N'rn', CAST(0 AS Numeric(10, 0)), NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701356684 AS DateTime), NULL, 0)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (95, N'SPECIAL', CAST(10 AS Numeric(10, 0)), N'NOBGM', N'rn', CAST(0 AS Numeric(10, 0)), NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701356684 AS DateTime), NULL, 0)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (96, N'H&A', CAST(11 AS Numeric(10, 0)), N'Y', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135AA48 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (97, N'H&A', CAST(11 AS Numeric(10, 0)), N'N', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135B45D AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (98, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'India', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135CAB2 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (99, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'Surat', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135CAB2 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (100, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'Mumbai', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135CAB2 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (101, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'Delhi', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135CAB2 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (102, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'Honcong', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA70135CAB2 AS DateTime), NULL, 1)
INSERT [dbo].[Procmas] ([Id], [Procgroup], [Proccd], [Procnm], [Shortnm], [Ord], [Fancy_Color_Status], [IsChangeable], [Fancy_Color], [Fancy_Intensity], [Fancy_Overtone], [F_CTS], [T_CTS], [IsDeleted], [InsertedDate], [UpdatedDate], [IsActive]) VALUES (103, N'LOCATION', CAST(12 AS Numeric(10, 0)), N'Bangkok', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 0, CAST(0x0000ABA701362419 AS DateTime), NULL, 1)
SET IDENTITY_INSERT [dbo].[Procmas] OFF
SET IDENTITY_INSERT [dbo].[ShoppingCart] ON 

INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (1, N'A0123456', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (2, N'PH233067', 93, N'I', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'O', N'N', NULL, NULL, N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'H', N'VS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, N'Y', NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.28 AS Numeric(5, 2)), CAST(5.25 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.38 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.50 AS Numeric(5, 2)), N'  5.25 -  5.28 x  3.38', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud"', N'No Bgm/Eye Clean', N'GIA', N'6262417903', CAST(3600.00 AS Numeric(10, 2)), CAST(2160.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2484.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(1490.40 AS Numeric(15, 2)), CAST(2232.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(1339.20 AS Numeric(15, 2)), N'5', NULL, N'H', N'70070291', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, N'Test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'https://v360.in/DiamondView.aspx?cid=vnr&d=416.28P-32A', N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (3, N'PA224076', 93, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'OVEL', CAST(0.34 AS Decimal(10, 2)), N'D', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.60 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(4.47 AS Numeric(5, 2)), CAST(4.45 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(36.00 AS Numeric(5, 2)), CAST(2.79 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  4.45 -  4.47 x  2.79', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Crystal"', N'No Bgm/Eye Clean', N'IGI', N'1186528532', CAST(2600.00 AS Numeric(10, 2)), CAST(884.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'SURAT', N'-', N'-', N'H', CAST(1794.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(609.96 AS Numeric(15, 2)), CAST(1612.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(548.08 AS Numeric(15, 2)), N'3', CAST(4.46 AS Numeric(5, 2)), N'D', N'70067597', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (4, N'PA226015', 93, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'PRINCESS', CAST(0.50 AS Decimal(10, 2)), N'G', N'SI1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'Y', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.10 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.14 AS Numeric(5, 2)), CAST(5.13 AS Numeric(5, 2)), NULL, NULL, CAST(41.40 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.09 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.13 -  5.14 x  3.09', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud"', N'No Bgm/Eye Clean', N'HRD', N'2185538650', CAST(3100.00 AS Numeric(10, 2)), CAST(1550.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2166.28 AS Numeric(15, 2)), CAST(30.12 AS Numeric(15, 2)), CAST(1083.14 AS Numeric(15, 2)), CAST(1949.28 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(974.64 AS Numeric(15, 2)), N'4', NULL, N'G', N'70067831', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'TP: MAIN', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (5, N'PH108056', 93, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'ROUND', CAST(0.62 AS Decimal(10, 2)), N'H', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(5.49 AS Numeric(5, 2)), CAST(5.47 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  5.47 -  5.49 x  3.39', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Crystal', NULL, N'GIA', N'1248471062', CAST(3400.00 AS Numeric(10, 2)), CAST(2108.00 AS Numeric(14, 2)), CAST(0x0000A6F000000000 AS DateTime), N'INDIA', N'-', N'-', N'UP', CAST(2477.92 AS Numeric(15, 2)), CAST(27.12 AS Numeric(15, 2)), CAST(1536.31 AS Numeric(15, 2)), CAST(2239.92 AS Numeric(15, 2)), CAST(34.12 AS Numeric(15, 2)), CAST(1388.75 AS Numeric(15, 2)), N'3.50', CAST(5.48 AS Numeric(5, 2)), N'H', N'70052301', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (6, N'PH233315', 93, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, N'N', NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(59.70 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(5.18 AS Numeric(5, 2)), CAST(5.15 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.08 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.15 -  5.18 x  3.08', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud, Pinpoint"', N'No Bgm/Eye Clean', N'GIA', N'6262450948', CAST(4200.00 AS Numeric(10, 2)), CAST(2100.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2682.96 AS Numeric(15, 2)), CAST(36.12 AS Numeric(15, 2)), CAST(1341.48 AS Numeric(15, 2)), CAST(2388.96 AS Numeric(15, 2)), CAST(43.12 AS Numeric(15, 2)), CAST(1194.48 AS Numeric(15, 2)), N'3.50', NULL, N'F', N'70070928', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (7, N'PH233067', 93, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'H', N'VS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, N'Y', NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.28 AS Numeric(5, 2)), CAST(5.25 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.38 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.50 AS Numeric(5, 2)), N'  5.25 -  5.28 x  3.38', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud"', N'No Bgm/Eye Clean', N'GIA', N'6262417903', CAST(3600.00 AS Numeric(10, 2)), CAST(2160.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2484.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(1490.40 AS Numeric(15, 2)), CAST(2232.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(1339.20 AS Numeric(15, 2)), N'5', NULL, N'H', N'70070291', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, N'Test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'https://v360.in/DiamondView.aspx?cid=vnr&d=416.28P-32A', N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (8, N'PA226110', 1124, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'O', N'N', NULL, NULL, N'OVEL', CAST(0.70 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, N'N', NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.40 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.68 AS Numeric(5, 2)), CAST(5.63 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(62.30 AS Numeric(5, 2)), CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.53 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.63 -  5.68 x  3.53', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1268295994', CAST(5000.00 AS Numeric(10, 2)), CAST(3500.00 AS Numeric(14, 2)), CAST(0x0000A7BA00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2825.00 AS Numeric(15, 2)), CAST(43.50 AS Numeric(15, 2)), CAST(1977.50 AS Numeric(15, 2)), CAST(2475.00 AS Numeric(15, 2)), CAST(50.50 AS Numeric(15, 2)), CAST(1732.50 AS Numeric(15, 2)), N'3.50', CAST(5.67 AS Numeric(5, 2)), N'F', N'70069409', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (9, N'MA308077', 1124, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'O', N'N', NULL, NULL, N'OVEL', CAST(0.60 AS Decimal(10, 2)), N'E', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'N', NULL, N'-', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.80 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.33 AS Numeric(5, 2)), CAST(5.29 AS Numeric(5, 2)), NULL, NULL, CAST(40.40 AS Numeric(5, 2)), CAST(38.00 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  5.29 -  5.33 x  3.39', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Cloud, Crystal, Indented Natural, Pinpoint"', NULL, N'IGI', N'7236339962', CAST(4400.00 AS Numeric(10, 2)), CAST(2640.00 AS Numeric(14, 2)), CAST(0x0000A67400000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1633.63 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1448.83 AS Numeric(15, 2)), N'4.50', CAST(5.30 AS Numeric(5, 2)), N'E', N'70037340', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198703', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (10, N'PH202116', 1124, N'I', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'O', N'N', NULL, NULL, N'OVEL', CAST(0.40 AS Decimal(10, 2)), N'G', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'Y', NULL, N'VTN - STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.20 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.72 AS Numeric(5, 2)), CAST(4.69 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(2.93 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  4.69 -  4.72 x  2.93', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Crystal, Indented Natural, Needle"', N'No Bgm/Eye Clean', N'HRD', N'6252974594', CAST(2900.00 AS Numeric(10, 2)), CAST(1160.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1899.50 AS Numeric(15, 2)), CAST(34.50 AS Numeric(15, 2)), CAST(759.80 AS Numeric(15, 2)), CAST(1696.50 AS Numeric(15, 2)), CAST(41.50 AS Numeric(15, 2)), CAST(678.60 AS Numeric(15, 2)), N'4', NULL, N'G', N'70066811', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, N'UO', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (11, N'PA226110', 93, N'I', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'OVEL', CAST(0.70 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, N'N', NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.40 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.68 AS Numeric(5, 2)), CAST(5.63 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(62.30 AS Numeric(5, 2)), CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.53 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.63 -  5.68 x  3.53', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1268295994', CAST(5000.00 AS Numeric(10, 2)), CAST(3500.00 AS Numeric(14, 2)), CAST(0x0000A7BA00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2825.00 AS Numeric(15, 2)), CAST(43.50 AS Numeric(15, 2)), CAST(1977.50 AS Numeric(15, 2)), CAST(2475.00 AS Numeric(15, 2)), CAST(50.50 AS Numeric(15, 2)), CAST(1732.50 AS Numeric(15, 2)), N'3.50', CAST(5.67 AS Numeric(5, 2)), N'F', N'70069409', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (12, N'MA308077', 93, N'I', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'OVEL', CAST(0.60 AS Decimal(10, 2)), N'E', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'N', NULL, N'-', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.80 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.33 AS Numeric(5, 2)), CAST(5.29 AS Numeric(5, 2)), NULL, NULL, CAST(40.40 AS Numeric(5, 2)), CAST(38.00 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  5.29 -  5.33 x  3.39', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Cloud, Crystal, Indented Natural, Pinpoint"', NULL, N'IGI', N'7236339962', CAST(4400.00 AS Numeric(10, 2)), CAST(2640.00 AS Numeric(14, 2)), CAST(0x0000A67400000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1633.63 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1448.83 AS Numeric(15, 2)), N'4.50', CAST(5.30 AS Numeric(5, 2)), N'E', N'70037340', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198703', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (13, N'PH202116', 93, N'I', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'OVEL', CAST(0.40 AS Decimal(10, 2)), N'G', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, N'Y', NULL, N'VTN - STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.20 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.72 AS Numeric(5, 2)), CAST(4.69 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(2.93 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  4.69 -  4.72 x  2.93', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Crystal, Indented Natural, Needle"', N'No Bgm/Eye Clean', N'HRD', N'6252974594', CAST(2900.00 AS Numeric(10, 2)), CAST(1160.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1899.50 AS Numeric(15, 2)), CAST(34.50 AS Numeric(15, 2)), CAST(759.80 AS Numeric(15, 2)), CAST(1696.50 AS Numeric(15, 2)), CAST(41.50 AS Numeric(15, 2)), CAST(678.60 AS Numeric(15, 2)), N'4', NULL, N'G', N'70066811', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, N'UO', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
INSERT [dbo].[ShoppingCart] ([SC_Id], [SC_stoneid], [SC_Clientcd], [SC_Status], [SC_Date], [SC_MemoDate], [SC_delete_date], [sc_offerrate], [sc_offerdisc], [sc_rej_status], [SC_PROCESSEES], [SC_CUR_STATUS], [isMailed], [sc_mail_date], [orderno], [SC_SHAPE], [SC_CTS], [SC_COLOR], [SC_CLARITY], [SC_CUT], [SC_POLISH], [SC_SYM], [SC_FLOURENCE], [SC_FL_COLOR], [SC_INCLUSION], [SC_HA], [SC_LUSTER], [SC_GIRDLE], [SC_GIRDLE_CONDITION], [SC_CULET], [SC_MILKY], [SC_SHADE], [SC_NATTS], [SC_NATURAL], [SC_DEPTH], [SC_DIATABLE], [SC_LENGTH], [SC_WIDTH], [SC_PAVILION], [SC_CROWN], [SC_PAVANGLE], [SC_CROWNANGLE], [SC_HEIGHT], [SC_PAVHEIGHT], [SC_CROWNHEIGHT], [SC_MEASUREMENT], [SC_RATIO], [SC_PAIR], [SC_STAR_LENGTH], [SC_LOWER_HALF], [SC_KEY_TO_SYMBOL], [SC_REPORT_COMMENT], [SC_CERTIFICATE], [SC_CERTNO], [SC_RAPARATE], [SC_RAPAAMT], [SC_CURDATE], [SC_LOCATION], [SC_LEGEND1], [SC_LEGEND2], [SC_LEGEND3], [SC_ASKRATE_FC], [SC_ASKDISC_FC], [SC_ASKAMT_FC], [SC_COSTRATE_FC], [SC_COSTDISC_FC], [SC_COSTAMT_FC], [SC_GIRDLEPER], [SC_DIA], [SC_COLORDESC], [SC_BARCODE], [SC_INSCRIPTION], [SC_NEW_CERT], [SC_MEMBER_COMMENT], [SC_UPLOADCLIENTID], [SC_REPORT_DATE], [SC_NEW_ARRI_DATE], [SC_TINGE], [SC_EYE_CLN], [SC_TABLE_INCL], [SC_SIDE_INCL], [SC_TABLE_BLACK], [SC_SIDE_BLACK], [SC_TABLE_OPEN], [SC_SIDE_OPEN], [SC_PAV_OPEN], [SC_EXTRA_FACET], [SC_INTERNAL_COMMENT], [SC_POLISH_FEATURES], [SC_SYMMETRY_FEATURES], [SC_GRAINING], [SC_IMG_URL], [SC_RATEDISC], [SC_GRADE], [SC_CLIENT_LOCATION], [SC_ORIGIN], [BUY_REQID], [ERP_PROFORMA_ID], [ERP_INVOICE_ID], [ERP_INVOICE_DATE]) VALUES (14, N'PA173643', 1125, N'B', NULL, NULL, NULL, NULL, NULL, N'N', NULL, N'I', N'N', NULL, NULL, N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VVS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.20 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.09 AS Numeric(5, 2)), CAST(5.07 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.11 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.07 -  5.09 x  3.11', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'2185437124', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2389.44 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(1194.72 AS Numeric(15, 2)), CAST(2123.44 AS Numeric(15, 2)), CAST(44.12 AS Numeric(15, 2)), CAST(1061.72 AS Numeric(15, 2)), N'4.50', CAST(5.08 AS Numeric(5, 2)), N'H', N'70065432', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', N'WHT: GIRDLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[ShoppingCart] OFF
SET IDENTITY_INSERT [dbo].[Temp] ON 

INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233067', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'H', N'VS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.28 AS Numeric(5, 2)), CAST(5.25 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.38 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.50 AS Numeric(5, 2)), N'  5.25 -  5.28 x  3.38', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud"', N'No Bgm/Eye Clean', N'GIA', N'6262417903', CAST(3600.00 AS Numeric(10, 2)), CAST(2160.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2484.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(1490.40 AS Numeric(15, 2)), CAST(2232.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(1339.20 AS Numeric(15, 2)), NULL, N'N', N'5', NULL, N'H', N'70070291', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, N'Test', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'https://v360.in/DiamondView.aspx?cid=vnr&d=416.28P-32A', N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 1)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA224076', N'ROUND', CAST(0.34 AS Decimal(10, 2)), N'D', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.60 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(4.47 AS Numeric(5, 2)), CAST(4.45 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(36.00 AS Numeric(5, 2)), CAST(2.79 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  4.45 -  4.47 x  2.79', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Crystal"', N'No Bgm/Eye Clean', N'GIA', N'1186528532', CAST(2600.00 AS Numeric(10, 2)), CAST(884.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'H', CAST(1794.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(609.96 AS Numeric(15, 2)), CAST(1612.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(548.08 AS Numeric(15, 2)), NULL, N'N', N'3', CAST(4.46 AS Numeric(5, 2)), N'D', N'70067597', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 2)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA226015', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'G', N'SI1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.10 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.14 AS Numeric(5, 2)), CAST(5.13 AS Numeric(5, 2)), NULL, NULL, CAST(41.40 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.09 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.13 -  5.14 x  3.09', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud"', N'No Bgm/Eye Clean', N'GIA', N'2185538650', CAST(3100.00 AS Numeric(10, 2)), CAST(1550.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2166.28 AS Numeric(15, 2)), CAST(30.12 AS Numeric(15, 2)), CAST(1083.14 AS Numeric(15, 2)), CAST(1949.28 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(974.64 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'G', N'70067831', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'TP: MAIN', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 3)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH108056', N'ROUND', CAST(0.62 AS Decimal(10, 2)), N'H', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(5.49 AS Numeric(5, 2)), CAST(5.47 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  5.47 -  5.49 x  3.39', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Crystal', NULL, N'GIA', N'1248471062', CAST(3400.00 AS Numeric(10, 2)), CAST(2108.00 AS Numeric(14, 2)), CAST(0x0000A6F000000000 AS DateTime), N'INDIA', N'-', N'-', N'UP', CAST(2477.92 AS Numeric(15, 2)), CAST(27.12 AS Numeric(15, 2)), CAST(1536.31 AS Numeric(15, 2)), CAST(2239.92 AS Numeric(15, 2)), CAST(34.12 AS Numeric(15, 2)), CAST(1388.75 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.48 AS Numeric(5, 2)), N'H', N'70052301', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 4)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA226110', N'ROUND', CAST(0.70 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, NULL, NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.40 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.68 AS Numeric(5, 2)), CAST(5.63 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(62.30 AS Numeric(5, 2)), CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.53 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.63 -  5.68 x  3.53', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1268295994', CAST(5000.00 AS Numeric(10, 2)), CAST(3500.00 AS Numeric(14, 2)), CAST(0x0000A7BA00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2825.00 AS Numeric(15, 2)), CAST(43.50 AS Numeric(15, 2)), CAST(1977.50 AS Numeric(15, 2)), CAST(2475.00 AS Numeric(15, 2)), CAST(50.50 AS Numeric(15, 2)), CAST(1732.50 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.67 AS Numeric(5, 2)), N'F', N'70069409', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 5)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233315', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(59.70 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(5.18 AS Numeric(5, 2)), CAST(5.15 AS Numeric(5, 2)), NULL, NULL, CAST(41.20 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.08 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.15 -  5.18 x  3.08', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud, Pinpoint"', N'No Bgm/Eye Clean', N'GIA', N'6262450948', CAST(4200.00 AS Numeric(10, 2)), CAST(2100.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2682.96 AS Numeric(15, 2)), CAST(36.12 AS Numeric(15, 2)), CAST(1341.48 AS Numeric(15, 2)), CAST(2388.96 AS Numeric(15, 2)), CAST(43.12 AS Numeric(15, 2)), CAST(1194.48 AS Numeric(15, 2)), NULL, N'N', N'3.50', NULL, N'F', N'70070928', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 6)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'MA308077', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'E', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'-', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.80 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.33 AS Numeric(5, 2)), CAST(5.29 AS Numeric(5, 2)), NULL, NULL, CAST(40.40 AS Numeric(5, 2)), CAST(38.00 AS Numeric(5, 2)), CAST(3.39 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  5.29 -  5.33 x  3.39', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Cloud, Crystal, Indented Natural, Pinpoint"', NULL, N'GIA', N'7236339962', CAST(4400.00 AS Numeric(10, 2)), CAST(2640.00 AS Numeric(14, 2)), CAST(0x0000A67400000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1633.63 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1448.83 AS Numeric(15, 2)), NULL, N'N', N'4.50', CAST(5.30 AS Numeric(5, 2)), N'E', N'70037340', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198703', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 7)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH202116', N'ROUND', CAST(0.40 AS Decimal(10, 2)), N'G', N'VS1', N'VG', N'EX', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'VTN - STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.20 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.72 AS Numeric(5, 2)), CAST(4.69 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(2.93 AS Numeric(5, 2)), CAST(43.50 AS Numeric(5, 2)), CAST(15.00 AS Numeric(5, 2)), N'  4.69 -  4.72 x  2.93', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Crystal, Indented Natural, Needle"', N'No Bgm/Eye Clean', N'GIA', N'6252974594', CAST(2900.00 AS Numeric(10, 2)), CAST(1160.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1899.50 AS Numeric(15, 2)), CAST(34.50 AS Numeric(15, 2)), CAST(759.80 AS Numeric(15, 2)), CAST(1696.50 AS Numeric(15, 2)), CAST(41.50 AS Numeric(15, 2)), CAST(678.60 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'G', N'70066811', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', NULL, N'UO', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 8)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH131041', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS2', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.90 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(5.00 AS Numeric(5, 2)), CAST(4.97 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.19 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(14.50 AS Numeric(5, 2)), N'  4.97 -  5.00 x  3.19', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Feather, Cloud, Crystal"', N'No Bgm/Eye Clean', N'GIA', N'2247958791', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A74100000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2199.44 AS Numeric(15, 2)), CAST(42.12 AS Numeric(15, 2)), CAST(1099.72 AS Numeric(15, 2)), CAST(1933.44 AS Numeric(15, 2)), CAST(49.12 AS Numeric(15, 2)), CAST(966.72 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(4.99 AS Numeric(5, 2)), N'F', N'70056880', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn1ti2', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 9)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA191261', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'F', N'VS1', N'G', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'STK TO VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(66.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(4.90 AS Numeric(5, 2)), CAST(4.87 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(38.50 AS Numeric(5, 2)), CAST(3.23 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  4.87 -  4.90 x  3.23', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'Crystal', N'No Bgm/Eye Clean', N'GIA', N'1186436509', CAST(4200.00 AS Numeric(10, 2)), CAST(2100.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2136.96 AS Numeric(15, 2)), CAST(49.12 AS Numeric(15, 2)), CAST(1068.48 AS Numeric(15, 2)), CAST(1842.96 AS Numeric(15, 2)), CAST(56.12 AS Numeric(15, 2)), CAST(921.48 AS Numeric(15, 2)), NULL, N'N', N'6', CAST(4.88 AS Numeric(5, 2)), N'F', N'70065569', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti1', N'WHT: L.H.', N'PDV MM MB EF', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 10)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173059', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'E', N'SI1', N'EX', N'VG', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.00 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(5.12 AS Numeric(5, 2)), CAST(5.11 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(3.12 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.11 -  5.12 x  3.12', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'Crystal', NULL, N'GIA', N'5256393587', CAST(3400.00 AS Numeric(10, 2)), CAST(1700.00 AS Numeric(14, 2)), CAST(0x0000A77200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2103.92 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1051.96 AS Numeric(15, 2)), CAST(1865.92 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(932.96 AS Numeric(15, 2)), NULL, N'N', N'4', CAST(5.09 AS Numeric(5, 2)), N'E', N'70060956', N'YES', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'PIT: TABLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 11)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173643', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VVS1', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.20 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.09 AS Numeric(5, 2)), CAST(5.07 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(3.11 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.07 -  5.09 x  3.11', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Feather"', N'No Bgm/Eye Clean', N'GIA', N'2185437124', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A79200000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2389.44 AS Numeric(15, 2)), CAST(37.12 AS Numeric(15, 2)), CAST(1194.72 AS Numeric(15, 2)), CAST(2123.44 AS Numeric(15, 2)), CAST(44.12 AS Numeric(15, 2)), CAST(1061.72 AS Numeric(15, 2)), NULL, N'N', N'4.50', CAST(5.08 AS Numeric(5, 2)), N'H', N'70065432', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', N'WHT: GIRDLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 12)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_18', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 13)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_22', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 14)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'MP491348', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'L', N'VVS2', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.20 AS Numeric(5, 2)), CAST(62.00 AS Numeric(5, 2)), CAST(5.11 AS Numeric(5, 2)), CAST(5.06 AS Numeric(5, 2)), NULL, NULL, CAST(41.60 AS Numeric(5, 2)), CAST(33.50 AS Numeric(5, 2)), CAST(3.11 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  5.06 -  5.11 x  3.11', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Needle, Pinpoint"', NULL, N'GIA', N'5246495782', CAST(2000.00 AS Numeric(10, 2)), CAST(1000.00 AS Numeric(14, 2)), CAST(0x0000A6FE00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1180.00 AS Numeric(15, 2)), CAST(41.00 AS Numeric(15, 2)), CAST(590.00 AS Numeric(15, 2)), CAST(1040.00 AS Numeric(15, 2)), CAST(48.00 AS Numeric(15, 2)), CAST(520.00 AS Numeric(15, 2)), NULL, N'N', N'4.50', NULL, N'L', N'70054157', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198078', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 15)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA184438', N'ROUND', CAST(0.51 AS Decimal(10, 2)), N'D', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.50 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.10 AS Numeric(5, 2)), CAST(5.08 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.18 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.08 -  5.10 x  3.18', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud"', NULL, N'GIA', N'1255680910', CAST(4400.00 AS Numeric(10, 2)), CAST(2244.00 AS Numeric(14, 2)), CAST(0x0000A77600000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2722.72 AS Numeric(15, 2)), CAST(38.12 AS Numeric(15, 2)), CAST(1388.59 AS Numeric(15, 2)), CAST(2414.72 AS Numeric(15, 2)), CAST(45.12 AS Numeric(15, 2)), CAST(1231.51 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.08 AS Numeric(5, 2)), N'D', N'70064325', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197764', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn 1 Ti 2', N'SCR: TABLE', NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 16)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA135268', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VVS1', N'VG', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.20 AS Numeric(5, 2)), CAST(56.00 AS Numeric(5, 2)), CAST(5.00 AS Numeric(5, 2)), CAST(4.98 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.20 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(17.00 AS Numeric(5, 2)), N'  4.98 -  5.00 x  3.20', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Pinpoint, Feather, Indented Natural, Surface Graining"', N'No Bgm/Eye Clean', N'GIA', N'2244904505', CAST(3800.00 AS Numeric(10, 2)), CAST(1900.00 AS Numeric(14, 2)), CAST(0x0000A72900000000 AS DateTime), N'INDIA', N'-', N'-', N'H', CAST(2318.00 AS Numeric(15, 2)), CAST(39.00 AS Numeric(15, 2)), CAST(1159.00 AS Numeric(15, 2)), CAST(2052.00 AS Numeric(15, 2)), CAST(46.00 AS Numeric(15, 2)), CAST(1026.00 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(5.00 AS Numeric(5, 2)), N'H', N'70056026', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 17)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA125113', N'ROUND', CAST(0.31 AS Decimal(10, 2)), N'J', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.00 AS Numeric(5, 2)), CAST(58.00 AS Numeric(5, 2)), CAST(4.32 AS Numeric(5, 2)), CAST(4.30 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(2.67 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  4.30 -  4.32 x  2.67', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Feather, Needle"', NULL, N'GIA', N'6245720896', CAST(1600.00 AS Numeric(10, 2)), CAST(496.00 AS Numeric(14, 2)), CAST(0x0000A71500000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1216.00 AS Numeric(15, 2)), CAST(24.00 AS Numeric(15, 2)), CAST(376.96 AS Numeric(15, 2)), CAST(1104.00 AS Numeric(15, 2)), CAST(31.00 AS Numeric(15, 2)), CAST(342.24 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(4.31 AS Numeric(5, 2)), N'J', N'70055206', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 18)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA173422', N'ROUND', CAST(0.30 AS Decimal(10, 2)), N'F', N'VS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(61.10 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(4.32 AS Numeric(5, 2)), CAST(4.30 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(41.80 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(2.63 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  4.30 -  4.32 x  2.63', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Needle, Feather"', N'No Bgm / Eye Clean', N'GIA', N'1255548672', CAST(2300.00 AS Numeric(10, 2)), CAST(690.00 AS Numeric(14, 2)), CAST(0x0000A76E00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1598.50 AS Numeric(15, 2)), CAST(30.50 AS Numeric(15, 2)), CAST(479.55 AS Numeric(15, 2)), CAST(1437.50 AS Numeric(15, 2)), CAST(37.50 AS Numeric(15, 2)), CAST(431.25 AS Numeric(15, 2)), NULL, N'N', N'4', NULL, N'F', N'70062985', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 19)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'MS272326', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'D', N'VVS2', N'VG', N'EX', N'EX', N'FAINT', NULL, NULL, NULL, NULL, N'STK-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(63.30 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(5.31 AS Numeric(5, 2)), CAST(5.27 AS Numeric(5, 2)), NULL, NULL, CAST(40.20 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.35 AS Numeric(5, 2)), CAST(42.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.27 -  5.31 x  3.35', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Pinpoint', NULL, N'GIA', N'2237432015', CAST(5200.00 AS Numeric(10, 2)), CAST(3120.00 AS Numeric(14, 2)), CAST(0x0000A67600000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(3113.76 AS Numeric(15, 2)), CAST(40.12 AS Numeric(15, 2)), CAST(1868.26 AS Numeric(15, 2)), CAST(2749.76 AS Numeric(15, 2)), CAST(47.12 AS Numeric(15, 2)), CAST(1649.86 AS Numeric(15, 2)), NULL, N'N', N'5', CAST(5.29 AS Numeric(5, 2)), N'D', N'70039066', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942198616', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 20)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH181133', N'ROUND', CAST(0.60 AS Decimal(10, 2)), N'G', N'VVS1', N'EX', N'EX', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.30 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.39 AS Numeric(5, 2)), CAST(5.37 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(35.50 AS Numeric(5, 2)), CAST(3.35 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  5.37 -  5.39 x  3.35', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(45.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Pinpoint, Extra Facet"', N'No Bgm / Eye Clean', N'GIA', N'7256488997', CAST(4200.00 AS Numeric(10, 2)), CAST(2520.00 AS Numeric(14, 2)), CAST(0x0000A76300000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2961.00 AS Numeric(15, 2)), CAST(29.50 AS Numeric(15, 2)), CAST(1776.60 AS Numeric(15, 2)), CAST(2667.00 AS Numeric(15, 2)), CAST(36.50 AS Numeric(15, 2)), CAST(1600.20 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.38 AS Numeric(5, 2)), N'G', N'70062344', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', N'TP: MAIN', N'SM EF', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 21)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH233320', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VS2', N'VG', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED-THK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.40 AS Numeric(5, 2)), CAST(59.00 AS Numeric(5, 2)), CAST(4.96 AS Numeric(5, 2)), CAST(4.92 AS Numeric(5, 2)), NULL, NULL, CAST(40.80 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.18 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  4.92 -  4.96 x  3.18', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Cloud, Crystal"', N'No Bgm/Eye Clean', N'GIA', N'7266450851', CAST(3400.00 AS Numeric(10, 2)), CAST(1700.00 AS Numeric(14, 2)), CAST(0x0000A7C400000000 AS DateTime), N'INDIA', N'N', N'-', N'H', CAST(2261.00 AS Numeric(15, 2)), CAST(33.50 AS Numeric(15, 2)), CAST(1130.50 AS Numeric(15, 2)), CAST(2023.00 AS Numeric(15, 2)), CAST(40.50 AS Numeric(15, 2)), CAST(1011.50 AS Numeric(15, 2)), NULL, N'N', N'5.50', NULL, N'H', N'70070933', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 22)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA139388', N'ROUND', CAST(0.51 AS Decimal(10, 2)), N'E', N'VS1', N'EX', N'EX', N'EX', N'MEDIUM', N'BLUE', NULL, NULL, NULL, N'THN-MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(62.80 AS Numeric(5, 2)), CAST(57.00 AS Numeric(5, 2)), CAST(5.12 AS Numeric(5, 2)), CAST(5.10 AS Numeric(5, 2)), NULL, NULL, CAST(41.00 AS Numeric(5, 2)), CAST(36.50 AS Numeric(5, 2)), CAST(3.21 AS Numeric(5, 2)), CAST(43.00 AS Numeric(5, 2)), CAST(16.00 AS Numeric(5, 2)), N'  5.10 -  5.12 x  3.21', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Pinpoint, Needle"', N'No Bgm/Eye Clean', N'GIA', N'2257108069', CAST(4400.00 AS Numeric(10, 2)), CAST(2244.00 AS Numeric(14, 2)), CAST(0x0000A73E00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2398.00 AS Numeric(15, 2)), CAST(45.50 AS Numeric(15, 2)), CAST(1222.98 AS Numeric(15, 2)), CAST(2090.00 AS Numeric(15, 2)), CAST(52.50 AS Numeric(15, 2)), CAST(1065.90 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(5.09 AS Numeric(5, 2)), N'E', N'70058087', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn1ti1', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 23)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PH238062', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'H', N'VS1', N'FR', N'EX', N'G', N'NONE', NULL, NULL, NULL, NULL, N'THK-VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(70.30 AS Numeric(5, 2)), CAST(53.00 AS Numeric(5, 2)), CAST(4.79 AS Numeric(5, 2)), CAST(4.78 AS Numeric(5, 2)), NULL, NULL, CAST(42.20 AS Numeric(5, 2)), CAST(37.50 AS Numeric(5, 2)), CAST(3.36 AS Numeric(5, 2)), CAST(45.00 AS Numeric(5, 2)), CAST(18.00 AS Numeric(5, 2)), N'  4.78 -  4.79 x  3.36', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Pinpoint"', NULL, N'GIA', N'7261425394', CAST(3600.00 AS Numeric(10, 2)), CAST(1800.00 AS Numeric(14, 2)), CAST(0x0000A7BC00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1890.00 AS Numeric(15, 2)), CAST(47.50 AS Numeric(15, 2)), CAST(945.00 AS Numeric(15, 2)), CAST(1638.00 AS Numeric(15, 2)), CAST(54.50 AS Numeric(15, 2)), CAST(819.00 AS Numeric(15, 2)), NULL, N'N', N'7', NULL, N'H', N'70070855', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'T/OC T/OCT', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 24)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA254001', N'ROUND', CAST(0.30 AS Decimal(10, 2)), N'D', N'SI2', N'G', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'THN-VTK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(64.60 AS Numeric(5, 2)), CAST(52.00 AS Numeric(5, 2)), CAST(4.18 AS Numeric(5, 2)), CAST(4.17 AS Numeric(5, 2)), NULL, NULL, CAST(40.60 AS Numeric(5, 2)), CAST(33.00 AS Numeric(5, 2)), CAST(2.70 AS Numeric(5, 2)), CAST(42.50 AS Numeric(5, 2)), CAST(15.50 AS Numeric(5, 2)), N'  4.17 -  4.18 x  2.70', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'Feather', N'No Bgm/Eye Clean', N'GIA', N'6262227899', CAST(2000.00 AS Numeric(10, 2)), CAST(600.00 AS Numeric(14, 2)), CAST(0x0000A7A900000000 AS DateTime), N'INDIA', N'-', N'-', N'H', CAST(1240.00 AS Numeric(15, 2)), CAST(38.00 AS Numeric(15, 2)), CAST(372.00 AS Numeric(15, 2)), CAST(1100.00 AS Numeric(15, 2)), CAST(45.00 AS Numeric(15, 2)), CAST(330.00 AS Numeric(15, 2)), NULL, N'N', N'6', CAST(4.17 AS Numeric(5, 2)), N'D', N'70068239', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ti2crown Hair Line Open Girdle Natural', N'WHT: L.H. TP: L.H.', N'T/OCT PDV CV PV ALN', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 25)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'DF38453', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 26)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'DF37928', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 27)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_32', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 28)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'QWER_36', N'ROUND', CAST(0.50 AS Decimal(10, 2)), N'D', N'VVS2', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'GIA', N'12341654', CAST(5300.00 AS Numeric(10, 2)), CAST(2650.00 AS Numeric(14, 2)), NULL, N'INDIA', N'A', N'A', N'A', CAST(3438.64 AS Numeric(15, 2)), CAST(35.12 AS Numeric(15, 2)), CAST(1719.32 AS Numeric(15, 2)), NULL, NULL, NULL, NULL, N'N', NULL, NULL, N'D', NULL, NULL, NULL, NULL, 8536, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', NULL, NULL, 29)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA152378', N'ROUND', CAST(0.33 AS Decimal(10, 2)), N'D', N'VVS1', N'EX', N'EX', N'EX', N'NONE', NULL, NULL, NULL, NULL, N'MED', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.30 AS Numeric(5, 2)), CAST(61.00 AS Numeric(5, 2)), CAST(4.52 AS Numeric(5, 2)), CAST(4.50 AS Numeric(5, 2)), NULL, NULL, CAST(41.80 AS Numeric(5, 2)), CAST(32.50 AS Numeric(5, 2)), CAST(2.72 AS Numeric(5, 2)), CAST(44.50 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  4.50 -  4.52 x  2.72', CAST(1.00 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(75.00 AS Numeric(10, 2)), N'"Pinpoint, Feather"', N'No Bgm/Eye Clean', N'GIA', N'1253220599', CAST(3100.00 AS Numeric(10, 2)), CAST(1023.00 AS Numeric(14, 2)), CAST(0x0000A74C00000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(2569.28 AS Numeric(15, 2)), CAST(17.12 AS Numeric(15, 2)), CAST(847.86 AS Numeric(15, 2)), CAST(2352.28 AS Numeric(15, 2)), CAST(24.12 AS Numeric(15, 2)), CAST(776.25 AS Numeric(15, 2)), NULL, N'N', N'3.50', CAST(4.50 AS Numeric(5, 2)), N'D', N'70059525', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942199182', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Ok', NULL, NULL, NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 30)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'PA163143', N'ROUND', CAST(0.30 AS Decimal(10, 2)), N'E', N'SI2', N'EX', N'VG', N'VG', N'NONE', NULL, NULL, NULL, NULL, N'MED-STK', N'FACETED', N'NONE', NULL, NULL, NULL, NULL, CAST(60.60 AS Numeric(5, 2)), CAST(60.00 AS Numeric(5, 2)), CAST(4.34 AS Numeric(5, 2)), CAST(4.30 AS Numeric(5, 2)), NULL, NULL, CAST(41.40 AS Numeric(5, 2)), CAST(32.00 AS Numeric(5, 2)), CAST(2.62 AS Numeric(5, 2)), CAST(44.00 AS Numeric(5, 2)), CAST(12.50 AS Numeric(5, 2)), N'  4.30 -  4.34 x  2.62', CAST(1.01 AS Numeric(5, 2)), NULL, CAST(50.00 AS Numeric(10, 2)), CAST(80.00 AS Numeric(10, 2)), N'"Crystal, Cloud, Feather"', N'No Bgm / Eye Clean', N'GIA', N'1253487692', CAST(1900.00 AS Numeric(10, 2)), CAST(570.00 AS Numeric(14, 2)), CAST(0x0000A76300000000 AS DateTime), N'INDIA', N'-', N'-', N'A', CAST(1213.72 AS Numeric(15, 2)), CAST(36.12 AS Numeric(15, 2)), CAST(364.12 AS Numeric(15, 2)), CAST(1080.72 AS Numeric(15, 2)), CAST(43.12 AS Numeric(15, 2)), CAST(324.22 AS Numeric(15, 2)), NULL, N'N', N'4', CAST(4.30 AS Numeric(5, 2)), N'E', N'70061311', N'YES', NULL, N'Skype - sjogani55 /skype - ndoshi9490@gmail.com/ QQ- 2645330142 / QQ - 2942197719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Cn1, Ti2', N'TP: MAIN', N'UO', NULL, NULL, N'DISCOUNT', NULL, N'INDIA', N'CANADAMARK', NULL, 31)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project123', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 32)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project12', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 33)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project1', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 34)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project0', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 35)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project3', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(10, 2)), N's', N's', N's', N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(14, 2)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 36)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project4', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(10, 2)), N's', N's', N's', N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(14, 2)), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 37)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project5', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(10, 2)), N's', N's', N's', N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(14, 2)), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1 AS Numeric(10, 0)), N's', N's', CAST(1.00 AS Numeric(5, 2)), N's', N's', N's', N's', N's', 1, CAST(0x0000001500000000 AS DateTime), CAST(0x0000001500000000 AS DateTime), N's', N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 38)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project6', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(10, 2)), N's', N's', N's', N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(14, 2)), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1 AS Numeric(10, 0)), N's', N's', CAST(1.00 AS Numeric(5, 2)), N's', N's', N's', N's', N's', 1, CAST(0x0000001500000000 AS DateTime), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 39)
INSERT [dbo].[Temp] ([COMPCD], [STONEID], [SHAPE], [CTS], [COLOR], [CLARITY], [CUT], [POLISH], [SYM], [FLOURENCE], [FL_COLOR], [INCLUSION], [HA], [LUSTER], [GIRDLE], [GIRDLE_CONDITION], [CULET], [MILKY], [SHADE], [NATTS], [NATURAL], [DEPTH], [DIATABLE], [LENGTH], [WIDTH], [PAVILION], [CROWN], [PAVANGLE], [CROWNANGLE], [HEIGHT], [PAVHEIGHT], [CROWNHEIGHT], [MEASUREMENT], [RATIO], [PAIR], [STAR_LENGTH], [LOWER_HALF], [KEY_TO_SYMBOL], [REPORT_COMMENT], [CERTIFICATE], [CERTNO], [RAPARATE], [RAPAAMT], [CURDATE], [LOCATION], [LEGEND1], [LEGEND2], [LEGEND3], [ASKRATE_FC], [ASKDISC_FC], [ASKAMT_FC], [COSTRATE_FC], [COSTDISC_FC], [COSTAMT_FC], [WEB_CLIENTID], [wl_rej_status], [GIRDLEPER], [DIA], [COLORDESC], [BARCODE], [INSCRIPTION], [NEW_CERT], [MEMBER_COMMENT], [UPLOADCLIENTID], [REPORT_DATE], [NEW_ARRI_DATE], [TINGE], [EYE_CLN], [TABLE_INCL], [SIDE_INCL], [TABLE_BLACK], [SIDE_BLACK], [TABLE_OPEN], [SIDE_OPEN], [PAV_OPEN], [EXTRA_FACET], [INTERNAL_COMMENT], [POLISH_FEATURES], [SYMMETRY_FEATURES], [GRAINING], [IMG_URL], [RATEDISC], [GRADE], [CLIENT_LOCATION], [ORIGIN], [BGM], [Id]) VALUES (CAST(1 AS Numeric(5, 0)), N'Project7', N'Rouund', CAST(1.00 AS Decimal(10, 2)), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(5, 2)), N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(10, 2)), N's', N's', N's', N's', CAST(1.00 AS Numeric(10, 2)), CAST(1.00 AS Numeric(14, 2)), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1.00 AS Numeric(15, 2)), CAST(1 AS Numeric(10, 0)), N's', N's', CAST(1.00 AS Numeric(5, 2)), N's', N's', N's', N's', N's', 1, CAST(0x0000001500000000 AS DateTime), CAST(0x0000001500000000 AS DateTime), N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', N's', 40)
SET IDENTITY_INSERT [dbo].[Temp] OFF
ALTER TABLE [dbo].[Banner] ADD  CONSTRAINT [DF_Banner1_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Clientmaster] ADD  CONSTRAINT [DF_Clientmaster_InsertedDate]  DEFAULT (getdate()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[Clientmaster] ADD  DEFAULT ((0)) FOR [UTypeID]
GO
ALTER TABLE [dbo].[Clientmaster] ADD  CONSTRAINT [DF_Clientmaster_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Clientmaster] ADD  CONSTRAINT [DF_Clientmaster_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[GRADDET] ADD  DEFAULT ('N') FOR [wl_rej_status]
GO
ALTER TABLE [dbo].[Procmas] ADD  CONSTRAINT [DF_Procmas1_IsChangeable]  DEFAULT ((1)) FOR [IsChangeable]
GO
ALTER TABLE [dbo].[Procmas] ADD  CONSTRAINT [DF_Procmas_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Procmas] ADD  CONSTRAINT [DF_Procmas_InsertedDate]  DEFAULT (getdate()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[Procmas] ADD  CONSTRAINT [DF_Procmas_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[ShoppingCart] ADD  DEFAULT ('N') FOR [sc_rej_status]
GO
ALTER TABLE [dbo].[ShoppingCart] ADD  DEFAULT ('N') FOR [isMailed]
GO
ALTER TABLE [dbo].[Temp] ADD  DEFAULT ('N') FOR [wl_rej_status]
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH NOCHECK ADD  CONSTRAINT [FK_SC_CLIENTCD] FOREIGN KEY([SC_Clientcd])
REFERENCES [dbo].[Clientmaster] ([ClientCd])
GO
ALTER TABLE [dbo].[ShoppingCart] CHECK CONSTRAINT [FK_SC_CLIENTCD]
GO
USE [master]
GO
ALTER DATABASE [DiamondWebInventory] SET  READ_WRITE 
GO
