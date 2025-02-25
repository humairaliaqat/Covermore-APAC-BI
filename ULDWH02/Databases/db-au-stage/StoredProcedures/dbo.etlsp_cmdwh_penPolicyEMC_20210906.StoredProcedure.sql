USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyEMC_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyEMC_20210906]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120203  
Prerequisite:   Requires penguin data model successfully run prior to execution  
Description:    This stored procedure transforms tblPolicyEMC table.  
  
Change History:  
                20120203 - LT - Procedure created  
                20121107 - LS - refactoring & domain related changes  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20131204 - LS - case 19524, index optimisation for new pricing calculation  
                20140321 - LS - TFS9410, add EMC ApplicationKey  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
    20160321 - LT - Penguin 18.0, added US Penguin instance  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penPolicyEMC') is not null  
        drop table etl_penPolicyEMC  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pe.ID) PolicyEMCKey,  
        PrefixKey + convert(varchar, pe.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        CountryKey + '-' + ltrim(rtrim(pe.EMCRef)) collate database_default EMCApplicationKey,  
        DomainID,  
        pe.ID as PolicyEMCID,  
        pe.PolicyTravellerTransactionID,  
        pe.Title,  
        pe.FirstName,  
        pe.LastName,  
        dbo.xfn_ConvertUTCtoLocal(pe.DOB, TimeZone) DOB,  
        pe.EMCRef,  
        pe.EMCScore,  
        pe.PremiumIncrease,  
        pe.isPercentage,  
        pe.AddOnID  
    into etl_penPolicyEMC  
    from  
        penguin_tblPolicyEMC_aucm pe  
        cross apply  
        (  
            select top 1  
                pt.PolicyID,  
                pt.CRMUserID,  
                pt.ConsultantID  
            from  
                penguin_tblPolicyTravellerTransaction_aucm ptt  
                inner join penguin_tblPolicyTransaction_aucm pt on  
                    pt.ID = ptt.PolicyTransactionID  
            where  
                ptt.ID = pe.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pe.ID) PolicyEMCKey,  
        PrefixKey + convert(varchar, pe.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        CountryKey + '-' + ltrim(rtrim(pe.EMCRef)) collate database_default EMCApplicationKey,  
        DomainID,  
        pe.ID as PolicyEMCID,  
        pe.PolicyTravellerTransactionID,  
        pe.Title,  
        pe.FirstName,  
        pe.LastName,  
        dbo.xfn_ConvertUTCtoLocal(pe.DOB, TimeZone) DOB,  
        pe.EMCRef,  
        pe.EMCScore,  
        pe.PremiumIncrease,  
        pe.isPercentage,  
        pe.AddOnID  
    from  
        penguin_tblPolicyEMC_autp pe  
        cross apply  
        (  
            select top 1  
                pt.PolicyID,  
                pt.CRMUserID,  
                pt.ConsultantID  
            from  
                penguin_tblPolicyTravellerTransaction_autp ptt  
                inner join penguin_tblPolicyTransaction_autp pt on  
                    pt.ID = ptt.PolicyTransactionID  
            where  
                ptt.ID = pe.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pe.ID) PolicyEMCKey,  
        PrefixKey + convert(varchar, pe.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        CountryKey + '-' + ltrim(rtrim(pe.EMCRef)) collate database_default EMCApplicationKey,  
        DomainID,  
        pe.ID as PolicyEMCID,  
        pe.PolicyTravellerTransactionID,  
        pe.Title,  
        pe.FirstName,  
        pe.LastName,  
        dbo.xfn_ConvertUTCtoLocal(pe.DOB, TimeZone) DOB,  
        pe.EMCRef,  
        pe.EMCScore,  
        pe.PremiumIncrease,  
        pe.isPercentage,  
        pe.AddOnID  
    from  
        penguin_tblPolicyEMC_ukcm pe  
        cross apply  
        (  
            select top 1  
                pt.PolicyID,  
                pt.CRMUserID,  
                pt.ConsultantID  
            from  
                penguin_tblPolicyTravellerTransaction_ukcm ptt  
                inner join penguin_tblPolicyTransaction_ukcm pt on  
                    pt.ID = ptt.PolicyTransactionID  
            where  
                ptt.ID = pe.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, pe.ID) PolicyEMCKey,  
        PrefixKey + convert(varchar, pe.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        CountryKey + '-' + ltrim(rtrim(pe.EMCRef)) collate database_default EMCApplicationKey,  
        DomainID,  
        pe.ID as PolicyEMCID,  
        pe.PolicyTravellerTransactionID,  
        pe.Title,  
        pe.FirstName,  
        pe.LastName,  
        dbo.xfn_ConvertUTCtoLocal(pe.DOB, TimeZone) DOB,  
        pe.EMCRef,  
        pe.EMCScore,  
        pe.PremiumIncrease,  
        pe.isPercentage,  
        pe.AddOnID  
    from  
        penguin_tblPolicyEMC_uscm pe  
        cross apply  
        (  
            select top 1  
                pt.PolicyID,  
                pt.CRMUserID,  
                pt.ConsultantID  
            from  
                penguin_tblPolicyTravellerTransaction_uscm ptt  
                inner join penguin_tblPolicyTransaction_uscm pt on  
                    pt.ID = ptt.PolicyTransactionID  
            where  
                ptt.ID = pe.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk  
  
  
    if object_id('[db-au-cmdwh].dbo.penPolicyEMC') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyEMC]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [PolicyEMCKey] varchar(41) null,  
            [PolicyTravellerTransactionKey] varchar(41) null,  
            [PolicyEMCID] int not null,  
            [PolicyTravellerTransactionID] int not null,  
            [Title] nvarchar(50) null,  
            [FirstName] nvarchar(100) null,  
            [LastName] nvarchar(100) null,  
            [DOB] datetime not null,  
            [EMCRef] varchar(100) not null,  
            [EMCScore] numeric(10,4) null,  
            [PremiumIncrease] numeric(18,5) null,  
            [isPercentage] bit null,  
            [AddOnID] int null,  
            [DomainKey] varchar(41) null,  
            [DomainID] int null,  
            [EMCApplicationKey] varchar(41) null  
        )  
  
        create clustered index idx_penPolicyEMC_PolicyTravellerTransactionKey on [db-au-cmdwh].dbo.penPolicyEMC(PolicyTravellerTransactionKey)  
        create nonclustered index idx_penPolicyEMC_CountryKey on [db-au-cmdwh].dbo.penPolicyEMC(CountryKey)  
        create nonclustered index idx_penPolicyEMC_EMCApplicationKey on [db-au-cmdwh].dbo.penPolicyEMC(EMCApplicationKey) include (PolicyTravellerTransactionKey,EMCRef)  
        create nonclustered index idx_penPolicyEMC_EMCRef on [db-au-cmdwh].dbo.penPolicyEMC(EMCRef)  
        create nonclustered index idx_penPolicyEMC_Pricing on [db-au-cmdwh].dbo.penPolicyEMC(PolicyTravellerTransactionKey) include (PolicyEMCID)  
  
    end  
      
      
    begin transaction penPolicyEMC  
      
    begin try  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPolicyEMC a  
            inner join etl_penPolicyEMC b on  
                a.PolicyEMCKey = b.PolicyEMCKey and  
                a.PolicyTravellerTransactionKey = b.PolicyTravellerTransactionKey  
  
        insert [db-au-cmdwh].dbo.penPolicyEMC with(tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            DomainKey,  
            PolicyEMCKey,  
            PolicyTravellerTransactionKey,  
            EMCApplicationKey,  
            DomainID,  
            PolicyEMCID,  
            PolicyTravellerTransactionID,  
            Title,  
            FirstName,  
            LastName,  
            DOB,  
            EMCRef,  
            EMCScore,  
            PremiumIncrease,  
            isPercentage,  
            AddonID  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            DomainKey,  
            PolicyEMCKey,  
            PolicyTravellerTransactionKey,  
            EMCApplicationKey,  
            DomainID,  
            PolicyEMCID,  
            PolicyTravellerTransactionID,  
            Title,  
            FirstName,  
            LastName,  
            DOB,  
            EMCRef,  
            EMCScore,  
            PremiumIncrease,  
            isPercentage,  
            AddonID  
        from  
            etl_penPolicyEMC  
  
    end try  
      
    begin catch  
      
        if @@trancount > 0  
            rollback transaction penPolicyEMC  
              
        exec syssp_genericerrorhandler 'penPolicyEMC data refresh failed'  
          
    end catch      
  
    if @@trancount > 0  
        commit transaction penPolicyEMC  
  
end  
  
GO
