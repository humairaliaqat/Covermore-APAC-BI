USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPolicyCancellationRequests]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPolicyCancellationRequests](
	[PolicyCancellationRequestID] [numeric](18, 0) NULL,
	[PolicyID] [numeric](18, 0) NULL,
	[RequesterEntityID] [numeric](18, 0) NULL,
	[DocumentFile] [varchar](500) NULL,
	[Reason] [varchar](1000) NULL,
	[Charges] [numeric](18, 2) NULL,
	[Remarks] [varchar](1000) NULL,
	[ProcessedByEntityID] [numeric](18, 0) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
