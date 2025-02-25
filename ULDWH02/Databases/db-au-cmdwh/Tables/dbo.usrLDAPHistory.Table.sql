USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrLDAPHistory]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrLDAPHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](320) NULL,
	[FirstName] [nvarchar](320) NULL,
	[LastName] [nvarchar](320) NULL,
	[DisplayName] [nvarchar](445) NULL,
	[Department] [nvarchar](255) NULL,
	[Company] [nvarchar](255) NULL,
	[JobTitle] [nvarchar](255) NULL,
	[CreateDateTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrLDAPHistory_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrLDAPHistory_BIRowID] ON [dbo].[usrLDAPHistory]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAPHistory_DisplayName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAPHistory_DisplayName] ON [dbo].[usrLDAPHistory]
(
	[DisplayName] ASC
)
INCLUDE([UserID],[Company],[Department],[JobTitle]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrLDAPHistory_UserID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrLDAPHistory_UserID] ON [dbo].[usrLDAPHistory]
(
	[UserID] ASC,
	[CreateDateTime] DESC
)
INCLUDE([FirstName],[LastName],[Company],[Department],[JobTitle]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
