USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgfactSession]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgfactSession](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[factSessionID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[ParentFactSessionID] [int] NULL,
	[SessionCreateDate] [datetime] NULL,
	[SessionCloseDate] [datetime] NULL,
	[AffiliateCode] [varchar](100) NULL,
	[IsClosed] [int] NULL,
	[IsPolicyPurchased] [int] NOT NULL,
	[Domain] [nvarchar](2) NOT NULL,
	[SessionToken] [uniqueidentifier] NOT NULL,
	[GigyaID] [nvarchar](40) NULL,
	[TotalPoliciesSold] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactSession_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgfactSession_BIRowID] ON [dbo].[cdgfactSession]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactSession_businessunitid]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactSession_businessunitid] ON [dbo].[cdgfactSession]
(
	[BusinessUnitID] ASC,
	[SessionCreateDate] ASC
)
INCLUDE([factSessionID],[IsPolicyPurchased]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactSession_factSessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactSession_factSessionID] ON [dbo].[cdgfactSession]
(
	[factSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactSession_SessionCreateDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactSession_SessionCreateDate] ON [dbo].[cdgfactSession]
(
	[SessionCreateDate] ASC
)
INCLUDE([factSessionID],[BusinessUnitID],[Domain],[AffiliateCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactSession_SessionToken]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactSession_SessionToken] ON [dbo].[cdgfactSession]
(
	[SessionToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
