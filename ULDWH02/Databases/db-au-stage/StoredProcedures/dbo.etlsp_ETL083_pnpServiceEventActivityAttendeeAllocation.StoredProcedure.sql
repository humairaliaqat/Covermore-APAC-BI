USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceEventActivityAttendeeAllocation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[etlsp_ETL083_pnpServiceEventActivityAttendeeAllocation] as
BEGIN 
	/**************************************
	Modifications: 
		20180914 DM Changed logic to prepare into Temp table and then update into materalised table.


	***************************************/

	IF OBJECT_ID('tempdb..#Attendees') IS NOT NULL DROP TABLE #Attendees
	IF OBJECT_ID('tempdb..#src') IS NOT NULL DROP TABLE #src

    --20180504, LL, do we really need to update all records? 20180914 - Yes we do, event does not get updated with mod date if worker is added or removed.
    if object_id('tempdb..#updates') is not null 
        drop table #updates

    select 
        se.ServiceEventSK
    into #updates
    from
        [db-au-dtc].dbo.pnpServiceEvent se
	where 
		isnull(se.Category,'') <> 'Indirect'

	--Get a list of all attendee's for all Events, count number of removed attendee's / existing attendees
	select seat.ServiceEventSK, 
			U.UserSK, 
			U.LoginName, 
			U.UserID, 
			SUM(CASE WHEN seat.DeletedDatetime is null THEN 1 ELSE 0 END) over(partition by seat.ServiceEventSK) as Counted,
			SUM(CASE WHEN seat.DeletedDatetime is null THEN 0 ELSE 1 END) over(partition by seat.ServiceEventSK) as CountedDeleted,
			se.PrimaryWorkerUserSK as EventPrimaryWorker,
			CASE WHEN seat.DeletedDatetime is null THEN 0 ELSE 1 END as IsDeleted,
			rank() over(partition by seat.ServiceEventSK order by seat.deleteddatetime desc) as ranked,
			seat.deleteddatetime
	into #Attendees
	from [db-au-dtc].dbo.pnpServiceEventAttendee seat
	inner join [db-au-dtc].dbo.pnpUser U ON seat.UserSK = U.UserSK
	inner JOIN [db-au-dtc].dbo.pnpServiceEvent se on seat.ServiceEventSK = se.ServiceEventSK
	join #updates U1 on se.ServiceEventSK = u1.ServiceEventSK

	create index TMPIDX_Attendee on #Attendees (ServiceEventSK)

	--Create a source table which contains all Service Event Activities and matches the Worker where there is only 1 worker on the Event.
	select SEA.ServiceEventActivitySK, X.UserSK as AllocatedUser, X.UserID
	INTO #src
	from [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock)
	join [db-au-dtc].dbo.pnpServiceEvent se with(nolock) on sea.ServiceEventSK = se.ServiceEventSK
	join #updates U on se.ServiceEventSK = u.ServiceEventSK
	outer apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK
		AND (A.counted = 1)
		AND A.IsDeleted = 0) X
	where LEFT(sea.ServiceEventActivityID,7) NOT IN ('CLI_SCH', 'CLI_INV')

	if object_id('tempdb..#tmpServiceEventActivityAllocated') is not null 
        drop table #tmpServiceEventActivityAllocated
	
	CREATE TABLE #tmpServiceEventActivityAllocated (
		[ServiceEventActivitySK] [bigint] NULL,
		[AllocatedUser] [bigint] NULL,
		[AttendeeReason] [varchar](250) NULL,
		[UserID] [varchar](50) null
	) 

	--Merge into correct table	
	;merge into #tmpServiceEventActivityAllocated as tgt
	using #src
	on tgt.ServiceEventActivitySK = #src.ServiceEventActivitySK
	when not matched then 
		insert(ServiceEventActivitySK, AllocatedUser, AttendeeReason, UserID)
		values(#src.ServiceEventActivitySK, #src.AllocatedUser, CASE WHEN #src.Allocateduser is not null THEN 'Only Attending Worker' ELSE NULL END, #src.UserID)
	WHEN MATCHED AND #src.Allocateduser is not null THEN
		UPDATE 
			SET AllocatedUser = #src.AllocatedUser,
				AttendeeReason = 'Only Attending Worker'
			;

	CREATE NONCLUSTERED INDEX [idx_tmpServiceEventActivityAllocated] ON #tmpServiceEventActivityAllocated ([ServiceEventActivitySK] ASC ) INCLUDE ( [AllocatedUser], [AttendeeReason]) 
	
	UPDATE T
	SET AllocatedUser = X.UserSK,
		AttendeeReason = 'Attendee Worker matching Activity entry User',
		UserID = X.UserID
	--select T.*, X.*, *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	cross apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK
		AND A.counted > 1 
		AND sea.CreatedBy = A.LoginName
		) X
	where T.AllocatedUser is null
	AND sea.ServiceEventActivityIDRet IS NULL

	UPDATE T
	SET AllocatedUser = X.UserSK,
		AttendeeReason = 'Only Non-Attendee Worker',
		UserID = X.UserID
	--select *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	cross apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK
		AND A.CountedDeleted = 1 
		AND A.Counted = 0
		AND A.IsDeleted = 1
		) X
	where T.AllocatedUser IS NULL
	AND sea.ServiceEventActivityIDRet IS NULL

	UPDATE T
	SET AllocatedUser = X.UserSK,
		AttendeeReason = 'Non-Attendee Worker matching Activity entry User',
		UserID = X.UserID
	--select *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	cross apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK
		AND A.CountedDeleted <> 1 
		AND A.Counted = 0
		AND sea.CreatedBy = A.LoginName
		AND A.IsDeleted = 1
		) X
	where T.AllocatedUser IS NULL
	AND sea.ServiceEventActivityIDRet IS NULL

	UPDATE T
	SET AllocatedUser = X.UserSK,
		AttendeeReason = 'Attendee Worker matching Event Primary User',
		UserID = X.UserID
	--select X.UserSK, *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	cross apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK 
		AND A.Counted > 1
		AND e.PrimaryWorkerUserSK = A.EventPrimaryWorker
		AND A.IsDeleted = 0
		) X
	where T.AllocatedUser IS NULL
	AND sea.ServiceEventActivityIDRet IS NULL

	UPDATE T
	SET AllocatedUser = X.UserSK,
		AttendeeReason = 'Non-Attendee Worker matching Event Primary User',
		UserID = X.UserID
	--select X.UserSK, *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	cross apply(
		select top 1 *
		from #Attendees A
		WHERE sea.ServiceEventSK = A.ServiceEventSK 
		AND A.Counted = 0
		AND A.CountedDeleted > 1
		AND e.PrimaryWorkerUserSK = A.EventPrimaryWorker
		AND A.IsDeleted = 0
		) X
	where T.AllocatedUser IS NULL
	AND sea.ServiceEventActivityIDRet IS NULL

	UPDATE T
	SET AllocatedUser = e.PrimaryWorkerUserSK,
		AttendeeReason = 'Event Primary User',
		UserID = U.UserID
	--select e.PrimaryWorkerUserSK, *
	from #tmpServiceEventActivityAllocated T
	JOIN [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) ON T.ServiceEventActivitySK = sea.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEvent e with(nolock) on sea.ServiceEventSK = e.ServiceEventSK
	join [db-au-dtc].dbo.pnpUser u on e.PrimaryWorkerUserSK = u.UserSK
	where T.AllocatedUser IS NULL
	and (not exists (select 1 from #Attendees A WHERE e.ServiceEventSK = A.ServiceEventSK)
	OR
		exists (select 1 from #Attendees A where e.ServiceEventSK = A.ServiceEventSK AND u.LoginName = a.LoginName))
	AND sea.ServiceEventActivityIDRet IS NULL

	update tr
	set AllocatedUser = t.AllocatedUser, 
		AttendeeReason = 'Returned: ' + t.AttendeeReason,
		UserID = t.UserID
	--select *
	from [db-au-dtc].dbo.pnpServiceEventActivity sear
	join #tmpServiceEventActivityAllocated tr on sear.ServiceEventActivitySK = tr.ServiceEventActivitySK
	join [db-au-dtc].dbo.pnpServiceEventActivity sea on sea.ServiceEventActivityID = CAST(sear.ServiceEventActivityIDRet as varchar)
	JOIN #tmpServiceEventActivityAllocated t on sea.ServiceEventActivitySK = t.ServiceEventActivitySK
	where sear.ServiceEventActivityIDRet is not null

	UPDATE X
	SET AttendeeReason = null,
		AllocatedUser = null,
		UserID = null
	--select *
	from #tmpServiceEventActivityAllocated X
	where AllocatedUser IN (149,356,997)

	CREATE NONCLUSTERED INDEX tmpIDX_ServiceEventActivityAllocatedUser ON [dbo].[#tmpServiceEventActivityAllocated] ([AllocatedUser]) INCLUDE ([ServiceEventActivitySK],[AttendeeReason])
	
	if object_id('tempdb..#output') is not null 
        drop table #output
	CREATE TABLE #output(
		[ActionType] [varchar](10) NULL,
		[ServiceEventActivitySK] [bigint] NULL,
		[DeletedAllocatedUserSK] [bigint] NULL,
		[DeletedAttendeeReason] [varchar](250) NULL,
		[InsertedAllocatedUserSK] [bigint] NULL,
		[InsertedAttendeeReason] [varchar](250) NULL
	) 

	merge into [db-au-dtc].dbo.usrServiceEventActivityAllocated as tgt
	using #tmpServiceEventActivityAllocated as src
	on tgt.ServiceEventActivitySK = src.ServiceEventActivitySK
	when not matched then 
		insert (ServiceEventActivitySK, AllocatedUser, AttendeeReason, userID)
		values (src.ServiceEventActivitySK, src.AllocatedUser, src.AttendeeReason, src.userID)
	when matched and IsNull(tgt.userid,'') <> IsNull(src.userid,'') then
		update
			set AllocatedUser = src.AllocatedUser, 
				AttendeeReason = src.AttendeeReason, 
				userID = src.UserID
	output $action, IsNull(deleted.ServiceEventActivitySK,inserted.ServiceEventActivitySK), deleted.AllocatedUser, deleted.AttendeeReason, inserted.AllocatedUser, inserted.AttendeeReason into #output;

	insert into [db-au-dtc].[dbo].[usrServiceEventActivityAllocated_Audit]([ActionType],[ServiceEventActivitySK],[DeletedAllocatedUserSK],[DeletedAttendeeReason],[InsertedAllocatedUserSK],[InsertedAttendeeReason])
	select *
	from #output
	where ActionType <> 'INSERT'
	
	ALTER INDEX [idx_usrServiceEventActivityAllocated_ServiceEventActivitySK] ON [db-au-dtc].dbo.usrServiceEventActivityAllocated REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
END
GO
