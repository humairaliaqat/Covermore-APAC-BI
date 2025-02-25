USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lutaskpri_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lutaskpri_audtc](
	[lutaskpriid] [int] NOT NULL,
	[taskpriority] [nvarchar](10) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
