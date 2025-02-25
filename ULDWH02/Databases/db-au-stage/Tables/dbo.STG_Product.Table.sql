USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Product]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Product](
	[Product_Code] [varchar](50) NOT NULL,
	[Product_Desc] [varchar](200) NULL,
	[Product_Type_Code] [varchar](50) NOT NULL,
	[Product_Type_Desc] [varchar](200) NULL,
	[Product_Parent_Code] [varchar](50) NOT NULL,
	[Product_Parent_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
