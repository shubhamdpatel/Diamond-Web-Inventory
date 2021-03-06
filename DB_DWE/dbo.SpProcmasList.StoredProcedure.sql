USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpProcmasList]    Script Date: 24-Jun-20 03:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpProcmasList] ' ','ORDER BY b.Id ASC',10,2
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
	  where  1=1 '+@whereclause+' AND ISNULL(c.IsDeleted,0)=0) as c_count
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
