USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTNSWDW_vwRevenueAUD_audtc]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_vwRevenueAUD_audtc](
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
	[nat_balance] [money] NULL,
	[seq_ref_id] [int] NULL,
	[calc_seq_id] [int] NULL,
	[ServiceEventActivitySK] [int] NULL,
	[rate] [money] NULL,
	[AUDConversionRate] [money] NULL,
	[journal_Description] [varchar](30) NULL,
	[posted_flag] [smallint] NULL,
	[companyName] [nvarchar](50) NOT NULL,
	[accountAndService] [varchar](6) NULL
) ON [PRIMARY]
GO
