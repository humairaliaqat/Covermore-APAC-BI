USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Accounts]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Accounts](
	[Parent_Account_Code] [varchar](50) NULL,
	[Child_Account_Code] [varchar](50) NOT NULL,
	[Child_Account_Desc] [varchar](200) NULL,
	[Account_Hierarchy_Type] [varchar](200) NOT NULL,
	[Account_Operator] [varchar](50) NOT NULL,
	[Account_Order] [int] NOT NULL,
	[Account_Category] [varchar](50) NULL
) ON [PRIMARY]
GO
