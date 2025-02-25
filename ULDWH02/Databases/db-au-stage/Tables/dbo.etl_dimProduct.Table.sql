USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimProduct]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimProduct](
	[Country] [nvarchar](20) NOT NULL,
	[ProductKey] [nvarchar](1566) NULL,
	[ProductCode] [nvarchar](255) NOT NULL,
	[ProductName] [nvarchar](255) NOT NULL,
	[ProductPlan] [nvarchar](767) NULL,
	[ProductType] [nvarchar](255) NOT NULL,
	[ProductGroup] [nvarchar](255) NOT NULL,
	[PolicyType] [nvarchar](255) NOT NULL,
	[ProductClassification] [nvarchar](255) NOT NULL,
	[PlanType] [nvarchar](255) NOT NULL,
	[TripType] [nvarchar](255) NOT NULL,
	[FinanceProductCode] [nvarchar](255) NOT NULL,
	[FinanceProductCodeOld] [nvarchar](255) NOT NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
