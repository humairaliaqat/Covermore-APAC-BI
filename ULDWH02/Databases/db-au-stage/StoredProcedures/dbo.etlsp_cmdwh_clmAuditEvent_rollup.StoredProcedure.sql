USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmAuditEvent_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_clmAuditEvent_rollup]  
as  
begin  
  
/*  
20140812 - LS - T12242 Global Claim, create  
20140918 - LS - T13338 Claim UTC  
20141111, LS,   T14092 Claims.Net Global  
                add new UK data set
20210306, SS, CHG0034615 Add filter for BK.com  
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
  
    if object_id('[db-au-cmdwh].dbo.clmAuditEvent') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmAuditEvent  
        (  
            [CountryKey] varchar(2) not null,  
            [AuditKey] varchar(50) not null,  
            [AuditUserName] nvarchar(150) null,  
            [AuditDateTime] datetime not null,  
            [AuditAction] char(1) not null,  
            [ClaimKey] varchar(40) not null,  
            [EventKey] varchar(40) not null,  
            [EventID] int not null,  
            [ClaimNo] int null,  
            [EMCID] int null,  
            [PerilCode] varchar(3) null,  
            [PerilDesc] nvarchar(65) null,  
            [EventCountryCode] varchar(3) null,  
            [EventCountryName] nvarchar(45) null,  
            [EventDate] datetime null,  
            [EventDesc] nvarchar(100) null,  
            [CreateDate] datetime null,  
            [CreatedBy] nvarchar(150) null,  
            [CaseID] varchar(15) null,  
            [CatastropheCode] varchar(3) null,  
            [CatastropheShortDesc] nvarchar(20) null,  
            [CatastropheLongDesc] nvarchar(60) null,  
            [BIRowID] int not null identity(1,1),  
            [AuditDateTimeUTC] datetime null,  
            [EventDateTimeUTC] datetime null,  
            [CreateDateTimeUTC] datetime null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null  
        )  
  
        create clustered index idx_clmAuditEvent_BIRowID on [db-au-cmdwh].dbo.clmAuditEvent(BIRowID)  
        create nonclustered index idx_clmAuditEvent_ClaimKey on [db-au-cmdwh].dbo.clmAuditEvent(ClaimKey) include(EventKey,EventCountryCode,EventDate,EventDesc,CaseID,CatastropheCode)  
        create nonclustered index idx_clmAuditEvent_EventKey on [db-au-cmdwh].dbo.clmAuditEvent(EventKey) include(ClaimKey,EventCountryCode,EventCountryName,EventDate,EventDesc,CaseID)  
        create nonclustered index idx_clmAuditEvent_AuditKey on [db-au-cmdwh].dbo.clmAuditEvent(AuditKey)  
  
    end  
  
    if object_id('etl_audit_claims_event') is not null  
        drop table etl_audit_claims_event  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, e.KE_ID) + '-' + left(e.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, e.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, e.KECLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, e.KECLAIM) + '-' + convert(varchar, e.KE_ID) EventKey,  
        e.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(e.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        dbo.xfn_ConvertUTCtoLocal(e.KEDLOSS, dk.TimeZone) EventDate,  
        dbo.xfn_ConvertUTCtoLocal(e.KEDCREATED, dk.TimeZone) CreateDate,  
        e.AUDIT_DATETIME AuditDateTimeUTC,  
        e.KEDLOSS EventDateTimeUTC,  
        e.KEDCREATED CreateDateTimeUTC,  
        e.AUDIT_ACTION AuditAction,  
        e.KE_ID EventID,  
        e.KECLAIM ClaimNo,  
        e.KEEMC_ID EMCID,  
        e.KEPERIL PerilCode,  
        (  
            select top 1  
                KLPERDESC  
            from  
                claims_klperilcodes_au pc  
            where  
                pc.KLPERCODE = e.KEPERIL and  
                pc.KLDOMAINID = c.KLDOMAINID  
        ) PerilDesc,  
        e.KECOUNTRY EventCountryCode,  
        (  
            select top 1  
                KLCNTRYDESC  
            from  
                claims_klcountry_au  
            where  
                KLCNTRYCODE = e.KECOUNTRY  
        ) EventCountryName,  
        e.KEDESC EventDesc,  
        (  
            select top 1  
                KSNAME  
            from  
                claims_klsecurity_au  
            where  
                KS_ID = e.KECREATEDBY_ID  
        ) CreatedBy,  
        e.KECASE_ID CaseID,  
        e.KECATASTROPHE CatastropheCode,  
        cat.CatastropheShortDesc,  
        cat.CatastropheLongDesc  
    into  
        etl_audit_claims_event  
    from  
        claims_audit_klevent_au e  
        outer apply  
        (  
            select top 1  
                c.KLDOMAINID  
            from  
                claims_klreg_au c  
            where  
                c.KLCLAIM = e.KECLAIM  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                KCSHORT CatastropheShortDesc,  
                KCLONG CatastropheLongDesc  
            from  
                claims_klcatas_au  cat  
            where  
                cat.KC_CODE = e.KECATASTROPHE and  
                cat.KLDOMAINID = c.KLDOMAINID  
        ) cat  
  
    union all  
      
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, e.KE_ID) + '-' + left(e.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, e.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, e.KECLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, e.KECLAIM) + '-' + convert(varchar, e.KE_ID) EventKey,  
        e.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(e.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        dbo.xfn_ConvertUTCtoLocal(e.KEDLOSS, dk.TimeZone) EventDate,  
        dbo.xfn_ConvertUTCtoLocal(e.KEDCREATED, dk.TimeZone) CreateDate,  
        e.AUDIT_DATETIME AuditDateTimeUTC,  
        e.KEDLOSS EventDateTimeUTC,  
        e.KEDCREATED CreateDateTimeUTC,  
        e.AUDIT_ACTION AuditAction,  
        e.KE_ID EventID,  
        e.KECLAIM ClaimNo,  
        e.KEEMC_ID EMCID,  
        e.KEPERIL PerilCode,  
        (  
            select top 1  
                KLPERDESC  
            from  
                claims_klperilcodes_uk2 pc  
            where  
                pc.KLPERCODE = e.KEPERIL and  
                pc.KLDOMAINID = c.KLDOMAINID  
        ) PerilDesc,  
        e.KECOUNTRY EventCountryCode,  
        (  
            select top 1  
                KLCNTRYDESC  
            from  
                claims_klcountry_uk2  
            where  
                KLCNTRYCODE = e.KECOUNTRY  
        ) EventCountryName,  
        e.KEDESC EventDesc,  
        (  
            select top 1  
                KSNAME  
            from  
                claims_klsecurity_uk2  
            where  
                KS_ID = e.KECREATEDBY_ID  
        ) CreatedBy,  
        e.KECASE_ID CaseID,  
        e.KECATASTROPHE CatastropheCode,  
        cat.CatastropheShortDesc,  
        cat.CatastropheLongDesc  
    from  
        claims_audit_klevent_uk2 e  
        outer apply  
        (  
            select top 1  
                c.KLDOMAINID  
            from  
                claims_klreg_uk2 c  
            where  
                c.KLCLAIM = e.KECLAIM  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk  
        outer apply  
        (  
     select top 1  
                KCSHORT CatastropheShortDesc,  
                KCLONG CatastropheLongDesc  
            from  
                claims_klcatas_uk2 cat  
            where  
                cat.KC_CODE = e.KECATASTROPHE and  
                cat.KLDOMAINID = c.KLDOMAINID  
        ) cat  
	where dk.CountryKey + '-' + convert(varchar, e.KECLAIM) not in 
	(select dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey
		from    
        claims_klreg_uk2 c    
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk 
		where c.KLALPHA like 'BK%')
      
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmAuditEvent with(tablock) t  
        using etl_audit_claims_Event s on  
            s.AuditKey = t.AuditKey  
  
        when matched then  
  
            update  
            set  
                AuditUserName = s.AuditUserName,  
                AuditDateTime = s.AuditDateTime,  
                AuditAction = s.AuditAction,  
                ClaimKey = s.ClaimKey,  
                EventID = s.EventID,  
                ClaimNo = s.ClaimNo,  
                EMCID = s.EMCID,  
                PerilCode = s.PerilCode,  
                PerilDesc = s.PerilDesc,  
                EventCountryCode = s.EventCountryCode,  
                EventCountryName = s.EventCountryName,  
                EventDate = s.EventDate,  
                EventDesc = s.EventDesc,  
                CreateDate = s.CreateDate,  
                CreatedBy = s.CreatedBy,  
                CaseID = s.CaseID,  
                CatastropheCode = s.CatastropheCode,  
                CatastropheShortDesc = s.CatastropheShortDesc,  
                CatastropheLongDesc = s.CatastropheLongDesc,  
                AuditDateTimeUTC = s.AuditDateTimeUTC,  
                EventDateTimeUTC = s.EventDateTimeUTC,  
                CreateDateTimeUTC = s.CreateDateTimeUTC,  
                UpdateBatchID = @batchid  
  
        when not matched by target then  
            insert  
            (  
                AuditKey,  
                AuditUserName,  
                AuditDateTime,  
                AuditAction,  
                CountryKey,  
                ClaimKey,  
                EventKey,  
                EventID,  
                ClaimNo,  
                EMCID,  
                PerilCode,  
                PerilDesc,  
                EventCountryCode,  
                EventCountryName,  
                EventDate,  
                EventDesc,  
                CreateDate,  
                CreatedBy,  
                CaseID,  
                CatastropheCode,  
                CatastropheShortDesc,  
                CatastropheLongDesc,  
                AuditDateTimeUTC,  
                EventDateTimeUTC,  
                CreateDateTimeUTC,  
                CreateBatchID  
            )  
            values  
            (  
                s.AuditKey,  
                s.AuditUserName,  
                s.AuditDateTime,  
                s.AuditAction,  
                s.CountryKey,  
                s.ClaimKey,  
                s.EventKey,  
                s.EventID,  
                s.ClaimNo,  
                s.EMCID,  
                s.PerilCode,  
                s.PerilDesc,  
                s.EventCountryCode,  
                s.EventCountryName,  
                s.EventDate,  
                s.EventDesc,  
                s.CreateDate,  
                s.CreatedBy,  
                s.CaseID,  
                s.CatastropheCode,  
                s.CatastropheShortDesc,  
                s.CatastropheLongDesc,  
                s.AuditDateTimeUTC,  
                s.EventDateTimeUTC,  
                s.CreateDateTimeUTC,  
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
            @SourceInfo = 'clmAuditEvent data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
  
GO
