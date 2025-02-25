USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_ppmult_my]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_ppmult_my](
	[PPMULT_ID] [int] NOT NULL,
	[PPALPHA] [varchar](7) NULL,
	[PPPOLYN] [int] NOT NULL,
	[PPPOLTP] [varchar](4) NULL,
	[PPNAME] [varchar](25) NULL,
	[PPINITS] [varchar](4) NULL,
	[PPTITLE] [varchar](6) NULL,
	[PPAGE] [varchar](3) NULL,
	[PPDOB] [datetime] NULL,
	[PPFIRST] [varchar](25) NULL,
	[ISADULT] [bit] NULL,
	[WNTRBRD] [bit] NULL,
	[WNTRSKI] [bit] NULL,
	[MTRCYCLE] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL
) ON [PRIMARY]
GO
