USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyTravellerAddOn]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyTravellerAddOn]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120127  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    Transform penPolicyTravellerAddOn table and adding essential key fields  
  
Change History:  
                20120127 - LT - Procedure created  
                20121108 - LS - refactoring & domain related changes  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20131204 - LS - case 19524, index optimisation for new pricing calculation  
                20131212 - LS - index optimisation for addon summary  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
    20160321 - LT - Penguin 18.0, added US penguin instance  
  20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penPolicyTravellerAddOn') is not null  
        drop table etl_penPolicyTravellerAddOn  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pa.ID) PolicyTravellerAddOnKey,  
        PrefixKey + convert(varchar, pa.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pa.AddOnID) AddOnKey,  
        pa.ID as PolicyTravellerAddOnID,  
        pa.PolicyTravellerTransactionID,  
        pa.AddOnID,  
        a.AddonCode,  
        a.AddonName,  
        a.DisplayName,  
        pa.AddOnValueID,  
        av.AddonValueCode,  
        av.AddonValueDesc,  
        av.AddonValuePremiumIncrease,  
        pa.CoverIncrease,  
        pa.AddOnGroup,  
        pa.AddOnText,  
        pa.isRateCardBased  
    into etl_penPolicyTravellerAddOn  
    from  
        penguin_tblPolicyTravellerAddOn_aucm pa  
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
                ptt.ID = pa.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                AddonCode,  
                AddonName,  
                DisplayName  
            from  
                penguin_tblAddon_aucm a  
            where  
                a.AddonID = pa.AddonID  
        ) a  
        outer apply  
        (  
            select top 1  
                Code AddonValueCode,  
                [Description] AddonValueDesc,  
                PremiumIncrease AddonValuePremiumIncrease  
            from  
                penguin_tblAddonValue_aucm av  
            where  
                av.AddonValueID = pa.AddonValueID  
        ) av  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pa.ID) PolicyTravellerAddOnKey,  
        PrefixKey + convert(varchar, pa.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pa.AddOnID) AddOnKey,  
        pa.ID as PolicyTravellerAddOnID,  
        pa.PolicyTravellerTransactionID,  
        pa.AddOnID,  
        a.AddonCode,  
     a.AddonName,  
        a.DisplayName,  
        pa.AddOnValueID,  
        av.AddonValueCode,  
        av.AddonValueDesc,  
        av.AddonValuePremiumIncrease,  
        pa.CoverIncrease,  
        pa.AddOnGroup,  
        pa.AddOnText,  
        pa.isRateCardBased  
    from  
        penguin_tblPolicyTravellerAddOn_autp pa  
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
                ptt.ID = pa.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk  
        outer apply  
        (  
            select top 1  
                AddonCode,  
                AddonName,  
                DisplayName  
            from  
                penguin_tblAddon_autp a  
            where  
                a.AddonID = pa.AddonID  
        ) a  
        outer apply  
        (  
            select top 1  
                Code AddonValueCode,  
                [Description] AddonValueDesc,  
                PremiumIncrease AddonValuePremiumIncrease  
            from  
                penguin_tblAddonValue_autp av  
            where  
                av.AddonValueID = pa.AddonValueID  
        ) av  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pa.ID) PolicyTravellerAddOnKey,  
        PrefixKey + convert(varchar, pa.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pa.AddOnID) AddOnKey,  
        pa.ID as PolicyTravellerAddOnID,  
        pa.PolicyTravellerTransactionID,  
        pa.AddOnID,  
        a.AddonCode,  
        a.AddonName,  
        a.DisplayName,  
        pa.AddOnValueID,  
        av.AddonValueCode,  
        av.AddonValueDesc,  
        av.AddonValuePremiumIncrease,  
        pa.CoverIncrease,  
        pa.AddOnGroup,  
        pa.AddOnText,  
        pa.isRateCardBased  
    from  
        penguin_tblPolicyTravellerAddOn_ukcm pa  
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
                ptt.ID = pa.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                AddonCode,  
                AddonName,  
                DisplayName  
            from  
                penguin_tblAddon_ukcm a  
            where  
                a.AddonID = pa.AddonID  
        ) a  
        outer apply  
        (  
            select top 1  
                Code AddonValueCode,  
                [Description] AddonValueDesc,  
                PremiumIncrease AddonValuePremiumIncrease  
            from  
                penguin_tblAddonValue_ukcm av  
            where  
                av.AddonValueID = pa.AddonValueID  
        ) av  
	where PrefixKey + convert(varchar, pa.PolicyTravellerTransactionID) not in 
	(select PrefixKey + convert(varchar, ptt.ID) 
	from penguin_tblPolicyTravellerTransaction_ukcm ptt  
        inner join penguin_tblPolicyTransaction_ukcm pt on  
            pt.ID = ptt.PolicyTransactionID  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk
	where PrefixKey + convert(varchar, ptt.PolicyTravellerID) in 
		(select PrefixKey + convert(varchar, pt.ID) PolicyTravellerKey from penguin_tblPolicyTraveller_ukcm pt    
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, null, null, 'CM', 'UK') dk 
		where (PrefixKey + convert(varchar, pt.PolicyID)) in (select PrefixKey + convert(varchar, PolicyID) from Penguin_tblpolicy_ukcm cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'UK') dk where AlphaCode like 'BK%'))) ------adding condition to filter out BK.com data  
   
   union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + convert(varchar, pa.ID) PolicyTravellerAddOnKey,  
        PrefixKey + convert(varchar, pa.PolicyTravellerTransactionID) PolicyTravellerTransactionKey,  
        PrefixKey + convert(varchar, pa.AddOnID) AddOnKey,  
        pa.ID as PolicyTravellerAddOnID,  
        pa.PolicyTravellerTransactionID,  
        pa.AddOnID,  
        a.AddonCode,  
        a.AddonName,  
        a.DisplayName,  
        pa.AddOnValueID,  
        av.AddonValueCode,  
        av.AddonValueDesc,  
        av.AddonValuePremiumIncrease,  
        pa.CoverIncrease,  
        pa.AddOnGroup,  
        pa.AddOnText,  
        pa.isRateCardBased  
    from  
        penguin_tblPolicyTravellerAddOn_uscm pa  
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
                ptt.ID = pa.PolicyTravellerTransactionID  
        ) pt  
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk  
        outer apply  
        (  
            select top 1  
                AddonCode,  
                AddonName,  
                DisplayName  
            from  
                penguin_tblAddon_uscm a  
            where  
                a.AddonID = pa.AddonID  
        ) a  
        outer apply  
        (  
            select top 1  
                Code AddonValueCode,  
                [Description] AddonValueDesc,  
                PremiumIncrease AddonValuePremiumIncrease  
            from  
                penguin_tblAddonValue_uscm av  
            where  
                av.AddonValueID = pa.AddonValueID  
        ) av  
  
  
    if object_id('[db-au-cmdwh].dbo.penPolicyTravellerAddOn') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyTravellerAddOn]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [PolicyTravellerAddOnKey] varchar(41) null,  
            [PolicyTravellerTransactionKey] varchar(41) null,  
            [AddOnKey] varchar(33) null,  
            [PolicyTravellerAddOnID] int not null,  
            [PolicyTravellerTransactionID] int not null,  
            [AddOnID] int not null,  
            [AddonCode] nvarchar(50) null,  
            [AddonName] nvarchar(50) null,  
            [DisplayName] nvarchar(100) null,  
            [AddOnValueID] int not null,  
            [AddonValueCode] nvarchar(10) null,  
            [AddonValueDesc] nvarchar(50) null,  
            [AddonValuePremiumIncrease] numeric(18,5) null,  
            [CoverIncrease] money not null,  
            [AddOnGroup] nvarchar(50) null,  
            [AddOnText] nvarchar(500) null,  
            [isRateCardBased] bit not null  
        )  
  
        create clustered index idx_penPolicyTravellerAddOn_PolicyTravellerTransactionKey on [db-au-cmdwh].dbo.penPolicyTravellerAddOn(PolicyTravellerTransactionKey)  
        create nonclustered index idx_penPolicyTravellerAddOn_AddOnKey on [db-au-cmdwh].dbo.penPolicyTravellerAddOn(AddOnKey)  
        create nonclustered index idx_penPolicyTravellerAddOn_CountryKey on [db-au-cmdwh].dbo.penPolicyTravellerAddOn(CountryKey)  
        create nonclustered index idx_penPolicyTravellerAddOn_PolicyTravellerAddOnKey on [db-au-cmdwh].dbo.penPolicyTravellerAddOn(PolicyTravellerAddOnKey)  
        create nonclustered index idx_penPolicyTravellerAddOn_Price on [db-au-cmdwh].dbo.penPolicyTravellerAddOn(PolicyTravellerTransactionKey) include (AddOnGroup,PolicyTravellerAddOnID,CoverIncrease,AddOnText)  
  
    end  
      
      
    begin transaction penPolicyTravellerAddOn  
      
    begin try  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPolicyTravellerAddOn a  
            inner join etl_penPolicyTravellerAddOn b on  
                a.PolicyTravellerAddonKey = b.PolicyTravellerAddOnKey and  
                a.PolicyTravellerTransactionKey = b.PolicyTravellerTransactionKey  
  
        insert into [db-au-cmdwh].dbo.penPolicyTravellerAddOn with(tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            PolicyTravellerAddOnKey,  
            PolicyTravellerTransactionKey,  
            AddOnKey,  
            PolicyTravellerAddOnID,  
            PolicyTravellerTransactionID,  
     AddOnID,  
            AddonCode,  
            AddonName,  
            DisplayName,  
            AddOnValueID,  
            AddonValueCode,  
            AddonValueDesc,  
            AddonValuePremiumIncrease,  
            CoverIncrease,  
            AddOnGroup,  
            AddOnText,  
            isRateCardBased  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            PolicyTravellerAddOnKey,  
            PolicyTravellerTransactionKey,  
            AddOnKey,  
            PolicyTravellerAddOnID,  
            PolicyTravellerTransactionID,  
            AddOnID,  
            AddonCode,  
            AddonName,  
            DisplayName,  
            AddOnValueID,  
            AddonValueCode,  
            AddonValueDesc,  
            AddonValuePremiumIncrease,  
            CoverIncrease,  
            AddOnGroup,  
            AddOnText,  
            isRateCardBased  
        from  
            etl_penPolicyTravellerAddOn  
  
    end try  
      
    begin catch  
      
        if @@trancount > 0  
            rollback transaction penPolicyTravellerAddOn  
              
        exec syssp_genericerrorhandler 'penPolicyTravellerAddOn data refresh failed'  
          
    end catch      
  
    if @@trancount > 0  
        commit transaction penPolicyTravellerAddOn  
          
end  
  
GO
