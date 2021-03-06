USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpBannerCrud]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
