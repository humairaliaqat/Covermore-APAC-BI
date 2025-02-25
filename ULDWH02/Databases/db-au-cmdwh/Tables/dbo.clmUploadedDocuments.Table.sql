USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmUploadedDocuments]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmUploadedDocuments](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[DocumentKey] [varchar](40) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ClaimNo] [int] NULL,
	[SectionCode] [varchar](25) NULL,
	[OnlineClaimID] [int] NOT NULL,
	[DocumentType] [nvarchar](128) NULL,
	[FileName] [nvarchar](128) NULL,
	[isProcessed] [bit] NULL,
	[MissingReason] [varchar](25) NULL,
	[ReasonDescription] [nvarchar](256) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmUploadedDomcuments_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmUploadedDomcuments_BIRowID] ON [dbo].[clmUploadedDocuments]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmUploadedDomcuments_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmUploadedDomcuments_ClaimKey] ON [dbo].[clmUploadedDocuments]
(
	[ClaimKey] ASC
)
INCLUDE([SectionCode],[DocumentType],[FileName],[isProcessed],[MissingReason],[ReasonDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmUploadedDomcuments_DocumentKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmUploadedDomcuments_DocumentKey] ON [dbo].[clmUploadedDocuments]
(
	[DocumentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
