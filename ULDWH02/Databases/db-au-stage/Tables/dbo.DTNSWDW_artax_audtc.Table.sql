USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTNSWDW_artax_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_artax_audtc](
	[timestamp] [timestamp] NOT NULL,
	[tax_code] [varchar](8) NOT NULL,
	[tax_desc] [varchar](40) NOT NULL,
	[tax_included_flag] [smallint] NOT NULL,
	[override_flag] [smallint] NOT NULL,
	[module_flag] [smallint] NOT NULL,
	[tax_connect_flag] [smallint] NOT NULL,
	[external_tax_code] [varchar](100) NOT NULL,
	[imported_flag] [smallint] NULL,
	[company_code] [varchar](16) NULL
) ON [PRIMARY]
GO
