USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkFaceTime_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkFaceTime_au](
	[Id] [bigint] NOT NULL,
	[Work_Id] [uniqueidentifier] NULL,
	[Status_Id] [int] NOT NULL,
	[WorkActivity_Id] [uniqueidentifier] NULL,
	[Category3_Id] [int] NULL,
	[SessionUser] [nvarchar](100) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[GetNext] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[Launch] [bit] NOT NULL,
	[Activate] [bit] NOT NULL,
	[InitialWork_Id] [uniqueidentifier] NULL,
	[Event_Id] [int] NULL,
	[Detail] [nvarchar](200) NULL,
	[RootSession_Id] [bigint] NULL,
	[FaceTimeInSeconds] [int] NULL
) ON [PRIMARY]
GO
