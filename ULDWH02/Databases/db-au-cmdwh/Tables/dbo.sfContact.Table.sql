USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfContact]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfContact](
	[ContactID] [nvarchar](18) NULL,
	[AccountID] [nvarchar](18) NULL,
	[AgencyID] [nvarchar](255) NULL,
	[ConsultantID] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[DOB] [date] NULL,
	[Status] [nvarchar](255) NULL,
	[UserType] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[CRMUserName] [nvarchar](255) NULL,
	[Department] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[Phone] [nvarchar](255) NULL,
	[HomePhone] [nvarchar](255) NULL,
	[Fax] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[EmailBouncedDate] [datetime] NULL,
	[EmailBouncedReason] [nvarchar](255) NULL,
	[isDeleted] [bit] NULL,
	[isEmailBounced] [bit] NULL,
	[CourseName] [nvarchar](255) NULL,
	[ExamResult] [nvarchar](255) NULL,
	[ExamTime] [datetime] NULL,
	[LastModifiedBy] [nvarchar](255) NULL,
	[LastModifiedDate] [datetime] NULL,
	[RecordType] [nvarchar](255) NULL,
	[SystemModStamp] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfContact_ContactID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_sfContact_ContactID] ON [dbo].[sfContact]
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfContact_AccountID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfContact_AccountID] ON [dbo].[sfContact]
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfContact_AgencyID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfContact_AgencyID] ON [dbo].[sfContact]
(
	[AgencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfContact_ConsultantID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfContact_ConsultantID] ON [dbo].[sfContact]
(
	[ConsultantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
