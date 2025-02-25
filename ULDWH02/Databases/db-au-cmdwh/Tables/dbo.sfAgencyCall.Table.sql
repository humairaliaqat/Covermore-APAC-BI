USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfAgencyCall]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfAgencyCall](
	[CallID] [nvarchar](18) NULL,
	[CallNumber] [nvarchar](80) NULL,
	[AccountID] [nvarchar](18) NULL,
	[AgencyID] [nvarchar](1300) NULL,
	[CallStartTime] [datetime] NULL,
	[CallEndTime] [datetime] NULL,
	[CallDuration] [int] NULL,
	[CallDurationText] [varchar](1300) NULL,
	[CallType] [nvarchar](255) NULL,
	[CallCategory] [nvarchar](255) NULL,
	[CallSubCategory] [nvarchar](255) NULL,
	[ConsultantID] [nvarchar](18) NULL,
	[ConsultantName] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[isDeleted] [bit] NULL,
	[LastActivityDate] [date] NULL,
	[LastModifiedBy] [nvarchar](255) NULL,
	[LastModifiedDate] [datetime] NULL,
	[RecordType] [varchar](255) NULL,
	[RoleType] [nvarchar](1300) NULL,
	[StopCall] [nvarchar](1300) NULL,
	[SurveyEmail] [nvarchar](255) NULL,
	[SystemModstamp] [datetime] NULL,
	[Timezone] [nvarchar](200) NULL,
	[CallComment] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAgencyCall_CallID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_sfAgencyCall_CallID] ON [dbo].[sfAgencyCall]
(
	[CallID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAgencyCall_AccountID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAgencyCall_AccountID] ON [dbo].[sfAgencyCall]
(
	[AccountID] ASC
)
INCLUDE([CallStartTime],[CallDuration],[CallType],[CallCategory],[CallSubCategory]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAgencyCall_CallCategory]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAgencyCall_CallCategory] ON [dbo].[sfAgencyCall]
(
	[CallCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_sfAgencyCall_CallStartTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAgencyCall_CallStartTime] ON [dbo].[sfAgencyCall]
(
	[CallStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAgencyCall_CallSubCategory]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAgencyCall_CallSubCategory] ON [dbo].[sfAgencyCall]
(
	[CallSubCategory] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAgencyCall_CallType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAgencyCall_CallType] ON [dbo].[sfAgencyCall]
(
	[CallType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
