USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vHLORisk]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vHLORisk] as
select --top 1000
    p.PolicyKey,
    case 
        when isnull(datediff(dd, p.IssueDate, p.TripStart), 0) < 0 then 0 
        else isnull(datediff(dd, p.IssueDate, p.TripStart), 0) 
    end LeadTime, 
    case 
        when isnull(TripDuration, 0) < 0 then 0 
        else isnull(TripDuration, 0)
    end Duration, 
    p.IssueDate, 
    convert(bigint, p.CancellationCover) CancellationCover,
    ptv.Age,
    case 
        when isnull(EMCCount, 0) = 0 then 0 
        else 1 
    end EMCPolicy,
    do.GroupName,
    do.StateSalesArea
from 
    [db-au-cmdwh]..penPolicy p with(nolock)
    inner join [db-au-cmdwh]..penOutlet o with(nolock) on 
        o.OutletAlphaKey = p.OutletAlphaKey and 
        o.OutletStatus = 'Current'
    inner join [db-au-cmdwh]..penOutlet lo with(nolock) on 
        lo.OutletStatus = 'Current' and
        lo.OutletKey = o.LatestOutletKey
    cross apply
    (
        select top 1 
            do.SuperGroupName,
            do.GroupName,
            do.StateSalesArea
        from
            [db-au-star]..dimOutlet do with(nolock)
        where
            do.OutletAlphaKey = lo.OutletAlphaKey and
            do.isLatest = 'Y'
    ) do
    cross apply
    (
        select top 1
            Age
        from
            [db-au-cmdwh]..penPolicyTraveller ptv with(nolock)
        where
            p.policykey = ptv.policykey and 
            ptv.isprimary = 1
    ) ptv
    outer apply
    (
        select 
            sum(pt.EMCCount) EMCCount
        from  
            [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
        where  
            pt.PolicyKey = p.PolicyKey
    ) e
where 
    do.SuperGroupName = ('helloworld') and 
    o.CountryKey = 'AU' and
    p.AreaType = 'International'


GO
