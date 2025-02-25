USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrLDAPtest]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrLDAPtest](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](320) NULL,
	[UserName] [nvarchar](320) NULL,
	[ManagerID] [nvarchar](320) NULL,
	[Manager] [nvarchar](320) NULL,
	[EmailAddress] [nvarchar](320) NULL,
	[FirstName] [nvarchar](320) NULL,
	[LastName] [nvarchar](320) NULL,
	[DisplayName] [nvarchar](445) NULL,
	[PreviousName] [nvarchar](640) NULL,
	[CommonName] [nvarchar](640) NULL,
	[Department] [nvarchar](255) NULL,
	[Company] [nvarchar](255) NULL,
	[JobTitle] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Extension] [nvarchar](255) NULL,
	[Mobile] [nvarchar](255) NULL,
	[isActive] [bit] NULL,
	[isLocked] [bit] NULL,
	[isPasswordRequired] [bit] NULL,
	[isUnableToChangePassword] [bit] NULL,
	[isPasswordNeverExpired] [bit] NULL,
	[isPasswordExpired] [bit] NULL,
	[isTemporaryAccount] [bit] NULL,
	[isNormalAccount] [bit] NULL,
	[isInterDomainTrust] [bit] NULL,
	[isWorkstationTrust] [bit] NULL,
	[isServerTrust] [bit] NULL,
	[isTrustedForDelegation] [bit] NULL,
	[isTrustedToAuthDelegation] [bit] NULL,
	[AdminCount] [int] NULL,
	[CreateTimeStamp] [datetime] NULL,
	[ModifyTimeStamp] [datetime] NULL,
	[PasswordLastSet] [datetime] NULL,
	[AccountLockedOutTime] [datetime] NULL,
	[LastLogon] [datetime] NULL,
	[LogonCount] [int] NULL,
	[BadPasswordCount] [int] NULL,
	[LastBadPassword] [datetime] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrLDAP_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrLDAP_BIRowID] ON [dbo].[usrLDAPtest]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_Department]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_Department] ON [dbo].[usrLDAPtest]
(
	[Department] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_DisplayName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_DisplayName] ON [dbo].[usrLDAPtest]
(
	[DisplayName] ASC
)
INCLUDE([UserID],[UserName],[Company],[Department],[JobTitle]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_EmailAddress]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_EmailAddress] ON [dbo].[usrLDAPtest]
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_FirstName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_FirstName] ON [dbo].[usrLDAPtest]
(
	[FirstName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_LastName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_LastName] ON [dbo].[usrLDAPtest]
(
	[LastName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_UserID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_UserID] ON [dbo].[usrLDAPtest]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAP_UserName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAP_UserName] ON [dbo].[usrLDAPtest]
(
	[UserName] ASC
)
INCLUDE([UserID],[DisplayName],[PreviousName],[DeleteDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
