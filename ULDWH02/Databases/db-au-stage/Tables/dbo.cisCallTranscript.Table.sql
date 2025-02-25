USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cisCallTranscript]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCallTranscript](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetaDataID] [bigint] NOT NULL,
	[Transcript] [varchar](max) NULL,
	[ClassificationText] [nvarchar](max) NULL,
	[TopicText] [nvarchar](max) NULL,
	[SentimentText] [nvarchar](max) NULL,
	[UpdateDateTime] [timestamp] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:08:03 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[cisCallTranscript]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_metadata]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_metadata] ON [dbo].[cisCallTranscript]
(
	[MetaDataID] ASC
)
INCLUDE([Transcript],[ClassificationText],[TopicText],[SentimentText]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
