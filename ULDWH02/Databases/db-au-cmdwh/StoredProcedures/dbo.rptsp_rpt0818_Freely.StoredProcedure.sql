USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0818_Freely]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0818_Freely]   --'_User Defined','2024-05-05','2024-05-31'        
@ReportingPeriod varchar(30),          
@StartDate date,          
@EndDate date          
as           
          
Begin          
          
/****************************************************************************************************/          
--  Name:           dbo.rptsp_rpt0818          
--  Author:         Peter Zhuo          
--  Date Created:   20160927          
--  Description:    This stored procedure produces details of EMC assessments that match the criterias          
--     required by Meredith Staib on 5th September 2016          
--     TFS 27481          
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period          
--                            
--  Change History:           
--                  20160927 - PZ - Created          
--     20190116    -   SRI -   The procedure have been modified to accomodate new          
--           business rules for EMC denial thresholds.          
--                                         Rule1: scores greater than 5.5 and less than a medical risk of 8.01          
--           Rule2: medical risk greater than 8  

--       20240531  CHG0039147 -- Created This New Stored Procedure to populate only Freely EMC Data
--                     
/****************************************************************************************************/          
          
set nocount on          
          
--Uncomment to debug          
--Declare          
--    @ReportingPeriod varchar(30),          
--    @StartDate date,          
--    @EndDate date          
--Select           
--    @ReportingPeriod = 'Current Month',          
--    @StartDate = '2015-02-01',          
--    @EndDate = '2015-02-04'          
          
          
declare          
    @rptStartDate datetime,          
    @rptEndDate datetime          
          
    if @ReportingPeriod = '_User Defined'          
        select          
            @rptStartDate = @StartDate,          
            @rptEndDate = @EndDate          
          
    else          
        select          
            @rptStartDate = StartDate,          
            @rptEndDate = EndDate          
        from          
            [db-au-cmdwh].[dbo].vDateRange          
        where          
            DateRange = @ReportingPeriod          
          
select          
 ea.CountryKey as [Country],          
 ea.ApplicationID,          
 ea.OutletAlphaKey,          
 case when isnull(ea.AgeApprovalStatus,'') = '' then 'Leisure' else 'Aged' end as [Policy Type],          
 ea.AssessedDateOnly as [AssessdDate],          
 ea.ApprovalStatus,          
 ea.AgeApprovalStatus,          
 ea.MedicalRisk,          
 c1.ApplicationID as [C1 ApplicationID],          
 c2.ApplicationID as [C2 ApplicationID],          
 c3.ApplicationID as [C3 ApplicationID],          
 p.PolicyNumber,          
 @ReportingPeriod as [ReportingPeriod],          
 @rptStartDate as [StartDate],          
 @rptEndDate as [EndDate]    
 --po.GroupName    
from           
 [db-au-cmdwh].[dbo].emcApplications ea          
left join [db-au-star].[dbo].[dimOutlet] o ON o.OutletAlphaKey=ea.OutletAlphaKey and o.isLatest = 'Y'          
LEFT OUTER JOIN [db-au-cmdwh].[dbo].penPolicyEMC ppe ON (ea.ApplicationKey=ppe.EMCApplicationKey)          
LEFT OUTER JOIN [db-au-cmdwh].[dbo].penPolicyTravellerTransaction ptt ON (ppe.PolicyTravellerTransactionKey=ptt.PolicyTravellerTransactionKey)          
LEFT OUTER JOIN [db-au-cmdwh].[dbo].penPolicyTransSummary pts ON (ptt.PolicyTransactionKey=pts.PolicyTransactionKey)          
left join [db-au-cmdwh].[dbo].penpolicy p on p.PolicyKey = pts.PolicyKey      
LEFT JOIN [db-au-cmdwh].[dbo].penOutlet po on p.OutletSKey=po.OutletSKey --and OutletStatus='Current'             
outer apply          
 (          
 SELECT distinct          
  a_ea.ApplicationID          
 FROM          
  [db-au-cmdwh].[dbo].emcMedical a_em          
 RIGHT OUTER JOIN [db-au-cmdwh].[dbo].emcApplications a_ea ON (a_ea.ApplicationKey= a_em.ApplicationKey)          
 WHERE          
  (            a_ea.CountryKey  in ('AU','NZ')          
  AND a_em.MedicalScore  >  5.5 AND a_ea.MedicalRisk < 8.01          
  and isnull(a_ea.AgeApprovalStatus,'') = ''          
  and a_ea.AssessedDateOnly >= '2016-08-31'          
  and a_ea.AssessedDateOnly > @rptStartDate and a_ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)          
  and a_ea.ApplicationKey = ea.ApplicationKey          
  )          
 ) as c1          
outer apply          
 (          
 select distinct          
  a_ea.ApplicationID          
 from           
  [db-au-cmdwh].[dbo].emcApplications a_ea          
 where          
  a_ea.CountryKey  in ('AU','NZ')          
  and a_ea.MedicalRisk > 8          
  and isnull(a_ea.AgeApprovalStatus,'') = ''          
  and a_ea.AssessedDateOnly >= '2016-08-31'          
  and a_ea.AssessedDateOnly > @rptStartDate and a_ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)          
  and a_ea.ApplicationKey = ea.ApplicationKey          
 ) as c2          
outer apply          
 (          
 select distinct          
  a_ea.ApplicationID          
 from           
  [db-au-cmdwh].[dbo].emcApplications a_ea          
 where          
  a_ea.CountryKey  in ('AU','NZ')          
  and a_ea.MedicalRisk > 5          
  and isnull(a_ea.AgeApprovalStatus,'') <> ''          
  and a_ea.AssessedDateOnly >= '2016-08-31'          
  and a_ea.AssessedDateOnly > @rptStartDate and a_ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)          
  and a_ea.ApplicationKey = ea.ApplicationKey          
 ) as c3          
where     
 po.GroupName='Freely'  AND    
 ea.CountryKey in ('AU','NZ')          
 and ea.AssessedDateOnly > @rptStartDate and ea.AssessedDateOnly < dateadd(day,1,@rptEndDate)          
 and           
  (          
  c1.ApplicationID is not null          
  or           
  c2.ApplicationID is not null          
  or          
  c3.ApplicationID is not null          
  )          
 and isnull(o.Channel,'') not in ('Website White-Label','Mobile')      
 --and o.GroupName='Freely'    
          
 order by 2          
End 
GO
