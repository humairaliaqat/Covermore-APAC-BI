USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tblageloading_a_au]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tblageloading_a_au](
	[AgeLoadingId] [int] NOT NULL,
	[PlanId] [int] NULL,
	[AgeBracket] [varchar](10) NULL,
	[NetRate] [float] NULL
) ON [PRIMARY]
GO
