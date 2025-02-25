USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Telephony_dimCSQ]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_Telephony_dimCSQ]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20141217
Prerequisite:   Verint
Description:    
Change History:
                20141217 - LS - created

*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Telephony STAR',
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

    if object_id('[db-au-star].dbo.dimCSQ') is null
    begin

        create table [db-au-star].dbo.dimCSQ
        (
            CSQSK int not null identity(1,1),
            CSQID nvarchar(50) null,
            CSQName nvarchar(50),
            Company nvarchar(50),
            SLAPercentage int,
            SLA int,
            SelectionCriteria nvarchar(50),
            isActive bit,
            CreateBatchID int,
            UpdateBatchID int
        )
        
        create clustered index idx_dimCSQ_CSQSK on [db-au-star].dbo.dimCSQ(CSQSK)
        create nonclustered index idx_dimCSQ_CSQID on [db-au-star].dbo.dimCSQ(CSQID)
        
        set identity_insert [db-au-star].dbo.dimCSQ on

        insert [db-au-star].[dbo].dimCSQ
        (
            CSQSK,
            CSQID,
            CSQName,
            Company,
            SLAPercentage,
            SLA,
            SelectionCriteria,
            isActive,
            CreateBatchID,
            UpdateBatchID
        )
        values
        (
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            0,
            0,
            'UNKNOWN',
            0,
            @batchid,
            @batchid
        )

        set identity_insert [db-au-star].dbo.dimCSQ off
        
    end
    
    if object_id('tempdb..#dimCSQ') is not null
        drop table #dimCSQ

    select 
        CSQKey CSQID,
        CSQName,
        case
            when charindex('CC_', CSQName) > 0 then 'Medical Assistance'
            when charindex('NZ_', CSQName) > 0 then 'Air New Zealand'
            when charindex('_CM_', CSQName) > 0 then 'CoverMore'
            when charindex('_AP_', CSQName) > 0 then 'Australia Post'
            when charindex('_MB_', CSQName) > 0 then 'Medibank'
            when charindex('_YG_', CSQName) > 0 then 'YouGo'
            when charindex('_ZU_', CSQName) > 0 then 'Zurich'
            when charindex('_TIP_', CSQName) > 0 then 'TIP'
            when charindex('_AAA_', CSQName) > 0 then 'AAA'
            when charindex('_IAL_', CSQName) > 0 then 'IAL'
            else 'Other'
        end Company,
        SLAPercentage,
        SLA,
        SelectionCriteria,
        isActive
    into #dimCSQ
    from
        [db-au-cmdwh]..cisCSQ
    
    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-star].dbo.dimCSQ with(tablock) t
        using #dimCSQ s on
            s.CSQID = t.CSQID

        when
            matched and
            binary_checksum(
                t.CSQName,
                t.Company,
                t.SLAPercentage,
                t.SLA,
                t.SelectionCriteria,
                t.isActive
            ) <>
            binary_checksum(
                s.CSQName,
                s.Company,
                s.SLAPercentage,
                s.SLA,
                s.SelectionCriteria,
                s.isActive
            )
        then

            update
            set
                CSQName = s.CSQName,
                Company = s.Company,
                SLAPercentage = s.SLAPercentage,
                SLA = s.SLA,
                SelectionCriteria = s.SelectionCriteria,
                isActive = s.isActive,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                CSQID,
                CSQName,
                Company,
                SLAPercentage,
                SLA,
                SelectionCriteria,
                isActive,
                CreateBatchID
            )
            values
            (
                s.CSQID,
                s.CSQName,
                s.Company,
                s.SLAPercentage,
                s.SLA,
                s.SelectionCriteria,
                s.isActive,
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
            @SourceInfo = 'Failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
