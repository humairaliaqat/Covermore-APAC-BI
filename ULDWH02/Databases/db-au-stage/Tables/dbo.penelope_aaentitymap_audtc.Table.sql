USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_aaentitymap_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_aaentitymap_audtc](
	[kentitymapid] [int] NOT NULL,
	[kmaptypeid] [int] NOT NULL,
	[primkey1] [int] NOT NULL,
	[primkey2] [int] NULL,
	[assockey1] [int] NOT NULL,
	[assockey2] [int] NULL
) ON [PRIMARY]
GO
