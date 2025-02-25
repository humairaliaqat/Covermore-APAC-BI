USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[EmailMessage_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[EmailMessage_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[ActivityId] [varchar](25) NULL,
	[BccAddress] [varchar](4000) NULL,
	[CcAddress] [varchar](4000) NULL,
	[FirstOpenedDate] [datetime] NULL,
	[FromAddress] [varchar](255) NULL,
	[FromName] [varchar](1000) NULL,
	[HasAttachment] [bit] NULL,
	[Headers] [varchar](max) NULL,
	[HtmlBody] [varchar](max) NULL,
	[Incoming] [bit] NULL,
	[IsBounced] [bit] NULL,
	[IsClientManaged] [bit] NULL,
	[IsExternallyVisible] [bit] NULL,
	[IsOpened] [bit] NULL,
	[IsPrivateDraft] [bit] NULL,
	[IsTracked] [bit] NULL,
	[LastOpenedDate] [datetime] NULL,
	[MessageDate] [datetime] NULL,
	[MessageIdentifier] [varchar](255) NULL,
	[ParentId] [varchar](25) NULL,
	[RedactedInformation_c] [varchar](max) NULL,
	[RelatedToId] [varchar](255) NULL,
	[ReplyToEmailMessageId] [varchar](255) NULL,
	[ShowOnTimeline_c] [bit] NULL,
	[Status] [nvarchar](255) NULL,
	[Subject] [varchar](3000) NULL,
	[TextBody] [varchar](max) NULL,
	[ThreadIdentifier] [varchar](255) NULL,
	[ToAddress] [varchar](4000) NULL,
	[ValidatedFromAddress] [nvarchar](255) NULL,
	[EmailTemplateId] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ix_EmailMessage_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_EmailMessage_Hist] ON [atlas].[EmailMessage_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
