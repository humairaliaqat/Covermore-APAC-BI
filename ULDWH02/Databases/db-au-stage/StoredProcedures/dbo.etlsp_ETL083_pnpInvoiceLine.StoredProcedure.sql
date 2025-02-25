USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpInvoiceLine]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpInvoiceLine
-- Modification:
--  20180313 - DM - Included lines to create the "header" of a Credit from Penelope. The "invoice number" will be the Credit number inverse (negative).
--  20180327 - LL - optimise
--	20190329 - DM - Adjust logic for Invoice Line Department to match what is printed on invoice. Check if Department has been overriden, otherwise use the current department on the Policy Member attached. Keep a copy of the Original data from Invoice Line
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpInvoiceLine]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    if object_id('[db-au-dtc].dbo.pnpInvoiceLine') is null
    begin
        create table [db-au-dtc].[dbo].[pnpInvoiceLine](
            InvoiceLineSK int identity(1,1) primary key,
            InvoiceSK int,
            ServiceEventActivitySK int,
            PolicyCoverageSK int,
            PolicyMemberSK int,
            FunderSK int,
            FunderDepartmentSK int,
            IndividualSK int,
            PatientIndividualSK int,
            InvoiceLineID varchar(50),
            InvoiceLineType nvarchar(25),
            InvoiceLineTypeShort nvarchar(10),
            ServiceEventActivityID varchar(50),
            PolicyCoverageID varchar(50),
            PolicyMemberID varchar(100),
            FunderID varchar(50),
            FunderDepartmentID varchar(50),
            IndividualID varchar(50),
            Fee money,
            Total money,
            Adjustment money,
            AdjustmentID int,
            AdjustmentName nvarchar(20),
            AdjustmentCategory nvarchar(20),
            InvoiceSScale numeric(10,2),
            Amount money,
            Seq int,
            InvoiceID varchar(50),
            Paid varchar(5),
            PartialPaid varchar(5),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            PolicyAgreementID int,
            Quantity numeric(10,2),
            DispAmount money,
            InvoicePosted varchar(5),
            PatientIndividualID varchar(50),
            TaxAmount money,
            TotalAmount money,
            TaxAdjustment varchar(5),
            FullyAppliedDate date,
            ReceiptIDRet int,
            InvoiceLineIDRet varchar(50),
            NonChargeable tinyint,
            [Service] nvarchar(80),
            DeletedDatetime datetime2,
			OrigFunderDepartmentSK int,
			OrigFunderDepartmentID varchar(50),
            index idx_pnpInvoiceLine_InvoiceSK nonclustered (InvoiceSK),
            index idx_pnpInvoiceLine_InvoiceID nonclustered (InvoiceID),
            index idx_pnpInvoiceLine_ServiceEventActivitySK nonclustered (ServiceEventActivitySK),
            index idx_pnpInvoiceLine_PolicyCoverageSK nonclustered (PolicyCoverageSK, ServiceEventActivitySK, InvoiceLineID, InvoiceID),
            index idx_pnpInvoiceLine_PolicyMemberSK nonclustered (PolicyMemberSK),
            index idx_pnpInvoiceLine_FunderSK nonclustered (FunderSK),
            index idx_pnpInvoiceLine_FunderDepartmentSK nonclustered (FunderDepartmentSK),
            index idx_pnpInvoiceLine_IndividualSK nonclustered (IndividualSK),
            index idx_pnpInvoiceLine_PatientIndividualSK nonclustered (PatientIndividualSK),
            index idx_pnpInvoiceLine_InvoiceLineID nonclustered (InvoiceLineID),
            index idx_pnpInvoiceLine_ServiceEventActivityID nonclustered (ServiceEventActivityID),
            index idx_pnpInvoiceLine_PolicyCoverageID nonclustered (PolicyCoverageID),
            index idx_pnpInvoiceLine_PolicyMemberID nonclustered (PolicyMemberID),
            index idx_pnpInvoiceLine_FunderID nonclustered (FunderID),
            index idx_pnpInvoiceLine_FunderDepartmentID nonclustered (FunderDepartmentID),
            index idx_pnpInvoiceLine_IndividualID nonclustered (IndividualID),
            index idx_pnpInvoiceLine_PatientIndividualID nonclustered (PatientIndividualID),
            index idx_pnpInvoiceLine_InvoiceLineID_InvoiceID nonclustered (InvoiceLineID, InvoiceID)
    )
    end;

    if object_id('[db-au-stage].dbo.penelope_btinvline_audtc') is null
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

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            inv.InvoiceSK,
            sa.ServiceEventActivitySK,
            pc.PolicyCoverageSK,
            pm.PolicyMemberSK,
            f.FunderSK,
			IsNull(cor.FunderDepartmentSK, pm.FunderDepartmentSK) FunderDepartmentSK, --mod 20190329
            fd.FunderDepartmentSK as OrigFunderDepartmentSK, --mod 20190329
            i.IndividualSK,
            pind.PatientIndividualSK,
            convert(varchar, il.kinvlineid) as InvoiceLineID,
            ilt.invlinetype as InvoiceLineType,
            ilt.invlinetypeshort as InvoiceLineTypeShort,
            convert(varchar, il.kactlineid) as ServiceEventActivityID,
            convert(varchar, il.kcoverageid) as PolicyCoverageID,
            convert(varchar, il.kpolicymemid) as PolicyMemberID,
            convert(varchar, il.kfunderid) as FunderID,
			IsNull(cor.FunderDepartmentID, pm.FunderDepartmentID) as FunderDepartmentID,
            convert(varchar, il.kfunderdeptid) as OrigFunderDepartmentID,
            convert(varchar, il.kindid) as IndividualID,
            il.invlinefee as Fee,
            il.invlinetotal as Total,
            il.invlineadj as Adjustment,
            il.kadjustid as AdjustmentID,
            a.adjustment as AdjustmentName,
            ac.adjustcat as AdjustmentCategory,
            il.invsscale as InvoiceSScale,
            il.invlineamt as Amount,
            il.invlineseq as Seq,
            convert(varchar, IsNull(il.kreceiptidret * -1,  il.kinvoicenoid)) as InvoiceID, -- ADJ 20180313
            il.invlinepaid as Paid,
            il.invlinepartialpaid as PartialPaid,
            il.slogin as CreatedDatetime,
            il.slogmod as UpdatedDatetime,
            il.sloginby as CreatedBy,
            il.slogmodby as UpdatedBy,
            il.kpolagreid as PolicyAgreementID,
            il.invlineqty as Quantity,
            il.invlinedispamt as DispAmount,
            il.invposted as InvoicePosted,
            convert(varchar, il.kindidpatient) as PatientIndividualID,
            il.invlinetaxamt as TaxAmount,
            il.invlinetotamt as TotalAmount,
            il.invlinetaxadj as TaxAdjustment,
            il.fullyapplieddate as FullyAppliedDate,
            il.kreceiptidret as ReceiptIDRet,
            convert(varchar, il.kinvlineidret) as InvoiceLineIDRet,
            case
                when il.invlineamt = 0 and il.invlineadj <> 0 then 1
                else 0
            end NonChargeable,
            sf.[Service]
        into #src
        from
            penelope_btinvline_audtc il
            left join penelope_ssinvlinetype_audtc ilt on ilt.kinvlinetypeid = il.kinvlinetypeid
            left join penelope_saadjust_audtc a on a.kadjustid = il.kadjustid
            left join penelope_saadjustcat_audtc ac on ac.kadjustcatid = a.kadjustcatid
            outer apply (
                select top 1 InvoiceSK
                from [db-au-dtc]..pnpInvoice
                where InvoiceID = convert(varchar,  IsNull(il.kreceiptidret * -1,  il.kinvoicenoid)) -- ADJ 20180313
            ) inv
            outer apply (
                select top 1 ServiceEventActivitySK, ServiceFileSK, ServiceFileID, CaseID, CaseSK
                from [db-au-dtc]..pnpServiceEventActivity
                where ServiceEventActivityID = convert(varchar, il.kactlineid)
            ) sa
            outer apply (
                select top 1 PolicyCoverageSK
                from [db-au-dtc]..pnpPolicyCoverage
                where PolicyCoverageID = convert(varchar, il.kcoverageid)
            ) pc
            outer apply (
				--mod 20190329 DM: Add in FunderDepartmentSK
                select top 1 PolicyMemberSK, FunderDepartmentSK, FunderDepartmentID
                from [db-au-dtc]..pnpPolicyMember m
                where PolicyMemberID = convert(varchar, il.kpolicymemid)
            ) pm
            outer apply (
                select top 1 FunderSK
                from [db-au-dtc]..pnpFunder
                where FunderID = convert(varchar, il.kfunderid) and IsCurrent = 1
            ) f
            outer apply (
                select top 1 FunderDepartmentSK
                from [db-au-dtc]..pnpFunderDepartment
                where FunderDepartmentID = convert(varchar, il.kfunderdeptid)
            ) fd
            outer apply (
                select top 1 IndividualSK
                from [db-au-dtc]..pnpIndividual
                where IndividualID = convert(varchar, il.kindid)
                    and IsCurrent = 1
            ) i
            outer apply (
                select top 1 IndividualSK as PatientIndividualSK
                from [db-au-dtc].dbo.pnpIndividual
                where IndividualID = convert(varchar, il.kindidpatient)
                    and IsCurrent = 1
            ) pind
            outer apply (
                select top 1 [Service]
                from [db-au-dtc]..pnpServiceFile sf
                where sf.ServiceFileID = sa.ServiceFileID
            ) sf
			--mod 20190329 DM
			outer apply (
				select top 1 d.FunderDepartmentSK, D.FunderDepartmentID
				from penelopeDataMart_pen_CaseInvoicePerson_audtc t
				inner join [db-au-dtc].dbo.pnpFunderDepartment d on
					d.FunderDepartmentID = convert(varchar, t.DepartmentID)
				where 
					sa.CaseID = convert(varchar, t.CaseID)
			) cor

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpInvoiceLine as tgt
        using #src
            on #src.InvoiceLineID = tgt.InvoiceLineID
        when matched then
            update set
                tgt.InvoiceSK = #src.InvoiceSK,
                tgt.ServiceEventActivitySK = #src.ServiceEventActivitySK,
                tgt.PolicyCoverageSK = #src.PolicyCoverageSK,
                tgt.PolicyMemberSK = #src.PolicyMemberSK,
                tgt.FunderSK = #src.FunderSK,
                tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
				tgt.OrigFunderDepartmentSK = #src.FunderDepartmentSK, --mod 20190329
                tgt.IndividualSK = #src.IndividualSK,
                tgt.PatientIndividualSK = #src.PatientIndividualSK,
                tgt.InvoiceLineType = #src.InvoiceLineType,
                tgt.InvoiceLineTypeShort = #src.InvoiceLineTypeShort,
                tgt.ServiceEventActivityID = #src.ServiceEventActivityID,
                tgt.PolicyCoverageID = #src.PolicyCoverageID,
                tgt.PolicyMemberID = #src.PolicyMemberID,
                tgt.FunderID = #src.FunderID,
                tgt.FunderDepartmentID = #src.FunderDepartmentID,
				tgt.OrigFunderDepartmentID = #src.OrigFunderDepartmentID, --mod 20190329
                tgt.IndividualID = #src.IndividualID,
                tgt.Fee = #src.Fee,
                tgt.Total = #src.Total,
                tgt.Adjustment = #src.Adjustment,
                tgt.AdjustmentID = #src.AdjustmentID,
                tgt.AdjustmentName = #src.AdjustmentName,
                tgt.AdjustmentCategory = #src.AdjustmentCategory,
                tgt.InvoiceSScale = #src.InvoiceSScale,
                tgt.Amount = #src.Amount,
                tgt.Seq = #src.Seq,
                tgt.InvoiceID = #src.InvoiceID,
                tgt.Paid = #src.Paid,
                tgt.PartialPaid = #src.PartialPaid,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdatedBy = #src.UpdatedBy,
                tgt.PolicyAgreementID = #src.PolicyAgreementID,
                tgt.Quantity = #src.Quantity,
                tgt.DispAmount = #src.DispAmount,
                tgt.InvoicePosted = #src.InvoicePosted,
                tgt.PatientIndividualID = #src.PatientIndividualID,
                tgt.TaxAmount = #src.TaxAmount,
                tgt.TotalAmount = #src.TotalAmount,
                tgt.TaxAdjustment = #src.TaxAdjustment,
                tgt.FullyAppliedDate = #src.FullyAppliedDate,
                tgt.ReceiptIDRet = #src.ReceiptIDRet,
                tgt.InvoiceLineIDRet = #src.InvoiceLineIDRet,
                tgt.NonChargeable = #src.NonChargeable,
                tgt.[Service] = #src.[Service]
        when not matched by target then
            insert (
                InvoiceSK,
                ServiceEventActivitySK,
                PolicyCoverageSK,
                PolicyMemberSK,
                FunderSK,
                FunderDepartmentSK,
				OrigFunderDepartmentSK,  --mod 20190329
                IndividualSK,
                PatientIndividualSK,
                InvoiceLineID,
                InvoiceLineType,
                InvoiceLineTypeShort,
                ServiceEventActivityID,
                PolicyCoverageID,
                PolicyMemberID,
                FunderID,
                FunderDepartmentID,
				OrigFunderDepartmentID,  --mod 20190329
                IndividualID,
                Fee,
                Total,
                Adjustment,
                AdjustmentID,
                AdjustmentName,
                AdjustmentCategory,
                InvoiceSScale,
                Amount,
                Seq,
                InvoiceID,
                Paid,
                PartialPaid,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
                PolicyAgreementID,
                Quantity,
                DispAmount,
                InvoicePosted,
                PatientIndividualID,
                TaxAmount,
                TotalAmount,
                TaxAdjustment,
                FullyAppliedDate,
                ReceiptIDRet,
                InvoiceLineIDRet,
                NonChargeable,
                [Service]
            )
            values (
                #src.InvoiceSK,
                #src.ServiceEventActivitySK,
                #src.PolicyCoverageSK,
                #src.PolicyMemberSK,
                #src.FunderSK,
                #src.FunderDepartmentSK,
				#src.OrigFunderDepartmentSK,  --mod 20190329
                #src.IndividualSK,
                #src.PatientIndividualSK,
                #src.InvoiceLineID,
                #src.InvoiceLineType,
                #src.InvoiceLineTypeShort,
                #src.ServiceEventActivityID,
                #src.PolicyCoverageID,
                #src.PolicyMemberID,
                #src.FunderID,
                #src.FunderDepartmentID,
				#src.OrigFunderDepartmentID,  --mod 20190329
                #src.IndividualID,
                #src.Fee,
                #src.Total,
                #src.Adjustment,
                #src.AdjustmentID,
                #src.AdjustmentName,
                #src.AdjustmentCategory,
                #src.InvoiceSScale,
                #src.Amount,
                #src.Seq,
                #src.InvoiceID,
                #src.Paid,
                #src.PartialPaid,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreatedBy,
                #src.UpdatedBy,
                #src.PolicyAgreementID,
                #src.Quantity,
                #src.DispAmount,
                #src.InvoicePosted,
                #src.PatientIndividualID,
                #src.TaxAmount,
                #src.TotalAmount,
                #src.TaxAdjustment,
                #src.FullyAppliedDate,
                #src.ReceiptIDRet,
                #src.InvoiceLineIDRet,
                #src.NonChargeable,
                #src.[Service]
            )
        --20180812 - LL - change Deleted logic, reading the new id table
        --when not matched by source and tgt.InvoiceLineID not like 'CLI_%' AND tgt.DeletedDatetime IS NULL then update
        --    set tgt.DeletedDatetime = current_timestamp

        output $action into @mergeoutput;

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

        update il
        set
            DeletedDatetime = sea.DeletedDatetime
        --select *
        from
            [db-au-dtc].dbo.pnpInvoiceLine IL
            inner join [db-au-dtc].dbo.pnpServiceEventActivity sea on
                il.ServiceEventActivitySK = sea.ServiceEventActivitySK
        where
            IL.DeletedDatetime is null and
            sea.DeletedDatetime is not null

        --20180812 - LL - change Deleted logic, reading the new id table
        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            penelope_btinvline_audtc_id

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpInvoiceLine t
        where
            t.InvoiceLineID not like 'CLI_%' and
            t.InvoiceLineID not like 'DUMMY%' and
            t.DeletedDatetime is null

        --select @old, @new
        update t
        set
            DeletedDateTime = null
        from
            [db-au-dtc].dbo.pnpInvoiceLine t
        where
            t.InvoiceLineID not like 'CLI_%' and
            t.InvoiceLineID not like 'DUMMY%' and
            t.DeletedDatetime is not null and
            exists
            (
                select
                    null
                from
                    penelope_btinvline_audtc_id id
                where
                    id.kinvlineid = try_convert(bigint, t.InvoiceLineID)
            ) and
            exists
            (
                select
                    null
                from
                    [db-au-dtc].dbo.pnpServiceEventActivity sea
                where
                    sea.ServiceEventActivitySK = t.ServiceEventActivitySK and
                    sea.DeletedDatetime is null
            )

        --if @new > @old - 400
        begin

            update t
            set
                DeletedDateTime = current_timestamp 
            from
                [db-au-dtc].dbo.pnpInvoiceLine t
            where
                t.InvoiceLineID not like 'CLI_%' and
                t.InvoiceLineID not like 'DUMMY%' and
                t.DeletedDatetime is null and
                not exists
                (
                    select
                        null
                    from
                        penelope_btinvline_audtc_id id
                    where
                        id.kinvlineid = try_convert(bigint, t.InvoiceLineID)
                )

        end

        -- update "Invoiced" flag in pnpServiceEventActivity table
        update
            [db-au-dtc]..pnpServiceEventActivity
        set
            Invoiced = 1
        from
            [db-au-dtc]..pnpServiceEventActivity sea
        --    cross apply (
        --        select
        --            top 1 InvoiceID
        --        from
        --            [db-au-dtc]..pnpInvoiceLine
        --        where
        --            ServiceEventActivitySK = sea.ServiceEventActivitySK
        --    ) il
        --where
        --    il.InvoiceID is not null

        where
            sea.ServiceEventActivitySK in
            (
                select
                    ServiceEventActivitySK
                from
                    #src
            )


        -- update amounts in pnpInvoice
        update i
        set
            Amount = t.Amount,
            TaxAmount = t.TaxAmount,
            TotalAmount = t.TotalAmount
        from
            [db-au-dtc]..pnpInvoice i
            cross apply
            (
                select
                    sum(il.Amount) Amount,
                    sum(il.TaxAmount) TaxAmount,
                    sum(il.TotalAmount) TotalAmount
                from
                    [db-au-dtc]..pnpInvoiceLine il
                where
                    il.InvoiceSK = i.InvoiceSK and
                    il.DeletedDatetime is null
            ) t

            --join (
            --    select
            --        InvoiceID,
            --        sum(Amount) Amount,
            --        sum(TaxAmount) TaxAmount,
            --        sum(TotalAmount) TotalAmount
            --    from
            --        [db-au-dtc]..pnpInvoiceLine
            --    where
            --        InvoiceID in (
            --            select distinct convert(varchar, kinvoicenoid)
            --            from penelope_btinvline_audtc
            --        )
            --        and DeletedDatetime is null
            --    group by
            --        InvoiceID
            --) t
            --    on i.InvoiceID = t.InvoiceID

        where
            InvoiceSK in
            (
                select
                    InvoiceSK
                from
                    #src
            )

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
