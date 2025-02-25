USE [db-au-stage]
GO
/****** Object:  Table [dbo].[focus_archive_sessions]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[focus_archive_sessions](
	[sessiontoken] [uniqueidentifier] NULL,
	[sessiondata] [nvarchar](4000) NULL,
	[lastupdatetime] [datetime2](7) NULL
) ON [PRIMARY]
GO
