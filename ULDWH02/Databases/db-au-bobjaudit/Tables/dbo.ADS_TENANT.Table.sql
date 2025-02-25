USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_TENANT]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_TENANT](
	[Tenant_ID] [varchar](64) NOT NULL,
	[Tenant_Name] [varchar](255) NULL,
	[Cluster_ID] [varchar](64) NOT NULL,
 CONSTRAINT [ADS_TENANT_PK] PRIMARY KEY CLUSTERED 
(
	[Tenant_ID] ASC,
	[Cluster_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
