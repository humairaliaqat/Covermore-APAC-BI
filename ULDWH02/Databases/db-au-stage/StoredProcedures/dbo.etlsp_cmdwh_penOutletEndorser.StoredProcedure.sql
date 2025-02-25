USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penOutletEndorser]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penOutletEndorser]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120125  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    OutletEndorser table contains agency endorsements.  
                This transformation adds essential key fields  
Change History:  
                20120125 - LT - Procedure created  
                20121107 - LS - refactoring & domain related changes  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.  
                20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
    20160321 - LT - Penguin 18.0, added US Penguin instance  
  		20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penOutletEndorser') is not null  
        drop table etl_penOutletEndorser  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + cast(oe.OutletID as varchar) as OutletKey,  
        oe.OutletID,  
        oe.EndorserID,  
        dbo.fn_GetReferenceValueByID(oe.EndorserID, CompanyKey, CountrySet) Endorser,  
        oe.EndorserList  
    into etl_penOutletEndorser  
    from  
        penguin_tblOutletEndorser_aucm oe  
        inner join penguin_tblOutlet_aucm o on  
            o.OutletId = oe.OutletID  
        cross apply dbo.fn_GetOutletDomainKeys(o.OutletID, 'CM', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + cast(oe.OutletID as varchar) as OutletKey,  
        oe.OutletID,  
        oe.EndorserID,  
        dbo.fn_GetReferenceValueByID(oe.EndorserID, CompanyKey, CountrySet) Endorser,  
        oe.EndorserList  
    from  
        penguin_tblOutletEndorser_aucm oe  
        inner join penguin_tblOutlet_aucm o on  
            o.OutletId = oe.OutletID  
        cross apply dbo.fn_GetOutletDomainKeys(o.OutletID, 'TIP', 'AU') dk  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + cast(oe.OutletID as varchar) as OutletKey,  
        oe.OutletID,  
        oe.EndorserID,  
        dbo.fn_GetReferenceValueByID(oe.EndorserID, CompanyKey, CountrySet) Endorser,  
        oe.EndorserList  
    from  
        penguin_tblOutletEndorser_ukcm oe  
        inner join penguin_tblOutlet_ukcm o on  
            o.OutletId = oe.OutletID  
        cross apply dbo.fn_GetOutletDomainKeys(o.OutletID, 'CM', 'UK') dk  
	where oe.OutletID not in (select OutletID from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')		------adding condition to filter out BK.com data

    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        PrefixKey + cast(oe.OutletID as varchar) as OutletKey,  
        oe.OutletID,  
        oe.EndorserID,  
        dbo.fn_GetReferenceValueByID(oe.EndorserID, CompanyKey, CountrySet) Endorser,  
        oe.EndorserList  
    from  
        penguin_tblOutletEndorser_uscm oe  
        inner join penguin_tblOutlet_uscm o on  
            o.OutletId = oe.OutletID  
        cross apply dbo.fn_GetOutletDomainKeys(o.OutletID, 'CM', 'US') dk  
  
  
    if object_id('[db-au-cmdwh].dbo.penOutletEndorser') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penOutletEndorser]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [OutletKey] varchar(33) not null,  
            [OutletID] int not null,  
            [EndorserID] int null,  
            [Endorser] nvarchar(50) null,  
            [EndorserList] nvarchar(max) null  
        )  
  
        create clustered index idx_penOutletEndorser_OutletKey on [db-au-cmdwh].dbo.penOutletEndorser(OutletKey)  
        create nonclustered index idx_penOutletEndorser_CountryKey on [db-au-cmdwh].dbo.penOutletEndorser(CountryKey)  
  
    end  
    else  
    begin  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penOutletEndorser a  
            inner join etl_penOutletEndorser b on  
                a.OutletKey = b.OutletKey  
  
    end  
  
    insert into [db-au-cmdwh].dbo.penOutletEndorser with(tablockx)  
    (  
        CountryKey,  
        CompanyKey,  
        OutletKey,  
        OutletID,  
        EndorserID,  
        Endorser,  
        EndorserList  
    )  
    select  
        CountryKey,  
        CompanyKey,  
        OutletKey,  
        OutletID,  
        EndorserID,  
        Endorser,  
        EndorserList  
    from  
        etl_penOutletEndorser  
  
end  
  
  
GO
