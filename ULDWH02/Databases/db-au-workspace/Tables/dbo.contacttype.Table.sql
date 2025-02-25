USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[contacttype]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contacttype](
	[SessionKey] [nvarchar](95) NULL,
	[SessionID] [numeric](18, 0) NOT NULL,
	[ContactType] [smallint] NULL
) ON [PRIMARY]
GO
