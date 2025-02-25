USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransactionPromo_deleted_records_dated20191223]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransactionPromo_deleted_records_dated20191223](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PromoKey] [varchar](41) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PromoID] [int] NULL,
	[PromoCode] [nvarchar](10) NULL,
	[PromoName] [nvarchar](250) NULL,
	[PromoType] [nvarchar](50) NULL,
	[Discount] [numeric](10, 4) NULL,
	[IsApplied] [bit] NULL,
	[ApplyOrder] [int] NULL,
	[GoBelowNet] [bit] NULL
) ON [PRIMARY]
GO
