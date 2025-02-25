USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Tmp_KLCatas]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Tmp_KLCatas](
	[KC_CODE] [varchar](3) NOT NULL,
	[KCSHORT] [varchar](20) NULL,
	[KCLONG] [nvarchar](60) NULL,
	[KLDOMAINID] [int] NOT NULL,
	[DomainId] [int] NOT NULL,
	[DomainName] [nvarchar](50) NULL,
	[CurrencySymbol] [nvarchar](10) NULL,
	[Underwriter] [nvarchar](50) NULL,
	[CurrencyCode] [char](3) NULL,
	[CountryCode] [varchar](2) NOT NULL,
	[TimeZoneCode] [varchar](50) NOT NULL,
	[CultureCode] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_KLCatas_KC_Code]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_KLCatas_KC_Code] ON [cng].[Tmp_KLCatas]
(
	[KC_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
