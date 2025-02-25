USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceFile]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpServiceFile
-- Modifications: 20181019 - DM - SEARCH: MOD20181019 - Commented out due to Server issues
--				  20181030 - DM - Re-instating commented out code as per above
--				  20181108 - DM - Moved code to update the Trauma Department overrides to [etlsp_ETL083_pnpBillSeq] 
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceFile]
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

    if object_id('[db-au-dtc].dbo.pnpServiceFile') is null
    begin
        create table [db-au-dtc].[dbo].[pnpServiceFile](
            ServiceFileSK int identity(1,1) primary key,
            ServiceSK int,
            PolicySK int,
            CaseSK int,
            FunderSK int,
            FunderDepartmentSK int,
            PrimaryWorkerUserSK int,
            PresentingServiceFileMemberSK int,
            BillIndividualSK int,
            SecBillIndividualSK int,
            RegServiceEventSK int,
            ServiceFileID varchar(50),
            PolicyID varchar(50),
            CaseID varchar(50),
            FunderID varchar(50),
            FunderDepartmentID varchar(50),
            [Service] nvarchar(80),
            Stream nvarchar(50),
            WorkshopID int,
            PrimaryWorkerID varchar(50),
            SecWorkerID varchar(50),
            StartDate date,
            EndDate date,
            [Status] nvarchar(20),
            BookOnly varchar(5),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            FeeOvr numeric(10,2),
            kppfunagreid int,
            SessionRemind varchar(5),
            DaysRemind varchar(5),
            EstimatedSessions int,
            BillIndividualPercent numeric(5,3),
            PresentingServiceFileMemberID varchar(50),
            RegServiceEventID int,
            ClienteleJobNumber nvarchar(100),
            CostCentre nvarchar(100),
            InvoiceText nvarchar(max),
            CounsellingType nvarchar(200),
            RelatedWorkImpact nvarchar(200),
            WorkImpactNature nvarchar(200),
            ReferralSource nvarchar(100),
            SelfReferralSource nvarchar(100),
            EmploymentPeriod nvarchar(100),
            WorkPlaceDiversityGroup nvarchar(100),
            CaseManagement nvarchar(100),
            FirstEventDatetime datetime2,
            FirstShowEventDatetime datetime2,
            FirstBilledEventDatetime datetime2,
            CPFStatus varchar (20),
            LastActivityDatetime datetime2,
            PolicyReference nvarchar(50),
            ManualRevenueAccrual smallint,
            index idx_pnpServiceFile_ServiceSK nonclustered (ServiceSK),
            index idx_pnpServiceFile_CaseSK nonclustered (CaseSK),
            index idx_pnpServiceFile_FunderSK nonclustered (FunderSK),
            index idx_pnpServiceFile_FunderDepartmentSK nonclustered (FunderDepartmentSK),
            index idx_pnpServiceFile_PrimaryWorkerUserSK nonclustered (PrimaryWorkerUserSK),
            index idx_pnpServiceFile_PresentingServiceFileMemberSK nonclustered (PresentingServiceFileMemberSK),
            index idx_pnpServiceFile_BillIndividualSK nonclustered (BillIndividualSK),
            index idx_pnpServiceFile_ServiceFileID nonclustered (ServiceFileID),
            index idx_pnpServiceFile_FirstEventDatetime nonclustered (FirstEventDatetime),
            index idx_pnpServiceFile_FirstShowEventDatetime nonclustered (FirstShowEventDatetime),
            index idx_pnpServiceFile_FirstBilledEventDatetime nonclustered (FirstBilledEventDatetime),
            index idx_pnpServiceFile_ClienteleJobNumber nonclustered (ClienteleJobNumber),
            index idx_pnpServiceFile_Stream_ServiceFileID nonclustered (Stream, ServiceFileID)
        )

        -- create dummy service file for indirect events
        insert into [db-au-dtc]..pnpServiceFile (
            ServiceFileID
        )
        values (
            'DUMMY_FOR_INDIRECT_EVENT'
        )

        update [db-au-dtc]..pnpServiceFile
        set CaseSK = (select top 1 CaseSK from [db-au-dtc]..pnpCase where CaseID = 'DUMMY_FOR_INDIRECT_EVENT'),
            CaseID = 'DUMMY_FOR_INDIRECT_EVENT'
        where
            ServiceFileID = 'DUMMY_FOR_INDIRECT_EVENT'

    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            sv.ServiceSK,
            p.PolicySK,
            c.CaseSK,
            f.FunderSK,
            fd.FunderDepartmentSK,
            w.PrimaryWorkerUserSK,
            bi.BillIndividualSK,
            sbi.SecBillIndividualSK,
            convert(varchar, sf.kprogprovid) as ServiceFileID,
            p.PolicyID,
            convert(varchar, c.CaseID) CaseID,
            f.FunderID,
            fd.FunderDepartmentID,
            s.asername as [Service],
            pg.proggroupname as Stream,
            sf.kcworkshopid as WorkshopID,
            convert(varchar, sf.kcworkeridprim) as PrimaryWorkerID,
            convert(varchar, sf.kcworkeridsec) as SecWorkerID,
            sf.pprovstart as StartDate,
            sf.pprovend as EndDate,
            sfs.progprovstatus as [Status],
            sf.pprovbookonly as BookOnly,
            sf.slogin as CreatedDatetime,
            sf.slogmod as UpdatedDatetime,
            sf.sloginby as CreatedBy,
            sf.slogmodby as UpdatedBy,
            sf.ppfeeovr as FeeOvr,
            sf.kppfunagreid as kppfunagreid,
            sf.ppsessremind as SessionRemind,
            sf.ppdaysremind as DaysRemind,
            sf.estimsessioncount as EstimatedSessions,
            sf.billindprimpercent as BillIndividualPercent,
            convert(varchar, sf.kprogmemidpres) as PresentingServiceFileMemberID,
            sf.kactidreg as RegServiceEventID,
            case
                when rtrim(sfe.progprovexp1) = '' then convert(varchar, sf.kprogprovid)
                when sfe.progprovexp1 is null then convert(varchar, sf.kprogprovid)
                else sfe.progprovexp1
            end as ClienteleJobNumber,
            sfe.progprovexp2 as CostCentre,
            --20180607, LL, move this to update statement
            sfe.progprovexp9 as InvoiceText,
            --[dbo].[udf_StripHTML](sfe.progprovexp9) as InvoiceText,
            p.PolicyReference
        into #src
        from
            penelope_ctprogprov_audtc sf
            left join penelope_prcaseprog_audtc cp on cp.kcaseprogid = sf.kcaseprogid
            left join penelope_pragser_audtc s on s.kagserid = cp.kagserid
            left join penelope_saproggroup_audtc pg on pg.kproggroupid = cp.kproggroupid
            left join penelope_ssprogprovstatus_audtc sfs on sfs.kprogprovstatusid = sf.kprogprovstatusid
            left join penelope_ctprogprovexp_audtc sfe on sfe.kprogprovid = sf.kprogprovid
            left join penelope_servicefile_funder_audtc sff on sff.kprogprovid = sf.kprogprovid -- sff from pnpCase ETL
            outer apply (
                select top 1 ServiceSK
                from [db-au-dtc].dbo.pnpService
                where ServiceID = convert(varchar, cp.kagserid)
            ) sv
            outer apply (
                select top 1 CaseSK, CaseID
                from [db-au-dtc].dbo.pnpCase
                where CaseID = convert(varchar, sf.kcaseid)
            ) c
            outer apply (
                select top 1 FunderSK, FunderID
                from [db-au-dtc].dbo.pnpFunder
                where FunderID = convert(varchar, sff.kfunderid) and IsCurrent = 1
            ) f
            outer apply (
                select top 1 FunderDepartmentSK, FunderDepartmentID
                from [db-au-dtc].dbo.pnpFunderDepartment
                where FunderDepartmentID = convert(varchar, sff.kfunderdeptid)
            ) fd
            outer apply (
                select top 1 UserSK as PrimaryWorkerUserSK
                from [db-au-dtc].dbo.pnpUser
                where WorkerID = convert(varchar, sf.kcworkeridprim)
                    and IsCurrent = 1
            ) w
            outer apply (
                select top 1 IndividualSK as BillIndividualSK
                from [db-au-dtc].dbo.pnpIndividual
                where IndividualID = convert(varchar, sf.kbillindid)
                    and IsCurrent = 1
            ) bi
            outer apply (
                select top 1 IndividualSK as SecBillIndividualSK
                from [db-au-dtc].dbo.pnpIndividual
                where IndividualID = convert(varchar, sf.kbillindsecid)
                    and IsCurrent = 1
            ) sbi
            outer apply (
                select
                    top 1 PolicySK, PolicyID, coalesce(nullif(PolicyNumber,''), PublicPolicyName, Name) PolicyReference
                from
                    [db-au-dtc].dbo.pnpPolicy
                where
                    PolicyID = convert(varchar, sff.kpolicyid)
            ) p

        update #src
        set
            InvoiceText = [dbo].[xfn_StripHTML](InvoiceText)

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpServiceFile as tgt
        using #src
            on #src.ServiceFileID = tgt.ServiceFileID
        when matched then
            update set
                tgt.PolicySK = #src.PolicySK,
                tgt.ServiceSK = #src.ServiceSK,
                tgt.CaseSK = #src.CaseSK,
                tgt.FunderSK = #src.FunderSK,
                tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
                tgt.PrimaryWorkerUserSK = #src.PrimaryWorkerUserSK,
                tgt.BillIndividualSK = #src.BillIndividualSK,
                tgt.SecBillIndividualSK = #src.SecBillIndividualSK,
                tgt.PolicyID = #src.PolicyID,
                tgt.CaseID = #src.CaseID,
                tgt.FunderID = #src.FunderID,
                tgt.FunderDepartmentID = #src.FunderDepartmentID,
                tgt.[Service] = #src.[Service],
                tgt.Stream = #src.Stream,
                tgt.WorkshopID = #src.WorkshopID,
                tgt.PrimaryWorkerID = #src.PrimaryWorkerID,
                tgt.SecWorkerID = #src.SecWorkerID,
                tgt.StartDate = #src.StartDate,
                tgt.EndDate = #src.EndDate,
                tgt.[Status] = #src.[Status],
                tgt.BookOnly = #src.BookOnly,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdatedBy = #src.UpdatedBy,
                tgt.FeeOvr = #src.FeeOvr,
                tgt.kppfunagreid = #src.kppfunagreid,
                tgt.SessionRemind = #src.SessionRemind,
                tgt.DaysRemind = #src.DaysRemind,
                tgt.EstimatedSessions = #src.EstimatedSessions,
                tgt.BillIndividualPercent = #src.BillIndividualPercent,
                tgt.PresentingServiceFileMemberID = #src.PresentingServiceFileMemberID,
                tgt.RegServiceEventID = #src.RegServiceEventID,
                tgt.ClienteleJobNumber = #src.ClienteleJobNumber,
                tgt.CostCentre = #src.CostCentre,
                tgt.InvoiceText = #src.InvoiceText,
                tgt.PolicyReference = #src.PolicyReference
        when not matched by target then
            insert (
                ServiceSK,
                PolicySK,
                CaseSK,
                FunderSK,
                FunderDepartmentSK,
                PrimaryWorkerUserSK,
                BillIndividualSK,
                SecBillIndividualSK,
                ServiceFileID,
                PolicyID,
                CaseID,
                FunderID,
                FunderDepartmentID,
                [Service],
                Stream,
                WorkshopID,
                PrimaryWorkerID,
                SecWorkerID,
                StartDate,
                EndDate,
                [Status],
                BookOnly,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
                FeeOvr,
                kppfunagreid,
                SessionRemind,
                DaysRemind,
                EstimatedSessions,
                BillIndividualPercent,
                PresentingServiceFileMemberID,
                RegServiceEventID,
                ClienteleJobNumber,
                CostCentre,
                InvoiceText,
                PolicyReference
            )
            values (
                #src.ServiceSK,
                #src.PolicySK,
                #src.CaseSK,
                #src.FunderSK,
                #src.FunderDepartmentSK,
                #src.PrimaryWorkerUserSK,
                #src.BillIndividualSK,
                #src.SecBillIndividualSK,
                #src.ServiceFileID,
                #src.PolicyID,
                #src.CaseID,
                #src.FunderID,
                #src.FunderDepartmentID,
                #src.[Service],
                #src.Stream,
                #src.WorkshopID,
                #src.PrimaryWorkerID,
                #src.SecWorkerID,
                #src.StartDate,
                #src.EndDate,
                #src.[Status],
                #src.BookOnly,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreatedBy,
                #src.UpdatedBy,
                #src.FeeOvr,
                #src.kppfunagreid,
                #src.SessionRemind,
                #src.DaysRemind,
                #src.EstimatedSessions,
                #src.BillIndividualPercent,
                #src.PresentingServiceFileMemberID,
                #src.RegServiceEventID,
                #src.ClienteleJobNumber,
                #src.CostCentre,
                #src.InvoiceText,
                #src.PolicyReference
            )

        output $action into @mergeoutput;

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		update sf
		set ClienteleJobNumber = bj.Job_num
		--select ServiceFileID, ClienteleJobNumber, bj.Job_num
		from [db-au-dtc]..pnpServiceFile sf
		join [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup sfl on CAST(sfl.kprogprovid as varchar) = sf.ServiceFileID
		join [db-au-stage].dbo.dtc_cli_Base_Job bj on sfl.uniquecaseid = bj.Pene_ID
		where IsNull(sf.ClienteleJobNumber,'') <> bj.Job_num

        -- use ServiceFileID if there is no ClienteleJobNumber
        update [db-au-dtc]..pnpServiceFile
        set ClienteleJobNumber = ServiceFileID
        where ClienteleJobNumber is null


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
