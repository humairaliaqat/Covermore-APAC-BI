USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_PPGRP_my]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_PPGRP_my](
	[PPGRP_ID] [int] NOT NULL,
	[PPALPHA] [varchar](7) NULL,
	[PPPOLTP] [varchar](3) NULL,
	[PPPOLYN] [int] NULL,
	[PPAMT] [money] NULL,
	[PPGTOT] [money] NULL,
	[PPDES] [varchar](35) NULL,
	[PPSECT] [varchar](2) NULL
) ON [PRIMARY]
GO
