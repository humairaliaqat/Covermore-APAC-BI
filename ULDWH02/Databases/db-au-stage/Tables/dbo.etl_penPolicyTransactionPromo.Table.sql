USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyTransactionPromo]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyTransactionPromo](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PromoKey] [varchar](71) NULL,
	[PolicyTransactionKey] [varchar](71) NULL,
	[PolicyNumber] [varchar](25) NULL,
	[PromoID] [int] NOT NULL,
	[PromoCode] [varchar](50) NULL,
	[PromoName] [nvarchar](250) NOT NULL,
	[PromoType] [nvarchar](200) NULL,
	[Discount] [numeric](10, 4) NOT NULL,
	[IsApplied] [bit] NOT NULL,
	[ApplyOrder] [smallint] NOT NULL,
	[GoBelowNet] [bit] NOT NULL
) ON [PRIMARY]
GO
