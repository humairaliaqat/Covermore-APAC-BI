USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dqcQuoteImpulse]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dqcQuoteImpulse](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[TranDate] [date] NULL,
	[TravellerCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[QuoteCount2] [int] NULL,
	[BusinessUnitCount] [int] NULL,
	[ProductCount] [int] NULL,
	[DataSource] [varchar](100) NOT NULL,
	[BatchID] [int] NOT NULL,
	[LastUpdated] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dqcQuoteImpulse_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_dqcQuoteImpulse_BIRowID] ON [dbo].[dqcQuoteImpulse]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dqcQuoteImpulse_TranDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_dqcQuoteImpulse_TranDate] ON [dbo].[dqcQuoteImpulse]
(
	[DataSource] ASC,
	[TranDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dqcQuoteImpulse] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
