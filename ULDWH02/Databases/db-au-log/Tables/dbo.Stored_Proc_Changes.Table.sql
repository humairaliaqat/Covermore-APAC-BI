USE [db-au-log]
GO
/****** Object:  Table [dbo].[Stored_Proc_Changes]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stored_Proc_Changes](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateTime] [datetime] NULL,
	[LoginName] [nvarchar](255) NULL,
	[EventType] [varchar](100) NULL,
	[ServerName] [nvarchar](50) NULL,
	[DatabaseName] [nvarchar](50) NULL,
	[SchemaName] [nvarchar](50) NULL,
	[ObjectName] [nvarchar](255) NULL,
	[TSQLCommand] [nvarchar](max) NULL,
	[UserName] [nvarchar](255) NULL,
	[HostName] [varchar](50) NULL,
	[IPAddress] [varchar](32) NULL,
	[Rollback] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stored_Proc_Changes] ADD  DEFAULT (getdate()) FOR [DateTime]
GO
