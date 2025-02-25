USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_PPCD2_au]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_PPCD2_au](
	[PPCD2_ID] [int] NOT NULL,
	[PPMULTID] [int] NOT NULL,
	[PPALPHA] [varchar](7) NULL,
	[PPPOLYN] [int] NOT NULL,
	[PPPOLTP] [varchar](4) NULL,
	[PPSECT] [varchar](2) NULL,
	[PPDES] [varchar](35) NULL,
	[PPAMT] [money] NULL,
	[PPCTOT] [money] NULL
) ON [PRIMARY]
GO
