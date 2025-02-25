USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmLocationHistory]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmLocationHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[ClaimKey] [varchar](40) NULL,
	[LocationHistoryKey] [varchar](40) NOT NULL,
	[LocationKey] [varchar](40) NULL,
	[ClaimNo] [int] NULL,
	[LocationHistoryID] [int] NULL,
	[LocationID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[CorroReceivedDate] [datetime] NULL,
	[CreatedByName] [nvarchar](150) NULL,
	[Location] [nvarchar](50) NULL,
	[LocationDescription] [nvarchar](50) NULL,
	[Note] [nvarchar](50) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[isFirst] [bit] NOT NULL,
	[CreatedDateTimeUTC] [datetime] NULL,
	[CorroReceivedDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmLocationHistory_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmLocationHistory_BIRowID] ON [dbo].[clmLocationHistory]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmLocationHistory_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmLocationHistory_ClaimKey] ON [dbo].[clmLocationHistory]
(
	[ClaimKey] ASC
)
INCLUDE([LocationKey],[LocationID],[Location],[LocationDescription],[CreatedDate],[CreatedByName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clmLocationHistory] ADD  DEFAULT ((0)) FOR [isFirst]
GO
