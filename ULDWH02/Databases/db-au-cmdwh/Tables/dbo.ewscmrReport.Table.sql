USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ewscmrReport]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ewscmrReport](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Sender] [nvarchar](320) NULL,
	[SentDateTime] [datetime] NULL,
	[Report] [nvarchar](1024) NULL,
	[Recipient] [nvarchar](1024) NULL,
	[RecipientType] [nvarchar](50) NULL,
	[isUndeliverable] [bit] NULL,
	[isOutOfOffice] [bit] NULL,
	[isAutomaticReply] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_ewscmrReport_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_ewscmrReport_BIRowID] ON [dbo].[ewscmrReport]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewscmrReport_Sender]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewscmrReport_Sender] ON [dbo].[ewscmrReport]
(
	[Sender] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
