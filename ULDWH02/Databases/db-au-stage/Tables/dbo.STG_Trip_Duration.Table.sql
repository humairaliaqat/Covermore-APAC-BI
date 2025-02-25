USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Trip_Duration]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Trip_Duration](
	[Trip_Duration_Days] [int] NOT NULL,
	[Trip_Duration_Band_Desc] [varchar](200) NOT NULL,
	[Trip_Duration_Band_Min] [int] NULL,
	[Trip_Duration_Band_Max] [int] NULL
) ON [PRIMARY]
GO
