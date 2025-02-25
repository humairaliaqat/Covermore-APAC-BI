USE [db-au-actuary]
GO
/****** Object:  Table [ws].[~EMCGroupScore_bkp]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[~EMCGroupScore_bkp](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceSystem] [varchar](15) NULL,
	[SourceKey] [varchar](100) NULL,
	[Max EMC Score] [numeric](6, 2) NULL,
	[Total EMC Score] [numeric](6, 2) NULL,
	[Max EMC Score No Filter] [numeric](6, 2) NULL,
	[Total EMC Score No Filter] [numeric](6, 2) NULL
) ON [PRIMARY]
GO
