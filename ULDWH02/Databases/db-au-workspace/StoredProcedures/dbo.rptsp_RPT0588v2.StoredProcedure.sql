USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_RPT0588v2]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




 CREATE PROCEDURE [dbo].[rptsp_RPT0588v2]

@Country varchar(20),
@ReportingPeriod varchar(30),
@StartDate datetime = null,  
@EndDate datetime = null  
as

begin

 set nocount on  
  
    declare   
        @rptStartDate datetime,  
        @rptEndDate datetime 

		   /* get reporting dates */  
    if @ReportingPeriod = '_User Defined'  
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
            DateRange = @ReportingPeriod  


 --RPT0588
;with 
cte_applicants as
(
    select 
        cc.CaseNo,
        case
            when e.ApplicationID = pea.ApplicationID then cp.PolicyNo
            else null
        end PolicyNo,
        ea.ApplicantHash,
        ea.Title,
        ea.FirstName,
        ea.Surname,
        convert(datetime, decryptbykeyautocert(cert_id('EMCCertificate'), null, ea.DOB, 0, null)) DOB,
        pea.ApplicationKey,
        pea.ApplicationID,
        pea.AssessmentStatus,
        pea.AssessedDateOnly,
        pea.AreaName,
        pea.DepartureDate,
        pea.ReturnDate,
        pea.MedicalRisk
    from
        [db-au-cmdwh].[dbo].cbCase cc
        inner join [db-au-cmdwh].[dbo].cbPolicy cp on
            cp.CaseKey = cc.CaseKey and
            cp.IsMainPolicy = 1
        inner join [db-au-cmdwh].[dbo].penPolicyTravellerTransaction ptt on
            ptt.PolicyTransactionKey = cp.PolicyTransactionKey 
        inner join [db-au-cmdwh].[dbo].penPolicyEMC pe on
            pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
        inner join [db-au-cmdwh].[dbo].emcApplications e on
            e.ApplicationKey = pe.EMCApplicationKey
        inner join [db-au-cmdwh].[dbo].emcApplicants ea on
            ea.ApplicationKey = e.ApplicationKey
        cross apply
        (
            select
                count(pea.ApplicantKey) AssessmentCount
            from
               [db-au-cmdwh].[dbo].emcApplicants pea
                inner join [db-au-cmdwh].[dbo].emcApplications pe on
                    pe.ApplicationKey = pea.ApplicationKey
            where
                pea.ApplicantHash = ea.ApplicantHash and
                pe.AssessedDateOnly >= dateadd(month, -6, convert(date, e.AssessedDateOnly)) and
                pe.AssessedDateOnly <  e.AssessedDateOnly
        ) pemc
        cross apply
        (
            select
                pe.ApplicationKey,
                pe.ApplicationID,
                pe.AssessedDateOnly,
                pe.AreaName,
                pe.DepartureDate,
                pe.ReturnDate,
                pe.MedicalRisk,
                case
                	when pe.ApprovalStatus = 'Policy Denied' then  'Policy Denied'
                	when pe.AgeApprovalStatus = 'Denied' then  'Policy Denied'
                	when pe.ApprovalStatus = 'NotCovered' then 'All EMC Denied'
                	when pe.MedicalDeniedCount = 0 then 'All EMC Approved'
                	when pe.MedicalDeniedCount > 0 and pe.MedicalApprovedCount > 0 then 'Approved & Denied'
                	when pe.MedicalApprovedCount = 0 then 'All EMC Denied'
                	else 'Not Defined'
                end AssessmentStatus
            from
               [db-au-cmdwh].[dbo].emcApplicants pea
                inner join [db-au-cmdwh].[dbo].emcApplications pe on
                    pe.ApplicationKey = pea.ApplicationKey
            where
                pea.ApplicantHash = ea.ApplicantHash and
                pe.AssessedDateOnly >= dateadd(month, -6, convert(date, e.AssessedDateOnly)) and
                pe.AssessedDateOnly <= convert(date, e.AssessedDateOnly)
        ) pea
    where
         --convert(date,cc.OpenDate) between  @PeriodStartDate and @PeiodEndDate 
		 cc.OpenDate >= @rptStartDate and    cc.OpenDate <  dateadd(day, 1, @rptEndDate)
		 and
        cc.CountryKey  in (@Country) and
        pemc.AssessmentCount >= 2
)    
select 
    CaseNo,
    ApplicantHash,
    Title,
    FirstName,
    Surname,
    DOB,
    e.ApplicationID,             
    e.AssessmentStatus,
    e.PolicyNo,
    AssessedDateOnly,
    AreaName,
    DepartureDate,
    ReturnDate,
    MedicalRisk,
    m.MedicalID,
    Condition,       
    ConditionStatus,
    m.MedicalScore,
    mq.QuestionID,
    Question,
    Answer,
	@rptStartDate as startdate,
	@rptEndDate as enddate
from
    cte_applicants e
    inner join [db-au-cmdwh].[dbo].emcMedical m on
        m.ApplicationKey = e.ApplicationKey
    inner join [db-au-cmdwh].[dbo].emcMedicalQuestions mq on    
        mq.MedicalKey = m.MedicalKey
 end 

GO
