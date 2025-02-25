USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_AUDITEE]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_AUDITEE](
	[Cluster_ID] [varchar](64) NOT NULL,
	[Server_ID] [varchar](64) NOT NULL,
	[Service_Type_ID] [varchar](64) NOT NULL,
	[Server_Type_ID] [varchar](64) NOT NULL,
	[Application_Type_ID] [varchar](64) NOT NULL,
	[Version] [varchar](64) NULL,
	[Retrieved_Events_Completed_By] [datetime] NULL,
	[State] [int] NULL,
	[Potentially_Incomplete_Data] [int] NULL,
 CONSTRAINT [ADS_AUDITEE_PK] PRIMARY KEY CLUSTERED 
(
	[Cluster_ID] ASC,
	[Server_ID] ASC,
	[Service_Type_ID] ASC,
	[Server_Type_ID] ASC,
	[Application_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ADS_AUDITEE_1]    Script Date: 21/02/2025 11:29:59 AM ******/
CREATE NONCLUSTERED INDEX [ADS_AUDITEE_1] ON [dbo].[ADS_AUDITEE]
(
	[Application_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ADS_AUDITEE_2]    Script Date: 21/02/2025 11:29:59 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ADS_AUDITEE_2] ON [dbo].[ADS_AUDITEE]
(
	[Cluster_ID] ASC,
	[Server_ID] ASC,
	[Service_Type_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
