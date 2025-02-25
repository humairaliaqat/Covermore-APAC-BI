USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrDomain]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrDomain](
	[DomainId] [int] NOT NULL,
	[DomainName] [nvarchar](50) NULL,
	[CurrencySymbol] [nvarchar](10) NULL,
	[Underwriter] [nvarchar](50) NULL,
	[CalculationRuleId] [int] NULL,
	[AgeCalcFromDeparture] [bit] NULL,
	[AddTripDays] [int] NULL,
	[PaymentUrlID] [int] NULL,
	[ShowAddOnGroup] [bit] NOT NULL,
	[DaysInAdvance] [int] NULL,
	[StartDateLimiter] [datetime] NULL,
	[EndDateLimiter] [datetime] NULL,
	[BonusDaysLimiter] [int] NULL,
	[CurrencyCode] [char](3) NULL,
	[CountryCode] [varchar](2) NOT NULL,
	[TimeZoneCode] [varchar](50) NOT NULL,
	[AgeCompareLimit] [int] NOT NULL,
	[CultureCode] [nvarchar](20) NOT NULL,
	[IsDefault] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrDomain_DomainId]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_usrDomain_DomainId] ON [dbo].[usrDomain]
(
	[DomainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
