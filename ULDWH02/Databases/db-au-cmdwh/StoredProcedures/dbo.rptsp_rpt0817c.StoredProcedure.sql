USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0817c]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0817c]	
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
--  Name:           dbo.rptsp_rpt0817c
--  Author:         Peter Zhuo
--  Date Created:   20160919
--  Description:    Returns finalised claims in the selected period
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
--                  20160919 - PZ - Created
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
--    @DateRange = 'current Month',
--    @StartDate = null,   
--    @EndDate = null,
--	  @SuperGroup = 'All',
--	  @Group = 'All',
--	  @Subgroup = 'All'


  
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
	fp.FirstPaymentDate as [First Payment Date], -- first payment date
	ce.PerilDesc as [PerilCode],
	ce.EventCountryName,
	ce.EventDate,
	ce.EventDesc,
	p.*,	
	bc.OperationalBenefitGroup,
	isnull(fe.FirstEstimateValue,0) as [FirstEstimateValue],
	isnull(fp.PaidPayment, 0) * (1 - cs.isDeleted) as [PaidPayment],
	case
		when isnull(cp.[Approved Count],0) = (isnull(cp.[Approved Count],0) + isnull(cp.[Declined Count],0)) then 'Approved'
		when (isnull(cp.[Approved Count],0) > 0 and isnull(cp.[Declined Count],0) > 0)  then 'Partial Approved'
		else 'Denied'
	end as [ApproveDeny Flag],
	@DateRange as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from 
	clmSection cs 
left join vclmBenefitCategory bc on bc.BenefitSectionKey = cs.BenefitSectionKey
inner join clmevent ce on cs.EventKey = ce.EventKey
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
	( -- cp
	select
		sum(cp.[Approved Count]) as [Approved Count],
		sum(cp.[Declined Count]) as [Declined Count]
	from vClaimPortfolio cp
	where
		cp.ClaimKey = cl.ClaimKey
	) as cp
outer apply
	( -- fe
	select top 1
		eh.EHCreateDate as FirstEstimateDate,
		eh.EHEstimateValue as FirstEstimateValue,
		eh.EHCreatedBy as FirstEstimateCreator
	from
		dbo.clmEstimateHistory eh
	where
		eh.SectionKey = cs.SectionKey
	order by
		eh.EHCreateDate
	) as fe
 outer apply
	(-- fp
		select
			min(
				case
					when PaymentStatus = 'PAID' then ModifiedDate
					else null
				end
			) as [FirstPaymentDate],
		sum(
                    case
                        when a_cp.PaymentStatus = 'PAID' then a_cp.PaymentAmount
                        else 0
                    end
                ) PaidPayment
		from
			[db-au-cmdwh].dbo.clmPayment a_cp
		where
			a_cp.SectionKey = cs.SectionKey and
			a_cp.isDeleted = 0
	) fp
	outer apply
		( -- pm
		select
			sum(a_ci.PaymentDelta) as [Paid]
		from vclmClaimIncurred a_ci
		where
			a_ci.ClaimKey = cl.ClaimKey
		) as pm
where
	o.CountryKey = @Country and
	(case when cl.FinalisedDate is null then 0 else 1 end) = 1 -- IsFinalised
	and cl.FinalisedDate >= @rptStartDate and cl.FinalisedDate < dateadd(day,1,@rptEndDate)
	and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
	and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
	and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')


end
GO
