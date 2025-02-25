USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ewsMalaysiaFolder]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_ewsMalaysiaFolder]
as
begin




/*
    20160229, DM,   create
*/

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
        @SubjectArea = 'EWS Assessments Dump',
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
    
    if object_id('[db-au-cmdwh].dbo.ews_folder_Malaysia') is null
    begin
    
        create table [db-au-cmdwh].dbo.ews_folder_Malaysia
        (
            [BIRowID] bigint not null identity(1,1),
            [MailBox] nvarchar(320) null,
            [FolderID] nvarchar(255) null,
            [FolderName] nvarchar(255) null,
            [FullPath] nvarchar(max) null,
            [CreateDateTime] datetime null,
            [UpdateDateTime] datetime null,
            [DeleteDateTime] datetime null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        )

        create clustered index idx_ews_folder_Malaysia_BIRowID on [db-au-cmdwh].dbo.ews_folder_Malaysia(BIRowID)
        create nonclustered index idx_ews_folder_Malaysia_FolderID on [db-au-cmdwh].dbo.ews_folder_Malaysia(FolderID) include (MailBox,FolderName,FullPath)

    end

    if object_id('tempdb..#ews_folder_Malaysia') is not null
        drop table #ews_folder_Malaysia

    ;with cte_foldertree as
    (
        select 
            mailbox,
            id,
            name,
            parentid,
            0 depth
        from 
            ews_folder_Malaysia
        where
            parentid <> ''
            
        union all
        
        select 
            t.mailbox,
            t.id,
            f.name,
            f.parentid,
            depth + 1
        from 
            cte_foldertree t
            inner join ews_folder_Malaysia f on
                f.id = t.parentid
				AND t.mailbox = f.mailbox
    )
    select 
        isnull(id, mailbox + name) FolderID,
        name FolderName,
        mailbox MailBox,
        isnull(
            (
                select
                    name + '\'
                from
                    cte_foldertree r
                where
                    r.id = t.id
					AND r.mailbox = t.mailbox
                order by depth desc
                for xml path('')
            ),
            name
        ) FullPath
    into #ews_folder_Malaysia
    from
        ews_folder_Malaysia t


    set @sourcecount = @@rowcount
        
    begin transaction

    begin try
    
        merge into [db-au-cmdwh].dbo.ews_folder_Malaysia with(tablock) t
        using #ews_folder_Malaysia s on 
            s.FolderID = t.FolderID	AND 
			s.MailBox = t.MailBox and
			s.FolderName = t.FolderName
            
        when 
            matched and
            binary_checksum(
                t.FolderName,
                t.FullPath
            ) <>
            binary_checksum(
                s.FolderName,
                s.FullPath
            )
        then
        
            update
            set
                FolderName = s.FolderName,
                FullPath = s.FullPath,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                MailBox,
                FolderID,
                FolderName,
                FullPath,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.MailBox,
                s.FolderID,
                s.FolderName,
                s.FullPath,
                getdate(),
                @batchid
            )

        when 
            not matched by source and
            DeleteDateTime is null
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
            @SourceInfo = 'ews_folder_Malaysia data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end


GO
