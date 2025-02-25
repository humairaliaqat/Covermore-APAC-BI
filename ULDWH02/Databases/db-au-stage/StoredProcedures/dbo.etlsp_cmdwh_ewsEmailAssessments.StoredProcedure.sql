USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ewsEmailAssessments]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_ewsEmailAssessments]
    @LoadHistory bit = 0
    
as
begin
/*
    20150929, DM,   create
*/

    set nocount on
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int,
        @deletetime datetime
        
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

    if object_id('[db-au-cmdwh].dbo.ewsEmailAssessments') is null
    begin

        create table [db-au-cmdwh].dbo.ewsEmailAssessments
        (
            [BIRowID] bigint not null identity(1,1),
            [MailBox] nvarchar(320) null,
            [FolderID] nvarchar(255) null,
            [FullPath] nvarchar(max) null,
            [EmailID] nvarchar(450) null,
            [Subject] nvarchar(1024) null,
            [ConversationID] nvarchar(255) null,
            [ConversationTopic] nvarchar(1024) null,
            [InReplyTo] nvarchar(1024) null,
            [Category] nvarchar(1024) null,
            [CreateDateTime] datetime null,
            [ReceiveDateTime] datetime null,
            [SentDateTime] datetime null,
            [ModifyDateTime] datetime null,
            [SenderAddress] nvarchar(320) null,
            [ReplyToAddress] nvarchar(320) null,
            [ToAddress] nvarchar(max) null,
            [CCAddress] nvarchar(max) null,
            [ReceivedBy] nvarchar(320) null,
            [ModifyBy] nvarchar(320) null,
			[RepliedDateTime] datetime null,
            [Importance] nvarchar(255) null,
            [EmailSize] bigint null,
            [HasAttachment] bit null,
            [IsResend] bit null,
            [IsNew] bit null,
            [IsRead] bit null,
            [InternetHeader] nvarchar(max) null,
            [DeleteDateTime] datetime null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        )

        create clustered index idx_ewsEmailAssessments_BIRowID on [db-au-cmdwh].dbo.ewsEmailAssessments(BIRowID)
        create nonclustered index idx_ewsEmailAssessments_FolderID on [db-au-cmdwh].dbo.ewsEmailAssessments(FolderID) include (MailBox,EmailID,FullPath,[Subject],CreateDateTime,SentDateTime)
        create nonclustered index idx_ewsEmailAssessments_MailBox on [db-au-cmdwh].dbo.ewsEmailAssessments(MailBox) include (FolderID,EmailID,FullPath,[Subject],CreateDateTime,SentDateTime)
        create nonclustered index idx_ewsEmailAssessments_EmailID on [db-au-cmdwh].dbo.ewsEmailAssessments(EmailID) include (MailBox,FolderID,FullPath,[Subject],CreateDateTime,SentDateTime)
        create nonclustered index idx_ewsEmailAssessments_receivedate on [db-au-cmdwh].dbo.ewsEmailAssessments (ReceiveDateTime,MailBox) include (EmailID,DeleteDateTime,FullPath)
        create nonclustered index idx_ewsEmailAssessments_sentdate on [db-au-cmdwh].dbo.ewsEmailAssessments (SentDateTime,MailBox) include (EmailID,DeleteDateTime,FullPath)

    end

    if object_id('[db-au-cmdwh].dbo.ewsEmailAssessmentsHistory') is null
    begin
    
        create table [db-au-cmdwh].dbo.ewsEmailAssessmentsHistory
        (
            [BIRowID] bigint not null identity(1,1),
            [EmailID] nvarchar(450) null,
            [FullPath] nvarchar(max) null,
            [Category] nvarchar(1024) null,
            [ModifyDateTime] datetime null,
            [ModifyBy] nvarchar(320) null,
            [Importance] nvarchar(255) null,
            [EmailSize] bigint null,
            [HasAttachment] bit null,
            [IsResend] bit null,
            [IsNew] bit null,
            [IsRead] bit null,
            [CreateDateTime] datetime null,
            [CreateBatchID] int null
        )

        create clustered index idx_ewsEmailAssessmentsHistory_BIRowID on [db-au-cmdwh].dbo.ewsEmailAssessmentsHistory(BIRowID)
        create nonclustered index idx_ewsEmailAssessmentsHistory_EmailID on [db-au-cmdwh].dbo.ewsEmailAssessmentsHistory(EmailID) include (FullPath,Category,ModifyDateTime,ModifyBy,Importance,EmailSize,HasAttachment,IsResend,IsNew,IsRead,CreateDateTime)

    end
    
    if object_id('tempdb..#ewsAll') is not null
        drop table #ewsAll

    select 
        MailBox,
        parentfolderid FolderID,
        FullPath,
        convert(nvarchar(450), ConversationID + convert(varchar(max), hashbytes('md5', convert(varchar, datetimecreated, 120) + convert(varchar, datetimereceived, 120) + convert(varchar, datetimesent, 120)), 2)) EmailID,
        emailsubject [Subject],
        ConversationID,
        ConversationTopic,
        InReplyTo,
        catgories Category,
        datetimecreated CreateDateTime,
        datetimereceived ReceiveDateTime,
        datetimesent SentDateTime,
        lastmodifiedtime ModifyDateTime,
        sender SenderAddress,
        replyto ReplyToAddress,
        displayto ToAddress,
        displaycc CCAddress,
        ReceivedBy,
        lastmodifiedname ModifyBy,
		LastReplied RepliedDateTime,
        Importance,
        size EmailSize,
        HasAttachment,
        IsResend,
        IsNew,
        IsRead,
        internetheaders InternetHeader
    into #ewsAll
    from
        ews_email_assessments e
        outer apply
        (
            select top 1
                FullPath
            from
                [db-au-cmdwh]..ews_folder_assessments f
            where
                f.FolderID = e.parentfolderid
        ) fp
        outer apply
        (
            select 
                charindex('Message-ID', internetheaders) StartID
        ) hs
        outer apply
        (
            select
                convert(varchar, charindex('>', internetheaders, StartID)) + ',' +
                convert(varchar, charindex(' ', internetheaders, StartID)) + ',' +
                convert(varchar, charindex(';', internetheaders, StartID)) + ',' +
                convert(varchar, charindex(char(10), internetheaders, StartID)) Terminators
        ) hec
        outer apply
        (
            select
                case 
                    when min(convert(int, t.Item)) <= StartID then StartID
                    else min(convert(int, t.Item))
                end EndID
            from
                dbo.fn_DelimitedSplit8K(Terminators, ',') t
            where
                t.Item > 0
        ) he
        
    create nonclustered index idx on #ewsAll (EmailID, ModifyDateTime)
    
    if object_id('tempdb..#ewsID') is not null
        drop table #ewsID
        
    select distinct
        EmailID
    into #ewsID
    from
        #ewsAll
    
    if object_id('tempdb..#ewsEmailAssessments') is not null
        drop table #ewsEmailAssessments
        
    select 
        e.MailBox,
        e.FolderID,
        e.FullPath,
        e.EmailID,
        e.[Subject],
        e.ConversationID,
        e.ConversationTopic,
        e.InReplyTo,
        e.Category,
        e.CreateDateTime,
        e.ReceiveDateTime,
        e.SentDateTime,
        e.ModifyDateTime,
        e.SenderAddress,
        e.ReplyToAddress,
        e.ToAddress,
        e.CCAddress,
        e.ReceivedBy,
        e.ModifyBy,
		e.RepliedDateTime,
        e.Importance,
        e.EmailSize,
        e.HasAttachment,
        e.IsResend,
        e.IsNew,
        e.IsRead,
        e.InternetHeader
    into #ewsEmailAssessments
    from
        #ewsID id
        cross apply
        (
            select top 1 *
            from
                #ewsAll a
            where
                a.EmailID = id.EmailID
            order by
                ModifyDateTime desc
        ) e
   
    set @sourcecount = @@rowcount
        
    begin transaction

    begin try
    
        insert into [db-au-cmdwh]..ewsEmailAssessmentsHistory
        (
            EmailID,
            FullPath,
            Category,
            ModifyDateTime,
            ModifyBy,
            Importance,
            EmailSize,
            HasAttachment,
            IsResend,
            IsNew,
            IsRead,
            CreateDateTime,
            CreateBatchID
        )
        select 
            n.EmailID,
            n.FullPath,
            n.Category,
            n.ModifyDateTime,
            n.ModifyBy,
            n.Importance,
            n.EmailSize,
            n.HasAttachment,
            n.IsResend,
            n.IsNew,
            n.IsRead,
            getdate(), --n.ModifyDateTime
            @batchid
        from
            [db-au-cmdwh].dbo.ewsEmailAssessments e
            inner join #ewsEmailAssessments n on
                n.EmailID = e.EmailID and
                binary_checksum
                (
                    e.FullPath,
                    e.Category,
                    e.ModifyDateTime,
                    e.ModifyBy,
                    e.Importance,
                    e.EmailSize,
                    e.HasAttachment,
                    e.IsResend,
                    e.IsNew,
                    e.IsRead
                ) <>
                binary_checksum
                (
                    n.FullPath,
                    n.Category,
                    n.ModifyDateTime,
                    n.ModifyBy,
                    n.Importance,
                    n.EmailSize,
                    n.HasAttachment,
                    n.IsResend,
                    n.IsNew,
                    n.IsRead
                )                 

        if @LoadHistory = 0
        begin
 
            merge into [db-au-cmdwh].dbo.ewsEmailAssessments with(tablock) t
            using #ewsEmailAssessments s on 
                s.EmailID = t.EmailID
                
            when matched then
                update
                set
                    MailBox = s.MailBox,
                    FolderID = s.FolderID,
                    FullPath = s.FullPath,
                    [Subject] = s.[Subject],
                    ConversationID = s.ConversationID,
                    ConversationTopic = s.ConversationTopic,
                    InReplyTo = s.InReplyTo,
                    Category = s.Category,
                    CreateDateTime = s.CreateDateTime,
                    ReceiveDateTime = s.ReceiveDateTime,
                    SentDateTime = s.SentDateTime,
                    ModifyDateTime = s.ModifyDateTime,
                    SenderAddress = s.SenderAddress,
                    ReplyToAddress = s.ReplyToAddress,
                    ToAddress = s.ToAddress,
                    CCAddress = s.CCAddress,
                    ReceivedBy = s.ReceivedBy,
                    ModifyBy = s.ModifyBy,
					RepliedDateTime = s.RepliedDateTime,
                    Importance = s.Importance,
                    EmailSize = s.EmailSize,
                    HasAttachment = s.HasAttachment,
                    IsResend = s.IsResend,
                    IsNew = s.IsNew,
                    IsRead = s.IsRead,
                    InternetHeader = s.InternetHeader,
                    UpdateBatchID = @batchid
                    
            when not matched by target then
                insert 
                (
                    EmailID,
                    MailBox,
                    FolderID,
                    FullPath,
                    [Subject],
                    ConversationID,
                    ConversationTopic,
                    InReplyTo,
                    Category,
                    CreateDateTime,
                    ReceiveDateTime,
                    SentDateTime,
                    ModifyDateTime,
                    SenderAddress,
                    ReplyToAddress,
                    ToAddress,
                    CCAddress,
                    ReceivedBy,
                    ModifyBy,
					RepliedDateTime,
                    Importance,
                    EmailSize,
                    HasAttachment,
                    IsResend,
                    IsNew,
                    IsRead,
                    InternetHeader,
                    CreateBatchID
                )
                values
                (
                    s.EmailID,
                    s.MailBox,
                    s.FolderID,
                    s.FullPath,
                    s.[Subject],
                    s.ConversationID,
                    s.ConversationTopic,
                    s.InReplyTo,
                    s.Category,
                    s.CreateDateTime,
                    s.ReceiveDateTime,
                    s.SentDateTime,
                    s.ModifyDateTime,
                    s.SenderAddress,
                    s.ReplyToAddress,
                    s.ToAddress,
                    s.CCAddress,
                    s.ReceivedBy,
                    s.ModifyBy,
					s.RepliedDateTime,
                    s.Importance,
                    s.EmailSize,
                    s.HasAttachment,
                    s.IsResend,
                    s.IsNew,
                    s.IsRead,
                    s.InternetHeader,
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
                
        end
        
        else
        begin
        
            merge into [db-au-cmdwh].dbo.ewsEmailAssessments with(tablock) t
            using #ewsEmailAssessments s on 
                s.EmailID = t.EmailID
                
            when matched then
                update
                set
                    MailBox = s.MailBox,
                    FolderID = s.FolderID,
                    FullPath = s.FullPath,
                    [Subject] = s.[Subject],
                    ConversationID = s.ConversationID,
                    ConversationTopic = s.ConversationTopic,
                    InReplyTo = s.InReplyTo,
                    Category = s.Category,
                    CreateDateTime = s.CreateDateTime,
                    ReceiveDateTime = s.ReceiveDateTime,
                    SentDateTime = s.SentDateTime,
                    ModifyDateTime = s.ModifyDateTime,
                    SenderAddress = s.SenderAddress,
                    ReplyToAddress = s.ReplyToAddress,
                    ToAddress = s.ToAddress,
                    CCAddress = s.CCAddress,
                    ReceivedBy = s.ReceivedBy,
                    ModifyBy = s.ModifyBy,
					RepliedDateTime = s.RepliedDateTime,
                    Importance = s.Importance,
                    EmailSize = s.EmailSize,
                    HasAttachment = s.HasAttachment,
                    IsResend = s.IsResend,
                    IsNew = s.IsNew,
                    IsRead = s.IsRead,
                    UpdateBatchID = @batchid
                    
            when not matched by target then
                insert 
                (
                    EmailID,
                    MailBox,
                    FolderID,
                    FullPath,
                    [Subject],
                    ConversationID,
                    ConversationTopic,
                    InReplyTo,
                    Category,
                    CreateDateTime,
                    ReceiveDateTime,
                    SentDateTime,
                    ModifyDateTime,
                    SenderAddress,
                    ReplyToAddress,
                    ToAddress,
                    CCAddress,
                    ReceivedBy,
                    ModifyBy,
					RepliedDateTime,
                    Importance,
                    EmailSize,
                    HasAttachment,
                    IsResend,
                    IsNew,
                    IsRead,
                    InternetHeader,
                    CreateBatchID
                )
                values
                (
                    s.EmailID,
                    s.MailBox,
                    s.FolderID,
                    s.FullPath,
                    s.[Subject],
                    s.ConversationID,
                    s.ConversationTopic,
                    s.InReplyTo,
                    s.Category,
                    s.CreateDateTime,
                    s.ReceiveDateTime,
                    s.SentDateTime,
                    s.ModifyDateTime,
                    s.SenderAddress,
                    s.ReplyToAddress,
                    s.ToAddress,
                    s.CCAddress,
                    s.ReceivedBy,
                    s.ModifyBy,
					s.RepliedDateTime,
                    s.Importance,
                    s.EmailSize,
                    s.HasAttachment,
                    s.IsResend,
                    s.IsNew,
                    s.IsRead,
                    s.InternetHeader,
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
                    
        end
        

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
            @SourceInfo = 'ewsEmailAssessments data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
