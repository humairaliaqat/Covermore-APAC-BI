USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fltTickets]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fltTickets](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[DocumentNumber] [varchar](100) NULL,
	[PNRNumber] [varchar](50) NULL,
	[T3Code] [varchar](50) NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[OutletKey] [varchar](50) NULL,
	[IssueDate] [date] NULL,
	[RefundedDate] [date] NULL,
	[DocumentType] [varchar](50) NULL,
	[TicketType] [varchar](50) NULL,
	[JourneyType] [varchar](50) NULL,
	[TravelType] [varchar](50) NULL,
	[AdultChildIndicator] [varchar](50) NULL,
	[FirstFlightDate] [date] NULL,
	[TotalDuration] [int] NULL,
	[DurationAtDestination] [int] NULL,
	[IATANumber] [varchar](50) NULL,
	[IATACode] [varchar](50) NULL,
	[AirlineCode] [varchar](50) NULL,
	[PrimaryClass] [varchar](50) NULL,
	[MultiClassIndicator] [bit] NULL,
	[RoutingDescription] [varchar](8000) NULL,
	[NumberOfSectors] [int] NULL,
	[OriginAirportCode] [varchar](50) NULL,
	[OriginAirportCityName] [varchar](100) NULL,
	[OriginAirportCountryName] [varchar](100) NULL,
	[DestinationAirportCode] [varchar](50) NULL,
	[DestinationAirportCityName] [varchar](100) NULL,
	[DestinationAirportCountryName] [varchar](100) NULL,
	[BookingBusinessUnitID] [bigint] NULL,
	[BillingBusinessUnitID] [bigint] NULL,
	[BillingConsultantID] [bigint] NULL,
	[BookingConsultantID] [bigint] NULL,
	[SystemName] [varchar](50) NULL,
	[FileDate] [date] NULL,
	[LastUpdate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_fltTickets_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_fltTickets_BIRowID] ON [dbo].[fltTickets]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_fltTickets_DocumentNo]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_fltTickets_DocumentNo] ON [dbo].[fltTickets]
(
	[DocumentNumber] ASC,
	[PNRNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_fltTickets_IssueDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_fltTickets_IssueDate] ON [dbo].[fltTickets]
(
	[IssueDate] ASC,
	[TicketType] ASC,
	[RefundedDate] ASC,
	[DocumentType] ASC,
	[AlphaCode] ASC,
	[Domain] ASC,
	[TravelType] ASC
)
INCLUDE([DocumentNumber],[OutletKey],[FirstFlightDate],[TotalDuration],[OriginAirportCountryName],[DestinationAirportCountryName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
