USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblUser_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblUser_ukcm](
	[UserId] [int] NOT NULL,
	[OutletId] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](100) NULL,
	[Initial] [nvarchar](50) NOT NULL,
	[ASICNumber] [varchar](50) NULL,
	[AgreementDate] [datetime] NULL,
	[AccessLevel] [int] NOT NULL,
	[AccreditationNumber] [varchar](50) NULL,
	[AllowAdjustPricing] [bit] NULL,
	[Status] [datetime] NULL,
	[AgentCode] [nvarchar](50) NULL,
	[Password] [varbinary](100) NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NULL,
	[MustChangePassword] [bit] NOT NULL,
	[ASICCheck] [int] NULL,
	[AccountLocked] [bit] NOT NULL,
	[LoginFailedTimes] [int] NOT NULL,
	[Email] [nvarchar](200) NULL,
	[IsSuperUser] [bit] NOT NULL,
	[DateOfBirth] [datetime] NULL,
	[LastUpdateUserId] [int] NULL,
	[LastUpdateCrmUserId] [int] NULL,
	[LastLoggedInDateTime] [datetime] NULL,
	[IsAutomatedUser] [bit] NOT NULL,
	[ExternalIdentifier] [nvarchar](100) NULL,
	[IsUserClickedLink] [bit] NOT NULL,
	[VelocityNumber] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblUser_ukcm_UserID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblUser_ukcm_UserID] ON [dbo].[penguin_tblUser_ukcm]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblUser_ukcm_DomainID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblUser_ukcm_DomainID] ON [dbo].[penguin_tblUser_ukcm]
(
	[UserId] ASC
)
INCLUDE([OutletId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penguin_tblUser_ukcm_Login]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblUser_ukcm_Login] ON [dbo].[penguin_tblUser_ukcm]
(
	[Login] ASC,
	[OutletId] ASC
)
INCLUDE([FirstName],[LastName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
