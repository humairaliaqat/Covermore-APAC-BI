USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLPROVIDERS_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLPROVIDERS_nz](
	[KPROV_ID] [int] NOT NULL,
	[KPROVTYPE] [varchar](25) NULL,
	[KPROVNAME] [varchar](30) NULL,
	[KPROVSURNAME] [varchar](30) NULL,
	[KPPROVFIRST] [varchar](15) NULL,
	[KPSTREET] [varchar](100) NULL,
	[KPSUBURB] [varchar](20) NULL,
	[KPSTATE] [varchar](5) NULL,
	[KPPCODE] [varchar](8) NULL,
	[KPCOUNTRY] [varchar](20) NULL,
	[KPPHONE] [varchar](20) NULL,
	[KPFAX] [varchar](50) NULL,
	[KPEMAIL] [varchar](60) NULL,
	[KPFOREIGN] [bit] NOT NULL,
	[KPACCT] [varchar](10) NULL,
	[KPACCTNAME] [varchar](30) NULL,
	[KPBSB] [varchar](6) NULL,
	[KPDIRECTCRED] [bit] NULL,
	[KPEMAILOK] [bit] NULL
) ON [PRIMARY]
GO
