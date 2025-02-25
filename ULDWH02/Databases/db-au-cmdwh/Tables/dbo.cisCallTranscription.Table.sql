USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisCallTranscription]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCallTranscription](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetaDataID] [bigint] NOT NULL,
	[Transcript] [varchar](max) NULL,
	[ClassificationText] [nvarchar](max) NULL,
	[TopicText] [nvarchar](max) NULL,
	[SentimentText] [nvarchar](max) NULL,
	[UpdateDateTime] [timestamp] NOT NULL,
	[InsertDateTime] [datetime] NULL,
	[CustomerTranscript] [varchar](max) NULL,
	[EmployeeTranscript] [varchar](max) NULL,
	[confidence_level] [decimal](4, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[cisCallTranscription]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_metadata]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_metadata] ON [dbo].[cisCallTranscription]
(
	[MetaDataID] ASC
)
INCLUDE([Transcript],[ClassificationText],[TopicText],[SentimentText],[UpdateDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
