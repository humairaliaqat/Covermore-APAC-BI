USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Usr_Trip_Duration_Bands]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usr_Trip_Duration_Bands](
	[Trip_Duration_Days] [int] NOT NULL,
	[Trip_Duration_Band_Desc] [varchar](200) NOT NULL,
	[Trip_Duration_Band_Min] [int] NULL,
	[Trip_Duration_Band_Max] [int] NULL
) ON [PRIMARY]
GO
