USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0722]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0722]	@DateRange varchar(30),
					@StartDate datetime = null,
					@EndDate datetime = null
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0722
--  Author:         Saurabh Date
--  Date Created:   20151130
--  Description:    This stored procedure returns EMC and other premium details along with policy and Insured person details
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20151130 - SD - Created
--					20160106 - SD - Changed the EMCFilter conidtion(Table changed from penPolicyTraveller to penPolicyEMC), also EMC premium calculation is changed to fetch EMC premium at traveller level
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2015-10-01', @EndDate = '2015-10-31'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

/* get reporting dates */
if @DateRange = '_User Defined'
	select  @rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select	@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @DateRange;


select 
		(penPolicyTraveller.FirstName + ' ' + penPolicyTraveller.LastName) [Insured Person],
		penPolicyTraveller.Age [Age of Insured],
		penPolicy.PolicyNumber [Policy Number],
		penPolicy.PolicyKey [Policy Key],
		penPolicy.ProductDisplayName [Product Type],
		penPolicy.AlphaCode [Agency Alpha Code],
		(
		isnull(sum(vPenguinPolicyPremiums.[Sell Price]),0) 
		- isnull(sum(vPenPolicyAddOnPremium.Cancellation),0) 
		- isnull(sum(vPenPolicyAddOnPremium.WinterSport),0) 
		- isnull(sum(vPenPolicyAddOnPremium.RentalCar),0) 
		- isnull(sum(vPenPolicyAddOnPremium.Motorcycle),0) 
		- isnull(sum(vPenPolicyAddOnPremium.Luggage),0) 
		- isnull(sum(vPenPolicyAddOnPremium.Medical),0)  
		- isnull(sum(vPenPolicyAddOnPremium.Electronic),0)
		) [Base Premium],
		isnull(sum(vPenguinPolicyPremiums.[Sell Price]),0) [Total Premium],
		isnull(sum(vPenPolicyAddOnPremium.Medical),0) [EMC Premium],
		isnull(sum(vPenguinPolicyPremiums.[Agency Commission]),0) [Agency Commission],
		isnull(sum(emcApplications.MedicalRisk),0) [Healix Assessment Score],
		@rptStartDate [RPTStartDate],
		@rptEndDate [RPTEndDate]
	from
		penPolicy INNER JOIN penPolicyTransSummary 
			ON (penPolicy.PolicyKey=penPolicyTransSummary.PolicyKey)
		INNER JOIN vPenguinPolicyPremiums
			ON (vPenguinPolicyPremiums.PolicyTransactionKey=penPolicyTransSummary.PolicyTransactionKey)
		INNER JOIN vPenPolicyAddOnPremium
			ON (vPenPolicyAddOnPremium.PolicyTransactionKey=penPolicyTransSummary.PolicyTransactionKey)
		INNER JOIN penPolicyTravellerTransaction
			ON (penPolicyTransSummary.PolicyTransactionKey=penPolicyTravellerTransaction.PolicyTransactionKey)
		LEFT OUTER JOIN penPolicyEMC
			ON (penPolicyEMC.PolicyTravellerTransactionKey=penPolicyTravellerTransaction.PolicyTravellerTransactionKey)
		INNER JOIN penPolicyTraveller
			ON (PenPolicyTraveller.PolicyTravellerKey=penPolicyTravellerTransaction.PolicyTravellerKey)
		LEFT OUTER JOIN emcApplications
			ON (emcApplications.ApplicationKey=penPolicyEMC.EMCApplicationKey)
	where
		penPolicyTransSummary.CountryKey='NZ'
		AND
		penPolicy.StatusDescription<>'Cancelled'
		--AND
		--(
		--penPolicyTraveller.EMCRef  Is Not Null  
		--OR
		--penPolicyTraveller.EMCRef  <>  ''
		--)
		AND
		(
		penPolicyEMC.EMCRef  Is Not Null  
		OR
		penPolicyEMC.EMCRef  <>  ''
		)
		AND
		convert(varchar(10),penPolicy.IssueDate,120) between  convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120)
	group by
		(penPolicyTraveller.FirstName + ' ' + penPolicyTraveller.LastName),
		penPolicyTraveller.Age,
		penPolicy.PolicyNumber,
		penPolicy.PolicyKey,
		penPolicy.ProductDisplayName,
		penPolicy.AlphaCode
	order by
		penPolicy.PolicyKey;
GO
