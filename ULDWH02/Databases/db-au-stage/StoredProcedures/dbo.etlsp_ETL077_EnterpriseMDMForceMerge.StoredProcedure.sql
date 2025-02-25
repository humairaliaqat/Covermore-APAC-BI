USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL077_EnterpriseMDMForceMerge]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL077_EnterpriseMDMForceMerge]
as
begin

    set nocount on


    --same name, same policy key
    if object_id('tempdb..#manualmerge') is not null
        drop table #manualmerge

    select 
        cpp.PRTY_FK, 
        cpp.POLICY_KEY, 
        cpp.LAST_ROWID_SYSTEM,
        cp.PRTY_NM
    into #manualmerge
    from 
        [db_au_mdmenterprise]..vC_PARTY_MANUALMERGE cp with(nolock)
        inner join [db_au_mdmenterprise]..vC_PARTY_PRODUCT_MANUALMERGE cpp with(nolock) on
            cpp.PRTY_FK = cp.ROWID_OBJECT
    where
        cp.STATUS = 'Valid' and
        exists 
        (
            select
                null
            from 
                [db_au_mdmenterprise]..vC_PARTY_MANUALMERGE rp with(nolock)
                inner join [db_au_mdmenterprise]..vC_PARTY_PRODUCT_MANUALMERGE rpp with(nolock) on
                    rpp.PRTY_FK = rp.ROWID_OBJECT
            WHERE 
                rp.STATUS = 'Valid' and
                rpp.POLICY_KEY = cpp.POLICY_KEY and
                rp.PRTY_NM = cp.PRTY_NM and
                rpp.LAST_ROWID_SYSTEM <> cpp.LAST_ROWID_SYSTEM and
                rpp.PRTY_FK <> cpp.PRTY_FK 
        )

    --select *
    --from
    --    #manualmerge

    update [db_au_mdmenterprise]..C_PARTY
    set
        CONSOLIDATION_IND = 4
    where
        ROWID_OBJECT in
        (
            select 
                PRTY_FK
            from
                #manualmerge
        )

    --same name & dob, same identity (e.g. membership number)
    if object_id('tempdb..#manualmergeid') is not null
        drop table #manualmergeid

    select 
        cp.PRTY_NM,
        cpd.DOB,
        ci.IDNTIFR_TYP,
        ci.IDNTIFR_VAL,
        count(distinct cp.ROWID_OBJECT) RecCount
    into #manualmergeid
    from
        [db_au_mdmenterprise]..C_PARTY cp with(nolock)
        inner join [db_au_mdmenterprise]..C_PRTY_IND_DTL cpd with(nolock) on
            cpd.PRTY_FK = cp.ROWID_OBJECT
        inner join [db_au_mdmenterprise]..C_PARTY_IDENTIFIER ci with(nolock) on
            ci.PRTY_FK = cp.ROWID_OBJECT
    where
        cp.STATUS = 'VALID' and
        cpd.DOB is not null and
        cp.PRTY_NM like '% %' and
        len(ltrim(rtrim(ci.IDNTIFR_VAL))) >= 5
    group by
        cp.PRTY_NM,
        cpd.DOB,
        ci.IDNTIFR_TYP,
        ci.IDNTIFR_VAL
    having 
        count(distinct cp.ROWID_OBJECT) > 1
    order by 5 desc


    update [db_au_mdmenterprise]..C_PARTY
    set
        CONSOLIDATION_IND = 4
    where
        STATUS = 'VALID' and
        ROWID_OBJECT in
        (
            select 
                cp.ROWID_OBJECT
            from
                #manualmergeid t
                inner join [db_au_mdmenterprise]..C_PARTY cp with(nolock) on
                    cp.PRTY_NM = t.PRTY_NM
                inner join [db_au_mdmenterprise]..C_PRTY_IND_DTL cpd with(nolock) on
                    cpd.PRTY_FK = cp.ROWID_OBJECT and
                    cpd.DOB = t.DOB
                inner join [db_au_mdmenterprise]..C_PARTY_IDENTIFIER ci with(nolock) on
                    ci.PRTY_FK = cp.ROWID_OBJECT and
                    ci.IDNTIFR_TYP = t.IDNTIFR_TYP and
                    ci.IDNTIFR_VAL = t.IDNTIFR_VAL
        )

    --select distinct
    --    t.*,
    --    cp.ROWID_OBJECT,
    --    cp.CREATE_DATE,
    --    cp.LAST_UPDATE_DATE
    --from
    --    #manualmergeid t
    --    inner join [db_au_mdmenterprise]..C_PARTY cp with(nolock) on
    --        cp.PRTY_NM = t.PRTY_NM
    --    inner join [db_au_mdmenterprise]..C_PRTY_IND_DTL cpd with(nolock) on
    --        cpd.PRTY_FK = cp.ROWID_OBJECT and
    --        cpd.DOB = t.DOB
    --    inner join [db_au_mdmenterprise]..C_PARTY_IDENTIFIER ci with(nolock) on
    --        ci.PRTY_FK = cp.ROWID_OBJECT and
    --        ci.IDNTIFR_TYP = t.IDNTIFR_TYP and
    --        ci.IDNTIFR_VAL = t.IDNTIFR_VAL
    --order by 5 desc, 1, 2, 6

end
GO
