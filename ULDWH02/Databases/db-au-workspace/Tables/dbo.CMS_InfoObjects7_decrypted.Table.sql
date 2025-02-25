USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CMS_InfoObjects7_decrypted]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS_InfoObjects7_decrypted](
	[objectid] [int] NOT NULL,
	[parentid] [int] NOT NULL,
	[ownerid] [int] NOT NULL,
	[lastmodifytime] [varchar](8000) NULL,
	[ObjectName] [varchar](8000) NULL,
	[typeid] [int] NOT NULL,
	[type] [varchar](31) NOT NULL,
	[si_cuid] [varbinary](56) NULL
) ON [PRIMARY]
GO
