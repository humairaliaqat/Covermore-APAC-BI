USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_Product]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_Product](
	[CountryKey] [nvarchar](255) NULL,
	[CompanyKey] [nvarchar](255) NULL,
	[ProductKey] [nvarchar](255) NULL,
	[ProductCode] [nvarchar](255) NULL,
	[ProductName] [nvarchar](255) NULL,
	[ProductDisplayName] [nvarchar](255) NULL,
	[DomainID] [float] NULL,
	[PlanName] [nvarchar](255) NULL,
	[ProductType] [nvarchar](255) NULL,
	[ProductGroup] [nvarchar](255) NULL,
	[PolicyType] [nvarchar](255) NULL,
	[ProductClassification] [nvarchar](255) NULL,
	[PlanType] [nvarchar](255) NULL,
	[TripType] [nvarchar](255) NULL,
	[FinanceProductCode] [nvarchar](255) NULL,
	[FinanceProductCodeOld] [nvarchar](255) NULL
) ON [PRIMARY]
GO
