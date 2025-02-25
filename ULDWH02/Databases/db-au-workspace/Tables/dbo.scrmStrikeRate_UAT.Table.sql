USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[scrmStrikeRate_UAT]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scrmStrikeRate_UAT](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[UniqueIdentifier] [varchar](50) NULL,
	[Month] [date] NULL,
	[StrikeRate] [numeric](6, 4) NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[isSynced] [nvarchar](1) NULL,
	[SyncedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
