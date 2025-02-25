USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5WorkAttachment]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_e5WorkAttachment]
as
begin
/*
20190409, LL, create
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

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'e5 ODS',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
        set @start = dateadd(day, -1, getdate())
        set @end = dateadd(day, -1, getdate())
	
	end catch

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.e5WorkAttachment') is null
    begin

        create table [db-au-cmdwh].dbo.e5WorkAttachment
        (
            BIRowID bigint not null identity(1,1),
            Work_ID varchar(50),
            WorkAttachmentID int,
            AttachmentID varchar(36),
            AttachmentType nvarchar(100),
            AttachmentName nvarchar(128),
            AttachmentExt nvarchar(128),
            AttachmentURL nvarchar(512),
            AttachmentSize int,
            DateCreated datetime,
            DateModified datetime
        )

        create unique clustered index cidx_e5WorkAttachment on [db-au-cmdwh].dbo.e5WorkAttachment (BIRowID)
        create nonclustered index idx_WorkID_e5WorkAttachment on [db-au-cmdwh].dbo.e5WorkAttachment (Work_ID)
        create nonclustered index idx_WorkAttachmentID_e5WorkAttachment on [db-au-cmdwh].dbo.e5WorkAttachment (WorkAttachmentID)

    end

    declare 
        @run uniqueidentifier = newid(),
        @sql varchar(max)

    set @sql =
    '
    if object_id(''[WardyIT].dbo.works'') is null
    begin

        create table [WardyIT].dbo.works
        (
            BIRowID bigint not null identity(1,1),
            Work_ID varchar(50),
            Original_Work_ID uniqueidentifier,
            Run_ID uniqueidentifier,
            Run_Date date
        )

        create unique clustered index cidx on [WardyIT].dbo.works (BIRowID)
        create nonclustered index idx1 on [WardyIT].dbo.works (Run_ID)
        create nonclustered index idx2 on [WardyIT].dbo.works (Run_Date)

    end
    '

    execute (@sql) at [ULSQLGOLD01\E5]

    set @sql =
    '
    if object_id(''[WardyIT].dbo.attachments'') is null
    begin

        create table [WardyIT].dbo.attachments
        (
            Run_ID uniqueidentifier,
            Work_ID varchar(50),
            WorkAttachmentID int,
            AttachmentID varchar(36),
            AttachmentType nvarchar(100),
            AttachmentName nvarchar(128),
            AttachmentExt nvarchar(128),
            AttachmentURL nvarchar(512),
            AttachmentSize int,
            DateCreated datetime,
            DateModified datetime
        )

        create nonclustered index idx1 on [WardyIT].dbo.attachments (Run_ID)

    end
    '

    execute (@sql) at [ULSQLGOLD01\E5]

    execute 
    (
    '
    delete [WardyIT].dbo.works 
    where 
        Run_Date < dateadd(day, -1, getdate())
    '
    ) at [ULSQLGOLD01\E5]

    execute 
    (
    '
    delete a
    from
        [WardyIT].dbo.attachments a
    where 
        not exists
        (
            select
                null
            from
                [WardyIT].dbo.works w
            where
                w.Run_ID = a.Run_ID
        )
    '
    ) at [ULSQLGOLD01\E5]

    insert into [ULSQLGOLD01\E5].WardyIT.dbo.works with(tablock)
    (
        Run_ID,
        Run_Date,
        Work_ID,
        Original_Work_ID
    )
    select
        @run,
        getdate(),
        Work_ID,
        Original_Work_ID
    from
        [db-au-cmdwh]..e5Work w
    where
        Original_Work_ID in
        (
            select
                Id
            from
                e5_Work_v3
        )
        
    set @sql =
    '
    insert into [WardyIT].dbo.attachments
    (
        Run_ID,
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    )
    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
        --,
        --adocs.Content
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2019].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2019].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
        --inner join [WSS_Content_e5DocAuFy2019].dbo.DocStreams ds with(nolock) on
        --    ds.SiteId = aud.tp_SiteId and
        --    ds.DocId = aud.tp_DocId
    where
        wa.Library_Location = ''http://e5.covermore.com/sites/e5DocumentsAuFy2019'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        '

    execute (@sql) at [ULSQLGOLD01\E5]

    set @sql =
    '
    insert into [WardyIT].dbo.attachments
    (
        Run_ID,
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    )
    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocNzFy2019].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocNzFy2019].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://e5.covermore.com/sites/e5DocumentsNzFy2019'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        '

    execute (@sql) at [ULSQLGOLD01\E5]

    set @sql =
    '
    insert into [WardyIT].dbo.attachments
    (
        Run_ID,
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    )
    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2016].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2016].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location in
        (
            ''http://e5.covermore.com/sites/e5DocumentsAuFy2016'',
            ''http://ule501/sites/e5DocumentsAuFy2016''
        ) and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        '

    execute (@sql) at [ULSQLGOLD01\E5]

    set @sql =
    '
    insert into [WardyIT].dbo.attachments
    (
        Run_ID,
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    )
    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocNzFy2016].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocNzFy2016].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://e5.covermore.com/sites/e5DocumentsNzFy2016'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        '

    execute (@sql) at [ULSQLGOLD01\E5]

    set @sql =
    '
    insert into [WardyIT].dbo.attachments
    (
        Run_ID,
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    )
    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2015].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2015].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2015'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        
    union all

    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2014].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2014].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2014'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        
    union all

    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2013].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2013].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2013'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
        
    union all

    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2012].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2012].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2012'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''

    union all

    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2011].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2011].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2011'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''

    union all

    select 
        w.Run_ID,
        w.Work_Id,
        wa.Id,
        wa.Attachment_Id,
        at.[Name] as AttachmentType,
        adocs.LeafName AttachmentName,
        adocs.Extension,
        ''http://e5.covermore.com/'' + adocs.DirName + ''/'' + adocs.LeafName URL,
        adocs.Size,
        adocs.TimeCreated,
        adocs.TimeLastModified
    from
        [WardyIT].dbo.works w
        inner join [e5_Content_PRD].dbo.WorkAttachment wa with(nolock) on
            wa.Work_ID = w.Original_Work_ID
        left join [e5_Content_PRD].[dbo].[AttachmentType] at on wa.AttachmentType_id = at.id
        inner join [WSS_Content_e5DocAuFy2010].dbo.AllUserData aud with(nolock) on
            aud.tp_ID = wa.Attachment_Id
        inner join [WSS_Content_e5DocAuFy2010].dbo.AllDocs adocs with(nolock) on
            adocs.SiteId = aud.tp_SiteId and
            adocs.Id = aud.tp_DocId
    where
        wa.Library_Location = ''http://ule501/sites/e5DocumentsAuFy2010'' and
        w.Run_ID = ''' + convert(varchar(max), @run) + ''' and 
        adocs.TimeLastModified >= ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(@start, 'AUS Eastern Standard Time'), 120) + ''' and
        adocs.TimeLastModified <  ''' + convert(varchar(20), dbo.xfn_ConvertLocaltoUTC(dateadd(day, 1, @end), 'AUS Eastern Standard Time'), 120) + '''
    '

    execute (@sql) at [ULSQLGOLD01\E5]


--        select 
--*
--        from
--            [WSS_Content_e5DocAuFy2019].dbo.AllDocs adocs with(nolock)
--        where
--            SiteId = '9331E5D2-8D5E-4DC8-A9BC-B0967EB8E28C' and
--            Id = '8B75C34E-D7A3-4DD4-A133-8FC93893AE36'

--select 
--    *
--from
--    [WSS_Content_e5DocAuFy2019].dbo.AllUserData
--where
--    tp_Id = 1238019

--select top 100 *
--from
--    DocStreams
--where
--            SiteId = '9331E5D2-8D5E-4DC8-A9BC-B0967EB8E28C' and
--            DocId = '8B75C34E-D7A3-4DD4-A133-8FC93893AE36'


--select *
--from
--    [e5_Content_PRD]..WorkAttachment
--where
--    Work_Id = 'F63A7E43-54ED-11E9-80E4-005056A83B6B'





    if object_id('tempdb..#e5WorkAttachment') is not null
        drop table #e5WorkAttachment

    select 
        Work_ID,
        WorkAttachmentID,
        AttachmentID,
        AttachmentType,
        AttachmentName,
        AttachmentExt,
        AttachmentURL,
        AttachmentSize,
        DateCreated,
        DateModified
    into #e5WorkAttachment
    from
        [ULSQLGOLD01\E5].[WardyIT].[dbo].[attachments] with(nolock)
    where
        Run_ID = @run

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5WorkAttachment] with(tablock) t
        using #e5WorkAttachment s on
            s.AttachmentID = t.AttachmentID

        when matched then
            update
            set
                Work_ID = s.Work_ID,
                Original_Work_ID = s.Original_Work_ID,
                EventDate = s.EventDate,
                Event_Id = s.Event_Id,
                EventName = s.EventName,
                EventUserID = s.EventUserID,
                EventUser = s.EventUser,
                Status_Id = s.Status_Id,
                StatusName  = s.StatusName,
                Detail = s.Detail,
                Allocation = s.Allocation,
                ResumeEventId = s.ResumeEventId,
                ResumeEventStatusName = s.ResumeEventStatusName,
                BookmarkId = s.BookmarkId,
                ProcessStatus_Id = s.ProcessStatus_Id,
                ProcessStatus = s.ProcessStatus,
                ResumeEventDetail = s.ResumeEventDetail,
                UpdateBatchID = @batchid,
                DeleteBatchID = null

        when not matched by target then
            insert
            (
                Domain,
                Work_ID,
                Original_Work_ID,
                ID,
                EventDate,
                Event_Id,
                EventName,
                EventUserID,
                EventUser,
                Status_Id,
                StatusName,
                Detail,
                Allocation,
                ResumeEventId,
                ResumeEventStatusName,
                BookmarkId,
                ProcessStatus_Id,
                ProcessStatus,
                ResumeEventDetail,
                CreateBatchID
            )
            values
            (
                s.Domain,
                s.Work_ID,
                s.Original_Work_ID,
                s.ID,
                s.EventDate,
                s.Event_Id,
                s.EventName,
                s.EventUserID,
                s.EventUser,
                s.Status_Id,
                s.StatusName,
                s.Detail,
                s.Allocation,
                s.ResumeEventId,
                s.ResumeEventStatusName,
                s.BookmarkId,
                s.ProcessStatus_Id,
                s.ProcessStatus,
                s.ResumeEventDetail,
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
            @SourceInfo = 'e5WorkAttachment data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
