USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceEventActivity]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpServiceEventActivity
-- Modification:
--      20180313 - DM - Adjusted the ScheduleEndDate to take into account the QTY of the line.
--      20180327 - DM - Added a line to marked Activities deleted which had been imported into Star Projects before 1/7/2017 (Penelope Go-live).
--      20180812 - LL - change Deleted logic, reading the new id table
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceEventActivity]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    if object_id('[db-au-stage].dbo.penelope_etactline_audtc') is null
        goto Finish

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

    if object_id('[db-au-dtc].dbo.pnpServiceEventActivity') is null
    begin
        create table [db-au-dtc].[dbo].[pnpServiceEventActivity](
            ServiceEventActivitySK int identity(1,1) primary key,
            ServiceEventSK int,
            ServiceFileSK int,
            CaseSK int,
            ItemSK int,
            FunderSK int,
            FunderDepartmentSK int,
            ServiceEventActivityID varchar(50),
            ServiceEventID varchar(50),
            ServiceFileID varchar(50),
            CaseID varchar(50),
            ItemID varchar(50),
            FunderID varchar(50),
            FunderDepartmentID varchar(50),
            [Name] nvarchar(100),
            Quantity numeric(10,2),
            UnitOfMeasurementClass nvarchar(max),
            UnitOfMeasurementIsTime varchar(5),
            UnitOfMeasurementIsSchedule nvarchar(30),
            UnitOfMeasurementIsName nvarchar(10),
            UnitOfMeasurementIsEquivalent numeric(10,2),
            Fee numeric(10,2),
            Total numeric(10,2),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            UseSeqOvr varchar(5),
            WorkshopRegItemID int,
            WorkshopSessionLineID int,
            ServiceEventActivityIDRet int,
            DeletedDatetime datetime2,
            Invoiced tinyint default 0,
            Note nvarchar(max),
            ScheduleStartDate date,
            ScheduleEndDate date,
            ScheduleDate date,
            DebtorCode varchar(16),
            CompanyCode varchar(10),
            PostingCode varchar(8),
            RCTIDate datetime,
            FinanceDate datetime,
            FinMonthAC varchar(8000),
            FinYearAC varchar(4),
            FinMonthACDate datetime,
            index idx_pnpServiceEventActivity_ServiceEventSK nonclustered (ServiceEventSK),
            index idx_pnpServiceEventActivity_ServiceFileSK nonclustered (ServiceFileSK),
            index idx_pnpServiceEventActivity_CaseSK nonclustered (CaseSK),
            index idx_pnpServiceEventActivity_ItemSK nonclustered (ItemSK),
            index idx_pnpServiceEventActivity_FunderSK nonclustered (FunderSK),
            index idx_pnpServiceEventActivity_FunderDepartmentSK nonclustered (FunderDepartmentSK),
            index idx_pnpServiceEventActivity_ServiceEventActivityID nonclustered (ServiceEventActivityID),
            index idx_pnpServiceEventActivity_ServiceEventID nonclustered (ServiceEventID),
            index idx_pnpServiceEventActivity_ServiceFileID nonclustered (ServiceFileID),
            index idx_pnpServiceEventActivity_CaseID nonclustered (CaseID),
            index idx_pnpServiceEventActivity_ItemID nonclustered (ItemID),
            index idx_pnpServiceEventActivity_FunderID nonclustered (FunderID),
            index idx_pnpServiceEventActivity_FunderDepartmentID nonclustered (FunderDepartmentID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            se.ServiceEventSK,
            se.ServiceFileSK,
            se.CaseSK,
            i.ItemSK,
            se.FunderSK,
            se.FunderDepartmentSK,
            convert(varchar, a.kactlineid) as ServiceEventActivityID,
            convert(varchar, a.kactid) as ServiceEventID,
            se.ServiceFileID,
            se.CaseID,
            convert(varchar, a.kitemid) as ItemID,
            se.FunderID,
            se.FunderDepartmentID,
            a.itemname as Name,
            a.lineqty as Quantity,
            uomc.uomclass as UnitOfMeasurementClass,
            uomc.istime as UnitOfMeasurementIsTime,
            uoms.uomschedule as UnitOfMeasurementIsSchedule,
            uom.uomname as UnitOfMeasurementIsName,
            uom.equiv as UnitOfMeasurementIsEquivalent,
            a.linefee as Fee,
            a.linetotal as Total,
            a.slogin as CreatedDatetime,
            a.slogmod as UpdatedDatetime,
            a.sloginby as CreatedBy,
            a.slogmodby as UpdatedBy,
            a.useseqovr as UseSeqOvr,
            a.kworkshopregitemid as WorkshopRegItemID,
            a.kwssesslineid as WorkshopSessionLineID,
            a.kactlineidret as ServiceEventActivityIDRet,
            an.actlinenote as Note,
            case
                when se.WorkshopID is not null  then convert(date, se.StartDatetime)
                else null
            end ScheduleStartDate,
            case
                when se.WorkshopID is not null then dateadd(day, -1, dateadd(month, uom.equiv * abs(a.lineqty), convert(date, se.StartDatetime))) --ADJ 20180313 - DM - Included the QTY in the calculation
                else null
            end ScheduleEndDate
        into #src
        from
            penelope_etactline_audtc a
            left join penelope_nruom_audtc uom on uom.kuomid = a.kuomid
            left join penelope_nruoms_audtc uoms on uoms.kuomsid = uom.kuomsid
            left join penelope_ssuomclass_audtc uomc on uomc.kuomclassid = uoms.kuomclassid
            left join (
                select
                    kactlineid,
                    stuff(
                        convert(varchar(max), (
                            select ' | Note ' + convert(varchar, kactlinenoteid) + ': ' + convert(nvarchar(max), actlinenote)
                            from penelope_etactlinenote_audtc t1
                            where t1.kactlineid = t2.kactlineid
                            for xml path ('')))
                        , 1, 3, ''
                    ) actlinenote
                from penelope_etactlinenote_audtc t2
                group by kactlineid
            ) an on an.kactlineid = a.kactlineid
            outer apply (
                select top 1
                    t1.ServiceEventSK,
                    t1.ServiceFileSK,
                    t1.CaseSK,
                    t1.FunderSK,
                    t1.FunderDepartmentSK,
                    t1.ServiceFileID,
                    t1.CaseID,
                    t1.FunderID,
                    t1.FunderDepartmentID,
                    t1.StartDatetime,
                    t2.WorkshopID
                from [db-au-dtc]..pnpServiceEvent t1 left join [db-au-dtc]..pnpServiceFile t2 on t2.ServiceFileSK = t1.ServiceFileSK
                where ServiceEventID = convert(varchar, a.kactid)
            ) se
            outer apply (
                select top 1 ItemSK
                from [db-au-dtc]..pnpItem
                where ItemID = convert(varchar, a.kitemid)
            ) i

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpServiceEventActivity as tgt
        using #src
            on #src.ServiceEventActivityID = tgt.ServiceEventActivityID
        when matched then
            update set
                tgt.ServiceEventSK = #src.ServiceEventSK,
                tgt.ServiceFileSK = #src.ServiceFileSK,
                tgt.CaseSK = #src.CaseSK,
                tgt.ItemSK = #src.ItemSK,
                tgt.FunderSK = #src.FunderSK,
                tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
                tgt.ServiceEventID = #src.ServiceEventID,
                tgt.ServiceFileID = #src.ServiceFileID,
                tgt.CaseID = #src.CaseID,
                tgt.ItemID = #src.ItemID,
                tgt.FunderID = #src.FunderID,
                tgt.FunderDepartmentID = #src.FunderDepartmentID,
                tgt.[Name] = #src.[Name],
                tgt.Quantity = #src.Quantity,
                tgt.UnitOfMeasurementClass = #src.UnitOfMeasurementClass,
                tgt.UnitOfMeasurementIsTime = #src.UnitOfMeasurementIsTime,
                tgt.UnitOfMeasurementIsSchedule = #src.UnitOfMeasurementIsSchedule,
                tgt.UnitOfMeasurementIsName = #src.UnitOfMeasurementIsName,
                tgt.UnitOfMeasurementIsEquivalent = #src.UnitOfMeasurementIsEquivalent,
                tgt.Fee = #src.Fee,
                tgt.Total = #src.Total,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdatedBy = #src.UpdatedBy,
                tgt.UseSeqOvr = #src.UseSeqOvr,
                tgt.WorkshopRegItemID = #src.WorkshopRegItemID,
                tgt.WorkshopSessionLineID = #src.WorkshopSessionLineID,
                tgt.ServiceEventActivityIDRet = #src.ServiceEventActivityIDRet,
                tgt.Note = #src.Note,
                tgt.ScheduleStartDate = #src.ScheduleStartDate,
                tgt.ScheduleEndDate = #src.ScheduleEndDate,
                tgt.ScheduleDate = #src.ScheduleStartDate
        when not matched by target then
            insert (
                ServiceEventSK,
                ServiceFileSK,
                CaseSK,
                ItemSK,
                FunderSK,
                FunderDepartmentSK,
                ServiceEventActivityID,
                ServiceEventID,
                ServiceFileID,
                CaseID,
                ItemID,
                FunderID,
                FunderDepartmentID,
                [Name],
                Quantity,
                UnitOfMeasurementClass,
                UnitOfMeasurementIsTime,
                UnitOfMeasurementIsSchedule,
                UnitOfMeasurementIsName,
                UnitOfMeasurementIsEquivalent,
                Fee,
                Total,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
                UseSeqOvr,
                WorkshopRegItemID,
                WorkshopSessionLineID,
                ServiceEventActivityIDRet,
                Note,
                ScheduleStartDate,
                ScheduleEndDate,
                ScheduleDate,
                DeletedDatetime
            )
            values (
                #src.ServiceEventSK,
                #src.ServiceFileSK,
                #src.CaseSK,
                #src.ItemSK,
                #src.FunderSK,
                #src.FunderDepartmentSK,
                #src.ServiceEventActivityID,
                #src.ServiceEventID,
                #src.ServiceFileID,
                #src.CaseID,
                #src.ItemID,
                #src.FunderID,
                #src.FunderDepartmentID,
                #src.[Name],
                #src.Quantity,
                #src.UnitOfMeasurementClass,
                #src.UnitOfMeasurementIsTime,
                #src.UnitOfMeasurementIsSchedule,
                #src.UnitOfMeasurementIsName,
                #src.UnitOfMeasurementIsEquivalent,
                #src.Fee,
                #src.Total,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreatedBy,
                #src.UpdatedBy,
                #src.UseSeqOvr,
                #src.WorkshopRegItemID,
                #src.WorkshopSessionLineID,
                #src.ServiceEventActivityIDRet,
                #src.Note,
                #src.ScheduleStartDate,
                #src.ScheduleEndDate,
                #src.ScheduleStartDate,
                null
            )
        --20180812 - LL - change Deleted logic, reading the new id table
        --when not matched by source and tgt.DeletedDatetime is null and tgt.ServiceEventActivityID not like 'CLI_%' and tgt.ServiceEventActivityID not like 'DUMMY%' then
        --    update set tgt.DeletedDatetime = current_timestamp

        output $action into @mergeoutput;

        --MOD20180327: Mark items as deleted which were brought into Star Projects before go-live (ie remove duplicate lines).
        update sea
        set
            DeletedDateTime = sia.TS_CreatedDate
        --select *
        from
            [db-au-dtc].dbo.pnpServiceEventActivity sea
            inner join [db-au-dtc].dbo.usr_StarImportedActivities sia on
                sea.ServiceEventActivityID = CAST(sia.actline_id as varchar)
        where
            sia.trx_detail_id is not null and
            sea.DeletedDatetime is null


        --20180812 - LL - change Deleted logic, reading the new id table
        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            penelope_etactline_audtc_id

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpServiceEventActivity t
        where
            t.ServiceEventActivityID not like 'CLI_%' and
            t.ServiceEventActivityID not like 'DUMMY%' and
            t.DeletedDatetime is null

        select @old, @new

        update sea
        set
            DeletedDatetime = null
        from
            [db-au-dtc].dbo.pnpServiceEventActivity sea
        where
            sea.ServiceEventActivityID not like 'CLI_%' and
            sea.ServiceEventActivityID not like 'DUMMY%' and
            sea.DeletedDatetime >= '2018-06-01' and
            exists
            (
                select
                    null
                from
                    penelope_etactline_audtc_id id
                where
                    id.kactlineid = try_convert(bigint, sea.ServiceEventActivityID)
            )


        --if @new > @old - 200
        begin


            update sea
            set
                DeletedDateTime = current_timestamp 
            from
                [db-au-dtc].dbo.pnpServiceEventActivity sea
            where
                sea.ServiceEventActivityID not like 'CLI_%' and
                sea.ServiceEventActivityID not like 'DUMMY%' and
                sea.DeletedDatetime is null and
                not exists
                (
                    select
                        null
                    from
                        penelope_etactline_audtc_id id
                    where
                        id.kactlineid = try_convert(bigint, sea.ServiceEventActivityID)
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

Finish:
END



GO
