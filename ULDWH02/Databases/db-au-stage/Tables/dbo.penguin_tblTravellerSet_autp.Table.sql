USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblTravellerSet_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblTravellerSet_autp](
	[TravellerSetID] [int] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[DomainID] [int] NOT NULL,
	[MinimumAdult] [smallint] NULL,
	[MaximumAdult] [smallint] NULL,
	[MinimumChild] [smallint] NULL,
	[MaximumChild] [smallint] NULL
) ON [PRIMARY]
GO
