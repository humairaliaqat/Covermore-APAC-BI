USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssbilltype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssbilltype_audtc](
	[kbilltypeid] [int] NOT NULL,
	[billtype] [nvarchar](255) NOT NULL
) ON [PRIMARY]
GO
