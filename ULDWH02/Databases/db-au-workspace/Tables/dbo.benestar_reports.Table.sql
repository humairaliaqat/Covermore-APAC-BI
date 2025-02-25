USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[benestar_reports]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[benestar_reports](
	[Start_Time] [datetime] NULL,
	[User_Name] [nvarchar](255) NULL,
	[Event_Type_Name] [nvarchar](255) NULL,
	[Object_ID] [varchar](64) NULL,
	[Object_Name] [nvarchar](255) NULL,
	[Object_Folder_Path] [nvarchar](255) NULL,
	[Top_Folder_Name] [nvarchar](255) NULL,
	[Object_Type_Name] [nvarchar](255) NULL
) ON [PRIMARY]
GO
