USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_SUPPORTED_EVENTS]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_SUPPORTED_EVENTS](
	[Cluster_ID] [varchar](64) NULL,
	[Service_Type_ID] [varchar](64) NULL,
	[Event_Type_ID] [int] NULL,
	[Event_Detail_Type_ID] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ADS_SUPPORTED_EVENTS_1]    Script Date: 21/02/2025 11:29:59 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ADS_SUPPORTED_EVENTS_1] ON [dbo].[ADS_SUPPORTED_EVENTS]
(
	[Cluster_ID] ASC,
	[Service_Type_ID] ASC,
	[Event_Type_ID] ASC,
	[Event_Detail_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
