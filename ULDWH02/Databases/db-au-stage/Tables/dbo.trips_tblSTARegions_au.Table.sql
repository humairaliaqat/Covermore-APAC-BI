USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tblSTARegions_au]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tblSTARegions_au](
	[RgnId] [int] NOT NULL,
	[RgnDesc] [varchar](50) NULL,
	[inuse] [int] NULL,
	[orderby] [int] NULL
) ON [PRIMARY]
GO
