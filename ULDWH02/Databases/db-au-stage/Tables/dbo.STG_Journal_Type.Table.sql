USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Journal_Type]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Journal_Type](
	[Journal_Type_Code] [varchar](50) NOT NULL,
	[Journal_Type_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
