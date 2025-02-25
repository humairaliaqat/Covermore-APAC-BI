USE [db-au-star]
GO
/****** Object:  Table [dbo].[factABSTraveller]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factABSTraveller](
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[LeisureTravellerCount] [int] NOT NULL,
	[NonLeisureTravellerCount] [int] NOT NULL,
	[FriendRelativeCount] [int] NOT NULL,
	[HolidayCount] [int] NOT NULL,
	[LoadDate] [datetime] NOT NULL,
	[LoadID] [int] NOT NULL,
	[updateDate] [datetime] NULL,
	[updateID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factABSTraveller_DateSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_factABSTraveller_DateSK] ON [dbo].[factABSTraveller]
(
	[DateSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factABSTraveller_AgeBandSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factABSTraveller_AgeBandSK] ON [dbo].[factABSTraveller]
(
	[AgeBandSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factABSTraveller_DestinationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factABSTraveller_DestinationSK] ON [dbo].[factABSTraveller]
(
	[DestinationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factABSTraveller_DomainSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factABSTraveller_DomainSK] ON [dbo].[factABSTraveller]
(
	[DomainSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factABSTraveller_DurationSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factABSTraveller_DurationSK] ON [dbo].[factABSTraveller]
(
	[DurationSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
