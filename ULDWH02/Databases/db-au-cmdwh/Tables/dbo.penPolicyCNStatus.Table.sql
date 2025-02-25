USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyCNStatus]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyCNStatus](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NOT NULL,
	[CNStatusID] [int] NOT NULL,
	[CNStatus] [varchar](200) NULL
) ON [PRIMARY]
GO
