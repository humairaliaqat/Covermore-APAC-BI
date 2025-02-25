USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAirport]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAirport](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AirportKey] [varchar](41) NULL,
	[AirportID] [int] NULL,
	[CountryID] [int] NULL,
	[AirportCode] [nvarchar](50) NULL,
	[AirportName] [nvarchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAirport_AirportKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penAirport_AirportKey] ON [dbo].[penAirport]
(
	[AirportKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAirport_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penAirport_CountryKey] ON [dbo].[penAirport]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
