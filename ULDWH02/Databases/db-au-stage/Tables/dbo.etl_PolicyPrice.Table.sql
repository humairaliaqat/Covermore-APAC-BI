USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_PolicyPrice]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_PolicyPrice](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyPriceKey] [varchar](41) NULL,
	[PolicyTransactionID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[ComponentID] [int] NOT NULL,
	[GrossPremium] [money] NULL,
	[BasePremium] [money] NOT NULL,
	[AdjustedNet] [money] NOT NULL,
	[Commission] [money] NOT NULL,
	[CommissionRate] [numeric](10, 9) NULL,
	[Discount] [money] NOT NULL,
	[DiscountRate] [numeric](12, 9) NULL,
	[BaseAdminFee] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[isPOSDiscount] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_main]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_main] ON [dbo].[etl_PolicyPrice]
(
	[CountryKey] ASC,
	[CompanyKey] ASC,
	[ComponentID] ASC,
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
