USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factABSTraveller]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factABSTraveller](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[LeisureTravellerCount] [int] NULL,
	[NonLeisureTravellerCount] [int] NULL,
	[FriendRelativeCount] [int] NULL,
	[HolidayCount] [int] NULL
) ON [PRIMARY]
GO
