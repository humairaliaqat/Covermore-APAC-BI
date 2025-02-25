USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_emcCompanies]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_emcCompanies](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](11) NULL,
	[ParentCompanyID] [int] NULL,
	[CompanyID] [smallint] NOT NULL,
	[SubCompanyID] [int] NULL,
	[ParentCompanyCode] [varchar](3) NULL,
	[CompanyCode] [varchar](50) NULL,
	[SubCompanyCode] [varchar](50) NULL,
	[ProductCode] [varchar](3) NULL,
	[ParentCompanyName] [nchar](100) NULL,
	[CompanyName] [varchar](50) NULL,
	[SubCompanyName] [varchar](250) NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[Phone] [varchar](30) NULL,
	[Fax] [varchar](30) NULL,
	[Email] [varchar](255) NULL,
	[BCC] [varchar](255) NULL,
	[FromEmail] [varchar](255) NULL,
	[isHealixOnly] [int] NOT NULL,
	[isSubCompanyActive] [int] NOT NULL
) ON [PRIMARY]
GO
