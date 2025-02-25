USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btinvline_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btinvline_audtc](
	[kinvlineid] [int] NOT NULL,
	[kinvlinetypeid] [int] NOT NULL,
	[kactlineid] [int] NOT NULL,
	[kcoverageid] [int] NULL,
	[kpolicymemid] [int] NULL,
	[kfunderid] [int] NULL,
	[kindid] [int] NULL,
	[invlinefee] [numeric](10, 2) NOT NULL,
	[invlinetotal] [numeric](10, 2) NOT NULL,
	[invlineadj] [numeric](10, 2) NOT NULL,
	[kadjustid] [int] NULL,
	[invsscale] [numeric](10, 2) NOT NULL,
	[invlineamt] [numeric](10, 2) NOT NULL,
	[invlineseq] [int] NULL,
	[kinvoicenoid] [int] NULL,
	[invlinepaid] [varchar](5) NOT NULL,
	[invlinepartialpaid] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[kpolagreid] [int] NULL,
	[invlineqty] [numeric](10, 2) NOT NULL,
	[invlinedispamt] [numeric](10, 2) NOT NULL,
	[invposted] [varchar](5) NOT NULL,
	[kindidpatient] [int] NULL,
	[invlinetaxamt] [numeric](10, 2) NULL,
	[invlinetotamt] [numeric](10, 2) NULL,
	[invlinetaxadj] [varchar](5) NULL,
	[fullyapplieddate] [date] NULL,
	[kreceiptidret] [int] NULL,
	[kinvlineidret] [int] NULL,
	[kfunderdeptid] [int] NULL
) ON [PRIMARY]
GO
