USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpShoppingCartList]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
