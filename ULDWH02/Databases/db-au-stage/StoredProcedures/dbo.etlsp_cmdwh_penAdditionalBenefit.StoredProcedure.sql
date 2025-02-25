USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAdditionalBenefit]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penAdditionalBenefit]  
as  
begin  
  
  
/************************************************************************************************************************************  
Author:         Leonardus Setyabudi  
Date:           20130304  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    This stored procedure parse XML in Additional Benefit scheme into their respective table  
Change History:  
                20130304 - LS - TFS 7785-7786, Global SIM ETL  
                20130614 - LS - TFS 7664/8556/8557, UK Penguin  
                20140612 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20160321 - LT - Penguin 18.0, no changes. No GlobalSIM for US domain  
		20210306, SS, CHG0034615 Add filter for BK.com 
  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
  
    /* Global SIM begin */  
    if object_id('etl_penPolicyGlobalSIM') is not null  
        drop table etl_penPolicyGlobalSIM  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, abt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, abt.Id) AdditionalBenefitKey,  
        ab.DomainID,  
        abt.PolicyId,  
        abt.Id AdditionalBenefitID,  
        dbo.xfn_ConvertUTCtoLocal(abt.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(abt.UpdateDateTime, TimeZone) UpdateDateTime,  
        abt.CreateDateTime CreateDateTimeUTC,  
        abt.UpdateDateTime UpdateDateTimeUTC,  
        abt.Status,  
        abd.Comments,  
        FirstName,  
        Surname,  
        Address,  
        Suburb,  
        State,  
        Postcode,  
        Email,  
        Mobile,  
        TypeOfSimCard,  
        ItalyVisit  
    into etl_penPolicyGlobalSIM  
    from  
        penguin_tblAdditionalBenefit_aucm ab  
        inner join penguin_tblAdditionalBenefitTransaction_aucm abt on  
            abt.BenefitId = ab.BenefitId  
        inner join penguin_tblAdditionalBenefitDetails_aucm abd on  
            abd.AdditionalBenefitTransactionId = abt.Id  
        cross apply dbo.fn_GetDomainKeys(ab.DomainId, 'CM', 'AU') dk  
        cross apply  
        (  
            select  
                convert(xml, abd.Data).value('(/Sim/FirstName)[1]', 'varchar(255)') FirstName,  
                convert(xml, abd.Data).value('(/Sim/Surname)[1]', 'varchar(255)') Surname,  
                convert(xml, abd.Data).value('(/Sim/Address)[1]', 'varchar(255)') Address,  
                convert(xml, abd.Data).value('(/Sim/Suburb)[1]', 'varchar(255)') Suburb,  
                convert(xml, abd.Data).value('(/Sim/State)[1]', 'varchar(255)') State,  
                convert(xml, abd.Data).value('(/Sim/Postcode)[1]', 'varchar(255)') Postcode,  
                convert(xml, abd.Data).value('(/Sim/Email)[1]', 'varchar(255)') Email,  
                convert(xml, abd.Data).value('(/Sim/Mobile)[1]', 'varchar(255)') Mobile,  
                convert(xml, abd.Data).value('(/Sim/TypeOfSimCard)[1]', 'varchar(255)') TypeOfSimCard,  
                convert(xml, abd.Data).value('(/Sim/ItalyVisit)[1]', 'varchar(255)') ItalyVisit  
        ) d  
    where  
        Code = 'SIM'  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, abt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, abt.Id) AdditionalBenefitKey,  
        ab.DomainID,  
        abt.PolicyId,  
        abt.Id AdditionalBenefitID,  
        dbo.xfn_ConvertUTCtoLocal(abt.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(abt.UpdateDateTime, TimeZone) UpdateDateTime,  
        abt.CreateDateTime CreateDateTimeUTC,  
        abt.UpdateDateTime UpdateDateTimeUTC,  
        abt.Status,  
        abd.Comments,  
        FirstName,  
        Surname,  
        Address,  
        Suburb,  
        State,  
        Postcode,  
        Email,  
        Mobile,  
        TypeOfSimCard,  
        ItalyVisit  
    from  
        penguin_tblAdditionalBenefit_autp ab  
        inner join penguin_tblAdditionalBenefitTransaction_autp abt on  
            abt.BenefitId = ab.BenefitId  
        inner join penguin_tblAdditionalBenefitDetails_autp abd on  
            abd.AdditionalBenefitTransactionId = abt.Id  
        cross apply dbo.fn_GetDomainKeys(ab.DomainId, 'TIP', 'AU') dk  
        cross apply  
        (  
            select  
                convert(xml, abd.Data).value('(/Sim/FirstName)[1]', 'varchar(255)') FirstName,  
                convert(xml, abd.Data).value('(/Sim/Surname)[1]', 'varchar(255)') Surname,  
                convert(xml, abd.Data).value('(/Sim/Address)[1]', 'varchar(255)') Address,  
                convert(xml, abd.Data).value('(/Sim/Suburb)[1]', 'varchar(255)') Suburb,  
                convert(xml, abd.Data).value('(/Sim/State)[1]', 'varchar(255)') State,  
                convert(xml, abd.Data).value('(/Sim/Postcode)[1]', 'varchar(255)') Postcode,  
                convert(xml, abd.Data).value('(/Sim/Email)[1]', 'varchar(255)') Email,  
                convert(xml, abd.Data).value('(/Sim/Mobile)[1]', 'varchar(255)') Mobile,  
                convert(xml, abd.Data).value('(/Sim/TypeOfSimCard)[1]', 'varchar(255)') TypeOfSimCard,  
                convert(xml, abd.Data).value('(/Sim/ItalyVisit)[1]', 'varchar(255)') ItalyVisit  
        ) d  
    where  
        Code = 'SIM'  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, abt.PolicyID) PolicyKey,  
        PrefixKey + convert(varchar, abt.Id) AdditionalBenefitKey,  
        ab.DomainID,  
        abt.PolicyId,  
        abt.Id AdditionalBenefitID,  
        dbo.xfn_ConvertUTCtoLocal(abt.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(abt.UpdateDateTime, TimeZone) UpdateDateTime,  
        abt.CreateDateTime CreateDateTimeUTC,  
        abt.UpdateDateTime UpdateDateTimeUTC,  
        abt.Status,  
        abd.Comments,  
        FirstName,  
        Surname,  
        Address,  
        Suburb,  
        State,  
        Postcode,  
        Email,  
        Mobile,  
        TypeOfSimCard,  
        ItalyVisit  
    from  
        penguin_tblAdditionalBenefit_ukcm ab  
        inner join penguin_tblAdditionalBenefitTransaction_ukcm abt on  
            abt.BenefitId = ab.BenefitId  
        inner join penguin_tblAdditionalBenefitDetails_ukcm abd on  
            abd.AdditionalBenefitTransactionId = abt.Id  
        cross apply dbo.fn_GetDomainKeys(ab.DomainId, 'CM', 'UK') dk  
        cross apply  
        (  
            select  
                convert(xml, abd.Data).value('(/Sim/FirstName)[1]', 'varchar(255)') FirstName,  
                convert(xml, abd.Data).value('(/Sim/Surname)[1]', 'varchar(255)') Surname,  
                convert(xml, abd.Data).value('(/Sim/Address)[1]', 'varchar(255)') Address,  
                convert(xml, abd.Data).value('(/Sim/Suburb)[1]', 'varchar(255)') Suburb,  
                convert(xml, abd.Data).value('(/Sim/State)[1]', 'varchar(255)') State,  
                convert(xml, abd.Data).value('(/Sim/Postcode)[1]', 'varchar(255)') Postcode,  
                convert(xml, abd.Data).value('(/Sim/Email)[1]', 'varchar(255)') Email,  
                convert(xml, abd.Data).value('(/Sim/Mobile)[1]', 'varchar(255)') Mobile,  
                convert(xml, abd.Data).value('(/Sim/TypeOfSimCard)[1]', 'varchar(255)') TypeOfSimCard,  
                convert(xml, abd.Data).value('(/Sim/ItalyVisit)[1]', 'varchar(255)') ItalyVisit  
        ) d  
    where  
        Code = 'SIM'  
	and (PrefixKey + convert(varchar, abt.PolicyID)) not in (select PrefixKey + convert(varchar, PolicyID) from Penguin_tblpolicy_ukcm cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'UK') dk where AlphaCode like 'BK%')	------adding condition to filter out BK.com data
  
    /**************************************************************************/  
    --delete existing global sim benefit or create table if table doesnt exist  
    /**************************************************************************/  
    if object_id('[db-au-cmdwh].dbo.penPolicyGlobalSIM') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penPolicyGlobalSIM]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [DomainKey] varchar(41) null,  
            [PolicyKey] varchar(41) null,  
            [AdditionalBenefitKey] varchar(41) null,  
            [DomainID] int null,  
            [PolicyID] int not null,  
            [AdditionalBenefitID] int not null,  
            [CreateDateTime] datetime not null,  
            [UpdateDateTime] datetime not null,  
            [CreateDateTimeUTC] datetime not null,  
            [UpdateDateTimeUTC] datetime not null,  
            [Status] varchar(15) not null,  
            [Comments] varchar(1000) null,  
            [FirstName] nvarchar(255) null,  
            [Surname] nvarchar(255) null,  
            [Address] nvarchar(255) null,  
            [Suburb] nvarchar(255) null,  
            [State] nvarchar(255) null,  
            [Postcode] nvarchar(255) null,  
            [Email] nvarchar(255) null,  
            [Mobile] varchar(255) null,  
            [TypeOfSimCard] nvarchar(255) null,  
            [ItalyVisit] varchar(255) null  
        )  
  
        create clustered index idx_penPolicyGlobalSIM_PolicyKey on [db-au-cmdwh].dbo.penPolicyGlobalSIM(PolicyKey)  
        create nonclustered index idx_penPolicy_CountryKey on [db-au-cmdwh].dbo.penPolicyGlobalSIM(CountryKey)  
        create nonclustered index idx_penPolicy_CreateDateTime on [db-au-cmdwh].dbo.penPolicyGlobalSIM(CreateDateTime)  
        create nonclustered index idx_penPolicy_TypeOfSimCard on [db-au-cmdwh].dbo.penPolicyGlobalSIM(TypeOfSimCard)  
  
    end  
    else  
    begin  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPolicyGlobalSIM a  
            inner join etl_penPolicyGlobalSIM b on  
                a.PolicyKey = b.PolicyKey  
  
    end  
  
  
    /*****************************************************************************************/  
    -- Transfer data from  penPolicyGlobalSIM to [db-au-cmdwh].dbo.penPolicyGlobalSIM  
    /*****************************************************************************************/  
  
    insert into [db-au-cmdwh].dbo.penPolicyGlobalSIM with (tablockx)  
    (  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PolicyKey,  
        AdditionalBenefitKey,  
        DomainID,  
        PolicyID,  
        AdditionalBenefitID,  
        CreateDateTime,  
        UpdateDateTime,  
        CreateDateTimeUTC,  
        UpdateDateTimeUTC,  
        Status,  
        Comments,  
        FirstName,  
        Surname,  
        Address,  
        Suburb,  
        State,  
        Postcode,  
        Email,  
        Mobile,  
        TypeOfSimCard,  
        ItalyVisit  
    )  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PolicyKey,  
        AdditionalBenefitKey,  
        DomainID,  
        PolicyID,  
        AdditionalBenefitID,  
        CreateDateTime,  
        UpdateDateTime,  
        CreateDateTimeUTC,  
        UpdateDateTimeUTC,  
        Status,  
        Comments,  
        FirstName,  
        Surname,  
        Address,  
        Suburb,  
        State,  
        Postcode,  
        Email,  
        Mobile,  
        TypeOfSimCard,  
        ItalyVisit  
    from  
        etl_penPolicyGlobalSIM  
  
    /* Global SIM end */  
  
end  
  
GO
