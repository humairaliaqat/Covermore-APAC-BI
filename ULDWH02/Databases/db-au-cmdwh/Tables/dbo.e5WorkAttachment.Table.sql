USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkAttachment]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkAttachment](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Work_ID] [varchar](50) NULL,
	[WorkAttachmentID] [int] NULL,
	[AttachmentID] [varchar](36) NULL,
	[AttachmentType] [nvarchar](100) NULL,
	[AttachmentName] [nvarchar](128) NULL,
	[AttachmentExt] [nvarchar](128) NULL,
	[AttachmentURL] [nvarchar](512) NULL,
	[AttachmentSize] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateModified] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_e5WorkAttachment]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_e5WorkAttachment] ON [dbo].[e5WorkAttachment]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_WorkAttachmentID_e5WorkAttachment]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_WorkAttachmentID_e5WorkAttachment] ON [dbo].[e5WorkAttachment]
(
	[WorkAttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_WorkID_e5WorkAttachment]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_WorkID_e5WorkAttachment] ON [dbo].[e5WorkAttachment]
(
	[Work_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
