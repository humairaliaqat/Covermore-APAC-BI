USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[LOAD_TICKET_Issuecheck]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOAD_TICKET_Issuecheck](
	[Local_Issue_Date] [varchar](50) NULL,
	[PNR_Number] [varchar](50) NULL,
	[Document_Number] [varchar](50) NULL,
	[Refunded_Date] [varchar](50) NULL,
	[Document_Type] [varchar](50) NULL,
	[TicketType] [varchar](50) NULL,
	[Adult_Child_Indicator] [varchar](50) NULL,
	[Number_of_Nights_at_Total_Journey] [varchar](50) NULL,
	[Number_of_Nights_at_Destination] [varchar](50) NULL,
	[Issuing_IATA_Number] [varchar](50) NULL,
	[Issuing_IATA_Code] [varchar](50) NULL,
	[Local_First_Flight_Date] [varchar](50) NULL,
	[Journey_Type] [varchar](50) NULL,
	[Travel_Type] [varchar](50) NULL,
	[Airline_Code] [varchar](50) NULL,
	[Primary_Class] [varchar](50) NULL,
	[Multi_Class_Indicator] [varchar](50) NULL,
	[Routing_Description] [varchar](50) NULL,
	[Origin_Airport_Code] [varchar](50) NULL,
	[Destination_Airport_Code] [varchar](50) NULL,
	[Number_of_Sectors] [varchar](50) NULL,
	[T3_Code] [varchar](50) NULL,
	[DimBookingCurrentBusinessUnitId] [varchar](50) NULL,
	[BillingCurrentBusinessUnitId] [varchar](50) NULL,
	[DimBillingConsultantId] [varchar](50) NULL,
	[DimBookingConsultantId] [varchar](50) NULL,
	[System_Name] [varchar](50) NULL
) ON [PRIMARY]
GO
