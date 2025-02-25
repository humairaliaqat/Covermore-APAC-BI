USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factTicket_29032021]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factTicket_29032021](
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
