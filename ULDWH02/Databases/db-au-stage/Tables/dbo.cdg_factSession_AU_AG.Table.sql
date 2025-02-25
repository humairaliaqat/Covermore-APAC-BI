USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_factSession_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_factSession_AU_AG](
	[FactSessionID] [int] NOT NULL,
	[BusinessUnitID] [int] NOT NULL,
	[CampaignID] [int] NOT NULL,
	[SessionCreateDateID] [int] NOT NULL,
	[SessionCreateTimeID] [int] NOT NULL,
	[SessionCloseDateID] [int] NULL,
	[SessionCloseTimeID] [int] NULL,
	[ParentFactSessionID] [int] NULL,
	[AffiliateCodeID] [int] NULL,
	[IsClosed] [int] NULL,
	[IsPolicyPurchased] [int] NOT NULL,
	[Domain] [nvarchar](2) NOT NULL,
	[SessionToken] [uniqueidentifier] NOT NULL,
	[GigyaID] [nvarchar](40) NULL,
	[TotalPoliciesSold] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ClusteredIndex-20240820-204909]    Script Date: 24/02/2025 5:08:03 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20240820-204909] ON [dbo].[cdg_factSession_AU_AG]
(
	[FactSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20240831-025920]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20240831-025920] ON [dbo].[cdg_factSession_AU_AG]
(
	[SessionToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
