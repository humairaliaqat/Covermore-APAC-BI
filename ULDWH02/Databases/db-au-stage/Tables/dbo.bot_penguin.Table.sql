USE [db-au-stage]
GO
/****** Object:  Table [dbo].[bot_penguin]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bot_penguin](
	[QuoteKey] [nvarchar](30) NULL,
	[DestinationMAFactor] [float] NULL,
	[DurationMAFactor] [float] NULL,
	[LeadTimeMAFactor] [float] NULL,
	[AgeMAFactor] [float] NULL,
	[TransactionHourMAFactor] [float] NULL,
	[SameSessionQuoteCount] [int] NULL,
	[ConvertedFlag] [smallint] NULL,
	[BotFlag] [smallint] NULL
) ON [PRIMARY]
GO
