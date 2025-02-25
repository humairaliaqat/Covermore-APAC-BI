USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[pnpCartItemsWorker]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pnpCartItemsWorker](
	[ServiceFileSK] [int] NOT NULL,
	[ServiceFileID] [varchar](50) NULL,
	[StartDatetime] [datetime2](7) NULL,
	[EndDatetime] [datetime2](7) NULL,
	[ServiceEventActivitySK] [int] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Quantity] [numeric](10, 2) NULL,
	[UnitOfMeasurementIsName] [nvarchar](10) NULL,
	[CalculatedHour] [numeric](18, 6) NULL,
	[DurationHour] [numeric](14, 4) NULL,
	[Invoiced] [money] NOT NULL,
	[Paid] [money] NOT NULL,
	[Status] [nvarchar](25) NULL,
	[IndividualID] [varchar](50) NULL,
	[Individual] [nvarchar](101) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[AddressLine1] [nvarchar](60) NULL,
	[Postcode] [nvarchar](12) NULL,
	[City] [nvarchar](20) NULL,
	[RefID] [varchar](100) NULL,
	[UserID] [varchar](50) NULL,
	[Worker] [nvarchar](201) NULL,
	[ResourceType] [nvarchar](50) NULL,
	[DerivedRole] [nvarchar](50) NULL
) ON [PRIMARY]
GO
