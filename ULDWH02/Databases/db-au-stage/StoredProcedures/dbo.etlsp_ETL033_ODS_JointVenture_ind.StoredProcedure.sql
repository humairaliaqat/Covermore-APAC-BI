USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_JointVenture_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_ODS_JointVenture_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load jv table
Change History:
                20160506 - LL - created
				20180423 - LT - created for SUN GL INDIA
    
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
        @SubjectArea = 'SUN GL INDIA',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    if @batchid = -1
        raiserror('prevent running without batch', 15, 1) with nowait

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh]..glJointVentures_ind') is null
    begin

        create table [db-au-cmdwh]..glJointVentures_ind
        (
            BIRowID bigint identity(1,1) not null,
            JVCode varchar(50) not null,
            JVDescription nvarchar(255),
            TypeOfJVCode varchar(50),
            TypeOfJVDescription nvarchar(200),
            DistributionTypeCode varchar(50),
            DistributionTypeDescription nvarchar(200),
            SuperGroupCode varchar(50),
            SuperGroupDescription nvarchar(200),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glJointVentures_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glJointVentures_ind (JVCode) include 
            (JVDescription,TypeOfJVCode,TypeOfJVDescription,DistributionTypeCode,DistributionTypeDescription,SuperGroupCode,SuperGroupDescription)

    end

    if object_id('tempdb..#glJointVentures_ind') is not null
        drop table #glJointVentures_ind

    select *
    into #glJointVentures_ind
    from
        [db-au-cmdwh]..glJointVentures_ind
    where
        1 = 0

    insert into #glJointVentures_ind
    (
        JVCode,
        JVDescription,
        TypeOfJVCode,
        TypeOfJVDescription,
        DistributionTypeCode,
        DistributionTypeDescription,
        SuperGroupCode,
        SuperGroupDescription
    )
    select 
        t.[JV Code],
        t.[JV Description],
        t.[Type of JV Code],
        t.[Type of JV Description],
        t.[Distribution Type Code],
        t.[Distribution Type Description],
        t.[Super Group Code],
        t.[Super Group Description]
    from
        [db-au-stage]..sungl_excel_jv_ind t
    where
        isnull(ltrim(rtrim(t.[JV Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glJointVentures_ind with(tablock) t
        using #glJointVentures_ind s on
            s.JVCode = t.JVCode

        when 
            matched and
            binary_checksum(t.JVDescription,t.TypeOfJVCode,t.TypeOfJVDescription,t.DistributionTypeCode,t.DistributionTypeDescription,t.SuperGroupCode,t.SuperGroupDescription,t.DeleteDateTime) <>
            binary_checksum(s.JVDescription,s.TypeOfJVCode,s.TypeOfJVDescription,s.DistributionTypeCode,s.DistributionTypeDescription,s.SuperGroupCode,s.SuperGroupDescription,s.DeleteDateTime) 
        then

            update
            set
                JVDescription = s.JVDescription,
                TypeOfJVCode = s.TypeOfJVCode,
                TypeOfJVDescription = s.TypeOfJVDescription,
                DistributionTypeCode = s.DistributionTypeCode,
                DistributionTypeDescription = s.DistributionTypeDescription,
                SuperGroupCode = s.SuperGroupCode,
                SuperGroupDescription = s.SuperGroupDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                JVCode,
                JVDescription,
                TypeOfJVCode,
                TypeOfJVDescription,
                DistributionTypeCode,
                DistributionTypeDescription,
                SuperGroupCode,
                SuperGroupDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.JVCode,
                s.JVDescription,
                s.TypeOfJVCode,
                s.TypeOfJVDescription,
                s.DistributionTypeCode,
                s.DistributionTypeDescription,
                s.SuperGroupCode,
                s.SuperGroupDescription,
                getdate(),
                @batchid
            )

        when
            not matched by source and
            t.DeleteDateTime is null
        then

            update
            set
                DeleteDateTime = getdate()

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
                        when MergeAction = 'delete' then 1
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
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Error'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
