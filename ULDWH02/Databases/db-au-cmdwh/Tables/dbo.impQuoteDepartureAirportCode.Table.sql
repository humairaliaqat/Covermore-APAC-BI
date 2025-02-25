USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuoteDepartureAirportCode]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuoteDepartureAirportCode](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[AirportCode] [nvarchar](50) NULL,
	[CreateBatchID] [int] NULL,
 CONSTRAINT [pk_impQuoteDepartureAirportCode] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuoteDepartureAirportCode_QuoteIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuoteDepartureAirportCode_QuoteIDKey] ON [dbo].[impQuoteDepartureAirportCode]
(
	[QuoteIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
