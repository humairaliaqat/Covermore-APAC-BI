USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_DISORDER_SUBTYPE_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_DISORDER_SUBTYPE_aucm](
	[SUBTYPEID] [varchar](2) NOT NULL,
	[DISORDERID] [varchar](2) NOT NULL,
	[SUBTYPEDESC] [nvarchar](100) NULL
) ON [PRIMARY]
GO
