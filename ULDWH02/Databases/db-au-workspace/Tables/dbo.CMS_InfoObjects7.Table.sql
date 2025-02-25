USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CMS_InfoObjects7]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CMS_InfoObjects7](
	[ObjectID] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
	[OwnerID] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[LastModifyTime] [varbinary](32) NOT NULL,
	[ScheduleStatus] [int] NULL,
	[NextRunTime] [varbinary](32) NULL,
	[CRC] [varbinary](30) NOT NULL,
	[Properties] [image] NOT NULL,
	[SI_GUID] [varbinary](56) NULL,
	[SI_CUID] [varbinary](56) NULL,
	[SI_RUID] [varbinary](56) NULL,
	[SI_INSTANCE_OBJECT] [int] NULL,
	[SI_PLUGIN_OBJECT] [int] NULL,
	[SI_TABLE] [int] NULL,
	[SI_HIDDEN_OBJECT] [int] NULL,
	[SI_RECURRING] [int] NULL,
	[SI_RUNNABLE_OBJECT] [int] NULL,
	[SI_PSS_SERVICE_ID] [int] NULL,
	[SI_CRYPTOGRAPHIC_KEY] [int] NULL,
	[SI_NAMEDUSER] [int] NULL,
	[SI_KEYWORD] [varbinary](255) NULL,
	[SI_KEYWORD_TR] [int] NULL,
	[MOBILE_READY] [varbinary](34) NULL,
	[MOBILE_READY_TR] [int] NULL,
	[LOV_KEY] [varbinary](18) NULL,
	[SI_TENANT_ID] [int] NULL,
	[ObjName] [varbinary](255) NULL,
	[ObjName_TR] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
