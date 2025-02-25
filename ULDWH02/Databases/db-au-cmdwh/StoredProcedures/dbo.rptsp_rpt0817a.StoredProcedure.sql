USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0817a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0817a]	
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
--  Name:           dbo.rptsp_rpt0817a
--  Author:         Peter Zhuo
--  Date Created:   20160919
--  Description:    Returns top 5 claims benefit sections paid in the selected period
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
--					20170209 - SD - Inculsion of Subgroup selection prompt
--                  
/****************************************************************************************************/

--Uncomment to debug
--Declare
--    @DateRange varchar(30),
--    @StartDate datetime,
--    @EndDate datetime,
--	@Country nvarchar(5),
--	@Supergroup nvarchar(50),
--	@Group nvarchar(50),
--	@Subgroup nvarchar(50)

--Select 
--    @DateRange = 'Last Month',
--    @StartDate = '2015-02-01',
--    @EndDate = '2015-02-04',
--	@Country = 'AU',
--	@Supergroup = 'All',
--	@Group = 'All',
--	@Subgroup = 'All'


declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @DateRange = '_User Defined'
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
            DateRange = @DateRange



select top 5
	clm.ClaimNo,
	ce.PerilDesc,
	ce.EventCountryName,
	bc.OperationalBenefitGroup,
	sum(isnull(si.PaymentDelta,0)) as [Paid],
	@DateRange as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from 
	clmSection cs
inner join clmEvent ce on cs.EventKey = ce.EventKey
inner join clmClaim clm on ce.ClaimKey = clm.ClaimKey
left join vclmBenefitCategory bc on bc.BenefitSectionKey = cs.BenefitSectionKey
left join vclmClaimSectionIncurred si on si.SectionKey = cs.SectionKey
inner join penoutlet o on o.OutletKey = clm.OutletKey and o.OutletStatus = 'current'
where
	o.CountryKey = @Country and
	(o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All') and
	(o.GroupName = @Group or isnull(@Group,'All') = 'All') and
	(o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All') and
	si.IncurredDate >= @rptStartDate and si.IncurredDate < dateadd(day,1,@rptEndDate)
group by
	clm.ClaimNo,
	ce.PerilDesc,
	ce.EventCountryName,
	bc.OperationalBenefitGroup
order by [Paid] desc

End
GO
