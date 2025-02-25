USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_pataxtypdet]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_pataxtypdet](
	[tax_type_code] [varchar](10) NOT NULL,
	[effective_date] [datetime] NOT NULL,
	[tax_amt] [money] NOT NULL,
	[created_date] [datetime] NULL,
	[created_user] [varchar](31) NULL,
	[last_edit_date] [datetime] NULL,
	[last_edit_user] [varchar](31) NULL
) ON [PRIMARY]
GO
