USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[spValidAdmin]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
