USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Project_Codes]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Project_Codes](
	[Project_Code] [varchar](50) NOT NULL,
	[Project_Desc] [varchar](200) NULL,
	[Project_Owner_Code] [varchar](50) NOT NULL,
	[Project_Owner_Desc] [varchar](200) NULL,
	[Parent_Project_Code] [varchar](50) NOT NULL,
	[Parent_Project_Code_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
