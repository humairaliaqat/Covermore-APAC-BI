USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpDestination]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpDestination](
	[CountryKey] [varchar](2) NOT NULL,
	[DestinationKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[DestinationID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[DaysPaidID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[PropBal] [char](1) NULL,
	[DestinationTypeID] [smallint] NULL,
	[DestinationDesc] [varchar](150) NULL,
	[DestinationType] [varchar](50) NULL,
	[DestinationDailyRate] [money] NULL,
	[NoJourns] [smallint] NULL,
	[NoDays] [smallint] NULL,
	[TotDays] [int] NULL,
	[DaysLoad] [money] NULL
) ON [PRIMARY]
GO
