USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_addpvassign_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_addpvassign_audtc](
	[kdocpartflattreeid] [int] NOT NULL,
	[kcomdocid] [int] NOT NULL,
	[delpropagate] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
