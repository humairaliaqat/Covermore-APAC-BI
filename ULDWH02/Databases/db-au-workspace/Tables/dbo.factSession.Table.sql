USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factSession]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factSession](
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
