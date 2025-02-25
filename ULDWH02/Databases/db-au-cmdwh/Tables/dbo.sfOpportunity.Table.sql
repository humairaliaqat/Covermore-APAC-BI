USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfOpportunity]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfOpportunity](
	[OpportunityID] [nvarchar](18) NULL,
	[OpportunityName] [nvarchar](120) NULL,
	[AccountId] [nvarchar](18) NULL,
	[Amount] [numeric](18, 2) NULL,
	[BusinessType] [nvarchar](255) NULL,
	[CampaignId] [nvarchar](18) NULL,
	[CloseDate] [date] NULL,
	[ContractDocumentUploaded] [bit] NULL,
	[CreatedBy] [nvarchar](121) NULL,
	[CreatedDate] [datetime] NULL,
	[Description] [nvarchar](max) NULL,
	[Difficulty] [nvarchar](255) NULL,
	[DraftAgreementDocumentUploaded] [bit] NULL,
	[EstimatedAnnualRevenue] [numeric](12, 2) NULL,
	[ExpectedRevenue] [numeric](18, 2) NULL,
	[FinancialModelTemplateUploaded] [bit] NULL,
	[Fiscal] [nvarchar](6) NULL,
	[FiscalQuarter] [int] NULL,
	[FiscalYear] [int] NULL,
	[FollowUpDate] [date] NULL,
	[ForecastCategory] [nvarchar](40) NULL,
	[ForecastCategoryName] [nvarchar](40) NULL,
	[GrossWrittenPremium] [nvarchar](255) NULL,
	[HasOpportunityLineItem] [bit] NULL,
	[Hold] [bit] NULL,
	[isClosed] [bit] NULL,
	[isDeleted] [bit] NULL,
	[isWon] [bit] NULL,
	[LastActivityDate] [date] NULL,
	[LastModifiedBy] [nvarchar](121) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[LaunchDate] [date] NULL,
	[LeadSource] [nvarchar](40) NULL,
	[NextStep] [nvarchar](255) NULL,
	[NumberOfContract] [numeric](18, 0) NULL,
	[NumberOfDraftAgreement] [numeric](18, 0) NULL,
	[NumberOfFinancialModelTemplate] [numeric](18, 0) NULL,
	[NumberOfProposal] [numeric](18, 0) NULL,
	[OwnerID] [nvarchar](18) NULL,
	[Owner] [nvarchar](121) NULL,
	[PriceBook2ID] [nvarchar](18) NULL,
	[Probability] [numeric](3, 0) NULL,
	[Product] [nvarchar](255) NULL,
	[ProposalDocumentUploaded] [bit] NULL,
	[RecordType] [nvarchar](80) NULL,
	[Solution] [nvarchar](max) NULL,
	[StageName] [nvarchar](40) NULL,
	[SystemModstamp] [datetime] NULL,
	[Type] [nvarchar](40) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfOpportunity_OpportunityID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_sfOpportunity_OpportunityID] ON [dbo].[sfOpportunity]
(
	[OpportunityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfOpportunity_AccountID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfOpportunity_AccountID] ON [dbo].[sfOpportunity]
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfOpportunity_Owner]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfOpportunity_Owner] ON [dbo].[sfOpportunity]
(
	[Owner] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfOpportunity_OwnerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfOpportunity_OwnerID] ON [dbo].[sfOpportunity]
(
	[OwnerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfOpportunity_RecordType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfOpportunity_RecordType] ON [dbo].[sfOpportunity]
(
	[RecordType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
