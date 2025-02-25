USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyTransaction_BKP20240221]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyTransaction_BKP20240221]  
as  
begin  
  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120127  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    Policy Transaction table contains policy transactions attributes.  
                This transformation adds essential key fields  
Change History:  
                20120127 - LT - Procedure created  
                20120911 - LS - fix indexing  
                                add transaction promo  
                20121107 - LS - refactoring & domain related changes  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20131024 - LT - Added ImportDate column to penPolicyTransaction  
                20131127 - LS - Penguin 7.8 schema changes  
                20131204 - LS - case 19524, index optimisation for new pricing calculation  
                20131205 - LS - (ref: case 19524), also change UserSKey update statement  
                20131218 - LT - Found bug with UserSKey lookup. Reverting back to the old UserSKey update statement.  
                20140128 - LS - case 20020, out of sync summary roll up, fix: log rows updated to global temp table  
                20140320 - LS - case 20561, the fix on 20020 doesn't work all the time (e.g. UK)  
                                this is due to the global temporary table usage, changing this to a disk table  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                                add TotalCommission & TotalNet, not sure when was these two added  
                                drop and recreate etl promo instead of defining it and truncate the data  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20140703 - LT - Fixed final insert statement to include TotalCommission and TotalNet columns  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
                20140805 - LT - TFS 13021, changed PolicyNumber from bigint to varchar(50), changed PolicyNoKey from varchar(41) to varchar(100)  
                20141216 - LS - P11.5, username from 50 to 100 nvarchar  
                20150408 - LS - TFS 15452, add PaymentMode & PointsRedeemed  
                20150428 - LT - TFS 14124, added GoBelowNet to penPolicyTransactionPromo table  
                20150601 - LS - TFS 16953, change PointsRedeemed, add RedemptionReference  
    20151027 - DM - Penguin v16 Release. Add Column GigyaID  
    20160321 - LT - Penguin 18.0, Added US penguin instance  
                20161021 - LS - Penguin 2x.? IssuingConsultantID  
                                Penguin 21.5 LeadTimeDate  
                20161123 - LL - GLM implementation: capture base transaction start & end dates (copy from policy)  
                20161123 - LL - remove GLM implementation, put into separate process  
    20181024 - LT - Penguin 32.0 release. Added RefundTransactionID and RefundTransactionKey columns  
    20200731 - GS - Added Topup,RefundToCustomer and CNStatusID as a part of Penguin release
	20210306, SS, CHG0034615 Add filter for BK.com    
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    /* policy transaction */  
    if object_id('etl_penPolicyTransaction') is not null  
        drop table etl_penPolicyTransaction  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        PrefixKey + convert(varchar, pt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, pt.TripsPolicyNumber collate database_default) PolicyNoKey,  
        PrefixKey + convert(varchar, pt.ConsultantID) UserKey,  
        convert(bigint,null) as UserSKey,  
        DomainID,  
        pt.ID as PolicyTransactionID,  
        pt.PolicyID,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        pt.TransactionType as TransactionTypeID,  
        tt.TransactionType,  
        pt.GrossPremium,  
        dbo.xfn_ConvertUTCtoLocal(pt.IssueDate, TimeZone) IssueDate,  
        pt.IssueDate IssueDateUTC,  
        dbo.xfn_ConvertUTCtoLocal(pt.AccountingPeriod, TimeZone) AccountingPeriod,  
        pt.CRMUserID,  
        crm.CRMUserName,  
        pt.TransactionStatus as TransactionStatusID,  
        ts.TransactionStatus,  
        pt.Transferred,  
        pt.UserComments,  
        pt.CommissionTier,  
        pt.VolumeCommission,  
        pt.Discount,  
        pt.isExpo,  
        pt.isPriceBeat,  
        pt.NoOfBonusDaysApplied,  
        pt.isAgentSpecial,  
        pt.ParentID,  
        pt.ConsultantID,  
        pt.isClientCall,  
        pt.RiskNet,  
        pt.AutoComments,  
        pt.TripCost,  
        pt.AllocationNumber,  
        dbo.xfn_ConvertUTCtoLocal(pt.PaymentDate, TimeZone) PaymentDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionStart, TimeZone) TransactionStart,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionEnd, TimeZone) TransactionEnd,  
        pt.PaymentDate PaymentDateUTC,  
        pt.TransactionStart TransactionStartUTC,  
        pt.TransactionEnd TransactionEndUTC,  
        pt.StoreCode,  
        ppi.ImportDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, TimeZone) TransactionDateTime,  
        pt.TotalCommission,  
        pt.TotalNet,  
        pt.PaymentMode,  
        kvpr.PointsRedeemed,  
        kvrr.RedemptionReference,  
  pt.GigyaId,  
        pt.IssuingConsultantId,  
        pt.LeadTimeDate,  
  pt.RefundTransactionID,  
  PrefixKey + convert(varchar, pt.RefundTransactionID) as RefundTransactionKey,  
  pt.TopUp ,  
  pt.RefundToCustomer,  
  pt.CNStatusID  
    into etl_penPolicyTransaction  
    from  
        penguin_tblPolicyTransaction_aucm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                [Type] TransactionType  
            from  
                penguin_tblPolicyTransactionType_aucm  
            where  
                ID = pt.TransactionType  
        ) tt  
        outer apply  
        (  
            select top 1  
                UserName CRMUserName  
            from  
                penguin_tblCRMUser_aucm  
            where  
                ID = pt.CRMUserID  
        ) crm  
        outer apply  
        (  
            select top 1  
                StatusDescription TransactionStatus  
            from  
                dbo.penguin_tblPolicyTransactionStatus_aucm  
            where  
                ID = pt.TransactionStatus  
        ) ts  
        outer apply  
        (  
            select  
                convert(date, max(CreateDateTime)) ImportDate  
            from  
                [db-au-cmdwh].dbo.penPolicyImport ppi  
            where  
                ppi.Status = 'DONE' and  
                ppi.CountryKey = 'AU' and  
                ppi.PolicyNumber  collate database_default = pt.TripsPolicyNumber collate database_default  
        ) ppi  
        outer apply  
        (  
            select top 1  
                convert(money, kv.Value) PointsRedeemed  
            from  
                penguin_tblPolicyTransactionKeyValues_aucm kv  
                inner join penguin_tblPolicyKeyValueTypes_aucm kvt on  
                    kvt.ID = kv.TypeId  
            where  
    kvt.Code = 'POINTSREDEEMED' and  
                kv.PolicyTransactionId = pt.ID  
        ) kvpr  
        outer apply  
        (  
            select top 1  
                kv.Value RedemptionReference  
            from  
                penguin_tblPolicyKeyValues_aucm kv  
                inner join penguin_tblPolicyKeyValueTypes_aucm kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyId = pt.PolicyID and  
                kvt.Code = 'REDEMPTIONREFERENCE'  
        ) kvrr  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        PrefixKey + convert(varchar, pt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, pt.TripsPolicyNumber collate database_default) PolicyNoKey,  
        PrefixKey + convert(varchar, pt.ConsultantID) UserKey,  
        convert(bigint,null) as UserSKey,  
        DomainID,  
        pt.ID as PolicyTransactionID,  
        pt.PolicyID,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        pt.TransactionType as TransactionTypeID,  
        tt.TransactionType,  
        pt.GrossPremium,  
        dbo.xfn_ConvertUTCtoLocal(pt.IssueDate, TimeZone) IssueDate,  
        pt.IssueDate IssueDateUTC,  
        dbo.xfn_ConvertUTCtoLocal(pt.AccountingPeriod, TimeZone) AccountingPeriod,  
        pt.CRMUserID,  
        crm.CRMUserName,  
        pt.TransactionStatus as TransactionStatusID,  
        ts.TransactionStatus,  
        pt.Transferred,  
        pt.UserComments,  
        pt.CommissionTier,  
        pt.VolumeCommission,  
        pt.Discount,  
        pt.isExpo,  
        pt.isPriceBeat,  
        pt.NoOfBonusDaysApplied,  
        pt.isAgentSpecial,  
        pt.ParentID,  
        pt.ConsultantID,  
        pt.isClientCall,  
        pt.RiskNet,  
        pt.AutoComments,  
        pt.TripCost,  
        pt.AllocationNumber,  
        dbo.xfn_ConvertUTCtoLocal(pt.PaymentDate, TimeZone) PaymentDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionStart, TimeZone) TransactionStart,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionEnd, TimeZone) TransactionEnd,  
        pt.PaymentDate PaymentDateUTC,  
        pt.TransactionStart TransactionStartUTC,  
        pt.TransactionEnd TransactionEndUTC,  
        pt.StoreCode,  
        ppi.ImportDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, TimeZone) TransactionDateTime,  
        pt.TotalCommission,  
        pt.TotalNet,  
        pt.PaymentMode,  
        kvpr.PointsRedeemed,  
        kvrr.RedemptionReference,  
  pt.GigyaId,  
        pt.IssuingConsultantId,  
        pt.LeadTimeDate,  
  pt.RefundTransactionID,  
  PrefixKey + convert(varchar, pt.RefundTransactionID) as RefundTransactionKey,  
  pt.TopUp ,  
  pt.RefundToCustomer,  
  pt.CNStatusID  
    from  
        penguin_tblPolicyTransaction_autp pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk  
        outer apply  
        (  
            select top 1  
                [Type] TransactionType  
            from  
                penguin_tblPolicyTransactionType_autp  
            where  
                ID = pt.TransactionType  
        ) tt  
        outer apply  
        (  
            select top 1  
                UserName CRMUserName  
            from  
                penguin_tblCRMUser_autp  
            where  
                ID = pt.CRMUserID  
        ) crm  
        outer apply  
        (  
            select top 1  
                StatusDescription TransactionStatus  
            from  
                dbo.penguin_tblPolicyTransactionStatus_autp  
            where  
                ID = pt.TransactionStatus  
        ) ts  
        outer apply  
        (  
            select  
                convert(date, max(CreateDateTime)) ImportDate  
            from  
                [db-au-cmdwh].dbo.penPolicyImport ppi  
            where  
                ppi.Status = 'DONE' and  
                ppi.CountryKey = 'AU' and  
                ppi.PolicyNumber  collate database_default = pt.TripsPolicyNumber collate database_default  
        ) ppi  
        outer apply  
        (  
            select top 1  
                convert(money, kv.Value) PointsRedeemed  
            from  
                penguin_tblPolicyTransactionKeyValues_autp kv  
                inner join penguin_tblPolicyKeyValueTypes_autp kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyTransactionId = pt.ID and  
                kvt.Code = 'POINTSREDEEMED'  
        ) kvpr  
        outer apply  
        (  
            select top 1  
                kv.Value RedemptionReference  
            from  
                penguin_tblPolicyKeyValues_autp kv  
                inner join penguin_tblPolicyKeyValueTypes_autp kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyId = pt.PolicyID and  
                kvt.Code = 'REDEMPTIONREFERENCE'  
        ) kvrr  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        PrefixKey + convert(varchar, pt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, pt.TripsPolicyNumber collate database_default) PolicyNoKey,  
        PrefixKey + convert(varchar, pt.ConsultantID) UserKey,  
        convert(bigint,null) as UserSKey,  
        DomainID,  
        pt.ID as PolicyTransactionID,  
        pt.PolicyID,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        pt.TransactionType as TransactionTypeID,  
        tt.TransactionType,  
        pt.GrossPremium,  
        dbo.xfn_ConvertUTCtoLocal(pt.IssueDate, TimeZone) IssueDate,  
        pt.IssueDate IssueDateUTC,  
        dbo.xfn_ConvertUTCtoLocal(pt.AccountingPeriod, TimeZone) AccountingPeriod,  
        pt.CRMUserID,  
        crm.CRMUserName,  
        pt.TransactionStatus as TransactionStatusID,  
        ts.TransactionStatus,  
        pt.Transferred,  
        pt.UserComments,  
        pt.CommissionTier,  
        pt.VolumeCommission,  
        pt.Discount,  
        pt.isExpo,  
        pt.isPriceBeat,  
        pt.NoOfBonusDaysApplied,  
        pt.isAgentSpecial,  
        pt.ParentID,  
        pt.ConsultantID,  
        pt.isClientCall,  
        pt.RiskNet,  
        pt.AutoComments,  
        pt.TripCost,  
        pt.AllocationNumber,  
        dbo.xfn_ConvertUTCtoLocal(pt.PaymentDate, TimeZone) PaymentDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionStart, TimeZone) TransactionStart,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionEnd, TimeZone) TransactionEnd,  
        pt.PaymentDate PaymentDateUTC,  
        pt.TransactionStart TransactionStartUTC,  
        pt.TransactionEnd TransactionEndUTC,  
        pt.StoreCode,  
        ppi.ImportDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, TimeZone) TransactionDateTime,  
        pt.TotalCommission,  
        pt.TotalNet,  
        pt.PaymentMode,  
        kvpr.PointsRedeemed,  
        kvrr.RedemptionReference,  
  pt.GigyaId,  
        pt.IssuingConsultantId,  
        pt.LeadTimeDate,  
  pt.RefundTransactionID,  
  PrefixKey + convert(varchar, pt.RefundTransactionID) as RefundTransactionKey,  
  pt.TopUp ,  
  pt.RefundToCustomer,  
  pt.CNStatusID  
    from  
        penguin_tblPolicyTransaction_ukcm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                [Type] TransactionType  
            from  
                penguin_tblPolicyTransactionType_ukcm  
            where  
                ID = pt.TransactionType  
        ) tt  
        outer apply  
        (  
            select top 1  
                UserName CRMUserName  
            from  
                penguin_tblCRMUser_ukcm  
            where  
                ID = pt.CRMUserID  
        ) crm  
        outer apply  
        (  
            select top 1  
                StatusDescription TransactionStatus  
            from  
                dbo.penguin_tblPolicyTransactionStatus_ukcm  
            where  
                ID = pt.TransactionStatus  
        ) ts  
        outer apply  
        (  
            select  
convert(date, max(CreateDateTime)) ImportDate  
            from  
                [db-au-cmdwh].dbo.penPolicyImport ppi  
            where  
                ppi.Status = 'DONE' and  
                ppi.CountryKey = 'UK' and  
                ppi.PolicyNumber  collate database_default = pt.TripsPolicyNumber collate database_default  
        ) ppi  
        outer apply  
        (  
            select top 1  
                convert(money, kv.Value) PointsRedeemed  
            from  
                penguin_tblPolicyTransactionKeyValues_ukcm kv  
                inner join penguin_tblPolicyKeyValueTypes_ukcm kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyTransactionId = pt.ID and  
                kvt.Code = 'POINTSREDEEMED'  
        ) kvpr  
        outer apply  
        (  
            select top 1  
                kv.Value RedemptionReference  
            from  
                penguin_tblPolicyKeyValues_ukcm kv  
                inner join penguin_tblPolicyKeyValueTypes_ukcm kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyId = pt.PolicyID and  
                kvt.Code = 'REDEMPTIONREFERENCE'  
        ) kvrr  
	where (PrefixKey + convert(varchar, pt.PolicyID)) not in (select PrefixKey + convert(varchar, PolicyID) from Penguin_tblpolicy_ukcm cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'UK') dk where AlphaCode like 'BK%')	------adding condition to filter out BK.com data

    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        PrefixKey + convert(varchar, pt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, pt.TripsPolicyNumber collate database_default) PolicyNoKey,  
        PrefixKey + convert(varchar, pt.ConsultantID) UserKey,  
        convert(bigint,null) as UserSKey,  
        DomainID,  
        pt.ID as PolicyTransactionID,  
        pt.PolicyID,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        pt.TransactionType as TransactionTypeID,  
        tt.TransactionType,  
        pt.GrossPremium,  
        dbo.xfn_ConvertUTCtoLocal(pt.IssueDate, TimeZone) IssueDate,  
        pt.IssueDate IssueDateUTC,  
        dbo.xfn_ConvertUTCtoLocal(pt.AccountingPeriod, TimeZone) AccountingPeriod,  
        pt.CRMUserID,  
        crm.CRMUserName,  
        pt.TransactionStatus as TransactionStatusID,  
        ts.TransactionStatus,  
        pt.Transferred,  
        pt.UserComments,  
        pt.CommissionTier,  
        pt.VolumeCommission,  
        pt.Discount,  
        pt.isExpo,  
        pt.isPriceBeat,  
        pt.NoOfBonusDaysApplied,  
        pt.isAgentSpecial,  
        pt.ParentID,  
        pt.ConsultantID,  
        pt.isClientCall,  
        pt.RiskNet,  
        pt.AutoComments,  
        pt.TripCost,  
        pt.AllocationNumber,  
        dbo.xfn_ConvertUTCtoLocal(pt.PaymentDate, TimeZone) PaymentDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionStart, TimeZone) TransactionStart,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionEnd, TimeZone) TransactionEnd,  
        pt.PaymentDate PaymentDateUTC,  
        pt.TransactionStart TransactionStartUTC,  
        pt.TransactionEnd TransactionEndUTC,  
        pt.StoreCode,  
        ppi.ImportDate,  
        dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, TimeZone) TransactionDateTime,  
        pt.TotalCommission,  
        pt.TotalNet,  
        pt.PaymentMode,  
        kvpr.PointsRedeemed,  
        kvrr.RedemptionReference,  
  pt.GigyaId,  
        pt.IssuingConsultantId,  
        pt.LeadTimeDate,  
  pt.RefundTransactionID,  
  PrefixKey + convert(varchar, pt.RefundTransactionID) as RefundTransactionKey,  
  pt.TopUp,  
  pt.RefundToCustomer,  
  pt.CNStatusID  
    from  
        penguin_tblPolicyTransaction_uscm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk  
        outer apply  
        (  
            select top 1  
                [Type] TransactionType  
            from  
                penguin_tblPolicyTransactionType_uscm  
            where  
                ID = pt.TransactionType  
        ) tt  
        outer apply  
        (  
            select top 1  
                UserName CRMUserName  
            from  
                penguin_tblCRMUser_uscm  
            where  
                ID = pt.CRMUserID  
        ) crm  
        outer apply  
        (  
            select top 1  
                StatusDescription TransactionStatus  
            from  
                dbo.penguin_tblPolicyTransactionStatus_uscm  
            where  
                ID = pt.TransactionStatus  
        ) ts  
        outer apply  
        (  
            select  
                convert(date, max(CreateDateTime)) ImportDate  
            from  
                [db-au-cmdwh].dbo.penPolicyImport ppi  
            where  
                ppi.Status = 'DONE' and  
                ppi.CountryKey = 'US' and  
                ppi.PolicyNumber  collate database_default = pt.TripsPolicyNumber collate database_default  
        ) ppi  
        outer apply  
        (  
            select top 1  
                convert(money, kv.Value) PointsRedeemed  
            from  
                penguin_tblPolicyTransactionKeyValues_uscm kv  
                inner join penguin_tblPolicyKeyValueTypes_uscm kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyTransactionId = pt.ID and  
                kvt.Code = 'POINTSREDEEMED'  
        ) kvpr  
        outer apply  
        (  
            select top 1  
                kv.Value RedemptionReference  
            from  
                penguin_tblPolicyKeyValues_uscm kv  
                inner join penguin_tblPolicyKeyValueTypes_uscm kvt on  
                    kvt.ID = kv.TypeId  
            where  
                kv.PolicyId = pt.PolicyID and  
                kvt.Code = 'REDEMPTIONREFERENCE'  
        ) kvrr  
  
  
  
    /*************************************************************/  
    --Update UserSKey in etl_penPolicyTransaction records  
    --For UserStatus = Current  
    /*************************************************************/  
    update p  
    set p.UserSKey = u.UserSKey  
    from  
        etl_penPolicyTransaction p  
        inner join [db-au-cmdwh].dbo.penUser u on  
            p.UserKey = u.UserKey and  
            u.UserStatus = 'Current'  
  
    /*************************************************************/  
    --Update UserSKey in etl_penPolicy records  
    --For UserStatus = Not Current AND  
    --PolicyTransaction IssueDate between UserStartDate and UserEndDate  
    /*************************************************************/  
    update p  
    set p.UserSKey = u.UserSKey  
    from  
        etl_penPolicyTransaction p  
        inner join [db-au-cmdwh].dbo.penUser u on  
            p.UserKey = u.UserKey and  
            u.UserStatus = 'Not Current' and  
            convert(date,p.IssueDate) >= convert(date, u.UserStartDate) and  
            convert(date,p.IssueDate) <  convert(date, dateadd(day, 1, u.UserEndDate))  
  
  
    if object_id('[db-au-cmdwh].dbo.penPolicyTransaction') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyTransaction]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [PolicyTransactionKey] varchar(41) not null,  
            [PolicyKey] varchar(41) null,  
            [PolicyNoKey] varchar(100) null,  
            [UserKey] varchar(41) null,  
            [UserSKey] bigint null,  
            [PolicyTransactionID] int not null,  
            [PolicyID] int not null,  
            [PolicyNumber] varchar(50) null,  
            [TransactionTypeID] int not null,  
            [TransactionType] varchar(50) null,  
            [GrossPremium] money not null,  
            [IssueDate] datetime not null,  
            [AccountingPeriod] datetime not null,  
            [CRMUserID] int null,  
            [CRMUserName] nvarchar(100) null,  
            [TransactionStatusID] int not null,  
            [TransactionStatus] nvarchar(50) null,  
            [Transferred] bit not null,  
            [UserComments] nvarchar(1000) null,  
            [CommissionTier] varchar(50) null,  
      [VolumeCommission] numeric(18,9) null,  
            [Discount] numeric(18,9) null,  
            [isExpo] bit not null,  
            [isPriceBeat] bit not null,  
            [NoOfBonusDaysApplied] int null,  
            [isAgentSpecial] bit not null,  
            [ParentID] int null,  
            [ConsultantID] int null,  
            [isClientCall] bit null,  
            [RiskNet] money null,  
            [AutoComments] nvarchar(2000) null,  
            [TripCost] varchar(50) null,  
            [AllocationNumber] int null,  
            [PaymentDate] datetime null,  
            [TransactionStart] datetime null,  
            [TransactionEnd] datetime null,  
            [StoreCode] varchar(10) null,  
            [DomainKey] varchar(41) null,  
            [DomainID] int null,  
            [IssueDateUTC] datetime null,  
            [PaymentDateUTC] datetime null,  
            [TransactionStartUTC] datetime null,  
            [TransactionEndUTC] datetime null,  
            [ImportDate] datetime null,  
            [TransactionDateTime] datetime null,  
            [TotalCommission] money null,  
            [TotalNet] money null,  
            [PaymentMode] nvarchar(20) null,  
            [PointsRedeemed] money null,  
            [RedemptionReference] nvarchar(255) null,  
   [GigyaId] nvarchar(300) null,  
            [IssuingConsultantID] int null,  
            [LeadTimeDate] date null,  
   [RefundTransactionID] int null,  
   [RefundTransactionKey] varchar(41) null,  
   [TopUp] bit null,  
   [RefundToCustomer] bit null,  
   [CNStatusID] int null    
        )  
  
        create clustered index idx_penPolicyTransaction_PolicyKey on [db-au-cmdwh].dbo.penPolicyTransaction(PolicyKey)  
        create nonclustered index idx_penPolicyTransaction_IssueDate on [db-au-cmdwh].dbo.penPolicyTransaction(IssueDate)  
        create nonclustered index idx_penPolicyTransaction_PaymentDate on [db-au-cmdwh].dbo.penPolicyTransaction(PaymentDate)  
        create nonclustered index idx_penPolicyTransaction_PolicyID on [db-au-cmdwh].dbo.penPolicyTransaction(PolicyID)  
        create nonclustered index idx_penPolicyTransaction_PolicyNumber on [db-au-cmdwh].dbo.penPolicyTransaction(PolicyNumber)  
        create nonclustered index idx_penPolicyTransaction_PolicyTransactionID on [db-au-cmdwh].dbo.penPolicyTransaction(PolicyTransactionID)  
        create nonclustered index idx_penPolicyTransaction_PolicyTransactionKey on [db-au-cmdwh].dbo.penPolicyTransaction(PolicyTransactionKey) include (PolicyNumber,PolicyKey,TransactionType)  
        create nonclustered index idx_penPolicyTransaction_UserKey on [db-au-cmdwh].dbo.penPolicyTransaction(UserKey)  
        create nonclustered index idx_penPolicyTransaction_UserSKey on [db-au-cmdwh].dbo.penPolicyTransaction(UserSKey)  
  
    end  
  
  
    begin transaction penPolicyTransaction  
  
    begin try  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPolicyTransaction a  
            inner join etl_penPolicyTransaction b on  
                a.PolicyTransactionKey = b.PolicyTransactionKey  
  
        insert into [db-au-cmdwh].dbo.penPolicyTransaction with(tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            DomainKey,  
            PolicyTransactionKey,  
            PolicyKey,  
            PolicyNoKey,  
            UserKey,  
            UserSKey,  
            DomainID,  
            PolicyTransactionID,  
            PolicyID,  
            PolicyNumber,  
            TransactionTypeID,  
            TransactionType,  
            GrossPremium,  
            IssueDate,  
            IssueDateUTC,  
            AccountingPeriod,  
            CRMUserID,  
            CRMUserName,  
            TransactionStatusID,  
            TransactionStatus,  
            Transferred,  
            UserComments,  
            CommissionTier,  
            VolumeCommission,  
            Discount,  
            isExpo,  
            isPriceBeat,  
            NoOfBonusDaysApplied,  
            isAgentSpecial,  
        ParentID,  
            ConsultantID,  
            isClientCall,  
            RiskNet,  
            AutoComments,  
            TripCost,  
            AllocationNumber,  
            PaymentDate,  
            TransactionStart,  
            TransactionEnd,  
            PaymentDateUTC,  
            TransactionStartUTC,  
            TransactionEndUTC,  
            StoreCode,  
            ImportDate,  
            TransactionDateTime,  
            TotalCommission,  
            TotalNet,  
            PaymentMode,  
            PointsRedeemed,  
            RedemptionReference,  
   GigyaId,  
            IssuingConsultantID,  
            LeadTimeDate,  
   RefundTransactionID,  
   RefundTransactionKey,  
   TopUp,  
   RefundToCustomer,  
   CNStatusID  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            DomainKey,  
            PolicyTransactionKey,  
            PolicyKey,  
            PolicyNoKey,  
            UserKey,  
            UserSKey,  
            DomainID,  
            PolicyTransactionID,  
            PolicyID,  
            PolicyNumber,  
            TransactionTypeID,  
            TransactionType,  
            GrossPremium,  
            IssueDate,  
            IssueDateUTC,  
            AccountingPeriod,  
            CRMUserID,  
            CRMUserName,  
            TransactionStatusID,  
            TransactionStatus,  
            Transferred,  
            UserComments,  
            CommissionTier,  
            VolumeCommission,  
            Discount,  
            isExpo,  
            isPriceBeat,  
            NoOfBonusDaysApplied,  
            isAgentSpecial,  
            ParentID,  
            ConsultantID,  
            isClientCall,  
            RiskNet,  
            AutoComments,  
            TripCost,  
            AllocationNumber,  
            PaymentDate,  
            TransactionStart,  
            TransactionEnd,  
            PaymentDateUTC,  
            TransactionStartUTC,  
            TransactionEndUTC,  
            StoreCode,  
            ImportDate,  
            TransactionDateTime,  
            TotalCommission,  
            TotalNet,  
            PaymentMode,  
            PointsRedeemed,  
            RedemptionReference,  
   GigyaId,  
            IssuingConsultantID,  
            LeadTimeDate,  
   RefundTransactionID,  
   RefundTransactionKey,  
   TopUp,  
   RefundToCustomer,  
   CNStatusID  
        from  
            etl_penPolicyTransaction  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction penPolicyTransaction  
  
        exec syssp_genericerrorhandler 'penPolicyTransaction data refresh failed'  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction penPolicyTransaction  
  
  
    /* sync rollup */  
    if object_id('etl_penPolicyTransaction_sync') is null  
        create table etl_penPolicyTransaction_sync  
        (  
            PolicyTransactionKey varchar(41) null  
        )  
    else  
        truncate table etl_penPolicyTransaction_sync  
  
  
    insert into etl_penPolicyTransaction_sync  
    (  
        PolicyTransactionKey  
    )  
    select  
        PolicyTransactionKey  
    from  
        etl_penPolicyTransaction  
  
  
    /* policy transaction promo */  
    if object_id('etl_penPolicyTransactionPromo') is not null  
        drop table etl_penPolicyTransactionPromo  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, ptp.PromoID) PromoKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        pt.TripsPolicyNumber collate database_default PolicyNumber,  
        ptp.PromoID,  
        ptp.PromoCode,  
        ptp.PromoName,  
        ptp.PromoType,  
        ptp.Discount,  
        ptp.IsApplied,  
        ptp.ApplyOrder,  
        ptp.GoBelowNet  
    into etl_penPolicyTransactionPromo  
    from  
        penguin_tblPolicyTransaction_aucm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk  
        cross apply  
        (  
            select  
                pr.PromoID,  
                pr.Code PromoCode,  
                pr.Name PromoName,  
                rv.Value PromoType,  
                ptp.Discount,  
                ptp.IsApplied,  
                ptp.ApplyOrder,  
                pr.GoBelowNet  
            from  
                penguin_tblPolicyTransactionPromo_aucm ptp  
                inner join penguin_tblPromo_aucm pr on  
                    pr.PromoID = ptp.PromoID  
                inner join penguin_tblReferenceValue_aucm rv on  
                    rv.ID = pr.PromoTypeID  
            where  
                ptp.PolicyTransactionID = pt.ID  
        ) ptp  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, ptp.PromoID) PromoKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        ptp.PromoID,  
        ptp.PromoCode,  
        ptp.PromoName,  
        ptp.PromoType,  
        ptp.Discount,  
        ptp.IsApplied,  
        ptp.ApplyOrder,  
        ptp.GoBelowNet  
    from  
        penguin_tblPolicyTransaction_autp pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk  
        cross apply  
        (  
            select  
                pr.PromoID,  
                pr.Code PromoCode,  
                pr.Name PromoName,  
                rv.Value PromoType,  
                ptp.Discount,  
                ptp.IsApplied,  
                ptp.ApplyOrder,  
                pr.GoBelowNet  
            from  
                penguin_tblPolicyTransactionPromo_autp ptp  
                inner join penguin_tblPromo_autp pr on  
                    pr.PromoID = ptp.PromoID  
                inner join penguin_tblReferenceValue_autp rv on  
                    rv.ID = pr.PromoTypeID  
            where  
                ptp.PolicyTransactionID = pt.ID  
        ) ptp  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, ptp.PromoID) PromoKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        ptp.PromoID,  
        ptp.PromoCode,  
        ptp.PromoName,  
        ptp.PromoType,  
        ptp.Discount,  
        ptp.IsApplied,  
        ptp.ApplyOrder,  
        ptp.GoBelowNet  
    from  
        penguin_tblPolicyTransaction_ukcm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk  
        cross apply  
        (  
            select  
                pr.PromoID,  
                pr.Code PromoCode,  
                pr.Name PromoName,  
                rv.Value PromoType,  
                ptp.Discount,  
                ptp.IsApplied,  
                ptp.ApplyOrder,  
                pr.GoBelowNet  
            from  
                penguin_tblPolicyTransactionPromo_ukcm ptp  
                inner join penguin_tblPromo_ukcm pr on  
                    pr.PromoID = ptp.PromoID  
                inner join penguin_tblReferenceValue_ukcm rv on  
                    rv.ID = pr.PromoTypeID  
            where  
                ptp.PolicyTransactionID = pt.ID  
        ) ptp  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, ptp.PromoID) PromoKey,  
        PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,  
        pt.TripsPolicyNumber  collate database_default PolicyNumber,  
        ptp.PromoID,  
        ptp.PromoCode,  
        ptp.PromoName,  
        ptp.PromoType,  
        ptp.Discount,  
        ptp.IsApplied,  
        ptp.ApplyOrder,  
        ptp.GoBelowNet  
    from  
        penguin_tblPolicyTransaction_uscm pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk  
        cross apply  
        (  
            select  
                pr.PromoID,  
                pr.Code PromoCode,  
                pr.Name PromoName,  
                rv.Value PromoType,  
                ptp.Discount,  
                ptp.IsApplied,  
                ptp.ApplyOrder,  
                pr.GoBelowNet  
            from  
                penguin_tblPolicyTransactionPromo_uscm ptp  
                inner join penguin_tblPromo_uscm pr on  
                    pr.PromoID = ptp.PromoID  
                inner join penguin_tblReferenceValue_uscm rv on  
                    rv.ID = pr.PromoTypeID  
            where  
                ptp.PolicyTransactionID = pt.ID  
        ) ptp  
  
    /* delete existing policy transaction promo */  
    if object_id('[db-au-cmdwh].dbo.penPolicyTransactionPromo') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyTransactionPromo]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [PromoKey] varchar(41) null,  
            [PolicyTransactionKey] varchar(41) null,  
            [PolicyNumber] varchar(50) null,  
            [PromoID] int null,  
            [PromoCode] nvarchar(10) null,  
            [PromoName] nvarchar(250) null,  
            [PromoType] nvarchar(50) null,  
            [Discount] numeric(10,4) null,  
            [IsApplied] bit null,  
            [ApplyOrder] int null,  
            [GoBelowNet] bit null  
        )  
  
        create clustered index idx_penPolicyTransactionPromo_PolicyTransactionKey on [db-au-cmdwh].dbo.penPolicyTransactionPromo(PolicyTransactionKey)  
        create nonclustered index idx_penPolicyTransactionPromo_PolicyNumber on [db-au-cmdwh].dbo.penPolicyTransactionPromo(PolicyNumber,CountryKey)  
        create nonclustered index idx_penPolicyTransactionPromo_PromoCode on [db-au-cmdwh].dbo.penPolicyTransactionPromo(PromoCode,CountryKey)  
        create nonclustered index idx_penPolicyTransactionPromo_PromoID on [db-au-cmdwh].dbo.penPolicyTransactionPromo(PromoID,CountryKey)  
        create nonclustered index idx_penPolicyTransactionPromo_PromoName on [db-au-cmdwh].dbo.penPolicyTransactionPromo(PromoName,CountryKey)  
  
    end  
  
  
    /* load policy transaction promo */  
    begin transaction penPolicyTransactionPromo  
  
    begin try  
  
        delete [db-au-cmdwh].dbo.penPolicyTransactionPromo  
        where  
            PolicyTransactionKey in  
            (  
                select distinct  
                    PolicyTransactionKey  
                from  
                    etl_penPolicyTransactionPromo  
            )  
  
        insert into [db-au-cmdwh].dbo.penPolicyTransactionPromo with (tablock)  
        (  
            CountryKey,  
            CompanyKey,  
            PromoKey,  
            PolicyTransactionKey,  
            PolicyNumber,  
            PromoID,  
            PromoCode,  
            PromoName,  
            PromoType,  
            Discount,  
            IsApplied,  
            ApplyOrder,  
            GoBelowNet  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            PromoKey,  
            PolicyTransactionKey,  
            PolicyNumber,  
            PromoID,  
            PromoCode,  
            PromoName,  
            PromoType,  
            Discount,  
            IsApplied,  
            ApplyOrder,  
            GoBelowNet  
        from  
            etl_penPolicyTransactionPromo  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction penPolicyTransactionPromo  
  
        exec syssp_genericerrorhandler 'penPolicyTransactionPromo data refresh failed'  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction penPolicyTransactionPromo  
  
  
end  
  
  

GO
