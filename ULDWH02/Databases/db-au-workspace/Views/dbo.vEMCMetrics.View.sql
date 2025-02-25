USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vEMCMetrics]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vEMCMetrics]
as
select 
    --top 100 e.*
    convert(date, convert(varchar(7), e.AssessedDate, 120) + '-01') [Date],
    ec.CountryKey Country,
    e.AreaName,
    ec.ParentCompanyName,
    ec.CompanyName,
    o.SuperGroupName,
    o.GroupName,
    e.ApplicationType,
    aa.PurchasePath,
    count(e.ApplicationKey) AssessmentCount,
    count(
	    distinct
	    case
		    when e.ApprovalStatus = 'Covered' then e.ApplicationKey
		    else null
	    end
    ) CoveredAssessmentCount,
    count(
	    distinct
	    case
		    when e.ApprovalStatus = 'NotCovered' then e.ApplicationKey
		    else null
	    end
    ) NotCoveredAssessmentCount,
    count(
	    distinct
	    case
		    when aa.PurchasePath = 'Age Approved' then e.ApplicationKey
		    else null
	    end
    ) AgeAssessmentCount,
    count(
	    distinct
	    case
		    when aa.PurchasePath = 'Age Approved' and e.AgeApprovalStatus = 'Approved' then e.ApplicationKey
		    else null
	    end
    ) AgeApprovedAssessmentCount,
    count(
	    distinct
	    case
		    when aa.PurchasePath = 'Age Approved' and e.AgeApprovalStatus = 'Denied' then e.ApplicationKey
		    else null
	    end
    ) AgeDeniedAssessmentCount,
    sum(
        case
            when datediff(day, ReceiveDate, AssessedDate) < 0 then 1
            else datediff(day, ReceiveDate, AssessedDate)
        end
    ) TurnAround
from
    [db-au-cmdwh]..emcApplications e
    cross apply
    (
        select
	        case
		        when isnull(e.AgeApprovalStatus, '') <> '' then 'Age Approved'
		        else 'Leisure'
	        end PurchasePath
    ) aa
    inner join [db-au-cmdwh]..emcCompanies ec on
        ec.CompanyKey = e.CompanyKey
    cross apply
    (
        select
            case
                when ec.ParentCompanyCode = 'TIP' then 'TIP'
                else 'CM'
            end CompanyKey
    ) pc
    left join [db-au-cmdwh]..penOutlet o on
        o.CountryKey = ec.CountryKey and
        o.CompanyKey = pc.CompanyKey and
        o.AlphaCode = e.AgencyCode and
        o.OutletStatus = 'Current'
where
    AssessedDate >= '2013-07-01' and
    AssessedDate <  dateadd(day, 1, convert(date, getdate()))
    --(
    --    select 
    --        LastFiscalStart
    --    from
    --        Calendar
    --    where
    --        [Date] = convert(date, getdate())
    --)
group by
    convert(date, convert(varchar(7), e.AssessedDate, 120) + '-01'),
    ec.CountryKey,
    e.AreaName,
    ec.ParentCompanyName,
    ec.CompanyName,
    o.SuperGroupName,
    o.GroupName,
    e.ApplicationType,
    aa.PurchasePath
    
    
    
--select
--    ScoreType,
--    e.ApplicationID,
--    case
--        when ScoreType = 'Medical Risk' then mgs.Score
--        when ScoreType = 'Healix Medical Risk' then hms.Score
--        when ScoreType = 'Group Score' then gs.Score
--        when ScoreType = 'Individual Condition Score' then ms.Score
--    end Score
--from
--    emcApplications e
--    inner join emcCompanies c on
--        c.CompanyKey = e.CompanyKey
--    cross apply
--    (
--        select
--            @prompt('Score Type','A',{'Medical Risk','Healix Medical Risk','Group Score','Individual Condition Score'},Single,Constrained,Persistent,{'Medical Risk'},User:0) ScoreType,
--            @prompt('Purchase Path','A',{'All','Age Approved','Leisure'},Single,Constrained,Persistent,{'All'},User:1) PurchasePath
--    ) prompts
--    outer apply
--    ( 
--        select 
--            case
--                when ScoreType = 'Medical Risk' then sum(GroupScore) 
--                else null
--            end Score
--        from
--            (
--                select distinct
--                    GroupID,
--                    GroupScore
--                from
--                    emcMedical m
--                where
--                    m.ApplicationKey = e.ApplicationKey
--            ) mg
--    ) mgs
--    outer apply
--    (
--        select 
--            case
--                when ScoreType = 'Healix Medical Risk' then e.MedicalRisk
--                else null
--            end Score
--    ) hms
--    outer apply
--    ( 
--        select distinct
--            case
--                when ScoreType = 'Group Score' then GroupID
--                else null
--            end GroupID,
--            case
--                when ScoreType = 'Group Score' then GroupScore
--                else null
--            end Score
--        from 
--            emcMedical m
--        where
--            m.ApplicationKey = e.ApplicationKey
--    )  gs
--    outer apply
--    ( 
--        select distinct
--            case
--                when ScoreType = 'Individual Condition Score' then Condition
--                else null
--            end Condition,
--            case
--                when ScoreType = 'Individual Condition Score' then MedicalScore
--                else null
--            end Score
--        from 
--            emcMedical m
--        where
--            m.ApplicationKey = e.ApplicationKey
--    )  ms
--where
--    e.ApplicationType = 'Healix' and
--    e.AssessedDateOnly in @dpvalue('D', DP2.DO369) and
--    (
--        PurchasePath = 'All' or
--        (
--            PurchasePath = 'Age Approved' and
--            e.AgeApprovalStatus is not null and
--            e.AgeApprovalStatus <> ''
--        ) or
--        (
--            PurchasePath = 'Leisure' and
--            isnull(e.AgeApprovalStatus, '') = ''
--        )

--        --exists
--        --(
--        --    select null
--        --    from
--        --        penPolicyEMC pe
--        --        inner join penPolicyTravellerTransaction ptt on
--        --            ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
--        --        inner join penPolicyTransSummary pt on
--        --            pt.PolicyTransactionKey = ptt.PolicyTransactionKey
--        --    where
--        --        pe.EMCRef = convert(varchar, e.ApplicationID) and
--        --        pt.PurchasePath = prompts.PurchasePath
--        --)
--    ) and
--    c.CompanyName in @dpvalue('A', DP7.DOa) and
--    e.AreaName in @dpvalue('A', DP9.DO283)    
GO
