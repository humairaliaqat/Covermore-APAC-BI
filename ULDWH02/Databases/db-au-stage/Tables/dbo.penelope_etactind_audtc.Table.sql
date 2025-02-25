USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_etactind_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_etactind_audtc](
	[kactid] [int] NOT NULL,
	[luaindtypeid] [int] NOT NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[aindsecure] [varchar](5) NOT NULL,
	[aindmemrestrict] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
