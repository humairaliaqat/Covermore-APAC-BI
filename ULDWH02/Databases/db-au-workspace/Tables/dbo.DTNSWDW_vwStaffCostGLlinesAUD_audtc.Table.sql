USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTNSWDW_vwStaffCostGLlinesAUD_audtc]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_vwStaffCostGLlinesAUD_audtc](
	[journal_ctrl_num] [varchar](16) NOT NULL,
	[sequence_id] [int] NOT NULL,
	[account_code] [varchar](32) NULL,
	[seg1_code] [char](4) NULL,
	[seg2_code] [char](2) NULL,
	[seg3_code] [char](2) NULL,
	[balance] [money] NULL,
	[AUDbalance] [money] NULL,
	[DateApplied] [date] NULL,
	[DebtorCode] [varchar](8000) NULL,
	[Description] [varchar](40) NULL,
	[Document_1] [varchar](16) NULL,
	[Document_2] [varchar](16) NULL,
	[CompanyID] [int] NOT NULL
) ON [PRIMARY]
GO
