USE [db-au-log]
GO
/****** Object:  Table [dbo].[OlapQueryLog]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OlapQueryLog](
	[MSOLAP_Database] [nvarchar](255) NULL,
	[MSOLAP_ObjectPath] [nvarchar](4000) NULL,
	[MSOLAP_User] [nvarchar](255) NULL,
	[Dataset] [nvarchar](4000) NULL,
	[StartTime] [datetime] NULL,
	[Duration] [bigint] NULL
) ON [PRIMARY]
GO
