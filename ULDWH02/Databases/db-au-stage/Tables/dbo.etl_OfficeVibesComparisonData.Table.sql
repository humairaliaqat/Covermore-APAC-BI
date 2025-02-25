USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_OfficeVibesComparisonData]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_OfficeVibesComparisonData](
	[Month] [varchar](50) NULL,
	[Groups] [varchar](50) NULL,
	[Participation] [varchar](50) NULL,
	[Engagement] [varchar](50) NULL,
	[eNPS] [varchar](50) NULL,
	[Recognition] [varchar](50) NULL,
	[Ambassadorship] [varchar](50) NULL,
	[Feedback] [varchar](50) NULL,
	[RelationshipWithColleagues] [varchar](50) NULL,
	[RelationshipWithManagers] [varchar](50) NULL,
	[Satisfaction] [varchar](50) NULL,
	[CompanyAlignment] [varchar](50) NULL,
	[Happiness] [varchar](50) NULL,
	[Wellness] [varchar](50) NULL,
	[PersonalGrowth] [varchar](50) NULL
) ON [PRIMARY]
GO
