USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_OBJECT_TYPE_STR]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_OBJECT_TYPE_STR](
	[Object_Type_ID] [varchar](64) NOT NULL,
	[Language] [varchar](10) NOT NULL,
	[Object_Type_Name] [nvarchar](255) NULL
) ON [PRIMARY]
GO
