USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpClientMasterCrud]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
