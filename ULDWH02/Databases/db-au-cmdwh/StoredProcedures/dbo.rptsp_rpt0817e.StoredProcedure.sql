USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0817e]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0817e]	
    @DateRange varchar(30),
    @StartDate datetime,
    @EndDate datetime,
	@Country nvarchar(5),
	@Supergroup nvarchar(50),
	@Group nvarchar(50),
	@Subgroup nvarchar(50)
as

Begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0817e
--  Author:         Peter Zhuo
--  Date Created:   20160919
--  Description:    Returns all claims received in the selected period
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--					@Country: Required. Valid outlet country
--					@Supergroup: Optional. Valid outlet supergroupname or choose 'All'
--					@Group: Optional. Valid outlet groupname or choose 'All'
--					@Subgroup: Optional. Valid outlet subgroupname or choose 'All'
--                  
--  Change History: 
--                  20160927 - PZ - Created
--					20170209 - SD - Inclusion of subgroup selection prompt
--                  
/****************************************************************************************************/



--uncomment to debug  
--declare 
--    @DateRange varchar(30),
--    @StartDate datetime,
--    @EndDate datetime,
--	@Country nvarchar(5),
--	@Supergroup nvarchar(50),
--	@Group nvarchar(50),
--	@Subgroup nvarchar(50)
--select   
--    @Country = 'AU',
--    @DateRange = 'Last Month',
--    @StartDate = null,   
--    @EndDate = null,
--	@SuperGroup = 'All',
--	@Group = 'All',
--	@Subgroup = 'All'


  
declare @rptStartDate datetime  
declare @rptEndDate datetime  
  
/* get reporting dates */  
if @DateRange = '_User Defined'  
    select   
        @rptStartDate = @StartDate,   
        @rptEndDate = @EndDate  
  
else  
    select   
        @rptStartDate = StartDate,   
        @rptEndDate = EndDate  
    from   
        [db-au-cmdwh].dbo.vDateRange  
    where   
        DateRange = @DateRange


select
	o.SuperGroupName,
	o.GroupName,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	cl.ClaimNo,
	cl.ReceivedDate,
	cl.FinalisedDate,
	ce.PerilDesc as [PerilCode],
	ce.EventCountryName,
	ce.EventDate,
	ce.EventDesc,
	p.*,
	pm.Paid,
	pm.[Active Estimate],	
	@DateRange as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from 
	clmevent ce
inner join clmclaim cl on cl.ClaimKey = ce.ClaimKey
inner join penoutlet o on o.outletkey = cl.outletkey and o.outletstatus = 'current'
outer apply
	( -- p
	select top 1
		a_p.ProductCode,
		a_pp.PlanCode,
		a_p.AreaType,
		a_p.IssueDate,
		a_p.TripStart,
		a_p.TripEnd,
		a_p.TripDuration
	from penPolicyTransSummary a_pts
	inner join penpolicy a_p on a_p.PolicyKey = a_pts.PolicyKey
	inner join [db-au-cmdwh].dbo.vpenPolicyPlanCode a_pp on a_pp.PolicyTransactionKey = a_pts.PolicyTransactionKey
	where
		a_pts.PolicyTransactionKey = cl.PolicyTransactionKey 
	) as p
outer apply
	( -- pm
	select
		sum(a_ci.PaymentDelta) as [Paid],
		sum(a_ci.EstimateDelta) as [Active Estimate]
	from vclmClaimIncurred a_ci
	where
		a_ci.ClaimKey = cl.ClaimKey
	) as pm
inner join 
	(-- new
	select distinct
		a_cm.ClaimKey
	from clmClaimIntradayMovement a_cm
	where
		a_cm.IncurredDate >= @rptStartDate and a_cm.IncurredDate < dateadd(day,1,@rptEndDate)
		and a_cm.NewCount > 0
	) as new on new.ClaimKey = cl.ClaimKey


where
	o.CountryKey = @Country
	and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
	and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
	and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')

end
GO
