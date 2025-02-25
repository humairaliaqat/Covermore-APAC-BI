USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_QuoteCRMUser]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_QuoteCRMUser](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](3) NOT NULL,
	[QuoteID] [int] NOT NULL,
	[CRMUserName] [nvarchar](50) NULL,
	[CRMFullName] [nvarchar](101) NOT NULL
) ON [PRIMARY]
GO
