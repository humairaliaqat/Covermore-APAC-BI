USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_clstkprods_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_clstkprods_uk](
	[ID] [int] NOT NULL,
	[CLALPHA] [varchar](7) NULL,
	[PRODUCT] [varchar](3) NULL,
	[COMM] [float] NULL,
	[CLSCODE] [smallint] NULL,
	[LOADING] [float] NULL
) ON [PRIMARY]
GO
