USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[spValidLogin]    Script Date: 24-Jun-20 03:37:06 PM ******/
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
