USE [db-au-stage]
GO
/****** Object:  Table [dbo].[test_sungl_excel_usercoa]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test_sungl_excel_usercoa](
	[HiearchyType] [nvarchar](255) NULL,
	[Level 1 Code] [nvarchar](255) NULL,
	[Level 1] [nvarchar](255) NULL,
	[Level 1 Category] [nvarchar](255) NULL,
	[Level 1 Operator] [nvarchar](255) NULL,
	[Level 2 Code] [nvarchar](255) NULL,
	[Level 2] [nvarchar](255) NULL,
	[Level 2 Category] [nvarchar](255) NULL,
	[Level 2 Operator] [nvarchar](255) NULL,
	[Level 3 Code] [nvarchar](255) NULL,
	[Level 3] [nvarchar](255) NULL,
	[Level 3 Category] [nvarchar](255) NULL,
	[Level 3 Operator] [nvarchar](255) NULL,
	[Level 4 Code] [nvarchar](255) NULL,
	[Level 4] [nvarchar](255) NULL,
	[Level 4 Category] [nvarchar](255) NULL,
	[Level 4 Operator] [nvarchar](255) NULL,
	[Level 5 Code] [nvarchar](255) NULL,
	[Level 5] [nvarchar](255) NULL,
	[Level 5 Category] [nvarchar](255) NULL,
	[Level 5 Operator] [nvarchar](255) NULL,
	[Level 6 Code] [nvarchar](255) NULL,
	[Level 6] [nvarchar](255) NULL,
	[Level 6 Category] [nvarchar](255) NULL,
	[Level 6 Operator] [nvarchar](255) NULL,
	[Level 7 Code] [nvarchar](255) NULL,
	[Level 7] [nvarchar](255) NULL,
	[Level 7 Category] [nvarchar](255) NULL,
	[Level 7 Operator] [nvarchar](255) NULL,
	[Level 8 Code] [nvarchar](255) NULL,
	[Level 8] [nvarchar](255) NULL,
	[Level 8 Category] [nvarchar](255) NULL,
	[Level 8 Operator] [nvarchar](255) NULL,
	[FIP Account] [float] NULL,
	[SAP PE3 Account] [float] NULL,
	[FIP TOB] [float] NULL,
	[SAP TOB] [float] NULL,
	[TOM] [nvarchar](255) NULL,
	[Account Type] [nvarchar](255) NULL,
	[Statutory Mapping] [nvarchar](255) NULL,
	[Internal Mapping] [nvarchar](255) NULL,
	[Technical] [nvarchar](255) NULL,
	[Intercompany] [nvarchar](255) NULL,
	[ID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
