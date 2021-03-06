USE [DiamondWebInventory]
GO
/****** Object:  Table [dbo].[Banner]    Script Date: 24-Jun-20 03:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Banner](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NULL,
	[ImageType] [nvarchar](50) NULL,
	[ClickUrl] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[InsertedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Banner] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Banner] ON 

INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (9, N'Sparkle ', N'a.jpg', N'shubham', 1, 1, CAST(0x0000AB8401421395 AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (10, N'shubham', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (11, N'tarunbanti', N'Pubg Tounament.jpg', N'tarun', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (12, N'Shubham', N'WIN_20200509_10_53_25_Pro.jpg', N'http://shubham.com', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (13, N'Shubham', N'WIN_20190503_10_35_11_Pro.jpg', N'http://shubham.com', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (14, N'uday', N'20191225173004_IMG_1505 (1).jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (15, N'Shubham', N's.jpg', N'http://shubham.com', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (16, N'uday', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (17, N'Shubham', N'ben-kolde-403278-unsplash.jpg', N'Sbm', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (18, N'uday', N'a.jpg', N'uday', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (19, N'uday', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (20, N'UDAY', N'WIN_20190503_10_35_11_Pro.jpg', N'http://Uday.com', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (21, N'uday', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (22, N'Shubham', N'20191030_124201.jpg', N's', 1, 0, CAST(0x0000AB8E00F8C52C AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (23, N'Shubham', N'DSC_8620.jpg', N's', 1, 0, CAST(0x0000AB8E00F8C52C AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (24, N'shubham', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (25, N'Tarun', N'20191225164550_IMG_1389.jpg', N'Tarun', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (26, N'uday', N'20191225164432_IMG_1384.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (27, N'uday', N'20191225171354_IMG_1474.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (28, N'uday', N'20191225173004_IMG_1505 (1).jpg', N'uday', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (29, N'uday', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (30, N'uday', N'martin-shreder-349256-unsplash.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (31, N'Shubham', N'ben-kolde-403278-unsplash.jpg', N'Sbm', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (32, N'uday', N'a.jpg', N'uday', 1, 0, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (34, N'uday', N'a.jpg', N'uday', 1, 1, CAST(0x0000AB84014562AE AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (35, N'Rachna', N'Pubg Tounament.jpg', N'R', 1, 1, CAST(0x0000ABDB00CB6D47 AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (36, N'Rachna', N'MRV_20200607_13_44_08.jpg', N's', 1, 1, CAST(0x0000ABDE0181C2F4 AS DateTime), NULL)
INSERT [dbo].[Banner] ([Id], [Title], [ImageType], [ClickUrl], [IsActive], [IsDeleted], [InsertedDate], [UpdatedDate]) VALUES (37, N'SparkleWeb', N'WIN_20190503_10_35_11_Pro.jpg', N'http://Shubham.com', 1, 0, CAST(0x0000ABE3009CD3E9 AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[Banner] OFF
ALTER TABLE [dbo].[Banner] ADD  CONSTRAINT [DF_Banner1_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
