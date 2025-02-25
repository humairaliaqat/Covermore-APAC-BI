USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1065]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/****************************************************************************************************/
----  Name				:	rptsp_rpt1065
----  Description		:	Claims Performance Dashboard
----  Author			:	Yi Yang
----  Date Created		:	20190430
----  Parameters		:	
----  Change History	:	
--/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1065]
AS 

begin

    set nocount on

    if object_id('tempdb..#dates') is not null
        drop table #dates

    select 
        d.[Date],
		d.CurMonthStart
    into #dates
    from
        [db-au-cmdwh].[dbo].[Calendar] d
    where
        year(d.[Date]) >= year(dateadd(day, -1, getdate())) - 1 and
        year(d.[Date]) <= year(dateadd(day, -1, getdate()))
		

---  New Claims Volume
    if object_id('tempdb..#volume') is not null
        drop table #volume

    select 
       	convert(date, convert(varchar(7), cl.CreateDate, 120) + '-01') as RegisterDate,
        cg.ClaimGroup,
        count(distinct cl.ClaimKey) as ClaimCount
    into #volume
    from
        [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
        inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select
                case
                    when o.SuperGroupName = 'CBA Group' then 'CBA'
                    else 'Non CBA'
                end ClaimGroup
        ) cg
    where
        o.CountryKey = 'AU' and
        convert(date, cl.CreateDate) in
        (
            select 
                [Date]
            from
                #dates
        )
    group by
        convert(date, convert(varchar(7), cl.CreateDate, 120) + '-01'),
        cg.ClaimGroup

--select * from #volume

---  Claims Payment
    if object_id('tempdb..#incurred') is not null
        drop table #incurred

    select 
       	convert(date, convert(varchar(7), ci.IncurredDate, 120) + '-01') as IncurredDate,
        cg.ClaimGroup,
        sum(ci.IncurredDelta) ClaimCost,
        sum(ci.EstimateDelta) ClaimEstimate,
        sum(ci.PaymentDelta) ClaimPayment,
		sum(case when ci.PaymentDelta < 75000 then ci.PaymentDelta else 0 end) ClaimPaymentExcBig,
		count(distinct cl.ClaimKey) PaymentClaimCount
    into #incurred
    from
        [db-au-cmdwh].[dbo].[clmClaim] cl with(nolock)
        inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select
                case
                    when o.SuperGroupName = 'CBA Group' then 'CBA'
                    else 'Non CBA'
                end ClaimGroup
        ) cg
        inner join [db-au-cmdwh].[dbo].[vclmClaimIncurred] ci with(nolock) on
            ci.Claimkey = cl.ClaimKey

    where
        o.CountryKey = 'AU' and
        ci.IncurredDate in
        (
            select 
                [Date]
            from
                #dates
        )
		and ci.PaymentDelta <> 0
		

    group by
        convert(date, convert(varchar(7), ci.IncurredDate, 120) + '-01'),
        cg.ClaimGroup

--select * from #incurred order by incurreddate

---  Investigation Savings

if object_id('tempdb..#investigation') is not null
    drop table #investigation

select 
    convert(date, convert(varchar(7), w.CompletionDate, 120) + '-01') as InvestigationDate,
	cg.ClaimGroup,
	sum( cast(wp.PropertyValue as money)) as InvSavings
into #investigation
from
	[db-au-cmdwh].[dbo].e5Work as w with(nolock)
	inner join [db-au-cmdwh].[dbo].penOutlet as o with(nolock) on 
		w.AgencyCode = o.AlphaCode 
		and o.OutletStatus = 'Current'
    inner join [db-au-cmdwh].[dbo].e5WorkProperties wp with(nolock) on
		w.Work_ID = wp.Work_ID
	cross apply
    (
        select
            case
                when o.SuperGroupName = 'CBA Group' then 'CBA'
                else 'Non CBA'
            end ClaimGroup
    ) cg
where
	w.Claimkey like 'AU%' and
	w.WorkType = 'Investigation' and
	convert(date, w.CompletionDate) in
    (
        select 
            [Date]
        from
            #dates
    )
	and 
	wp.Property_ID = 'Investigationamountsaved' 
group by
    convert(date, convert(varchar(7), w.CompletionDate, 120) + '-01'),
	cg.ClaimGroup

-------------

select 
    case
        when convert(varchar(7), d.[Date], 120) = convert(varchar(7), dateadd(day, -1, getdate()), 120) then 'Yes'
        else 'No'
    end CurrentMonthFlag,
    convert(date, convert(varchar(8), d.[Date], 120) + '01') MonthPeriod,
    convert(date, d.[Date]) as Date,
    g.[ClaimGroup],
    cyi.*,
    pyi.*,
    cyv.*,
    pyv.*,
	cyis.*,
	pyis.*
from
    #dates d
    cross apply
    (
        select 'CBA' ClaimGroup
        union 
        select 'Non CBA' ClaimGroup
    ) g
    cross apply
    (
        select 
            sum(i.ClaimCost) ClaimCostCY,
            sum(i.ClaimEstimate) ClaimEstimateCY,
            sum(i.ClaimPayment) ClaimPaymentCY,
			sum(i.ClaimPaymentExcBig) ClaimPaymentExcBigCY,
			sum(i.PaymentClaimCount) PaymentClaimCountCY
        from
            #incurred i
        where
            i.IncurredDate = d.Date and
            i.ClaimGroup = g.ClaimGroup 

    ) cyi
    cross apply
    (
        select 
            sum(i.ClaimCost) ClaimCostPY,
            sum(i.ClaimEstimate) ClaimEstimatePY,
            sum(i.ClaimPayment) ClaimPaymentPY,
			sum(i.ClaimPaymentExcBig) ClaimPaymentExcBigPY,
			sum(i.PaymentClaimCount) PaymentClaimCountPY
        from
            #incurred i
        where
            dateadd(year, 1, i.IncurredDate) = d.Date and
            i.ClaimGroup = g.ClaimGroup 
    ) pyi
    cross apply
    (
        select 
            sum(v.ClaimCount) ClaimVolumeCY
        from
            #volume v
        where
            v.RegisterDate = d.Date and
            v.ClaimGroup = g.ClaimGroup 
    ) cyv
    cross apply
    (
        select 
            sum(v.ClaimCount) ClaimVolumePY
        from
            #volume v
        where
            dateadd(year, 1, v.RegisterDate) = d.Date and
            v.ClaimGroup = g.ClaimGroup 
    ) pyv

	cross apply
    (
        select 
            sum(i.InvSavings) InvSavingsCY
        from
            #investigation i
        where
            i.InvestigationDate = d.Date and
            i.ClaimGroup = g.ClaimGroup 
    ) cyis

	cross apply
    (
        select 
            sum(i.InvSavings) InvSavingsPY
        from
            #investigation i
        where
           
			dateadd(year, 1, i.InvestigationDate) = d.Date and
            i.ClaimGroup = g.ClaimGroup 
    ) pyis

	where 
		right(convert(varchar(10), d.date, 120),2) = '01'

end 
GO
