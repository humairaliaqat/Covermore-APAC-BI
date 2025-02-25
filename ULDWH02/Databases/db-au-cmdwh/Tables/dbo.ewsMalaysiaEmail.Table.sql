USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ewsMalaysiaEmail]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ewsMalaysiaEmail](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MailBox] [nvarchar](320) NULL,
	[FolderID] [nvarchar](255) NULL,
	[FullPath] [nvarchar](max) NULL,
	[EmailID] [nvarchar](450) NULL,
	[Subject] [nvarchar](1024) NULL,
	[ConversationID] [nvarchar](255) NULL,
	[ConversationTopic] [nvarchar](1024) NULL,
	[InReplyTo] [nvarchar](1024) NULL,
	[Category] [nvarchar](1024) NULL,
	[CreateDateTime] [datetime] NULL,
	[ReceiveDateTime] [datetime] NULL,
	[SentDateTime] [datetime] NULL,
	[ModifyDateTime] [datetime] NULL,
	[SenderAddress] [nvarchar](320) NULL,
	[ReplyToAddress] [nvarchar](320) NULL,
	[ToAddress] [nvarchar](max) NULL,
	[CCAddress] [nvarchar](max) NULL,
	[ReceivedBy] [nvarchar](320) NULL,
	[ModifyBy] [nvarchar](320) NULL,
	[RepliedDateTime] [datetime] NULL,
	[Importance] [nvarchar](255) NULL,
	[EmailSize] [bigint] NULL,
	[HasAttachment] [bit] NULL,
	[IsResend] [bit] NULL,
	[IsNew] [bit] NULL,
	[IsRead] [bit] NULL,
	[InternetHeader] [nvarchar](max) NULL,
	[DeleteDateTime] [datetime] NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_ewsMalaysiaEmail_BIRowID] ON [dbo].[ewsMalaysiaEmail]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_EmailID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmail_EmailID] ON [dbo].[ewsMalaysiaEmail]
(
	[EmailID] ASC
)
INCLUDE([MailBox],[FolderID],[FullPath],[Subject],[CreateDateTime],[SentDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_FolderID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmail_FolderID] ON [dbo].[ewsMalaysiaEmail]
(
	[FolderID] ASC
)
INCLUDE([MailBox],[EmailID],[FullPath],[Subject],[CreateDateTime],[SentDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_MailBox]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmail_MailBox] ON [dbo].[ewsMalaysiaEmail]
(
	[MailBox] ASC
)
INCLUDE([FolderID],[EmailID],[FullPath],[Subject],[CreateDateTime],[SentDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_receivedate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmail_receivedate] ON [dbo].[ewsMalaysiaEmail]
(
	[ReceiveDateTime] ASC,
	[MailBox] ASC
)
INCLUDE([EmailID],[DeleteDateTime],[FullPath]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ewsMalaysiaEmail_sentdate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_ewsMalaysiaEmail_sentdate] ON [dbo].[ewsMalaysiaEmail]
(
	[SentDateTime] ASC,
	[MailBox] ASC
)
INCLUDE([EmailID],[DeleteDateTime],[FullPath]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
