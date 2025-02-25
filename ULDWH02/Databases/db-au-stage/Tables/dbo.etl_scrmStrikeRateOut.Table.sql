USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmStrikeRateOut]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmStrikeRateOut](
	[UniqueIdentifier] [nvarchar](27) NOT NULL,
	[Month] [datetime] NULL,
	[StrikeRate] [numeric](6, 4) NULL,
	[LoadDate] [datetime] NOT NULL,
	[UpdateDate] [int] NULL
) ON [PRIMARY]
GO
