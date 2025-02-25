USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceEvent]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- Create date: 2017-04-19
-- Description:    Transformation - pnpServiceEvent
-- 20180321, LL, optimise .. taking too long
-- 20180523, DM, Adjusted the Indirect Dummy Event code to bring in the dummy Cart Item and quantity
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceEvent] 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    if object_id('[db-au-dtc].dbo.pnpServiceEvent') is null
    begin 
        create table [db-au-dtc].[dbo].[pnpServiceEvent](
            ServiceEventSK int identity(1,1) primary key,
            SiteSK int,
            BookItemSK int,
            ServiceFileSK int,
            CaseSK int,
            FunderSK int,
            FunderDepartmentSK int,
            PrimaryWorkerUserSK int,
            SecWorkerUserSK int,
            BillActOvrIndividualSK int,
            ServiceEventID varchar(50),
            SiteID varchar(50),
            BookItemID int,
            ServiceFileID varchar(50),
            CaseID varchar(50),
            FunderID varchar(50),
            FunderDepartmentID varchar(50),
            PrimaryWorkerID varchar(50),
            PrimaryWorkerUserID varchar(50),
            SecWorkerID varchar(50),
            SecWorkerUserID varchar(50),
            BillActOvrIndividualID varchar(50),
            Title nvarchar(80),
            StartDatetime datetime2,
            EndDatetime datetime2,
            [Out] varchar(5),
            Category nvarchar(25),
            Notes nvarchar(max),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            NotesFinished varchar(5),
            FollowupRequired varchar(5),
            Lock varchar(5),
            FirstSessionInSeries varchar(5),
            NoteUpdateDatetime datetime2,
            NoteUpdateUserID int,
            NoteUpdateUserSK int,
            UnregClients int,
            NonScheduled varchar(5),
            ActivityType nvarchar(25),
            ActivityTypeDescription nvarchar(14),
            [Status] nvarchar(25),
            WorkshopID int,
            WorkshopSessionID int,
            UseSeqOvr varchar(5),
            Confirmed varchar(5),
            AcceptCancellationPolicy varchar(5),
            ResolvedDate date,
            ReviewRequired varchar(5),
            ForReview varchar(5),
            SiteRegion nvarchar(100),
            SiteRegionGLCode nvarchar(15),
            EventSeq int,
            EventSeqShow int,
            EventSeqBilled int,
            index idx_pnpServiceEvent_SiteSK nonclustered (SiteSK),
            index idx_pnpServiceEvent_BookItemSK nonclustered (BookItemSK),
            index idx_pnpServiceEvent_ServiceFileSK nonclustered (ServiceFileSK),
            index idx_pnpServiceEvent_CaseSK nonclustered (CaseSK),
            index idx_pnpServiceEvent_FunderSK nonclustered (FunderSK),
            index idx_pnpServiceEvent_FunderDepartmentSK nonclustered (FunderDepartmentSK),
            index idx_pnpServiceEvent_PrimaryWorkerUserSK nonclustered (PrimaryWorkerUserSK),
            index idx_pnpServiceEvent_BillActOvrIndividualSK nonclustered (BillActOvrIndividualSK),
            index idx_pnpServiceEvent_ServiceEventID nonclustered (ServiceEventID),
            index idx_pnpServiceEvent_SiteID nonclustered (SiteID),
            index idx_pnpServiceEvent_BookItemID nonclustered (BookItemID),
            index idx_pnpServiceEvent_ServiceFileID nonclustered (ServiceFileID),
            index idx_pnpServiceEvent_CaseID nonclustered (CaseID),
            index idx_pnpServiceEvent_FunderID nonclustered (FunderID),
            index idx_pnpServiceEvent_FunderDepartmentID nonclustered (FunderDepartmentID),
            index idx_pnpServiceEvent_PrimaryWorkerID nonclustered (PrimaryWorkerID),
            index idx_pnpServiceEvent_PrimaryWorkerUserID nonclustered (PrimaryWorkerUserID),
            index idx_pnpServiceEvent_BillActOvrIndividualID nonclustered (BillActOvrIndividualID),
        )
    end;

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int = 0,
        @insertcount int = 0,
        @updatecount int = 0

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

    begin transaction
    begin try

        if object_id('[db-au-stage].dbo.penelope_etact_audtc') is not null and object_id('[db-au-stage].dbo.penelope_etactcase_audtc') is not null 
        begin

            if object_id('tempdb..#src') is not null drop table #src 
    
            select 
                sf.ServiceFileSK,
                sf.CaseSK,
                sf.FunderSK,
                sf.FunderDepartmentSK,
                w1.PrimaryWorkerUserSK,
                w2.SecWorkerUserSK,
                i.BillActOvrIndividualSK, 
                s.SiteSK,
                bi.BookItemSK,
                convert(varchar, se1.kactid) as ServiceEventID,
                convert(varchar, se1.ksiteid) as SiteID,
                se1.kbookitemidby as BookItemID,
                case when cat.actcatname = 'Indirect' then 'DUMMY_FOR_INDIRECT_EVENT' else convert(varchar, se2.kprogprovid) end as ServiceFileID,
                sf.CaseID,
                sf.FunderID,
                sf.FunderDepartmentID,
                at.activitytypename as ActivityType,
                at.shortdesc as ActivityTypeDescription,
                st.actstatus as [Status],
                se2.kcworkshopid as WorkshopID,
                se2.ksessid as WorkshopSessionID,
                se2.useseqovr as UseSeqOvr,
                convert(varchar, se2.kcworkeridprimact) as PrimaryWorkerID,
                convert(varchar, w.kuserid) as PrimaryWorkerUserID,
                convert(varchar, se2.kcworkeridsecact) as SecWorkerID,
                se2.confirmed as Confirmed,
                se2.acceptcancellationpolicy as AcceptCancellationPolicy,
                se2.resolveddate as ResolvedDate,
                se2.reviewrequired as ReviewRequired,
                se2.forreview as ForReview,
                sr.siteregion as SiteRegion,
                sr.siteregionglcode as SiteRegionGLCode,
                convert(varchar, se2.kbillindidactovr) as BillActOvrIndividualID,
                se1.acttitle as Title,
                se1.actstime as StartDatetime,
                se1.actetime as EndDatetime,
                se1.actout as Out,
                cat.actcatname as Category,
                convert(nvarchar(max), se1.actnotes) as Notes,
                --[db-au-stage].dbo.udf_StripHTML(se1.actnotes) as Notes,
                se1.slogin as CreatedDatetime,
                se1.slogmod as UpdatedDatetime,
                se1.sloginby as CreatedBy,
                se1.slogmodby as UpdatedBy,
                se1.actnotesfinished as NotesFinished,
                se1.followuprequired as FollowupRequired,
                se1.actlock as Lock,
                se1.firstsessinseries as FirstSessionInSeries,
                se1.snotemod as NoteUpdateDatetime,
                convert(varchar, se1.kuseridnotemod) as NoteUpdateUserID,
                nuu.NoteUpdateUserSK,
                se1.unregclients as UnregClients,
                se1.nonsched as NonScheduled 
            into #src 
            from 
                penelope_etact_audtc se1 
                left join penelope_etactcase_audtc se2 on se1.kactid = se2.kactid 
                left join penelope_ssactcat_audtc cat on cat.kactcatid = se1.kactcatid
                outer apply (
                    select top 1 SiteSK
                    from [db-au-dtc].dbo.pnpSite
                    where SiteID = convert(varchar, se1.ksiteid)
                ) s
                outer apply (
                    select top 1 BookItemSK
                    from [db-au-dtc].dbo.pnpBookItem
                    where BookItemID = se1.kbookitemidby
                ) bi
                outer apply (
                    select top 1 UserSK as NoteUpdateUserSK
                    from [db-au-dtc].dbo.pnpUser
                    where UserID = convert(varchar, se1.kuseridnotemod)
                        and IsCurrent = 1
                ) nuu 
                left join penelope_saacttype_audtc at on at.kactivitytypeid = se2.kactivitytypeid
                left join penelope_ssactstatus_audtc st on st.kactstatusid = se2.kactstatusid
                left join penelope_wrcworker_audtc w on w.kcworkerid = se2.kcworkeridprimact
                left join penelope_lusiteregion_audtc sr on sr.lusiteregionid = se2.lusiteregionid
                outer apply (
                    select top 1 ServiceFileSK, CaseSK, FunderSK, FunderDepartmentSK, CaseID, FunderID, FunderDepartmentID
                    from [db-au-dtc].dbo.pnpServiceFile
                    where ServiceFileID = case when cat.actcatname = 'Indirect' then 'DUMMY_FOR_INDIRECT_EVENT' else convert(varchar, se2.kprogprovid) end 
                ) sf 
                outer apply (
                    select top 1 UserSK as PrimaryWorkerUserSK
                    from [db-au-dtc].dbo.pnpUser
                    where UserID = convert(varchar, w.kuserid)
                        and IsCurrent = 1
                ) w1
                outer apply (
                    select top 1 UserSK as SecWorkerUserSK
                    from [db-au-dtc].dbo.pnpUser
                    where WorkerID = convert(varchar, se2.kcworkeridsecact) 
                        and IsCurrent = 1
                ) w2
                outer apply (
                    select top 1 IndividualSK as BillActOvrIndividualSK
                    from [db-au-dtc].dbo.pnpIndividual
                    where IndividualID = convert(varchar, se2.kbillindidactovr) 
                        and IsCurrent = 1
                ) i 

            --20180321, LL, optimise
            update #src
            set
                Notes = [db-au-stage].dbo.xfn_StripHTML(Notes)

            select @sourcecount = count(*) from #src 

            merge [db-au-dtc].dbo.pnpServiceEvent as tgt 
            using #src 
                on #src.ServiceEventID = tgt.ServiceEventID 
            when matched then 
                update set 
                    tgt.SiteSK = #src.SiteSK,
                    tgt.BookItemSK = #src.BookItemSK,
                    tgt.SiteID = #src.SiteID,
                    tgt.BookItemID = #src.BookItemID,
                    tgt.Title = #src.Title,
                    tgt.StartDatetime = #src.StartDatetime,
                    tgt.EndDatetime = #src.EndDatetime,
                    tgt.[Out] = #src.[Out],
                    tgt.Category = #src.Category,
                    tgt.Notes = #src.Notes,
                    tgt.UpdatedDatetime = #src.UpdatedDatetime,
                    tgt.UpdatedBy = #src.UpdatedBy,
                    tgt.NotesFinished = #src.NotesFinished,
                    tgt.FollowupRequired = #src.FollowupRequired,
                    tgt.Lock = #src.Lock,
                    tgt.FirstSessionInSeries = #src.FirstSessionInSeries,
                    tgt.NoteUpdateDatetime = #src.NoteUpdateDatetime,
                    tgt.NoteUpdateUserID = #src.NoteUpdateUserID,
                    tgt.NoteUpdateUserSK = #src.NoteUpdateUserSK,
                    tgt.UnregClients = #src.UnregClients,
                    tgt.NonScheduled = #src.NonScheduled,
                    tgt.ServiceFileSK = #src.ServiceFileSK,
                    tgt.CaseSK = #src.CaseSK,
                    tgt.FunderSK = #src.FunderSK,
                    tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
                    tgt.PrimaryWorkerUserSK = #src.PrimaryWorkerUserSK,
                    tgt.SecWorkerUserSK = #src.SecWorkerUserSK,
                    tgt.BillActOvrIndividualSK = #src.BillActOvrIndividualSK,
                    tgt.ServiceFileID = #src.ServiceFileID,
                    tgt.CaseID = #src.CaseID,
                    tgt.FunderID = #src.FunderID,
                    tgt.FunderDepartmentID = #src.FunderDepartmentID,
                    tgt.ActivityType = #src.ActivityType,
                    tgt.ActivityTypeDescription = #src.ActivityTypeDescription,
                    tgt.[Status] = #src.[Status],
                    tgt.WorkshopID = #src.WorkshopID,
                    tgt.WorkshopSessionID = #src.WorkshopSessionID,
                    tgt.UseSeqOvr = #src.UseSeqOvr,
                    tgt.PrimaryWorkerID = #src.PrimaryWorkerID,
                    tgt.PrimaryWorkerUserID = #src.PrimaryWorkerUserID,
                    tgt.SecWorkerID = #src.SecWorkerID,
                    tgt.Confirmed = #src.Confirmed,
                    tgt.AcceptCancellationPolicy = #src.AcceptCancellationPolicy,
                    tgt.ResolvedDate = #src.ResolvedDate,
                    tgt.ReviewRequired = #src.ReviewRequired,
                    tgt.ForReview = #src.ForReview,
                    tgt.SiteRegion = #src.SiteRegion,
                    tgt.SiteRegionGLCode = #src.SiteRegionGLCode,
                    tgt.BillActOvrIndividualID = #src.BillActOvrIndividualID

            when not matched by target then 
                insert (
                    SiteSK,
                    BookItemSK,
                    ServiceEventID,
                    SiteID,
                    BookItemID,
                    Title,
                    StartDatetime,
                    EndDatetime,
                    [Out],
                    Category,
                    Notes,
                    CreatedDatetime,
                    UpdatedDatetime,
                    CreatedBy,
                    UpdatedBy,
                    NotesFinished,
                    FollowupRequired,
                    Lock,
                    FirstSessionInSeries,
                    NoteUpdateDatetime,
                    NoteUpdateUserID,
                    NoteUpdateUserSK,
                    UnregClients,
                    NonScheduled,
                    ServiceFileSK,
                    CaseSK,
                    FunderSK,
                    FunderDepartmentSK,
                    PrimaryWorkerUserSK,
                    SecWorkerUserSK,
                    BillActOvrIndividualSK,
                    ServiceFileID,
                    CaseID,
                    FunderID,
                    FunderDepartmentID,
                    ActivityType,
                    ActivityTypeDescription,
                    [Status],
                    WorkshopID,
                    WorkshopSessionID,
                    UseSeqOvr,
                    PrimaryWorkerID,
                    PrimaryWorkerUserID,
                    SecWorkerID,
                    Confirmed,
                    AcceptCancellationPolicy,
                    ResolvedDate,
                    ReviewRequired,
                    ForReview,
                    SiteRegion,
                    SiteRegionGLCode,
                    BillActOvrIndividualID
                )
                values (
                    #src.SiteSK,
                    #src.BookItemSK,
                    #src.ServiceEventID,
                    #src.SiteID,
                    #src.BookItemID,
                    #src.Title,
                    #src.StartDatetime,
                    #src.EndDatetime,
                    #src.[Out],
                    #src.Category,
                    #src.Notes,
                    #src.CreatedDatetime,
                    #src.UpdatedDatetime,
                    #src.CreatedBy,
                    #src.UpdatedBy,
                    #src.NotesFinished,
                    #src.FollowupRequired,
                    #src.Lock,
                    #src.FirstSessionInSeries,
                    #src.NoteUpdateDatetime,
                    #src.NoteUpdateUserID,
                    #src.NoteUpdateUserSK,
                    #src.UnregClients,
                    #src.NonScheduled,
                    #src.ServiceFileSK,
                    #src.CaseSK,
                    #src.FunderSK,
                    #src.FunderDepartmentSK,
                    #src.PrimaryWorkerUserSK,
                    #src.SecWorkerUserSK,
                    #src.BillActOvrIndividualSK,
                    #src.ServiceFileID,
                    #src.CaseID,
                    #src.FunderID,
                    #src.FunderDepartmentID,
                    #src.ActivityType,
                    #src.ActivityTypeDescription,
                    #src.[Status],
                    #src.WorkshopID,
                    #src.WorkshopSessionID,
                    #src.UseSeqOvr,
                    #src.PrimaryWorkerID,
                    #src.PrimaryWorkerUserID,
                    #src.SecWorkerID,
                    #src.Confirmed,
                    #src.AcceptCancellationPolicy,
                    #src.ResolvedDate,
                    #src.ReviewRequired,
                    #src.ForReview,
                    #src.SiteRegion,
                    #src.SiteRegionGLCode,
                    #src.BillActOvrIndividualID
                )
            output $action into @mergeoutput;

            select
                @insertcount = sum(case when MergeAction = 'Insert' then 1 else 0 end),
                @updatecount = sum(case when MergeAction = 'Update' then 1 else 0 end)
            from
                @mergeoutput

        end

        -- update RegServiceEventSK in [db-au-dtc].dbo.pnpServiceFile
        update sf
        set RegServiceEventSK = rse.RegServiceEventSK
        from 
            [db-au-dtc].dbo.pnpServiceFile sf
            cross apply (
                select top 1 ServiceEventSK as RegServiceEventSK
                from [db-au-dtc].dbo.pnpServiceEvent
                where ServiceEventID = convert(varchar, sf.RegServiceEventID)
            ) rse
        where 
            --20180321, LL, optimise
            --RegServiceEventID is not null
            ServiceFileSK in
            (
                select
                    ServiceFileSK
                from
                    #src
            )




        if object_id('tempdb..#seq') is not null
            drop table #seq

        select
            ServiceEventSK,
            row_number() over(partition by ServiceFileSK order by StartDatetime) EventSeq,
            case
                when se.Status <> 'Show' then null
                else row_number() over 
                    (
                        partition by ServiceFileSK 
                        order by 
                            case 
                                when se.Status <> 'Show' then '5000-01-01'
                                else StartDatetime
                            end
                    )
            end EventSeqShow,
            case
                when se.Status not in ('Show', 'No Show', 'Late Cn; Billed As NoShow') then null
                else row_number() over 
                    (
                        partition by ServiceFileSK 
                        order by 
                            case 
                                when se.Status not in ('Show', 'No Show', 'Late Cn; Billed As NoShow') then '5000-01-01'
                                else StartDatetime
                            end
                    )
            end EventSeqBilled
        into #seq
        from 
            [db-au-dtc]..pnpServiceEvent se 
        where
            se.ServiceFileSK in
            (
                select 
                    ServiceFileSK
                from
                    #src
            ) and
            --20180327, LL
            --previous code: 
            --for dates, exclude clientele's invoice
            --for sequence, include clientele's invoice
            --impact:
            --disconnect between first event date and first event sequence
            --no impact on show & billed
            --change:
            --also exclude clientele's invoice in event sequence
            ServiceEventID not like 'CLI_INV_%' 
        
        update se
        set
            EventSeq = cte.EventSeq,
            EventSeqShow = cte.EventSeqShow,
            EventSeqBilled = cte.EventSeqBilled
        from
            [db-au-dtc]..pnpServiceEvent se 
            inner join #seq cte on
                cte.ServiceEventSK = se.ServiceEventSK


        -- update FirstEventDatetime in [db-au-dtc]..pnpServiceFile 
        -- update FirstShowEventDatetime in [db-au-dtc]..pnpServiceFile 
        -- update FirstBilledEventDatetime in [db-au-dtc]..pnpServiceFile 
        -- update pnpServiceFile.LastActivityDatetime 

        --select
        --    sf.ServiceFileSK,
        --    sf.FirstEventDatetime,
        --    sf.FirstShowEventDatetime,
        --    sf.FirstBilledEventDatetime,
        --    sf.LastActivityDatetime,
        --    se.*
        update sf
        set
            sf.FirstEventDatetime = se.FirstEventDatetime,
            sf.FirstShowEventDatetime = se.FirstShowEventDatetime,
            sf.FirstBilledEventDatetime = se.FirstBilledEventDatetime,
            sf.LastActivityDatetime = se.LastActivityDatetime
        from
            [db-au-dtc]..pnpServiceFile sf
            outer apply
            (
                select
                    min
                    (
                        case
                            when se.EventSeq = 1 then convert(date, se.StartDatetime)
                            else null
                        end 
                    ) FirstEventDatetime,
                    min
                    (
                        case
                            when se.EventSeqShow = 1 then convert(date, se.StartDatetime)
                            else null
                        end 
                    ) FirstShowEventDatetime,
                    min
                    (
                        case
                            when se.EventSeqBilled = 1 then convert(date, se.StartDatetime)
                            else null
                        end 
                    ) FirstBilledEventDatetime,
                    max
                    (
                        case
                            when se.EventSeqBilled is not null then se.StartDatetime
                            else null
                        end 
                    ) LastActivityDatetime
                from
                    [db-au-dtc]..pnpServiceEvent se
                where
                    se.ServiceFileSK = sf.ServiceFileSK
            ) se
        where
            sf.ServiceFileSK in
            (
                select
                    ServiceFileSK
                from
                    #src
            )
            
        
        --select
        --    c.CaseSK,
        --    c.FirstEventDatetime,
        --    c.FirstShowEventDatetime,
        --    c.FirstBilledEventDatetime,
        --    sf.*
        update c
        set
            c.FirstEventDatetime = sf.FirstEventDatetime,
            c.FirstShowEventDatetime = sf.FirstShowEventDatetime,
            c.FirstBilledEventDatetime = sf.FirstBilledEventDatetime
        from
            [db-au-dtc]..pnpCase c
            outer apply
            (
                select
                    min(sf.FirstEventDatetime) FirstEventDatetime,
                    min(sf.FirstShowEventDatetime) FirstShowEventDatetime,
                    min(sf.FirstBilledEventDatetime) FirstBilledEventDatetime
                from
                    [db-au-dtc]..pnpServiceFile sf
                where
                    sf.CaseSK = c.CaseSK
            ) sf
        where
            CaseSK in
            (
                select
                    CaseSK
                from
                    #src
            )

        -- update FirstEventDatetime in [db-au-dtc]..pnpCase 
        -- update FirstShowEventDatetime in [db-au-dtc]..pnpCase 
        -- update FirstBilledEventDatetime in [db-au-dtc]..pnpCase 



        ---- update FirstEventDatetime in [db-au-dtc]..pnpServiceFile 
        --if object_id('tempdb..#fed') is not null drop table #fed 
        --select 
        --    ServiceFileID,
        --    FirstEventDatetime 
        --into 
        --    #fed 
        --from (
        --    select 
        --        ServiceFileID,  
        --        convert(date, StartDatetime) FirstEventDatetime,
        --        row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --ServiceFileID is not null 
        --        ServiceFileID in
        --        (
        --            select
        --                ServiceFileID
        --            from
        --                #src
        --        )
        --) a 
        --where 
        --    rn = 1 

        --update sf 
        --set FirstEventDatetime = #fed.FirstEventDatetime 
        --from 
        --    [db-au-dtc]..pnpServiceFile sf 
        --    inner join #fed on #fed.ServiceFileID = sf.ServiceFileID 


        ---- update FirstShowEventDatetime in [db-au-dtc]..pnpServiceFile 
        --if object_id('tempdb..#fsed') is not null drop table #fsed 
        --select 
        --    ServiceFileID,
        --    FirstShowEventDatetime 
        --into 
        --    #fsed 
        --from (
        --    select 
        --        ServiceFileID,  
        --        convert(date, StartDatetime) FirstShowEventDatetime,
        --        row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --ServiceFileID is not null 
        --        ServiceFileID in
        --        (
        --            select
        --                ServiceFileID
        --            from
        --                #src
        --        )
        --        and Status = 'Show'
        --) a 
        --where 
        --    rn = 1 

        --update sf 
        --set FirstShowEventDatetime = #fsed.FirstShowEventDatetime 
        --from 
        --    [db-au-dtc]..pnpServiceFile sf 
        --    inner join #fsed on #fsed.ServiceFileID = sf.ServiceFileID 


        ---- update FirstBilledEventDatetime in [db-au-dtc]..pnpServiceFile 
        --if object_id('tempdb..#fbed') is not null drop table #fbed 
        --select 
        --    ServiceFileID,
        --    FirstBilledEventDatetime 
        --into 
        --    #fbed 
        --from (
        --    select 
        --        ServiceFileID,  
        --        convert(date, StartDatetime) FirstBilledEventDatetime,
        --        row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --ServiceFileID is not null 
        --        ServiceFileID in
        --        (
        --            select
        --                ServiceFileID
        --            from
        --                #src
        --        )
        --        and Status in ('Show', 'No Show', 'Late Cn; Billed As NoShow')
        --) a 
        --where 
        --    rn = 1 

        --update sf 
        --set FirstBilledEventDatetime = #fbed.FirstBilledEventDatetime 
        --from 
        --    [db-au-dtc]..pnpServiceFile sf 
        --    join #fbed on #fbed.ServiceFileID = sf.ServiceFileID 


        ---- update FirstEventDatetime in [db-au-dtc]..pnpCase 
        --if object_id('tempdb..#fced') is not null drop table #fced 
        --select 
        --    CaseID,
        --    FirstEventDatetime 
        --into 
        --    #fced 
        --from (
        --    select 
        --        CaseID,  
        --        convert(date, StartDatetime) FirstEventDatetime,
        --        row_number() over(partition by CaseID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --CaseID is not null 
        --        CaseID in
        --        (
        --            select
        --                CaseID
        --            from
        --                #src
        --        )
        --) a 
        --where 
        --    rn = 1 

        --update c 
        --set FirstEventDatetime = #fced.FirstEventDatetime 
        --from 
        --    [db-au-dtc]..pnpCase c 
        --    inner join #fced on #fced.CaseID = c.CaseID 


        ---- update FirstShowEventDatetime in [db-au-dtc]..pnpCase 
        --if object_id('tempdb..#fcsed') is not null drop table #fcsed 
        --select 
        --    CaseID,
        --    FirstShowEventDatetime 
        --into 
        --    #fcsed 
        --from (
        --    select 
        --        CaseID,  
        --        convert(date, StartDatetime) FirstShowEventDatetime,
        --        row_number() over(partition by CaseID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --CaseID is not null 
        --        CaseID in
        --        (
        --            select
        --                CaseID
        --            from
        --                #src
        --        )
        --        and Status = 'Show'
        --) a 
        --where 
        --    rn = 1 

        --update c 
        --set FirstShowEventDatetime = #fcsed.FirstShowEventDatetime 
        --from 
        --    [db-au-dtc]..pnpCase c  
        --    join #fcsed on #fcsed.CaseID = c.CaseID 


        ---- update FirstBilledEventDatetime in [db-au-dtc]..pnpCase 
        --if object_id('tempdb..#fcbed') is not null drop table #fcbed 
        --select 
        --    CaseID,
        --    FirstBilledEventDatetime 
        --into 
        --    #fcbed 
        --from (
        --    select 
        --        CaseID,  
        --        convert(date, StartDatetime) FirstBilledEventDatetime,
        --        row_number() over(partition by CaseID order by StartDatetime) rn
        --    from 
        --        [db-au-dtc]..pnpServiceEvent 
        --    where 
        --        --20180321, LL, optimise
        --        --CaseID is not null 
        --        CaseID in
        --        (
        --            select
        --                CaseID
        --            from
        --                #src
        --        )
        --        and Status in ('Show', 'No Show', 'Late Cn; Billed As NoShow')
        --) a 
        --where 
        --    rn = 1 

        --update c 
        --set FirstBilledEventDatetime = #fcbed.FirstBilledEventDatetime 
        --from 
        --    [db-au-dtc]..pnpCase c 
        --    join #fcbed on #fcbed.CaseID = c.CaseID 


        ---- update EventSeq, EventSeqShow, EventSeqBilled
        --update se 
        --set EventSeq = s.rn 
        --from 
        --    [db-au-dtc]..pnpServiceEvent se 
        --    join (
        --        select 
        --            ServiceEventID,  
        --            row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --        from 
        --            [db-au-dtc]..pnpServiceEvent 
        --        where 
        --            ServiceFileID is not null 
        --            and ServiceEventID not like 'CLI_INV_%' 
        --    ) s 
        --        on se.ServiceEventID = s.ServiceEventID 

        --update se 
        --set EventSeqShow = s.rn 
        --from 
        --    [db-au-dtc]..pnpServiceEvent se 
        --    join (
        --        select 
        --            ServiceEventID,  
        --            row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --        from 
        --            [db-au-dtc]..pnpServiceEvent 
        --        where 
        --            ServiceFileID is not null 
        --            and ServiceEventID not like 'CLI_INV_%' 
        --            and Status = 'Show'
        --    ) s 
        --        on se.ServiceEventID = s.ServiceEventID 

        --update se 
        --set EventSeqBilled = s.rn 
        --from 
        --    [db-au-dtc]..pnpServiceEvent se 
        --    join (
        --        select 
        --            ServiceEventID,  
        --            row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --        from 
        --            [db-au-dtc]..pnpServiceEvent 
        --        where 
        --            ServiceFileID is not null 
        --            and ServiceEventID not like 'CLI_INV_%' 
        --            and Status in ('Show', 'No Show', 'Late Cn; Billed As NoShow')
        --    ) s 
        --        on se.ServiceEventID = s.ServiceEventID 





        -- update pnpServiceFile.LastActivityDatetime 
        --update sf 
        --set LastActivityDatetime = la.LastActivityDatetime 
        --from 
        --    [db-au-dtc]..pnpServiceFile sf 
        --    join (
        --        select 
        --            ServiceFileID, 
        --            StartDatetime LastActivityDatetime, 
        --            row_number() over(partition by ServiceFileID order by StartDatetime) rn
        --        from 
        --            [db-au-dtc]..pnpServiceEvent se 
        --        where 
        --            ServiceFileID is not null 
        --            and ServiceEventID not like 'CLI_INV_%' 
        --            and Status in ('Show', 'No Show', 'Late Cn; Billed As NoShow')
        --    ) la 
        --        on la.ServiceFileID = sf.ServiceFileID and rn = 1 

        --update sf
        --set
        --    LastActivityDatetime = se.LastActivityDatetime
        --from
        --    [db-au-dtc]..pnpServiceFile sf 
        --    cross apply
        --    (
        --        select
        --            max(se.StartDateTime) LastActivityDatetime
        --        from
        --            [db-au-dtc]..pnpServiceEvent se 
        --        where
        --            se.ServiceFileSK = sf.ServiceFileSK and
        --            se.ServiceEventID not like 'CLI_INV_%' and
        --            se.Status in ('Show', 'No Show', 'Late Cn; Billed As NoShow')
        --    ) se
        --where
        --    sf.ServiceFileSK in
        --    (
        --        select 
        --            ServiceFileSK
        --        from
        --            #src
        --    )


       -- --update cart item schedule dates
       -- update sea
       -- set
       --     ScheduleStartDate =
       -- 	    case 
				   -- when se.WorkshopID is not null  then convert(date, se.StartDatetime) 
				   -- else null 
			    --end,
       --     ScheduleEndDate =
			    --case 
				   -- when se.WorkshopID is not null then dateadd(day, -1, dateadd(month, sea.UnitOfMeasurementIsEquivalent * abs(sea.Quantity), convert(date, se.StartDatetime))) --ADJ 20180313 - DM - Included the QTY in the calculation
				   -- else null 
			    --end 
       -- from
       --     [db-au-dtc]..pnpServiceEventActivity sea
       --     inner join [db-au-dtc]..pnpServiceEvent se on
       --         se.ServiceEventSK = sea.ServiceEventSK
       -- where
       --     se.ServiceEventID in
       --     (
       --         select
       --             ServiceEventID
       --         from
       --             #src
       --     )


        -- update dummy cart items for indirect events 
        if object_id('tempdb..#dummy') is not null drop table #dummy
        select 
            se.ServiceEventSK,
            se.ServiceFileSK,
            se.CaseSK,
            'DUMMY_FOR_INDIRECT_EVENT_' + ServiceEventID ServiceEventActivityID,
            se.ServiceEventID,
            se.ServiceFileID,
            se.CaseID,
            se.CreatedDatetime,
            se.UpdatedDatetime,
            se.CreatedBy,
            se.UpdatedBy,
			I.ItemSK,
			I.ItemID,
			I.UnitOfMeasurementClass,
			I.UnitOfMeasurementIsEquivalent,
			I.UnitOfMeasurementIsName,
			I.UnitOfMeasurementIsSchedule,
			I.UnitOfMeasurementIsTime,
			I.Name,
			CAST(DateDiff(minute, se.StartDateTime, se.EndDatetime) as float) / 60.0 as Qty
        into #dummy 
        from 
            [db-au-dtc]..pnpServiceEvent se
			left join penelope_etactind_audtc sea on se.ServiceEventID = CAST(sea.kactid as varchar)
			left join [db-au-dtc].dbo.pnpItem I ON 'INDIRECT_' + CAST(sea.luaindtypeid as varchar)= I.ItemID
        where 
            Category = 'Indirect' 

        merge [db-au-dtc]..pnpServiceEventActivity tgt 
        using #dummy src 
            on src.ServiceEventActivityID = tgt.ServiceEventActivityID 
        when matched then update set 
            tgt.ServiceEventSK = src.ServiceEventSK,
            tgt.ServiceFileSK = src.ServiceFileSK,
            tgt.CaseSK = src.CaseSK,
            tgt.ServiceEventID = src.ServiceEventID,
            tgt.ServiceFileID = src.ServiceFileID,
            tgt.CaseID = src.CaseID,
            tgt.CreatedDatetime = src.CreatedDatetime,
            tgt.UpdatedDatetime = src.UpdatedDatetime,
            tgt.CreatedBy = src.CreatedBy,
            tgt.UpdatedBy = src.UpdatedBy,
			tgt.ItemSK = src.itemSK,
			tgt.ItemID = src.ItemID,
			tgt.Name = src.name,
			tgt.UnitOfMeasurementClass = src.UnitOfMeasurementClass,
			tgt.UnitOfMeasurementIsEquivalent = src.UnitOfMeasurementIsEquivalent,
			tgt.UnitOfMeasurementIsName = src.UnitOfMeasurementIsName,
			tgt.UnitOfMeasurementIsSchedule = src.UnitOfMeasurementIsSchedule,
			tgt.UnitOfMeasurementIsTime = src.UnitOfMeasurementIsTime,
			tgt.Quantity = src.Qty
        when not matched by target then 
            insert (
                ServiceEventSK,
                ServiceFileSK,
                CaseSK,
                ServiceEventActivityID,
                ServiceEventID,
                ServiceFileID,
                CaseID,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
				ItemSK,
				ItemID,
				Name,
				UnitOfMeasurementClass,
				UnitOfMeasurementIsEquivalent,
				UnitOfMeasurementIsName,
				UnitOfMeasurementIsSchedule,
				UnitOfMeasurementIsTime,
				Quantity
            )
            values (
                src.ServiceEventSK,
                src.ServiceFileSK,
                src.CaseSK,
                src.ServiceEventActivityID,
                src.ServiceEventID,
                src.ServiceFileID,
                src.CaseID,
                src.CreatedDatetime,
                src.UpdatedDatetime,
                src.CreatedBy,
                src.UpdatedBy,
				src.ItemSK,
				src.ItemID,
				src.Name,
				src.UnitOfMeasurementClass,
				src.UnitOfMeasurementIsEquivalent,
				src.UnitOfMeasurementIsName,
				src.UnitOfMeasurementIsSchedule,
				src.UnitOfMeasurementIsTime,
				src.Qty
            );


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
