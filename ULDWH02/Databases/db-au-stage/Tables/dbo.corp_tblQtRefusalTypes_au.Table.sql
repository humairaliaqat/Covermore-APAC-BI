USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblQtRefusalTypes_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblQtRefusalTypes_au](
	[RefusalTypeID] [int] NOT NULL,
	[Reason] [varchar](50) NULL
) ON [PRIMARY]
GO
