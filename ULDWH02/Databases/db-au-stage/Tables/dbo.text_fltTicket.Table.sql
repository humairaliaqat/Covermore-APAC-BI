USE [db-au-stage]
GO
/****** Object:  Table [dbo].[text_fltTicket]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[text_fltTicket](
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
	[Routing_Description] [varchar](max) NULL,
	[Origin_Airport_Code] [varchar](50) NULL,
	[Destination_Airport_Code] [varchar](50) NULL,
	[Number_of_Sectors] [varchar](50) NULL,
	[T3_Code] [varchar](50) NULL,
	[Source_File_ID] [int] NULL,
	[Load_Date] [datetime] NULL,
	[DimBookingCurrentBusinessUnitId] [varchar](50) NULL,
	[DimBillingBusinessUnitId] [varchar](50) NULL,
	[DimBillingConsultantId] [varchar](50) NULL,
	[DimBookingConsultantId] [varchar](50) NULL,
	[System_Name] [varchar](50) NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_fltTicket_SrcFileID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_fltTicket_SrcFileID] ON [dbo].[text_fltTicket]
(
	[Source_File_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [src]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [src] ON [dbo].[text_fltTicket]
(
	[Source_File_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
