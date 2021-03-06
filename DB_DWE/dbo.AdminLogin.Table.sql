USE [DiamondWebInventory]
GO
/****** Object:  Table [dbo].[AdminLogin]    Script Date: 24-Jun-20 03:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdminLogin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Email_Id] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[User_Profile_Image] [nvarchar](max) NULL,
 CONSTRAINT [PK_AdminLogin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[AdminLogin] ON 

INSERT [dbo].[AdminLogin] ([Id], [Name], [Email_Id], [Password], [User_Profile_Image]) VALUES (1, N'Shubham Patel', N'Sparkleweb@dp.com', N'123456', N'DSC_8620.jpg')
SET IDENTITY_INSERT [dbo].[AdminLogin] OFF
