USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyKeyValues]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyKeyValues]
as
begin


/************************************************************************************************************************************
Author:         LL
Date:           20190306
Prerequisite:   Requires Penguin Data Model ETL successfully run.
Description:    store policy and transaction key values
Change History:
                20190306 - LL - REQ-1166, Procedure created
*************************************************************************************************************************************/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    --transform and load penPolicyKeyValues
    if object_id('etl_penkeyvalues') is not null 
        drop table etl_penkeyvalues

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyID) PolicyKey,
        null PolicyTransactionKey,
        pkv.PolicyId PolicyID,
        null PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    into etl_penkeyvalues
    from
        penguin_tblPolicyKeyValues_aucm pkv
        inner join penguin_tblPolicyKeyValueTypes_aucm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'AU') dk  

    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        null PolicyKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyTransactionID) PolicyTransactionKey,
        null PolicyID,
        pkv.PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyTransactionKeyValues_aucm pkv
        inner join penguin_tblPolicyKeyValueTypes_aucm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'AU') dk  
    
    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyID) PolicyKey,
        null PolicyTransactionKey,
        pkv.PolicyId PolicyID,
        null PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyKeyValues_autp pkv
        inner join penguin_tblPolicyKeyValueTypes_autp pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'TIP', 'AU') dk  

    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        null PolicyKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyTransactionID) PolicyTransactionKey,
        null PolicyID,
        pkv.PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyTransactionKeyValues_autp pkv
        inner join penguin_tblPolicyKeyValueTypes_autp pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'TIP', 'AU') dk  
  
    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyID) PolicyKey,
        null PolicyTransactionKey,
        pkv.PolicyId PolicyID,
        null PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyKeyValues_ukcm pkv
        inner join penguin_tblPolicyKeyValueTypes_ukcm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'UK') dk  

    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        null PolicyKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyTransactionID) PolicyTransactionKey,
        null PolicyID,
        pkv.PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyTransactionKeyValues_ukcm pkv
        inner join penguin_tblPolicyKeyValueTypes_ukcm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'UK') dk  

    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyID) PolicyKey,
        null PolicyTransactionKey,
        pkv.PolicyId PolicyID,
        null PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyKeyValues_uscm pkv
        inner join penguin_tblPolicyKeyValueTypes_uscm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'US') dk  

    union all

    select 
        dk.CountryKey,
        dk.CompanyKey,
        dk.DomainKey,
        null PolicyKey,
        dk.PrefixKey + convert(varchar, pkv.PolicyTransactionID) PolicyTransactionKey,
        null PolicyID,
        pkv.PolicyTransactionID,
        pkv.TypeId ValueTypeID,
        pkvt.Code ValueType,
        pkv.Value
    from
        penguin_tblPolicyTransactionKeyValues_uscm pkv
        inner join penguin_tblPolicyKeyValueTypes_uscm pkvt on 
            pkvt.ID = pkv.TypeId
        cross apply dbo.fn_GetDomainKeys(pkvt.DomainId, 'CM', 'US') dk  

    if object_id('[db-au-cmdwh].dbo.penPolicyKeyValues') is null
    begin

        create table [db-au-cmdwh].dbo.penPolicyKeyValues
        (
            BIRowID bigint identity(1,1) not null,
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            DomainKey varchar(41) not null,
            PolicyKey varchar(41) null,
            PolicyTransactionKey varchar(41) null,
            PolicyID int null,
            PolicyTransactionID int null,
            ValueTypeID int null,
            ValueType nvarchar(100) null,
            KeyValue nvarchar(255) null
        )

        create unique clustered index idx_penPolicyKeyValues_BIRowID on [db-au-cmdwh].dbo.penPolicyKeyValues(BIRowID)
        create nonclustered index idx_penPolicyKeyValues_PolicyKey on [db-au-cmdwh].dbo.penPolicyKeyValues(PolicyKey,ValueType) include (KeyValue)
        create nonclustered index idx_penPolicyKeyValues_PolicyTransactionKey on [db-au-cmdwh].dbo.penPolicyKeyValues(PolicyTransactionKey,ValueType) include (KeyValue)

    end


    /*************************************************************/
    -- Transfer data 
    /*************************************************************/
    begin transaction 

    begin try

        delete a
        from
            [db-au-cmdwh].dbo.penPolicyKeyValues a
            inner join etl_penkeyvalues b on
                b.PolicyKey = a.PolicyKey

        delete a
        from
            [db-au-cmdwh].dbo.penPolicyKeyValues a
            inner join etl_penkeyvalues b on
                b.PolicyTransactionKey = a.PolicyTransactionKey


        insert [db-au-cmdwh].dbo.penPolicyKeyValues with(tablockx)
        (
            CountryKey,
            CompanyKey,
            DomainKey,
            PolicyKey,
            PolicyTransactionKey,
            PolicyID,
            PolicyTransactionID,
            ValueTypeID,
            ValueType,
            KeyValue
        )
        select
            CountryKey,
            CompanyKey,
            DomainKey,
            PolicyKey,
            PolicyTransactionKey,
            PolicyID,
            PolicyTransactionID,
            ValueTypeID,
            ValueType,
            Value
        from
            etl_penkeyvalues

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler 'penPolicyKeyValues data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction 


end



GO
