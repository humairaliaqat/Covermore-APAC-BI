USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Source]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Source](
	[Source_Code] [varchar](50) NOT NULL,
	[Source_Desc] [varchar](200) NULL,
	[Last_Change_Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
