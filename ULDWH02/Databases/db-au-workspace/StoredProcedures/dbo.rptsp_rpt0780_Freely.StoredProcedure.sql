USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0780_Freely]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0780_Freely]       
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
--     [db-au-cmdwh].dbo.usrRPT0780 is manually populated. Get product details from Lisa Boes (or EMC team)      
--      
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period      
--                        
--  Change History:       
--                  20160526 - PZ - Created      
--                  20161104 - PZ - Added HIF, also moved the temp table to permanent table [dbo].[usrRPT0780]      
--     20161117 - LT - Added P&O Cruise products      
--     20170216 - LT - INC0024969 - Added Farmers Mutual Group products       
--     20181106 - SD - Added CBA and BW products (We need to change this method, as it involves manual efforts and prone to errors)      
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
  when o.CountryKey = 'AU' then      
   case       
    when o.OutletType = 'B2B' then 1      
    when o.OutletType = 'B2C' then 2      
   end      
  when o.CountryKey = 'NZ' then      
   case       
    when o.OutletType = 'B2B' then 3      
    when o.OutletType = 'B2C' then 4      
   end      
  when o.CountryKey = 'UK' then      
   case       
    when o.OutletType = 'B2B' then 5      
    when o.OutletType = 'B2C' then 6      
   end      
 end as [Product]      
from penOutlet o      
where      
 o.OutletStatus = 'current'      
 and o.GroupName like '%Freely%'      
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
 and a.ApplicationKey in     
  (    
  select EMCApplicationKey from penPolicyTravellerTransaction      
as pp with(nolock) inner join penPolicyEMC  as pe with(nolock) on pp.PolicyTravellerTransactionKey=pe.PolicyTravellerTransactionKey      
inner join penPolicyTraveller as Pt with(nolock) on pt.PolicyTravellerKey=pp.PolicyTravellerKey      
inner join penPolicy as po with(nolock) on  po.PolicyKey=pt.PolicyKey      
inner join penOutlet as pu with(nolock) on pu.OutletSKey=po.OutletSKey  and OutletStatus='Current'    
where   pu.GroupName='Freely'    
  )    
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
  and a.ApplicationKey in     
  (    
  select EMCApplicationKey from penPolicyTravellerTransaction      
as pp with(nolock) inner join penPolicyEMC  as pe with(nolock) on pp.PolicyTravellerTransactionKey=pe.PolicyTravellerTransactionKey      
inner join penPolicyTraveller as Pt with(nolock) on pt.PolicyTravellerKey=pp.PolicyTravellerKey      
inner join penPolicy as po with(nolock) on  po.PolicyKey=pt.PolicyKey      
inner join penOutlet as pu with(nolock) on pu.OutletSKey=po.OutletSKey  and OutletStatus='Current'    
where   pu.GroupName='Freely'    
  )    
    
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
