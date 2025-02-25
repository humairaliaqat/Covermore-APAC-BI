USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyTax_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyTax_20210906]  
as  
begin  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120124  
Prerequisite:   Requires penguin data model successfully run prior to execution  
Description:    penPolicyTax transformation adds essential key fields  
  
Change History:  
                20120203 - LT - Procedure created  
                20121107 - LS - refactoring & domain related changes  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20130812 - LS - performance fixes, dump raw data before grouping  
                                (this is a huge table with >2mil rows every time it runs)  
                20131204 - LS - case 19524, index optimisation for new pricing calculation (prevent expensive physical disk re-sorting)  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
                                speed up deletion by using clustered index   
    20160321 - LT - Penguin 18.0, added US Penguin instance  
                                      
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penPolicyTax') is not null  
        drop table etl_penPolicyTax  
  
    if object_id('tempdb..#penPolicyTax') is not null  
        drop table #penPolicyTax  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pat.ID) PolicyTaxKey,  
        PrefixKey + convert(varchar, pat.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,  
        DomainID,  
        pat.ID as PolicyTaxID,  
        pat.PolicyTravellerTransactionID,  
        pat.TaxID,  
        tx.TaxName,  
        tx.TaxRate,  
        tx.TaxType,  
        (case when pat.isPOSDiscount = 0 then pat.TaxAmount else 0 end) as TaxAmount,  
        (case when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentComm,  
        (case when pat.isPOSDiscount = 1 then pat.TaxAmount else 0 end) as TaxAmountPOSDisc,  
        (case when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentCommPOSDisc  
    into #penPolicyTax  
    from  
        dbo.penguin_tblPolicyTax_aucm pat  
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
                ptt.ID = pat.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                ta.TaxName,  
                ta.TaxRate,  
                tt.TaxType  
            from  
                penguin_tblTax_aucm ta  
                inner join penguin_tblTaxType_aucm tt on  
                    ta.TaxTypeID = tt.TaxTypeID  
            where  
                ta.TaxID = pat.TaxID  
        ) tx  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pat.ID) PolicyTaxKey,  
        PrefixKey + convert(varchar, pat.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,  
        DomainID,  
        pat.ID as PolicyTaxID,  
        pat.PolicyTravellerTransactionID,  
        pat.TaxID,  
        tx.TaxName,  
        tx.TaxRate,  
        tx.TaxType,  
        (case when pat.isPOSDiscount = 0 then pat.TaxAmount else 0 end) as TaxAmount,  
        (case when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentComm,  
        (case when pat.isPOSDiscount = 1 then pat.TaxAmount else 0 end) as TaxAmountPOSDisc,  
        (case when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentCommPOSDisc  
    from  
        penguin_tblPolicyTax_autp pat  
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
                ptt.ID = pat.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk  
        outer apply  
        (  
            select top 1  
                ta.TaxName,  
                ta.TaxRate,  
                tt.TaxType  
            from  
                penguin_tblTax_autp ta  
                inner join penguin_tblTaxType_autp tt on  
                    ta.TaxTypeID = tt.TaxTypeID  
            where  
                ta.TaxID = pat.TaxID  
        ) tx  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pat.ID) PolicyTaxKey,  
        PrefixKey + convert(varchar, pat.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,  
        DomainID,  
        pat.ID as PolicyTaxID,  
        pat.PolicyTravellerTransactionID,  
        pat.TaxID,  
        tx.TaxName,  
        tx.TaxRate,  
        tx.TaxType,  
        (case when pat.isPOSDiscount = 0 then pat.TaxAmount else 0 end) as TaxAmount,  
        (case when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentComm,  
        (case when pat.isPOSDiscount = 1 then pat.TaxAmount else 0 end) as TaxAmountPOSDisc,  
        (case when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentCommPOSDisc  
    from  
        dbo.penguin_tblPolicyTax_ukcm pat  
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
                ptt.ID = pat.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                ta.TaxName,  
                ta.TaxRate,  
                tt.TaxType  
            from  
                penguin_tblTax_ukcm ta  
                inner join penguin_tblTaxType_ukcm tt on  
                    ta.TaxTypeID = tt.TaxTypeID  
            where  
                ta.TaxID = pat.TaxID  
        ) tx  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pat.ID) PolicyTaxKey,  
        PrefixKey + convert(varchar, pat.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,  
        DomainID,  
        pat.ID as PolicyTaxID,  
        pat.PolicyTravellerTransactionID,  
        pat.TaxID,  
        tx.TaxName,  
        tx.TaxRate,  
        tx.TaxType,  
        (case when pat.isPOSDiscount = 0 then pat.TaxAmount else 0 end) as TaxAmount,  
  (case when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentComm,  
        (case when pat.isPOSDiscount = 1 then pat.TaxAmount else 0 end) as TaxAmountPOSDisc,  
        (case when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm else 0 end) as TaxOnAgentCommPOSDisc  
    from  
        dbo.penguin_tblPolicyTax_uscm pat  
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
                ptt.ID = pat.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk  
        outer apply  
        (  
            select top 1  
                ta.TaxName,  
                ta.TaxRate,  
                tt.TaxType  
            from  
                penguin_tblTax_uscm ta  
                inner join penguin_tblTaxType_uscm tt on  
                    ta.TaxTypeID = tt.TaxTypeID  
            where  
                ta.TaxID = pat.TaxID  
        ) tx  
  
  
    select  
        CountryKey,  
        CompanyKey,  
        PolicyTaxKey,  
        PolicyTravellerTransactionKey,  
        TaxKey,  
        DomainID,  
        PolicyTaxID,  
        PolicyTravellerTransactionID,  
        TaxID,  
        TaxName,  
        TaxRate,  
        TaxType,  
        sum(TaxAmount) TaxAmount,  
        sum(TaxOnAgentComm) TaxOnAgentComm,  
        sum(TaxAmountPOSDisc) TaxAmountPOSDisc,  
        sum(TaxOnAgentCommPOSDisc) TaxOnAgentCommPOSDisc  
    into etl_penPolicyTax  
    from  
        #penPolicyTax  
    group by  
        CountryKey,  
        CompanyKey,  
        PolicyTaxKey,  
        PolicyTravellerTransactionKey,  
        TaxKey,  
        DomainID,  
        PolicyTaxID,  
        PolicyTravellerTransactionID,  
        TaxID,  
        TaxName,  
        TaxRate,  
        TaxType  
  
    if object_id('[db-au-cmdwh].dbo.penPolicyTax') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyTax]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [PolicyTaxKey] varchar(41) null,  
            [PolicyTravellerTransactionKey] varchar(41) null,  
            [TaxKey] varchar(41) null,  
            [PolicyTaxID] int not null,  
            [PolicyTravellerTransactionID] int not null,  
            [TaxID] int not null,  
            [TaxName] nvarchar(50) null,  
            [TaxRate] numeric(18,5) null,  
            [TaxType] nvarchar(50) null,  
            [TaxAmount] money null,  
            [TaxOnAgentComm] money null,  
            [TaxAmountPOSDisc] money null,  
            [TaxOnAgentCommPOSDisc] money null,  
            [DomainID] int null  
        )  
  
        create clustered index idx_penPolicyTax_PolicyTaxID on [db-au-cmdwh].dbo.penPolicyTax(PolicyTaxID)  
        create nonclustered index idx_penPolicyTax_PolicyTravellerTransactionKey on [db-au-cmdwh].dbo.penPolicyTax(PolicyTravellerTransactionKey) include (TaxName,TaxType,TaxAmount,TaxOnAgentComm,TaxAmountPOSDisc,TaxOnAgentCommPOSDisc)  
  
    end  
      
      
    begin transaction penPolicyTax  
      
    begin try  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPolicyTax a  
            inner join etl_penPolicyTax b on  
                a.PolicyTaxID = b.PolicyTaxID and  
                a.CompanyKey = b.CompanyKey and  
                a.CountryKey = b.CountryKey  
  
        insert [db-au-cmdwh].dbo.penPolicyTax with(tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            PolicyTaxKey,  
            PolicyTravellerTransactionKey,  
            TaxKey,  
            DomainID,  
            PolicyTaxID,  
            PolicyTravellerTransactionID,  
            TaxID,  
            TaxName,  
            TaxRate,  
            TaxType,  
            TaxAmount,  
            TaxOnAgentComm,  
            TaxAmountPOSDisc,  
            TaxOnAgentCommPOSDisc  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            PolicyTaxKey,  
            PolicyTravellerTransactionKey,  
            TaxKey,  
            DomainID,  
            PolicyTaxID,  
            PolicyTravellerTransactionID,  
            TaxID,  
            TaxName,  
            TaxRate,  
            TaxType,  
            TaxAmount,  
            TaxOnAgentComm,  
            TaxAmountPOSDisc,  
            TaxOnAgentCommPOSDisc  
        from  
            etl_penPolicyTax  
  
    end try  
      
    begin catch  
      
        if @@trancount > 0  
            rollback transaction penPolicyTax  
              
        exec syssp_genericerrorhandler 'penPolicyTax data refresh failed'  
          
    end catch      
  
    if @@trancount > 0  
        commit transaction penPolicyTax  
          
end  
  
GO
