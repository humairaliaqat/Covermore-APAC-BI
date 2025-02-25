USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmAuditSection_rollup_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
create procedure [dbo].[etlsp_cmdwh_clmAuditSection_rollup_20210906]  
as  
begin  
  
/*  
20121214 - LS - Case 18105  
                change from dimension to fact (incremental)  
20130305 - LS - TFS 7740, AAA schema changes  
20140516 - LS - Online claim bug, null event id handler  
20140807 - LS - T12242 Global Claim  
                use batch logging  
20140918 - LS - T13338 Claim UTC  
20141111 - LS - T14092 Claims.Net Global  
                add new UK data set  
20150224, LS,   F23264  
                audit based flagging moved to audit etl (as in payment)  
20160810, LL,   null benefit section causes duplicate records  
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
  
    if object_id('[db-au-cmdwh].dbo.clmAuditSection') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmAuditSection  
        (  
            [CountryKey] varchar(2) not null,  
            [AuditKey] varchar(50) not null,  
            [ClaimKey] varchar(40) not null,  
            [SectionKey] varchar(40) not null,  
            [EventKey] varchar(40) not null,  
            [AuditUserName] nvarchar(150) null,  
            [AuditDateTime] datetime not null,  
            [AuditAction] char(1) not null,  
            [SectionID] int not null,  
            [ClaimNo] int null,  
            [EventID] int null,  
            [SectionCode] varchar(25) null,  
            [EstimateValue] money null,  
            [Redundant] bit not null,  
            [BenefitSectionKey] varchar(40) null,  
            [BenefitSectionID] int null,  
            [BenefitSubSectionID] int null,  
            [SectionDescription] nvarchar(200) null,  
            [BenefitLimit] nvarchar(200) null,  
            [RecoveryEstimateValue] money null,  
            [BIRowID] int not null identity(1,1),  
            [AuditDateTimeUTC] datetime null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null  
        )  
  
        create clustered index idx_clmAuditSection_BIRowID on [db-au-cmdwh].dbo.clmAuditSection(BIRowID)  
        create nonclustered index idx_clmAuditSection_AuditDateTime on [db-au-cmdwh].dbo.clmAuditSection(AuditDateTime) include(ClaimKey,SectionKey)  
        create nonclustered index idx_clmAuditSection_ClaimKey on [db-au-cmdwh].dbo.clmAuditSection(ClaimKey) include(SectionKey,AuditDateTime,AuditAction,EstimateValue)  
        create nonclustered index idx_clmAuditSection_SectionKey on [db-au-cmdwh].dbo.clmAuditSection(SectionKey,AuditDateTime) include(AuditAction,EstimateValue,BenefitSectionKey)  
        create nonclustered index idx_clmAuditSection_ClaimNo on [db-au-cmdwh].dbo.clmAuditSection(ClaimNo)  
        create nonclustered index idx_clmAuditSection_AuditKey on [db-au-cmdwh].dbo.clmAuditSection(AuditKey)  
  
    end  
  
    if object_id('etl_audit_claims_section') is not null  
        drop table etl_audit_claims_section  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, s.KS_ID) + '-' + left(s.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, s.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,  
        s.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(s.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        s.AUDIT_DATETIME AuditDateTimeUTC,  
        s.AUDIT_ACTION AuditAction,  
        s.KS_ID SectionID,  
        s.KSCLAIM_ID ClaimNo,  
        s.KSEVENT_ID EventID,  
        s.KSSECTCODE SectionCode,  
        s.KSESTV EstimateValue,  
        isnull(s.KSREDUND, 0) Redundant,  
        case  
            when coalesce(b.KBSECT_ID, bfo.BenefitSectionID) is null then dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '') collate database_default)  
            else dk.CountryKey + '-' + convert(varchar, coalesce(b.KBSECT_ID, bfo.BenefitSectionID))  
        end BenefitSectionKey,  
        coalesce(b.KBSECT_ID, bfo.BenefitSectionID) BenefitSectionID,  
        s.KBSS_ID BenefitSubSectionID,  
        s.KSBENEFITLIMIT BenefitLimit,  
        s.KSSECTDESC SectionDescription,  
        s.KSRECOVEST RecoveryEstimateValue  
    into  
        etl_audit_claims_section  
    from  
        claims_AUDIT_KLSECTION_au s  
        outer apply  
        (  
            /* claim record exists due to metadata rule */  
            select top 1  
                KLDOMAINID,  
                KLPRODUCT  
            from  
                claims_KLREG_au c  
            where  
                c.KLCLAIM = s.KSCLAIM_ID  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                b.KBSECT_ID  
            from  
                claims_klbenefit_au b  
            where  
                b.KBCODE = s.KSSECTCODE and  
                b.KBPROD = c.KLPRODUCT and  
                b.KLDOMAINID = c.KLDOMAINID  
            order by  
                b.KBVALIDFROM desc  
        ) b  
        outer apply  
        (  
            select top 1  
                b.BenefitSectionID  
            from  
                [db-au-cmdwh]..clmBenefit b  
            where  
                b.ProductCode = s.KSSECTCODE collate database_default and  
                b.ProductCode = c.KLPRODUCT collate database_default and  
                b.CountryKey = dk.CountryKey  
            order by  
                b.BenefitValidFrom desc  
        ) bfo  
          
    union all  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, s.KS_ID) + '-' + left(s.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, s.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) + '-' + convert(varchar, s.KS_ID) SectionKey,  
        dk.CountryKey + '-' + convert(varchar, s.KSCLAIM_ID) + '-' + convert(varchar, isnull(s.KSEVENT_ID, 0)) EventKey,  
        s.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(s.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        s.AUDIT_DATETIME AuditDateTimeUTC,  
        s.AUDIT_ACTION AuditAction,  
        s.KS_ID SectionID,  
        s.KSCLAIM_ID ClaimNo,  
        s.KSEVENT_ID EventID,  
        s.KSSECTCODE SectionCode,  
        s.KSESTV EstimateValue,  
        isnull(s.KSREDUND, 0) Redundant,  
        case  
            when coalesce(b.KBSECT_ID, bfo.BenefitSectionID) is null then dk.CountryKey + '-X' + (isnull(c.KLPRODUCT, '') + isnull(s.KSSECTCODE, '') collate database_default)  
            else dk.CountryKey + '-' + convert(varchar, coalesce(b.KBSECT_ID, bfo.BenefitSectionID))  
        end BenefitSectionKey,  
        coalesce(b.KBSECT_ID, bfo.BenefitSectionID) BenefitSectionID,  
        s.KBSS_ID BenefitSubSectionID,  
  s.KSBENEFITLIMIT BenefitLimit,  
        s.KSSECTDESC SectionDescription,  
        s.KSRECOVEST RecoveryEstimateValue  
    from  
        claims_AUDIT_KLSECTION_uk2 s  
        outer apply  
        (  
            /* claim record exists due to metadata rule */  
            select top 1  
                KLDOMAINID,  
                KLPRODUCT  
            from  
                claims_KLREG_uk2 c  
            where  
                c.KLCLAIM = s.KSCLAIM_ID  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                b.KBSECT_ID  
            from  
                claims_klbenefit_uk2 b  
            where  
                b.KBCODE = s.KSSECTCODE and  
                b.KBPROD = c.KLPRODUCT and  
                b.KLDOMAINID = c.KLDOMAINID  
            order by  
                b.KBVALIDFROM desc  
        ) b  
        outer apply  
        (  
            select top 1  
                b.BenefitSectionID  
            from  
                [db-au-cmdwh]..clmBenefit b  
            where  
                b.ProductCode = s.KSSECTCODE collate database_default and  
                b.ProductCode = c.KLPRODUCT collate database_default and  
                b.CountryKey = dk.CountryKey  
            order by  
                b.BenefitValidFrom desc  
        ) bfo  
      
  
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmAuditSection with(tablock) t  
        using etl_audit_claims_section s on  
            s.AuditKey = t.AuditKey  
  
        when matched then  
  
            update  
            set  
                ClaimKey = s.ClaimKey,  
                SectionKey = s.SectionKey,  
                EventKey = s.EventKey,  
                AuditUserName = s.AuditUserName,  
                AuditDateTime = s.AuditDateTime,  
                AuditAction = s.AuditAction,  
                SectionID = s.SectionID,  
                ClaimNo = s.ClaimNo,  
                EventID = s.EventID,  
                SectionCode = s.SectionCode,  
                EstimateValue = s.EstimateValue,  
                Redundant = s.Redundant,  
                BenefitSectionKey = s.BenefitSectionKey,  
                BenefitSectionID = s.BenefitSectionID,  
                BenefitSubSectionID = s.BenefitSubSectionID,  
                BenefitLimit = s.BenefitLimit,  
                SectionDescription = s.SectionDescription,  
                RecoveryEstimateValue = s.RecoveryEstimateValue,  
                AuditDateTimeUTC = s.AuditDateTimeUTC,  
                UpdateBatchID = @batchid  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                AuditKey,  
                ClaimKey,  
                SectionKey,  
                EventKey,  
                AuditUserName,  
                AuditDateTime,  
                AuditAction,  
                SectionID,  
                ClaimNo,  
                EventID,  
                SectionCode,  
                EstimateValue,  
                Redundant,  
                BenefitSectionKey,  
                BenefitSectionID,  
                BenefitSubSectionID,  
                BenefitLimit,  
                SectionDescription,  
                RecoveryEstimateValue,  
                AuditDateTimeUTC,  
                CreateBatchID  
            )  
            values  
            (  
                s.CountryKey,  
                s.AuditKey,  
                s.ClaimKey,  
                s.SectionKey,  
                s.EventKey,  
                s.AuditUserName,  
                s.AuditDateTime,  
                s.AuditAction,  
                s.SectionID,  
                s.ClaimNo,  
                s.EventID,  
                s.SectionCode,  
                s.EstimateValue,  
                s.Redundant,  
                s.BenefitSectionKey,  
                s.BenefitSectionID,  
                s.BenefitSubSectionID,  
                s.BenefitLimit,  
                s.SectionDescription,  
                s.RecoveryEstimateValue,  
                s.AuditDateTimeUTC,  
                @batchid  
            )  
  
        output $action into @mergeoutput  
        ;  
  
  
        --update isDeleted  
        update [db-au-cmdwh]..clmSection  
        set  
            isDeleted = 1,  
            UpdateBatchID = @batchid  
        where  
            SectionKey in  
            (  
                select  
                    SectionKey  
                from  
                    etl_audit_claims_section  
                where  
                    AuditAction = 'D'  
            )  
  
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
            @SourceInfo = 'clmAuditSection data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
GO
