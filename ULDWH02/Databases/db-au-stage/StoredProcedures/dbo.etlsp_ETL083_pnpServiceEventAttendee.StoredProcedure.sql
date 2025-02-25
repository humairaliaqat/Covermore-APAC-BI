USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceEventAttendee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpServiceEventAttendee
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceEventAttendee]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    declare
    @batchid int,
    @start date,
    @end date,
    @name varchar(100),
    @sourcecount int,
    @insertcount int,
    @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-dtc].dbo.pnpServiceEventAttendee') is null
    begin
        create table [db-au-dtc].[dbo].[pnpServiceEventAttendee](
            BookItemSK int,
            ServiceEventSK int,
            IndividualSK int,
            UserSK int,
            BookItemID int,
            ServiceEventID varchar(50),
            IndividualID varchar(50),
            UserID varchar(50),
            WorkerID varchar(50),
            [Name] nvarchar(100),
            [Role] nvarchar(50),
            amemshow varchar(5),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            amemcode int,
            kexempttypeid int,
            DeletedDatetime datetime2,
            index idx_pnpServiceEventAttendee_BookItemSK nonclustered (BookItemSK),
            index idx_pnpServiceEventAttendee_ServiceEventSK nonclustered (ServiceEventSK),
            index idx_pnpServiceEventAttendee_IndividualSK nonclustered (IndividualSK),
            index idx_pnpServiceEventAttendee_UserSK nonclustered (UserSK),
            index idx_pnpServiceEventAttendee_BookItemID nonclustered (BookItemID),
            index idx_pnpServiceEventAttendee_ServiceEventID nonclustered (ServiceEventID),
            index idx_pnpServiceEventAttendee_IndividualID nonclustered (IndividualID),
            index idx_pnpServiceEventAttendee_UserID nonclustered (UserID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src;

        with tmp as (
            select
                kbookitemid as BookItemID,
                kindid as IndividualID,
                null as UserID,
                null as WorkerID,
                i.indfirstname + ' ' + i.indlastname as Name
            from [dbo].[penelope_irindividual_audtc] i
            union all
            select
                u.kbookitemid,
                null,
                u.kuserid,
                w.kcworkerid,
                u.usfirstname + ' ' + u.uslastname
            from [dbo].[penelope_wruser_audtc] u left join [dbo].[penelope_wrcworker_audtc] w on u.kuserid = w.kuserid
        )
        select
            bi.BookItemSK,
            se1.ServiceEventSK,
            i.IndividualSK,
            u.UserSK,
            sea.kbookitemid as BookItemID,
            convert(varchar, sea.kactid) as ServiceEventID,
            convert(varchar, tmp.IndividualID) as IndividualID,
            convert(varchar, tmp.UserID) as UserID,
            convert(varchar, tmp.WorkerID) as WorkerID,
            tmp.Name as Name,
            case
                when tmp.IndividualID = presind.kindid then 'Presenting Individual'
                when tmp.IndividualID is not null and presind.kindid is null then 'Individual'
                when tmp.WorkerID = se.kcworkeridprimact then 'Primary Worker'
                when tmp.WorkerID is not null then 'Worker'
                else 'Unknown'
            end as [Role],
            sea.amemshow as amemshow,
            sea.slogin as CreatedDatetime,
            sea.slogmod as UpdatedDatetime,
            sea.amemcode as amemcode,
            sea.kexempttypeid as kexempttypeid
        into #src
        from
            penelope_aecactmem_audtc sea
            left join tmp on tmp.BookItemID = sea.kbookitemid
            left join penelope_etactcase_audtc se on se.kactid = sea.kactid
            left join penelope_ctprogprov_audtc sf on sf.kprogprovid = se.kprogprovid
            outer apply (
                select top 1 kindid
                from penelope_aiccasemembers_audtc
                where kindid = tmp.IndividualID and cmemprimary = '1'
            ) presind
            outer apply (
                select top 1 BookItemSK
                from [db-au-dtc].dbo.pnpBookItem
                where BookItemID = sea.kbookitemid
            ) bi
            outer apply (
                select top 1 ServiceEventSK
                from [db-au-dtc].dbo.pnpServiceEvent
                where ServiceEventID = convert(varchar, sea.kactid)
            ) se1
            outer apply (
                select top 1 IndividualSK
                from [db-au-dtc].dbo.pnpIndividual
                where IndividualID = convert(varchar, tmp.IndividualID)
                    and IsCurrent = 1
            ) i
            outer apply (
                select top 1 UserSK
                from [db-au-dtc].dbo.pnpUser
                where UserID = convert(varchar(50), tmp.UserID)
                    and IsCurrent = 1
            ) u

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpServiceEventAttendee as tgt
        using #src
            on #src.BookItemID = tgt.BookItemID and #src.ServiceEventID = tgt.ServiceEventID
        when matched then
            update set
                tgt.BookItemSK = #src.BookItemSK,
                tgt.ServiceEventSK = #src.ServiceEventSK,
                tgt.IndividualSK = #src.IndividualSK,
                tgt.UserSk = #src.UserSK,
                tgt.IndividualID = #src.IndividualID,
                tgt.UserID = #src.UserID,
                tgt.WorkerID = #src.WorkerID,
                tgt.Name = #src.Name,
                tgt.[Role] = #src.[Role],
                tgt.amemshow = #src.amemshow,
                tgt.CreatedDatetime = #src.CreatedDatetime,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.amemcode = #src.amemcode,
                tgt.kexempttypeid = #src.kexempttypeid,
                tgt.deleteddatetime = null
        when not matched by target then
            insert (
                BookItemSK,
                ServiceEventSK,
                IndividualSK,
                UserSk,
                BookItemID,
                ServiceEventID,
                IndividualID,
                UserID,
                WorkerID,
                Name,
                [Role],
                amemshow,
                CreatedDatetime,
                UpdatedDatetime,
                amemcode,
                kexempttypeid,
                DeletedDatetime
            )
            values (
                #src.BookItemSK,
                #src.ServiceEventSK,
                #src.IndividualSK,
                #src.UserSk,
                #src.BookItemID,
                #src.ServiceEventID,
                #src.IndividualID,
                #src.UserID,
                #src.WorkerID,
                #src.Name,
                #src.[Role],
                #src.amemshow,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.amemcode,
                #src.kexempttypeid,
                null
            )
            --20180812 - LL - change Deleted logic, reading the new id table
            --when not matched by source and tgt.DeletedDatetime is null and tgt.ServiceEventID NOT LIKE 'CLI%' then
            --    update set tgt.DeletedDatetime = current_timestamp

        output $action into @mergeoutput;

        --20180812 - LL - change Deleted logic, reading the new id table
        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            penelope_aecactmem_audtc_id

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpServiceEventAttendee t
        where
            t.ServiceEventID not like 'CLI_%' and
            t.ServiceEventID not like 'DUMMY%' and
            t.DeletedDatetime is null

        select @old, @new

        --if @new > @old - 100
        begin

            update t
            set
                DeletedDateTime = current_timestamp
            from
                [db-au-dtc].dbo.pnpServiceEventAttendee t
            where
                t.ServiceEventID not like 'CLI_%' and
                t.ServiceEventID not like 'DUMMY%' and
                t.DeletedDatetime is null and
                not exists
                (
                    select
                        null
                    from
                        penelope_aecactmem_audtc_id id
                    where
                        id.kbookitemid = try_convert(bigint, t.BookItemID) and
                        id.kactid = try_convert(bigint, t.ServiceEventID)
                )

        end

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
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
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

END




GO
