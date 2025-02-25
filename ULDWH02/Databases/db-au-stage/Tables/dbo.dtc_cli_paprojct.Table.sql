USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_paprojct]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_paprojct](
	[project_code] [varchar](10) NOT NULL,
	[project_sell_tax_code] [varchar](10) NOT NULL,
	[fee_basis_code] [varchar](10) NULL,
	[Status] [varchar](9) NULL,
	[posting_code] [varchar](8) NULL,
	[company_code] [varchar](10) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_paprojct]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_paprojct] ON [dbo].[dtc_cli_paprojct]
(
	[project_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
