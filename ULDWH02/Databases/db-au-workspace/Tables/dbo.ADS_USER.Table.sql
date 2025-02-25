USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ADS_USER]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_USER](
	[User_ID] [varchar](64) NOT NULL,
	[User_Name] [varchar](255) NULL,
	[Tenant_ID] [varchar](64) NULL,
	[Cluster_ID] [varchar](64) NOT NULL
) ON [PRIMARY]
GO
