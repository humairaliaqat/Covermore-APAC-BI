USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblDests_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblDests_nz](
	[DestID] [int] NOT NULL,
	[QtID] [int] NULL,
	[DaysPaidID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[PropBal] [char](1) NULL,
	[DestTypeID] [smallint] NULL,
	[NoJourns] [smallint] NULL,
	[NoDays] [smallint] NULL,
	[TotDays] [int] NULL,
	[DaysLoad] [money] NULL
) ON [PRIMARY]
GO
