USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penUserAudit]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penUserAudit](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NULL,
	[UserAuditKey] [varchar](41) NOT NULL,
	[UserKey] [varchar](41) NOT NULL,
	[OutletKey] [varchar](41) NOT NULL,
	[DomainID] [int] NULL,
	[UserAuditID] [int] NOT NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditDateTimeUTC] [datetime] NOT NULL,
	[UserID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](100) NOT NULL,
	[Password] [varchar](255) NULL,
	[Initial] [nvarchar](50) NULL,
	[ASICNumber] [int] NULL,
	[AgreementDate] [datetime] NULL,
	[AccessLevel] [int] NOT NULL,
	[AccessLevelName] [nvarchar](50) NULL,
	[AccreditationNumber] [varchar](50) NULL,
	[AllowAdjustPricing] [bit] NULL,
	[Status] [varchar](20) NULL,
	[InactiveDate] [datetime] NULL,
	[AgentCode] [nvarchar](50) NULL,
	[DateOfBirth] [datetime] NULL,
	[ASICCheck] [nvarchar](50) NULL,
	[Email] [nvarchar](200) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[MustChangePassword] [bit] NULL,
	[AccountLocked] [bit] NULL,
	[LoginFailedTimes] [int] NULL,
	[IsSuperUser] [bit] NULL,
	[LastUpdateUserID] [int] NULL,
	[LastUpdateCRMUserID] [int] NULL,
	[LastLoggedIn] [datetime] NULL,
	[LastLoggedInUTC] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUserAudit_UserAuditKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penUserAudit_UserAuditKey] ON [dbo].[penUserAudit]
(
	[UserAuditKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penUserAudit_AuditDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUserAudit_AuditDateTime] ON [dbo].[penUserAudit]
(
	[AuditDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUserAudit_UserKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUserAudit_UserKey] ON [dbo].[penUserAudit]
(
	[UserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
