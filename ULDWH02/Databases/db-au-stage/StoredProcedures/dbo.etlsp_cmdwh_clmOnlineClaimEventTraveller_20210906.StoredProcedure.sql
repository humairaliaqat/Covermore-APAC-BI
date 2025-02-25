USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmOnlineClaimEventTraveller_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_clmOnlineClaimEventTraveller_20210906]  
as  
begin  
/*  
    20160620, LL, create  
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
  
    if object_id('[db-au-cmdwh].dbo.clmOnlineClaimEventTraveller') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller  
        (  
            BIRowID bigint identity(1,1) not null,  
            CountryKey varchar(2) not null,  
            ClaimKey varchar(40),  
            OnlineClaimKey varchar(40) not null,  
            ClaimNo int,  
            OnlineClaimID int not null,  
            FirstName varchar(255),  
            Lastname varchar(255),  
            DOB date  
        )  
  
        create clustered index idx_clmOnlineClaimEventTraveller_BIRowID on [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller(BIRowID)  
        create nonclustered index idx_clmOnlineClaimEventTraveller_ClaimKey on [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller(ClaimKey) include(BIRowID)  
        create nonclustered index idx_clmOnlineClaimEventTraveller_ClaimNo on [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller(ClaimNo) include(BIRowID)  
        create nonclustered index idx_clmOnlineClaimEventTraveller_OnlineClaimKey on [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller(OnlineClaimKey)  
        create nonclustered index idx_clmOnlineClaimEventTraveller_Name on [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller(FirstName,Lastname) include (DOB,ClaimKey)  
  
    end  
  
--select   
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',  
--    COLUMN_NAME + ','  
--from  
--    tempdb.INFORMATION_SCHEMA.COLUMNS  
--where  
--    TABLE_NAME like '#onlineclaimseventtraveller%'  
  
    if object_id('tempdb..#onlineclaimseventtraveller') is not null  
        drop table #onlineclaimseventtraveller  
  
    --ill travellers  
    select   
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, oc.OnlineClaimID) OnlineClaimKey,  
        oc.ClaimId ClaimNo,  
        oc.OnlineClaimID,  
        inj.value('FirstName[1]', 'varchar(max)') FirstName,  
        inj.value('LastName[1]', 'varchar(max)') Lastname,  
        try_convert(date, inj.value('Dob[1]', 'varchar(max)')) DOB  
    into #onlineclaimseventtraveller  
    from  
        claims_tblOnlineClaims_au oc   
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'AU') dk  
        inner join claims_tblOnlineClaimEventCauses_au oce on  
            oce.EventCauseId = oc.ClaimCauseId  
        left join claims_KLPERILCODES_au p on  
            p.KLPER_ID = oce.KLPER_ID  
        cross apply  
        (  
            select  
                try_convert(xml, oce.DetailDescription) EventXML  
        ) ex  
        cross apply EventXML.nodes('/ClaimCauseIllHealth/Travellers/Traveller') as inj(inj)  
  
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        delete   
        from  
            [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller  
        where  
            OnlineClaimKey in  
            (  
                select  
                    OnlineClaimKey  
                from  
                    #onlineclaimseventtraveller  
            )  
  
        insert into [db-au-cmdwh].dbo.clmOnlineClaimEventTraveller with (tablock)  
        (  
            CountryKey,  
            ClaimKey,  
            OnlineClaimKey,  
            ClaimNo,  
            OnlineClaimID,  
            FirstName,  
            Lastname,  
            DOB  
        )  
        select  
            CountryKey,  
            ClaimKey,  
            OnlineClaimKey,  
            ClaimNo,  
            OnlineClaimID,  
            FirstName,  
            Lastname,  
            DOB  
        from  
            #onlineclaimseventtraveller  
  
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
            @SourceInfo = 'clmOnlineClaimEventTraveller data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
  
GO
