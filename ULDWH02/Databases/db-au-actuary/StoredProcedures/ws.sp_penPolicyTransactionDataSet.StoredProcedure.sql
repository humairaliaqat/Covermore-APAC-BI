USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[sp_penPolicyTransactionDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [ws].[sp_penPolicyTransactionDataSet]
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           ws.sp_penPolicyTransactionDataSet
--  Author:         Linus Tor
--  Date Created:   20171023
--	Prerequisite:	[db-au-actuary].[ws].[penPolicy] table exists and populated with data.
--  Description:    This stored procedure inserts [db-au-cmdwh].dbo.penPolicyTransaction data into [db-au-actuary].[ws].[penPolicyTransaction]
--
--  Change History: 20171023 - LT - Created
--					20190412 - LT - Added the following tables:
--										ws.penPolicyTravellerTransaction
--										ws.penPolicyTransAddon
--										ws.penPolicyEMC
--                  
/****************************************************************************************************/

--create penPolicyTransaction table and populate with data that exists in [db-au-actuary].ws.penPolicy
if object_id('[db-au-actuary].ws.penPolicyTransaction') is null
begin
	create table [db-au-actuary].ws.penPolicyTransaction
	(
		CountryKey varchar(2) not null,
		CompanyKey varchar(5) not null,
		PolicyTransactionKey varchar(41) not null,
		PolicyKey varchar(41) null,
		PolicyNoKey varchar(100) null,
		UserKey varchar(41) null,
		UserSKey bigint null,
		PolicyTransactionID int not null,
		PolicyID int not null,
		PolicyNumber varchar(50) null,
		TransactionTypeID int not null,
		TransactionType varchar(50) null,
		GrossPremium money not null,
		IssueDate datetime not null,
		AccountingPeriod datetime not null,
		CRMUserID int null,
		CRMUserName nvarchar(100) null,
		TransactionStatusID int not null,
		TransactionStatus nvarchar(50) null,
		Transferred bit not null,
		UserComments nvarchar(1000) null,
		CommissionTier varchar(50) null,
		VolumeCommission numeric(18, 9) null,
		Discount numeric(18, 9) null,
		isExpo bit not null,
		isPriceBeat bit not null,
		NoOfBonusDaysApplied int null,
		isAgentSpecial bit not null,
		ParentID int null,
		ConsultantID int null,
		isClientCall bit null,
		RiskNet money null,
		AutoComments nvarchar(2000) null,
		TripCost varchar(50) null,
		AllocationNumber int null,
		PaymentDate datetime null,
		TransactionStart datetime null,
		TransactionEnd datetime null,
		StoreCode varchar(10) null,
		DomainKey varchar(41) null,
		DomainID int null,
		IssueDateUTC datetime null,
		PaymentDateUTC datetime null,
		TransactionStartUTC datetime null,
		TransactionEndUTC datetime null,
		ImportDate datetime null,
		TransactionDateTime datetime null,
		TotalCommission money null,
		TotalNet money null,
		PaymentMode nvarchar(20) null,
		PointsRedeemed money null,
		RedemptionReference nvarchar(255) null,
		GigyaId nvarchar(300) null,
		IssuingConsultantID int null,
		LeadTimeDate date null,
		MaxAMTDuration int null
	) 
    create clustered index idx_penPolicyTransaction_PolicyKey on [db-au-actuary].ws.penPolicyTransaction(PolicyKey)
    create nonclustered index idx_penPolicyTransaction_IssueDate on [db-au-actuary].ws.penPolicyTransaction(IssueDate)
    create nonclustered index idx_penPolicyTransaction_PaymentDate on [db-au-actuary].ws.penPolicyTransaction(PaymentDate)
    create nonclustered index idx_penPolicyTransaction_PolicyID on [db-au-actuary].ws.penPolicyTransaction(PolicyID)
    create nonclustered index idx_penPolicyTransaction_PolicyNumber on [db-au-actuary].ws.penPolicyTransaction(PolicyNumber)
    create nonclustered index idx_penPolicyTransaction_PolicyTransactionID on [db-au-actuary].ws.penPolicyTransaction(PolicyTransactionID)
    create nonclustered index idx_penPolicyTransaction_PolicyTransactionKey on [db-au-actuary].ws.penPolicyTransaction(PolicyTransactionKey) include (PolicyNumber,PolicyKey,TransactionType)
    create nonclustered index idx_penPolicyTransaction_UserKey on [db-au-actuary].ws.penPolicyTransaction(UserKey)
    create nonclustered index idx_penPolicyTransaction_UserSKey on [db-au-actuary].ws.penPolicyTransaction(UserSKey)
end
else 
	truncate table [db-au-actuary].ws.penPolicyTransaction


--populate policytransaction data
insert into [db-au-actuary].ws.penPolicyTransaction with (tablockx)
(
    CountryKey,
    CompanyKey,
    DomainKey,
    PolicyTransactionKey,
    PolicyKey,
    PolicyNoKey,
    UserKey,
    UserSKey,
    DomainID,
    PolicyTransactionID,
    PolicyID,
    PolicyNumber,
    TransactionTypeID,
    TransactionType,
    GrossPremium,
    IssueDate,
    IssueDateUTC,
    AccountingPeriod,
    CRMUserID,
    CRMUserName,
    TransactionStatusID,
    TransactionStatus,
    Transferred,
    UserComments,
    CommissionTier,
    VolumeCommission,
    Discount,
    isExpo,
    isPriceBeat,
    NoOfBonusDaysApplied,
    isAgentSpecial,
    ParentID,
    ConsultantID,
    isClientCall,
    RiskNet,
    AutoComments,
    TripCost,
    AllocationNumber,
    PaymentDate,
    TransactionStart,
    TransactionEnd,
    PaymentDateUTC,
    TransactionStartUTC,
    TransactionEndUTC,
    StoreCode,
    ImportDate,
    TransactionDateTime,
    TotalCommission,
    TotalNet,
    PaymentMode,
    PointsRedeemed,
    RedemptionReference,
	GigyaId,
    IssuingConsultantID,
    LeadTimeDate
)
select
    CountryKey,
    CompanyKey,
    DomainKey,
    PolicyTransactionKey,
    PolicyKey,
    PolicyNoKey,
    UserKey,
    UserSKey,
    DomainID,
    PolicyTransactionID,
    PolicyID,
    PolicyNumber,
    TransactionTypeID,
    TransactionType,
    GrossPremium,
    IssueDate,
    IssueDateUTC,
    AccountingPeriod,
    CRMUserID,
    CRMUserName,
    TransactionStatusID,
    TransactionStatus,
    Transferred,
    UserComments,
    CommissionTier,
    VolumeCommission,
    Discount,
    isExpo,
    isPriceBeat,
    NoOfBonusDaysApplied,
    isAgentSpecial,
    ParentID,
    ConsultantID,
    isClientCall,
    RiskNet,
    AutoComments,
    TripCost,
    AllocationNumber,
    PaymentDate,
    TransactionStart,
    TransactionEnd,
    PaymentDateUTC,
    TransactionStartUTC,
    TransactionEndUTC,
    StoreCode,
    ImportDate,
    TransactionDateTime,
    TotalCommission,
    TotalNet,
    PaymentMode,
    PointsRedeemed,
    RedemptionReference,
	GigyaId,
    IssuingConsultantID,
    LeadTimeDate
from
    [db-au-cmdwh].dbo.penPolicyTransaction with(nolock)
where
	CountryKey = 'AU' and
	PolicyKey in (select PolicyKey from [db-au-actuary].ws.penPolicy)


--penPolicyTravellerTransaction
if object_id('[db-au-actuary].ws.penPolicyTravellerTransaction') is null
begin
	create table [db-au-actuary].ws.penPolicyTravellerTransaction
	(
		[CountryKey] [varchar](2) NOT NULL,
		[CompanyKey] [varchar](5) NOT NULL,
		[PolicyTravellerTransactionKey] [varchar](41) NOT NULL,
		[PolicyTransactionKey] [varchar](41) NULL,
		[PolicyTravellerKey] [varchar](41) NULL,
		[PolicyTravellerTransactionID] [int] NOT NULL,
		[PolicyTransactionID] [int] NULL,
		[PolicyTravellerID] [int] NOT NULL,
		[HasEMC] [bit] NOT NULL,
		[TripsTravellerID] [int] NULL,
		[MemberRewardFactor] [decimal](18, 2) NULL,
		[MemberRewardPointsEarned] [money] NULL
	)
	create clustered index idx_penPolicyTravellerTransaction_PolicyTransactionKey on [db-au-actuary].ws.penPolicyTravellerTransaction(PolicyTransactionKey)
	create nonclustered index idx_penPolicyTravellerTransaction_PolicyTravellerTransactionKey on [db-au-actuary].ws.penPolicyTravellerTransaction(PolicyTravellerTransactionKey, PolicyTravellerKey)
end
else
	truncate table [db-au-actuary].ws.penPolicyTravellerTransaction


insert [db-au-actuary].ws.penPolicyTravellerTransaction with(tablockx)
(
	[CountryKey],
	[CompanyKey],
	[PolicyTravellerTransactionKey],
	[PolicyTransactionKey],
	[PolicyTravellerKey],
	[PolicyTravellerTransactionID],
	[PolicyTransactionID],
	[PolicyTravellerID],
	[HasEMC],
	[TripsTravellerID],
	[MemberRewardFactor],
	[MemberRewardPointsEarned]
)
select
	[CountryKey],
	[CompanyKey],
	[PolicyTravellerTransactionKey],
	[PolicyTransactionKey],
	[PolicyTravellerKey],
	[PolicyTravellerTransactionID],
	[PolicyTransactionID],
	[PolicyTravellerID],
	[HasEMC],
	[TripsTravellerID],
	[MemberRewardFactor],
	[MemberRewardPointsEarned]
from
	[db-au-cmdwh].dbo.penPolicyTravellerTransaction with(nolock)
where
	CountryKey = 'AU' and
	PolicyTransactionKey in (select PolicyTransactionKey from [db-au-actuary].ws.penPolicyTransaction)


--create penPolicyTransAddon table and populate with data that exists in [db-au-actuary].ws.penPolicy
if object_id('[db-au-actuary].ws.penPolicyTransAddon') is null
begin
	create table [db-au-actuary].ws.penPolicyTransAddon
	(
		[PolicyTransactionKey] [varchar](41) NULL,
		[AddOnGroup] [nvarchar](50) NULL,
		[AddOnText] [nvarchar](500) NULL,
		[CoverIncrease] [money] NULL,
		[GrossPremium] [money] NULL,
		[UnAdjGrossPremium] [money] NULL,
		[AddonCount] [int] NULL,
		[PolicyKey] [varchar](41) NULL
	)
    create clustered index idx_penPolicyTransAddon_PolicyTransactionKey on [db-au-actuary].ws.penPolicyTransAddon(PolicyTransactionKey)
end
else
	truncate table [db-au-actuary].ws.penPolicyTransAddon


--populate PolicyTransAddon data
insert into [db-au-actuary].ws.penPolicyTransAddon with(tablockx)
(
	[PolicyTransactionKey],
	[AddOnGroup],
	[AddOnText],
	[CoverIncrease],
	[GrossPremium],
	[UnAdjGrossPremium],
	[AddonCount],
	[PolicyKey]
)
select
	[PolicyTransactionKey],
	[AddOnGroup],
	[AddOnText],
	[CoverIncrease],
	[GrossPremium],
	[UnAdjGrossPremium],
	[AddonCount],
	[PolicyKey]
from
	[db-au-cmdwh].dbo.penPolicyTransAddon with(nolock)
where
	CountryKey = 'AU' and
	PolicyTransactionKey in (select PolicyTransactionKey from [db-au-actuary].ws.penPolicyTransaction)



--ws.penPolicyEMC
if object_id('[db-au-actuary].ws.penPolicyEMC') is null
begin
	create table [db-au-actuary].ws.penPolicyEMC
	(
		[CountryKey] [varchar](2) NOT NULL,
		[CompanyKey] [varchar](5) NOT NULL,
		[PolicyEMCKey] [varchar](41) NULL,
		[PolicyTravellerTransactionKey] [varchar](41) NULL,
		[PolicyEMCID] [int] NOT NULL,
		[PolicyTravellerTransactionID] [int] NOT NULL,
		[Title] [nvarchar](50) NULL,
		[FirstName] [nvarchar](100) NULL,
		[LastName] [nvarchar](100) NULL,
		[DOB] [datetime] NOT NULL,
		[EMCRef] [varchar](100) NOT NULL,
		[EMCScore] [numeric](10, 4) NULL,
		[PremiumIncrease] [numeric](18, 5) NULL,
		[isPercentage] [bit] NULL,
		[AddOnID] [int] NULL,
		[DomainKey] [varchar](41) NULL,
		[DomainID] [int] NULL,
		[EMCApplicationKey] [varchar](41) NULL
	)
	create clustered index idx_penPolicyEMC_PolicyEMCKey on [db-au-actuary].ws.penPolicyEMC(PolicyEMCKey)
	create nonclustered index idx_penPolicyEMC_PolicyTravellerTransactionKey on [db-au-actuary].ws.penPolicyEMC(PolicyTravellerTransactionKey)
end
else
	truncate table [db-au-actuary].ws.penPolicyEMC

insert [db-au-actuary].ws.penPolicyEMC with(tablockx)
(
	[CountryKey],
	[CompanyKey],
	[PolicyEMCKey],
	[PolicyTravellerTransactionKey],
	[PolicyEMCID],
	[PolicyTravellerTransactionID],
	[Title],
	[FirstName],
	[LastName],
	[DOB],
	[EMCRef],
	[EMCScore],
	[PremiumIncrease],
	[isPercentage],
	[AddOnID],
	[DomainKey],
	[DomainID],
	[EMCApplicationKey]
)
select
	[CountryKey],
	[CompanyKey],
	[PolicyEMCKey],
	[PolicyTravellerTransactionKey],
	[PolicyEMCID],
	[PolicyTravellerTransactionID],
	[Title],
	[FirstName],
	[LastName],
	[DOB],
	[EMCRef],
	[EMCScore],
	[PremiumIncrease],
	[isPercentage],
	[AddOnID],
	[DomainKey],
	[DomainID],
	[EMCApplicationKey]
from
	[db-au-cmdwh].dbo.penPolicyEMC with(nolock)
where
	CountryKey = 'AU' and
	PolicyTravellerTransactionKey in
	(
		select 
			PolicyTravellerTransactionKey 
		from
			[db-au-actuary].ws.penPolicyTravellerTransaction ptt
	)
GO
