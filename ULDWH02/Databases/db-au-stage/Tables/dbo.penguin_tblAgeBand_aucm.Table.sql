USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAgeBand_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAgeBand_aucm](
	[AgeBandID] [int] NOT NULL,
	[AgeBandSetID] [int] NOT NULL,
	[StartAge] [int] NOT NULL,
	[EndAge] [int] NOT NULL
) ON [PRIMARY]
GO
