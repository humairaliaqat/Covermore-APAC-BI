USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTNSW_mccurtdt_audtc]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSW_mccurtdt_audtc](
	[timestamp] [timestamp] NOT NULL,
	[from_currency] [varchar](8) NOT NULL,
	[to_currency] [varchar](8) NOT NULL,
	[convert_date] [int] NOT NULL,
	[buy_rate] [float] NOT NULL,
	[sell_rate] [float] NOT NULL,
	[budget_flag] [smallint] NOT NULL,
	[in_use_flag] [smallint] NOT NULL,
	[rate_type] [varchar](8) NULL,
	[valid_for_days] [int] NOT NULL,
	[ddid] [varchar](32) NULL,
	[ConvertedDate] [datetime] NULL
) ON [PRIMARY]
GO
