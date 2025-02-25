USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwAreas]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwAreas](
	[AreaID] [numeric](18, 0) NULL,
	[Name] [varchar](50) NULL,
	[RegionID] [numeric](18, 0) NULL,
	[ManagerEmployeeID] [numeric](18, 0) NULL,
	[EntityID] [numeric](18, 0) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY]
GO
