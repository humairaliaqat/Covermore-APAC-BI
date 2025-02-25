USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_account_ind]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_account_ind](
	[Parent Account Code] [varchar](255) NULL,
	[Child Account Code] [varchar](255) NULL,
	[Child Account Description] [varchar](255) NULL,
	[Account Category] [varchar](255) NULL,
	[Account Hierarchy Type] [varchar](1) NOT NULL,
	[Account Operator] [varchar](255) NULL,
	[Account Order] [bigint] NULL
) ON [PRIMARY]
GO
