USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penOutletSalesTarget]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penOutletSalesTarget]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20160531  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    OutletSalesTargets table contains Gross Sell Price targets per alpha code  
                This transformation adds essential key fields  
Change History:  
                20160531 - LT - Procedure created as part of Penguin 19.0 release  
		20210306, SS, CHG0034615 Add filter for BK.com  
  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penOutletSalesTarget') is not null  
        drop table etl_penOutletSalesTarget  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.ID) as OutletSalesTargetKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.ID as OutletSalesTargetID,  
  os.[Month],  
  os.GrossSellPriceTarget  
    into etl_penOutletSalesTarget  
    from  
        dbo.penguin_tblOutlet_aucm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'AU') dk  
        inner join dbo.penguin_tblOutletSalesTargets_aucm os on  
            o.OutletID = os.OutletID  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.ID) as OutletSalesTargetKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.ID as OutletSalesTargetID,  
  os.[Month],  
  os.GrossSellPriceTarget  
    from  
        dbo.penguin_tblOutlet_autp o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'TIP', 'AU') dk  
        inner join dbo.penguin_tblOutletSalesTargets_autp os on  
            o.OutletID = os.OutletID  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.ID) as OutletSalesTargetKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.ID as OutletSalesTargetID,  
  os.[Month],  
  os.GrossSellPriceTarget  
    from  
        dbo.penguin_tblOutlet_ukcm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk  
        inner join dbo.penguin_tblOutletSalesTargets_ukcm os on  
            o.OutletID = os.OutletID  
	where o.OutletId not in (select OutletId from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')

    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.ID) as OutletSalesTargetKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.ID as OutletSalesTargetID,  
  os.[Month],  
  os.GrossSellPriceTarget  
    from  
        dbo.penguin_tblOutlet_uscm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'US') dk  
        inner join dbo.penguin_tblOutletSalesTargets_uscm os on  
            o.OutletID = os.OutletID  
  
  
    --create Agency table if not already created  
    if object_id('[db-au-cmdwh].dbo.penOutletSalesTarget') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penOutletSalesTarget]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [DomainKey] varchar(41) null,  
            [OutletSalesTargetKey] varchar(33) null,  
            [OutletKey] varchar(33) null,  
            [OutletAlphaKey] nvarchar(50) null,  
            [OutletSalesTargetID] int null,  
            [Month] int null,  
            [GrossSellPriceTarget] money null  
      )  
  
        create clustered index idx_penOutletSalesTarget_OutletStoreKey on [db-au-cmdwh].dbo.penOutletSalesTarget(OutletSalesTargetKey)  
        create index idx_penOutletSalesTarget_OutletKey on [db-au-cmdwh].dbo.penOutletSalesTarget(OutletKey) include(OutletSalesTargetID, OutletAlphaKey)  
  
    end  
    else  
    begin  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penOutletSalesTarget a  
            inner join etl_penOutletSalesTarget b on  
                a.OutletSalesTargetKey = b.OutletSalesTargetKey and  
    a.OutletKey = b.OutletKey  
  
    end  
  
  
    insert into [db-au-cmdwh].dbo.penOutletSalesTarget with (tablockx)  
    (  
        [CountryKey],  
        [CompanyKey],  
        [DomainKey],  
        [OutletSalesTargetKey],  
        [OutletKey],  
        [OutletAlphaKey],  
        [OutletSalesTargetID],  
        [Month],  
        [GrossSellPriceTarget]  
    )  
    select  
        [CountryKey],  
        [CompanyKey],  
        [DomainKey],  
        [OutletSalesTargetKey],  
        [OutletKey],  
        [OutletAlphaKey],  
        [OutletSalesTargetID],  
        [Month],  
        [GrossSellPriceTarget]  
    from  
        etl_penOutletSalesTarget  
  
  
end  
  
  
GO
