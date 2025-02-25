USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrOfficeVibesEngagement]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrOfficeVibesEngagement](
	[Month] [datetime] NULL,
	[Team] [varchar](200) NULL,
	[Participation] [float] NULL,
	[Engagement] [float] NULL,
	[eNPS] [float] NULL,
	[Recognition] [float] NULL,
	[Ambassadorship] [float] NULL,
	[Feedback] [float] NULL,
	[RelationshipWithColleagues] [float] NULL,
	[RelationshipWithManagers] [float] NULL,
	[Satisfaction] [float] NULL,
	[CompanyAlignment] [float] NULL,
	[Happiness] [float] NULL,
	[Wellness] [float] NULL,
	[PersonalGrowth] [float] NULL
) ON [PRIMARY]
GO
