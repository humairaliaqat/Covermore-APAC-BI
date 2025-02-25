USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfUser]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfUser](
	[UserID] [nvarchar](18) NULL,
	[UserType] [nvarchar](40) NULL,
	[Username] [nvarchar](80) NULL,
	[Name] [nvarchar](121) NULL,
	[FirstName] [nvarchar](40) NULL,
	[LastName] [nvarchar](80) NULL,
	[Alias] [nvarchar](8) NULL,
	[IsActive] [bit] NULL,
	[BDM] [nvarchar](250) NULL,
	[Manager] [nvarchar](121) NULL,
	[Profile] [nvarchar](255) NULL,
	[RoleType] [nvarchar](255) NULL,
	[CommunityNickname] [nvarchar](40) NULL,
	[CompanyName] [nvarchar](80) NULL,
	[CRMUser] [nvarchar](80) NULL,
	[Department] [nvarchar](80) NULL,
	[Division] [nvarchar](80) NULL,
	[Title] [nvarchar](80) NULL,
	[Street] [nvarchar](255) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](80) NULL,
	[Postcode] [nvarchar](20) NULL,
	[Country] [nvarchar](80) NULL,
	[Phone] [nvarchar](40) NULL,
	[MobilePhone] [nvarchar](40) NULL,
	[Fax] [nvarchar](40) NULL,
	[Email] [nvarchar](128) NULL,
	[CreatedBy] [nvarchar](121) NULL,
	[CreatedDate] [datetime] NULL,
	[LastLoginDate] [datetime] NULL,
	[LastModifiedBy] [nvarchar](121) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[Timezone] [nvarchar](40) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_UserID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_sfUser_UserID] ON [dbo].[sfUser]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_sfUser_isActive]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_isActive] ON [dbo].[sfUser]
(
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_Manager]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_Manager] ON [dbo].[sfUser]
(
	[Manager] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_Name]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_Name] ON [dbo].[sfUser]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_RoleType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_RoleType] ON [dbo].[sfUser]
(
	[RoleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_UserName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_UserName] ON [dbo].[sfUser]
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfUser_UserType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfUser_UserType] ON [dbo].[sfUser]
(
	[UserType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
