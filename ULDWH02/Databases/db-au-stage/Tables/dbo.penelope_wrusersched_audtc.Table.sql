USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_wrusersched_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_wrusersched_audtc](
	[kuserschedid] [int] NOT NULL,
	[kuserid] [int] NOT NULL,
	[ludayid] [int] NOT NULL,
	[uschedin] [time](0) NOT NULL,
	[uschedout] [time](0) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[ksiteid] [int] NOT NULL,
	[kuseravailtypeid] [int] NOT NULL,
	[kusercalid] [int] NOT NULL
) ON [PRIMARY]
GO
