USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_opportunity]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL061_opportunity]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160209
Prerequisite:   N/A
Description:    transform salesforce opportunity fact
Parameters:		
				
Change History:
                20160209 - LT - Procedure created

*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_sfOpportunity') is not null drop table [db-au-stage].dbo.etl_sfOpportunity
select
	o.[Id] as OpportunityID,
	o.[Name] as OpportunityName,
	o.[AccountId],
	o.[Amount],
	o.[Business_Type__c] as BusinessType,
	o.[CampaignId],
	o.[CloseDate],
	o.[Contract_Document_Uploaded__c] as ContractDocumentUploaded,
	c.CreatedBy,
	o.[CreatedDate],
	o.[Description],
	o.[Difficulty__c] as Difficulty,
	o.[Draft_Agreement_Document_Uploaded__c] as DraftAgreementDocumentUploaded,
	o.[Estimated_Annual_Revenue__c] as EstimatedAnnualRevenue,
	o.[ExpectedRevenue] as ExpectedRevenue,
	o.[Financial_Model_Template_Uploaded__c] as FinancialModelTemplateUploaded,
	o.[Fiscal],
	o.[FiscalQuarter],
	o.[FiscalYear],
	o.[Follow_Up_Date__c] as FollowUpDate,
	o.[ForecastCategory],
	o.[ForecastCategoryName],
	o.[Gross_Written_Premium__c] as GrossWrittenPremium,
	o.[HasOpportunityLineItem],
	o.[Hold__c] as Hold,	
	o.[IsClosed] isClosed,
	o.[IsDeleted] isDeleted,
	o.[IsWon] isWon,
	o.[LastActivityDate],
	lm.LastModifiedBy,
	o.[LastModifiedDate],
	o.[LastReferencedDate],
	o.[LastViewedDate],
	o.[Launch_Date__c] as LaunchDate,
	o.[LeadSource],
	o.[NextStep],
	o.[No_of_Contract__c] as NumberOfContract,
	o.[No_of_Draft_Agreement__c] as NumberOfDraftAgreement,
	o.[No_of_Financial_Model_Template__c] as NumberOfFinancialModelTemplate,
	o.[No_of_Proposal__c] as NumberOfProposal,
	o.OwnerId,
	[owner].[Owner],
	o.[Pricebook2Id] as PriceBook2ID,
	o.[Probability] as Probability,
	o.[Product__c] as Product,
	o.[Proposal_Document_Uploaded__c] as ProposalDocumentUploaded,
	rt.RecordType,
	o.[Solution__c] as Solution,
	o.[StageName],
	o.[SystemModstamp],
	o.[Type]
into [db-au-stage].dbo.etl_sfOpportunity
from
	[db-au-stage].dbo.sforce_Opportunity o
	outer apply
	(
		select top 1 Name as CreatedBy
		from [db-au-stage].dbo.sforce_user
		where ID = o.CreatedById
	) c
	outer apply
	(
		select top 1 Name as LastModifiedBy
		from [db-au-stage].dbo.sforce_user
		where ID = o.LastModifiedById
	) lm
	outer apply
	(
		select top 1 Name as [Owner]
		from [db-au-stage].dbo.sforce_user
		where ID = o.OwnerId
	) [owner]
	outer apply
	(
		select top 1 Name as RecordType
		from [db-au-stage].dbo.sforce_RecordType
		where ID = o.RecordTypeID
	) rt


if object_id('[db-au-cmdwh].dbo.sfOpportunity') is null
begin

	create table [db-au-cmdwh].dbo.sfOpportunity
	(
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
	)
	create clustered index idx_sfOpportunity_OpportunityID on [db-au-cmdwh].dbo.sfOpportunity(OpportunityID)
	create nonclustered index idx_sfOpportunity_AccountID on [db-au-cmdwh].dbo.sfOpportunity(AccountID)
	create nonclustered index idx_sfOpportunity_RecordType on [db-au-cmdwh].dbo.sfOpportunity(RecordType)
	create nonclustered index idx_sfOpportunity_OwnerID on [db-au-cmdwh].dbo.sfOpportunity(OwnerID)
	create nonclustered index idx_sfOpportunity_Owner on [db-au-cmdwh].dbo.sfOpportunity([Owner])

end
else
	delete a
	from 
		[db-au-cmdwh].dbo.sfOpportunity a
		inner join [db-au-stage].dbo.etl_sfOpportunity b on
			a.OpportunityID = b.OpportunityID



insert [db-au-cmdwh].dbo.sfOpportunity with (tablockx)
(
	[OpportunityID],
	[OpportunityName],
	[AccountId],
	[Amount],
	[BusinessType],
	[CampaignId],
	[CloseDate],
	[ContractDocumentUploaded],
	[CreatedBy],
	[CreatedDate],
	[Description],
	[Difficulty],
	[DraftAgreementDocumentUploaded],
	[EstimatedAnnualRevenue],
	[ExpectedRevenue],
	[FinancialModelTemplateUploaded],
	[Fiscal],
	[FiscalQuarter],
	[FiscalYear],
	[FollowUpDate],
	[ForecastCategory],
	[ForecastCategoryName],
	[GrossWrittenPremium],
	[HasOpportunityLineItem],
	[Hold],
	[isClosed],
	[isDeleted],
	[isWon],
	[LastActivityDate],
	[LastModifiedBy],
	[LastModifiedDate],
	[LastReferencedDate],
	[LastViewedDate],
	[LaunchDate],
	[LeadSource],
	[NextStep],
	[NumberOfContract],
	[NumberOfDraftAgreement],
	[NumberOfFinancialModelTemplate],
	[NumberOfProposal],
	[OwnerID],
	[Owner],
	[PriceBook2ID],
	[Probability],
	[Product],
	[ProposalDocumentUploaded],
	[RecordType],
	[Solution],
	[StageName],
	[SystemModstamp],
	[Type]
)
select
	[OpportunityID],
	[OpportunityName],
	[AccountId],
	[Amount],
	[BusinessType],
	[CampaignId],
	[CloseDate],
	[ContractDocumentUploaded],
	[CreatedBy],
	[CreatedDate],
	[Description],
	[Difficulty],
	[DraftAgreementDocumentUploaded],
	[EstimatedAnnualRevenue],
	[ExpectedRevenue],
	[FinancialModelTemplateUploaded],
	[Fiscal],
	[FiscalQuarter],
	[FiscalYear],
	[FollowUpDate],
	[ForecastCategory],
	[ForecastCategoryName],
	[GrossWrittenPremium],
	[HasOpportunityLineItem],
	[Hold],
	[isClosed],
	[isDeleted],
	[isWon],
	[LastActivityDate],
	[LastModifiedBy],
	[LastModifiedDate],
	[LastReferencedDate],
	[LastViewedDate],
	[LaunchDate],
	[LeadSource],
	[NextStep],
	[NumberOfContract],
	[NumberOfDraftAgreement],
	[NumberOfFinancialModelTemplate],
	[NumberOfProposal],
	[OwnerID],
	[Owner],
	[PriceBook2ID],
	[Probability],
	[Product],
	[ProposalDocumentUploaded],
	[RecordType],
	[Solution],
	[StageName],
	[SystemModstamp],
	[Type]
from
	[db-au-stage].dbo.etl_sfOpportunity
GO
