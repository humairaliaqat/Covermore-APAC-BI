USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_fccountry_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_fccountry_uk](
	[CID] [char](2) NOT NULL,
	[CDESCRIPT] [varchar](50) NULL,
	[NATION] [varchar](50) NULL,
	[INUSE] [bit] NULL,
	[Nationid] [tinyint] NULL
) ON [PRIMARY]
GO
