USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[COAUpload]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COAUpload](
	[Check Level 1] [bit] NOT NULL,
	[Check Level 2] [bit] NOT NULL,
	[Check Level 3] [bit] NOT NULL,
	[Check Level 4] [bit] NOT NULL,
	[Check Level 5] [bit] NOT NULL,
	[Check Level 6] [bit] NOT NULL,
	[Check Level 7] [bit] NOT NULL,
	[Level 1 Code] [nvarchar](255) NULL,
	[Level 1] [nvarchar](255) NULL,
	[Level 2 Code] [nvarchar](255) NULL,
	[Level 2] [nvarchar](255) NULL,
	[Level 3 Code] [nvarchar](255) NULL,
	[Level 3] [nvarchar](255) NULL,
	[Level 4 Code] [nvarchar](255) NULL,
	[Level 4] [nvarchar](255) NULL,
	[Level 5 Code] [nvarchar](255) NULL,
	[Level 5] [nvarchar](255) NULL,
	[Level 6 Code] [nvarchar](255) NULL,
	[Level 6] [nvarchar](255) NULL,
	[Level 7 Code] [nvarchar](255) NULL,
	[Level 7] [nvarchar](255) NULL,
	[Level 8 Code] [nvarchar](255) NULL,
	[Level 8] [nvarchar](255) NULL,
	[Account_Category] [nvarchar](255) NULL,
	[Account_Operator] [nvarchar](255) NULL
) ON [PRIMARY]
GO
