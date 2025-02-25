USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ItineraryDetail_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ItineraryDetail_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[AdditionalInformation_c] [varchar](255) NULL,
	[Airline_c] [varchar](25) NULL,
	[AirportCode_c] [varchar](25) NULL,
	[BookedBy_c] [nvarchar](50) NULL,
	[CityFrom_c] [varchar](50) NULL,
	[CityTo_c] [varchar](50) NULL,
	[EndDate_c] [date] NULL,
	[Itinerary_c] [varchar](25) NULL,
	[MethodOfTravel_c] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NULL,
	[Provider_c] [varchar](25) NULL,
	[Remarks_c] [varchar](255) NULL,
	[Seating_c] [nvarchar](50) NULL,
	[Services_c] [nvarchar](50) NULL,
	[StartDate_c] [date] NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_ItineraryDetail_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_ItineraryDetail_Hist] ON [atlas].[ItineraryDetail_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
