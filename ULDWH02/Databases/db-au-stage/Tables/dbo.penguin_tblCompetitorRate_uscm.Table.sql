USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCompetitorRate_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCompetitorRate_uscm](
	[Id] [int] NOT NULL,
	[CompetitorId] [int] NOT NULL,
	[Area] [nvarchar](100) NOT NULL,
	[AgeBand] [int] NOT NULL,
	[Duration] [int] NOT NULL,
	[Excess] [int] NOT NULL,
	[GrossPremium] [money] NOT NULL
) ON [PRIMARY]
GO
