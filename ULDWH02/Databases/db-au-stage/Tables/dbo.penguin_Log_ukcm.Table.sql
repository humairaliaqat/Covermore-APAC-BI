USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_Log_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_Log_ukcm](
	[Id] [bigint] NOT NULL,
	[LogActionId] [bigint] NOT NULL,
	[ObjectType] [varchar](50) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[Comment] [nvarchar](max) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[DeliveryStatus] [varchar](50) NULL,
	[LogData] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
