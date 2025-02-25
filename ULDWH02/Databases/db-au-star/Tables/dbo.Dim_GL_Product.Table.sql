USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_GL_Product]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_GL_Product](
	[Product_SK] [int] IDENTITY(0,1) NOT NULL,
	[Product_Code] [varchar](50) NOT NULL,
	[Product_Desc] [varchar](200) NULL,
	[Product_Type_Code] [varchar](50) NOT NULL,
	[Product_Type_Desc] [varchar](200) NULL,
	[Product_Parent_Code] [varchar](50) NOT NULL,
	[Product_Parent_Desc] [varchar](200) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_GL_Product_PK] PRIMARY KEY CLUSTERED 
(
	[Product_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX01_Dim_GL_Product]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [IX01_Dim_GL_Product] ON [dbo].[Dim_GL_Product]
(
	[Product_Code] ASC
)
INCLUDE([Product_Type_Code],[Product_Parent_Code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
