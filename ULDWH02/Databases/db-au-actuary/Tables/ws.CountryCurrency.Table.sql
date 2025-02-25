USE [db-au-actuary]
GO
/****** Object:  Table [ws].[CountryCurrency]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[CountryCurrency](
	[BIRowID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CountryName] [nvarchar](400) NULL,
	[CountryISO2Code] [varchar](5) NULL,
	[CountryISO3Code] [varchar](5) NULL,
	[CurrencyName] [nvarchar](400) NULL,
	[CurrencyCode] [varchar](5) NULL,
 CONSTRAINT [PK_CountryCurrency] PRIMARY KEY NONCLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [ws].[CountryCurrency]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [iso3]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [iso3] ON [ws].[CountryCurrency]
(
	[CountryISO3Code] ASC
)
INCLUDE([CurrencyCode],[CurrencyName],[CountryName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
