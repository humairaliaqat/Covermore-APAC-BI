USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_EVENT]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_EVENT](
	[Event_ID] [varchar](64) NOT NULL,
	[Cluster_ID] [varchar](64) NULL,
	[Server_ID] [varchar](64) NULL,
	[Service_Type_ID] [varchar](64) NULL,
	[Client_Type_ID] [varchar](64) NULL,
	[Start_Time] [datetime] NULL,
	[Duration_ms] [int] NULL,
	[Added_To_ADS] [datetime] NULL,
	[User_ID] [varchar](64) NULL,
	[User_Name] [nvarchar](255) NULL,
	[Session_ID] [varchar](64) NULL,
	[Action_ID] [varchar](64) NULL,
	[Sequence_In_Action] [int] NULL,
	[Event_Type_ID] [int] NULL,
	[Status_ID] [int] NULL,
	[Object_ID] [varchar](64) NULL,
	[Object_Name] [nvarchar](255) NULL,
	[Object_Type_ID] [varchar](64) NULL,
	[Object_Folder_Path] [nvarchar](255) NULL,
	[Top_Folder_Name] [nvarchar](255) NULL,
	[Top_Folder_ID] [varchar](64) NULL,
	[Folder_ID] [varchar](64) NULL
) ON [PRIMARY]
GO
