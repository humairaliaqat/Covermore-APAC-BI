USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssentitytable_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssentitytable_audtc](
	[kentitytableid] [int] NOT NULL,
	[entitytype] [nvarchar](100) NOT NULL,
	[tablename] [nvarchar](100) NOT NULL,
	[primkeyfield] [nvarchar](100) NOT NULL,
	[primkeyfield2] [nvarchar](100) NULL
) ON [PRIMARY]
GO
