USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fltTickets_bkp24032021]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fltTickets_bkp24032021](
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
