USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLNAMES_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLNAMES_uk](
	[KN_ID] [int] NOT NULL,
	[KNCLAIM_ID] [int] NULL,
	[KNNUM] [smallint] NULL,
	[KNSURNAME] [varchar](60) NULL,
	[KNFIRST] [varchar](15) NULL,
	[KNTITLE] [varchar](5) NULL,
	[KNDOB] [datetime] NULL,
	[KNSTREET] [varchar](100) NULL,
	[KNSUBURB] [varchar](20) NULL,
	[KNSTATE] [varchar](15) NULL,
	[KNCOUNTRY] [varchar](20) NULL,
	[KNPCODE] [varchar](8) NULL,
	[KNHPHONE] [varchar](20) NULL,
	[KNWPHONE] [varchar](20) NULL,
	[KNFAX] [varchar](20) NULL,
	[KNEMAIL] [varchar](60) NULL,
	[KNDIRECTCRED] [bit] NOT NULL,
	[KNACCT] [varchar](8) NULL,
	[KNACCTNAME] [varchar](35) NULL,
	[KNBSB] [varchar](11) NULL,
	[KNPRIMARY] [bit] NOT NULL,
	[KNTHIRDPARTY] [bit] NOT NULL,
	[KNFOREIGN] [bit] NOT NULL,
	[KNPROV_ID] [int] NULL,
	[KNBUSINESSNAME] [varchar](30) NULL,
	[KNEMAILOK] [bit] NULL
) ON [PRIMARY]
GO
