USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyCompetitor]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyCompetitor](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyKey] [varchar](71) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[CompetitorID] [int] NOT NULL,
	[CompetitorName] [nvarchar](50) NULL,
	[CompetitorPrice] [money] NOT NULL
) ON [PRIMARY]
GO
