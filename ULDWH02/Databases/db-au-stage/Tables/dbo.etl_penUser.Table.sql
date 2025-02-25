USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penUser]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penUser](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[UserKey] [varchar](71) NULL,
	[OutletKey] [varchar](71) NULL,
	[DomainID] [int] NULL,
	[UserStatus] [varchar](20) NULL,
	[UserStartDate] [datetime] NULL,
	[UserEndDate] [datetime] NULL,
	[UserHashKey] [binary](30) NULL,
	[UserID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](100) NULL,
	[Password] [int] NULL,
	[Initial] [nvarchar](50) NOT NULL,
	[ASICNumber] [varchar](50) NULL,
	[AgreementDate] [datetime] NULL,
	[AccessLevel] [int] NOT NULL,
	[AccessLevelName] [nvarchar](50) NULL,
	[AccreditationNumber] [varchar](50) NULL,
	[AllowAdjustPricing] [bit] NULL,
	[Status] [varchar](8) NOT NULL,
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
	[Email] [nvarchar](200) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[MustChangePassword] [bit] NOT NULL,
	[AccountLocked] [bit] NOT NULL,
	[LoginFailedTimes] [int] NOT NULL,
	[IsSuperUser] [bit] NOT NULL,
	[LastUpdateUserId] [int] NULL,
	[LastUpdateCrmUserId] [int] NULL,
	[LastLoggedIn] [datetime] NULL,
	[LastLoggedInUTC] [datetime] NULL,
	[ConsultantType] [nvarchar](50) NULL,
	[ExternalIdentifier] [nvarchar](100) NULL,
	[isUserClickedLink] [bit] NOT NULL,
	[VelocityNumber] [nvarchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_main]    Script Date: 24/02/2025 5:08:04 PM ******/
CREATE CLUSTERED INDEX [idx_main] ON [dbo].[etl_penUser]
(
	[UserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
