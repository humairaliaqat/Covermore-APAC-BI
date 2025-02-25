USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Joint_Venture]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Joint_Venture](
	[Type_of_JV_Code] [varchar](50) NOT NULL,
	[Type_of_JV_Desc] [varchar](200) NULL,
	[JV_Code] [varchar](50) NOT NULL,
	[JV_Desc] [varchar](200) NULL,
	[Distribution_Type_Code] [varchar](50) NOT NULL,
	[Distribution_Type_Desc] [varchar](200) NULL,
	[Super_Group_Code] [varchar](50) NOT NULL,
	[Super_Group_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
