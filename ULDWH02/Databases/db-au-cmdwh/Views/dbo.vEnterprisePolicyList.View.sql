USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterprisePolicyList]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vEnterprisePolicyList]
as
select 
    ep.CustomerID,
    p.PolicyNumber,
    p.IssueDate,
    p.PrimaryCountry,
    p.TripStart,
    p.TripEnd,
    p.StatusDescription,
    o.GroupName,
    o.CountryKey Domain,
    case
        when p.StatusDescription like '%cancel%' then p.StatusDescription
        when p.TripEnd < dateadd(day, 1, convert(date, getdate())) then 'Expired'
        when p.TripStart >= dateadd(day, 1, convert(date, getdate())) then 'Has not start'
        else 'On trip'
    end PolicyStatus,
    isnull(TripType, 'Single Trip') TripType,
    ptv.TravellerCount,
    ptv.AdultCount,
    ptv.ChildrenCount,
    ptv.Suburb,
    ptv.State,
    isnull(pt.ClaimCount, 0) ClaimCount
from
    entPolicy ep with(nolock)
    inner join penPolicy p with(nolock) on
        p.PolicyKey = ep.PolicyKey
    inner join penOutlet o with (nolock) on
        o.OutletAlphaKey = p.OutletAlphaKey and
        o.OutletStatus = 'Current'
    outer apply
    (
        select 
            count(cl.ClaimKey) ClaimCount
        from
            penPolicyTransSummary pt with (nolock)
            inner join clmClaim cl with (nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
        where
            pt.PolicyKey = p.PolicyKey
    ) pt
    outer apply
    (
        select 
            max(
                case 
                    when ptv.isPrimary = 1 then ptv.Suburb
                    else null
                end
            ) Suburb,
            max(
                case 
                    when ptv.isPrimary = 1 then ptv.State
                    else null
                end
            ) State,
            sum(1) TravellerCount,
            sum
            (
                case
                    when ptv.isAdult = 1 then 1
                    else 0
                end
            ) AdultCount,
            sum(
                case
                    when ptv.isAdult = 1 then 0
                    else 1
                end
            ) ChildrenCount
        from
            penPolicyTraveller ptv with (nolock)
        where
            ptv.PolicyKey = p.PolicyKey
    ) ptv
GO
