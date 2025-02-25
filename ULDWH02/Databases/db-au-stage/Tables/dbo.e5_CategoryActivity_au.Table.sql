USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_CategoryActivity_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_CategoryActivity_au](
	[Id] [int] NOT NULL,
	[Category1_Id] [int] NOT NULL,
	[Category2_Id] [int] NOT NULL,
	[Category3_Id] [int] NOT NULL,
	[Activity_Id] [int] NOT NULL,
	[Prescription] [smallint] NOT NULL,
	[KnowledgeBaseURL] [nvarchar](500) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [text] NULL,
	[Process] [int] NOT NULL,
	[Status] [smallint] NOT NULL,
	[TemplateFolder] [nvarchar](200) NULL,
	[SortOrder] [int] NULL,
	[SLAMinutes] [int] NULL,
	[EETMinutes] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
