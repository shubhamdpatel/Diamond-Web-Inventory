USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[spGetPassword]    Script Date: 24-Jun-20 03:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [spGetPassword] 'shubhampatel1780@gmail.com'
-- =============================================
CREATE PROCEDURE [dbo].[spGetPassword]
@Email nvarchar(50)
as
BEGIN
	If Exists(SELECT * FROM Clientmaster WHERE EmailID1=@Email)
	BEGIN
		SELECT EmailID1, Password FROM Clientmaster WHERE EmailID1=@Email 
	END
END
GO
