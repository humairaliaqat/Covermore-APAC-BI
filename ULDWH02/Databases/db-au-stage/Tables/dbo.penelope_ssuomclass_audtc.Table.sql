USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssuomclass_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssuomclass_audtc](
	[kuomclassid] [int] NOT NULL,
	[uomclass] [ntext] NULL,
	[istime] [varchar](5) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
