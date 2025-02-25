USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdg_factSession_AU_AG_Finder]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_factSession_AU_AG_Finder](
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
