USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtdocpartflattree_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtdocpartflattree_audtc](
	[kdocpartflattreeid] [int] NOT NULL,
	[kdocid] [int] NOT NULL,
	[kdocstagenameid] [int] NULL
) ON [PRIMARY]
GO
