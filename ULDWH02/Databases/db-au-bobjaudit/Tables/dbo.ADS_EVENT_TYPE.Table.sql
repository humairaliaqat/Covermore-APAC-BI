USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_EVENT_TYPE]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_EVENT_TYPE](
	[Event_Type_ID] [int] NOT NULL,
	[Event_Category_ID] [int] NOT NULL,
 CONSTRAINT [ADS_EVENT_TYPE_PK] PRIMARY KEY CLUSTERED 
(
	[Event_Type_ID] ASC,
	[Event_Category_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [ADS_EVENT_TYPE_1]    Script Date: 21/02/2025 11:29:59 AM ******/
CREATE NONCLUSTERED INDEX [ADS_EVENT_TYPE_1] ON [dbo].[ADS_EVENT_TYPE]
(
	[Event_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ADS_EVENT_TYPE_2]    Script Date: 21/02/2025 11:29:59 AM ******/
CREATE NONCLUSTERED INDEX [ADS_EVENT_TYPE_2] ON [dbo].[ADS_EVENT_TYPE]
(
	[Event_Category_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
