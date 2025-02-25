USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpCompany]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpCompany](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](10) NULL,
	[CompanyID] [int] NOT NULL,
	[CompanyName] [varchar](50) NULL,
	[Nature] [varchar](50) NULL,
	[ACN] [varchar](15) NULL,
	[ABN] [varchar](15) NULL,
	[Street] [varchar](100) NULL,
	[Suburb] [varchar](25) NULL,
	[State] [varchar](20) NULL,
	[PostCode] [varchar](10) NULL,
	[ITC] [float] NULL,
	[NotRenew] [bit] NULL,
	[Phone] [varchar](15) NULL,
	[Fax] [varchar](15) NULL,
	[Email] [varchar](50) NULL
) ON [PRIMARY]
GO
