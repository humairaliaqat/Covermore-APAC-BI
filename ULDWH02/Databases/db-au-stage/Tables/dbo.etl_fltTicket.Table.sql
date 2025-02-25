USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_fltTicket]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_fltTicket](
	[Local_Issue_Date] [varchar](100) NULL,
	[PNR_Number] [varchar](100) NULL,
	[Document_Number] [varchar](100) NULL,
	[Refunded_Date] [varchar](100) NULL,
	[Document_Type] [varchar](100) NULL,
	[TicketType] [varchar](100) NULL,
	[Adult_Child_Indicator] [varchar](100) NULL,
	[Number_of_Nights_at_Total_Journey] [varchar](100) NULL,
	[Number_of_Nights_at_Destination] [varchar](100) NULL,
	[Issuing_IATA_Number] [varchar](100) NULL,
	[Issuing_IATA_Code] [varchar](100) NULL,
	[Local_First_Flight_Date] [varchar](100) NULL,
	[Journey_Type] [varchar](100) NULL,
	[Travel_Type] [varchar](100) NULL,
	[Airline_Code] [varchar](100) NULL,
	[Primary_Class] [varchar](100) NULL,
	[Multi_Class_Indicator] [varchar](100) NULL,
	[Routing_Description] [varchar](max) NULL,
	[Origin_Airport_Code] [varchar](100) NULL,
	[Destination_Airport_Code] [varchar](100) NULL,
	[Number_of_Sectors] [varchar](100) NULL,
	[T3_Code] [varchar](100) NULL,
	[DimBookingCurrentBusinessUnitId] [varchar](100) NULL,
	[DimBillingBusinessUnitId] [varchar](100) NULL,
	[DimBillingConsultantId] [varchar](100) NULL,
	[DimBookingConsultantId] [varchar](100) NULL,
	[System_Name] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
