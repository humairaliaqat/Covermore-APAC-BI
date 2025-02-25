USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[e5_docs_20210817]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_docs_20210817](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[AssessmentOutcome] [varchar](6) NOT NULL,
	[Work_ID] [varchar](50) NULL,
	[OrgWorkID] [varchar](50) NULL,
	[CompletionDate] [datetime] NULL,
	[AssessmentOutcomeDescription] [nvarchar](400) NULL,
	[Idx] [bigint] NULL,
	[ClaimNumber] [nvarchar](1000) NULL,
	[Reference] [int] NULL,
	[CreationDate] [datetime] NULL,
	[Work Type] [nvarchar](100) NULL,
	[Process Type] [nvarchar](100) NULL,
	[Attachment_Id] [varchar](36) NULL,
	[Library_Location] [nvarchar](200) NULL,
	[DirName] [nvarchar](256) NULL,
	[LeafName] [nvarchar](260) NULL
) ON [PRIMARY]
GO
