USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmClaim_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
  
CREATE procedure [dbo].[etlsp_cmdwh_clmClaim_rollup]  
as  
begin  
/*  
    20140415, LS,   20728, Refactoring, change to incremental  
                    20632, add online alpha & online consultant  
    20140509, LS,   add sync table for clmClaimSummary  
    20140808, LS,   T12242 Global Claim  
                    use batch logging  
    20140918, LS,   T13338 Claim UTC  
    20141014, LS,   Duplicate policy number (reseeded penguin addons)  
    20141111, LS,   T14092 Claims.Net Global  
                    add new UK data set  
    20150506, LT,   Changed PolicyPlanCode length to varchar(50) from varchar(6)  
    20151001, LS,   add [or] condition to pickup policy transaction key where it's created after claim as long as it's having the same issue date  
    20160530, LS, changed GroupName length  
    20180206, LL,   casekey link  
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
  
    if object_id('[db-au-cmdwh].dbo.clmClaim') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.clmClaim  
        (  
            [CountryKey] varchar(2) not null,  
            [ClaimKey] varchar(40) not null,  
            [PolicyKey] varchar(55) null,  
            [AgencyKey] varchar(50) null,  
            [ClaimNo] int not null,  
            [CreatedBy] varchar(30) null,  
            [CreateDate] datetime null,  
            [OfficerName] varchar(30) null,  
            [StatusCode] varchar(4) null,  
            [StatusDesc] varchar(50) null,  
            [ReceivedDate] datetime null,  
            [Authorisation] varchar(1) null,  
            [ActionDate] datetime null,  
            [ActionCode] int null,  
            [FinalisedDate] datetime null,  
            [ArchiveBox] varchar(20) null,  
            [PolicyID] int null,  
            [PolicyNo] varchar(50) null,  
            [PolicyProduct] varchar(4) null,  
            [AgencyCode] varchar(7) null,  
            [PolicyPlanCode] varchar(50) null,  
            [IntDom] varchar(3) null,  
            [Excess] money null,  
            [SingleFamily] varchar(1) null,  
            [PolicyIssuedDate] datetime null,  
            [AccountingDate] datetime null,  
            [DepartureDate] datetime null,  
            [ArrivalDate] datetime null,  
            [NumberOfDays] int null,  
            [ITCPremium] float null,  
            [EMCApprovalNo] varchar(15) null,  
            [GroupPolicy] tinyint null,  
            [LuggageFlag] tinyint null,  
            [HRisk] tinyint null,  
            [CaseNo] varchar(14) null,  
            [Comment] ntext null,  
            [ClaimProduct] varchar(5) null,  
            [ClaimPlan] varchar(10) null,  
            [RecoveryType] tinyint null,  
            [RecoveryOutcome] tinyint null,  
            [OnlineClaim] bit null,  
            [RecoveryTypeDesc] varchar(255) null,  
            [RecoveryOutcomeDesc] varchar(255) null,  
            [OnlineConsultant] varchar(50) null,  
            [OnlineAlpha] varchar(20) null,  
            [CultureCode] nvarchar(10) null,  
            [ClaimGroupCode] varchar(20) null,  
            [PolicyTransactionKey] varchar(41) null,  
            [OutletKey] varchar(41) null,  
            [DomainID] int null,  
            [BIRowID] int not null identity(1,1),  
            [CreateDateTimeUTC] datetime null,  
            [ReceivedDateTimeUTC] datetime null,  
            [ActionDateTimeUTC] datetime null,  
            [FinalisedDateTimeUTC] datetime null,  
            [CreateBatchID] int null,  
            [UpdateBatchID] int null,  
   [PolicyOffline] bit null,  
   [MasterPolicyNumber] varchar(20) null,  
   [GroupName] nvarchar(200) null,  
   [AgencyName] nvarchar(200) null,  
            FirstNilDate date,  
            [CaseKey] nvarchar(20) null  
        )  
  
        create clustered index idx_clmClaim_BIRowID on [db-au-cmdwh].dbo.clmClaim(BIRowID)  
        create nonclustered index idx_clmClaim_ReceivedDate on [db-au-cmdwh].dbo.clmClaim(ReceivedDate,CountryKey) include(CreateDate,FinalisedDate,ClaimKey,ClaimNo,PolicyNo,PolicyTransactionKey,AgencyCode,OutletKey)  
        create nonclustered index idx_clmClaim_CreateDate on [db-au-cmdwh].dbo.clmClaim(CreateDate,CountryKey) include(ReceivedDate,FinalisedDate,ClaimKey,ClaimNo,PolicyNo,PolicyTransactionKey,AgencyCode,OutletKey)  
        create nonclustered index idx_clmClaim_FinalisedDate on [db-au-cmdwh].dbo.clmClaim(FinalisedDate,CountryKey) include(ReceivedDate,CreateDate,ClaimKey,ClaimNo,PolicyNo,PolicyTransactionKey,AgencyCode,OutletKey)  
        create nonclustered index idx_clmClaim_PolicyIssueDate on [db-au-cmdwh].dbo.clmClaim(PolicyIssuedDate,CountryKey) include (ReceivedDate,CreateDate,ClaimKey,PolicyNo,ClaimNo,PolicyTransactionKey)  
        create nonclustered index idx_clmClaim_ClaimKey on [db-au-cmdwh].dbo.clmClaim(ClaimKey) include(CountryKey,ReceivedDate,CreateDate,FinalisedDate,ClaimNo,PolicyNo,PolicyTransactionKey,AgencyCode,OutletKey,FirstNilDate)  
        create nonclustered index idx_clmClaim_OutletKey on [db-au-cmdwh].dbo.clmClaim(OutletKey)  include(ClaimKey,CountryKey,ReceivedDate,CreateDate,FinalisedDate,ClaimNo,PolicyNo,PolicyTransactionKey,AgencyCode)  
        create nonclustered index idx_clmClaim_PolicyTransactionKey on [db-au-cmdwh].dbo.clmClaim(PolicyTransactionKey) include(ClaimKey,CountryKey,ReceivedDate,CreateDate,FinalisedDate,ClaimNo,PolicyNo,AgencyCode,OutletKey)  
        create nonclustered index idx_clmClaim_ClaimNo on [db-au-cmdwh].dbo.clmClaim(ClaimNo) include(ClaimKey,CountryKey)  
        create nonclustered index idx_clmClaim_AgencyKey on [db-au-cmdwh].dbo.clmClaim(AgencyKey) include(ClaimKey,CountryKey)  
        create nonclustered index idx_clmClaim_PolicyKey on [db-au-cmdwh].dbo.clmClaim(PolicyKey,CountryKey) include(ClaimKey,ClaimNo,CreateDate,ReceivedDate,PolicyNo)  
  
    end  
  
    if object_id('etl_claims') is not null  
        drop table etl_claims  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLPOLICY) collate database_default PolicyKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLALPHA) collate database_default AgencyKey,  
        (  
            select top 1  
                OutletKey  
            from  
                [db-au-cmdwh]..penOutlet o  
            where  
                o.OutletStatus = 'Current' and  
                o.CountryKey = dk.CountryKey and  
                o.AlphaCode = c.KLALPHA collate database_default  
        ) OutletKey,  
        (  
            select top 1  
                pt.PolicyTransactionKey  
            from  
                [db-au-cmdwh]..penPolicyTransSummary pt  
            where  
                pt.CountryKey = dk.CountryKey and  
                pt.PolicyNumber = convert(varchar, c.KLPOLICY) collate database_default and  
                (  
                    convert(date, pt.IssueDate) <= dbo.xfn_ConvertUTCtoLocal(c.KLCREATED, dk.TimeZone) or  
                    convert(date, pt.IssueDate) = convert(date, c.KLDISS)  
                )  
        ) PolicyTransactionKey,  
        c.KLCLAIM ClaimNo,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_klsecurity_au  
            where  
                KS_ID = c.KLCREATEDBY_ID  
        ) CreatedBy,  
        dbo.xfn_ConvertUTCtoLocal(c.KLCREATED, dk.TimeZone) CreateDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLRECEIVED, dk.TimeZone) ReceivedDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLACTIONDATE, dk.TimeZone) ActionDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLFINALDATE, dk.TimeZone) FinalisedDate,  
        c.KLCREATED CreateDateTimeUTC,  
        c.KLRECEIVED ReceivedDateTimeUTC,  
        c.KLACTIONDATE ActionDateTimeUTC,  
        c.KLFINALDATE FinalisedDateTimeUTC,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_klsecurity_au  
            where  
                KS_ID = c.KLOFFICER_ID  
        ) OfficerName,  
        cs.StatusCode,  
        cs.StatusDesc,  
        c.KLAUTH Authorisation,  
        c.KLACTION ActionCode,  
        c.KLARCBOX ArchiveBox,  
        c.KLPOL_ID PolicyID,  
        c.KLPOLICY PolicyNo,  
        c.KLPRODUCT PolicyProduct,  
        c.KLALPHA AgencyCode,  
        c.KLPLAN PolicyPlanCode,  
        c.KLINTDOM IntDom,  
        c.KLEXCESS Excess,  
        c.KLSF SingleFamily,  
        c.KLDISS PolicyIssuedDate,  
        c.KLACT AccountingDate,  
        c.KLDEP DepartureDate,  
        c.KLRET ArrivalDate,  
        c.KLDAYS NumberOfDays,  
        c.KLITCPREM ITCPremium,  
        convert(varchar(15), c.KLEMCAPPROV) EMCApprovalNo,  
        c.KLGROUPPOL GroupPolicy,  
        c.KLLUGG LuggageFlag,  
        c.KLHRISK HRisk,  
        c.KLCASE CaseNo,  
        c.KLCOMMENT Comment,  
        (  
            select top 1  
                KPPRODUCT  
            from  
                claims_klproducts_au  
            where  
                KPProd_ID = c.KLPROD_ID  
        ) ClaimProduct,  
        (  
            select top 1  
                KLPLANCODE  
            from  
                claims_klproductplan_au  
            where  
                KLPLAN_ID = c.KLPLAN_ID  
        ) ClaimPlan,  
        c.KLRECOVERY RecoveryType,  
        null RecoveryTypeDesc,  
        c.KLREC_OUTCOMEID RecoveryOutcome,  
        (  
            select top 1  
                KTDESC  
            from  
                claims_klstatus_au  
            where  
                KT_ID = c.KLREC_OUTCOMEID  
        ) RecoveryOutcomeDesc,  
        c.KLONLINE OnlineClaim,  
        OnlineConsultant,  
        OnlineAlpha,  
        c.KLGroupCode ClaimGroupCode,  
        c.CultureCode,  
        c.KLDOMAINID DomainID,  
  NULL KLPolicyOffline,  
  NULL KLMASTERPOLICYNUMBER,  
  NULL KLGroupName,  
  NULL KLAgencyName  
    into etl_claims  
    from  
        claims_klreg_au c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                AlphaCode OnlineAlpha,  
                ConsultantName OnlineConsultant  
            from  
                claims_tblOnlineClaims_au oc  
            where  
                oc.ClaimId = c.KLCLAIM  
            order by  
                oc.OnlineClaimId desc  
        ) oc  
        outer apply  
        (  
            select top 1  
                KTSTATUS StatusCode,  
                KTDESC StatusDesc  
            from  
                claims_klstatus_au  
            where  
                KT_ID = c.KLSTATUS_ID and  
                KTTABLE = 'KLREG'  
        ) cs  
  
    union all  
      
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLPOLICY) collate database_default PolicyKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLALPHA) collate database_default AgencyKey,  
        (  
            select top 1  
                OutletKey  
            from  
                [db-au-cmdwh]..penOutlet o  
            where  
                o.OutletStatus = 'Current' and  
                o.CountryKey = dk.CountryKey and  
                o.AlphaCode = c.KLALPHA collate database_default  
        ) OutletKey,  
        (  
            select top 1  
                pt.PolicyTransactionKey  
            from  
   [db-au-cmdwh]..penPolicyTransSummary pt  
            where  
                pt.CountryKey = dk.CountryKey and  
                pt.PolicyNumber = convert(varchar, c.KLPOLICY) collate database_default and  
                (  
                    convert(date, pt.IssueDate) <= dbo.xfn_ConvertUTCtoLocal(c.KLCREATED, dk.TimeZone) or  
                    convert(date, pt.IssueDate) = convert(date, c.KLDISS)  
                )  
        ) PolicyTransactionKey,  
        c.KLCLAIM ClaimNo,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_klsecurity_uk2  
            where  
                KS_ID = c.KLCREATEDBY_ID  
        ) CreatedBy,  
        dbo.xfn_ConvertUTCtoLocal(c.KLCREATED, dk.TimeZone) CreateDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLRECEIVED, dk.TimeZone) ReceivedDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLACTIONDATE, dk.TimeZone) ActionDate,  
        dbo.xfn_ConvertUTCtoLocal(c.KLFINALDATE, dk.TimeZone) FinalisedDate,  
        c.KLCREATED CreateDateTimeUTC,  
        c.KLRECEIVED ReceivedDateTimeUTC,  
        c.KLACTIONDATE ActionDateTimeUTC,  
        c.KLFINALDATE FinalisedDateTimeUTC,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_klsecurity_uk2  
            where  
                KS_ID = c.KLOFFICER_ID  
        ) OfficerName,  
        cs.StatusCode,  
        cs.StatusDesc,  
        c.KLAUTH Authorisation,  
        c.KLACTION ActionCode,  
        c.KLARCBOX ArchiveBox,  
        c.KLPOL_ID PolicyID,  
        c.KLPOLICY PolicyNo,  
        c.KLPRODUCT PolicyProduct,  
        c.KLALPHA AgencyCode,  
        c.KLPLAN PolicyPlanCode,  
        c.KLINTDOM IntDom,  
        c.KLEXCESS Excess,  
        c.KLSF SingleFamily,  
        c.KLDISS PolicyIssuedDate,  
        c.KLACT AccountingDate,  
        c.KLDEP DepartureDate,  
        c.KLRET ArrivalDate,  
        c.KLDAYS NumberOfDays,  
        c.KLITCPREM ITCPremium,  
        convert(varchar(15), c.KLEMCAPPROV) EMCApprovalNo,  
        c.KLGROUPPOL GroupPolicy,  
        c.KLLUGG LuggageFlag,  
        c.KLHRISK HRisk,  
        c.KLCASE CaseNo,  
        c.KLCOMMENT Comment,  
        (  
            select top 1  
                KPPRODUCT  
            from  
                claims_klproducts_uk2  
            where  
                KPProd_ID = c.KLPROD_ID  
        ) ClaimProduct,  
        (  
            select top 1  
                KLPLANCODE  
            from  
                claims_klproductplan_uk2  
            where  
                KLPLAN_ID = c.KLPLAN_ID  
        ) ClaimPlan,  
        c.KLRECOVERY RecoveryType,  
        null RecoveryTypeDesc,  
        c.KLREC_OUTCOMEID RecoveryOutcome,  
        (  
            select top 1  
                KTDESC  
            from  
                claims_klstatus_uk2  
            where  
                KT_ID = c.KLREC_OUTCOMEID  
        ) RecoveryOutcomeDesc,  
        c.KLONLINE OnlineClaim,  
        OnlineConsultant,  
        OnlineAlpha,  
        c.KLGroupCode ClaimGroupCode,  
        c.CultureCode,  
        c.KLDOMAINID DomainID,  
  NULL KLPolicyOffline,  
  NULL KLMASTERPOLICYNUMBER,  
  NULL KLGroupName,  
  NULL KLAgencyName  
    from  
        claims_klreg_uk2 c  
        cross apply dbo.fn_GetDomainKeys(c.KLDOMAINID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                AlphaCode OnlineAlpha,  
                ConsultantName OnlineConsultant  
            from  
                claims_tblOnlineClaims_uk2 oc  
            where  
                oc.ClaimId = c.KLCLAIM  
            order by  
                oc.OnlineClaimId desc  
        ) oc  
        outer apply  
        (  
            select top 1  
                KTSTATUS StatusCode,  
                KTDESC StatusDesc  
            from  
                claims_klstatus_uk2  
            where  
                KT_ID = c.KLSTATUS_ID and  
                KTTABLE = 'KLREG'  
        ) cs  
      where c.KLALPHA not like 'BK%'   ------adding condition to filter out BK.com data  

    union all  
      
  select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLPOLICY) collate database_default PolicyKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLALPHA) collate database_default AgencyKey,  
        (  
            select top 1  
                OutletKey  
            from  
                [db-au-cmdwh]..penOutlet o  
            where  
                o.OutletStatus = 'Current' and  
                o.CountryKey = dk.CountryKey and  
                o.AlphaCode = c.KLALPHA collate database_default  
        ) OutletKey,  
        (  
            select top 1  
                pt.PolicyTransactionKey  
            from  
                [db-au-cmdwh]..penPolicyTransSummary pt  
            where  
                pt.CountryKey = dk.CountryKey and  
                pt.PolicyNumber = convert(varchar, c.KLPOLICY) collate database_default and  
                (  
                    convert(date, pt.IssueDate) <= c.KLCREATED or  
                    convert(date, pt.IssueDate) = convert(date, c.KLDISS)  
                )  
        ) PolicyTransactionKey,  
        c.KLCLAIM ClaimNo,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_KLSECURITY_nz  
            where  
                KS_ID = c.KLCREATEDBY_ID  
        ) CreatedBy,  
        c.KLCREATED CreateDate,  
        c.KLRECEIVED ReceivedDate,  
        c.KLACTIONDATE ActionDate,  
        c.KLFINALDATE FinalisedDate,  
        dbo.xfn_ConvertLocaltoUTC(c.KLCREATED, dk.TimeZone) CreateDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLRECEIVED, dk.TimeZone) ReceivedDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLACTIONDATE, dk.TimeZone) ActionDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLFINALDATE, dk.TimeZone) FinalisedDateTimeUTC,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_KLSECURITY_nz  
            where  
                KS_ID = c.KLOFFICER_ID  
        ) OfficerName,  
        cs.StatusCode,  
        cs.StatusDesc,  
        c.KLAUTH Authorisation,  
        c.KLACTION ActionCode,  
        c.KLARCBOX ArchiveBox,  
        c.KLPOL_ID PolicyID,  
        convert(varchar(50), c.KLPOLICY) PolicyNo,  
        c.KLPRODUCT PolicyProduct,  
        c.KLALPHA AgencyCode,  
        c.KLPLAN PolicyPlanCode,  
        c.KLINTDOM IntDom,  
        c.KLEXCESS Excess,  
        c.KLSF SingleFamily,  
        c.KLDISS PolicyIssuedDate,  
        c.KLACT AccountingDate,  
        c.KLDEP DepartureDate,  
        c.KLRET ArrivalDate,  
        c.KLDAYS NumberOfDays,  
        c.KLITCPREM ITCPremium,  
        convert(varchar(15), c.KLEMCAPPROV) EMCApprovalNo,  
        c.KLGROUPPOL GroupPolicy,  
        c.KLLUGG LuggageFlag,  
        c.KLHRISK HRisk,  
        c.KLCASE CaseNo,  
        c.KLCOMMENT Comment,  
        (  
            select top 1  
                KPPRODUCT  
            from  
                claims_KLPRODUCTS_nz  
            where  
                KPProd_ID = c.KLPROD_ID  
        ) ClaimProduct,  
        null ClaimPlan,  
        c.KLRECOVERY RecoveryType,  
        null RecoveryTypeDesc,  
        null RecoveryOutcome,  
        null RecoveryOutcomeDesc,  
        null OnlineClaim,  
        null OnlineConsultant,  
        null OnlineAlpha,  
        null ClaimGroupCode,  
        null CultureCode,  
        null DomainID,  
  NULL KLPolicyOffline,  
  null KLMASTERPOLICYNUMBER,  
  null KLGroupName,  
  null KLAgencyName  
    from  
        claims_klreg_nz c  
        cross apply  
        (  
            select  
                'NZ' CountryKey,  
                'New Zealand Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                KTSTATUS StatusCode,  
                KTDESC StatusDesc  
            from  
                claims_KLSTATUS_nz  
            where  
                KT_ID = c.KLSTATUS_ID and  
      KTTABLE = 'KLREG'  
        ) cs  
  
    union all  
  
    select  
        dk.CountryKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLCLAIM) ClaimKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLPOLICY) collate database_default PolicyKey,  
        dk.CountryKey + '-' + convert(varchar, c.KLALPHA) collate database_default AgencyKey,  
        (  
            select top 1  
                OutletKey  
            from  
                [db-au-cmdwh]..penOutlet o  
            where  
                o.OutletStatus = 'Current' and  
                o.CountryKey = dk.CountryKey and  
                o.AlphaCode = c.KLALPHA collate database_default  
        ) OutletKey,  
        (  
            select top 1  
                pt.PolicyTransactionKey  
            from  
                [db-au-cmdwh]..penPolicyTransSummary pt  
            where  
                pt.CountryKey = dk.CountryKey and  
                pt.PolicyNumber = convert(varchar, c.KLPOLICY) collate database_default and  
                (  
                    convert(date, pt.IssueDate) <= c.KLCREATED or  
                    convert(date, pt.IssueDate) = convert(date, c.KLDISS)  
                )  
        ) PolicyTransactionKey,  
        c.KLCLAIM ClaimNo,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_KLSECURITY_uk  
            where  
                KS_ID = c.KLCREATEDBY_ID  
        ) CreatedBy,  
        c.KLCREATED CreateDate,  
        c.KLRECEIVED ReceivedDate,  
        c.KLACTIONDATE ActionDate,  
        c.KLFINALDATE FinalisedDate,  
        dbo.xfn_ConvertLocaltoUTC(c.KLCREATED, dk.TimeZone) CreateDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLRECEIVED, dk.TimeZone) ReceivedDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLACTIONDATE, dk.TimeZone) ActionDateTimeUTC,  
        dbo.xfn_ConvertLocaltoUTC(c.KLFINALDATE, dk.TimeZone) FinalisedDateTimeUTC,  
        (  
            select top 1  
                KSNAME collate database_default  
            from  
                claims_KLSECURITY_uk  
            where  
                KS_ID = c.KLOFFICER_ID  
        ) OfficerName,  
        cs.StatusCode,  
        cs.StatusDesc,  
        c.KLAUTH Authorisation,  
        c.KLACTION ActionCode,  
        c.KLARCBOX ArchiveBox,  
        c.KLPOL_ID PolicyID,  
        convert(varchar(50), c.KLPOLICY) PolicyNo,  
        c.KLPRODUCT PolicyProduct,  
        c.KLALPHA AgencyCode,  
        c.KLPLAN PolicyPlanCode,  
        c.KLINTDOM IntDom,  
        c.KLEXCESS Excess,  
        c.KLSF SingleFamily,  
        c.KLDISS PolicyIssuedDate,  
        c.KLACT AccountingDate,  
        c.KLDEP DepartureDate,  
        c.KLRET ArrivalDate,  
        c.KLDAYS NumberOfDays,  
        c.KLITCPREM ITCPremium,  
        convert(varchar(15), c.KLEMCAPPROV) EMCApprovalNo,  
        c.KLGROUPPOL GroupPolicy,  
        c.KLLUGG LuggageFlag,  
        c.KLHRISK HRisk,  
        c.KLCASE CaseNo,  
        c.KLCOMMENT Comment,  
        (  
            select top 1  
                KPPRODUCT  
            from  
                claims_KLPRODUCTS_uk  
            where  
                KPProd_ID = c.KLPROD_ID  
        ) ClaimProduct,  
        null ClaimPlan,  
        c.KLRECOVERY RecoveryType,  
        null RecoveryTypeDesc,  
        null RecoveryOutcome,  
        null RecoveryOutcomeDesc,  
        null OnlineClaim,  
        null OnlineConsultant,  
        null OnlineAlpha,  
        null ClaimGroupCode,  
        null CultureCode,  
        null DomainID,  
  NULL KLPolicyOffline,  
  null KLMASTERPOLICYNUMBER,  
  null KLGroupName,  
  null KLAgencyName  
    from  
        claims_klreg_uk c  
        cross apply  
        (  
            select  
                'UK' CountryKey,  
                'GMT Standard Time' TimeZone  
        ) dk  
        outer apply  
        (  
            select top 1  
                KTSTATUS StatusCode,  
                KTDESC StatusDesc  
            from  
                claims_KLSTATUS_uk  
            where  
               KT_ID = c.KLSTATUS_ID and  
                KTTABLE = 'KLREG'  
        ) cs  
  
    set @sourcecount = @@rowcount  
  
    /* sync rollup */  
    if object_id('etl_clmClaim_sync') is null  
        create table etl_clmClaim_sync  
        (  
            ClaimKey varchar(40) null  
        )  
    else  
        truncate table etl_clmClaim_sync  
  
    insert into etl_clmClaim_sync  
    (  
        ClaimKey  
    )  
    select  
        ClaimKey  
    from  
        etl_claims  
  
  
    begin transaction  
  
    begin try  
  
        merge into [db-au-cmdwh].dbo.clmClaim with(tablock) t  
        using etl_claims s on  
            s.ClaimKey = t.ClaimKey  
  
        when matched then  
  
            update  
            set  
                CountryKey = s.CountryKey,  
                PolicyKey = s.PolicyKey,  
                AgencyKey = s.AgencyKey,  
                ClaimNo = s.ClaimNo,  
                CreatedBy = s.CreatedBy,  
                CreateDate = s.CreateDate,  
                OfficerName = s.OfficerName,  
                StatusCode = s.StatusCode,  
                StatusDesc = s.StatusDesc,  
                ReceivedDate = s.ReceivedDate,  
                Authorisation = s.Authorisation,  
                ActionDate = s.ActionDate,  
                ActionCode = s.ActionCode,  
                FinalisedDate = s.FinalisedDate,  
                ArchiveBox = s.ArchiveBox,  
                PolicyID = s.PolicyID,  
                PolicyNo = s.PolicyNo,  
                PolicyProduct = s.PolicyProduct,  
                AgencyCode = s.AgencyCode,  
                PolicyPlanCode = s.PolicyPlanCode,  
                IntDom = s.IntDom,  
                Excess = s.Excess,  
                SingleFamily = s.SingleFamily,  
                PolicyIssuedDate = s.PolicyIssuedDate,  
                AccountingDate = s.AccountingDate,  
                DepartureDate = s.DepartureDate,  
                ArrivalDate = s.ArrivalDate,  
                NumberOfDays = s.NumberOfDays,  
                ITCPremium = s.ITCPremium,  
                EMCApprovalNo = s.EMCApprovalNo,  
                GroupPolicy = s.GroupPolicy,  
                LuggageFlag = s.LuggageFlag,  
                HRisk = s.HRisk,  
                CaseNo = s.CaseNo,  
                Comment = s.Comment,  
                ClaimProduct = s.ClaimProduct,  
                ClaimPlan = s.ClaimPlan,  
                RecoveryType = s.RecoveryType,  
                RecoveryOutcome = s.RecoveryOutcome,  
                OnlineClaim = s.OnlineClaim,  
                RecoveryTypeDesc = s.RecoveryTypeDesc,  
                RecoveryOutcomeDesc = s.RecoveryOutcomeDesc,  
                OnlineConsultant = s.OnlineConsultant,  
                OnlineAlpha = s.OnlineAlpha,  
                DomainID = s.DomainID,  
                PolicyTransactionKey = s.PolicyTransactionKey,  
                OutletKey = s.OutletKey,  
                CultureCode = s.CultureCode,  
                ClaimGroupCode = s.ClaimGroupCode,  
                CreateDateTimeUTC = s.CreateDateTimeUTC,  
                ReceivedDateTimeUTC = s.ReceivedDateTimeUTC,  
                ActionDateTimeUTC = s.ActionDateTimeUTC,  
                FinalisedDateTimeUTC = s.FinalisedDateTimeUTC,  
                UpdateBatchID = @batchid,  
    PolicyOffline = KLPolicyOffline,  
    MasterPolicyNumber = s.KLMasterPolicyNumber,  
    GroupName = s.KLGroupName,  
    Agencyname = s.KLAgencyName  
  
        when not matched by target then  
            insert  
            (  
                CountryKey,  
                ClaimKey,  
                PolicyKey,  
                AgencyKey,  
                ClaimNo,  
                CreatedBy,  
                CreateDate,  
                OfficerName,  
                StatusCode,  
                StatusDesc,  
                ReceivedDate,  
                Authorisation,  
                ActionDate,  
                ActionCode,  
                FinalisedDate,  
                ArchiveBox,  
                PolicyID,  
           PolicyNo,  
                PolicyProduct,  
                AgencyCode,  
                PolicyPlanCode,  
                IntDom,  
                Excess,  
                SingleFamily,  
                PolicyIssuedDate,  
                AccountingDate,  
                DepartureDate,  
                ArrivalDate,  
                NumberOfDays,  
                ITCPremium,  
                EMCApprovalNo,  
                GroupPolicy,  
                LuggageFlag,  
                HRisk,  
                CaseNo,  
                Comment,  
                ClaimProduct,  
                ClaimPlan,  
                RecoveryType,  
                RecoveryOutcome,  
                OnlineClaim,  
                RecoveryTypeDesc,  
                RecoveryOutcomeDesc,  
                OnlineConsultant,  
                OnlineAlpha,  
                DomainID,  
                PolicyTransactionKey,  
                OutletKey,  
                CultureCode,  
                ClaimGroupCode,  
                CreateDateTimeUTC,  
                ReceivedDateTimeUTC,  
                ActionDateTimeUTC,  
                FinalisedDateTimeUTC,  
                CreateBatchID,  
    PolicyOffline,  
    MasterPolicyNumber,  
    GroupName,  
    AgencyName  
            )  
            values  
            (  
                s.CountryKey,  
                s.ClaimKey,  
                s.PolicyKey,  
                s.AgencyKey,  
                s.ClaimNo,  
                s.CreatedBy,  
                s.CreateDate,  
                s.OfficerName,  
                s.StatusCode,  
                s.StatusDesc,  
                s.ReceivedDate,  
                s.Authorisation,  
                s.ActionDate,  
                s.ActionCode,  
                s.FinalisedDate,  
                s.ArchiveBox,  
                s.PolicyID,  
                s.PolicyNo,  
                s.PolicyProduct,  
                s.AgencyCode,  
                s.PolicyPlanCode,  
                s.IntDom,  
                s.Excess,  
                s.SingleFamily,  
                s.PolicyIssuedDate,  
                s.AccountingDate,  
                s.DepartureDate,  
                s.ArrivalDate,  
                s.NumberOfDays,  
                s.ITCPremium,  
                s.EMCApprovalNo,  
                s.GroupPolicy,  
                s.LuggageFlag,  
                s.HRisk,  
                s.CaseNo,  
                s.Comment,  
                s.ClaimProduct,  
                s.ClaimPlan,  
                s.RecoveryType,  
                s.RecoveryOutcome,  
                s.OnlineClaim,  
                s.RecoveryTypeDesc,  
                s.RecoveryOutcomeDesc,  
                s.OnlineConsultant,  
                s.OnlineAlpha,  
                s.DomainID,  
                s.PolicyTransactionKey,  
                s.OutletKey,  
                s.CultureCode,  
                s.ClaimGroupCode,  
                s.CreateDateTimeUTC,  
                s.ReceivedDateTimeUTC,  
                s.ActionDateTimeUTC,  
                s.FinalisedDateTimeUTC,  
                @batchid,  
    s.KLPolicyOffline,  
    s.KLMasterPolicyNumber,  
    s.KLGroupName,  
    s.KLAgencyName  
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
  
        update cl  
        set  
            cl.CaseKey = isnull(cbp.CaseKey, '')  
        from  
            [db-au-cmdwh]..clmClaim cl with(nolock)  
            outer apply  
            (  
                select top 1   
                    cc.CaseKey  
                from  
                    [db-au-cmdwh]..cbCase cc with(nolock)  
                where  
                    cc.CaseNo in  
                    (  
                        select   
                            ce.CaseID  
                        from  
                            [db-au-cmdwh]..clmEvent ce with(nolock)  
                        where  
                            ce.ClaimKey = cl.ClaimKey  
                    ) or  
                    cc.CaseKey in  
                    (  
                        select  
                            cbp.CaseKey  
                        from  
                            [db-au-cmdwh]..cbPolicy cbp  
                            inner join [db-au-cmdwh]..cbCase cc on  
                                cc.CaseKey = cbp.CaseKey  
                            inner join [db-au-cmdwh]..penPolicyTransSummary pt on  
                                pt.PolicyTransactionKey = cbp.PolicyTransactionKey  
                            inner join [db-au-cmdwh]..penPolicyTransSummary r on  
                                r.PolicyKey = pt.PolicyKey  
                        where  
                            r.PolicyTransactionKey = cl.PolicyTransactionKey and  
                            cc.CreateDate < cl.CreateDate  
                    )  
                order by  
                    cc.CreateDate desc  
            ) cbp  
        where  
            cl.CaseKey in  
            (  
                select   
                    ClaimKey  
                from  
                    etl_claims  
            )  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction  
  
        exec syssp_genericerrorhandler  
            @SourceInfo = 'clmClaim data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '-100',  
            @BatchID = @batchid,  
            @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
GO
