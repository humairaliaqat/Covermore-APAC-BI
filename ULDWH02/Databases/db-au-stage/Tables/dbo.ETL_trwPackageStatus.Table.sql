USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPackageStatus]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPackageStatus](
	[PackageID] [int] NOT NULL,
	[PackageSubGroupID] [int] NOT NULL,
	[PackageName] [nvarchar](250) NULL,
	[PackageSubGroupName] [nvarchar](250) NULL,
	[PackageLoadType] [nvarchar](1) NULL,
	[PackageForceLoad] [nvarchar](1) NULL,
	[DeltaLoadStartDate] [datetime] NULL,
	[DeltaLoadToDate] [datetime] NULL,
	[LastRunStartDate] [datetime] NULL,
	[LastRunEndDate] [datetime] NULL,
	[LastRunStatus] [nvarchar](20) NULL,
	[LastRunDescription] [nvarchar](2000) NULL,
	[CurrentRunStartDate] [datetime] NULL,
	[CurrentRunEndDate] [datetime] NULL,
	[CurrentRunStatus] [nvarchar](20) NULL,
	[CurrentRunDescription] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
