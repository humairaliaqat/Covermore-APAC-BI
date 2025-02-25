USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vClaimPortfolioStatistic]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[vClaimPortfolioStatistic] 
as

/****************************************************************************************************/
--  Name:          vClaimPortfolioStatistic
--  Author:        Leonardus Setyabudi
--  Date Created:  20150114
--  Description:   This view captures claims and e5 statistics
--  
--  Change History: 20150114 - LS - Created
--                  20150527 - LT - TFS 16595, added following columns:
--									[MTD Completed],
--									[MTD Diarised],
--									[MTD Reopened],
--									[MTD Declined],
--									[MTD Complaints],
--									[MTD IDR],
--									[MTD Call Backs]
--					20150709 - LT - TFS 16595, amended Lifespan criteria to include all Active, Diairised,
--									and (Completed in MTD).
--                  20150729 - LS - Lifespan is based on Absolute Age
--                  20150914 - LS - merge v3
--                  20151109 - LS - T20443, all [MTD *] calculations were incorrect
--                  20151110 - LS - T20443, change MTD Reopen definition, only for claims in MTD Closed
--                  20151202 - LS - INC0000129, change MTD reference to MTD of yesterday
--
/****************************************************************************************************/

select 
    coalesce(summ.Country, y.Country, age.Country, 'AU') Country,
    coalesce(summ.[Assigned User], y.[Assigned User], age.[Assigned User], 'Unassigned') [Assigned User],
    isnull([Team Leader], 'Unassigned') [Team Leader],
    isnull([Active Claims #], 0) [Active Claims #],
    isnull([Diarised Claims #], 0) [Diarised Claims #],
    isnull([Total #], 0) [Total #],
    isnull([Active Claims $], 0) [Active Claims $],
    isnull([Diarised Claims $], 0) [Diarised Claims $],
    isnull([Total $], 0) [Total $],
    isnull([New Claims #], 0) [New Claims #],
    isnull([Claims Diarised #], 0) [Claims Diarised #],
    isnull([Claims Completed #], 0) [Claims Completed #],
    isnull([New Claims $], 0) [New Claims $],
    isnull([Claims Diarised $], 0) [Claims Diarised $],
    isnull([Claims Completed $], 0) [Claims Completed $],
    isnull([Oldest Claim Age], 0) [Oldest Claim Age],
    isnull([Claim Count], 0) [Lifespan Claim Count],
    isnull([Lifespan], 0) [Lifespan Total],
    isnull([Yesterday Closed], 0) [Yesterday Closed],
    isnull([MTD Completed], 0) [MTD Completed],
    isnull([MTD Diarised], 0) [MTD Diarised],
    isnull([MTD Reopened], 0) [MTD Reopened],
    isnull([MTD Declined], 0) [MTD Declined],
    isnull([MTD Complaints], 0) [MTD Complaints],
    isnull([MTD IDR], 0) [MTD IDR],
    isnull([MTD Call Backs], 0) [MTD Call Backs]    
from
    (
        select 
            Country,
            [Assigned User],
            count(
                distinct
                case
                    when [Status] = 'Active' then [Claim Number]
                    else null
                end
            ) [Active Claims #],
            count(
                distinct
                case
                    when [Status] = 'Diarised' then [Claim Number]
                    else null
                end
            ) [Diarised Claims #],
            count(distinct [Claim Number]) [Total #],
            sum(
                case
                    when [Status] = 'Active' then [Current Estimate]
                    else 0
                end
            ) [Active Claims $],
            sum(
                case
                    when [Status] = 'Diarised' then [Current Estimate]
                    else 0
                end
            ) [Diarised Claims $],
            sum([Current Estimate]) [Total $],
            max([Absolute Age]) [Oldest Claim Age]
        from
            vClaimPortfolio
        where
            [Status] in ('Active', 'Diarised') and
            [Date Registered] < convert(date, getdate())
        group by
            Country,
            [Assigned User]
    ) summ
    full join 
    (
        select 
            Country,
            [Assigned User],
            count(
                distinct
                case
                    when 
                        [Date Registered] >= dateadd(day, -1, convert(date, getdate())) and
                        [Date Registered] <  convert(date, getdate())
                    then [Claim Number]
                    else null
                end
            ) [New Claims #],
            count(
                distinct
                case
                    when 
                        [Status] = 'Diarised' and
                        [Status Change Date] >= dateadd(day, -1, convert(date, getdate())) and
                        [Status Change Date] <  convert(date, getdate())
                    then [Claim Number]
                    else null
                end
            ) [Claims Diarised #],
            count(
                distinct
                case
                    when [Status] = 'Complete' and
                         [Completion Date] >= dateadd(day, -1, convert(date, getdate())) and
						 [Completion Date] < convert(date, getdate())                    
                    then [Claim Number]
                    else null
                end
            ) [Claims Completed #],
            sum(
                distinct
                case
                    when 
                        [Date Registered] >= dateadd(day, -1, convert(date, getdate())) and
                        [Date Registered] <  convert(date, getdate())
                    then [Current Estimate]
                    else 0
                end
            ) [New Claims $],
            sum(
                distinct
                case
                    when 
                        [Status] = 'Diarised' and
                        [Status Change Date] >= dateadd(day, -1, convert(date, getdate())) and
                        [Status Change Date] <  convert(date, getdate())
                    then [Current Estimate]
                    else 0
                end
            ) [Claims Diarised $],
            sum(
                distinct
                case
                    when [Status] = 'Complete' and
                         [Completion Date] >= dateadd(day, -1, convert(date, getdate())) and
						 [Completion Date] < convert(date, getdate())
                    then [Current Estimate]
                    else 0
                end
            ) [Claims Completed $],
            count(
				distinct
				case
					when 
						[Status] = 'Complete' and
						[Completion Date] >= dateadd(day, -1, convert(date, getdate())) and
						[Completion Date] < convert(date,getdate())
					then [Claim Number]
					else null
				end
			) [Yesterday Closed]
        from
            vClaimPortfolio
        where
            [Date Registered] < convert(date, getdate()) and
            (
                [Status] in ('Active', 'Diarised') or
                (
                    [Status] = 'Complete' and
                    [Completion Date] >= dateadd(day, -1, convert(date, getdate()))
                )
            )
        group by
            Country,
            [Assigned User]
    ) y on
        y.Country = summ.Country and
        y.[Assigned User] = summ.[Assigned User]
    full join 
    (
        select 
            Country,
            [Assigned User],
            count([Claim Number]) [Claim Count],
            sum([Absolute Age]) [Lifespan],
            avg([Absolute Age] * 1.0) [Avg Lifespan]
        from
            vClaimPortfolio
        where
            [Date Registered] < convert(date, getdate()) and
			(																--20150709_LT: include active and diarised claims, and completed claims in mtd
				[Status] in ('Active','Diarised') or
				(
					[Status] = 'Complete' and
					[Completion Date] >= dbo.fn_dtMTDStart(getdate()) and
					[Completion Date] < dbo.fn_dtMTDEnd(dateadd(d,1,getdate()))
				)
			)
        group by
            Country,
            [Assigned User]
    ) age on
        age.Country = summ.Country and
        age.[Assigned User] = summ.[Assigned User]
    full join
    (
        select 
            Country,
            [Assigned User],
            sum(isnull([MTD Completed], 0)) [MTD Completed],
            sum(isnull([MTD Diarised], 0)) [MTD Diarised],
            sum(isnull([MTD Reopened], 0)) [MTD Reopened],
            sum(isnull([MTD Declined], 0)) [MTD Declined],
            sum(isnull([MTD Complaints], 0)) [MTD Complaints],
            sum(isnull([MTD IDR], 0)) [MTD IDR],
            sum(isnull([MTD Call Backs], 0)) [MTD Call Backs]
        from
            (
                select 
                    w.Country,
                    isnull(w.AssignedUser, 'Unassigned') [Assigned User],
                    case
                        when we.StatusName = 'Complete' and r.PreviousStatus <> 'Complete' then 1
                        else 0
                    end [MTD Completed],
                    case
                        when we.StatusName = 'Diarised' and r.PreviousStatus <> 'Diarised' then 1
                        else 0
                    end [MTD Diarised],            
                    case
                        when 
                            we.StatusName = 'Active' and 
                            r.PreviousStatus = 'Complete' and
                            exists
                            (
                                select
                                    null
                                from
                                    e5WorkEvent rwe
                                    cross apply
                                    (
                                        select top 1
                                            rr.StatusName PreviousStatus
                                        from
                                            e5WorkEvent_v3 rr
                                        where
                                            rr.Work_Id = rwe.Work_ID and
                                            rr.EventDate < rwe.EventDate
                                        order by 
                                            rr.EventDate desc
                                    ) rr
                                where
                                    rwe.Work_ID = we.Work_ID and
                                    rwe.EventDate >= convert(date, convert(varchar(8), dateadd(day, -1, getdate()), 120) + '01') and
                                    rwe.EventDate <  convert(date, getdate()) and
                                    (
                                        rwe.EventName in ('Changed Work Status', 'Merged Work')
                                        or
                                        (
                                            rwe.EventName = 'Saved Work' and
                                            rwe.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                                        )
                                    ) and

                                    rwe.StatusName = 'Complete' and
                                    rr.PreviousStatus <> 'Complete'

                            )
                        then 1
                        else 0
                    end [MTD Reopened],
                    0 [MTD Declined],
                    0 [MTD Complaints],
                    0 [MTD IDR],
                    0 [MTD Call Backs]            
                from
                    e5WorkEvent we
                    inner join e5Work w on
                        w.Work_ID = we.Work_ID
                    cross apply
                    (
                        select top 1
                            r.StatusName PreviousStatus
                        from
                            e5WorkEvent_v3 r
                        where
                            r.Work_Id = we.Work_ID and
                            r.EventDate < we.EventDate
                        order by 
                            r.EventDate desc
                    ) r
                where
                    we.EventDate >= convert(date, convert(varchar(8), dateadd(day, -1, getdate()), 120) + '01') and
                    we.EventDate <  convert(date, getdate()) and
                    (
                        we.EventName in ('Changed Work Status', 'Merged Work')
                        or
                        (
                            we.EventName = 'Saved Work' and
                            we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                        )
                    ) and

                    (
                        (
                            we.StatusName = 'Active' and
                            r.PreviousStatus = 'Complete'
                        ) or
                        (
                            we.StatusName = 'Complete' and
                            r.PreviousStatus <> 'Complete'
                        ) or
                        (
                            we.StatusName = 'Diarised' and
                            r.PreviousStatus <> 'Diarised'
                        ) 
                    )

                    --migration events
                    and not
                    (
                        we.EventDate >= '2015-10-03' and
                        we.EventDate <  '2015-10-04' and
                        we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
                    )


                union all

                select 
                    w.Country,
                    isnull(w.AssignedUser, 'Unassigned') [Assigned User],
                    0 [MTD Completed],
                    0 [MTD Diarised],            
                    0 [MTD Reopened],
                    0 [MTD Declined],
                    case
                        when w.WorkClassName = 'Complaints' then 1
                        else 0
                    end [MTD Complaints],
                    case
                        when w.WorkClassName = 'IDR' then 1
                        else 0
                    end [MTD IDR],
                    case
                        when w.WorkType = 'Phone Call' then 1
                        else 0
                    end [MTD Call Backs]            
                from
                    e5Work w
                where
                    w.WorkType in ('Complaints', 'Phone Call') and
                    w.CreationDate >= convert(date, convert(varchar(8), dateadd(day, -1, getdate()), 120) + '01') and
                    w.CreationDate <  convert(date, getdate())

                union all

                select 
                    w.Country,
                    isnull(w.AssignedUser, 'Unassigned') [Assigned User],
                    0 [MTD Completed],
                    0 [MTD Diarised],            
                    0 [MTD Reopened],
                    count(distinct w.Work_ID) [MTD Declined],
                    0 [MTD Complaints],
                    0 [MTD IDR],
                    0 [MTD Call Backs]            
                from
                    e5Work w
                    inner join e5WorkActivity wa on
                        wa.Work_ID = w.Work_ID
                where
                    wa.CompletionDate >= convert(date, convert(varchar(8), dateadd(day, -1, getdate()), 120) + '01') and
                    wa.CompletionDate <  convert(date, getdate()) and

                    wa.CategoryActivityName = 'Assessment Outcome' and
                    (
                        wa.AssessmentOutcomeDescription like '%deny%' or
                        wa.AssessmentOutcomeDescription like '%deni%'
                    )
                group by
                    w.Country,
                    isnull(w.AssignedUser, 'Unassigned')
            ) mtd
        group by
            Country,
            [Assigned User]

    ) mtd on
        mtd.Country = summ.Country and
        mtd.[Assigned User] = summ.[Assigned User]
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
            u.DisplayName = coalesce(summ.[Assigned User], y.[Assigned User], age.[Assigned User], 'Unassigned')
    ) tl











GO
