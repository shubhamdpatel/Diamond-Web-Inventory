USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[spInsertShoppingCart]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
