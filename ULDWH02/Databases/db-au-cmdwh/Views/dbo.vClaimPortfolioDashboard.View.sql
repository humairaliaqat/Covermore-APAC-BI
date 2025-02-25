USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vClaimPortfolioDashboard]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vClaimPortfolioDashboard] as
select 
    coalesce(o.[Assigned User], c.[Assigned User], 'Unassigned') [Assigned User],
    isnull([Team Leader], 'Unassigned') [Team Leader],
    [Opening Active Claims #],
    [Opening Diarised Claims #],
    [Opening Total Claims #],
    [Opening Active Claims $],
    [Opening Diarised Claims $],
    [Opening Total Claims $],
    [Closing Active Claims #],
    [Closing Diarised Claims #],
    [Closing Total Claims #],
    [Closing Active Claims $],
    [Closing Diarised Claims $],
    [Closing Total Claims $]
from
    (
        select 
            w.AssignedUser [Assigned User],
            count(
                distinct
                case
                    when LastStatus = 'Active' then cl.ClaimNo
                    else null
                end
            ) [Opening Active Claims #],
            count(
                distinct
                case
                    when LastStatus = 'Diarised' then cl.ClaimNo
                    else null
                end
            ) [Opening Diarised Claims #],
            count(distinct cl.ClaimNo) [Opening Total Claims #],
            sum(
                case
                    when LastStatus = 'Active' then isnull([Last Estimate], 0)
                    else 0
                end
            ) [Opening Active Claims $],
            sum(
                case
                    when LastStatus = 'Diarised' then isnull([Last Estimate], 0)
                    else 0
                end
            ) [Opening Diarised Claims $],
            sum(isnull([Last Estimate], 0)) [Opening Total Claims $]
        from
            e5Work w
            inner join clmClaim cl on
                cl.ClaimKey = w.ClaimKey
            cross apply
            (
                select top 1
                    we.StatusName LastStatus
                from
                    e5WorkEvent we 
                where
                    we.Work_Id = w.Work_ID and
                    (
                        we.EventName in ('Changed Work Status', 'Merged Work') or
                        (
                            we.EventName = 'Saved Work' and
                            we.EventUser = 'e5 Launch Service'
                        )
                    ) and
                    we.EventDate < dateadd(day, -1, convert(date, getdate()))
                order by
                    we.EventDate desc
            ) we
            outer apply
            (
                select 
                    sum(isnull(EHEstimateValue, 0)) [Last Estimate]
                from
                    clmSection cs
                    outer apply
                    (
                        select top 1
                            EHEstimateValue
                        from
                            clmEstimateHistory eh
                        where
                            eh.SectionKey = cs.SectionKey and
                            eh.EHCreateDate < dateadd(day, -1, convert(date, getdate()))
                        order by
                            eh.EHCreateDate desc
                    ) eh
                where
                    cs.ClaimKey = cl.ClaimKey and
                    cs.isDeleted = 0
            ) cep
        where
            cl.CreateDate < dateadd(day, -1, convert(date, getdate())) and
            we.LastStatus in ('Active', 'Diarised')
        group by
            w.AssignedUser
    ) o
    full outer join
    (
        select 
            w.AssignedUser [Assigned User],
            count(
                distinct
                case
                    when LastStatus = 'Active' then cl.ClaimNo
                    else null
                end
            ) [Closing Active Claims #],
            count(
                distinct
                case
                    when LastStatus = 'Diarised' then cl.ClaimNo
                    else null
                end
            ) [Closing Diarised Claims #],
            count(distinct cl.ClaimNo) [Closing Total Claims #],
            sum(
                case
                    when LastStatus = 'Active' then isnull([Last Estimate], 0)
                    else 0
                end
            ) [Closing Active Claims $],
            sum(
                case
                    when LastStatus = 'Diarised' then isnull([Last Estimate], 0)
                    else 0
                end
            ) [Closing Diarised Claims $],
            sum(isnull([Last Estimate], 0)) [Closing Total Claims $]
        from
            e5Work w
            inner join clmClaim cl on
                cl.ClaimKey = w.ClaimKey
            cross apply
            (
                select top 1
                    we.StatusName LastStatus
                from
                    e5WorkEvent we 
                where
                    we.Work_Id = w.Work_ID and
                    (
                        we.EventName in ('Changed Work Status', 'Merged Work') or
                        (
                            we.EventName = 'Saved Work' and
                            we.EventUser = 'e5 Launch Service'
                        )
                    ) and
                    we.EventDate < convert(date, getdate())
                order by
                    we.EventDate desc
            ) we
            outer apply
            (
                select 
                    sum(isnull(EHEstimateValue, 0)) [Last Estimate]
                from
                    clmSection cs
                    outer apply
                    (
                        select top 1
                            EHEstimateValue
                        from
                            clmEstimateHistory eh
                        where
                            eh.SectionKey = cs.SectionKey and
                            eh.EHCreateDate < convert(date, getdate())
                        order by
                            eh.EHCreateDate desc
                    ) eh
                where
                    cs.ClaimKey = cl.ClaimKey and
                    cs.isDeleted = 0
            ) cep
        where
            cl.CreateDate < convert(date, getdate()) and
            we.LastStatus in ('Active', 'Diarised')
        group by
            w.AssignedUser
    ) c on
        c.[Assigned User] = o.[Assigned User]
    outer apply
    (
        select top 1 
            tl.DisplayName [Team Leader]
        from
            usrLDAPTeam t
            inner join usrLDAP u on
                u.UserID = t.UserID
            inner join usrLDAP tl on
                tl.UserID = t.TeamLeaderID
        where
            u.DisplayName = coalesce(o.[Assigned User], c.[Assigned User], 'Unassigned')
    ) tl


GO
