USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_State]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_State](
	[State_Code] [varchar](50) NOT NULL,
	[State_Desc] [varchar](200) NULL,
	[Parent_State_Code] [varchar](50) NOT NULL,
	[Parent_State_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
