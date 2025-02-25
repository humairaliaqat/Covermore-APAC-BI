USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblMiscCodes_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblMiscCodes_au](
	[MiscID] [int] NOT NULL,
	[MiscCode] [varchar](50) NULL,
	[MiscDesc] [varchar](50) NULL,
	[MiscComments] [varchar](200) NULL
) ON [PRIMARY]
GO
