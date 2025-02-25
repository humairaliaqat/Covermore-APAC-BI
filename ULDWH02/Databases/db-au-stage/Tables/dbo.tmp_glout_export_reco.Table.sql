USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tmp_glout_export_reco]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_glout_export_reco](
	[Unique Key] [varchar](521) NULL,
	[Business_Unit_Code] [varchar](50) NULL,
	[JV_Client_Code] [varchar](50) NULL,
	[Channel_Code] [varchar](50) NOT NULL,
	[Department_Code] [varchar](50) NOT NULL,
	[Product_Code] [varchar](50) NOT NULL,
	[State_Code] [varchar](50) NOT NULL,
	[Project_Code] [varchar](50) NULL,
	[Account_Code] [varchar](50) NOT NULL,
	[Scenario] [varchar](50) NULL,
	[Journal_Type] [varchar](3) NOT NULL,
	[Source_Business_Unit_Code] [varchar](50) NOT NULL,
	[Period] [varchar](10) NULL,
	[Month] [nvarchar](34) NULL,
	[GL_Amount] [numeric](38, 3) NULL,
	[BU_JV] [varchar](61) NULL,
	[BU_Dept] [varchar](61) NULL,
	[BU_Dept_JV] [varchar](92) NULL
) ON [PRIMARY]
GO
