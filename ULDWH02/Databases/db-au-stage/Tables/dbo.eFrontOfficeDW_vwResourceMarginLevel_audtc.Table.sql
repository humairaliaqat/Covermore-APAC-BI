USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_vwResourceMarginLevel_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_vwResourceMarginLevel_audtc](
	[resourceCode] [nvarchar](50) NOT NULL,
	[resourceName] [nvarchar](50) NULL,
	[MarginLevel] [int] NULL
) ON [PRIMARY]
GO
