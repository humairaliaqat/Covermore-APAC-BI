USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\dmurray].[pnpCartItems]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\dmurray].[pnpCartItems](
	[ServiceFileSK] [int] NOT NULL,
	[ServiceFileID] [varchar](50) NULL,
	[Service] [nvarchar](80) NULL,
	[Funder] [nvarchar](250) NULL,
	[PolicyType] [nvarchar](25) NULL,
	[ServiceEventSK] [int] NOT NULL,
	[ServiceEventID] [varchar](50) NULL,
	[StartDatetime] [datetime2](7) NULL,
	[EndDatetime] [datetime2](7) NULL,
	[ServiceEventActivitySK] [int] NOT NULL,
	[ServiceEventActivityID] [varchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[Quantity] [numeric](10, 2) NULL,
	[UnitOfMeasurementIsName] [nvarchar](10) NULL,
	[CalculatedHour] [numeric](18, 6) NULL,
	[DurationHour] [numeric](14, 4) NULL,
	[PaidHour] [money] NOT NULL,
	[Invoiced] [money] NOT NULL,
	[Payable] [numeric](38, 10) NOT NULL,
	[Paid] [money] NOT NULL,
	[PayableValue] [numeric](38, 10) NULL,
	[PaidWorker] [int] NOT NULL,
	[Status] [nvarchar](25) NULL,
	[IndividualID] [varchar](50) NULL,
	[Individual] [nvarchar](101) NULL,
	[DateOfBirth] [datetime2](7) NULL,
	[AddressLine1] [nvarchar](60) NULL,
	[Postcode] [nvarchar](12) NULL,
	[City] [nvarchar](20) NULL,
	[PrimaryWorkerID] [varchar](50) NULL,
	[PrimaryWorker] [nvarchar](201) NULL,
	[DerivedPrimaryRole] [nvarchar](50) NULL,
	[Role] [nvarchar](50) NULL
) ON [PRIMARY]
GO
