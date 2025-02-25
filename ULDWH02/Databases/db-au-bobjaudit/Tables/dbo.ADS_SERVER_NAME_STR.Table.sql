USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_SERVER_NAME_STR]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_SERVER_NAME_STR](
	[Cluster_ID] [varchar](64) NOT NULL,
	[Server_ID] [varchar](64) NOT NULL,
	[Language] [varchar](10) NOT NULL,
	[Server_Name] [varchar](255) NULL,
 CONSTRAINT [ADS_SERVER_NAME_STR_PK] PRIMARY KEY CLUSTERED 
(
	[Cluster_ID] ASC,
	[Server_ID] ASC,
	[Language] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
