USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_case_funder_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_case_funder_audtc](
	[kcaseid] [int] NOT NULL,
	[kfunderid] [int] NOT NULL,
	[kfunderdeptid] [int] NULL
) ON [PRIMARY]
GO
