USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyCNStatus]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyCNStatus](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[CNStatusID] [int] NOT NULL,
	[CNStatus] [varchar](200) NULL
) ON [PRIMARY]
GO
