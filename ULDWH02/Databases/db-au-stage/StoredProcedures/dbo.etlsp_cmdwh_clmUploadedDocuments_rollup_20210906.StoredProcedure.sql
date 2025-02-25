USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmUploadedDocuments_rollup_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_clmUploadedDocuments_rollup_20210906]  
as  
begin  
/*  
20150730, LS, create  
*/  
  
    set nocount on  
  
    exec etlsp_StagingIndex_Claim  
  
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
        @SubjectArea = 'Claim ODS',  
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
  
    if object_id('[db-au-cmdwh].dbo.clmUploadedDocuments') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmUploadedDocuments  
        (  
            [BIRowID] int not null identity(1,1),  
            [CountryKey] varchar(2) not null,  
            [ClaimKey] varchar(40) null,  
            [DocumentKey] varchar(40) not null,  
            [DocumentID] int not null,  
            [CreateDate] datetime null,  
            [ClaimNo] int null,  
            [SectionCode] varchar(25) null,  
            [OnlineClaimID] int not null,  
            [DocumentType] nvarchar(128) null,  
            [FileName] nvarchar(128) null,  
            [isProcessed] bit null,  
            [MissingReason] varchar(25) null,  
            [ReasonDescription] nvarchar(256) null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null  
        )  
  
        create clustered index idx_clmUploadedDocuments_BIRowID on [db-au-cmdwh].dbo.clmUploadedDocuments(BIRowID)  
        create nonclustered index idx_clmUploadedDocuments_DocumentKey on [db-au-cmdwh].dbo.clmUploadedDocuments(DocumentKey)  
        create nonclustered index idx_clmUploadedDocuments_ClaimKey on [db-au-cmdwh].dbo.clmUploadedDocuments(ClaimKey) include(SectionCode,DocumentType,FileName,isProcessed,MissingReason,ReasonDescription)  
  
    end  
  
    if object_id('tempdb..#etl_uploadeddocs') is not null  
        drop table #etl_uploadeddocs  
  
    select   
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, ud.Id) DocumentKey,  
        ud.Id DocumentID,  
        dbo.xfn_ConvertUTCtoLocal(ud.CreatedDate, dk.TimeZone) CreateDate,  
        oc.ClaimId ClaimNo,  
        ud.SectionCode,  
        oc.OnlineClaimID,  
        dt.DocumentType,  
        ud.FileName,  
        ud.IsProcessed,  
        case  
            when ud.MissingReason is null then 'N/A'  
            when ud.MissingReason = 1 then 'Cannot acquire'  
            when ud.MissingReason = 2 then 'Will provide later'  
            else 'Undefined'  
        end MissingReason,  
        ud.ReasonDescription  
    into #etl_uploadeddocs  
    from  
        claims_UploadedDocuments_au ud  
        inner join claims_tblOnlineClaims_au oc on  
            oc.OnlineClaimId = ud.OnlineClaimId  
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'AU') dk  
        left join claims_DocumentTypes_au dt on  
            dt.DocumentTypeId = ud.DocumentTypeId and  
            dt.DOMAINID = oc.KLDOMAINID  
  
    union all  
  
    select   
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, ud.Id) DocumentKey,  
        ud.Id DocumentID,  
        dbo.xfn_ConvertUTCtoLocal(ud.CreatedDate, dk.TimeZone) CreateDate,  
        oc.ClaimId ClaimNo,  
        ud.SectionCode,  
        oc.OnlineClaimID,  
        dt.DocumentType,  
        ud.FileName,  
        ud.IsProcessed,  
        case  
            when ud.MissingReason is null then 'N/A'  
            when ud.MissingReason = 1 then 'Cannot acquire'  
            when ud.MissingReason = 2 then 'Will provide later'  
            else 'Undefined'  
        end MissingReason,  
        ud.ReasonDescription  
    from  
        claims_UploadedDocuments_uk2 ud  
        inner join claims_tblOnlineClaims_uk2 oc on  
            oc.OnlineClaimId = ud.OnlineClaimId  
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'UK') dk  
        left join claims_DocumentTypes_uk2 dt on  
            dt.DocumentTypeId = ud.DocumentTypeId and  
            dt.DOMAINID = oc.KLDOMAINID  
  
  
    set @sourcecount = @@rowcount  
  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmUploadedDocuments with(tablock) t  
        using #etl_uploadeddocs s on  
            s.DocumentKey = t.DocumentKey  
  
        when matched then  
  
            update  
            set  
                CountryKey = s.CountryKey,  
                ClaimKey = s.ClaimKey,  
                DocumentID = s.DocumentID,  
                CreateDate = s.CreateDate,  
                ClaimNo = s.ClaimNo,  
                SectionCode = s.SectionCode,  
                OnlineClaimID = s.OnlineClaimID,  
                DocumentType = s.DocumentType,  
                FileName = s.FileName,  
                IsProcessed = s.IsProcessed,  
                MissingReason = s.MissingReason,  
                ReasonDescription = s.ReasonDescription,  
                UpdateBatchID = @batchid  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                ClaimKey,  
                DocumentKey,  
                DocumentID,  
                CreateDate,  
                ClaimNo,  
                SectionCode,  
                OnlineClaimID,  
                DocumentType,  
                FileName,  
                IsProcessed,  
                MissingReason,  
                ReasonDescription,  
                CreateBatchID  
            )  
            values  
            (  
                s.CountryKey,  
                s.ClaimKey,  
                s.DocumentKey,  
                s.DocumentID,  
                s.CreateDate,  
                s.ClaimNo,  
                s.SectionCode,  
                s.OnlineClaimID,  
                s.DocumentType,  
                s.FileName,  
                s.IsProcessed,  
                s.MissingReason,  
                s.ReasonDescription,  
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
            @SourceInfo = 'clmUploadedDocuments data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
GO
