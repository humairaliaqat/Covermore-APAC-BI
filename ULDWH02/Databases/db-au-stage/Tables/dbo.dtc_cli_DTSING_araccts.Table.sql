USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_DTSING_araccts]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_DTSING_araccts](
	[timestamp] [timestamp] NOT NULL,
	[posting_code] [varchar](8) NOT NULL,
	[description] [varchar](40) NOT NULL,
	[ar_acct_code] [varchar](32) NOT NULL,
	[fin_chg_acct_code] [varchar](32) NOT NULL,
	[rev_acct_code] [varchar](32) NOT NULL,
	[freight_acct_code] [varchar](32) NOT NULL,
	[disc_taken_acct_code] [varchar](32) NOT NULL,
	[disc_given_acct_code] [varchar](32) NOT NULL,
	[late_chg_acct_code] [varchar](32) NOT NULL,
	[suspense_acct_code] [varchar](32) NOT NULL,
	[cm_on_acct_code] [varchar](32) NOT NULL,
	[sales_ret_acct_code] [varchar](32) NOT NULL,
	[tax_rounding_acct_code] [varchar](32) NOT NULL,
	[nat_cur_code] [varchar](8) NOT NULL
) ON [PRIMARY]
GO
