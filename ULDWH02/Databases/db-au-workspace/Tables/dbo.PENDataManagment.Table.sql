USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[PENDataManagment]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PENDataManagment](
	[dateCreated] [datetime] NULL,
	[owner] [nvarchar](250) NULL,
	[dbName] [nvarchar](250) NULL,
	[tableName] [nvarchar](250) NULL,
	[expiryDate] [datetime] NULL,
	[comments] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
