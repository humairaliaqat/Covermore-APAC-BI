USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTNSWDW_glPrd_audtc]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTNSWDW_glPrd_audtc](
	[timestamp] [binary](8) NULL,
	[period_type] [smallint] NULL,
	[period_description] [varchar](30) NULL,
	[period_start_date] [int] NULL,
	[period_end_date] [int] NULL,
	[initialized_flag] [smallint] NULL,
	[period_percentage] [float] NULL,
	[AUD_Average_Rate] [money] NULL,
	[AUD_Period_End_Rate] [money] NULL,
	[companyId] [int] NULL
) ON [PRIMARY]
GO
