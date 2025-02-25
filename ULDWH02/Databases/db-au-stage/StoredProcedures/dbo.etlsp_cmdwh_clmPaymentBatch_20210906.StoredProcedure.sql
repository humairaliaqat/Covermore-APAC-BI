USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmPaymentBatch_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_clmPaymentBatch_20210906]  
as  
begin  
/*  
    20140805, LS,   T12242 Global Claim  
                    use batch logging  
                    merge etlsp_cmdwh_clmAudit & etlsp_cmdwh_clmChqRunext  
    20140918, LS,   T13338 Claim UTC  
    20141111, LS,   T14092 Claims.Net Global  
                    add new UK data set  
                    enlarge bank name  
    20150417, LS,   F24015, bring in cheque wordings  
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
  
  
    if object_id('[db-au-cmdwh].dbo.clmPaymentBatch') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmPaymentBatch  
        (  
            [BIRowID] int not null identity(1,1),  
            [CountryKey] varchar(2) not null,  
            [PaymentBatchKey] varchar(40) null,  
            [ClaimKey] varchar(40) null,  
            [NameKey] varchar(40) null,  
            [PaymentBatchID] int null,  
            [ClaimNo] int null,  
            [PaymentID] int null,  
            [PayeeID] int null,  
            [AddresseeID] int null,  
            [AccountID] int null,  
            [BatchNo] int null,  
            [BatchStatus] varchar(4) null,  
            [ChequeNo] bigint null,  
            [isDeleted] bit null,  
            [isSullied] bit null,  
            [Pseudo] int null,  
            [StartClaimNo] int null,  
            [EndClaimNo] int null,  
            [StartAccountingPeriod] datetime null,  
            [EndAccountingPeriod] datetime null,  
            [PaymentDate] datetime null,  
            [PaymentModifiedDate] datetime null,  
            [PaymentMethod] varchar(4) null,  
            [PaymentStatus] varchar(4) null,  
            [CurrencyCode] varchar(4) null,  
            [ForeignExchangeRate] float null,  
            [BillAmount] money null,  
            [AUDAmount] money null,  
            [Excess] money null,  
            [DepreciationValue] money null,  
            [Other] money null,  
            [GST] money null,  
            [ITCAdjustment] money null,  
            [TotalValue] money null,  
            [AccountNo] varchar(20) null,  
            [AccountName] varchar(100) null,  
            [BankName] varchar(50) null,  
            [BSB] varchar(15) null,  
            [OfficerID] int null,  
            [OfficerName] nvarchar(150) null,  
            [isAuthorised] bit null,  
            [AuthorisedValue] varchar(20) null,  
            [AuthorisedDate] datetime null,  
            [AuthorisedOfficerID] int null,  
            [AuthorisedOfficerName] nvarchar(150) null,  
            [SecondaryAuthorisedDate] datetime null,  
            [SecondaryAuthorisedOfficerID] int null,  
            [SecondaryAuthorisedOfficerName] nvarchar(150) null,  
            [PaymentModifiedDateTimeUTC] datetime null,  
            [AuthorisedDateTimeUTC] datetime null,  
            [SecondaryAuthorisedDateTimeUTC] datetime null,  
            [ChequeWording] nvarchar(255) null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null  
        )  
  
        create clustered index idx_clmPaymentBatch_BIRowID on [db-au-cmdwh].dbo.clmPaymentBatch(BIRowID)  
        create nonclustered index idx_clmPaymentBatch_PaymentBatchKey on [db-au-cmdwh].dbo.clmPaymentBatch(PaymentBatchKey,ClaimKey,PaymentID) include(BatchStatus,BatchNo)  
        create nonclustered index idx_clmPaymentBatch_ClaimKey on [db-au-cmdwh].dbo.clmPaymentBatch(ClaimKey,BatchNo,PaymentID) include(NameKey,BatchStatus,ChequeNo,StartAccountingPeriod,EndAccountingPeriod,AuthorisedDate,AuthorisedOfficerName,SecondaryAuthorisedOfficerName)  
        create nonclustered index idx_clmPaymentBatch_BatchNo on [db-au-cmdwh].dbo.clmPaymentBatch(BatchNo,PaymentID,ClaimKey) include(NameKey,BatchStatus,ChequeNo,StartAccountingPeriod,EndAccountingPeriod,AuthorisedDate,AuthorisedOfficerName,SecondaryAuthorisedOfficerName)  
        create nonclustered index idx_clmPaymentBatch_PaymentModifiedDate on [db-au-cmdwh].dbo.clmPaymentBatch(PaymentModifiedDate) include(PaymentMethod,BatchStatus,PaymentStatus,isDeleted,NameKey,ClaimKey,PaymentID,BIRowID)  
  
    end  
  
    if object_id('etl_clmPaymentBatch') is not null  
        drop table etl_clmPaymentBatch  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        CHADDRESSEE_ID AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        CHSTATUS BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        CHSTARTCLAIMNO StartClaimNo,  
        CHENDCLAIMNO EndClaimNo,  
        CHSTARTACTPER StartAccountingPeriod,  
        CHENDACTPER EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        CHPAYSTATUS PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        CHITCADJ ITCAdjustment,  
        CHVALUE TotalValue,  
        CHACCT AccountNo,  
        CHACCTNAME AccountName,  
        CHBSB BSB,  
        KPBANKNAME BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        dbo.xfn_ConvertUTCtoLocal(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT, dk.TimeZone) AuthorisedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT2, dk.TimeZone) SecondaryAuthorisedDate,  
        CHMODIFY_DT PaymentModifiedDateTimeUTC,  
        CHRANDCHKDDT AuthorisedDateTimeUTC,  
        CHRANDCHKDDT2 SecondaryAuthorisedDateTimeUTC,  
        CHRANDCHK isAuthorised,  
        CHRANDCHKVAL AuthorisedValue,  
        CHRANDCHKUSER AuthorisedOfficerID,  
        AuthorisedOfficerName,  
        CHRANDCHKUSER2 SecondaryAuthorisedOfficerID,  
        SecondaryAuthorisedOfficerName,  
        ChequeWording  
    into etl_clmPaymentBatch  
    from  
        claims_CHQRUNEXT_au t  
        cross apply dbo.fn_GetDomainKeys(t.KLDOMAINID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1  
                s.KSNAME AuthorisedOfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHRANDCHKUSER  
        ) a  
        outer apply  
        (  
            select top 1  
                s.KSNAME SecondaryAuthorisedOfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHRANDCHKDDT2  
        ) sa  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_au cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
      union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        CHADDRESSEE_ID AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        CHSTATUS BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        CHSTARTCLAIMNO StartClaimNo,  
        CHENDCLAIMNO EndClaimNo,  
        CHSTARTACTPER StartAccountingPeriod,  
        CHENDACTPER EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        CHPAYSTATUS PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        CHITCADJ ITCAdjustment,  
        CHVALUE TotalValue,  
        CHACCT AccountNo,  
        CHACCTNAME AccountName,  
        CHBSB BSB,  
        KPBANKNAME BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        dbo.xfn_ConvertUTCtoLocal(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT, dk.TimeZone) AuthorisedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT2, dk.TimeZone) SecondaryAuthorisedDate,  
        CHMODIFY_DT PaymentModifiedDateTimeUTC,  
        CHRANDCHKDDT AuthorisedDateTimeUTC,  
        CHRANDCHKDDT2 SecondaryAuthorisedDateTimeUTC,  
        CHRANDCHK isAuthorised,  
        CHRANDCHKVAL AuthorisedValue,  
        CHRANDCHKUSER AuthorisedOfficerID,  
        AuthorisedOfficerName,  
        CHRANDCHKUSER2 SecondaryAuthorisedOfficerID,  
        SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_klaudit_au t  
        cross apply dbo.fn_GetDomainKeys(t.KLDOMAINID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1  
                s.KSNAME AuthorisedOfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHRANDCHKUSER  
        ) a  
        outer apply  
        (  
            select top 1  
                s.KSNAME SecondaryAuthorisedOfficerName  
            from  
                claims_KLSECURITY_au s  
            where  
                s.KS_ID = t.CHRANDCHKDDT2  
        ) sa  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_au cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        CHADDRESSEE_ID AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        CHSTATUS BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        CHSTARTCLAIMNO StartClaimNo,  
        CHENDCLAIMNO EndClaimNo,  
        CHSTARTACTPER StartAccountingPeriod,  
        CHENDACTPER EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        CHPAYSTATUS PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        CHITCADJ ITCAdjustment,  
        CHVALUE TotalValue,  
        CHACCT AccountNo,  
        CHACCTNAME AccountName,  
        CHBSB BSB,  
        KPBANKNAME BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        dbo.xfn_ConvertUTCtoLocal(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT, dk.TimeZone) AuthorisedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT2, dk.TimeZone) SecondaryAuthorisedDate,  
        CHMODIFY_DT PaymentModifiedDateTimeUTC,  
        CHRANDCHKDDT AuthorisedDateTimeUTC,  
        CHRANDCHKDDT2 SecondaryAuthorisedDateTimeUTC,  
        CHRANDCHK isAuthorised,  
        CHRANDCHKVAL AuthorisedValue,  
        CHRANDCHKUSER AuthorisedOfficerID,  
        AuthorisedOfficerName,  
        CHRANDCHKUSER2 SecondaryAuthorisedOfficerID,  
        SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_CHQRUNEXT_uk2 t  
        cross apply dbo.fn_GetDomainKeys(t.KLDOMAINID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1  
                s.KSNAME AuthorisedOfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHRANDCHKUSER  
        ) a  
        outer apply  
        (  
            select top 1  
                s.KSNAME SecondaryAuthorisedOfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHRANDCHKDDT2  
        ) sa  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_uk2 cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        CHADDRESSEE_ID AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        CHSTATUS BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        CHSTARTCLAIMNO StartClaimNo,  
        CHENDCLAIMNO EndClaimNo,  
        CHSTARTACTPER StartAccountingPeriod,  
        CHENDACTPER EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        CHPAYSTATUS PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        CHITCADJ ITCAdjustment,  
        CHVALUE TotalValue,  
        CHACCT AccountNo,  
        CHACCTNAME AccountName,  
        CHBSB BSB,  
        KPBANKNAME BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        dbo.xfn_ConvertUTCtoLocal(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT, dk.TimeZone) AuthorisedDate,  
        dbo.xfn_ConvertUTCtoLocal(CHRANDCHKDDT2, dk.TimeZone) SecondaryAuthorisedDate,  
        CHMODIFY_DT PaymentModifiedDateTimeUTC,  
        CHRANDCHKDDT AuthorisedDateTimeUTC,  
        CHRANDCHKDDT2 SecondaryAuthorisedDateTimeUTC,  
        CHRANDCHK isAuthorised,  
        CHRANDCHKVAL AuthorisedValue,  
        CHRANDCHKUSER AuthorisedOfficerID,  
        AuthorisedOfficerName,  
        CHRANDCHKUSER2 SecondaryAuthorisedOfficerID,  
        SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_KLAUDIT_uk2 t  
        cross apply dbo.fn_GetDomainKeys(t.KLDOMAINID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1  
                s.KSNAME AuthorisedOfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHRANDCHKUSER  
        ) a  
        outer apply  
        (  
            select top 1  
                s.KSNAME SecondaryAuthorisedOfficerName  
            from  
                claims_KLSECURITY_uk2 s  
            where  
                s.KS_ID = t.CHRANDCHKDDT2  
        ) sa  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_uk2 cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        null AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        null BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        null StartClaimNo,  
        null EndClaimNo,  
        null StartAccountingPeriod,  
        null EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        null PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        0 ITCAdjustment,  
        CHVALUE TotalValue,  
        null AccountNo,  
        null AccountName,  
        null BSB,  
        null BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        CHMODIFY_DT PaymentModifiedDate,  
        null AuthorisedDate,  
        null SecondaryAuthorisedDate,  
        dbo.xfn_ConvertLocaltoUTC(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDateTimeUTC,  
        null AuthorisedDateTimeUTC,  
        null SecondaryAuthorisedDateTimeUTC,  
        null isAuthorised,  
        null AuthorisedValue,  
        null AuthorisedOfficerID,  
        null AuthorisedOfficerName,  
        null SecondaryAuthorisedOfficerID,  
        null SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_klaudit_nz t  
        cross apply  
        (  
            select  
                'NZ' CountryKey,  
                'New Zealand Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_nz s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_nz cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        null AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        null BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        null StartClaimNo,  
        null EndClaimNo,  
        null StartAccountingPeriod,  
        null EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        null PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        0 ITCAdjustment,  
        CHVALUE TotalValue,  
        null AccountNo,  
        null AccountName,  
        null BSB,  
        null BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        CHMODIFY_DT PaymentModifiedDate,  
        null AuthorisedDate,  
        null SecondaryAuthorisedDate,  
        dbo.xfn_ConvertLocaltoUTC(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDateTimeUTC,  
        null AuthorisedDateTimeUTC,  
        null SecondaryAuthorisedDateTimeUTC,  
        null isAuthorised,  
        null AuthorisedValue,  
        null AuthorisedOfficerID,  
        null AuthorisedOfficerName,  
        null SecondaryAuthorisedOfficerID,  
        null SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_CHQRUNEXT_nz t  
        cross apply  
        (  
            select  
                'NZ' CountryKey,  
                'New Zealand Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_nz s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_nz cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        null AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        null BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        null StartClaimNo,  
        null EndClaimNo,  
        null StartAccountingPeriod,  
        null EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        null PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        0 ITCAdjustment,  
        CHVALUE TotalValue,  
        null AccountNo,  
        null AccountName,  
        null BSB,  
        null BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        CHMODIFY_DT PaymentModifiedDate,  
        null AuthorisedDate,  
        null SecondaryAuthorisedDate,  
        dbo.xfn_ConvertLocaltoUTC(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDateTimeUTC,  
        null AuthorisedDateTimeUTC,  
        null SecondaryAuthorisedDateTimeUTC,  
        null isAuthorised,  
        null AuthorisedValue,  
        null AuthorisedOfficerID,  
        null AuthorisedOfficerName,  
        null SecondaryAuthorisedOfficerID,  
        null SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_klaudit_uk t  
        cross apply  
        (  
            select  
                'UK' CountryKey,  
                'GMT Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_uk s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_uk cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    union  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, CH_ID) PaymentBatchKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, CHCLAIM) + '-' + convert(varchar, CHPAYEE_ID) NameKey,  
        CH_ID PaymentBatchID,  
        CHCLAIM ClaimNo,  
        CHPAYID PaymentID,  
        CHPAYEE_ID PayeeID,  
        null AddresseeID,  
        CHACCOUNT_ID AccountID,  
        CHBATCH BatchNo,  
        null BatchStatus,  
        CHCHQNO ChequeNo,  
        CHDEL isDeleted,  
        CHSULLIED isSullied,  
        CHPSEUDO Pseudo,  
        null StartClaimNo,  
        null EndClaimNo,  
        null StartAccountingPeriod,  
        null EndAccountingPeriod,  
        CHPAYDATE PaymentDate,  
        CHPAYMETHOD PaymentMethod,  
        null PaymentStatus,  
        CHCURR CurrencyCode,  
        CHRATE ForeignExchangeRate,  
        CHBILLAMT BillAmount,  
        CHAUD AUDAmount,  
        CHEXCESS Excess,  
        CHDEPV DepreciationValue,  
        CHOTHER Other,  
        CHGST GST,  
        0 ITCAdjustment,  
        CHVALUE TotalValue,  
        null AccountNo,  
        null AccountName,  
        null BSB,  
        null BankName,  
        CHOFFICER_ID OfficerID,  
        OfficerName,  
        CHMODIFY_DT PaymentModifiedDate,  
        null AuthorisedDate,  
        null SecondaryAuthorisedDate,  
        dbo.xfn_ConvertLocaltoUTC(CHMODIFY_DT, dk.TimeZone) PaymentModifiedDateTimeUTC,  
        null AuthorisedDateTimeUTC,  
        null SecondaryAuthorisedDateTimeUTC,  
        null isAuthorised,  
        null AuthorisedValue,  
        null AuthorisedOfficerID,  
        null AuthorisedOfficerName,  
        null SecondaryAuthorisedOfficerID,  
        null SecondaryAuthorisedOfficerName,  
        ChequeWording  
    from  
        claims_CHQRUNEXT_uk t  
        cross apply  
        (  
            select  
                'UK' CountryKey,  
                'GMT Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                s.KSNAME OfficerName  
            from  
                claims_KLSECURITY_uk s  
            where  
                s.KS_ID = t.CHOFFICER_ID  
        ) o  
        outer apply  
        (  
            select top 1   
                cw.chqWORDINGS ChequeWording  
            from  
                claims_chqWording_uk cw  
            where  
                cw.chqBATCH = t.CHBATCH and  
                cw.chqPAYID = t.CHPAYID  
        ) cw  
  
    set @sourcecount = @@rowcount  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmPaymentBatch with(tablock) t  
        using etl_clmPaymentBatch s on  
            s.PaymentBatchKey = t.PaymentBatchKey and  
            s.ClaimKey = t.ClaimKey and  
            s.PaymentID = t.PaymentID  
  
        when matched then  
  
            update  
            set  
                PayeeID = s.PayeeID,  
                AddresseeID = s.AddresseeID,  
                AccountID = s.AccountID,  
        BatchNo = s.BatchNo,  
                BatchStatus = s.BatchStatus,  
                ChequeNo = s.ChequeNo,  
                isDeleted = s.isDeleted,  
                isSullied = s.isSullied,  
                Pseudo = s.Pseudo,  
                StartClaimNo = s.StartClaimNo,  
                EndClaimNo = s.EndClaimNo,  
                StartAccountingPeriod = s.StartAccountingPeriod,  
                EndAccountingPeriod = s.EndAccountingPeriod,  
                PaymentDate = s.PaymentDate,  
                PaymentModifiedDate = s.PaymentModifiedDate,  
                PaymentMethod = s.PaymentMethod,  
                PaymentStatus = s.PaymentStatus,  
                CurrencyCode = s.CurrencyCode,  
                ForeignExchangeRate = s.ForeignExchangeRate,  
                BillAmount = s.BillAmount,  
                AUDAmount = s.AUDAmount,  
                Excess = s.Excess,  
                DepreciationValue = s.DepreciationValue,  
                Other = s.Other,  
                GST = s.GST,  
                ITCAdjustment = s.ITCAdjustment,  
                TotalValue = s.TotalValue,  
                AccountNo = s.AccountNo,  
                AccountName = s.AccountName,  
                BSB = s.BSB,  
                BankName = s.BankName,  
                OfficerID = s.OfficerID,  
                OfficerName = s.OfficerName,  
                isAuthorised = s.isAuthorised,  
                AuthorisedValue = s.AuthorisedValue,  
                AuthorisedDate = s.AuthorisedDate,  
                AuthorisedOfficerID = s.AuthorisedOfficerID,  
                AuthorisedOfficerName = s.AuthorisedOfficerName,  
                SecondaryAuthorisedDate = s.SecondaryAuthorisedDate,  
                SecondaryAuthorisedOfficerID = s.SecondaryAuthorisedOfficerID,  
                SecondaryAuthorisedOfficerName = s.SecondaryAuthorisedOfficerName,  
                PaymentModifiedDateTimeUTC = s.PaymentModifiedDateTimeUTC,  
                AuthorisedDateTimeUTC = s.AuthorisedDateTimeUTC,  
                SecondaryAuthorisedDateTimeUTC = s.SecondaryAuthorisedDateTimeUTC,  
                ChequeWording = s.ChequeWording,  
                UpdateBatchID = @batchid  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                PaymentBatchKey,  
                ClaimKey,  
                NameKey,  
                PaymentBatchID,  
                ClaimNo,  
                PaymentID,  
                PayeeID,  
                AddresseeID,  
                AccountID,  
                BatchNo,  
                BatchStatus,  
                ChequeNo,  
                isDeleted,  
                isSullied,  
                Pseudo,  
                StartClaimNo,  
                EndClaimNo,  
                StartAccountingPeriod,  
                EndAccountingPeriod,  
                PaymentDate,  
                PaymentModifiedDate,  
                PaymentMethod,  
                PaymentStatus,  
                CurrencyCode,  
                ForeignExchangeRate,  
                BillAmount,  
                AUDAmount,  
                Excess,  
                DepreciationValue,  
                Other,  
                GST,  
                ITCAdjustment,  
                TotalValue,  
                AccountNo,  
                AccountName,  
                BSB,  
                BankName,  
                OfficerID,  
                OfficerName,  
                isAuthorised,  
                AuthorisedValue,  
                AuthorisedDate,  
                AuthorisedOfficerID,  
                AuthorisedOfficerName,  
                SecondaryAuthorisedDate,  
                SecondaryAuthorisedOfficerID,  
                SecondaryAuthorisedOfficerName,  
                PaymentModifiedDateTimeUTC,  
                AuthorisedDateTimeUTC,  
                SecondaryAuthorisedDateTimeUTC,  
                ChequeWording,  
                CreateBatchID  
            )  
            values  
        (  
                s.CountryKey,  
                s.PaymentBatchKey,  
                s.ClaimKey,  
                s.NameKey,  
                s.PaymentBatchID,  
                s.ClaimNo,  
                s.PaymentID,  
                s.PayeeID,  
                s.AddresseeID,  
                s.AccountID,  
                s.BatchNo,  
                s.BatchStatus,  
                s.ChequeNo,  
                s.isDeleted,  
                s.isSullied,  
                s.Pseudo,  
                s.StartClaimNo,  
                s.EndClaimNo,  
                s.StartAccountingPeriod,  
                s.EndAccountingPeriod,  
                s.PaymentDate,  
                s.PaymentModifiedDate,  
                s.PaymentMethod,  
                s.PaymentStatus,  
                s.CurrencyCode,  
                s.ForeignExchangeRate,  
                s.BillAmount,  
                s.AUDAmount,  
                s.Excess,  
                s.DepreciationValue,  
                s.Other,  
                s.GST,  
                s.ITCAdjustment,  
                s.TotalValue,  
                s.AccountNo,  
                s.AccountName,  
                s.BSB,  
                s.BankName,  
                s.OfficerID,  
                s.OfficerName,  
                s.isAuthorised,  
                s.AuthorisedValue,  
                s.AuthorisedDate,  
                s.AuthorisedOfficerID,  
                s.AuthorisedOfficerName,  
                s.SecondaryAuthorisedDate,  
                s.SecondaryAuthorisedOfficerID,  
                s.SecondaryAuthorisedOfficerName,  
                s.PaymentModifiedDateTimeUTC,  
                s.AuthorisedDateTimeUTC,  
                s.SecondaryAuthorisedDateTimeUTC,  
                s.ChequeWording,  
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
            @SourceInfo = 'clmPaymentBatch data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
  
end  
GO
