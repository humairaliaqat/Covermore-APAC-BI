USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblRiskReasonLevel_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblRiskReasonLevel_aucm](
	[RISKREASON_ID] [int] NOT NULL,
	[RISKLEVEL_ID] [int] NOT NULL,
	[RISKREASONLEVEL_ID] [int] NOT NULL
) ON [PRIMARY]
GO
