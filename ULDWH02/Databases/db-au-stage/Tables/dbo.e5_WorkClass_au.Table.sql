USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkClass_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkClass_au](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[DiariseList_Id] [int] NOT NULL,
	[AlwaysViewAttachments] [bit] NOT NULL,
	[MatchFindId] [int] NULL,
	[MatchProperty] [nvarchar](32) NULL,
	[MatchStatus] [int] NULL,
	[PreProcessorAssembly] [varchar](100) NULL,
	[PreProcessorClass] [varchar](100) NULL,
	[PreProcessorMethod] [varchar](100) NULL,
	[PostProcessorAssembly] [varchar](100) NULL,
	[PostProcessorClass] [varchar](100) NULL,
	[PostProcessorMethod] [varchar](100) NULL,
	[WorkWindowX] [int] NULL,
	[WorkWindowY] [int] NULL,
	[WorkWindowW] [int] NULL,
	[WorkWindowH] [int] NULL,
	[WorkWindowLayout] [int] NULL,
	[AttachmentWindowX] [int] NULL,
	[AttachmentWindowY] [int] NULL,
	[AttachmentWindowW] [int] NULL,
	[AttachmentWindowH] [int] NULL,
	[ChildrenFindId] [int] NULL,
	[SLAMode] [tinyint] NOT NULL,
	[BusinessHoursProviderType] [nvarchar](1024) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [e5_WorkClass_au1]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [e5_WorkClass_au1] ON [dbo].[e5_WorkClass_au]
(
	[Id] ASC
)
INCLUDE([Name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
