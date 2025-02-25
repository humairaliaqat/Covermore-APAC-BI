USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penOutletStore]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penOutletStore]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20130812  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    OutletStore table contains store attributes.  
                This transformation adds essential key fields  
Change History:  
                20130812 - LT - Procedure created  
                20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
    20160321 - LT - Penguin 18.0, added US Penguin instance  
  		20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penOutletStore') is not null  
        drop table etl_penOutletStore  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.OutletStoreID) as OutletStoreKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.OutletStoreID,  
        os.Name as StoreName,  
        os.Code as StoreCode,  
        o.DomainID,  
        o.OutletID,  
        os.[Status] as StoreStatus,  
        dbo.xfn_ConvertUTCtoLocal(os.CreateDateTime, TimeZone) as CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(os.UpdateDateTime, TimeZone) as UpdateDateTime,  
        os.CreateDateTime as CreateDateTimeUTC,  
        os.UpdateDateTime as UpdateDateTimeUTC,  
        (select top 1 Value from penguin_tblReferenceValue_aucm where ID = os.StoreType) as StoreType  
    into etl_penOutletStore  
    from  
        dbo.penguin_tblOutlet_aucm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'AU') dk  
        inner join dbo.penguin_tblOutletStore_aucm os on  
            o.OutletID = os.OutletID  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.OutletStoreID) as OutletStoreKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.OutletStoreID,  
        os.Name as StoreName,  
        os.Code as StoreCode,  
        o.DomainID,  
        o.OutletID,  
        os.[Status] as StoreStatus,  
        dbo.xfn_ConvertUTCtoLocal(os.CreateDateTime, TimeZone) as CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(os.UpdateDateTime, TimeZone) as UpdateDateTime,  
        os.CreateDateTime as CreateDateTimeUTC,  
        os.UpdateDateTime as UpdateDateTimeUTC,  
        (select top 1 Value from penguin_tblReferenceValue_autp where ID = os.StoreType) as StoreType  
    from  
        dbo.penguin_tblOutlet_autp o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'TIP', 'AU') dk  
        inner join dbo.penguin_tblOutletStore_autp os on  
            o.OutletID = os.OutletID  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.OutletStoreID) as OutletStoreKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.OutletStoreID,  
        os.Name as StoreName,  
        os.Code as StoreCode,  
        o.DomainID,  
        o.OutletID,  
        os.[Status] as StoreStatus,  
        dbo.xfn_ConvertUTCtoLocal(os.CreateDateTime, TimeZone) as CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(os.UpdateDateTime, TimeZone) as UpdateDateTime,  
        os.CreateDateTime as CreateDateTimeUTC,  
        os.UpdateDateTime as UpdateDateTimeUTC,  
        (select top 1 Value from penguin_tblReferenceValue_ukcm where ID = os.StoreType) as StoreType  
    from  
        dbo.penguin_tblOutlet_ukcm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk  
        inner join dbo.penguin_tblOutletStore_ukcm os on  
            o.OutletID = os.OutletID  
	where o.OutletId not in (select OutletID from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')

    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, os.OutletStoreID) as OutletStoreKey,  
        PrefixKey + convert(varchar, o.OutletID) OutletKey,  
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,  
        os.OutletStoreID,  
        os.Name as StoreName,  
        os.Code as StoreCode,  
        o.DomainID,  
        o.OutletID,  
        os.[Status] as StoreStatus,  
        dbo.xfn_ConvertUTCtoLocal(os.CreateDateTime, TimeZone) as CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(os.UpdateDateTime, TimeZone) as UpdateDateTime,  
        os.CreateDateTime as CreateDateTimeUTC,  
        os.UpdateDateTime as UpdateDateTimeUTC,  
        (select top 1 Value from penguin_tblReferenceValue_uscm where ID = os.StoreType) as StoreType  
    from  
        dbo.penguin_tblOutlet_uscm o  
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'US') dk  
        inner join dbo.penguin_tblOutletStore_uscm os on  
            o.OutletID = os.OutletID  
  
  
    --create Agency table if not already created  
    if object_id('[db-au-cmdwh].dbo.penOutletStore') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penOutletStore]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [DomainKey] varchar(41) null,  
            [OutletStoreKey] varchar(33) null,  
            [OutletKey] varchar(33) null,  
            [OutletAlphaKey] nvarchar(50) null,  
            [OutletStoreID] int null,  
            [StoreName] nvarchar(250) null,  
            [StoreCode] varchar(10) null,  
            [DomainID] int null,  
            [OutletID] int null,  
            [StoreStatus] varchar(15) null,  
            [CreateDateTime] datetime null,  
            [UpdateDateTime] datetime null,  
            [CreateDateTimeUTC] datetime null,  
            [UpdateDateTimeUTC] datetime null,  
            [StoreType] varchar(50) null  
        )  
  
        create clustered index idx_penOutletStore_OutletStoreKey on [db-au-cmdwh].dbo.penOutletStore(OutletStoreKey)  
        create index idx_penOutletStore_OutletKey on [db-au-cmdwh].dbo.penOutletStore(OutletKey) include(OutletStoreID,StoreName,StoreCode,StoreStatus,StoreType)  
        create index idx_penOutletStore_OutletAlphaKey on [db-au-cmdwh].dbo.penOutletStore(OutletAlphaKey) include(OutletStoreID,StoreName,StoreCode,StoreStatus,StoreType)  
  
    end  
    else  
    begin  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penOutletStore a  
            inner join etl_penOutletStore b on  
                a.OutletStoreKey = b.OutletStoreKey  
  
    end  
  
  
    insert into [db-au-cmdwh].dbo.penOutletStore with (tablockx)  
    (  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        OutletStoreKey,  
        OutletKey,  
        OutletAlphaKey,  
        OutletStoreID,  
        StoreName,  
        StoreCode,  
        DomainID,  
        OutletID,  
        StoreStatus,  
        CreateDateTime,  
        UpdateDateTime,  
        CreateDateTimeUTC,  
        UpdateDateTimeUTC,  
        StoreType  
    )  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        OutletStoreKey,  
        OutletKey,  
        OutletAlphaKey,  
        OutletStoreID,  
        StoreName,  
        StoreCode,  
        DomainID,  
        OutletID,  
        StoreStatus,  
        CreateDateTime,  
        UpdateDateTime,  
        CreateDateTimeUTC,  
        UpdateDateTimeUTC,  
        StoreType  
    from  
        etl_penOutletStore  
  
  
end  
  
  
GO
