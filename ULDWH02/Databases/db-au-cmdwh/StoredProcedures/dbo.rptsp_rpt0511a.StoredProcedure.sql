USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0511a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0511a] 

	@currency nvarchar(5),
	@ReportingPeriod varchar(30),
	@StartDate date,
	@EndDate date,
	@ReferenceDate varchar(20),
	@PremiumType varchar(20)

as


/****************************************************************************************************/
--  Name:          rptsp_rpt0511a  - MAS Sales- By channel and Plan
--  Author:        Peter Zhuo
--  Date Created:  20160304
--  Description:   This stored procedure extract malaysia aireline policy data for given parameters
--  Parameters:    @ReportingPeriod:    Value is valid date range
--                 @StartDate:    if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate:      if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--				   @Currency:	  Display currency
--				   @Group:		  Agency Group Name
--				   @ReferenceDate:	Posting Date or Issue Date for Policy
--				   @PremiumType:	Premium or Sell Price
--  
--  Change History: 20160303, PZ, T22719, Recreate RPT0511 in SQL so any user can access to all domain. Currently in Penguin Universe user can only see data from their own domain.
--
/****************************************************************************************************/



--uncomment to debug
--declare 
--	@currency nvarchar(5),
--	@ReportingPeriod varchar(30),
--	@StartDate date,
--	@EndDate date,
--	@ReferenceDate varchar(20),
--	@PremiumType varchar(20)
--select 
--	@currency = 'AUD',
--	@ReportingPeriod = 'Last Month', 
--	@StartDate = null, 
--	@EndDate = null,
--	@ReferenceDate = 'Issue Date',
--	@PremiumType = 'Premium'
---------------------------------------

set nocount on
                                    
declare 
    @rptStartDate datetime,
    @rptEndDate datetime

    --get reporting dates
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod


---------------------------------------


SELECT
  penOutlet.CountryKey,
  case when @ReferenceDate = 'Posting Date' then penPolicyTransSummary.PostingDate else penPolicyTransSummary.IssueDate end as [Date],
  penOutlet.SalesSegment,
  penOutlet.AlphaCode,
  penOutlet.OutletName,
  penPolicyTransSummary.ProductCode,
  penPolicy.ProductDisplayName,
  penPolicy.PlanDisplayName,
  penPolicy.TripType,
  penPolicyTransSummary.PolicyNumber,
  sum(penPolicyTransSummary.GrossPremium) as [Sell Price],
  sum(penPolicyTransSummary.BasePolicyCount) as BasePolicyCount,
  sum(penPolicyTransSummary.Commission) as Commission,
  sum(penPolicyTransSummary.TaxOnAgentCommissionGST) as TaxOnAgentCommissionGST,
  sum(vPenguinPolicyPremiums."Unadjusted Sell Price") as [Unadjusted Sell Price],
  sum(vPenguinPolicyPremiums."Unadjusted Sell Price (excl GST)") as [Unadjusted Sell Price (excl GST)],
  sum(vPenguinPolicyPremiums."Sell Price (excl GST)") as [Sell Price (excl GST)],
  sum(vPenguinPolicyPremiums."NAP (incl Tax)") as [NAP (incl Tax)],
  sum(vPenguinPolicyPremiums.Premium) as [Premium]
  ,@PremiumType as [Premium Type],
  0 as [YAGO GrossPremium],
  0 as [YAGO BasePolicyCount],
  0 as [YAGO Commission],
  0 as [YAGO TaxOnAgentCommissionGST],
  0 as [YAGO Premium]
FROM
penPolicy INNER JOIN penPolicyTransSummary ON (penPolicyTransSummary.PolicyKey=penPolicy.PolicyKey)
INNER JOIN penOutlet ON (penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
INNER JOIN vPenguinPolicyPremiums ON (vPenguinPolicyPremiums.PolicyTransactionKey=penPolicyTransSummary.PolicyTransactionKey)
WHERE
  (
   penOutlet.SuperGroupName  =  'Malaysia Airlines'
   and (
            (	
				@ReferenceDate = 'Posting Date' and
                penPolicyTransSummary.PostingDate >= @rptStartDate and 
                penPolicyTransSummary.PostingDate < dateadd(day, 1, @rptEndDate) 
            )
			or
			(	
				@ReferenceDate = 'Issue Date' and
                penPolicyTransSummary.IssueDate >= @rptStartDate and 
                penPolicyTransSummary.IssueDate < dateadd(day, 1, @rptEndDate) 
            )
        ) 
   AND penOutlet.OutletName  NOT LIKE  '%test%'
   AND penOutlet.OutletStatus = 'Current'
  )
GROUP BY
  penOutlet.CountryKey, 
  case when @ReferenceDate = 'Posting Date' then penPolicyTransSummary.PostingDate else penPolicyTransSummary.IssueDate end,
  penOutlet.SalesSegment, 
  penOutlet.AlphaCode, 
  penOutlet.OutletName, 
  penPolicyTransSummary.ProductCode, 
  penPolicy.ProductDisplayName, 
  penPolicy.PlanDisplayName, 
  penPolicy.TripType, 
  penPolicyTransSummary.PolicyNumber


  union all



  SELECT
  penOutlet.CountryKey,
  case when @ReferenceDate = 'Posting Date' then YAGO_penPolicyTransSummary.YAGOPostingDate else YAGO_penPolicyTransSummary.YAGOIssueDate end as [Date],
  penOutlet.SalesSegment,
  penOutlet.AlphaCode,
  penOutlet.OutletName,
  null as [ProductCode],
  null as [ProductDisplayName],
  null as [PlanDisplayName],
  null as [TripType],
  null as [PolicyNumber],
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  @PremiumType,
  sum(YAGO_penPolicyTransSummary.GrossPremium) as [YAGO GrossPremium],
  sum(YAGO_penPolicyTransSummary.BasePolicyCount) as [YAGO BasePolicyCount],
  sum(YAGO_penPolicyTransSummary.Commission) as [YAGO Commission],
  sum(YAGO_penPolicyTransSummary.TaxOnAgentCommissionGST) as [YAGO TaxOnAgentCommissionGST],
  sum(YAGO_PenguinPolicyPremiums.Premium) as [YAGO Premium]
FROM
penOutlet 
INNER JOIN penPolicyTransSummary  YAGO_penPolicyTransSummary ON (YAGO_penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
INNER JOIN vPenguinPolicyPremiums  YAGO_PenguinPolicyPremiums ON (YAGO_PenguinPolicyPremiums.PolicyTransactionKey=YAGO_penPolicyTransSummary.PolicyTransactionKey)
WHERE
 (
   penOutlet.SuperGroupName  =  'Malaysia Airlines'
   and (
            (	
				@ReferenceDate = 'Posting Date' and
                YAGO_penPolicyTransSummary.YAGOPostingDate >= @rptStartDate and 
                YAGO_penPolicyTransSummary.YAGOPostingDate < dateadd(day, 1, @rptEndDate) 
            )
			or
			(	
				@ReferenceDate = 'Issue Date' and
                YAGO_penPolicyTransSummary.YAGOIssueDate >= @rptStartDate and 
                YAGO_penPolicyTransSummary.YAGOIssueDate < dateadd(day, 1, @rptEndDate) 
            )
        ) 
   AND penOutlet.OutletName  NOT LIKE  '%test%'
   AND penOutlet.OutletStatus = 'Current'
  )
GROUP BY
  penOutlet.CountryKey, 
  case when @ReferenceDate = 'Posting Date' then YAGO_penPolicyTransSummary.YAGOPostingDate else YAGO_penPolicyTransSummary.YAGOIssueDate end,
  penOutlet.SalesSegment, 
  penOutlet.AlphaCode, 
  penOutlet.OutletName
GO
