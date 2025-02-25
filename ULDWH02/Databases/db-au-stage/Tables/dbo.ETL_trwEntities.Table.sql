USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwEntities]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwEntities](
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[EntityID] [numeric](18, 0) NULL,
	[EntityTypeID] [numeric](18, 0) NULL,
	[Name] [varchar](500) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
