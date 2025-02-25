USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1065v]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/****************************************************************************************************/
----  Name			:	rptsp_rpt1065v
----  Description	:	Claims Performance Dashboard - Days Count (Time in Current Staus)
----  Author		:	Yi Yang
----  Date Created	:	20190508
----					lc - latest claim work 
----					cws - current work status
----					pwe - previous work event
----					lsc - last status change
----					rd - status change reference date
----  Parameters	:	
----  Change History:	
--/****************************************************************************************************/

CREATE PROCEDURE [dbo].[rptsp_rpt1065v]

As


begin
set nocount on

declare @NoOfMonth int
declare @EOM date
set @NoOfMonth = 1
if object_id('tempdb..#DaysCount') is not null drop table #DaysCount

create table #DaysCount
	(EOMDate date null,
	worktype varchar(20) null, 
	createdate datetime null, 
	StatusName varchar(20) null, 
	EventDate datetime null,
	EventName varchar(255) null,
	PreviousStatus varchar(255) null,
	[Last Status Change] datetime null,
	ClaimNo varchar(20) null,
    [Time in current status] int null
	)


while (@NoOfMonth <= 15)
begin

select @EOM = EOMONTH(getdate(), (-1 * @NoOfMonth))
-- Get Claims Days count in Current Status for all claims with 'Active' stutus as at parameter's point of time
-- Align with the logic in vClaimPortfolio
insert into 
	#DaysCount
select 
	@EOM as EOMDate,
	lc.worktype, 
	cl.createdate, 
	cws.StatusName, 
	cws.EventDate,
	cws.EventName,
	cws.PreviousStatus,
	lsc.[Last Status Change], 
	cl.ClaimNo,
    datediff(day, rd.[TICS Reference Date], @EOM) -
    (
        select
            count(d.[Date])
        from
            Calendar d
        where
            d.[Date] >= rd.[TICS Reference Date] and
            d.[Date] <  @EOM and
            (
                d.isHoliday = 1 or
                d.isWeekEnd = 1
            )
    ) [Time in current status]
--into
--	#DaysCount
from 
	clmclaim as cl with(nolock)

	outer apply 
	(
		select 
			top 1 worktype, Work_ID, SLAStartDate
		from 
			e5work as w with(nolock) 
		where 
			cl.claimkey = w.claimkey
		order by 
			w.creationdate desc
	) lc
	outer apply
    (
        select top 1
            we.EventDate [Status Change Date], we.StatusName, we.Work_ID, pwe.PreviousStatus, pwe.eventdate,we.id, we.EventName, we.EventUser
        from
            e5WorkEvent we with(nolock)
            outer apply
            (
                select top 1
                    pwe.StatusName PreviousStatus,
					pwe.EventDate
                from
                    e5WorkEvent pwe with(nolock)
                where
                    pwe.Work_ID = lc.Work_ID and
                    pwe.EventDate < we.EventDate and
					 (pwe.EventName = 'Changed Work Status'
                or
                (
                    pwe.EventName = 'Saved Work' and
                    pwe.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
				)
					 
                order by
                    pwe.EventDate desc
            ) pwe
        where
            we.Work_Id = lc.Work_ID and
            (
                we.EventName = 'Changed Work Status'
                or
                (
                    we.EventName = 'Saved Work' and
                    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
			
            )
			and 
			we.EventDate < @EOM

            --migration events
            and not
            (
                we.EventDate >= '2015-10-03' and
                we.EventDate <  '2015-10-04' and
                we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
            ) 
			and
            we.StatusName <> isnull(PreviousStatus, '')

        order by
            we.EventDate desc
    ) cws
	outer apply
    (
        select top 1
            we.EventDate [Last Status Change],
            we.Detail [Last Status Detail],
			we.id,
            case
                when exists
                (
                    select
                        null
                    from
                        e5WorkEvent mwe with(nolock)
                    where
                        mwe.Work_Id = lc.Work_ID and
                        mwe.EventName = 'Merged Work' and
                        mwe.EventDate > we.EventDate and
                        mwe.EventDate < cws.[Status Change Date]

                        --migration events
                        and not
                        (
                            mwe.EventDate >= '2015-10-03' and
                            mwe.EventDate <  '2015-10-04' and
                            mwe.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
                        )

                ) then 1
                else 0
            end [Merged]
        from
            e5WorkEvent we with(nolock)
            outer apply
            (
                select top 1
                    pwe.StatusName PreviousStatus
                from
                    e5WorkEvent pwe with(nolock)
                where
                    pwe.Work_ID = lc.Work_ID and
                    pwe.EventDate < we.EventDate
                order by
                    pwe.EventDate desc
            ) pwe
        where
            
            we.Work_Id = lc.Work_ID and
            (
                we.EventName = 'Changed Work Status'
                or
                (
                    we.EventName = 'Saved Work' and
                    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
            ) and
            we.EventDate < cws.[Status Change Date] and
            we.StatusName <> isnull(PreviousStatus, '')

            --migration events
            and not
            (
                we.EventDate >= '2015-10-03' and
                we.EventDate <  '2015-10-04' and
                we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')
            )
        order by
            we.EventDate desc
    ) lsc
    outer apply
    (
        select lsc.[Last Status Detail], cws.[Status Change Date],
            case
                when lsc.[Last Status Detail] = 'Diarised - Referred for Medical Review' then lsc.[Last Status Change]
                when lsc.[Last Status Detail] = 'Diarised - Referred to Medical' then lsc.[Last Status Change]
                when lsc.Merged = 1 then isnull(lc.SLAStartDate, cws.[Status Change Date])
                else isnull(cws.[Status Change Date], cl.CreateDate)
            end [TICS Reference Date]
    ) rd

where 

	cws.StatusName = 'Active' and
	lc.worktype = 'Claim'
	and cl.CreateDate >'2017-01-01'

set @NoOfMonth = @NoOfMonth + 1

end

-- summarise and generate output columns
select 
	EOMDate, 
	case 
		when [Time in current status] = 1 then '1'
		when [Time in current status] = 2 then '2'
		when [Time in current status] = 3 then '3'
		when [Time in current status] = 4 then '4'
		when [Time in current status] = 5 then '5'
		when [Time in current status] = 6 then '6'
		when [Time in current status] = 7 then '7'
		when [Time in current status] = 8 then '8'
		when [Time in current status] = 9 then '9'
		when [Time in current status] = 10 then '10'
		when [Time in current status] > 10 then '10 +'
	end DayGroup,
	count(ClaimNo) as ClaimCount
		
from 
	#DaysCount

group by 
	EOMDate, 
	case 
		when [Time in current status] = 1 then '1'
		when [Time in current status] = 2 then '2'
		when [Time in current status] = 3 then '3'
		when [Time in current status] = 4 then '4'
		when [Time in current status] = 5 then '5'
		when [Time in current status] = 6 then '6'
		when [Time in current status] = 7 then '7'
		when [Time in current status] = 8 then '8'
		when [Time in current status] = 9 then '9'
		when [Time in current status] = 10 then '10'
		when [Time in current status] > 10 then '10 +'
	end 
order by
	EOMDate,
	DayGroup


end
GO
