USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwDesignations]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwDesignations](
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[DesignationID] [numeric](18, 0) NULL,
	[Designation] [varchar](50) NULL,
	[SeqNo] [numeric](18, 0) NULL,
	[IncentiveStructureAID] [numeric](18, 0) NULL,
	[IncentiveStuctureBID] [numeric](18, 0) NULL,
	[EmployeeIncentiveStructureCPercent] [numeric](18, 2) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
