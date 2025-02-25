USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_EVENT_DETAIL]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_EVENT_DETAIL](
	[Event_ID] [varchar](64) NOT NULL,
	[Event_Detail_ID] [int] NOT NULL,
	[Event_Detail_Type_ID] [int] NULL,
	[Bunch] [int] NULL,
	[Event_Detail_Value] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
