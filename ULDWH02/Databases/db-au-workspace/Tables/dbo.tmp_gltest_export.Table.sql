USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_gltest_export]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_gltest_export](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Unique Key] [varchar](500) NULL,
	[Business_Unit_Code] [varchar](50) NULL,
	[JV_Client_Code] [varchar](50) NULL,
	[Channel_Code] [varchar](50) NULL,
	[Department_Code] [varchar](50) NULL,
	[Product_Code] [varchar](50) NULL,
	[State_Code] [varchar](50) NULL,
	[Project_Code] [varchar](50) NULL,
	[Account_Code] [varchar](50) NULL,
	[Scenario] [varchar](50) NULL,
	[Journal_Type] [varchar](20) NULL,
	[Source_Business_Unit_Code] [varchar](50) NULL,
	[Period] [varchar](20) NULL,
	[Month] [varchar](50) NULL,
	[GL_Amount] [varchar](50) NULL,
	[BU_JV] [varchar](50) NULL,
	[BU_Dept] [varchar](50) NULL,
	[BU_Dept_JV] [varchar](50) NULL
) ON [PRIMARY]
GO
