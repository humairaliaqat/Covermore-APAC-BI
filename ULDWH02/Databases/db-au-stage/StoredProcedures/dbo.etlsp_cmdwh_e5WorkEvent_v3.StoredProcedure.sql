USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5WorkEvent_v3]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE procedure [dbo].[etlsp_cmdwh_e5WorkEvent_v3]
as
begin
/*
20130813, LS, Add staging index
20150708, LS, T16817, NZ e5 v3
20240623, BS, As part of claims Uplift(E5 classic to E5 connect) User details were updated according to respective joins (CHG0039218).
*/

    set nocount on

    exec etlsp_StagingIndex_e5_v3

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'e5 ODS',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.e5WorkEvent_v3') is null
    begin

        create table [db-au-cmdwh].dbo.e5WorkEvent_v3
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5) null,
            [Work_ID] varchar(50),
            [Original_Work_Id] [uniqueidentifier] not null,
            [Id] [bigint] not null,
            [EventDate] [datetime] not null,
            [Event_Id] [int] not null,
            [EventName] [nvarchar](50) null,
            [EventUserID] [nvarchar](100) null,
            [EventUser] [nvarchar](455) null,
            [Status_Id] [int] not null,
            [StatusName] [nvarchar](100) null,
            [Detail] [nvarchar](200) null,
            [Allocation] [varchar](20) null,
            ResumeEventId [int] null,
            ResumeEventStatusName [nvarchar](100) null,
            BookmarkId [uniqueidentifier] null,
            ProcessStatus_Id [int],
            ProcessStatus [nvarchar](100) null,
            ResumeEventDetail [nvarchar](200) null,
            [CreateBatchID] int,
            [UpdateBatchID] int,
            [DeleteBatchID] int
        )

        create clustered index idx_e5WorkEvent_v3_BIRowID on [db-au-cmdwh].dbo.e5WorkEvent_v3(BIRowID)
        create nonclustered index idx_e5WorkEvent_v3_Id on [db-au-cmdwh].dbo.e5WorkEvent_v3(Id,Domain)
        create nonclustered index idx_e5WorkEvent_v3_EventDate on [db-au-cmdwh].dbo.e5WorkEvent_v3(EventDate) include (Id,Domain,EventName,Work_Id,Event_Id,EventUser,StatusName)
        create nonclustered index idx_e5WorkEvent_v3_EventName on [db-au-cmdwh].dbo.e5WorkEvent_v3(EventName,StatusName,EventDate) include (Id,Domain,Work_Id,Detail)
        create nonclustered index idx_e5WorkEvent_v3_WorkID on [db-au-cmdwh].dbo.e5WorkEvent_v3(Work_Id,EventDate,EventName) include (Domain,Id,StatusName,EventUser,Detail)

    end

    if object_id('tempdb..#e5WorkEvent_v3') is not null
        drop table #e5WorkEvent_v3

    select 
        Domain,
        Country + Domain + convert(varchar(40), Work_ID) Work_ID,
        Work_ID Original_Work_ID,
        ID,
        EventDate,
        Event_ID,
        (
            select top 1 
                [Name] collate database_default
            from 
                e5_event_v3 
            where Id = we.Event_Id
        ) EventName,
        us.EventUser collate database_default EventUserID,
        coalesce
        (
            (
                select top 1
                    l.DisplayName
                from
                    [db-au-cmdwh]..usrLDAP l
                where
                    l.UserName = replace(us.EventUser, 'covermore\', '') collate database_default 
                order by
                    case
                        when DeleteDateTime is null then 0
                        else 1
                    end
            ),
            us.EventUser collate database_default
        ) EventUser,
        Status_Id,
        (
            select top 1 
                [Name] collate database_default 
            from 
                e5_status_v3 
            where 
                Id = we.Status_Id
        ) StatusName,
        Detail collate database_default Detail,
        Allocation collate database_default Allocation,
        ResumeEventId,
        (
            select top 1 
                [Name] collate database_default
            from 
                e5_event_v3 
            where Id = we.ResumeEventId
        ) ResumeEventStatusName,
        BookmarkId,
        ProcessStatus ProcessStatus_Id,
        (
            select top 1 
                [Name] collate database_default 
            from 
                e5_status_v3 
            where 
                Id = we.ProcessStatus
        ) ProcessStatus,
        ResumeEventDetail collate database_default ResumeEventDetail
    into #e5WorkEvent_v3
    from
        e5_WorkEvent_v3 we
        cross apply
        (
            select top 1 
                w.Category1_Id
            from
                e5_Work_v3 w
            where
                w.Id = we.Work_Id
        ) w
	outer apply  --Userdetails added as part of Claims uplift (CHG0039218): SB
        (
            select top 1
                u.UserName collate database_default EventUser
            from
                e5_User_v3 u
            where
                u.Id = we.EventUser
        ) us
        cross apply
        (
            select top 1
                [Code] collate database_default [Code],
                [Name] collate database_default [Name]
            from
                e5_Category1_v3
            where
                Id = w.Category1_Id
        ) bn
        cross apply
        (
            select
                'V3' Domain,
                bn.Code Country
        ) d

    set @sourcecount = @@rowcount


    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5WorkEvent_v3] with(tablock) t
        using #e5WorkEvent_v3 s on
            s.Id = t.Id and
            s.Domain = t.Domain

        when matched then
            update
            set
                Work_ID = s.Work_ID,
                Original_Work_ID = s.Original_Work_ID,
                EventDate = s.EventDate,
                Event_Id = s.Event_Id,
                EventName = s.EventName,
                EventUserID = s.EventUserID,
                EventUser = s.EventUser,
                Status_Id = s.Status_Id,
                StatusName  = s.StatusName,
                Detail = s.Detail,
                Allocation = s.Allocation,
                ResumeEventId = s.ResumeEventId,
                ResumeEventStatusName = s.ResumeEventStatusName,
                BookmarkId = s.BookmarkId,
                ProcessStatus_Id = s.ProcessStatus_Id,
                ProcessStatus = s.ProcessStatus,
                ResumeEventDetail = s.ResumeEventDetail,
                UpdateBatchID = @batchid,
                DeleteBatchID = null

        when not matched by target then
            insert
            (
                Domain,
                Work_ID,
                Original_Work_ID,
                ID,
                EventDate,
                Event_Id,
                EventName,
                EventUserID,
                EventUser,
                Status_Id,
                StatusName,
                Detail,
                Allocation,
                ResumeEventId,
                ResumeEventStatusName,
                BookmarkId,
                ProcessStatus_Id,
                ProcessStatus,
                ResumeEventDetail,
                CreateBatchID
            )
            values
            (
                s.Domain,
                s.Work_ID,
                s.Original_Work_ID,
                s.ID,
                s.EventDate,
                s.Event_Id,
                s.EventName,
                s.EventUserID,
                s.EventUser,
                s.Status_Id,
                s.StatusName,
                s.Detail,
                s.Allocation,
                s.ResumeEventId,
                s.ResumeEventStatusName,
                s.BookmarkId,
                s.ProcessStatus_Id,
                s.ProcessStatus,
                s.ResumeEventDetail,
                @batchid
            )

        output $action into @mergeoutput
        ;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'e5WorkEvent_v3 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end







GO
