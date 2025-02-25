USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmAuditName_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_clmAuditName_rollup]  
as  
begin  
/*  
20140807, LS,   T12242 Global Claim  
                use batch logging  
20140918, LS,   T13338 Claim UTC  
20141111, LS,   T14092 Claims.Net Global  
                add new UK data set  
                enlarge bank name 
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
  
    if object_id('[db-au-cmdwh].dbo.clmAuditName') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmAuditName  
        (  
            [CountryKey] varchar(2) not null,  
            [AuditKey] varchar(50) not null,  
            [NameKey] varchar(40) null,  
            [ClaimKey] varchar(40) null,  
            [AuditUserName] nvarchar(150) null,  
            [AuditDateTime] datetime not null,  
            [AuditAction] char(1) not null,  
            [NameID] int not null,  
            [ClaimNo] int null,  
            [Num] smallint null,  
            [Surname] nvarchar(100) null,  
            [Firstname] nvarchar(100) null,  
            [Title] nvarchar(50) null,  
            [DOB] datetime null,  
            [AddressStreet] nvarchar(100) null,  
            [AddressSuburb] nvarchar(50) null,  
            [AddressState] nvarchar(100) null,  
            [AddressCountry] nvarchar(100) null,  
            [AddressPostCode] nvarchar(50) null,  
            [HomePhone] nvarchar(50) null,  
            [WorkPhone] nvarchar(50) null,  
            [Fax] varchar(20) null,  
            [Email] nvarchar(255) null,  
            [isDirectCredit] bit null,  
            [AccountNo] varchar(20) null,  
            [AccountName] nvarchar(100) null,  
            [BSB] nvarchar(15) null,  
            [isPrimary] bit null,  
            [isThirdParty] bit null,  
            [isForeign] bit null,  
            [ProviderID] int null,  
            [BusinessName] nvarchar(100) null,  
            [isEmailOK] bit null,  
            [PaymentMethodID] int null,  
            [EMC] varchar(10) null,  
            [ITC] bit null,  
            [ITCPCT] float null,  
            [isGST] bit null,  
            [GSTPercentage] float null,  
            [GoodsSupplier] bit null,  
            [ServiceProvider] bit null,  
            [SupplyBy] int null,  
            [EncryptAccount] varbinary(256) null,  
            [EncryptBSB] varbinary(256) null,  
            [isPayer] bit null,  
            [BankName] nvarchar(50) null,  
            [BIRowID] int not null identity(1,1),  
            [AuditDateTimeUTC] datetime null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null  
        )  
  
        create clustered index idx_clmAuditName_BIRowID on [db-au-cmdwh].dbo.clmAuditName(BIRowID)  
        create nonclustered index idx_clmAuditName_AuditDateTime on [db-au-cmdwh].dbo.clmAuditName(AuditDateTime) include(NameKey)  
        create nonclustered index idx_clmAuditName_NameKey on [db-au-cmdwh].dbo.clmAuditName(NameKey)  
        create nonclustered index idx_clmAuditName_ClaimKey on [db-au-cmdwh].dbo.clmAuditName(ClaimKey)  
        create nonclustered index idx_clmAuditName_NameID on [db-au-cmdwh].dbo.clmAuditName(NameID)  
        create nonclustered index idx_clmAuditName_ClaimNo on [db-au-cmdwh].dbo.clmAuditName(ClaimNo)  
        create nonclustered index idx_clmAuditName_AuditKey on [db-au-cmdwh].dbo.clmAuditName(AuditKey)  
  
    end  
  
    if object_id('etl_audit_claims_name') is not null  
        drop table etl_audit_claims_name  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, n.KN_ID) + '-' + left(n.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, n.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, n.KNCLAIM_ID) + '-' + convert(varchar, n.KN_ID) NameKey,  
        dk.CountryKey + '-' + convert(varchar, n.KNCLAIM_ID) ClaimKey,  
        n.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(n.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        n.AUDIT_DATETIME AuditDateTimeUTC,  
        n.AUDIT_ACTION AuditAction,  
        n.KN_ID NameID,  
        n.KNCLAIM_ID ClaimNo,  
        n.KNNUM Num,  
        n.KNSURNAME Surname,  
        n.KNFIRST Firstname,  
        n.KNTITLE Title,  
        n.KNDOB DOB,  
        n.KNSTREET AddressStreet,  
        n.KNSUBURB AddressSuburb,  
        n.KNSTATE AddressState,  
        n.KNCOUNTRY AddressCountry,  
        n.KNPCODE AddressPostCode,  
        n.KNHPHONE HomePhone,  
        n.KNWPHONE WorkPhone,  
        n.KNFAX Fax,  
        n.KNEMAIL Email,  
        n.KNDIRECTCRED isDirectCredit,  
        n.KNACCT AccountNo,  
        n.KNACCTNAME AccountName,  
        n.KNBSB BSB,  
        n.KNPRIMARY isPrimary,  
        n.KNTHIRDPARTY isThirdParty,  
        n.KNFOREIGN isForeign,  
        n.KNPROV_ID ProviderID,  
        n.KNBUSINESSNAME BusinessName,  
        n.KNEMAILOK isEmailOK,  
        n.KNPAYMENTMETHODID PaymentMethodID,  
        n.KNEMC EMC,  
        n.KNITC ITC,  
        n.KNITCPCT ITCPCT,  
        n.KPGST isGST,  
        n.KPGSTPERC GSTPercentage,  
        n.KPGOODSSUPPLIER GoodsSupplier,  
        n.KPSERVPROV ServiceProvider,  
        n.KPSUPPLYBY SupplyBy,  
        n.KNEncryptACCT EncryptAccount,  
        n.KNEncryptBSB EncryptBSB,  
        n.KNPAYER isPayer,  
        n.KPBANKNAME BankName  
    into etl_audit_claims_name  
    from  
        claims_AUDIT_KLNAMES_au n  
        outer apply  
        (  
            /* claim record exists due to metadata rule */  
            select top 1  
                KLDOMAINID  
            from  
                claims_KLREG_au c  
            where  
                c.KLCLAIM = n.KNCLAIM_ID  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk  
          
    union all  
      
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, n.KN_ID) + '-' + left(n.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, n.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,  
        dk.CountryKey + '-' + convert(varchar, n.KNCLAIM_ID) + '-' + convert(varchar, n.KN_ID) NameKey,  
        dk.CountryKey + '-' + convert(varchar, n.KNCLAIM_ID) ClaimKey,  
        n.AUDIT_USERNAME AuditUserName,  
        dbo.xfn_ConvertUTCtoLocal(n.AUDIT_DATETIME, dk.TimeZone) AuditDateTime,  
        n.AUDIT_DATETIME AuditDateTimeUTC,  
        n.AUDIT_ACTION AuditAction,  
        n.KN_ID NameID,  
        n.KNCLAIM_ID ClaimNo,  
        n.KNNUM Num,  
        n.KNSURNAME Surname,  
        n.KNFIRST Firstname,  
        n.KNTITLE Title,  
        n.KNDOB DOB,  
        n.KNSTREET AddressStreet,  
        n.KNSUBURB AddressSuburb,  
        n.KNSTATE AddressState,  
        n.KNCOUNTRY AddressCountry,  
        n.KNPCODE AddressPostCode,  
        n.KNHPHONE HomePhone,  
        n.KNWPHONE WorkPhone,  
        n.KNFAX Fax,  
        n.KNEMAIL Email,  
        n.KNDIRECTCRED isDirectCredit,  
        n.KNACCT AccountNo,  
        n.KNACCTNAME AccountName,  
        n.KNBSB BSB,  
        n.KNPRIMARY isPrimary,  
        n.KNTHIRDPARTY isThirdParty,  
        n.KNFOREIGN isForeign,  
        n.KNPROV_ID ProviderID,  
        n.KNBUSINESSNAME BusinessName,  
        n.KNEMAILOK isEmailOK,  
        n.KNPAYMENTMETHODID PaymentMethodID,  
        n.KNEMC EMC,  
        n.KNITC ITC,  
        n.KNITCPCT ITCPCT,  
        n.KPGST isGST,  
        n.KPGSTPERC GSTPercentage,  
        n.KPGOODSSUPPLIER GoodsSupplier,  
        n.KPSERVPROV ServiceProvider,  
        n.KPSUPPLYBY SupplyBy,  
        n.KNEncryptACCT EncryptAccount,  
        n.KNEncryptBSB EncryptBSB,  
        n.KNPAYER isPayer,  
        n.KPBANKNAME BankName  
    from  
        claims_AUDIT_KLNAMES_uk2 n  
        outer apply  
        (  
            /* claim record exists due to metadata rule */  
            select top 1  
                KLDOMAINID  
            from  
                claims_KLREG_uk2 c  
            where  
                c.KLCLAIM = n.KNCLAIM_ID  
        ) c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk  
	where dk.CountryKey + '-' + convert(varchar, n.KNCLAIM_ID) not in 
		(select dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey
		from    
        claims_klreg_uk2 c    
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk 
		where c.KLALPHA like 'BK%')		 ------adding condition to filter out BK.com data 
  
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmAuditName with(tablock) t  
        using etl_audit_claims_name s on  
            s.AuditKey = t.AuditKey  
  
        when matched then  
  
            update  
            set  
                NameKey = s.NameKey,  
                ClaimKey = s.ClaimKey,  
                AuditUserName = s.AuditUserName,  
                AuditDateTime = s.AuditDateTime,  
                AuditAction = s.AuditAction,  
                NameID = s.NameID,  
                ClaimNo = s.ClaimNo,  
                Num = s.Num,  
                Surname = s.Surname,  
                Firstname = s.Firstname,  
                Title = s.Title,  
                DOB = s.DOB,  
                AddressStreet = s.AddressStreet,  
                AddressSuburb = s.AddressSuburb,  
                AddressState = s.AddressState,  
                AddressCountry = s.AddressCountry,  
                AddressPostCode = s.AddressPostCode,  
                HomePhone = s.HomePhone,  
                WorkPhone = s.WorkPhone,  
                Fax = s.Fax,  
                Email = s.Email,  
                isDirectCredit = s.isDirectCredit,  
                AccountNo = s.AccountNo,  
                AccountName = s.AccountName,  
                BSB = s.BSB,  
                isPrimary = s.isPrimary,  
                isThirdParty = s.isThirdParty,  
                isForeign = s.isForeign,  
                ProviderID = s.ProviderID,  
                BusinessName = s.BusinessName,  
                isEmailOK = s.isEmailOK,  
                PaymentMethodID = s.PaymentMethodID,  
                EMC = s.EMC,  
                ITC = s.ITC,  
                ITCPCT = s.ITCPCT,  
                isGST = s.isGST,  
                GSTPercentage = s.GSTPercentage,  
                GoodsSupplier = s.GoodsSupplier,  
                ServiceProvider = s.ServiceProvider,  
                SupplyBy = s.SupplyBy,  
                EncryptAccount = s.EncryptAccount,  
                EncryptBSB = s.EncryptBSB,  
                isPayer = s.isPayer,  
                BankName = s.BankName,  
                AuditDateTimeUTC = s.AuditDateTimeUTC,  
                UpdateBatchID = @batchid  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                AuditKey,  
                NameKey,  
                ClaimKey,  
                AuditUserName,  
                AuditDateTime,  
                AuditAction,  
                NameID,  
                ClaimNo,  
                Num,  
                Surname,  
                Firstname,  
                Title,  
                DOB,  
                AddressStreet,  
                AddressSuburb,  
                AddressState,  
                AddressCountry,  
                AddressPostCode ,  
                HomePhone,  
                WorkPhone,  
                Fax,  
                Email,  
                isDirectCredit,  
                AccountNo,  
                AccountName,  
                BSB,  
                isPrimary,  
                isThirdParty,  
                isForeign,  
                ProviderID,  
                BusinessName ,  
                isEmailOK,  
                PaymentMethodID,  
                EMC,  
                ITC,  
                ITCPCT,  
                isGST,  
                GSTPercentage,  
                GoodsSupplier,  
                ServiceProvider,  
                SupplyBy,  
                EncryptAccount ,  
                EncryptBSB,  
                isPayer,  
                BankName,  
                AuditDateTimeUTC,  
                CreateBatchID  
            )  
            values  
            (  
                s.CountryKey,  
                s.AuditKey,  
                s.NameKey,  
                s.ClaimKey,  
                s.AuditUserName,  
                s.AuditDateTime,  
                s.AuditAction,  
                s.NameID,  
                s.ClaimNo,  
                s.Num,  
                s.Surname,  
                s.Firstname,  
                s.Title,  
                s.DOB,  
                s.AddressStreet,  
                s.AddressSuburb,  
                s.AddressState,  
                s.AddressCountry,  
                s.AddressPostCode ,  
                s.HomePhone,  
                s.WorkPhone,  
                s.Fax,  
                s.Email,  
                s.isDirectCredit,  
                s.AccountNo,  
                s.AccountName,  
                s.BSB,  
                s.isPrimary,  
                s.isThirdParty,  
                s.isForeign,  
                s.ProviderID,  
                s.BusinessName ,  
                s.isEmailOK,  
                s.PaymentMethodID,  
                s.EMC,  
                s.ITC,  
                s.ITCPCT,  
                s.isGST,  
                s.GSTPercentage,  
                s.GoodsSupplier,  
                s.ServiceProvider,  
                s.SupplyBy,  
                s.EncryptAccount ,  
                s.EncryptBSB,  
                s.isPayer,  
                s.BankName,  
                s.AuditDateTimeUTC,  
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
            @SourceInfo = 'clmAuditName data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
GO
