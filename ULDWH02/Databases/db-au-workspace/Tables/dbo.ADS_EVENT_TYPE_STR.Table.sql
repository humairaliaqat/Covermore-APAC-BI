USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_EVENT_TYPE_STR]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_EVENT_TYPE_STR](
	[Event_Type_ID] [int] NOT NULL,
	[Language] [varchar](10) NOT NULL,
	[Event_Type_Name] [nvarchar](255) NULL
) ON [PRIMARY]
GO
