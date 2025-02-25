USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblDomain_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblDomain_uscm](
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
/****** Object:  Index [idx_penguin_tblDomain_uscm_DomainID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblDomain_uscm_DomainID] ON [dbo].[penguin_tblDomain_uscm]
(
	[DomainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
