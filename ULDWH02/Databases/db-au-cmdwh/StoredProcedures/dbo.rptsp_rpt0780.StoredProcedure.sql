USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0780]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0780] 
@ReportingPeriod varchar(30),
@StartDate date,
@EndDate date

as 

Begin


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0780
--  Author:         Peter Zhuo
--  Date Created:   20160524
--  Description:    This stored procedure shows healix screening numbers
--					[db-au-cmdwh].dbo.usrRPT0780 is manually populated. Get product details from Lisa Boes (or EMC team)
--
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  
--  Change History: 
--                  20160526 - PZ -	Created
--                  20161104 - PZ -	Added HIF, also moved the temp table to permanent table [dbo].[usrRPT0780]
--					20161117 - LT - Added P&O Cruise products
--					20170216 - LT - INC0024969 - Added Farmers Mutual Group products 
--					20181106 - SD - Added CBA and BW products (We need to change this method, as it involves manual efforts and prone to errors)
/****************************************************************************************************/

set nocount on 

--Uncomment to debug
--declare
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date

--select
--    @ReportingPeriod = 'Last Month',
--    @StartDate = '2017-01-01',
--    @EndDate = '2017-01-31'


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
----------------------------------------------------------

;with cte_alpha as 
(
select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.GroupName like '%AANT%' then
			case 
				when o.OutletType = 'B2B' then 1
				when o.OutletType = 'B2C' then 2
			end
		when o.GroupName like '%NRMA%' then
			case 
				when o.OutletType = 'B2B' then 3
				when o.OutletType = 'B2C' then 4
			end
		when o.GroupName like '%RAA%' then
			case 
				when o.OutletType = 'B2B' then 5
				when o.OutletType = 'B2C' then 6
			end
		when o.GroupName = 'RAC' then
			case 
				when o.OutletType = 'B2B' then 7
				when o.OutletType = 'B2C' then 8
			end
		when o.GroupName = 'RACQ' then
			case 
				when o.OutletType = 'B2B' then 9
				when o.OutletType = 'B2C' then 10
			end
		when o.GroupName = 'RACV' then
			case 
				when o.OutletType = 'B2B' then 11
				when o.OutletType = 'B2C' then 12
			end
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.superGroupName like '%aaa%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.CountryKey = 'AU' then
			case 
				when o.OutletType = 'B2B' then 13
				when o.OutletType = 'B2C' then 14
			end
		when o.CountryKey = 'NZ' then
			case 
				when o.OutletType = 'B2B' then 15
				when o.OutletType = 'B2C' then 16
			end
		when o.CountryKey = 'UK' then
			case 
				when o.OutletType = 'B2B' then 17
				when o.OutletType = 'B2C' then 18
			end
	end as [Product]
from penOutlet o
where
	o.OutletStatus = 'current'
	and o.SuperGroupName like '%Air NZ%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 19
		when o.OutletType = 'B2C' then 20
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'NZ'
	and o.OutletStatus = 'current'
	and o.GroupName like '%AMI%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 21
		when o.OutletType = 'B2C' then 22
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.GroupName like '%Australia Post%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.CountryKey = 'AU' then
			case 
				when o.OutletType = 'B2B' then 23
				when o.OutletType = 'B2C' then 24
			end
		when o.CountryKey = 'NZ' then
			case 
				when o.OutletType = 'B2B' then 25
				when o.OutletType = 'B2C' then 26
			end
		when o.CountryKey = 'UK' then
			case 
				when o.OutletType = 'B2B' then 27
				when o.OutletType = 'B2C' then 28
			end
	end as [Product]
from penOutlet o
where
	o.OutletStatus = 'current'
	and o.SuperGroupName like '%direct%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.CountryKey = 'AU' then
			case 
				when o.OutletType = 'B2B' then 29
				when o.OutletType = 'B2C' then 30
			end
		when o.CountryKey = 'NZ' then
			case 
				when o.OutletType = 'B2B' then 31
				when o.OutletType = 'B2C' then 32
			end
		when o.CountryKey = 'UK' then
			case 
				when o.OutletType = 'B2B' then 33
				when o.OutletType = 'B2C' then 34
			end
	end as [Product]
from penOutlet o
where
	o.OutletStatus = 'current'
	and o.SuperGroupName = 'Flight Centre'
	and o.OutletName not like '%GAP%year%'


union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 35
		when o.OutletType = 'B2C' then 36
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'UK'
	and o.OutletStatus = 'current'
	and o.OutletName like '%GAP%year%'


union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 37
		when o.OutletType = 'B2C' then 38
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.GroupName like '%NRMA%'
	and o.SuperGroupName = 'IAL'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 39
		when o.OutletType = 'B2C' then 40
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'Medibank'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 41
		when o.OutletType = 'B2C' then 42
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.GroupName = 'SGIC'
	
union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 43
		when o.OutletType = 'B2C' then 44
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.GroupName = 'SGIO'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 45
		when o.OutletType = 'B2C' then 46
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'NZ'
	and o.OutletStatus = 'current'
	and o.GroupName = 'state'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 47
		when o.OutletType = 'B2C' then 48
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'NZ'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'Westpac NZ'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 49
		when o.OutletType = 'B2C' then 50
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.GroupName like '%YouGo%'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 52
		when o.OutletType = 'B2C' then 53
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'HIF'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 54
		when o.OutletType = 'B2C' then 55
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'P&O Cruises'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 56
		when o.OutletType = 'B2C' then 57
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'NZ'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'P&O Cruises'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.OutletType = 'B2B' then 58
		when o.OutletType = 'B2C' then 59
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'NZ'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'Farmers Mutual Group'

union all

select
	o.OutletType,
	o.CountryKey,
	o.AlphaCode,
	o.OutletName,
	o.GroupName,
	o.SuperGroupName,
	case 
		when o.SubGroupName like 'CBA Whitelabel%' and o.OutletType = 'B2C' then 60
		when o.SubGroupName like 'CBA Whitelabel%' and o.OutletType = 'B2B' then 61
		when o.SubGroupName like 'CBA NAC%' and o.OutletType = 'B2C' then 62
		when o.SubGroupName like 'CBA NAC%' and o.OutletType = 'B2B' then 63
		when o.GroupCode = 'BW' and o.OutletType = 'B2C' then 64
		when o.GroupCode = 'BW' and o.OutletType = 'B2B' then 65
	end as [Product]
from penOutlet o
where
	o.CountryKey = 'AU'
	and o.OutletStatus = 'current'
	and o.SuperGroupName = 'CBA Group'

)



select
	ca.[Month],
	ta.Product,
	ta.Region,
	ta.[Platform],
	isnull(sum(ca.[Assessment Count]),0) as [Assessment Count],
	@rptStartDate as [Start Date],
	@rptEndDate as [End Date]
from [dbo].[usrRPT0780] ta
outer apply
(
select
	cast((cast(year(a.CreateDate) as nvarchar) + '-' + cast(month(a.CreateDate) as nvarchar) + '-01') as date) as [Month],
	count(a.ApplicationKey) as [Assessment Count]
from emcApplications a
left join cte_alpha ca on a.AgencyCode = ca.AlphaCode
inner join emcApplicants aa on a.ApplicationKey = aa.ApplicationKey
where
	a.CreateDate >= @rptStartDate and a.CreateDate <= @rptEndDate
	and ca.Product = ta.[Product ID]
	and not (aa.FirstName like '%test%' or aa.Surname like '%test%')
group by
	cast((cast(year(a.CreateDate) as nvarchar) + '-' + cast(month(a.CreateDate) as nvarchar) + '-01') as date)
) as ca
where
	ta.[Product ID] <> '51'
group by
	ca.[Month],
	ta.Product,
	ta.Region,
	ta.[Platform]

union all

select
	ca.[Month],
	ta.Product,
	ta.Region,
	ta.[Platform],
	isnull(sum(ca.[Assessment Count]),0) as [Assessment Count],
	@rptStartDate as [Start Date],
	@rptEndDate as [End Date]
from [dbo].[usrRPT0780] ta
cross apply
	(
	select
		cast((cast(year(a.CreateDate) as nvarchar) + '-' + cast(month(a.CreateDate) as nvarchar) + '-01') as date) as [Month],
		count(a.ApplicationKey) as [Assessment Count]
	from emcApplications a
	inner join emcCompanies c on a.CompanyKey = c.CompanyKey
	inner join emcApplicants aa on a.ApplicationKey = aa.ApplicationKey
	where
		a.CreateDate >= @rptStartDate and a.CreateDate <= @rptEndDate
		and c.ParentCompanyName = 'Zurich'
		and not (aa.FirstName like '%test%' or aa.Surname like '%test%')
	group by
		cast((cast(year(a.CreateDate) as nvarchar) + '-' + cast(month(a.CreateDate) as nvarchar) + '-01') as date)
	) as ca
where
	ta.[Product ID] = 51
group by
	ca.[Month],
	ta.Product,
	ta.Region,
	ta.[Platform]

End
GO
