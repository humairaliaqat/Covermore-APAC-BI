USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyPrice_20210906]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
create procedure [dbo].[etlsp_cmdwh_penPolicyPrice_20210906]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120124  
Prerequisite:   Requires penguin_tblPolicyPrice_au successfully transferred from  Penguin production database.  
Description:    PolicyPrice table contains pricing details for a number of components:  
                - tblPolicyAddOn: joins on tblPolicyAddOn.ID = PolicyPrice.ComponentID and PolicyPrice.GroupID = 4  
                - tblPolicyTravellerAddOn: joins on tblPolicyTravellerAddOn.ID = PolicyPrice.ComponentID and PolicyPrice.GroupID = 3  
                - tblPolicyTravellerTransaction: joins on tblPolicyTravellerTransaction.ID = PolicyPrice.ComponentID and PolicyPrice.GroupID = 2  
                - tblPolicyEMC: joins on tblPolicyEMC.ID = PolicyPrice.ComponentID and PolicyPrice.GroupID = 5  
  
                The transformation adds in key fields  
  
Change History:  
                20120124 - LT - Procedure created  
                20121107 - LS  
                                It's hard to get Domain ID for tblPolicyPrice (more precisely, it's a very expensive operation due to table truncating).  
                                for now policy key will use company as prefix (with current condition that there will be no duplicate ids on CM for AU, NZ, MY & SG)  
                                this stored proc (or any newly created) will need to be aware of this limitation:  
                                etlsp_cmdwh_penPolicyTransPricing  
                                TODO: change this table to fact table  
                20121212 - LS - change to fact table  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20130819 - LS - case 19018, critical bug found, UK data causes duplicate ids  
                                solution: now that all policy related tables are in parity (all referred to tblPolicyTransaction) it's possible to get the domain id  
                                addon: store PolicyTransactionID to ease further investigation  
                20131204 - LS - case 19524, index optimisation for new pricing calculation  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
                20160321 - LT - Penguin 18.0, added US Penguin instance  
    20170105 - LT - Source tblPolicyPrice had DiscountRate column data length increased to numeric(12,9). This caused insert failure.  
        Increased data length to following:  
          CommissionRate numeric(15,9) null  
          DiscountRate numeric(15,9) null  
  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_PolicyPrice') is not null  
        drop table etl_PolicyPrice  
  
    if object_id('etl_PolicyPriceComponent') is not null  
        drop table etl_PolicyPriceComponent  
  
    /* the lengthy domain id retrieval */  
    --AU CM  
    select  
        'AU' CountrySet,  
        'CM' Company,  
        2 GroupID,  
        ptt.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    into etl_PolicyPriceComponent  
    from  
        penguin_tblPolicyTravellerTransaction_aucm ptt  
        inner join penguin_tblPolicyTransaction_aucm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_aucm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'CM' Company,  
        3 GroupID,  
        pta.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerAddOn_aucm pta  
        inner join penguin_tblPolicyTravellerTransaction_aucm ptt on  
      ptt.ID = pta.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_aucm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_aucm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'CM' Company,  
        4 GroupID,  
        pa.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyAddOn_aucm pa  
        inner join penguin_tblPolicyTransaction_aucm pt on  
            pt.ID = pa.PolicyTransactionID  
        inner join penguin_tblPolicy_aucm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'CM' Company,  
        5 GroupID,  
        pe.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyEMC_aucm pe  
        inner join penguin_tblPolicyTravellerTransaction_aucm ptt on  
            ptt.ID = pe.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_aucm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_aucm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    --AU TIP  
    select  
        'AU' CountrySet,  
        'TIP' Company,  
        2 GroupID,  
        ptt.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerTransaction_autp ptt  
        inner join penguin_tblPolicyTransaction_autp pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_autp p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'TIP' Company,  
        3 GroupID,  
        pta.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerAddOn_autp pta  
        inner join penguin_tblPolicyTravellerTransaction_autp ptt on  
            ptt.ID = pta.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_autp pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_autp p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'TIP' Company,  
        4 GroupID,  
        pa.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyAddOn_autp pa  
        inner join penguin_tblPolicyTransaction_autp pt on  
            pt.ID = pa.PolicyTransactionID  
        inner join penguin_tblPolicy_autp p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'AU' CountrySet,  
        'TIP' Company,  
        5 GroupID,  
        pe.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyEMC_autp pe  
        inner join penguin_tblPolicyTravellerTransaction_autp ptt on  
            ptt.ID = pe.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_autp pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_autp p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    --UK CM  
    select  
        'UK' CountrySet,  
        'CM' Company,  
        2 GroupID,  
        ptt.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerTransaction_ukcm ptt  
        inner join penguin_tblPolicyTransaction_ukcm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_ukcm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'UK' CountrySet,  
        'CM' Company,  
        3 GroupID,  
        pta.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerAddOn_ukcm pta  
        inner join penguin_tblPolicyTravellerTransaction_ukcm ptt on  
            ptt.ID = pta.PolicyTravellerTransactionID  
    inner join penguin_tblPolicyTransaction_ukcm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_ukcm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'UK' CountrySet,  
        'CM' Company,  
        4 GroupID,  
        pa.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyAddOn_ukcm pa  
        inner join penguin_tblPolicyTransaction_ukcm pt on  
            pt.ID = pa.PolicyTransactionID  
        inner join penguin_tblPolicy_ukcm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'UK' CountrySet,  
        'CM' Company,  
        5 GroupID,  
        pe.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyEMC_ukcm pe  
        inner join penguin_tblPolicyTravellerTransaction_ukcm ptt on  
            ptt.ID = pe.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_ukcm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_ukcm p on  
            p.PolicyID = pt.PolicyID  
  
 union  
  
    --US CM  
    select  
        'US' CountrySet,  
        'CM' Company,  
        2 GroupID,  
        ptt.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerTransaction_uscm ptt  
        inner join penguin_tblPolicyTransaction_uscm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_uscm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'US' CountrySet,  
        'CM' Company,  
        3 GroupID,  
        pta.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyTravellerAddOn_uscm pta  
        inner join penguin_tblPolicyTravellerTransaction_uscm ptt on  
            ptt.ID = pta.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_uscm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_uscm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'US' CountrySet,  
        'CM' Company,  
        4 GroupID,  
        pa.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyAddOn_uscm pa  
        inner join penguin_tblPolicyTransaction_uscm pt on  
            pt.ID = pa.PolicyTransactionID  
        inner join penguin_tblPolicy_uscm p on  
            p.PolicyID = pt.PolicyID  
  
    union  
  
    select  
        'US' CountrySet,  
        'CM' Company,  
        5 GroupID,  
        pe.ID ComponentID,  
        p.DomainId,  
        pt.ID PolicyTransactionID  
    from  
        penguin_tblPolicyEMC_uscm pe  
        inner join penguin_tblPolicyTravellerTransaction_uscm ptt on  
            ptt.ID = pe.PolicyTravellerTransactionID  
        inner join penguin_tblPolicyTransaction_uscm pt on  
            pt.ID = ptt.PolicyTransactionID  
        inner join penguin_tblPolicy_uscm p on  
            p.PolicyID = pt.PolicyID  
  
  
    create index idx on etl_PolicyPriceComponent (GroupID, ComponentID, CountrySet, Company) include (DomainID, PolicyTransactionID)  
  
    /*end of domain id retrieval*/  
  
    select  
        dk.CountryKey,  
        dk.CompanyKey,  
        left(PrefixKey + convert(varchar, pp.ID), 41) PolicyPriceKey,  
        ppc.PolicyTransactionID,  
        pp.ID,  
        pp.GroupID,  
        pp.ComponentID,  
        pp.GrossPremium,  
        pp.BasePremium,  
        pp.AdjustedNet,  
        pp.Commission,  
        pp.CommissionRate,  
        pp.Discount,  
        pp.DiscountRate,  
        pp.BaseAdminFee,  
        pp.GrossAdminFee,  
        pp.isPOSDiscount  
    into etl_PolicyPrice  
    from  
        penguin_tblPolicyPrice_aucm pp  
        inner join etl_PolicyPriceComponent ppc on  
            ppc.GroupID = pp.GroupID and  
            ppc.ComponentID = pp.ComponentID and  
          ppc.CountrySet = 'AU' and  
            ppc.Company = 'CM'  
        cross apply dbo.fn_GetDomainKeys(ppc.DomainID, ppc.Company, ppc.CountrySet) dk  
  
    union all  
  
    select  
        dk.CountryKey,  
        dk.CompanyKey,  
        left(PrefixKey + convert(varchar, pp.ID), 41) PolicyPriceKey,  
        ppc.PolicyTransactionID,  
        pp.ID,  
        pp.GroupID,  
        pp.ComponentID,  
        pp.GrossPremium,  
        pp.BasePremium,  
        pp.AdjustedNet,  
        pp.Commission,  
        pp.CommissionRate,  
        pp.Discount,  
        pp.DiscountRate,  
        pp.BaseAdminFee,  
        pp.GrossAdminFee,  
        pp.isPOSDiscount  
    from  
        penguin_tblPolicyPrice_autp pp  
        inner join etl_PolicyPriceComponent ppc on  
            ppc.GroupID = pp.GroupID and  
            ppc.ComponentID = pp.ComponentID and  
            ppc.CountrySet = 'AU' and  
            ppc.Company = 'TIP'  
        cross apply dbo.fn_GetDomainKeys(ppc.DomainID, ppc.Company, ppc.CountrySet) dk  
  
    union all  
  
    select  
        dk.CountryKey,  
        dk.CompanyKey,  
        left(PrefixKey + convert(varchar, pp.ID), 41) PolicyPriceKey,  
        ppc.PolicyTransactionID,  
        pp.ID,  
        pp.GroupID,  
        pp.ComponentID,  
        pp.GrossPremium,  
        pp.BasePremium,  
        pp.AdjustedNet,  
        pp.Commission,  
        pp.CommissionRate,  
        pp.Discount,  
        pp.DiscountRate,  
        pp.BaseAdminFee,  
        pp.GrossAdminFee,  
        pp.isPOSDiscount  
    from  
        penguin_tblPolicyPrice_ukcm pp  
        inner join etl_PolicyPriceComponent ppc on  
            ppc.GroupID = pp.GroupID and  
            ppc.ComponentID = pp.ComponentID and  
            ppc.CountrySet = 'UK' and  
            ppc.Company = 'CM'  
        cross apply dbo.fn_GetDomainKeys(ppc.DomainID, ppc.Company, ppc.CountrySet) dk  
    
    union all  
  
    select  
        dk.CountryKey,  
        dk.CompanyKey,  
        left(PrefixKey + convert(varchar, pp.ID), 41) PolicyPriceKey,  
        ppc.PolicyTransactionID,  
        pp.ID,  
        pp.GroupID,  
        pp.ComponentID,  
        pp.GrossPremium,  
        pp.BasePremium,  
        pp.AdjustedNet,  
        pp.Commission,  
        pp.CommissionRate,  
        pp.Discount,  
        pp.DiscountRate,  
        pp.BaseAdminFee,  
        pp.GrossAdminFee,  
        pp.isPOSDiscount  
    from  
        penguin_tblPolicyPrice_uscm pp  
        inner join etl_PolicyPriceComponent ppc on  
            ppc.GroupID = pp.GroupID and  
            ppc.ComponentID = pp.ComponentID and  
            ppc.CountrySet = 'US' and  
            ppc.Company = 'CM'  
        cross apply dbo.fn_GetDomainKeys(ppc.DomainID, ppc.Company, ppc.CountrySet) dk  
  
  
    create index idx_main on etl_PolicyPrice(CountryKey, CompanyKey, ComponentID, GroupID)  
  
    if object_id('[db-au-cmdwh].dbo.penPolicyPrice') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.penPolicyPrice  
        (  
            CountryKey varchar(2) not null,  
            CompanyKey varchar(5) not null,  
            PolicyPriceKey varchar(41) not null,  
            PolicyTransactionID int,  
            ID int not null,  
            GroupID int not null,  
            ComponentID int not null,  
            GrossPremium money null,  
            BasePremium money not null,  
            AdjustedNet money not null,  
            Commission money not null,  
            CommissionRate numeric(15,9) null,  
            Discount money not null,  
            DiscountRate numeric(15,9) null,  
            BaseAdminFee money null,  
            GrossAdminFee money null,  
            isPOSDiscount bit null  
        )  
  
        create clustered index idx_PolicyPrice_ID on [db-au-cmdwh].dbo.penPolicyPrice(ID)  
        create index idx_PolicyPrice_Composite on [db-au-cmdwh].dbo.penPolicyPrice(CountryKey, CompanyKey, GroupID, ComponentID)  
            include  
            (  
                BasePremium,  
                GrossPremium,  
                Commission,  
                Discount,  
                GrossAdminFee,  
                CommissionRate,  
                DiscountRate,  
                AdjustedNet,  
                isPosDiscount,  
                BaseAdminFee  
            )  
        create index idx_PolicyPrice_PolicyTransactionID on [db-au-cmdwh].dbo.penPolicyPrice(PolicyTransactionID) include(CountryKey, CompanyKey)  
  
    end  
  
  
    begin transaction penPolicyPrice  
      
    begin try  
  
        delete pp  
        from  
            [db-au-cmdwh].dbo.penPolicyPrice pp  
            inner join etl_PolicyPrice t on  
                t.CompanyKey = pp.CompanyKey and  
                t.ComponentID = pp.ComponentID and  
                t.GroupID = pp.GroupID and  
                t.CountryKey = pp.CountryKey  
  
        insert into [db-au-cmdwh].dbo.penPolicyPrice with (tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            PolicyPriceKey,  
            PolicyTransactionID,  
            ID,  
            GroupID,  
            ComponentID,  
            GrossPremium,  
            BasePremium,  
            AdjustedNet,  
            Commission,  
            CommissionRate,  
            Discount,  
            DiscountRate,  
            BaseAdminFee,  
            GrossAdminFee,  
            isPOSDiscount  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            PolicyPriceKey,  
            PolicyTransactionID,  
            ID,  
            GroupID,  
            ComponentID,  
            GrossPremium,  
            BasePremium,  
            AdjustedNet,  
            Commission,  
            CommissionRate,  
            Discount,  
            DiscountRate,  
            BaseAdminFee,  
            GrossAdminFee,  
            isPOSDiscount  
        from  
            etl_PolicyPrice  
              
    end try  
      
    begin catch  
      
        if @@trancount > 0  
            rollback transaction penPolicyPrice  
              
        exec syssp_genericerrorhandler 'penPolicyPrice data refresh failed'  
          
    end catch      
  
    if @@trancount > 0  
        commit transaction penPolicyPrice  
  
end  
  
GO
