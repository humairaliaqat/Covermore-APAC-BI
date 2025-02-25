USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_State_Sales_Manager]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_State_Sales_Manager](
	[BDM_Code] [varchar](50) NOT NULL,
	[BDM_Name] [varchar](200) NULL,
	[State_Sales_Manager_ID] [varchar](50) NULL,
	[State_Sales_Manager_Name] [varchar](200) NULL
) ON [PRIMARY]
GO
