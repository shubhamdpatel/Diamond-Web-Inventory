USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpStoneListCrud]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
