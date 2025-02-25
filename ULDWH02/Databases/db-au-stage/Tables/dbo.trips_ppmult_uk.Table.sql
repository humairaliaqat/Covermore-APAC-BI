USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_ppmult_uk]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_ppmult_uk](
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
	[addactcover_amt] [money] NULL,
	[wntrcover_amt] [money] NULL,
	[mtrcyclecover_amt] [money] NULL,
	[businesscover_amt] [money] NULL,
	[petcover_amt] [money] NULL,
	[golfcover_amt] [money] NULL,
	[educover_amt] [money] NULL,
	[businesscover] [bit] NULL,
	[petcover] [bit] NULL,
	[golfcover] [bit] NULL,
	[educover] [bit] NULL,
	[addacttypea] [bit] NULL,
	[addacttypeb] [bit] NULL,
	[addacttypec] [bit] NULL,
	[addacttyped] [bit] NULL,
	[ISADULT] [bit] NULL,
	[WNTRBRD] [bit] NULL,
	[WNTRSKI] [bit] NULL,
	[MTRCYCLE] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL
) ON [PRIMARY]
GO
