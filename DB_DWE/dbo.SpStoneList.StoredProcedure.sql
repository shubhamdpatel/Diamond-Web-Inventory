USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpStoneList]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
