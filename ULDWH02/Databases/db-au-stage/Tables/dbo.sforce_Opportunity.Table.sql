USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sforce_Opportunity]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sforce_Opportunity](
	[AccountId] [nvarchar](18) NULL,
	[Amount] [numeric](18, 2) NULL,
	[Business_Type__c] [nvarchar](255) NULL,
	[CampaignId] [nvarchar](18) NULL,
	[CloseDate] [date] NULL,
	[Contract_Document_Uploaded__c] [bit] NULL,
	[CreatedById] [nvarchar](18) NULL,
	[CreatedDate] [datetime] NULL,
	[Description] [nvarchar](max) NULL,
	[Difficulty__c] [nvarchar](255) NULL,
	[Draft_Agreement_Document_Uploaded__c] [bit] NULL,
	[Estimated_Annual_Revenue__c] [numeric](12, 2) NULL,
	[ExpectedRevenue] [numeric](18, 2) NULL,
	[Financial_Model_Template_Uploaded__c] [bit] NULL,
	[Fiscal] [nvarchar](6) NULL,
	[FiscalQuarter] [int] NULL,
	[FiscalYear] [int] NULL,
	[Follow_Up_Date__c] [date] NULL,
	[ForecastCategory] [nvarchar](40) NULL,
	[ForecastCategoryName] [nvarchar](40) NULL,
	[Gross_Written_Premium__c] [nvarchar](255) NULL,
	[HasOpportunityLineItem] [bit] NULL,
	[Hold__c] [bit] NULL,
	[Id] [nvarchar](18) NULL,
	[IsClosed] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[IsWon] [bit] NULL,
	[LastActivityDate] [date] NULL,
	[LastModifiedById] [nvarchar](18) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[Launch_Date__c] [date] NULL,
	[LeadSource] [nvarchar](40) NULL,
	[Name] [nvarchar](120) NULL,
	[NextStep] [nvarchar](255) NULL,
	[No_of_Contract__c] [numeric](18, 0) NULL,
	[No_of_Draft_Agreement__c] [numeric](18, 0) NULL,
	[No_of_Financial_Model_Template__c] [numeric](18, 0) NULL,
	[No_of_Proposal__c] [numeric](18, 0) NULL,
	[OwnerId] [nvarchar](18) NULL,
	[Pricebook2Id] [nvarchar](18) NULL,
	[Probability] [numeric](3, 0) NULL,
	[Product__c] [nvarchar](255) NULL,
	[Proposal_Document_Uploaded__c] [bit] NULL,
	[RecordTypeId] [nvarchar](18) NULL,
	[Solution__c] [nvarchar](max) NULL,
	[StageName] [nvarchar](40) NULL,
	[SystemModstamp] [datetime] NULL,
	[Type] [nvarchar](40) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
