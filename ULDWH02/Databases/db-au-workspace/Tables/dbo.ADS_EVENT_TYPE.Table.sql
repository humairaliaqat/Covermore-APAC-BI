USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_EVENT_TYPE]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_EVENT_TYPE](
	[Event_Type_ID] [int] NOT NULL,
	[Event_Category_ID] [int] NOT NULL
) ON [PRIMARY]
GO
