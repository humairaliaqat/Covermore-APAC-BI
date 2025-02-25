USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_etactline_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_etactline_audtc](
	[kactlineid] [int] NOT NULL,
	[kitemid] [int] NOT NULL,
	[itemname] [nvarchar](40) NOT NULL,
	[lineqty] [numeric](10, 2) NOT NULL,
	[kuomid] [int] NOT NULL,
	[linefee] [numeric](10, 2) NOT NULL,
	[linetotal] [numeric](10, 2) NOT NULL,
	[kactid] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[useseqovr] [varchar](5) NULL,
	[kworkshopregitemid] [int] NULL,
	[kwssesslineid] [int] NULL,
	[kactlineidret] [int] NULL
) ON [PRIMARY]
GO
