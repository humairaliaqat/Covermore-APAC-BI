USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_Turnover]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_Turnover](
	[Division] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Month] [varchar](50) NULL,
	[TurnoverPct] [float] NULL
) ON [PRIMARY]
GO
