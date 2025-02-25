USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_account]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_account](
	[Parent Account Code] [varchar](255) NULL,
	[Child Account Code] [varchar](255) NULL,
	[Child Account Description] [varchar](255) NULL,
	[Account Category] [varchar](255) NULL,
	[Account Hierarchy Type] [varchar](1) NOT NULL,
	[Account Operator] [varchar](255) NULL,
	[Account Order] [bigint] NULL,
	[FIP Account] [float] NULL,
	[SAP PE3 Account] [float] NULL,
	[FIP TOB] [float] NULL,
	[SAP TOB] [float] NULL,
	[TOM] [nvarchar](255) NULL,
	[Account Type] [nvarchar](255) NULL,
	[Statutory Mapping] [nvarchar](255) NULL,
	[Internal Mapping] [nvarchar](255) NULL,
	[Technical] [nvarchar](255) NULL,
	[Intercompany] [nvarchar](255) NULL
) ON [PRIMARY]
GO
