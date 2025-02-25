USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[e5_docs_R]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_docs_R](
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [idx] ON [dbo].[e5_docs_R]
(
	[ClaimKey] ASC,
	[Attachment_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
