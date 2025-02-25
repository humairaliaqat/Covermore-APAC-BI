USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmOnlineClaim]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_clmOnlineClaim]  
as  
begin  
/*  
    20160617, LL, create  
    20190522, LL, add claimant information
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
  
    if object_id('[db-au-cmdwh].dbo.clmOnlineClaim') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmOnlineClaim  
        (  
            BIRowID bigint identity(1,1) not null,  
            CountryKey varchar(2) not null,  
            ClaimKey varchar(40),  
            OnlineClaimKey varchar(40) not null,  
            OnlineClaimID int not null,  
            ClaimNo int,  
            PrimaryClaimantID int,  
            ClaimCauseID int,  
            DeclarationID int,  
            LatestStep int,  
            PreferredContact nvarchar(50),  
            Email nvarchar(255),  
            Street nvarchar(255),  
            Suburb nvarchar(100),  
            Postcode nvarchar(50),  
            State nvarchar(100),  
            Country nvarchar(255),  
            Phone nvarchar(50),  
            WorkPhone nvarchar(50),  
            Fax varchar(50),  
            PreferredPayment nvarchar(50),  
            BankName nvarchar(50),  
            AccountName nvarchar(255),  
            AccountNumberEncrypt varbinary(256),  
            BSBEncrypt varbinary(256),  
            DateBooked date,  
            DateDeparted date,  
            DateReturned date,  
            hasPastClaim bit,  
            PastClaimDetail nvarchar(max),  
            hasCreditCard bit,  
            isPurchaseOnCard bit,  
            hasOtherSourceClaim bit,  
            OtherSourceClaimDetail nvarchar(max),  
            hasITC bit,  
            ITCRate numeric,  
            ABN varchar(50),  
            SelectedSections varchar(100),  
            isDeclared bit,  
            isSelfDeclared bit,  
            OnbehalfName nvarchar(255),  
            OnbehalfEmail nvarchar(255),  
            CreateDateTime datetime,  
            UpdateDateTime datetime,  
            UserID int,  
            AlphaCode nvarchar(20),  
            ConsultantName nvarchar(50),  
            UpdatedBy nvarchar(255),  
            MoreDocument bit,  
            DocumentDescription varchar(max),  
            --20190522, LL, add claimant information  
            PolicyNumber varchar(50),  
            FirstName nvarchar(100),  
            LastName nvarchar(100),  
            DOB date  
        )  
  
        create clustered index idx_clmOnlineClaim_BIRowID on [db-au-cmdwh].dbo.clmOnlineClaim(BIRowID)  
        create nonclustered index idx_clmOnlineClaim_ClaimKey on [db-au-cmdwh].dbo.clmOnlineClaim(ClaimKey) include(BIRowID,CreateDateTime,OnBehalfEmail,AlphaCode,COnsultantName)  
        create nonclustered index idx_clmOnlineClaim_ClaimNo on [db-au-cmdwh].dbo.clmOnlineClaim(ClaimNo) include(BIRowID)  
        create nonclustered index idx_clmOnlineClaim_OnlineClaimKey on [db-au-cmdwh].dbo.clmOnlineClaim(OnlineClaimKey)  
        create nonclustered index idx_clmOnlineClaim_CreateDate on [db-au-cmdwh].dbo.clmOnlineClaim(CreateDateTime)  
  
    end  
  
    if object_id('tempdb..#onlineclaims') is not null  
        drop table #onlineclaims  
  
    select --top 10000  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, oc.OnlineClaimID) OnlineClaimKey,  
        oc.OnlineClaimID,  
        oc.ClaimId ClaimNo,  
        oc.PrimaryClaimantID,  
        oc.ClaimCauseID,  
        oc.DeclarationID,  
        oc.LatestStep,  
        isnull(occ.PreferredContact, '') PreferredContact,  
        isnull(occ.Email, '') Email,  
        isnull(occ.Street, '') Street,  
        isnull(occ.Suburb, '') Suburb,  
        isnull(occ.Postcode, '') Postcode,  
        isnull(occ.State, '') State,  
        isnull(occ.Country, '') Country,  
        isnull(occ.Phone, '') Phone,  
        isnull(occ.WPhone, '') WorkPhone,  
        isnull(occ.Fax, '') Fax,  
        isnull(occ.PreferredPayment, '') PreferredPayment,  
        isnull(occ.BankName, '') BankName,  
        isnull(occ.AccountName, '') AccountName,  
        occ.AccountNumberEncrypt,  
        occ.BSBEncrypt,  
        occ.DateBooked,  
        occ.DateDeparted,  
        occ.DateReturned,  
        isnull(occ.hasPastClaim, 0) hasPastClaim,  
        isnull(occ.PastClaimDetail, '') PastClaimDetail,  
        isnull(occ.hasCreditCard, 0) hasCreditCard,  
        isnull(occ.isPurchaseOnCard, 0) isPurchaseOnCard,  
        isnull(occ.hasOtherSourceClaim, 0) hasOtherSourceClaim,  
        isnull(occ.OtherSourceClaimDetail, '') OtherSourceClaimDetail,  
        isnull(occ.hasITC, 0) hasITC,  
        isnull(occ.ITCRate, 0) ITCRate,  
        isnull(occ.ABN, '') ABN,  
        --occ.isHomeContentClaim,  
        --occ.hasHomeContentInsurance,  
        --occ.HomeContentInsurer,  
        isnull(ocs.SelectedSections, '') SelectedSections,  
        isnull(ocd.isDeclared, 0) isDeclared,  
        isnull(ocd.isSelfDeclared, 0) isSelfDeclared,  
        isnull(ocd.OnbehalfName, '') OnbehalfName,  
        isnull(ocd.OnbehalfEmail, '') OnbehalfEmail,  
        dbo.xfn_ConvertUTCtoLocal(oc.CreatedOn, dk.TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(oc.UpdatedOn, dk.TimeZone) UpdateDateTime,  
        oc.UserID,  
        oc.AlphaCode,  
        oc.ConsultantName,  
        isnull(oc.LastUpdatedBy, '') UpdatedBy,  
        oc.IsMoreDocument,  
        oc.DocumentDescription,  
        --20190522, LL, add claimant information  
        ocu.PolicyNumber,  
        ocu.FirstName,  
        ocu.LastName,  
        ocu.DOB  
    into #onlineclaims  
    from  
        claims_tblOnlineClaims_au oc   
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'AU') dk  
        --20190522, LL, add claimant information  
        outer apply  
        (  
            select top 1   
                u.PolicyNumber,  
                u.FirstName,  
                u.LastName,  
                u.DOB  
            from  
                claims_tblOnlineClaimUser_au u  
            where  
                u.UserId = oc.UserId  
        ) ocu  
        --all other tables have 1 to 1 relation  
        --these top 1 just to make sure no duplication in case some changes occur on source system  
        outer apply  
        (  
            select top 1  
                PreferredContact,  
                Email,  
                Street,  
                Suburb,  
                Postcode,  
                State,  
                Country,  
                Phone,  
                WPhone,  
                Fax,  
                PreferredPayment,  
                BankName,  
                AccountName,  
                AccountNumberEncrypt,  
                BSBEncrypt,  
                DateBooked,  
                DateDeparted,  
                DateReturned,  
                bitPastClaim hasPastClaim,  
                occpc.Details PastClaimDetail,  
                bitHasCreditCard hasCreditCard,  
                bitPurchaseOnCard isPurchaseOnCard,  
                bitOtherSourceClaim hasOtherSourceClaim,  
                occd.Details OtherSourceClaimDetail,  
                bititc hasITC,  
                ITCRate,  
                ABN  
                --,  
                --bitHCClaim isHomeContentClaim,  
                --bitHCInsurance hasHomeContentInsurance,  
                --HCInsurancer HomeContentInsurer  
            from  
        claims_tblOnlineClaimants_au occ  
                left join claims_tblOnlineClaimantOtherSourceDetails_au occd on  
                    occd.ClaimantId = occ.ClaimantId  
                left join claims_tblOnlineClaimantPastClaimDetails_au occpc on  
                    occpc.ClaimantId = occ.ClaimantId  
            where  
                occ.OnlineClaimId = oc.OnlineClaimId  
            order by  
                occ.ClaimantId  
        ) occ  
        outer apply  
        (  
            select top 1   
                SelectedSections  
            from  
                claims_tblOnlineClaimEventSections_au ocs  
            where  
                ocs.CauseId = oc.ClaimCauseId  
        ) ocs  
        outer apply  
        (  
            select top 1  
                try_convert(bit, dcl.value('Declared[1]', 'varchar(max)')) isDeclared,  
                try_convert(bit, dcl.value('SelfDeclared[1]', 'varchar(max)')) isSelfDeclared,  
                try_convert(nvarchar(255), dcl.value('OnbehalfName[1]', 'nvarchar(max)')) OnbehalfName,  
                try_convert(nvarchar(255), dcl.value('OnbehalfEmail[1]', 'varchar(max)')) OnbehalfEmail  
                --,  
                --DeclarationXML  
            from  
                claims_tblOnlineClaimDeclarations_au ocd  
                cross apply  
                (  
                    select  
                        try_convert(xml, ocd.details) DeclarationXML  
                ) dx  
                cross apply DeclarationXML.nodes('/Declaration') as dcl(dcl)  
            where  
                ocd.DeclarationId = oc.DeclarationId  
        ) ocd  
  
    union all  
  
    select --top 1000  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, oc.ClaimId) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, oc.OnlineClaimID) OnlineClaimKey,  
        oc.OnlineClaimID,  
        oc.ClaimId ClaimNo,  
        oc.PrimaryClaimantID,  
        oc.ClaimCauseID,  
        oc.DeclarationID,  
        oc.LatestStep,  
        isnull(occ.PreferredContact, '') PreferredContact,  
        isnull(occ.Email, '') Email,  
        isnull(occ.Street, '') Street,  
        isnull(occ.Suburb, '') Suburb,  
        isnull(occ.Postcode, '') Postcode,  
        isnull(occ.State, '') State,  
        isnull(occ.Country, '') Country,  
        isnull(occ.Phone, '') Phone,  
        isnull(occ.WPhone, '') WorkPhone,  
        isnull(occ.Fax, '') Fax,  
        isnull(occ.PreferredPayment, '') PreferredPayment,  
        isnull(occ.BankName, '') BankName,  
        isnull(occ.AccountName, '') AccountName,  
        occ.AccountNumberEncrypt,  
        occ.BSBEncrypt,  
        occ.DateBooked,  
        occ.DateDeparted,  
        occ.DateReturned,  
        isnull(occ.hasPastClaim, 0) hasPastClaim,  
        isnull(occ.PastClaimDetail, '') PastClaimDetail,  
        isnull(occ.hasCreditCard, 0) hasCreditCard,  
        isnull(occ.isPurchaseOnCard, 0) isPurchaseOnCard,  
        isnull(occ.hasOtherSourceClaim, 0) hasOtherSourceClaim,  
        isnull(occ.OtherSourceClaimDetail, '') OtherSourceClaimDetail,  
        isnull(occ.hasITC, 0) hasITC,  
        isnull(occ.ITCRate, 0) ITCRate,  
        isnull(occ.ABN, '') ABN,  
        --occ.isHomeContentClaim,  
        --occ.hasHomeContentInsurance,  
        --occ.HomeContentInsurer,  
        isnull(ocs.SelectedSections, '') SelectedSections,  
        isnull(ocd.isDeclared, 0) isDeclared,  
        isnull(ocd.isSelfDeclared, 0) isSelfDeclared,  
        isnull(ocd.OnbehalfName, '') OnbehalfName,  
        isnull(ocd.OnbehalfEmail, '') OnbehalfEmail,  
        dbo.xfn_ConvertUTCtoLocal(oc.CreatedOn, dk.TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(oc.UpdatedOn, dk.TimeZone) UpdateDateTime,  
        oc.UserID,  
        oc.AlphaCode,  
        oc.ConsultantName,  
        isnull(oc.LastUpdatedBy, '') UpdatedBy,  
        oc.IsMoreDocument,  
        oc.DocumentDescription,  
        --20190522, LL, add claimant information  
        ocu.PolicyNumber,  
        ocu.FirstName,  
        ocu.LastName,  
        ocu.DOB  
    from  
        claims_tblOnlineClaims_uk2 oc   
        cross apply dbo.fn_GetDomainKeys(oc.KLDOMAINID, 'CM', 'UK') dk  
        --20190522, LL, add claimant information  
        outer apply  
        (  
            select top 1   
                u.PolicyNumber,  
                u.FirstName,  
                u.LastName,  
                u.DOB  
            from  
                claims_tblOnlineClaimUser_uk2 u  
            where  
                u.UserId = oc.UserId  
        ) ocu  
        --all other tables have 1 to 1 relation  
        --these top 1 just to make sure no duplication in case some changes occur on source system  
        outer apply  
        (  
            select top 1  
                PreferredContact,  
                Email,  
                Street,  
                Suburb,  
                Postcode,  
                State,  
                Country,  
                Phone,  
                WPhone,  
                Fax,  
                PreferredPayment,  
                BankName,  
                AccountName,  
                AccountNumberEncrypt,  
                BSBEncrypt,  
                DateBooked,  
                DateDeparted,  
                DateReturned,  
                bitPastClaim hasPastClaim,  
                occpc.Details PastClaimDetail,  
                bitHasCreditCard hasCreditCard,  
                bitPurchaseOnCard isPurchaseOnCard,  
                bitOtherSourceClaim hasOtherSourceClaim,  
                occd.Details OtherSourceClaimDetail,  
                bititc hasITC,  
                ITCRate,  
                ABN  
                --,  
                --bitHCClaim isHomeContentClaim,  
                --bitHCInsurance hasHomeContentInsurance,  
                --HCInsurancer HomeContentInsurer  
            from  
                claims_tblOnlineClaimants_uk2 occ  
                left join claims_tblOnlineClaimantOtherSourceDetails_uk2 occd on  
                    occd.ClaimantId = occ.ClaimantId  
                left join claims_tblOnlineClaimantPastClaimDetails_uk2 occpc on  
                    occpc.ClaimantId = occ.ClaimantId  
            where  
                occ.OnlineClaimId = oc.OnlineClaimId  
            order by  
                occ.ClaimantId  
        ) occ  
        outer apply  
        (  
            select top 1   
                SelectedSections  
            from  
                claims_tblOnlineClaimEventSections_uk2 ocs  
            where  
                ocs.CauseId = oc.ClaimCauseId  
        ) ocs  
        outer apply  
        (  
            select top 1  
                try_convert(bit, dcl.value('Declared[1]', 'varchar(max)')) isDeclared,  
                try_convert(bit, dcl.value('SelfDeclared[1]', 'varchar(max)')) isSelfDeclared,  
                try_convert(nvarchar(255), dcl.value('OnbehalfName[1]', 'nvarchar(max)')) OnbehalfName,  
                try_convert(nvarchar(255), dcl.value('OnbehalfEmail[1]', 'varchar(max)')) OnbehalfEmail  
                --,  
                --DeclarationXML  
            from  
                claims_tblOnlineClaimDeclarations_uk2 ocd  
                cross apply  
                (  
                    select  
                        try_convert(xml, ocd.details) DeclarationXML  
                ) dx  
                cross apply DeclarationXML.nodes('/Declaration') as dcl(dcl)  
            where  
                ocd.DeclarationId = oc.DeclarationId  
        ) ocd  
	where dk.CountryKey + '-' + convert(varchar, oc.ClaimId) not in
		(select dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey
		from    
        claims_klreg_uk2 c    
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk 
		where c.KLALPHA like 'BK%')		 ------adding condition to filter out BK.com data 

    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmOnlineClaim with(tablock) t  
        using #onlineclaims s on  
            s.OnlineClaimKey = t.OnlineClaimKey  
  
        when matched then  
  
            update  
            set  
                CountryKey = s.CountryKey,  
                ClaimKey = s.ClaimKey,  
                OnlineClaimID = s.OnlineClaimID,  
                ClaimNo = s.ClaimNo,  
                PrimaryClaimantID = s.PrimaryClaimantID,  
        ClaimCauseID = s.ClaimCauseID,  
                DeclarationID = s.DeclarationID,  
                LatestStep = s.LatestStep,  
                PreferredContact = s.PreferredContact,  
                Email = s.Email,  
                Street = s.Street,  
                Suburb = s.Suburb,  
                Postcode = s.Postcode,  
                State = s.State,  
                Country = s.Country,  
                Phone = s.Phone,  
                WorkPhone = s.WorkPhone,  
                Fax = s.Fax,  
                PreferredPayment = s.PreferredPayment,  
                BankName = s.BankName,  
                AccountName = s.AccountName,  
                AccountNumberEncrypt = s.AccountNumberEncrypt,  
                BSBEncrypt = s.BSBEncrypt,  
                DateBooked = s.DateBooked,  
                DateDeparted = s.DateDeparted,  
                DateReturned = s.DateReturned,  
                hasPastClaim = s.hasPastClaim,  
                PastClaimDetail = s.PastClaimDetail,  
                hasCreditCard = s.hasCreditCard,  
                isPurchaseOnCard = s.isPurchaseOnCard,  
                hasOtherSourceClaim = s.hasOtherSourceClaim,  
                OtherSourceClaimDetail = s.OtherSourceClaimDetail,  
                hasITC = s.hasITC,  
                ITCRate = s.ITCRate,  
                ABN = s.ABN,  
                SelectedSections = s.SelectedSections,  
                isDeclared = s.isDeclared,  
                isSelfDeclared = s.isSelfDeclared,  
                OnbehalfName = s.OnbehalfName,  
                OnbehalfEmail = s.OnbehalfEmail,  
                CreateDateTime = s.CreateDateTime,  
                UpdateDateTime = s.UpdateDateTime,  
                UserID = s.UserID,  
                AlphaCode = s.AlphaCode,  
                ConsultantName = s.ConsultantName,  
                MoreDocument = s.IsMoreDocument,  
                DocumentDescription = s.DocumentDescription,  
                UpdatedBy = s.UpdatedBy,  
                --20190522, LL, add claimant information  
                PolicyNumber = s.PolicyNumber,  
                FirstName = s.FirstName,  
                LastName = s.LastName,  
                DOB = s.DOB  
  
--select   
--    's.' + COLUMN_NAME + ','  
--from  
--    tempdb.INFORMATION_SCHEMA.COLUMNS  
--where  
--    TABLE_NAME like '#onlineclaims%'  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                ClaimKey,  
                OnlineClaimKey,  
                OnlineClaimID,  
                ClaimNo,  
                PrimaryClaimantID,  
                ClaimCauseID,  
                DeclarationID,  
                LatestStep,  
                PreferredContact,  
                Email,  
                Street,  
                Suburb,  
                Postcode,  
                State,  
                Country,  
                Phone,  
                WorkPhone,  
                Fax,  
                PreferredPayment,  
                BankName,  
                AccountName,  
                AccountNumberEncrypt,  
                BSBEncrypt,  
                DateBooked,  
                DateDeparted,  
                DateReturned,  
                hasPastClaim,  
                PastClaimDetail,  
                hasCreditCard,  
                isPurchaseOnCard,  
                hasOtherSourceClaim,  
                OtherSourceClaimDetail,  
                hasITC,  
                ITCRate,  
                ABN,  
                SelectedSections,  
                isDeclared,  
                isSelfDeclared,  
                OnbehalfName,  
                OnbehalfEmail,  
                CreateDateTime,  
                UpdateDateTime,  
                UserID,  
                AlphaCode,  
                ConsultantName,  
                MoreDocument,  
                DocumentDescription,  
                UpdatedBy,  
                --20190522, LL, add claimant information  
                PolicyNumber,  
      FirstName,  
                LastName,  
                DOB  
            )  
            values  
            (  
                s.CountryKey,  
                s.ClaimKey,  
                s.OnlineClaimKey,  
                s.OnlineClaimID,  
                s.ClaimNo,  
                s.PrimaryClaimantID,  
                s.ClaimCauseID,  
                s.DeclarationID,  
                s.LatestStep,  
                s.PreferredContact,  
                s.Email,  
                s.Street,  
                s.Suburb,  
                s.Postcode,  
                s.State,  
                s.Country,  
                s.Phone,  
                s.WorkPhone,  
                s.Fax,  
                s.PreferredPayment,  
                s.BankName,  
                s.AccountName,  
                s.AccountNumberEncrypt,  
                s.BSBEncrypt,  
                s.DateBooked,  
                s.DateDeparted,  
                s.DateReturned,  
                s.hasPastClaim,  
                s.PastClaimDetail,  
                s.hasCreditCard,  
                s.isPurchaseOnCard,  
                s.hasOtherSourceClaim,  
                s.OtherSourceClaimDetail,  
                s.hasITC,  
                s.ITCRate,  
                s.ABN,  
                s.SelectedSections,  
                s.isDeclared,  
                s.isSelfDeclared,  
                s.OnbehalfName,  
                s.OnbehalfEmail,  
                s.CreateDateTime,  
                s.UpdateDateTime,  
                s.UserID,  
                s.AlphaCode,  
                s.ConsultantName,  
                s.IsMoreDocument,  
                s.DocumentDescription,  
                s.UpdatedBy,  
                --20190522, LL, add claimant information  
                s.PolicyNumber,  
                s.FirstName,  
                s.LastName,  
                s.DOB  
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
            @SourceInfo = 'clmOnlineClaim data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
  
end  
  
GO
