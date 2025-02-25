USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[penPolicyTransactionPromo_Imp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransactionPromo_Imp](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PromoKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PromoID] [int] NULL,
	[PromoCode] [nvarchar](40) NULL,
	[PromoName] [nvarchar](250) NULL,
	[PromoType] [nvarchar](50) NULL,
	[Discount] [numeric](10, 4) NULL,
	[IsApplied] [bit] NULL,
	[ApplyOrder] [int] NULL,
	[GoBelowNet] [bit] NULL,
	[ImpPromoID] [int] NULL,
	[ImpPromoCode] [varchar](200) NULL,
	[ImpPromoType] [varchar](200) NULL,
	[ImpDiscount] [varchar](200) NULL,
	[IsMember] [varchar](500) NULL,
	[PROMOCODE_Additional] [varchar](500) NULL
) ON [PRIMARY]
GO
