USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0665]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0665]

as

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0665
--  Author:         Saurabh Date
--  Date Created:   20160610
--  Description:    This stored procedure returns Claim details along with some specific medical review details
--  Change History: 20160610 - SD - Created
--		    20160614 - SD - Changed the stored procedure to achieve same results by using vClaimPortfolio
--		    20160615 - SD - Changed Medical Review Active and Diarised days logic, also included medical review create date
--		    20160616 - SD - Changed Medical Review Reopen and Diarised count logic
--		    20160915 - SD - Addition of Last Diarised Reason of the claim as well as active MR
--			20161115 - SD - Filtering only for AU data in Diarised reason logic
/****************************************************************************************************/

begin


select
    vClaimPortFolio.[Assigned User],
    vClaimPortFolio.[Status],
    vClaimPortFolio.[Claim Number],
    vClaimPortFolio.[Work Type],
    vClaimPortFolio.[Customer Name],
    vClaimPortFolio.[Date Received],
    vClaimPortFolio.[Absolute Age],
    vClaimPortFolio.ActiveDays,
    vClaimPortFolio.DiarisedDays,
    vClaimPortFolio.[Time in current status],
    vClaimPortFolio.[Medical Review],
    vClaimPortFolio.[Reopen Count],
    vClaimPortFolio.[Diarised Count],
    vClaimPortFolio.[Due Date],
    vClaimPortFolio.[Active Medical Review Reference],
    vClaimPortFolio.[Current Estimate],
    vClaimPortFolio.[Current Payment],
    vClaimPortFolio.[Recovery Estimate],
    vClaimPortFolio.[Check Existing Claims],
    vClaimPortFolio.[Customer Care Case],
    vClaimPortFolio.[Claim Description],
    vClaimPortFolio.[Policy Number],
    vClaimPortFolio.[Client],
    vClaimPortFolio.[First Medical Reviewer],
    vClaimPortFolio.[Active Medical Review Asignee],
    vClaimPortFolio.[e5 Reference],
    mrActiveDays,
    mrDiarisedDays,
    [MR Reopen Count],
    [MR Diarised Count],
    [MR Due Date],
    [MR Create Date],
    DiarisedReason.[Diarised Reason] [Last Diarised Reason],
    MRDiarisedReason.[Diarised Reason] [MR Last Diarised Reason]
From
    vClaimPortFolio inner join e5work w
        on vClaimPortFolio.[e5 Reference] = w.Reference
    outer apply
    (
        select 
            sum(
                case
                    when we.StatusName = 'Active' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate())))
                    else 0
                end
            ) mrActiveDays,
            sum(
                case
                    when we.StatusName = 'Diarised' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate())))
                    else 0
                end
            ) mrDiarisedDays
        from
            e5WorkEvent we inner join e5work w2
                on we.Work_Id = w2.work_Id
            outer apply
            (
                select top 1
                    r.EventDate NextChangeDate
                from
                    e5WorkEvent r
                where
                    r.Work_Id = w2.Work_ID and
                    r.EventDate > we.EventDate and
                    (
                        (
                            r.EventName in ('Changed Work Status', 'Merged Work') and
                            isnull(r.EventUser, r.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
                        )
                        or
                        (
                            --e5 Launch Service may cause a case to have total (Active Days + Diarised Days) > Absolute Age
                            --this is due to [Saved Work] events with multiple [Status] occuring in same timestamp to ms
                            --part of known issue revolving online claims in e5 v2
                            r.EventName = 'Saved Work' and
                            r.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                        )
                    )
                order by
                    r.EventDate
            ) nwe
            outer apply
            (
                select 
                    count(d.[Date]) OffDays
                from
                    Calendar d
                where
                    d.[Date] >= convert(date, we.EventDate) and
                    d.[Date] <  convert(date, isnull(nwe.NextChangeDate, getdate())) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            ) phd
        where
            we.Work_ID = w2.Work_ID and
            (
                (
                    we.EventName in ('Changed Work Status', 'Merged Work') and
                    isnull(we.EventUser, we.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
                )
                or
                (
                    we.EventName = 'Saved Work' and
                    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
            ) and
            w2.StatusName in ('Active', 'Diarised') and
            w2.Parent_Id = w.Work_Id and
            w2.WorkType = 'Medical Review'
    ) mrwdays
	outer apply
	(
		select top 1
			Work_ID [Active MR Work ID]
		From
			e5Work
		Where
			Reference = vClaimPortFolio.[Active Medical Review Reference]
	) ew
    outer apply
    (
        select top 1
            count(we.ID) [MR Reopen Count]
        from
            e5WorkEvent we
            cross apply
            (
                select top 1
                    r.StatusName PreviousStatus
                from
                    e5WorkEvent r
                where
                    r.Work_Id = [Active MR Work ID] and
                    r.EventDate < we.EventDate
                order by 
                    r.EventDate desc
            ) r
        where
            we.Work_Id = [Active MR Work ID] and
            (
                we.EventName in ('Changed Work Status', 'Merged Work')
                or
                (
                    we.EventName = 'Saved Work' and
                    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
            ) and
            we.StatusName = 'Active' and
            r.PreviousStatus = 'Complete'

            --migration events
            and not
            (
                we.EventDate >= '2015-10-03' and
                we.EventDate <  '2015-10-04' and
                we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
            )

    ) mrro
    outer apply
    (
        select top 1
            count(we.ID) [MR Diarised Count]
        from
            e5WorkEvent we
        where
            we.Work_Id = [Active MR Work ID] and
            (
                we.EventName = 'Changed Work Status' 
            ) and
            we.StatusName = 'Diarised' 

            --migration events
            and not
            (
                we.EventDate >= '2015-10-03' and
                we.EventDate <  '2015-10-04' and
                we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
            )

    ) mrdr
    outer apply
    (
        select top 1
            SLAExpiryDate [MR Due Date],
	    CreationDate [MR Create Date]
        From
            e5Work
        Where
            Reference = [Active Medical Review Reference]
    ) mrdd
	Outer apply -- Finding Diarised Reason
	(
		Select Top 1
			Case 
				When d.Detail like 'Diarised%' Then SubString(d.Detail,12,Len(d.Detail))
				Else d.Detail
			End [Diarised Reason]
		From
			e5WorkEvent d
		Where 
			d.Work_ID = (select ie.Work_ID from e5Work ie where ie.Country = 'AU' and ie.Reference = vClaimPortFolio.[e5 Reference])
			and d.EventName = 'Changed Work Status'
			and d.StatusName = 'Diarised'
		Order by
			d.EventDate Desc
	) DiarisedReason
	Outer apply -- Finding MR Diarised Reason
	(
		Select Top 1
			Case 
				When d2.Detail like 'Diarised%' Then SubString(d2.Detail,12,Len(d2.Detail))
				Else d2.Detail
			End [Diarised Reason]
		From
			e5WorkEvent d2
		Where 
			d2.Work_ID = (select ie2.Work_ID from e5Work ie2 where ie2.Country = 'AU' and ie2.Reference = [Active Medical Review Reference])
			and d2.EventName = 'Changed Work Status'
			and d2.StatusName = 'Diarised'
		Order by
			d2.EventDate Desc
	) MRDiarisedReason
Where
    vClaimPortFolio.[Status] in ('Active', 'Diarised') 
    and vClaimPortFolio.[Work Type] <> 'Complaints'
    and vClaimPortFolio.Country = 'AU'
    and [Active Medical Review] >= 1

end
GO
