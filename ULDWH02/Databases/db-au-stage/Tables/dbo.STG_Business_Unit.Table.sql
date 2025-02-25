USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Business_Unit]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Business_Unit](
	[Business_Unit_Code] [varchar](50) NOT NULL,
	[Business_Unit_Desc] [varchar](200) NULL,
	[Currency_Code] [varchar](50) NOT NULL,
	[Source_System_Code] [varchar](50) NULL,
	[Domain_ID] [varchar](50) NULL,
	[Parent_Business_Unit_Code] [varchar](50) NULL,
	[Country_Code] [varchar](50) NOT NULL,
	[Country_Desc] [varchar](200) NULL,
	[Region_Code] [varchar](50) NOT NULL,
	[Region_Desc] [varchar](200) NULL,
	[Type_of_Entity_Code] [varchar](50) NOT NULL,
	[Type_of_Entity_Desc] [varchar](200) NULL,
	[Type_of_Business_Code] [varchar](50) NOT NULL,
	[Type_of_Business_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
