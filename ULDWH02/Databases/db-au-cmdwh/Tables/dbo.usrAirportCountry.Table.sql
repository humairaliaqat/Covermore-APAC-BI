USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrAirportCountry]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrAirportCountry](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Airport_Code] [varchar](50) NULL,
	[Airport_City_Name] [varchar](50) NULL,
	[Airport_Country_Name] [varchar](50) NULL,
	[Airport_Area_Continent] [varchar](50) NULL,
	[PrimaryCountry] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[usrAirportCountry]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[usrAirportCountry]
(
	[Airport_Code] ASC
)
INCLUDE([Airport_City_Name],[Airport_Country_Name],[Airport_Area_Continent],[PrimaryCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
