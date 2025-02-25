USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Document_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Document_Hist](
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
	[Case_c] [varchar](25) NULL,
	[Channel_c] [nvarchar](50) NULL,
	[Comments_c] [varchar](255) NULL,
	[Count_of_Email_c] [numeric](18, 0) NULL,
	[DateReceived_c] [date] NULL,
	[DateRequested_c] [date] NULL,
	[DocumentReceiver_c] [nvarchar](50) NULL,
	[FireFlow_c] [bit] NULL,
	[Important_c] [bit] NULL,
	[InboundOutbound_c] [nvarchar](50) NULL,
	[IsCaseClosed_c] [bit] NULL,
	[IsPortal_c] [bit] NULL,
	[Name] [varchar](80) NULL,
	[NextScheduledDatetime_c] [datetime] NULL,
	[Portal_Status_c] [nvarchar](50) NULL,
	[Provider_c] [varchar](25) NULL,
	[Public_c] [bit] NULL,
	[SameAsPrimaryContact_c] [bit] NULL,
	[ScheduledDateTime_c] [datetime] NULL,
	[SendReminderNotificationEmail_c] [bit] NULL,
	[SendReminderNotification_c] [bit] NULL,
	[Status_c] [nvarchar](50) NULL,
	[TranslationFrom_c] [nvarchar](50) NULL,
	[TranslationStatus_c] [nvarchar](50) NULL,
	[TranslationTo_c] [nvarchar](50) NULL,
	[Type_c] [nvarchar](255) NULL,
	[VOB_c] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Document_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_Document_Hist] ON [atlas].[Document_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
