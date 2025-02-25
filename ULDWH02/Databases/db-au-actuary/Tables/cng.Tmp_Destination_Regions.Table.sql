USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_Destination_Regions]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_Destination_Regions](
	[Country or Area] [nvarchar](255) NULL,
	[M49 Code] [float] NULL,
	[ISO-alpha2 Code] [nvarchar](255) NULL,
	[ISO-alpha3 Code] [nvarchar](255) NULL,
	[Intermediate Region Name] [nvarchar](255) NULL,
	[Intermediate Region Code] [float] NULL,
	[Sub-region Name] [nvarchar](255) NULL,
	[Sub-region Code] [float] NULL,
	[Region Name] [nvarchar](255) NULL,
	[Region Code] [float] NULL,
	[Global Name] [nvarchar](255) NULL,
	[Global Code] [float] NULL,
	[Least Developed Countries (LDC)] [nvarchar](255) NULL,
	[Land Locked Developing Countries (LLDC)] [nvarchar](255) NULL,
	[Small Island Developing States (SIDS)] [nvarchar](255) NULL,
	[Developed / Developing Countries] [nvarchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Destination_Regions_CountryOrArea]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_Destination_Regions_CountryOrArea] ON [cng].[Tmp_Destination_Regions]
(
	[Country or Area] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
