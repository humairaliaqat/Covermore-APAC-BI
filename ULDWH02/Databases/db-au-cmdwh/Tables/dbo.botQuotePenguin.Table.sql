USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[botQuotePenguin]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[botQuotePenguin](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QuoteKey] [nvarchar](30) NULL,
	[DestinationMAFactor] [float] NULL,
	[DurationMAFactor] [float] NULL,
	[LeadTimeMAFactor] [float] NULL,
	[AgeMAFactor] [float] NULL,
	[TransactionHourMAFactor] [float] NULL,
	[SameSessionQuoteCount] [int] NULL,
	[ConvertedFlag] [bit] NULL,
	[BotFlag] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[botQuotePenguin]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[botQuotePenguin]
(
	[QuoteKey] ASC
)
INCLUDE([BotFlag]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
