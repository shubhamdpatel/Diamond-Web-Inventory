USE [DiamondWebInventory]
GO
/****** Object:  StoredProcedure [dbo].[SpProcmasCrud]    Script Date: 24-Jun-20 03:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- execute [SpProcmasCrud] 5,'Sparkle Web',1,'Mumbai','shubham',1,'y',1,'Red','Red','Red','Red','Red',1,'UPDATE',''
-- =============================================
CREATE PROCEDURE [dbo].[SpProcmasCrud]
	@Id int= '',
	@Procgroup varchar(20)= '',
	@Proccd numeric(10,0)= 0,
	@Procnm varchar(100) = '',
	@Shortnm varchar(100) = '',
	@Ord numeric(10,0) = 0,
	@IsActive bit = 0,
	--@IsDeleted bit = 0,
	--@InsertedDate Datetime = 0,
	--@UpdatedDate Datetime = 0,
	@FLAG nvarchar(10) = 'INSERT',
	@RETURNVAL nvarchar(10) OUTPUT
AS
BEGIN
    
--------------------------------------------	
    --INSERT'
--------------------------------------------
	--DECLARE @RETURNVAL nvarchar(50)
	IF @FLAG='INSERT'
	BEGIN 
		INSERT INTO Procmas (Procgroup,Proccd,Procnm,Shortnm,Ord,IsActive,IsDeleted,InsertedDate,UpdatedDate)
		VALUES (@Procgroup,@Proccd,@Procnm,@Shortnm,@Ord,@IsActive,0,GETDATE(),null)
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	ELSE IF @FLAG='DELETE'
	BEGIN 
		UPDATE Procmas SET IsDeleted=1 WHERE Id=@Id
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
	Else IF @FLAG='UPDATE'
	BEGIN
		UPDATE Procmas SET Procgroup=@Procgroup,Proccd=@Proccd,Procnm=@Procnm,Shortnm=@Shortnm,Ord=@Ord,IsActive=@IsActive WHERE ID=@Id 
		SET @RETURNVAL='1'
		RETURN @RETURNVAL
	END
END


GO
