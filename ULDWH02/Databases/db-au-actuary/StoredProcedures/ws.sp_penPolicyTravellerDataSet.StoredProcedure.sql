USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[sp_penPolicyTravellerDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ws].[sp_penPolicyTravellerDataSet]
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           ws.sp_penPolicyTravellerDataSet
--  Author:         Linus Tor
--  Date Created:   20171023
--	Prerequisite:	[db-au-actuary].[ws].[penPolicy] table exists and populated with data.
--  Description:    This stored procedure inserts [db-au-cmdwh].dbo.penPolicyTraveller data into [db-au-actuary].[ws].[penPolicyTraveller]
--
--  Change History: 20171023 - LT - Created
--                  
/****************************************************************************************************/

--create penPolicyTraveller table and populate with data that exists in [db-au-actuary].ws.penPolicy
if object_id('[db-au-actuary].ws.penPolicyTraveller') is null
begin

    create table [db-au-actuary].ws.penPolicyTraveller
    (
		[CountryKey] [varchar](2) NOT NULL,
		[CompanyKey] [varchar](5) NOT NULL,
		[PolicyTravellerKey] [varchar](41) NULL,
		[PolicyKey] [varchar](41) NULL,
		[QuoteCustomerKey] [varchar](41) NULL,
		[PolicyTravellerID] [int] NOT NULL,
		[PolicyID] [int] NOT NULL,
		[QuoteCustomerID] [int] NOT NULL,
		[Title] [nvarchar](50) NULL,
		[FirstName] [nvarchar](100) NULL,
		[LastName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[Age] [int] NULL,
		[isAdult] [bit] NULL,
		[AdultCharge] [numeric](18, 5) NULL,
		[isPrimary] [bit] NULL,
		[AddressLine1] [nvarchar](100) NULL,
		[AddressLine2] [nvarchar](100) NULL,
		[PostCode] [nvarchar](50) NULL,
		[Suburb] [nvarchar](50) NULL,
		[State] [nvarchar](100) NULL,
		[Country] [nvarchar](100) NULL,
		[HomePhone] [varchar](50) NULL,
		[WorkPhone] [varchar](50) NULL,
		[MobilePhone] [varchar](50) NULL,
		[EmailAddress] [nvarchar](255) NULL,
		[OptFurtherContact] [bit] NULL,
		[MemberNumber] [nvarchar](25) NULL,
		[DomainKey] [varchar](41) NULL,
		[DomainID] [int] NULL,
		[EMCRef] [varchar](100) NULL,
		[EMCScore] [numeric](10, 4) NULL,
		[DisplayName] [nvarchar](100) NULL,
		[AssessmentType] [varchar](20) NULL,
		[EmcCoverLimit] [numeric](18, 2) NULL,
		[MarketingConsent] [bit] NULL,
		[Gender] [nchar](2) NULL,
		[PIDType] [nvarchar](100) NULL,
		[PIDCode] [nvarchar](50) NULL,
		[PIDValue] [nvarchar](256) NULL,
		[MemberRewardPointsEarned] [money] NULL,
		[StateOfArrival] [varchar](100) NULL,
		[MemberTypeId] [int] NULL,
		[TicketType] [nvarchar](50) NULL,
		[VelocityNumber] [nvarchar](50) NULL
    )

    create clustered index idx_penPolicyTraveller_PolicyKey on [db-au-actuary].ws.penPolicyTraveller(PolicyKey)
    create nonclustered index idx_penPolicyTraveller_EMCRef on [db-au-actuary].ws.penPolicyTraveller(EMCRef)
    create nonclustered index idx_penPolicyTraveller_MemberNumber on [db-au-actuary].ws.penPolicyTraveller(MemberNumber,PolicyTravellerID) include (PolicyKey)
    create nonclustered index idx_penPolicyTraveller_Names on [db-au-actuary].ws.penPolicyTraveller(FirstName,LastName,DOB,PolicyTravellerID) include (CountryKey,PolicyKey)
    create nonclustered index idx_penPolicyTraveller_PolicyKeyTraveller on [db-au-actuary].ws.penPolicyTraveller(PolicyKey,isPrimary) include (PolicyTravellerKey,FirstName,LastName,DOB,MemberNumber,PolicyTravellerID,State,AddressLine1,Suburb)
    create nonclustered index idx_penPolicyTraveller_PolicyTravellerKey on [db-au-actuary].ws.penPolicyTraveller(PolicyTravellerKey)

end
else
	truncate table [db-au-actuary].ws.penPolicyTraveller

--populate policytraveller data
insert into [db-au-actuary].ws.penPolicyTraveller with (tablockx)
(
	[CountryKey],
	[CompanyKey],
	[PolicyTravellerKey],
	[PolicyKey],
	[QuoteCustomerKey],
	[PolicyTravellerID],
	[PolicyID],
	[QuoteCustomerID],
	[Title],
	[FirstName],
	[LastName],
	[DOB],
	[Age],
	[isAdult],
	[AdultCharge],
	[isPrimary],
	[AddressLine1],
	[AddressLine2],
	[PostCode],
	[Suburb],
	[State],
	[Country],
	[HomePhone],
	[WorkPhone],
	[MobilePhone],
	[EmailAddress],
	[OptFurtherContact],
	[MemberNumber],
	[DomainKey],
	[DomainID],
	[EMCRef],
	[EMCScore],
	[DisplayName],
	[AssessmentType],
	[EmcCoverLimit],
	[MarketingConsent],
	[Gender],
	[PIDType],
	[PIDCode],
	[PIDValue],
	[MemberRewardPointsEarned],
	[StateOfArrival],
	[MemberTypeId],
	[TicketType],
	[VelocityNumber]
)
select
	[CountryKey],
	[CompanyKey],
	[PolicyTravellerKey],
	[PolicyKey],
	[QuoteCustomerKey],
	[PolicyTravellerID],
	[PolicyID],
	[QuoteCustomerID],
	[Title],
	[FirstName],
	[LastName],
	[DOB],
	[Age],
	[isAdult],
	[AdultCharge],
	[isPrimary],
	[AddressLine1],
	[AddressLine2],
	[PostCode],
	[Suburb],
	[State],
	[Country],
	[HomePhone],
	[WorkPhone],
	[MobilePhone],
	[EmailAddress],
	[OptFurtherContact],
	[MemberNumber],
	[DomainKey],
	[DomainID],
	[EMCRef],
	[EMCScore],
	[DisplayName],
	[AssessmentType],
	[EmcCoverLimit],
	[MarketingConsent],
	[Gender],
	[PIDType],
	[PIDCode],
	[PIDValue],
	[MemberRewardPointsEarned],
	[StateOfArrival],
	[MemberTypeId],
	[TicketType],
	[VelocityNumber]
from
    [db-au-cmdwh].dbo.penPolicyTraveller with(nolock)
where
	CountryKey = 'AU' and
	PolicyKey in (select PolicyKey from [db-au-actuary].ws.penPolicy)
GO
