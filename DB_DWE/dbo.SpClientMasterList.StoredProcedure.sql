USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpClientMasterList]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
