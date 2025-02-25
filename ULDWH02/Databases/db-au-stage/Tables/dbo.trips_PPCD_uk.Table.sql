USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_PPCD_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_PPCD_uk](
	[PPCD_ID] [int] NOT NULL,
	[PPMULTID] [int] NULL,
	[PPALPHA] [varchar](7) NULL,
	[PPPOLYN] [int] NOT NULL,
	[PPPOLTP] [varchar](4) NULL,
	[PPSECT] [varchar](2) NULL,
	[PPDES] [varchar](35) NULL,
	[PPAMT] [money] NULL,
	[PPCTOT] [money] NULL,
	[PPEMCNAME] [varchar](20) NULL,
	[PPEMCFIRST] [varchar](10) NULL
) ON [PRIMARY]
GO
