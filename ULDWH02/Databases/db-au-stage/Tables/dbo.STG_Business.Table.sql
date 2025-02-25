USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Business]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Business](
	[Business_Code] [varchar](50) NULL,
	[Business_Desc] [varchar](200) NULL,
	[Last_Change_Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
