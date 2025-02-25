USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5WorkCaseNote_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_e5WorkCaseNote_v4]
as
begin
/*
20130813, LS, Add staging index
20150708, LS, T16817, NZ e5 v3
20190726, LT, e5 v4 upgrade
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

    if object_id('[db-au-cmdwh].dbo.e5WorkCaseNote_v4') is null
    begin

        create table [db-au-cmdwh].dbo.e5WorkCaseNote_v4
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5) null,
            [Country] varchar(5) null,
            [Work_Id] varchar(50),
            [ID] varchar(50),
            [Original_Work_Id] [uniqueidentifier] not null,
            [Original_Id] [bigint] not null,
            [CaseNoteDate] [datetime] not null,
            [CaseNoteUserID] [nvarchar](100) not null,
            [CaseNoteUser] [nvarchar](455) null,
            [CaseNote] [nvarchar](max) null,
            [PropertyId] [nvarchar](32) not null,
            [CreateBatchID] int,
            [UpdateBatchID] int,
            [DeleteBatchID] int
        )

        create clustered index idx_e5WorkCaseNote_v4_BIRowID on [db-au-cmdwh].dbo.e5WorkCaseNote_v4(BIRowID)
        create nonclustered index idx_e5WorkCaseNote_v4_ID on [db-au-cmdwh].dbo.e5WorkCaseNote_v4(ID)
        create nonclustered index idx_e5WorkCaseNote_v4_Work_ID on [db-au-cmdwh].dbo.e5WorkCaseNote_v4(Work_ID,Country) include(CaseNoteDate,CaseNoteUser,CaseNote,PropertyID)
        create nonclustered index idx_e5WorkCaseNote_v4_CaseNoteDate on [db-au-cmdwh].dbo.e5WorkCaseNote_v4(CaseNoteDate) include(Work_ID,ID)

    end

    if object_id('tempdb..#e5WorkCaseNote_v4') is not null
        drop table #e5WorkCaseNote_v4

    select
        Domain,
        Country,
        Country + Domain + convert(varchar(40), Work_ID) Work_ID,
        Country + Domain + convert(varchar(40), Id) Id,
        Work_ID Original_Work_ID,
        ID Original_ID,
        CaseNoteDate,
        CaseNoteUser collate database_default CaseNoteUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(CaseNoteUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) CaseNoteUser,
        CaseNote collate database_default CaseNote,
        PropertyID collate database_default PropertyID
    into #e5WorkCaseNote_v4
    from
        e5_WorkCaseNote_v4 wcn
        cross apply
        (
            select top 1 
                w.Category1_Id
            from
                e5_Work_v4 w
            where
                w.Id = wcn.Work_Id
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


    set @sourcecount = @@rowcount


    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5WorkCaseNote_v4] with(tablock) t
        using #e5WorkCaseNote_v4 s on
            s.ID = t.ID

        when matched then
            update
            set
                Domain = s.Domain,
                Country = s.Country,
                Work_ID = s.Work_ID,
                Original_Work_ID = s.Original_Work_ID,
                Original_ID = s.Original_ID,
                CaseNoteDate = s.CaseNoteDate,
                CaseNoteUserID = s.CaseNoteUserID,
                CaseNoteUser = s.CaseNoteUser,
                CaseNote = s.CaseNote,
                PropertyId = s.PropertyId,
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
                CaseNoteDate,
                CaseNoteUserID,
                CaseNoteUser,
                CaseNote,
                PropertyId,
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
                s.CaseNoteDate,
                s.CaseNoteUserID,
                s.CaseNoteUser,
                s.CaseNote,
                s.PropertyId,
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
            @SourceInfo = 'e5WorkCaseNote_v4 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
