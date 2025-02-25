USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sforce_RecordType]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sforce_RecordType](
	[BusinessProcessId] [nvarchar](18) NULL,
	[CreatedById] [nvarchar](18) NULL,
	[CreatedDate] [datetime] NULL,
	[Description] [nvarchar](255) NULL,
	[DeveloperName] [nvarchar](80) NULL,
	[Id] [nvarchar](18) NULL,
	[IsActive] [bit] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[Name] [nvarchar](80) NULL,
	[NamespacePrefix] [nvarchar](15) NULL,
	[SobjectType] [nvarchar](40) NULL,
	[SystemModstamp] [datetime] NULL
) ON [PRIMARY]
GO
