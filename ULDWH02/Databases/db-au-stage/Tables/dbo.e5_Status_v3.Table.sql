USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Status_v3]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Status_v3](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](32) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[SLAExclusion] [bit] NOT NULL,
	[WorkflowInitialisationExclusion] [bit] NOT NULL,
	[EventAssemblyName] [varchar](256) NULL,
	[EventClassName] [varchar](256) NULL,
	[EventMethodName] [varchar](256) NULL,
	[ExternalId] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedDateTime] [datetime2](7) NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[StatusType] [int] NULL,
	[LifecycleSLAExclusion] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [e5_Status_v31]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_Status_v31] ON [dbo].[e5_Status_v3]
(
	[Id] ASC
)
INCLUDE([Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
