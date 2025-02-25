USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ClaimsReferenceFiles_20190823]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimsReferenceFiles_20190823](
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[AssessmentOutcomeDescription] [nvarchar](400) NULL,
	[LatestAssessmentDate] [datetime] NULL,
	[Reference] [int] NULL,
	[Library_Location] [nvarchar](200) NOT NULL,
	[DirName] [nvarchar](256) NOT NULL,
	[LeafName] [nvarchar](260) NOT NULL,
	[Extension] [nvarchar](260) NULL,
	[AttachmentType] [nvarchar](100) NULL,
	[TimeCreated] [datetime] NOT NULL,
	[TimeLastModified] [datetime] NOT NULL
) ON [PRIMARY]
GO
