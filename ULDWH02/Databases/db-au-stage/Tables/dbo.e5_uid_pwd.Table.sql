USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_uid_pwd]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_uid_pwd](
	[Server] [varchar](50) NULL,
	[databasename] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[pwd] [varbinary](500) NULL
) ON [PRIMARY]
GO
