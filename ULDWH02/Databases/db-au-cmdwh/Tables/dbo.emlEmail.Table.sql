USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emlEmail]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emlEmail](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MailBox] [nvarchar](200) NULL,
	[MessageID] [nvarchar](1000) NULL,
	[EmailID] [nvarchar](500) NULL,
	[ChangeKey] [nvarchar](200) NULL,
	[FullPath] [nvarchar](1024) NULL,
	[FolderID] [nvarchar](300) NULL,
	[Subject] [nvarchar](500) NULL,
	[Body] [nvarchar](max) NULL,
	[Author] [nvarchar](300) NULL,
	[Sender] [nvarchar](300) NULL,
	[ReplyTo] [nvarchar](1000) NULL,
	[ToRecipients] [nvarchar](max) NULL,
	[CCRecipients] [nvarchar](max) NULL,
	[BCCRecipients] [nvarchar](max) NULL,
	[DatetimeCreated] [datetime2](7) NULL,
	[DatetimeSent] [datetime2](7) NULL,
	[DatetimeReceived] [datetime2](7) NULL,
	[LastModifiedTime] [datetime2](7) NULL,
	[LastModifiedName] [nvarchar](1000) NULL,
	[Categories] [nvarchar](500) NULL,
	[Sensitivity] [nvarchar](100) NULL,
	[Importance] [nvarchar](50) NULL,
	[HasAttachments] [tinyint] NULL,
	[IsRead] [tinyint] NULL,
	[IsDeliveryReceiptRequested] [tinyint] NULL,
	[IsReadReceiptRequested] [tinyint] NULL,
	[IsResponseRequested] [tinyint] NULL,
	[ReminderIsSet] [tinyint] NULL,
	[Headers] [nvarchar](max) NULL,
	[ExternID] [nvarchar](500) NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[emlEmail] ADD  DEFAULT ((-1)) FOR [CreateBatchID]
GO
ALTER TABLE [dbo].[emlEmail] ADD  DEFAULT (NULL) FOR [UpdateBatchID]
GO
