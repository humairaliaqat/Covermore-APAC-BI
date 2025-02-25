USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_verActivity]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_verActivity](
	[ActivityKey] [int] NOT NULL,
	[ActivityName] [varchar](350) NOT NULL,
	[ActivityDescription] [varchar](200) NOT NULL,
	[ActivityMedia] [varchar](1) NOT NULL
) ON [PRIMARY]
GO
