USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lufahcsiareferredto_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lufahcsiareferredto_audtc](
	[kreferredtoid] [int] NOT NULL,
	[referredto] [ntext] NULL,
	[datefrom] [date] NOT NULL,
	[dateto] [date] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
