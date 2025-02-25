USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_ppaddr_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_ppaddr_sg](
	[PPADDR_ID] [int] NOT NULL,
	[PPALPHA] [varchar](7) NULL,
	[PPPOLYN] [int] NOT NULL,
	[PPPOLTP] [varchar](4) NULL,
	[PPSTREET] [varchar](60) NULL,
	[PPSUBURB] [varchar](30) NULL,
	[PPSTATE] [varchar](20) NULL,
	[PPPOST] [varchar](50) NULL,
	[PPPHONE] [varchar](50) NULL,
	[PPWPHONE] [varchar](50) NULL,
	[PPEMAIL] [varchar](60) NULL,
	[PPCOUNTRY] [varchar](20) NULL
) ON [PRIMARY]
GO
