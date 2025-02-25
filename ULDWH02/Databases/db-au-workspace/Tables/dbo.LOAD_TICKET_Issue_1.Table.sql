USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[LOAD_TICKET_Issue_1]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOAD_TICKET_Issue_1](
	[Local_Issue_Date] [varchar](500) NULL,
	[PNR_Number] [varchar](500) NULL,
	[Document_Number] [varchar](500) NULL,
	[Refunded_Date] [varchar](500) NULL,
	[Document_Type] [varchar](500) NULL,
	[TicketType] [varchar](500) NULL,
	[Adult_Child_Indicator] [varchar](500) NULL,
	[Number_of_Nights_at_Total_Journey] [varchar](500) NULL,
	[Number_of_Nights_at_Destination] [varchar](500) NULL,
	[Issuing_IATA_Number] [varchar](500) NULL,
	[Issuing_IATA_Code] [varchar](500) NULL,
	[Local_First_Flight_Date] [varchar](500) NULL,
	[Journey_Type] [varchar](500) NULL,
	[Travel_Type] [varchar](500) NULL,
	[Airline_Code] [varchar](500) NULL,
	[Primary_Class] [varchar](500) NULL,
	[Multi_Class_Indicator] [varchar](500) NULL,
	[Routing_Description] [varchar](500) NULL,
	[Origin_Airport_Code] [varchar](500) NULL,
	[Destination_Airport_Code] [varchar](500) NULL,
	[Number_of_Sectors] [varchar](500) NULL,
	[T3_Code] [varchar](500) NULL,
	[DimBookingCurrentBusinessUnitId] [varchar](500) NULL,
	[BillingCurrentBusinessUnitId] [varchar](500) NULL,
	[DimBillingConsultantId] [varchar](500) NULL,
	[DimBookingConsultantId] [varchar](500) NULL,
	[System_Name] [varchar](500) NULL
) ON [PRIMARY]
GO
