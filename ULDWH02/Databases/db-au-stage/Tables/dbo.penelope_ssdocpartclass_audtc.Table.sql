USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssdocpartclass_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssdocpartclass_audtc](
	[kdocpartclassid] [int] NOT NULL,
	[docpartclass] [nvarchar](30) NOT NULL,
	[docpartlevel] [int] NOT NULL
) ON [PRIMARY]
GO
