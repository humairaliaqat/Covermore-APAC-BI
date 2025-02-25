USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_aecactmem_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_aecactmem_audtc](
	[kbookitemid] [int] NOT NULL,
	[kactid] [int] NOT NULL,
	[amemshow] [varchar](5) NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[amemcode] [int] NULL,
	[kexempttypeid] [int] NULL
) ON [PRIMARY]
GO
