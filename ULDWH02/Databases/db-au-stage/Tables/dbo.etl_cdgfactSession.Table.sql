USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_cdgfactSession]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_cdgfactSession](
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
