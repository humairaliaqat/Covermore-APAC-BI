USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssdocdataqueryspeckey_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssdocdataqueryspeckey_audtc](
	[kdocdataqueryspeckeyid] [int] NOT NULL,
	[kdocdataquerykeyid] [int] NOT NULL,
	[kdocdataqueryapplicid] [int] NOT NULL
) ON [PRIMARY]
GO
