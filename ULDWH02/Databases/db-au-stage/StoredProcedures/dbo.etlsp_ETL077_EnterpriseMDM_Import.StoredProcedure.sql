USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL077_EnterpriseMDM_Import]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL077_EnterpriseMDM_Import]
as
begin

    set nocount on

    if object_id('[db-au-stage]..ent_UPDATED_PARTIES') is null
        select 
            ROWID_OBJECT PARTY_FK
        into [db-au-stage]..ent_UPDATED_PARTIES
        from 
            [db_au_mdmenterprise].[dbo].C_PARTY 
        where 
            1 = 0

    if object_id('[db-au-stage].[dbo].ent_C_PARTY_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY 
    where 
        ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_C_PARTY_ADDRESS_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_ADDRESS_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_ADDRESS_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_ADDRESS 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_C_PARTY_EMAIL_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_EMAIL_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_EMAIL_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_EMAIL 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_C_PARTY_IDENTIFIER_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_IDENTIFIER_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_IDENTIFIER_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_IDENTIFIER 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_C_PARTY_PHONE_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_PHONE_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_PHONE_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_PHONE 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)
        
    if object_id('[db-au-stage].[dbo].ent_C_PARTY_PRODUCT_TXN_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PARTY_PRODUCT_TXN_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PARTY_PRODUCT_TXN_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_PRODUCT_TXN 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_C_PRTY_IND_DTL_aucm') is not null
        drop table [db-au-stage].[dbo].ent_C_PRTY_IND_DTL_aucm

    select * 
    into [db-au-stage].[dbo].ent_C_PRTY_IND_DTL_aucm
    from 
        [db_au_mdmenterprise].[dbo].C_PRTY_IND_DTL 
    where 
        PRTY_FK in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PARTY_ADDRESS_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PARTY_ADDRESS_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PARTY_ADDRESS_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_ADDRESS_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PARTY_EMAIL_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PARTY_EMAIL_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PARTY_EMAIL_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_EMAIL_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PARTY_IDENTIFIER_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PARTY_IDENTIFIER_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PARTY_IDENTIFIER_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_IDENTIFIER_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PARTY_PHONE_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PARTY_PHONE_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PARTY_PHONE_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_PHONE_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PARTY_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PARTY_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PARTY_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES) or
        ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)

    if object_id('[db-au-stage].[dbo].ent_vC_PRTY_IND_DTL_XREF_aucm') is not null
        drop table [db-au-stage].[dbo].ent_vC_PRTY_IND_DTL_XREF_aucm

    select * 
    into [db-au-stage].[dbo].ent_vC_PRTY_IND_DTL_XREF_aucm
    from 
        [db_au_mdmenterprise].[dbo].vC_PRTY_IND_DTL_XREF 
    where 
        ORIG_ROWID_OBJECT in (select PARTY_FK from [db-au-stage]..ent_UPDATED_PARTIES)


end
GO
