USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[bobjObjects]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bobjObjects](
	[si_cuid] [varchar](2000) NULL,
	[objectid] [int] NOT NULL,
	[parentid] [int] NOT NULL,
	[ownerid] [int] NOT NULL,
	[lastmodifytime] [varchar](2000) NULL,
	[ObjectName] [varchar](8000) NULL,
	[typeid] [int] NOT NULL,
	[type] [varchar](12) NOT NULL
) ON [PRIMARY]
GO
