USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrOfficeVibesScore]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrOfficeVibesScore](
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
