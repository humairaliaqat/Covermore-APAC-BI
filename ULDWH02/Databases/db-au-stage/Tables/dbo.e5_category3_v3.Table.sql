USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_category3_v3]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_category3_v3](
	[ExternalId] [uniqueidentifier] NOT NULL,
	[Category1_Id] [int] NOT NULL,
	[Category2_Id] [int] NOT NULL,
	[Id] [int] NOT NULL,
	[Code] [nvarchar](32) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Status] [smallint] NULL,
	[WorkClass_Id] [int] NULL,
	[SLAMinutes] [int] NULL,
	[KnowledgeBaseURL] [nvarchar](500) NULL,
	[TemplateFolder] [nvarchar](200) NULL,
	[SortOrder] [int] NULL,
	[EETMinutes] [int] NULL,
	[ArchiveDays] [int] NULL,
	[WorkFlow_Id] [uniqueidentifier] NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedDateTime] [datetime2](7) NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[LifecycleSLAMinutes] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [e5_Category3_v31]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_Category3_v31] ON [dbo].[e5_category3_v3]
(
	[Id] ASC
)
INCLUDE([Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
