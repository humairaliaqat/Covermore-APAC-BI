USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_StagingIndex_EnterpriseMDM]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_StagingIndex_EnterpriseMDM]
as
begin

    set nocount on

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PRTY_IND_DTL_aucm')
        create nonclustered index idx_ent_C_PRTY_IND_DTL_aucm on ent_C_PRTY_IND_DTL_aucm (PRTY_FK) include (TITLE,FRST_NM,MID_NM,LST_NM,GNDR,MARITL_STS,DOB,IS_DCSED)

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PARTY_ADDRESS_aucm')
        create nonclustered index idx_ent_C_PARTY_ADDRESS_aucm on ent_C_PARTY_ADDRESS_aucm (PRTY_FK,STATUS,LAST_UPDATE_DATE desc) include (ROWID_OBJECT,LAST_ROWID_SYSTEM,ADDR_LINE1,ADDR_LINE2,CITY,PRVNCE,CNTRY,CNTRY_CD,POST_CD,DLVRY_PT_DPID)

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PARTY_EMAIL_aucm')
        create nonclustered index idx_ent_C_PARTY_EMAIL_aucm on ent_C_PARTY_EMAIL_aucm (PRTY_FK,STATUS,LAST_UPDATE_DATE desc) include (ROWID_OBJECT,LAST_ROWID_SYSTEM,EMAIL_VAL,EMAIL_TYP)

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PARTY_PHONE_aucm')
        create nonclustered index idx_ent_C_PARTY_PHONE_aucm on ent_C_PARTY_PHONE_aucm (PRTY_FK,STATUS,LAST_UPDATE_DATE desc) include (ROWID_OBJECT,LAST_ROWID_SYSTEM,PH_CNTRY_CD,FULL_PH_VAL,PH_TYP,PH_SUB_TYP)

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PARTY_IDENTIFIER_aucm')
        create nonclustered index idx_ent_C_PARTY_IDENTIFIER_aucm on ent_C_PARTY_IDENTIFIER_aucm (PRTY_FK) include (ROWID_OBJECT,LAST_ROWID_SYSTEM,IDNTIFR_TYP,IDNTIFR_SUB_TYP,IDNTIFR_VAL,LAST_UPDATE_DATE,STATUS)

    if not exists (select null from sys.indexes where name = 'idx_ent_C_PARTY_PRODUCT_TXN_aucm')
        create nonclustered index idx_ent_C_PARTY_PRODUCT_TXN_aucm on ent_C_PARTY_PRODUCT_TXN_aucm (PRTY_FK) include (ROWID_OBJECT,LAST_ROWID_SYSTEM,PROD_REF_NO)

    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PARTY_XREF_aucm')
        create nonclustered index idx_ent_vC_PARTY_XREF_aucm on ent_vC_PARTY_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)

    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PRTY_IND_DTL_XREF_aucm')
        create nonclustered index idx_ent_vC_PRTY_IND_DTL_XREF_aucm on ent_vC_PRTY_IND_DTL_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)

    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PARTY_ADDRESS_XREF_aucm')
        create nonclustered index idx_ent_vC_PARTY_ADDRESS_XREF_aucm on ent_vC_PARTY_ADDRESS_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)
        
    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PARTY_EMAIL_XREF_aucm')
        create nonclustered index idx_ent_vC_PARTY_EMAIL_XREF_aucm on ent_vC_PARTY_EMAIL_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)

    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PARTY_PHONE_XREF_aucm')
        create nonclustered index idx_ent_vC_PARTY_PHONE_XREF_aucm on ent_vC_PARTY_PHONE_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)

    if not exists (select null from sys.indexes where name = 'idx_ent_vC_PARTY_IDENTIFIER_XREF_aucm')
        create nonclustered index idx_ent_vC_PARTY_IDENTIFIER_XREF_aucm on ent_vC_PARTY_IDENTIFIER_XREF_aucm (ORIG_ROWID_OBJECT) include (ROWID_OBJECT)

end



GO
