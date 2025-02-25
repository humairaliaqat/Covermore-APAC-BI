USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc](
	[journal_ctrl_num] [varchar](16) NOT NULL,
	[sequence_id] [int] NOT NULL,
	[account_code] [varchar](32) NULL,
	[seg1_code] [char](4) NULL,
	[seg2_code] [char](2) NULL,
	[seg3_code] [char](2) NULL,
	[balance] [money] NULL,
	[nat_balance] [money] NULL,
	[AUDbalance] [money] NULL,
	[DateApplied] [date] NULL,
	[DebtorCode] [varchar](8000) NULL,
	[Description] [varchar](40) NULL,
	[Document_1] [varchar](16) NULL,
	[Document_2] [varchar](16) NULL,
	[CompanyID] [int] NOT NULL,
	[seq_ref_id] [int] NULL,
	[calc_seq_id] [int] NULL,
	[ServiceEventActivitySK] [int] NULL,
	[nat_cur_code] [varchar](8) NULL,
	[rate] [money] NULL,
	[AUDConversionRate] [money] NULL,
	[journal_Description] [varchar](30) NULL,
	[posted_flag] [smallint] NULL,
	[companyName] [nvarchar](50) NOT NULL,
	[accountAndService] [varchar](6) NULL,
	[level11Desc] [varchar](95) NULL,
	[level12Desc] [varchar](95) NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [tmpIDX_GLCost_Seq]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [tmpIDX_GLCost_Seq] ON [dbo].[DTNSWDW_vwCostGLlinesAUD_audtc]
(
	[calc_seq_id] ASC
)
INCLUDE([BIRowID],[sequence_id],[Document_2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
