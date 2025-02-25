USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_ASSIST_DOMAINS_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_ASSIST_DOMAINS_aucm](
	[Domainid] [int] NOT NULL,
	[DomainCode] [varchar](3) NOT NULL,
	[DomainDesc] [varchar](50) NULL,
	[TimeZoneCode] [varchar](100) NULL,
	[currencySymbol] [varchar](10) NULL,
	[IsFeeRequired] [bit] NULL
) ON [PRIMARY]
GO
