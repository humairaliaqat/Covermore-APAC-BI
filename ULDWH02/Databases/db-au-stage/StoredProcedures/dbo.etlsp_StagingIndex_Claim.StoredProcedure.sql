USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_StagingIndex_Claim]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_StagingIndex_Claim]
as
begin
/*
    20140415, LS, 20728 optimise
*/

    set nocount on

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaims_au_id')
        create index idx_claims_tblOnlineClaims_au_id on claims_tblOnlineClaims_au(ClaimId) include (AlphaCode, ConsultantName, OnlineClaimId, ClaimCauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaims_au_eid')
        create index idx_claims_tblOnlineClaims_au_eid on claims_tblOnlineClaims_au(ClaimCauseId) include (OnlineClaimId, ClaimId, KLDOMAINID)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimEventCauses_au_id')
        create clustered index idx_claims_tblOnlineClaimEventCauses_au_id on claims_tblOnlineClaimEventCauses_au(EventCauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimants_au_id')
        create clustered index idx_claims_tblOnlineClaimants_au_id on claims_tblOnlineClaimants_au(OnlineClaimId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantOtherSourceDetails_au_id')
        create clustered index idx_claims_tblOnlineClaimantOtherSourceDetails_au_id on claims_tblOnlineClaimantOtherSourceDetails_au(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantCreditCards_au_id')
        create clustered index idx_claims_tblOnlineClaimantCreditCards_au_id on claims_tblOnlineClaimantCreditCards_au(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantPastClaimDetails_au_id')
        create clustered index idx_claims_tblOnlineClaimantPastClaimDetails_au_id on claims_tblOnlineClaimantPastClaimDetails_au(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimEventSections_au_id')
        create clustered index idx_claims_tblOnlineClaimEventSections_au_id on claims_tblOnlineClaimEventSections_au(CauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimDeclarations_au_id')
        create clustered index idx_claims_tblOnlineClaimDeclarations_au_id on claims_tblOnlineClaimDeclarations_au(declarationid)

    if not exists (select null from sys.indexes where name = 'idx_claims_klsecurity_au_id')
        create index idx_claims_klsecurity_au_id on claims_klsecurity_au(KS_ID) include (KSNAME)
        
    if not exists (select null from sys.indexes where name = 'idx_claims_klsecurity_nz_id')
        create index idx_claims_klsecurity_nz_id on claims_klsecurity_nz(KS_ID) include (KSNAME)

    if not exists (select null from sys.indexes where name = 'idx_claims_klsecurity_uk_id')
        create index idx_claims_klsecurity_uk_id on claims_klsecurity_uk(KS_ID) include (KSNAME)

    if not exists (select null from sys.indexes where name = 'idx_claims_klstatus_au_id')
        create index idx_claims_klstatus_au_id on claims_klstatus_au(KT_ID, KTTABLE) include (KTSTATUS, KTDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klstatus_nz_id')
        create index idx_claims_klstatus_nz_id on claims_klstatus_nz(KT_ID, KTTABLE) include (KTSTATUS, KTDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klstatus_uk_id')
        create index idx_claims_klstatus_uk_id on claims_klstatus_uk(KT_ID, KTTABLE) include (KTSTATUS, KTDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klproducts_au_id')
        create index idx_claims_klproducts_au_id on claims_klproducts_au(KPProd_ID) include (KPPRODUCT)

    if not exists (select null from sys.indexes where name = 'idx_claims_klproducts_nz_id')
        create index idx_claims_klproducts_nz_id on claims_klproducts_nz(KPProd_ID) include (KPPRODUCT)

    if not exists (select null from sys.indexes where name = 'idx_claims_klproducts_uk_id')
        create index idx_claims_klproducts_uk_id on claims_klproducts_uk(KPProd_ID) include (KPPRODUCT)

    if not exists (select null from sys.indexes where name = 'idx_claims_klreg_au_id')
        create index idx_claims_klreg_au_id on claims_klreg_au(KLCLAIM) include (KLPRODUCT, KLDISS, KLDOMAINID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klreg_nz_id')
        create index idx_claims_klreg_nz_id on claims_klreg_nz(KLCLAIM) include (KLPRODUCT, KLDISS)

    if not exists (select null from sys.indexes where name = 'idx_claims_klreg_uk_id')
        create index idx_claims_klreg_uk_id on claims_klreg_uk(KLCLAIM) include (KLPRODUCT, KLDISS)
        
    if not exists (select null from sys.indexes where name = 'idx_claims_klbenefit_au_id')
        create index idx_claims_klbenefit_au_id on claims_klbenefit_au(KBCODE, KBPROD, KBVALIDFROM, KBVALIDTO) include (KBSECT_ID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klbenefit_nz_id')
        create index idx_claims_klbenefit_nz_id on claims_klbenefit_nz(KBCODE, KBPROD, KBVALIDFROM, KBVALIDTO) include (KBSECT_ID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klbenefit_uk_id')
        create index idx_claims_klbenefit_uk_id on claims_klbenefit_uk(KBCODE, KBPROD, KBVALIDFROM, KBVALIDTO) include (KBSECT_ID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcatas_au_id')
        create index idx_claims_klcatas_au_id on claims_klcatas_au(KC_CODE) include (KCSHORT, KCLONG)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcatas_nz_id')
        create index idx_claims_klcatas_nz_id on claims_klcatas_nz(KC_CODE) include (KCSHORT, KCLONG)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcatas_uk_id')
        create index idx_claims_klcatas_uk_id on claims_klcatas_uk(KC_CODE) include (KCSHORT, KCLONG)
    
    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_au_id')
        create index idx_claims_klperilcodes_au_id on claims_klperilcodes_au(KLPERCODE) include (KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_nz_id')
        create index idx_claims_klperilcodes_nz_id on claims_klperilcodes_nz(KLPERCODE) include (KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_uk_id')
        create index idx_claims_klperilcodes_uk_id on claims_klperilcodes_uk(KLPERCODE) include (KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_uk2_id')
        create index idx_claims_klperilcodes_uk2_id on claims_klperilcodes_uk2(KLPERCODE) include (KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_au_cid')
        create index idx_claims_klperilcodes_au_cid on claims_klperilcodes_au(KLPER_ID) include (KLPERCODE,KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klperilcodes_uk2_cid')
        create index idx_claims_klperilcodes_uk2_cid on claims_klperilcodes_uk2(KLPER_ID) include (KLPERCODE,KLPERDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcountry_au_id')
        create index idx_claims_klcountry_au_id on claims_klcountry_au(KLCNTRYCODE) include (KLCNTRYDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcountry_nz_id')
        create index idx_claims_klcountry_nz_id on claims_klcountry_nz(KLCNTRYCODE) include (KLCNTRYDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcountry_uk_id')
        create index idx_claims_klcountry_uk_id on claims_klcountry_uk(KLCNTRYCODE) include (KLCNTRYDESC)
   
    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaims_uk2_id')
        create index idx_claims_tblOnlineClaims_uk2_id on claims_tblOnlineClaims_uk2(ClaimId) include (AlphaCode, ConsultantName, OnlineClaimId, ClaimCauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaims_uk2_eid')
        create index idx_claims_tblOnlineClaims_uk2_eid on claims_tblOnlineClaims_uk2(ClaimCauseId) include (OnlineClaimId, ClaimId, KLDOMAINID)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimEventCauses_uk2_id')
        create clustered index idx_claims_tblOnlineClaimEventCauses_uk2_id on claims_tblOnlineClaimEventCauses_uk2(EventCauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimants_uk2_id')
        create clustered index idx_claims_tblOnlineClaimants_uk2_id on claims_tblOnlineClaimants_uk2(OnlineClaimId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantOtherSourceDetails_uk2_id')
        create clustered index idx_claims_tblOnlineClaimantOtherSourceDetails_uk2_id on claims_tblOnlineClaimantOtherSourceDetails_uk2(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantCreditCards_uk2_id')
        create clustered index idx_claims_tblOnlineClaimantCreditCards_uk2_id on claims_tblOnlineClaimantCreditCards_uk2(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimantPastClaimDetails_uk2_id')
        create clustered index idx_claims_tblOnlineClaimantPastClaimDetails_uk2_id on claims_tblOnlineClaimantPastClaimDetails_uk2(ClaimantId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimEventSections_uk2_id')
        create clustered index idx_claims_tblOnlineClaimEventSections_uk2_id on claims_tblOnlineClaimEventSections_uk2(CauseId)

    if not exists (select null from sys.indexes where name = 'idx_claims_tblOnlineClaimDeclarations_uk2_id')
        create clustered index idx_claims_tblOnlineClaimDeclarations_uk2_id on claims_tblOnlineClaimDeclarations_uk2(declarationid)

    if not exists (select null from sys.indexes where name = 'idx_claims_klsecurity_uk2_id')
        create index idx_claims_klsecurity_uk2_id on claims_klsecurity_uk2(KS_ID) include (KSNAME)
        
    if not exists (select null from sys.indexes where name = 'idx_claims_klstatus_uk2_id')
        create index idx_claims_klstatus_uk2_id on claims_klstatus_uk2(KT_ID, KTTABLE) include (KTSTATUS, KTDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_klproducts_uk2_id')
        create index idx_claims_klproducts_uk2_id on claims_klproducts_uk2(KPProd_ID) include (KPPRODUCT)

    if not exists (select null from sys.indexes where name = 'idx_claims_klreg_uk2_id')
        create index idx_claims_klreg_uk2_id on claims_klreg_uk2(KLCLAIM) include (KLPRODUCT, KLDISS, KLDOMAINID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klbenefit_uk2_id')
        create index idx_claims_klbenefit_uk2_id on claims_klbenefit_uk2(KBCODE, KBPROD, KBVALIDFROM, KBVALIDTO) include (KBSECT_ID)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcatas_uk2_id')
        create index idx_claims_klcatas_uk2_id on claims_klcatas_uk2(KC_CODE) include (KCSHORT, KCLONG)

    if not exists (select null from sys.indexes where name = 'idx_claims_klcountry_uk2_id')
        create index idx_claims_klcountry_uk2_id on claims_klcountry_uk2(KLCNTRYCODE) include (KLCNTRYDESC)

    if not exists (select null from sys.indexes where name = 'idx_claims_chqWording_au_id')
        create index idx_claims_chqWording_au_id on claims_chqWording_au(chqBATCH,chqPAYID) include (chqWORDINGS)

    if not exists (select null from sys.indexes where name = 'idx_claims_chqWording_nz_id')
        create index idx_claims_chqWording_nz_id on claims_chqWording_nz(chqBATCH,chqPAYID) include (chqWORDINGS)

    if not exists (select null from sys.indexes where name = 'idx_claims_chqWording_uk_id')
        create index idx_claims_chqWording_uk_id on claims_chqWording_uk(chqBATCH,chqPAYID) include (chqWORDINGS)

    if not exists (select null from sys.indexes where name = 'idx_claims_chqWording_uk2_id')
        create index idx_claims_chqWording_uk2_id on claims_chqWording_uk2(chqBATCH,chqPAYID) include (chqWORDINGS)
        
end



GO
