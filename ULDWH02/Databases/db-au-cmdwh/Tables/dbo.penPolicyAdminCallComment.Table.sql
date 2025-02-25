USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyAdminCallComment]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyAdminCallComment](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](3) NOT NULL,
	[CallCommentKey] [varchar](41) NOT NULL,
	[PolicyKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[CallCommentID] [int] NOT NULL,
	[PolicyID] [int] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[CRMUserID] [int] NULL,
	[CallDate] [datetime] NULL,
	[CallReason] [nvarchar](50) NULL,
	[CallComment] [nvarchar](max) NULL,
	[DomainID] [int] NULL,
	[CallDateUTC] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAdminCallComment_PolicyKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyAdminCallComment_PolicyKey] ON [dbo].[penPolicyAdminCallComment]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAdminCallComment_CallCommentKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyAdminCallComment_CallCommentKey] ON [dbo].[penPolicyAdminCallComment]
(
	[CallCommentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAdminCallComment_CallDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyAdminCallComment_CallDate] ON [dbo].[penPolicyAdminCallComment]
(
	[CallDate] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAdminCallComment_CRMUserKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyAdminCallComment_CRMUserKey] ON [dbo].[penPolicyAdminCallComment]
(
	[CRMUserKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyAdminCallComment_PolicyNumber]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyAdminCallComment_PolicyNumber] ON [dbo].[penPolicyAdminCallComment]
(
	[PolicyNumber] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
