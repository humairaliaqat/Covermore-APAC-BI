USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_UploadedDocuments_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_UploadedDocuments_au](
	[Id] [int] NOT NULL,
	[DocumentTypeId] [int] NOT NULL,
	[FileName] [nvarchar](128) NULL,
	[MissingReason] [int] NULL,
	[ReasonDescription] [nvarchar](256) NULL,
	[SectionCode] [varchar](25) NULL,
	[ClaimId] [int] NULL,
	[OnlineClaimId] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[IsProcessed] [bit] NOT NULL
) ON [PRIMARY]
GO
