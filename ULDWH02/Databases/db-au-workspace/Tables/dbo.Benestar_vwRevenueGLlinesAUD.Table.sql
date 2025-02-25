USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_vwRevenueGLlinesAUD]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_vwRevenueGLlinesAUD](
	[journal_ctrl_num] [varchar](16) NOT NULL,
	[sequence_id] [int] NOT NULL,
	[account_code] [varchar](32) NULL,
	[seg1_code] [char](4) NULL,
	[seg2_code] [char](2) NULL,
	[seg3_code] [char](2) NULL,
	[DateApplied] [date] NULL,
	[DebtorCode] [varchar](8000) NULL,
	[Description] [varchar](40) NULL,
	[Document_1] [varchar](16) NULL,
	[Document_2] [varchar](16) NULL,
	[CompanyID] [int] NOT NULL,
	[Balance] [money] NULL,
	[AUDbalance] [money] NULL,
	[nat_cur_code] [varchar](8) NULL,
	[nat_balance] [money] NULL
) ON [PRIMARY]
GO
