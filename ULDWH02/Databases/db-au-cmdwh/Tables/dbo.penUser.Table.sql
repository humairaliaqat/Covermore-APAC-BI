USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penUser]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penUser](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[UserKey] [varchar](41) NOT NULL,
	[OutletKey] [varchar](41) NOT NULL,
	[UserSKey] [bigint] IDENTITY(1000,1) NOT NULL,
	[UserStatus] [varchar](20) NOT NULL,
	[UserStartDate] [datetime] NOT NULL,
	[UserEndDate] [datetime] NULL,
	[UserHashKey] [binary](30) NULL,
	[UserID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](200) NOT NULL,
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
	[RefereeName] [nvarchar](255) NULL,
	[ReasonableChecksMade] [bit] NULL,
	[AccreditationDate] [datetime] NULL,
	[DeclaredDate] [datetime] NULL,
	[PreviouslyKnownAs] [nvarchar](100) NULL,
	[YearsOfExperience] [varchar](15) NULL,
	[DateOfBirth] [datetime] NULL,
	[ASICCheck] [nvarchar](50) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[Email] [nvarchar](200) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[MustChangePassword] [bit] NULL,
	[AccountLocked] [bit] NULL,
	[IsSuperUser] [bit] NULL,
	[LoginFailedTimes] [int] NULL,
	[LastUpdateUserID] [int] NULL,
	[LastUpdateCRMUserID] [int] NULL,
	[LastLoggedIn] [datetime] NULL,
	[LastLoggedInUTC] [datetime] NULL,
	[FirstSellDate] [datetime] NULL,
	[LastSellDate] [datetime] NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[ConsultantType] [nvarchar](50) NULL,
	[IsAutomatedUser] [bit] NULL,
	[ExternalIdentifier] [nvarchar](100) NULL,
	[isUserClickedLink] [bit] NULL,
	[VelocityNumber] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_UserKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penUser_UserKey] ON [dbo].[penUser]
(
	[UserKey] ASC,
	[UserStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_CountryKey] ON [dbo].[penUser]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_Login]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_Login] ON [dbo].[penUser]
(
	[Login] ASC,
	[OutletKey] ASC,
	[UserStatus] ASC
)
INCLUDE([UserKey],[UserID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_OutletAlphaKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_OutletAlphaKey] ON [dbo].[penUser]
(
	[OutletAlphaKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_OutletKey] ON [dbo].[penUser]
(
	[OutletKey] ASC,
	[Login] ASC
)
INCLUDE([UserKey],[UserID],[Initial]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_UserHashKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_UserHashKey] ON [dbo].[penUser]
(
	[UserHashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penUser_UserID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_UserID] ON [dbo].[penUser]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penUser_UserKeyStatus]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_UserKeyStatus] ON [dbo].[penUser]
(
	[UserKey] ASC,
	[UserStatus] ASC
)
INCLUDE([FirstName],[LastName],[Login]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penUser_UserSKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penUser_UserSKey] ON [dbo].[penUser]
(
	[UserSKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
