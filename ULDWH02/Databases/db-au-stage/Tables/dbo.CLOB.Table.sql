USE [db-au-stage]
GO
/****** Object:  Table [dbo].[CLOB]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CLOB](
	[string] [varchar](max) NULL,
	[xmlstring] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
