USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[e5_docs_20200731]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_docs_20200731](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[Work_ID] [varchar](50) NULL,
	[OrgWorkID] [uniqueidentifier] NOT NULL,
	[CompletionDate] [datetime] NULL,
	[AssessmentOutcomeDescription] [nvarchar](400) NULL,
	[Idx] [bigint] NULL,
	[Attachment_Id] [varchar](36) NULL,
	[Library_Location] [nvarchar](200) NULL,
	[DirName] [nvarchar](256) NULL,
	[LeafName] [nvarchar](128) NULL,
	[doctext] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
