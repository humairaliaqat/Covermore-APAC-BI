USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_addpart_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_addpart_audtc](
	[kpartid] [int] NOT NULL,
	[kpartiditem] [int] NOT NULL,
	[orderseq] [int] NOT NULL
) ON [PRIMARY]
GO
