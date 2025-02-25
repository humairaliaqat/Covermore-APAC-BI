USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5WorkActivity_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_e5WorkActivity_v4]
as
begin
/*
20150708, LS, T16817, NZ e5 v3
20151118, LS, Dane found a bug with assessment outcome not reflected in WA (OSAssessmentOutcome)
*/

    set nocount on

    exec etlsp_StagingIndex_e5_v4

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
			@SubjectArea = 'e5 ODS v4',
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

    if object_id('[db-au-cmdwh].dbo.e5WorkActivity_v4') is null
    begin

        create table [db-au-cmdwh].dbo.e5WorkActivity_v4
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5) null,
            [Country] varchar(5) null,
            [Work_ID] varchar(50),
            [ID] varchar(50) null,
            [Original_ID] uniqueidentifier not null,
            [Original_Work_ID] uniqueidentifier not null,
            [WorkActivity_ID] bigint null,
            [CategoryActivityName] nvarchar(100) null,
            [StatusName] nvarchar(100) null,
            [SortOrder] int null,
            [CreationDate] datetime null,
            [CreationUserID] nvarchar(100) null,
            [CreationUser] nvarchar(455) null,
            [CompletionDate] datetime null,
            [CompletionUserID] nvarchar(100) null,
            [CompletionUser] nvarchar(455) null,
            [AssignedDate] datetime null,
            [AssignedUserID] nvarchar(100) null,
            [AssignedUser] nvarchar(455) null,
            [DueDate] datetime null,
            [AssessmentOutcome] int null,
            [AssessmentOutcomeDescription] nvarchar(400) null,
            [CreateBatchID] int,
            [UpdateBatchID] int,
            [DeleteBatchID] int
        )

        create clustered index idx_e5WorkActivity_v4_BIRowID on [db-au-cmdwh].dbo.e5WorkActivity_v4(BIRowID)
        create nonclustered index idx_e5WorkActivity_v4_ID on [db-au-cmdwh].dbo.e5WorkActivity_v4(ID)
        create nonclustered index idx_e5WorkActivity_v4_Work_ID on [db-au-cmdwh].dbo.e5WorkActivity_v4(Work_ID) include(ID,Country,CategoryActivityName,StatusName,CompletionDate,CompletionUser,AssessmentOutcome,AssessmentOutcomeDescription)
        create nonclustered index idx_e5Work_v4Act_CatActName on [db-au-cmdwh].dbo.e5WorkActivity_v4(CategoryActivityName,CompletionDate) include (ID,CompletionUser,AssessmentOutcome,AssessmentOutcomeDescription,Work_ID)
        create nonclustered index idx_e5Work_v4Act_CompletionDate on [db-au-cmdwh].dbo.e5WorkActivity_v4(CompletionDate) include (Work_ID,ID,AssessmentOutcome,AssessmentOutcomeDescription)
        create nonclustered index idx_e5Work_v4Act_CreationDate on [db-au-cmdwh].dbo.e5WorkActivity_v4(CreationDate) include (Work_ID,ID,AssessmentOutcome,AssessmentOutcomeDescription)


    end

    if object_id('tempdb..#e5WorkActivity_v4') is not null
        drop table #e5WorkActivity_v4

    select
        Domain,
        Country,
        Country + Domain + convert(varchar(40), wa.Work_ID) Work_ID,
        Country + Domain + convert(varchar(40), wa.ID) ID,
        Work_ID Original_Work_ID,
        ID Original_ID,
        wa.[_Id] as WorkActivity_ID,
        (
            select top 1
                [name] collate database_default
            from
                e5_CategoryActivity_v4
            where
                Id = wa.[CategoryActivity_ID]
        ) CategoryActivityName,
        (
            select top 1
                [name] collate database_default
            from
                e5_status_v4
            where
                Id = wa.[Status_ID]
        ) StatusName,
        wa.[SortOrder],
        wa.[CreationDate],
        wa.CreationUser collate database_default CreationUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(wa.CreationUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) CreationUser,
        wa.[CompletionDate],
        wa.CompletionUser collate database_default CompletionUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(wa.CompletionUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) CompletionUser,
        wa.[AssignedDate],
        wa.AssignedUser collate database_default AssignedUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(wa.AssignedUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) AssignedUser,
        wa.[SLAExpiryDate] DueDate,
        wacp.AssessmentOutcome,
        wao.AssessmentOutcomeDescription
    into #e5WorkActivity_v4
    from
        e5_WorkActivity_v4 wa
        cross apply
        (
            select top 1 
                w.Category1_Id
            from
                e5_Work_v4 w
            where
                w.Id = wa.Work_Id
        ) w
        cross apply
        (
            select top 1
                [Code] collate database_default [Code],
                [Name] collate database_default [Name]
            from
                e5_Category1_v4
            where
                Id = w.Category1_Id
        ) bn
        cross apply
        (
            select
                'V3' Domain,
                bn.Code Country
        ) d
        outer apply
        (
            select top 1
                convert(int, max(PropertyValue)) AssessmentOutcome
            from
                e5_WorkActivityProperty_v4 wacp
                inner join e5_Property_v4 p on
                    p.Id = wacp.Property_Id
            where
                wacp.Work_Id = wa.Work_Id and
                wacp.WorkActivity_Id = wa.Id and
                p.PropertyLabel = 'Assessment Outcome'
                --wacp.Property_Id in ('GeneralClaimAssessOutcome', 'AssessmentOutcome')
        ) wacp
        outer apply
        (
            select top 1
                i.Name  collate database_default AssessmentOutcomeDescription
            from
                e5_ListItem_v4 i
            where
                i.Id = wacp.AssessmentOutcome
        ) wao


    set @sourcecount = @@rowcount


    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5WorkActivity_v4] with(tablock) t
        using #e5WorkActivity_v4 s on
            s.ID = t.ID

        when matched then

            update
            set
                Domain = s.Domain,
                Country = s.Country,
                Work_ID = s.Work_ID,
                Original_Work_ID = s.Original_Work_ID,
                Original_ID = s.Original_ID,
                WorkActivity_ID = s.WorkActivity_ID,
                CategoryActivityName = s.CategoryActivityName,
                StatusName = s.StatusName,
                SortOrder = s.SortOrder,
                CreationDate = s.CreationDate,
                CreationUserID = s.CreationUserID,
                CreationUser = s.CreationUser,
                CompletionDate = s.CompletionDate,
                CompletionUserID = s.CompletionUserID,
                CompletionUser = s.CompletionUser,
                AssignedDate = s.AssignedDate,
                AssignedUserID = s.AssignedUserID,
                AssignedUser = s.AssignedUser,
                DueDate = s.DueDate,
                AssessmentOutcome = s.AssessmentOutcome,
                AssessmentOutcomeDescription = s.AssessmentOutcomeDescription,
                UpdateBatchID = @batchid,
                DeleteBatchID = null

        when not matched by target then
            insert
            (
                Domain,
                Country,
                Work_ID,
                ID,
                Original_Work_ID,
                Original_ID,
                WorkActivity_ID,
                CategoryActivityName,
                StatusName,
                SortOrder,
                CreationDate,
                CreationUserID,
                CreationUser,
                CompletionDate,
                CompletionUserID,
                CompletionUser,
                AssignedDate,
                AssignedUserID,
                AssignedUser,
                DueDate,
                AssessmentOutcome,
                AssessmentOutcomeDescription,
                CreateBatchID
            )
            values
            (
                s.Domain,
                s.Country,
                s.Work_ID,
                s.ID,
                s.Original_Work_ID,
                s.Original_ID,
                s.WorkActivity_ID,
                s.CategoryActivityName,
                s.StatusName,
                s.SortOrder,
                s.CreationDate,
                s.CreationUserID,
                s.CreationUser,
                s.CompletionDate,
                s.CompletionUserID,
                s.CompletionUser,
                s.AssignedDate,
                s.AssignedUserID,
                s.AssignedUser,
                s.DueDate,
                s.AssessmentOutcome,
                s.AssessmentOutcomeDescription,
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
            @SourceInfo = 'e5WorkActivity_v4 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
