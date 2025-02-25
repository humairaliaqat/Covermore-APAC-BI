USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCRemovedServiceEventActivities]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCRemovedServiceEventActivities](
	[ServiceEventSK] [int] NOT NULL,
	[ServiceEventID] [varchar](50) NULL,
	[ServiceFileID] [varchar](50) NULL,
	[CaseID] [varchar](50) NULL,
	[ItemID] [varchar](50) NULL,
	[FunderID] [varchar](50) NULL,
	[SiteID] [varchar](50) NULL,
	[ServiceEventActivitySK] [int] NOT NULL,
	[ServiceEventActivityID] [varchar](50) NULL,
	[StartDateTime] [datetime2](7) NULL,
	[EndDateTime] [datetime2](7) NULL,
	[Category] [nvarchar](25) NULL,
	[NonScheduled] [varchar](5) NULL,
	[ActivityType] [nvarchar](25) NULL,
	[ActivityTypeDescription] [nvarchar](25) NULL,
	[Status] [nvarchar](25) NULL,
	[NameShort] [nvarchar](25) NULL,
	[Name] [nvarchar](40) NULL,
	[PolicyID] [varchar](50) NULL,
	[Quantity] [numeric](17, 6) NULL,
	[UnitOfMeasurementIsSchedule] [nvarchar](30) NULL,
	[UnitofMeasurementIsName] [nvarchar](10) NULL,
	[UnitOfMeasurementIsEquivalent] [numeric](10, 2) NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[DeletedDatetime] [datetime2](7) NULL,
	[Payable] [bit] NULL,
	[CartItemBy] [varchar](50) NULL,
	[IsPublicPolicy] [bit] NULL,
	[ItemClass] [nchar](25) NULL
) ON [PRIMARY]
GO
