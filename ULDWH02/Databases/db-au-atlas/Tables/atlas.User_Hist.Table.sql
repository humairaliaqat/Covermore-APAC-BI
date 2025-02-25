USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[User_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[User_Hist](
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
	[IsActive] [bit] NULL,
	[Atlas] [varchar](20) NULL,
	[CompanyName] [varchar](80) NULL,
	[ContactId] [varchar](25) NULL,
	[AccountId] [varchar](25) NULL,
	[Department] [varchar](80) NULL,
	[Division] [varchar](80) NULL,
	[DisableDate] [date] NULL,
	[EnableDate] [date] NULL,
	[SenderEmail] [varchar](255) NULL,
	[SenderName] [varchar](80) NULL,
	[Extension] [varchar](255) NULL,
	[ManagerId] [varchar](25) NULL,
	[MobilePhone] [varchar](255) NULL,
	[Name] [varchar](255) NULL,
	[CommunityNickname] [varchar](40) NULL,
	[PasswordResetAttempt] [numeric](9, 0) NULL,
	[PasswordResetLockoutDate] [datetime] NULL,
	[Phone] [varchar](255) NULL,
	[PortalRole] [varchar](255) NULL,
	[ProfileId] [varchar](25) NULL,
	[UserRoleId] [varchar](25) NULL,
	[FederationIdentifier] [varchar](512) NULL,
	[Title] [varchar](80) NULL,
	[Username] [varchar](80) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_User_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_User_Hist] ON [atlas].[User_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
