USE [db-au-star]
GO
/****** Object:  Table [dbo].[factTicket]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factTicket](
	[factTicketSK] [int] IDENTITY(0,1) NOT NULL,
	[DateSK] [int] NULL,
	[DepartureDateSK] [int] NULL,
	[DomainSK] [int] NULL,
	[DestinationSK] [int] NULL,
	[OriginSK] [int] NULL,
	[DurationSK] [int] NULL,
	[OutletSK] [int] NULL,
	[TicketCount] [int] NULL,
	[InternationalTravellersCount] [int] NULL,
	[Source] [varchar](50) NULL,
	[ReferenceNumber] [varchar](50) NULL,
	[LoadDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[BIRowID] [int] NULL,
	[Gross_Fare] [numeric](16, 2) NULL,
	[Net_Fare] [numeric](16, 2) NULL,
	[DomesticTicketCount] [int] NULL,
	[DomesticTravellersCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_factTicket_Date]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factTicket_Date] ON [dbo].[factTicket]
(
	[DateSK] ASC
)
INCLUDE([DepartureDateSK],[DomainSK],[DestinationSK],[OriginSK],[DurationSK],[OutletSK],[TicketCount],[InternationalTravellersCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_factTicket_Source]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_factTicket_Source] ON [dbo].[factTicket]
(
	[Source] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_factTicket_SK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED COLUMNSTORE INDEX [idx_factTicket_SK] ON [dbo].[factTicket] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE) ON [PRIMARY]
GO
