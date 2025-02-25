USE [db-au-stage]
GO
/****** Object:  Table [dbo].[bot_penguin_check]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bot_penguin_check](
	[QuoteKey] [nvarchar](30) NULL,
	[DestinationMAFactor] [float] NULL,
	[DurationMAFactor] [float] NULL,
	[LeadTimeMAFactor] [float] NULL,
	[AgeMAFactor] [float] NULL,
	[TransactionHourMAFactor] [float] NULL,
	[SameSessionQuoteCount] [int] NULL,
	[ConvertedFlag] [int] NULL,
	[BotFlag] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[bot_penguin_check]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
