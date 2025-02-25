USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penOutlet_bkp20240201]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[etlsp_cmdwh_penOutlet_bkp20240201]    
as    
begin    
/************************************************************************************************************************************    
Author:         Linus Tor    
Date:           20120125    
Prerequisite:   Requires Penguin Data Model ETL successfully run.    
Description:    Outlet table contains agency attributes. Many of the tables derived from  tblReferenceValue.    
                This transformation adds essential key fields and implemented slow changing dimension technique to track    
                changes to the agency attributes.    
Change History:    
                20120125 - LT - Procedure created    
                20120321 - LT - Added PaymentType column to penOutlet table.    
                20120510 - LS - Add Trading Status    
                20121106 - LS - refactoring & domain related changes    
                20121217 - LS - Case 18108, Regression bug fix, BDM, Admin and other names should've look up CRM User table    
                20130617 - LS - TFS 7664/8556/8557, UK Penguin    
                20130619 - LS - bug fix, CCsales flag should lookup value instead of ID    
                20130701 - LS - bug fix, state fields are state names changed from varchar(3) to varchar(100)    
                20130809 - LS - add encrypted account number, part of AR cases (18915, 18927, 18945, 18946, 18947, 18955)    
                20130814 - LT - added nonclustered index to group    
                20130906 - LS - related to penUser unexplained binary subquery bug    
                                changing the binary subquery to left join as precaution    
                20131205 - LS - case 19805, new supergroup; Air NZ    
                20140102 - LS - add Helloworld to Stella (Ben's email)    
                20140123 - LT - added Helloworld Associates to Stella super group (John Kombos' email)    
                20140128 - LT - Added FCAreaCode column (required for Flight Centre TRIPS migration to Penguin    
                20140202 - LT - Added IAL to SuperGroupName    
                20140312 - LS - Update encrypted account number    
                20140321 - LT - Added Helloworld Affiliates to Stella super group (Fogbugz #20570)    
                20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)    
                20140617 - LS - TFS 12416, schema and index cleanup    
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data    
                20140709 - LT - Removed last Update statement. This is a bug that updates old history with current data. The history    
                                should not be updated.    
                20141014 - LS - F22154, track FC Nation & Area values, not ID    
                20141015 - LS - F22154, revert changes on 20140709, bring back the update statement *except* the BDM name    
                                this makes it inline with dimOutlet which tracks BDM only as type 2    
                20150128 - LT - Updated SuperGroupName definition for NZ to include IAG NZ and Farmers Mutual Group.    
                20150130 - LT - Updated SuperGroupName definition for CN to include Direct    
                20150226 - LS - changes on which fields are type 2    
                                update type 1 fields for all records, not just Not Current ones    
                                use identifier _and_ hash when comparing instead of hash alone (hash has a collision probability)    
                20150330 - LS - F23793, add LatestOutletKey for recoded alphas    
                20150409 - LS - F23793, don't track different supergroups    
                20150421 - LT - Changed ASICNumber column to nvarchar(50) in penOutlet table definition    
                20150424 - LS - F24210, store lineage for reconciliation report    
                20150428 - LS - F24210, revert the supergroup limitation (F23793)    
        20150408 - LS - TFS 15452, add AgencyGrading    
                20150706 - LT - added Simas Net as supergroup where GroupCode = SN    
                20150917 - LT - added P&O Cruises as supergroup where GroupCode = PO    
                20151027 - DM - Added Virgin as a supergroup where GroupCode = VA, Added Column DistributorKey    
                20151109 - DM - Added Westpac NZ as a supergroup where GroupCode = WP for NZ only    
                20160321 - LT - Penguin 18.0, Added ChannelID, JV, JVCode, JVID and US penguin instance    
                20160419 - PZ - Penguin 18.5, Add super group for CN Palm You    
                20160531 - PZ - Penguin 19.0, Add super group for NZ Mosaic (aka Volo)    
                20160727 - LT - Penguin 20.0, Added super group for HIF (AU)    
                20160804 - PZ - Penguin 20.5, Added group for AHM (AU) (supergroup changed from Indies to Medibank)    
                20161026 - LT - Penguin 21.5, Added World Traveller Group to Cover-More Indies Super group for NZ.    
                                              Added Westfund to Independents super group (AU)                
                20161207 - LT - Penguin 22.0, Added Ticketek to Super Group (AU)    
                20170505 - SD - Penguin 24.5, TFS 30940, Added AMIAreaCode, AMIArea, AMINAtion and AMIEGMNation columns, also changed logic for FCArea columns    
    20170713 - LT - Amended NZ Cover-More Directs supergroup definition to include TSN0077.    
    20170912 - SD - Added Independents as Super group where GroupCode = HP    
    20171109 - LT - Added Coles as Super Group where GroupCode = CF    
    20171117 - LT - helloworld SuperGroupName amendments for helloworld Integration, helloworld travel wholesale, and JTN    
    20171220 - RL - Adding SuperGroupNaming Mapping for Group Code AI NT AV CR HC RG HO YG ZU AR IN in AU, BK CB CR TK AR in NZ, ST TN in UK, QN SB in CN    
    20180322 - RL - Adding SuperGroupNaming Mapping for Group Code GC    
    20180322 - RL - Adding SuperGroupNaming Mapping for Group Code CG TX, both group codes are from migrated TRIPS data    
    20180613 - LT - Added SugarCRMID column.    
    20180927 - LT - Added super group name 'CBA Group'    
    20190123 - LT - Added Super Group Name 'Easy Travel Insurance'    
    20190619 - SD - Added Group "Magellan" (GroupCode = MG) into Supergroup "Stella" 
    20210306, SS, CHG0034615 Add filter for BK.com     
*************************************************************************************************************************************/    
    
    set nocount on    
    
    /* staging index */    
    exec etlsp_StagingIndex_Penguin    
    
    if object_id('etl_penOutlet') is not null    
        drop table etl_penOutlet    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, o.OutletID) OutletKey,    
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(varchar(20),null) as OutletStatus,    
        convert(datetime,null) as OutletStartDate,    
        convert(datetime,null) as OutletEndDate,    
        convert(binary,null) as OutletHashKey,    
        o.DomainID,    
        o.OutletID,    
        g.ID as GroupID,    
        o.SubGroupID,    
        o.OutletTypeID,    
        o.OutletName,    
        ot.OutletType,    
        o.AlphaCode,    
        o.StatusValue,    
        dbo.xfn_ConvertUTCtoLocal(o.CommencementDate, TimeZone) CommencementDate,    
        dbo.xfn_ConvertUTCtoLocal(o.CloseDate, TimeZone) CloseDate,    
        o.PreviousAlpha,    
        o.StatusRegion as StatusRegionID,    
        dbo.fn_GetReferenceValueByID(o.StatusRegion, CompanyKey, CountrySet) StatusRegion,    
        oci.Title as ContactTitle,    
        oci.Initial as ContactInitial,    
        oci.FirstName as ContactFirstName,    
        oci.LastName as ContactLastName,    
        oci.ManagerEmail as ContactManagerEmail,    
        oci.Phone as ContactPhone,    
        oci.Fax as ContactFax,    
     oci.Email as ContactEmail,    
        oci.Street as ContactStreet,    
        oci.Suburb as ContactSuburb,    
        oci.State as ContactState,    
        oci.PostCode as ContactPostCode,    
        oci.POBox as ContactPOBox,    
       oci.MailSuburb as ContactMailSuburb,    
        oci.MailState as ContactMailState,    
        oci.MailPostCode as ContactMailPostCode,    
        g.DomainID as GroupDomainID,    
        convert(varchar(25),null) as SuperGroupName,    
        g.Name as GroupName,    
        g.Code as GroupCode,    
        dbo.xfn_ConvertUTCtoLocal(g.StartDate, TimeZone) GroupStartDate,    
        g.Phone as GroupPhone,    
        g.Fax as GroupFax,    
        g.Email as GroupEmail,    
        g.Street as GroupStreet,    
        g.Suburb as GroupSuburb,    
        g.PostCode as GroupPostCode,    
        g.MailSuburb as GroupMailSuburb,    
        g.MailState as GroupMailState,    
        g.MailPostCode as GroupMailPostCode,    
        g.POBox as GroupPOBox,    
        sg.Name as SubGroupName,    
        sg.Code as SubGroupCode,    
        dbo.xfn_ConvertUTCtoLocal(sg.StartDate, TimeZone) SubGroupStartDate,    
        sg.Phone as SubGroupPhone,    
        sg.Fax as SubGroupFax,    
        sg.Email as SubGroupEmail,    
        sg.Street as SubGroupStreet,    
        sg.Suburb as SubGroupSuburb,    
        sg.PostCode as SubGroupPostCode,    
        sg.MailSuburb as SubGroupMailSuburb,    
        sg.MailState as SubGroupMailState,    
        sg.MailPostCode as SubGroupMailPostCode,    
        sg.POBox as SubGroupPOBox,    
        ofi.Title as AcctOfficerTitle,    
        ofi.AcctOfficerFirstName as AcctOfficerFirstName,    
        ofi.AcctOfficerLastName as AcctOfficerLastName,    
        ofi.AcctOfficerEmail as AcctOfficerEmail,    
        ofi.PaymentTypeID,    
        dbo.fn_GetReferenceValueByID(ofi.PaymentTypeID, CompanyKey, CountrySet) PaymentType,    
        ofi.AccountName,    
        ofi.BSB,    
        ofi.AccountNumber,    
        ofi.AccountsEmail,    
        dbo.fn_GetReferenceCodeByID(ofi.CCSaleOnly, CompanyKey, CountrySet) CCSaleOnly,    
        ofsri.FSRTypeID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSRTypeID, CompanyKey, CountrySet) FSRType,    
        ofsri.FSGCategoryID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSGCategoryID, CompanyKey, CountrySet) FSGCategory,    
        ofsri.LegalEntityName,    
        ofsri.ASICNumber,    
        ofsri.ABN,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.ASICCheckDate, TimeZone) ASICCheckDate,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.AgreementDate, TimeZone) AgreementDate,    
        omi.BDMID,    
        bdm.BDMName,    
        omi.BDMCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.BDMCallFreqID, CompanyKey, CountrySet) BDMCallFrequency,    
        omi.AcctManagerID,    
        am.AcctManagerName,    
        omi.AcctMgrCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.AcctMgrCallFreqID, CompanyKey, CountrySet) AcctMgrCallFrequency,    
        omi.AdminExecID,    
        ae.AdminExecName,    
        omi.ExtID,    
        omi.ExtBDMID,    
        dbo.fn_GetReferenceValueByID(omi.ExtBDMID, CompanyKey, CountrySet) ExternalBDMName,    
        omi.SalesSegment,    
        omi.PotentialSales,    
        omi.SalesTierID,    
        dbo.fn_GetReferenceValueByID(omi.SalesTierID, CompanyKey, CountrySet) SalesTier,    
        osi.Branch,    
        osi.Website,    
        osi.EGMNationID,    
        fc.EGMNation,    
        osi.FCNationID,    
        fc.FCNation,    
        fc.FCAreaID,    
        fc.FCArea,    
        osi.STARegionID,    
        dbo.fn_GetReferenceValueByID(osi.STARegionID, CompanyKey, CountrySet) STARegion,    
        osi.StateSalesAreaID,    
        dbo.fn_GetReferenceValueByID(osi.StateSalesAreaID, CompanyKey, CountrySet) StateSalesArea,    
        dbo.fn_GetReferenceValueByID(o.StatusValue, CompanyKey, CountrySet) TradingStatus,    
        fc.FCAreaCode,    
        dbo.fn_GetReferenceValueByID(osi.AgencyGradingId, CompanyKey, CountrySet) AgencyGrading,    
        PrefixKey + convert(varchar, g.Distributorid) as DistributorKey,    
        g.Distributorid,    
        jv.JVID,    
        jv.JV,    
        jv.JVCode,    
        ch.ChannelId,    
        ch.Channel,    
        ami.AMIArea,    
        ami.AMIAreaCode,    
        ami.AMINation,    
        ami.AMIEGMNation,    
  osi.SugarCRMID    
    into etl_penOutlet    
    from     
        dbo.penguin_tblOutlet_aucm o    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'AU') dk    
        left join dbo.penguin_tblOutletContactInfo_aucm oci on    
            o.OutletID = oci.OutletID    
        left join dbo.penguin_tblSubGroup_aucm sg on    
            o.SubGroupID = sg.ID    
        inner join dbo.penguin_tblGroup_aucm g on    
            sg.GroupID = g.ID    
        left join dbo.penguin_tblOutletFinancialInfo_aucm ofi on    
            o.OutletID = ofi.OutletID    
        left join dbo.penguin_tblOutletFSRInfo_aucm ofsri on    
            o.OutletID = ofsri.OutletID    
        left join dbo.penguin_tblOutletManagerInfo_aucm omi on    
            o.OutletID = omi.OutletID    
        inner join dbo.penguin_tblOutletType_aucm ot on    
            o.OutletTypeID = ot.OutletTypeID    
        left join dbo.penguin_tblOutletShopInfo_aucm osi on    
            o.OutletID = osi.OutletID    
        outer apply /* penguin doesn't update nation id & egm id */    
        (    
            select    
                a.id FCAreaID,    
                a.Code  FCAreaCode,    
                a.Value FCArea,    
                n.Value FCNation,    
                e.Value EGMNation    
            from    
                penguin_tblReferenceValue_aucm a    
                left join penguin_tblReferenceValue_aucm n on    
                    n.ID = a.ParentID    
                left join penguin_tblReferenceValue_aucm e on    
                    e.ID = n.ParentID    
            where    
                a.id = osi.FCAreaID and    
                a.GroupID Not in (Select ID from penguin_tblReferenceValueGroup_aucm where Name = 'AM_Areas')    
        ) fc    
        outer apply /* Fetching AMINation, AMIEGMNation, AMIArea and AMIAreaCode from Penguin */    
        (    
            select    
                a2.Code  AMIAreaCode,    
                a2.Value AMIArea,    
                n2.Value AMINation,    
                e2.Value AMIEGMNation    
            from    
                penguin_tblReferenceValue_aucm a2    
                left join penguin_tblReferenceValue_aucm n2 on    
                    n2.ID = a2.ParentID    
                left join penguin_tblReferenceValue_aucm e2 on    
                    e2.ID = n2.ParentID    
            where    
                a2.id = osi.FCAreaID and    
                a2.GroupID in (Select ID from penguin_tblReferenceValueGroup_aucm where Name = 'AM_Areas')    
        ) ami    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName BDMName    
            from    
                penguin_tblCRMUser_aucm    
            where    
                ID = omi.BDMID    
        ) bdm    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AcctManagerName    
            from    
                penguin_tblCRMUser_aucm    
            where    
                ID = omi.AcctManagerID    
        ) am    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AdminExecName    
            from    
                penguin_tblCRMUser_aucm    
            where    
                ID = omi.AdminExecID    
        ) ae    
        outer apply    
        (    
            select top 1    
                JointVentureID as JVID,    
                Name as JV,    
                Code as JVCode    
            from    
                penguin_tblJointVenture_aucm    
            where    
                JointVentureID = o.JointVentureID    
        ) jv    
       outer apply    
        (    
            select top 1    
                r.ID as ChanneLID,    
                r.Value as Channel    
             from     
                penguin_tblReferenceValue_aucm r    
                join penguin_tblReferenceValueGroup_aucm rg on r.GroupID=rg.ID    
                join penguin_tblOutlet_OTC_aucm otc on r.ID = otc.ChannelId    
            where     
                rg.Name= 'channel' and    
                otc.OutletID = o.OutletId    
        ) ch    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, o.OutletID) OutletKey,    
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(varchar(20),null) as OutletStatus,    
        convert(datetime,null) as OutletStartDate,    
        convert(datetime,null) as OutletEndDate,    
        convert(binary,null) as OutletHashKey,    
        o.DomainID,    
        o.OutletID,    
        g.ID as GroupID,    
        o.SubGroupID,    
        o.OutletTypeID,    
        o.OutletName,    
        ot.OutletType,    
        o.AlphaCode,    
        o.StatusValue,    
        dbo.xfn_ConvertUTCtoLocal(o.CommencementDate, TimeZone) CommencementDate,    
        dbo.xfn_ConvertUTCtoLocal(o.CloseDate, TimeZone) CloseDate,    
        o.PreviousAlpha,    
        o.StatusRegion as StatusRegionID,    
        dbo.fn_GetReferenceValueByID(o.StatusRegion, CompanyKey, CountrySet) StatusRegion,    
        oci.Title as ContactTitle,    
        oci.Initial as ContactInitial,    
        oci.FirstName as ContactFirstName,    
        oci.LastName as ContactLastName,    
        oci.ManagerEmail as ContactManagerEmail,    
        oci.Phone as ContactPhone,    
        oci.Fax as ContactFax,    
        oci.Email as ContactEmail,    
        oci.Street as ContactStreet,    
        oci.Suburb as ContactSuburb,    
        oci.State as ContactState,    
        oci.PostCode as ContactPostCode,    
        oci.POBox as ContactPOBox,    
        oci.MailSuburb as ContactMailSuburb,    
        oci.MailState as ContactMailState,    
        oci.MailPostCode as ContactMailPostCode,    
        g.DomainID as GroupDomainID,    
        convert(varchar(25),null) as SuperGroupName,    
        g.Name as GroupName,    
        g.Code as GroupCode,    
        dbo.xfn_ConvertUTCtoLocal(g.StartDate, TimeZone) GroupStartDate,    
        g.Phone as GroupPhone,    
        g.Fax as GroupFax,    
        g.Email as GroupEmail,    
        g.Street as GroupStreet,    
        g.Suburb as GroupSuburb,    
        g.PostCode as GroupPostCode,    
        g.MailSuburb as GroupMailSuburb,    
        g.MailState as GroupMailState,    
        g.MailPostCode as GroupMailPostCode,    
        g.POBox as GroupPOBox,    
        sg.Name as SubGroupName,    
        sg.Code as SubGroupCode,    
        dbo.xfn_ConvertUTCtoLocal(sg.StartDate, TimeZone) SubGroupStartDate,    
        sg.Phone as SubGroupPhone,    
        sg.Fax as SubGroupFax,    
        sg.Email as SubGroupEmail,    
        sg.Street as SubGroupStreet,    
        sg.Suburb as SubGroupSuburb,    
        sg.PostCode as SubGroupPostCode,    
        sg.MailSuburb as SubGroupMailSuburb,    
        sg.MailState as SubGroupMailState,    
        sg.MailPostCode as SubGroupMailPostCode,    
        sg.POBox as SubGroupPOBox,    
        ofi.Title as AcctOfficerTitle,    
        ofi.AcctOfficerFirstName as AcctOfficerFirstName,    
        ofi.AcctOfficerLastName as AcctOfficerLastName,    
        ofi.AcctOfficerEmail as AcctOfficerEmail,    
        ofi.PaymentTypeID,    
        dbo.fn_GetReferenceValueByID(ofi.PaymentTypeID, CompanyKey, CountrySet) PaymentType,    
        ofi.AccountName,    
        ofi.BSB,    
        ofi.AccountNumber,    
        ofi.AccountsEmail,    
        dbo.fn_GetReferenceCodeByID(ofi.CCSaleOnly, CompanyKey, CountrySet) CCSaleOnly,    
        ofsri.FSRTypeID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSRTypeID, CompanyKey, CountrySet) FSRType,    
        ofsri.FSGCategoryID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSGCategoryID, CompanyKey, CountrySet) FSGCategory,    
        ofsri.LegalEntityName,    
        ofsri.ASICNumber,    
        ofsri.ABN,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.ASICCheckDate, TimeZone) ASICCheckDate,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.AgreementDate, TimeZone) AgreementDate,    
        omi.BDMID,    
        bdm.BDMName,    
        omi.BDMCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.BDMCallFreqID, CompanyKey, CountrySet) BDMCallFrequency,    
        omi.AcctManagerID,    
        am.AcctManagerName,    
        omi.AcctMgrCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.AcctMgrCallFreqID, CompanyKey, CountrySet) AcctMgrCallFrequency,    
        omi.AdminExecID,    
ae.AdminExecName,    
        omi.ExtID,    
        omi.ExtBDMID,    
        dbo.fn_GetReferenceValueByID(omi.ExtBDMID, CompanyKey, CountrySet) ExternalBDMName,    
        omi.SalesSegment,    
        omi.PotentialSales,    
        omi.SalesTierID,    
        dbo.fn_GetReferenceValueByID(omi.SalesTierID, CompanyKey, CountrySet) SalesTier,    
        osi.Branch,    
        osi.Website,    
        osi.EGMNationID,    
        fc.EGMNation,    
        osi.FCNationID,    
        fc.FCNation,    
        fc.FCAreaID,    
        fc.FCArea,    
        osi.STARegionID,    
        dbo.fn_GetReferenceValueByID(osi.STARegionID, CompanyKey, CountrySet) STARegion,    
        osi.StateSalesAreaID,    
        dbo.fn_GetReferenceValueByID(osi.StateSalesAreaID, CompanyKey, CountrySet) StateSalesArea,    
        dbo.fn_GetReferenceValueByID(o.StatusValue, CompanyKey, CountrySet) TradingStatus,    
        fc.FCAreaCode,    
        dbo.fn_GetReferenceValueByID(osi.AgencyGradingId, CompanyKey, CountrySet) AgencyGrading,    
        PrefixKey + convert(varchar, g.Distributorid) as DistributorKey,    
        g.Distributorid,    
        jv.JVID,    
        jv.JV,    
        jv.JVCode,    
        ch.ChannelID,    
        ch.Channel,    
        ami.AMIArea,    
        ami.AMIAreaCode,    
        ami.AMINation,    
        ami.AMIEGMNation,    
  osi.SugarCRMID    
    from    
        dbo.penguin_tblOutlet_autp o    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'TIP', 'AU') dk    
        left join dbo.penguin_tblOutletContactInfo_autp oci on    
            o.OutletID = oci.OutletID    
        left join dbo.penguin_tblSubGroup_autp sg on    
            o.SubGroupID = sg.ID    
        inner join dbo.penguin_tblGroup_autp g on    
            sg.GroupID = g.ID    
        left join dbo.penguin_tblOutletFinancialInfo_autp ofi on    
            o.OutletID = ofi.OutletID    
        left join dbo.penguin_tblOutletFSRInfo_autp ofsri on    
            o.OutletID = ofsri.OutletID    
        left join dbo.penguin_tblOutletManagerInfo_autp omi on    
            o.OutletID = omi.OutletID    
        inner join dbo.penguin_tblOutletType_autp ot on    
            o.OutletTypeID = ot.OutletTypeID    
        left join dbo.penguin_tblOutletShopInfo_autp osi on    
            o.OutletID = osi.OutletID    
        outer apply /* penguin doesn't update nation id & egm id */    
        (    
            select    
                a.id FCAreaID,    
                a.Code  FCAreaCode,    
                a.Value FCArea,    
                n.Value FCNation,    
                e.Value EGMNation    
            from    
                penguin_tblReferenceValue_autp a    
                left join penguin_tblReferenceValue_autp n on    
                    n.ID = a.ParentID    
                left join penguin_tblReferenceValue_autp e on    
                    e.ID = n.ParentID    
            where    
                a.id = osi.FCAreaID and    
                a.GroupID Not in (Select ID from penguin_tblReferenceValueGroup_autp where Name = 'AM_Areas')    
        ) fc    
        outer apply /* Fetching AMINation, AMIEGMNation, AMIArea and AMIAreaCode from Penguin */    
        (    
            select    
                a2.Code  AMIAreaCode,    
                a2.Value AMIArea,    
                n2.Value AMINation,    
                e2.Value AMIEGMNation    
            from    
                penguin_tblReferenceValue_autp a2    
                left join penguin_tblReferenceValue_autp n2 on    
                    n2.ID = a2.ParentID    
                left join penguin_tblReferenceValue_autp e2 on    
                    e2.ID = n2.ParentID    
            where    
                a2.id = osi.FCAreaID and    
                a2.GroupID in (Select ID from penguin_tblReferenceValueGroup_autp where Name = 'AM_Areas')    
        ) ami    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName BDMName    
            from    
                penguin_tblCRMUser_autp    
            where    
                ID = omi.BDMID    
        ) bdm    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AcctManagerName    
            from    
                penguin_tblCRMUser_autp    
            where    
                ID = omi.AcctManagerID    
        ) am    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AdminExecName    
            from    
                penguin_tblCRMUser_autp    
            where    
                ID = omi.AdminExecID    
        ) ae    
        outer apply    
        (    
            select top 1    
                JointVentureID as JVID,    
                Name as JV,    
                Code as JVCode    
            from    
                penguin_tblJointVenture_autp    
            where    
                JointVentureID = o.JointVentureID    
        ) jv    
        outer apply    
        (    
            select top 1    
                r.ID as ChanneLID,    
                r.Value as Channel    
             from     
                penguin_tblReferenceValue_autp r    
                join penguin_tblReferenceValueGroup_autp rg on r.GroupID=rg.ID    
                join penguin_tblOutlet_OTC_autp otc on r.ID = otc.ChannelId    
            where     
                rg.Name= 'channel' and    
                otc.OutletID = o.OutletId    
        ) ch    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, o.OutletID) OutletKey,    
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(varchar(20),null) as OutletStatus,    
        convert(datetime,null) as OutletStartDate,    
        convert(datetime,null) as OutletEndDate,    
        convert(binary,null) as OutletHashKey,    
        o.DomainID,    
        o.OutletID,    
        g.ID as GroupID,    
        o.SubGroupID,    
        o.OutletTypeID,    
        o.OutletName,    
        ot.OutletType,    
        o.AlphaCode,    
        o.StatusValue,    
        dbo.xfn_ConvertUTCtoLocal(o.CommencementDate, TimeZone) CommencementDate,    
        dbo.xfn_ConvertUTCtoLocal(o.CloseDate, TimeZone) CloseDate,    
        o.PreviousAlpha,    
        o.StatusRegion as StatusRegionID,    
        dbo.fn_GetReferenceValueByID(o.StatusRegion, CompanyKey, CountrySet) StatusRegion,    
        oci.Title as ContactTitle,    
        oci.Initial as ContactInitial,    
        oci.FirstName as ContactFirstName,    
        oci.LastName as ContactLastName,    
        oci.ManagerEmail as ContactManagerEmail,    
        oci.Phone as ContactPhone,    
        oci.Fax as ContactFax,    
        oci.Email as ContactEmail,    
        oci.Street as ContactStreet,    
        oci.Suburb as ContactSuburb,    
        oci.State as ContactState,    
        oci.PostCode as ContactPostCode,    
        oci.POBox as ContactPOBox,    
        oci.MailSuburb as ContactMailSuburb,    
        oci.MailState as ContactMailState,    
        oci.MailPostCode as ContactMailPostCode,    
        g.DomainID as GroupDomainID,    
        convert(varchar(25),null) as SuperGroupName,    
        g.Name as GroupName,    
        g.Code as GroupCode,    
        dbo.xfn_ConvertUTCtoLocal(g.StartDate, TimeZone) GroupStartDate,    
        g.Phone as GroupPhone,    
        g.Fax as GroupFax,    
        g.Email as GroupEmail,    
        g.Street as GroupStreet,    
        g.Suburb as GroupSuburb,    
        g.PostCode as GroupPostCode,    
        g.MailSuburb as GroupMailSuburb,    
        g.MailState as GroupMailState,    
        g.MailPostCode as GroupMailPostCode,    
        g.POBox as GroupPOBox,    
        sg.Name as SubGroupName,    
        sg.Code as SubGroupCode,    
        dbo.xfn_ConvertUTCtoLocal(sg.StartDate, TimeZone) SubGroupStartDate,    
        sg.Phone as SubGroupPhone,    
        sg.Fax as SubGroupFax,    
        sg.Email as SubGroupEmail,    
        sg.Street as SubGroupStreet,    
        sg.Suburb as SubGroupSuburb,    
        sg.PostCode as SubGroupPostCode,    
        sg.MailSuburb as SubGroupMailSuburb,    
        sg.MailState as SubGroupMailState,    
        sg.MailPostCode as SubGroupMailPostCode,    
        sg.POBox as SubGroupPOBox,    
        ofi.Title as AcctOfficerTitle,    
        ofi.AcctOfficerFirstName as AcctOfficerFirstName,    
        ofi.AcctOfficerLastName as AcctOfficerLastName,    
        ofi.AcctOfficerEmail as AcctOfficerEmail,    
        ofi.PaymentTypeID,    
        dbo.fn_GetReferenceValueByID(ofi.PaymentTypeID, CompanyKey, CountrySet) PaymentType,    
        ofi.AccountName,    
        ofi.BSB,    
        ofi.AccountNumber,    
        ofi.AccountsEmail,    
        dbo.fn_GetReferenceCodeByID(ofi.CCSaleOnly, CompanyKey, CountrySet) CCSaleOnly,    
        ofsri.FSRTypeID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSRTypeID, CompanyKey, CountrySet) FSRType,    
        ofsri.FSGCategoryID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSGCategoryID, CompanyKey, CountrySet) FSGCategory,    
        ofsri.LegalEntityName,    
        ofsri.ASICNumber,    
        ofsri.ABN,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.ASICCheckDate, TimeZone) ASICCheckDate,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.AgreementDate, TimeZone) AgreementDate,    
        omi.BDMID,    
        bdm.BDMName,    
        omi.BDMCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.BDMCallFreqID, CompanyKey, CountrySet) BDMCallFrequency,    
        omi.AcctManagerID,    
        am.AcctManagerName,    
        omi.AcctMgrCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.AcctMgrCallFreqID, CompanyKey, CountrySet) AcctMgrCallFrequency,    
        omi.AdminExecID,    
        ae.AdminExecName,    
        omi.ExtID,    
        omi.ExtBDMID,    
        dbo.fn_GetReferenceValueByID(omi.ExtBDMID, CompanyKey, CountrySet) ExternalBDMName,    
        omi.SalesSegment,    
        omi.PotentialSales,    
        omi.SalesTierID,    
        dbo.fn_GetReferenceValueByID(omi.SalesTierID, CompanyKey, CountrySet) SalesTier,    
        osi.Branch,    
        osi.Website,    
        osi.EGMNationID,    
        fc.EGMNation,    
        osi.FCNationID,    
        fc.FCNation,    
        fc.FCAreaID,    
        fc.FCArea,    
        osi.STARegionID,    
        dbo.fn_GetReferenceValueByID(osi.STARegionID, CompanyKey, CountrySet) STARegion,    
        osi.StateSalesAreaID,    
        dbo.fn_GetReferenceValueByID(osi.StateSalesAreaID, CompanyKey, CountrySet) StateSalesArea,    
        dbo.fn_GetReferenceValueByID(o.StatusValue, CompanyKey, CountrySet) TradingStatus,    
        fc.FCAreaCode,    
        dbo.fn_GetReferenceValueByID(osi.AgencyGradingId, CompanyKey, CountrySet) AgencyGrading,    
        PrefixKey + convert(varchar, g.Distributorid) as DistributorKey,    
        g.Distributorid,    
        jv.JVID,    
        jv.JV,    
        jv.JVCode,    
        ch.ChannelID,    
        ch.Channel,    
        ami.AMIArea,    
        ami.AMIAreaCode,    
        ami.AMINation,    
        ami.AMIEGMNation,    
  osi.SugarCRMID    
    from     
        dbo.penguin_tblOutlet_ukcm o    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk    
        left join dbo.penguin_tblOutletContactInfo_ukcm oci on    
            o.OutletID = oci.OutletID    
        left join dbo.penguin_tblSubGroup_ukcm sg on    
            o.SubGroupID = sg.ID    
        inner join dbo.penguin_tblGroup_ukcm g on    
            sg.GroupID = g.ID    
        left join dbo.penguin_tblOutletFinancialInfo_ukcm ofi on    
            o.OutletID = ofi.OutletID    
        left join dbo.penguin_tblOutletFSRInfo_ukcm ofsri on    
            o.OutletID = ofsri.OutletID    
        left join dbo.penguin_tblOutletManagerInfo_ukcm omi on    
            o.OutletID = omi.OutletID    
        inner join dbo.penguin_tblOutletType_ukcm ot on    
            o.OutletTypeID = ot.OutletTypeID    
        left join dbo.penguin_tblOutletShopInfo_ukcm osi on    
            o.OutletID = osi.OutletID    
        outer apply /* penguin doesn't update nation id & egm id */    
        (    
            select    
                a.id FCAreaID,    
                a.Code  FCAreaCode,    
                a.Value FCArea,    
                n.Value FCNation,    
                e.Value EGMNation    
            from    
                penguin_tblReferenceValue_ukcm a    
                left join penguin_tblReferenceValue_ukcm n on    
                    n.ID = a.ParentID    
                left join penguin_tblReferenceValue_ukcm e on    
                    e.ID = n.ParentID    
            where    
                a.id = osi.FCAreaID and    
                a.GroupID Not in (Select ID from penguin_tblReferenceValueGroup_ukcm where Name = 'AM_Areas')    
        ) fc    
        outer apply /* Fetching AMINation, AMIEGMNation, AMIArea and AMIAreaCode from Penguin */    
        (    
            select    
                a2.Code  AMIAreaCode,    
                a2.Value AMIArea,    
                n2.Value AMINation,    
                e2.Value AMIEGMNation    
            from    
                penguin_tblReferenceValue_ukcm a2    
                left join penguin_tblReferenceValue_ukcm n2 on    
                    n2.ID = a2.ParentID    
                left join penguin_tblReferenceValue_ukcm e2 on    
                    e2.ID = n2.ParentID    
            where    
                a2.id = osi.FCAreaID and    
                a2.GroupID in (Select ID from penguin_tblReferenceValueGroup_ukcm where Name = 'AM_Areas')    
        ) ami    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName BDMName    
            from    
                penguin_tblCRMUser_ukcm    
            where    
                ID = omi.BDMID    
        ) bdm    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AcctManagerName    
            from    
                penguin_tblCRMUser_ukcm    
            where    
                ID = omi.AcctManagerID    
        ) am    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AdminExecName    
            from    
                penguin_tblCRMUser_ukcm    
            where    
                ID = omi.AdminExecID    
        ) ae    
        outer apply    
        (    
            select top 1    
                JointVentureID as JVID,    
                Name as JV,    
                Code as JVCode    
            from    
                penguin_tblJointVenture_ukcm    
            where    
                JointVentureID = o.JointVentureID    
        ) jv    
        outer apply    
        (    
            select top 1    
                r.ID as ChanneLID,    
                r.Value as Channel    
             from     
                penguin_tblReferenceValue_ukcm r    
                join penguin_tblReferenceValueGroup_ukcm rg on r.GroupID=rg.ID    
                join penguin_tblOutlet_OTC_ukcm otc on r.ID = otc.ChannelId    
            where     
                rg.Name= 'channel' and    
                otc.OutletID = o.OutletId    
        ) ch    
		where o.AlphaCode not like 'BK%'	------adding condition to filter out BK.com data

    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, o.OutletID) OutletKey,    
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(varchar(20),null) as OutletStatus,    
        convert(datetime,null) as OutletStartDate,    
        convert(datetime,null) as OutletEndDate,    
        convert(binary,null) as OutletHashKey,    
        o.DomainID,    
        o.OutletID,    
        g.ID as GroupID,    
        o.SubGroupID,    
        o.OutletTypeID,    
        o.OutletName,    
        ot.OutletType,    
        o.AlphaCode,    
        o.StatusValue,    
        dbo.xfn_ConvertUTCtoLocal(o.CommencementDate, TimeZone) CommencementDate,    
        dbo.xfn_ConvertUTCtoLocal(o.CloseDate, TimeZone) CloseDate,    
        o.PreviousAlpha,    
        o.StatusRegion as StatusRegionID,    
        dbo.fn_GetReferenceValueByID(o.StatusRegion, CompanyKey, CountrySet) StatusRegion,    
        oci.Title as ContactTitle,    
        oci.Initial as ContactInitial,    
        oci.FirstName as ContactFirstName,    
        oci.LastName as ContactLastName,    
        oci.ManagerEmail as ContactManagerEmail,    
        oci.Phone as ContactPhone,    
        oci.Fax as ContactFax,    
        oci.Email as ContactEmail,    
        oci.Street as ContactStreet,    
        oci.Suburb as ContactSuburb,    
        oci.State as ContactState,    
        oci.PostCode as ContactPostCode,    
        oci.POBox as ContactPOBox,    
        oci.MailSuburb as ContactMailSuburb,    
        oci.MailState as ContactMailState,    
        oci.MailPostCode as ContactMailPostCode,    
        g.DomainID as GroupDomainID,    
        convert(varchar(25),null) as SuperGroupName,    
        g.Name as GroupName,    
        g.Code as GroupCode,    
        dbo.xfn_ConvertUTCtoLocal(g.StartDate, TimeZone) GroupStartDate,    
        g.Phone as GroupPhone,    
        g.Fax as GroupFax,    
        g.Email as GroupEmail,    
        g.Street as GroupStreet,    
        g.Suburb as GroupSuburb,    
        g.PostCode as GroupPostCode,    
        g.MailSuburb as GroupMailSuburb,    
        g.MailState as GroupMailState,    
        g.MailPostCode as GroupMailPostCode,    
        g.POBox as GroupPOBox,    
        sg.Name as SubGroupName,    
        sg.Code as SubGroupCode,    
        dbo.xfn_ConvertUTCtoLocal(sg.StartDate, TimeZone) SubGroupStartDate,    
        sg.Phone as SubGroupPhone,    
        sg.Fax as SubGroupFax,    
        sg.Email as SubGroupEmail,    
        sg.Street as SubGroupStreet,    
        sg.Suburb as SubGroupSuburb,    
        sg.PostCode as SubGroupPostCode,    
        sg.MailSuburb as SubGroupMailSuburb,    
        sg.MailState as SubGroupMailState,    
        sg.MailPostCode as SubGroupMailPostCode,    
        sg.POBox as SubGroupPOBox,    
        ofi.Title as AcctOfficerTitle,    
        ofi.AcctOfficerFirstName as AcctOfficerFirstName,    
        ofi.AcctOfficerLastName as AcctOfficerLastName,    
        ofi.AcctOfficerEmail as AcctOfficerEmail,    
        ofi.PaymentTypeID,    
        dbo.fn_GetReferenceValueByID(ofi.PaymentTypeID, CompanyKey, CountrySet) PaymentType,    
        ofi.AccountName,    
        ofi.BSB,    
        ofi.AccountNumber,    
        ofi.AccountsEmail,    
        dbo.fn_GetReferenceCodeByID(ofi.CCSaleOnly, CompanyKey, CountrySet) CCSaleOnly,    
        ofsri.FSRTypeID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSRTypeID, CompanyKey, CountrySet) FSRType,    
        ofsri.FSGCategoryID,    
        dbo.fn_GetReferenceValueByID(ofsri.FSGCategoryID, CompanyKey, CountrySet) FSGCategory,    
        ofsri.LegalEntityName,    
        ofsri.ASICNumber,    
        ofsri.ABN,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.ASICCheckDate, TimeZone) ASICCheckDate,    
        dbo.xfn_ConvertUTCtoLocal(ofsri.AgreementDate, TimeZone) AgreementDate,    
  omi.BDMID,    
        bdm.BDMName,    
        omi.BDMCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.BDMCallFreqID, CompanyKey, CountrySet) BDMCallFrequency,    
        omi.AcctManagerID,    
        am.AcctManagerName,    
        omi.AcctMgrCallFreqID,    
        dbo.fn_GetReferenceValueByID(omi.AcctMgrCallFreqID, CompanyKey, CountrySet) AcctMgrCallFrequency,    
        omi.AdminExecID,    
        ae.AdminExecName,    
        omi.ExtID,    
        omi.ExtBDMID,    
        dbo.fn_GetReferenceValueByID(omi.ExtBDMID, CompanyKey, CountrySet) ExternalBDMName,    
        omi.SalesSegment,    
        omi.PotentialSales,    
        omi.SalesTierID,    
        dbo.fn_GetReferenceValueByID(omi.SalesTierID, CompanyKey, CountrySet) SalesTier,    
        osi.Branch,    
        osi.Website,    
        osi.EGMNationID,    
        fc.EGMNation,    
        osi.FCNationID,    
        fc.FCNation,    
        fc.FCAreaID,    
        fc.FCArea,    
        osi.STARegionID,    
        dbo.fn_GetReferenceValueByID(osi.STARegionID, CompanyKey, CountrySet) STARegion,    
        osi.StateSalesAreaID,    
        dbo.fn_GetReferenceValueByID(osi.StateSalesAreaID, CompanyKey, CountrySet) StateSalesArea,    
        dbo.fn_GetReferenceValueByID(o.StatusValue, CompanyKey, CountrySet) TradingStatus,    
        fc.FCAreaCode,    
        dbo.fn_GetReferenceValueByID(osi.AgencyGradingId, CompanyKey, CountrySet) AgencyGrading,    
        PrefixKey + convert(varchar, g.Distributorid) as DistributorKey,    
        g.Distributorid,    
        jv.JVID,    
        jv.JV,    
        jv.JVCode,    
        ch.ChannelID,    
        ch.Channel,    
        ami.AMIArea,    
        ami.AMIAreaCode,    
        ami.AMINation,    
        ami.AMIEGMNation,    
  osi.SugarCRMID    
    from     
        dbo.penguin_tblOutlet_uscm o    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'US') dk    
        left join dbo.penguin_tblOutletContactInfo_uscm oci on    
            o.OutletID = oci.OutletID    
        left join dbo.penguin_tblSubGroup_uscm sg on    
            o.SubGroupID = sg.ID    
        inner join dbo.penguin_tblGroup_uscm g on    
            sg.GroupID = g.ID    
        left join dbo.penguin_tblOutletFinancialInfo_uscm ofi on    
            o.OutletID = ofi.OutletID    
        left join dbo.penguin_tblOutletFSRInfo_uscm ofsri on    
            o.OutletID = ofsri.OutletID    
        left join dbo.penguin_tblOutletManagerInfo_uscm omi on    
            o.OutletID = omi.OutletID    
        inner join dbo.penguin_tblOutletType_uscm ot on    
            o.OutletTypeID = ot.OutletTypeID    
        left join dbo.penguin_tblOutletShopInfo_uscm osi on    
            o.OutletID = osi.OutletID    
        outer apply /* penguin doesn't update nation id & egm id */    
        (    
            select    
                a.id FCAreaID,    
                a.Code  FCAreaCode,    
                a.Value FCArea,    
                n.Value FCNation,    
                e.Value EGMNation    
            from    
                penguin_tblReferenceValue_uscm a    
                left join penguin_tblReferenceValue_uscm n on    
                    n.ID = a.ParentID    
                left join penguin_tblReferenceValue_uscm e on    
                    e.ID = n.ParentID    
            where    
                a.id = osi.FCAreaID and    
                a.GroupID Not in (Select ID from penguin_tblReferenceValueGroup_uscm where Name = 'AM_Areas')    
        ) fc    
        outer apply /* Fetching AMINation, AMIEGMNation, AMIArea and AMIAreaCode from Penguin */    
        (    
            select    
                a2.Code  AMIAreaCode,    
                a2.Value AMIArea,    
                n2.Value AMINation,    
                e2.Value AMIEGMNation    
            from    
                penguin_tblReferenceValue_uscm a2    
                left join penguin_tblReferenceValue_uscm n2 on    
                    n2.ID = a2.ParentID    
                left join penguin_tblReferenceValue_uscm e2 on    
                    e2.ID = n2.ParentID    
            where    
                a2.id = osi.FCAreaID and    
                a2.GroupID in (Select ID from penguin_tblReferenceValueGroup_uscm where Name = 'AM_Areas')    
        ) ami    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName BDMName    
            from    
                penguin_tblCRMUser_uscm    
            where    
                ID = omi.BDMID    
        ) bdm    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AcctManagerName    
            from    
                penguin_tblCRMUser_uscm    
            where    
                ID = omi.AcctManagerID    
        ) am    
        outer apply    
        (    
            select top 1    
                FirstName + ' ' + LastName AdminExecName    
            from    
                penguin_tblCRMUser_uscm    
            where    
                ID = omi.AdminExecID    
        ) ae    
        outer apply    
        (    
            select top 1    
                JointVentureID as JVID,    
                Name as JV,    
                Code as JVCode    
            from    
                penguin_tblJointVenture_uscm    
            where    
                JointVentureID = o.JointVentureID    
        ) jv    
        outer apply    
        (    
            select top 1    
                r.ID as ChanneLID,    
                r.Value as Channel    
             from     
                penguin_tblReferenceValue_uscm r    
                join penguin_tblReferenceValueGroup_uscm rg on r.GroupID=rg.ID    
                join penguin_tblOutlet_OTC_uscm otc on r.ID = otc.ChannelId    
            where     
                rg.Name= 'channel' and    
                otc.OutletID = o.OutletId    
        ) ch    
    
    create clustered index idx_etl_penOutlet_OutletKey on etl_penOutlet(OutletKey)    
    create index idx_etl_penOutlet_OutletHashKey on etl_penOutlet(OutletHashKey)    
    
      
    --Update Outlets with OutletHashKey values    
    update etl_penOutlet    
    set    
        OutletHashKey =    
            binary_checksum(    
                OutletKey,    
                AcctManagerID,    
                AcctManagerName,    
                BDMID,    
                BDMName,    
                EGMNation,    
                EGMNationID,    
                ExtBDMID,    
                ExternalBDMName,    
                ExtID,    
                FCArea,    
                FCAreaCode,    
                FCAreaID,    
                FCNation,    
                FCNationID,    
                GroupID,    
                GroupName,    
                OutletType,    
                OutletTypeID,    
                PreviousAlpha,    
                StateSalesArea,    
                StateSalesAreaID,    
                SubGroupID,    
                SubGroupName,    
                DistributorID,    
                JVID,    
                ChannelID,    
                AMIArea,    
                AMIAreaCode,    
                AMINation,    
                AMIEGMNation,    
    SugarCRMID    
            )    
    
    --create Agency table if not already created    
    if object_id('[db-au-cmdwh].dbo.penOutlet') is null    
    begin    
    
        create table [db-au-cmdwh].dbo.[penOutlet]    
        (    
            [CountryKey] varchar(2) not null,    
            [CompanyKey] varchar(5) not null,    
            [OutletKey] varchar(33) not null,    
            [OutletAlphaKey] nvarchar(50) not null,    
            [OutletSKey] bigint not null identity(1,1),    
            [OutletStatus] varchar(20) not null,    
            [OutletStartDate] datetime not null,    
            [OutletEndDate] datetime null,    
            [OutletHashKey] binary(30) null,    
            [OutletID] int not null,    
            [GroupID] int not null,    
            [SubGroupID] int not null,    
            [OutletTypeID] int not null,    
            [OutletName] nvarchar(50) not null,    
            [OutletType] nvarchar(50) not null,    
            [AlphaCode] nvarchar(20) not null,    
            [StatusValue] int not null,    
            [CommencementDate] datetime null,    
            [CloseDate] datetime null,    
            [PreviousAlpha] nvarchar(20) null,    
            [StatusRegionID] int null,    
            [StatusRegion] nvarchar(50) null,    
            [ContactTitle] nvarchar(100) null,    
            [ContactInitial] nvarchar(50) null,    
            [ContactFirstName] nvarchar(50) null,    
            [ContactLastName] nvarchar(50) null,    
            [ContactManagerEmail] nvarchar(100) null,    
            [ContactPhone] nvarchar(50) null,    
            [ContactFax] nvarchar(50) null,    
            [ContactEmail] nvarchar(100) null,    
            [ContactStreet] nvarchar(100) null,    
            [ContactSuburb] nvarchar(52) null,    
            [ContactState] nvarchar(100) null,    
            [ContactPostCode] nvarchar(50) null,    
            [ContactPOBox] nvarchar(100) null,    
            [ContactMailSuburb] nvarchar(52) null,    
            [ContactMailState] nvarchar(100) null,    
            [ContactMailPostCode] nvarchar(50) null,    
            [GroupDomainID] int not null,    
            [SuperGroupName] nvarchar(25) null,    
            [GroupName] nvarchar(50) not null,    
            [GroupCode] nvarchar(50) not null,    
            [GroupStartDate] datetime not null,    
            [GroupPhone] nvarchar(50) null,    
            [GroupFax] nvarchar(50) null,    
            [GroupEmail] nvarchar(100) null,    
            [GroupStreet] nvarchar(100) null,    
            [GroupSuburb] nvarchar(50) null,    
            [GroupPostCode] nvarchar(10) null,    
            [GroupMailSuburb] nvarchar(50) null,    
            [GroupMailState] nvarchar(100) null,    
            [GroupMailPostCode] nvarchar(10) null,    
            [GroupPOBox] nvarchar(50) null,    
            [SubGroupName] nvarchar(50) null,    
            [SubGroupCode] nvarchar(50) null,    
            [SubGroupStartDate] datetime null,    
            [SubGroupPhone] nvarchar(50) null,    
            [SubGroupFax] nvarchar(50) null,    
            [SubGroupEmail] nvarchar(100) null,    
            [SubGroupStreet] nvarchar(100) null,    
            [SubGroupSuburb] nvarchar(50) null,    
            [SubGroupPostCode] nvarchar(10) null,    
            [SubGroupMailSuburb] nvarchar(50) null,    
            [SubGroupMailState] nvarchar(100) null,    
            [SubGroupMailPostCode] nvarchar(10) null,    
            [SubGroupPOBox] nvarchar(50) null,    
            [AcctOfficerTitle] nvarchar(50) null,    
            [AcctOfficerFirstName] nvarchar(50) null,    
            [AcctOfficerLastName] nvarchar(50) null,    
            [AcctOfficerEmail] nvarchar(100) null,    
            [PaymentTypeID] int null,    
            [PaymentType] nvarchar(50) null,    
            [AccountName] nvarchar(100) null,    
            [BSB] nvarchar(50) null,    
            [AccountNumber] nvarchar(200) null,    
            [AccountsEmail] nvarchar(100) null,    
            [CCSaleOnly] int null,    
            [FSRTypeID] int null,    
            [FSRType] nvarchar(50) null,    
            [FSGCategoryID] int null,    
            [FSGCategory] nvarchar(50) null,    
            [LegalEntityName] nvarchar(100) null,    
            [ASICNumber] nvarchar(50) null,    
            [ABN] nvarchar(50) null,    
            [ASICCheckDate] datetime null,    
            [AgreementDate] datetime null,    
            [BDMID] int null,    
            [BDMName] nvarchar(101) null,    
            [BDMCallFreqID] int null,    
            [BDMCallFrequency] nvarchar(50) null,    
            [AcctManagerID] int null,    
            [AcctManagerName] nvarchar(101) null,    
            [AcctMgrCallFreqID] int null,    
            [AcctMgrCallFrequency] nvarchar(50) null,    
            [AdminExecID] int null,    
            [AdminExecName] nvarchar(101) null,    
            [ExtID] nvarchar(20) null,    
            [ExtBDMID] int null,    
            [ExternalBDMName] nvarchar(50) null,    
            [SalesSegment] nvarchar(50) null,    
            [PotentialSales] money null,    
            [SalesTierID] int null,    
            [SalesTier] nvarchar(50) null,    
            [Branch] nvarchar(60) null,    
            [Website] varchar(100) null,    
            [EGMNationID] int null,    
            [EGMNation] nvarchar(50) null,    
            [FCNationID] int null,    
            [FCNation] nvarchar(50) null,    
            [FCAreaID] int null,    
            [FCArea] nvarchar(50) null,    
            [STARegionID] int null,    
            [STARegion] nvarchar(50) null,    
            [StateSalesAreaID] int null,    
            [StateSalesArea] nvarchar(50) null,    
            [TradingStatus] nvarchar(50) null,    
            [DomainKey] varchar(41) null,    
            [DomainID] int null,    
            [EncryptedAccountNumber] varbinary(max) null,    
            [FCAreaCode] nvarchar(50) null,    
            [LatestOutletKey] varchar(33) null,    
            [AgencyGrading] nvarchar(50) null,    
            [DistributorKey] varchar(33) null,    
            [Distributorid] int null,    
            [JVID] int null,    
            [JV] nvarchar(55) null,    
            [JVCode] nvarchar(10),    
            [ChannelID] int null,    
            [Channel] nvarchar(100) null,    
            [AMIArea] nvarchar(50) null,    
            [AMIAreaCode] nvarchar(50) null,    
            [AMINation] nvarchar(50) null,    
            [AMIEGMNation] nvarchar(50) null,    
   [SugarCRMID] nvarchar(50) null    
        )    
    
        create clustered index idx_penOutlet_OutletKey on [db-au-cmdwh].dbo.penOutlet(OutletKey,OutletStatus)    
        create nonclustered index idx_penOutlet_AlphaCode on [db-au-cmdwh].dbo.penOutlet(AlphaCode,CountryKey,OutletStatus) include (CompanyKey,OutletAlphaKey,DomainKey,DomainID,OutletKey)    
        create nonclustered index idx_penOutlet_CountryKey on [db-au-cmdwh].dbo.penOutlet(CountryKey,OutletStatus) include (AlphaCode,SuperGroupName,GroupName,GroupCode,SubGroupName,SubGroupCode,OutletName,  
  ABN,ContactStreet,ContactSuburb,ContactState,ContactPostCode,PaymentType)    
        create nonclustered index idx_penOutlet_FCArea on [db-au-cmdwh].dbo.penOutlet(FCArea,CountryKey,OutletStatus)    
        create nonclustered index idx_penOutlet_AMIArea on [db-au-cmdwh].dbo.penOutlet(AMIArea,CountryKey,OutletStatus)    
        create nonclustered index idx_penOutlet_FCNation on [db-au-cmdwh].dbo.penOutlet(FCNation)    
        create nonclustered index idx_penOutlet_AMINation on [db-au-cmdwh].dbo.penOutlet(AMINation)    
        create nonclustered index idx_penOutlet_group on [db-au-cmdwh].dbo.penOutlet(CountryKey,SuperGroupName) include (GroupName)    
        create nonclustered index idx_penOutlet_GroupCode on [db-au-cmdwh].dbo.penOutlet(GroupCode)    
        create nonclustered index idx_penOutlet_OutletAlphaKey on [db-au-cmdwh].dbo.penOutlet(OutletAlphaKey,OutletStatus,CountryKey) include (OutletSKey,OutletKey,GroupCode,AlphaCode,SuperGroupName)    
        create nonclustered index idx_penOutlet_OutletHashKey on [db-au-cmdwh].dbo.penOutlet(OutletHashKey)    
        create nonclustered index idx_penOutlet_OutletSKey on [db-au-cmdwh].dbo.penOutlet(OutletSKey)    
        create nonclustered index idx_penOutlet_StateSalesArea on [db-au-cmdwh].dbo.penOutlet(StateSalesArea)    
        create nonclustered index idx_penOutlet_StatusValue on [db-au-cmdwh].dbo.penOutlet(StatusValue)    
        create nonclustered index idx_penOutlet_SubGroupCode on [db-au-cmdwh].dbo.penOutlet(SubGroupCode)    
        create nonclustered index idx_penOutlet_PreviousAlpha on [db-au-cmdwh].dbo.penOutlet(PreviousAlpha,CountryKey,CompanyKey) include(AlphaCode,OutletStatus)    
        create nonclustered index idx_penOutlet_LatestOutletKey on [db-au-cmdwh].dbo.penOutlet(LatestOutletKey) include(OutletKey,OutletStatus)    
    
    end    
    
    
     --get outlets that are new or had outlethashkey changed since last ETL run    
    if object_id('tempdb..#etl_outlet') is not null    
        drop table #etl_outlet    
    
    select    
        o.*    
    into #etl_outlet    
    from    
        etl_penOutlet o    
        left join [db-au-cmdwh].dbo.penOutlet r on    
            r.OutletAlphaKey = o.OutletAlphaKey and    
            r.OutletHashKey = o.OutletHashKey and    
            r.OutletStatus = 'Current'    
    where    
        r.OutletKey is null    
    
    
    --update Outlet to Not Current, and set the OutletEndDate to 2 days before ETL run date    
    update [db-au-cmdwh].dbo.penOutlet    
    set    
        OutletStatus = 'Not Current',    
        OutletEndDate = convert(varchar(10), dateadd(d, -2, getdate()), 120)    
    where    
        OutletKey in    
        (    
            select    
                OutletKey    
            from    
                #etl_outlet    
        ) and    
        OutletStatus = 'Current'    
    
    --insert new/modified outlets    
    insert into [db-au-cmdwh].dbo.penOutlet with (tablockx)    
    (    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        OutletKey,    
        OutletAlphaKey,    
        OutletStatus,    
        OutletStartDate,    
        OutletEndDate,    
        OutletHashKey,    
        DomainID,    
        OutletID,    
        GroupID,    
        SubGroupID,    
        OutletTypeID,    
        OutletName,    
        OutletType,    
        AlphaCode,    
        StatusValue,    
        TradingStatus,    
        CommencementDate,    
        CloseDate,    
        PreviousAlpha,    
        StatusRegionID,    
        StatusRegion,    
        ContactTitle,    
        ContactInitial,    
        ContactFirstName,    
        ContactLastName,    
        ContactManagerEmail,    
        ContactPhone,    
        ContactFax,    
        ContactEmail,    
        ContactStreet,    
        ContactSuburb,    
        ContactState,    
        ContactPostCode,    
        ContactPOBox,    
        ContactMailSuburb,    
        ContactMailState,    
        ContactMailPostCode,    
        GroupDomainID,    
        SuperGroupName,    
        GroupName,    
        GroupCode,    
        GroupStartDate,    
        GroupPhone,    
        GroupFax,    
        GroupEmail,    
        GroupStreet,    
        GroupSuburb,    
        GroupPostCode,    
        GroupMailSuburb,    
        GroupMailState,    
        GroupMailPostCode,    
        GroupPOBox,    
        SubGroupName,    
        SubGroupCode,    
   SubGroupStartDate,    
        SubGroupPhone,    
        SubGroupFax,    
        SubGroupEmail,    
        SubGroupStreet,    
        SubGroupSuburb,    
        SubGroupPostCode,    
        SubGroupMailSuburb,    
        SubGroupMailState,    
        SubGroupMailPostCode,    
        SubGroupPOBox,    
        AcctOfficerTitle,    
        AcctOfficerFirstName,    
        AcctOfficerLastName,    
        AcctOfficerEmail,    
        PaymentTypeID,    
        PaymentType,    
        AccountName,    
        BSB,    
        EncryptedAccountNumber,    
        AccountsEmail,    
        CCSaleOnly,    
        FSRTypeID,    
        FSRType,    
        FSGCategoryID,    
        FSGCategory,    
        LegalEntityName,    
        ASICNumber,    
        ABN,    
        ASICCheckDate,    
        AgreementDate,    
        BDMID,    
        BDMName,    
        BDMCallFreqID,    
        BDMCallFrequency,    
        AcctManagerID,    
        AcctManagerName,    
        AcctMgrCallFreqID,    
        AcctMgrCallFrequency,    
        AdminExecID,    
        AdminExecName,    
        ExtID,    
        ExtBDMID,    
        ExternalBDMName,    
        SalesSegment,    
        PotentialSales,    
        SalesTierID,    
        SalesTier,    
        Branch,    
        Website,    
        EGMNationID,    
        EGMNation,    
        FCNationID,    
        FCNation,    
        FCAreaID,    
        FCArea,    
        FCAreaCode,    
        STARegionID,    
        STARegion,    
        StateSalesAreaID,    
        StateSalesArea,    
        AgencyGrading,    
        Distributorkey,    
        Distributorid,    
        JVID,    
        JV,    
        JVCode,    
        ChannelID,    
        Channel,    
        AMIArea,    
        AMIAreaCode,    
        AMINation,    
        AMIEGMNation,    
  SugarCRMID    
    )    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        OutletKey,    
        OutletAlphaKey,    
        'Current' as OutletStatus,    
        convert(datetime,convert(varchar(10),dateadd(d,-1,getdate()),120)) as OutletStartDate,    
        null as OutletEndDate,    
        OutletHashKey,    
        DomainID,    
        OutletID,    
        GroupID,    
        SubGroupID,    
        OutletTypeID,    
        OutletName,    
        OutletType,    
        AlphaCode,    
        StatusValue,    
        TradingStatus,    
        CommencementDate,    
        CloseDate,    
        PreviousAlpha,    
        StatusRegionID,    
        StatusRegion,    
        ContactTitle,    
        ContactInitial,    
        ContactFirstName,    
        ContactLastName,    
        ContactManagerEmail,    
        ContactPhone,    
        ContactFax,    
        ContactEmail,    
        ContactStreet,    
        ContactSuburb,    
        ContactState,    
        ContactPostCode,    
        ContactPOBox,    
        ContactMailSuburb,    
        ContactMailState,    
        ContactMailPostCode,    
        GroupDomainID,    
        /* Super Group Definition */    
        convert(    
            varchar(25),    
            case    
                when CountryKey = 'AU' then    
                    case    
                        when GroupCode = 'FL' then 'Flight Centre'    
                        when GroupCode = 'CT' then 'TCIS'    
                        when GroupCode in ('AA','AE','IH','TW', 'HP', 'AI', 'NT', 'AV') then 'Independents'    
                        when GroupCode in ('TI','TT','HW','HF','HA','HL','HI','HT','JT', 'HC','MG') then 'Stella'    
                        when GroupCode = 'ST' then 'STA'    
                        when GroupCode in ('XA','XF','ZA') then 'Brokers'    
                        when GroupCode in ('CM','IU') then 'Direct'    
                        when GroupCode = 'AP' then 'Australia Post'    
                        when GroupCode in ('MB','AH') then 'Medibank'    
                        when GroupCode in ('RV','RC','RQ','RT','NR','AW','RA','AN', 'RG') then 'AAA'    
                        when GroupCode = 'MA' then 'Malaysia Airlines'    
                        when GroupCode = 'AZ' then 'Air NZ'    
                        when GroupCode in ('NI','SO','SE') then 'IAL'    
                        when GroupCode = 'PO' then 'P&O Cruises'    
                        when GroupCode = 'VA' then 'Virgin'    
                        when GroupCode = 'HH' then 'HIF'    
                        when GroupCode = 'TK' then 'Ticketek'    
      when GroupCode = 'CF' then 'Coles'    
      when GroupCode = 'CR' then 'Cruise Republic'    
      when GroupCode = 'HO' then 'Halo'    
      when GroupCode = 'YG' then 'YouGo'    
      when GroupCode = 'ZU' then 'Zurich'    
      when GroupCode = 'AR' then 'Affiliate Referrers'    
      when GroupCode = 'IN' then 'Internal'    
      when GroupCode = 'GC' then 'Gold Coast SUNS'    
      when GroupCode = 'CG' then 'Concorde Transonic'    
      when GroupCode = 'TX' then 'Travelex'    
      when GroupCode in ('CB','BW') then 'CBA Group'    
      when GroupCode = 'EA' then 'Easy Travel Insurance'    
                        when AlphaCode in ('NTA0001','NTA0002','NTA0003') then 'Independents'    
      WHEN Groupcode='WJ' THEN 'Webjet'    
                        else 'Other'    
                    end    
                when CountryKey = 'NZ' then    
                    case    
         when GroupCode = 'FL' then 'Flight Centre'    
                        when GroupCode in ('AT','GO','GH','HS','HW','UT','WA') then 'Stella'    
                        when GroupCode = 'ST' then 'STA'    
                        when GroupCode = 'MA' then 'Malaysia Airlines'    
                        when GroupCode = 'CI' then 'Christchurch Airport'    
                        when GroupCode = 'FA' then 'Flavour'    
                        when GroupCode = 'TM' then 'Travel Managers'    
                        when GroupCode IN ('AA', 'BK', 'CB', 'WT') or (GroupCode = 'TS' and AlphaCode not in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068','TSN0077')) then 'Cover-More Indies'    
                        when GroupCode = 'TS' and AlphaCode in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068','TSN0077') then 'Cover-More Directs'    
                        when GroupCode = 'AZ' then 'Air NZ'    
                        when GroupCode in ('AM','SA') then 'IAG NZ'    
                        when GroupCode = 'FM' then 'Farmers Mutual Group'    
                        when GroupCode = 'PO' then 'P&O Cruises'    
                        when GroupCode = 'VA' then 'Virgin'    
                        when GroupCode = 'WP' then 'Westpac NZ'    
                        when GroupCode = 'VL' then 'Mosaic'    
      when GroupCode = 'CR' then 'Cruise Republic'    
                        when GroupCode = 'TK' then 'Ticketek'    
      when GroupCode = 'AR' then 'Affiliate Referrers'    
      WHEN Groupcode='WJ' THEN 'Webjet'    
                        else 'Other'    
                    end    
                when CountryKey = 'UK' then    
                    case    
                        when GroupCode in ('FL') then 'Flight Centre'    
                        when GroupCode in ('AA', 'ST', 'TN') then 'Independents'    
                        when GroupCode in ('OT') then 'One Travel Insurance'    
                        when GroupCode = 'TB' then 'Travelbag'    
                        when GroupCode = 'MA' then 'Malaysia Airlines'    
                        when GroupCode = 'AT' then 'Advantage Travel'    
                        when GroupCode = 'RC' then 'Right Cover'    
                        when GroupCode = 'WT' then 'Worldchoice'    
                        when GroupCode = 'HW' then 'Harvey World'    
                        when GroupCode = 'AF' then 'Arsenal FC'    
                        when GroupCode = 'CM' then 'Direct Sales'    
                        when GroupCode = 'GL' then 'Global'    
                        when GroupCode = 'AZ' then 'Air NZ'    
      WHEN Groupcode='WJ' THEN 'Webjet'    
                        else 'Other'    
                    end    
                when CountryKey in ('MY','SG') then 'Malaysia Airlines'    
                when CountryKey = 'CN' then        
                    case    
                        when GroupCode = 'CM' then 'Direct'    
                        when GroupCode = 'PY' then 'Palm You'    
                        when GroupCode = 'QN' then 'Qunar'    
                        when GroupCode = 'SB' then 'SAIB'    
      WHEN Groupcode='WJ' THEN 'Webjet'    
                        else 'Other'    
                    end    
                when CountryKey = 'ID' and GroupCode = 'SN' then 'Simas Net'    
                when CountryKey = 'US' and GroupCode = 'FL' then 'Flight Center'    
    WHEN Groupcode='WJ' THEN 'Webjet'    
                else 'Other'    
            end    
        ) as SuperGroupName,    
        GroupName,    
        GroupCode,    
        GroupStartDate,    
        GroupPhone,    
        GroupFax,    
        GroupEmail,    
        GroupStreet,    
        GroupSuburb,    
        GroupPostCode,    
        GroupMailSuburb,    
        GroupMailState,    
        GroupMailPostCode,    
        GroupPOBox,    
        SubGroupName,    
        SubGroupCode,    
        SubGroupStartDate,    
        SubGroupPhone,    
        SubGroupFax,    
        SubGroupEmail,    
        SubGroupStreet,    
       SubGroupSuburb,    
        SubGroupPostCode,    
        SubGroupMailSuburb,    
        SubGroupMailState,    
        SubGroupMailPostCode,    
        SubGroupPOBox,    
        AcctOfficerTitle,    
        AcctOfficerFirstName,    
        AcctOfficerLastName,    
        AcctOfficerEmail,    
        PaymentTypeID,    
        PaymentType,    
        AccountName,    
        BSB,    
        AccountNumber,    
        AccountsEmail,    
        CCSaleOnly,    
        FSRTypeID,    
        FSRType,    
        FSGCategoryID,    
        FSGCategory,    
        LegalEntityName,    
        ASICNumber,    
        ABN,    
        ASICCheckDate,    
        AgreementDate,    
        BDMID,    
        BDMName,    
        BDMCallFreqID,    
        BDMCallFrequency,    
        AcctManagerID,    
        AcctManagerName,    
        AcctMgrCallFreqID,    
        AcctMgrCallFrequency,    
        AdminExecID,    
        AdminExecName,    
        ExtID,    
        ExtBDMID,    
        ExternalBDMName,    
        SalesSegment,    
        PotentialSales,    
        SalesTierID,    
        SalesTier,    
        Branch,    
        Website,    
        EGMNationID,    
        EGMNation,    
        FCNationID,    
        FCNation,    
        FCAreaID,    
        FCArea,    
        FCAreaCode,    
        STARegionID,    
        STARegion,    
        StateSalesAreaID,    
        StateSalesArea,    
        AgencyGrading,    
        Distributorkey,    
        Distributorid,    
        JVID,    
        JV,    
        JVCode,    
        ChannelID,    
        Channel,    
        AMIArea,    
        AMIAreaCode,    
        AMINation,    
        AMIEGMNation,    
  SugarCRMID    
    from    
        etl_penOutlet    
    where    
        OutletKey in    
        (    
            select    
                OutletKey    
            from    
                #etl_Outlet    
        )    
    
    --update all type 1 fields    
    update [db-au-cmdwh].dbo.penOutlet    
    set    
        SuperGroupName =    
            convert(    
                varchar(25),    
    case    
     when a.CountryKey = 'AU' then    
                        case    
                            when a.GroupCode = 'FL' then 'Flight Centre'    
                            when a.GroupCode = 'CT' then 'TCIS'    
                            when a.GroupCode in ('AA','AE','IH','TW', 'HP', 'AI', 'NT', 'AV') then 'Independents'    
                            when a.GroupCode in ('TI','TT','HW','HF','HA','HL','HI','HT','JT', 'HC','MG') then 'Stella'    
                            when a.GroupCode = 'ST' then 'STA'    
                            when a.GroupCode in ('XA','XF','ZA') then 'Brokers'    
                            when a.GroupCode in ('CM','IU') then 'Direct'    
                            when a.GroupCode = 'AP' then 'Australia Post'    
                            when a.GroupCode in ('MB','AH') then 'Medibank'    
                            when a.GroupCode in ('RV','RC','RQ','RT','NR','AW','RA','AN', 'RG') then 'AAA'    
                            when a.GroupCode = 'MA' then 'Malaysia Airlines'    
                            when a.GroupCode = 'AZ' then 'Air NZ'    
                            when a.GroupCode in ('NI','SO','SE') then 'IAL'    
                            when a.GroupCode = 'PO' then 'P&O Cruises'    
      when a.GroupCode = 'VA' then 'Virgin'    
                            when a.GroupCode = 'HH' then 'HIF'    
                            when a.GroupCode = 'TK' then 'Ticketek'    
                            when a.GroupCode = 'CF' then 'Coles'    
                            when a.GroupCode = 'CR' then 'Cruise Republic'    
                            when a.GroupCode = 'HO' then 'Halo'    
                            when a.GroupCode = 'YG' then 'YouGo'    
                            when a.GroupCode = 'ZU' then 'Zurich'    
                            when a.GroupCode = 'AR' then 'Affiliate Referrers'    
                            when a.GroupCode = 'IN' then 'Internal'    
  when a.GroupCode = 'GC' then 'Gold Coast SUNS'    
                            when a.GroupCode = 'CG' then 'Concorde Transonic'    
       when a.GroupCode = 'TX' then 'Travelex'    
       when a.GroupCode in ('CB','BW') then 'CBA Group'    
       when a.GroupCode = 'EA' then 'Easy Travel Insurance'    
       when a.AlphaCode in ('NTA0001','NTA0002','NTA0003') then 'Independents'    
       WHEN a.Groupcode='WJ' THEN 'Webjet'    
                            else 'Other'    
                        end    
                    when a.CountryKey = 'NZ' then    
                        case    
                            when a.GroupCode = 'FL' then 'Flight Centre'    
                            when a.GroupCode in ('AT','GO','GH','HS','HW','UT','WA') then 'Stella'    
                            when a.GroupCode = 'ST' then 'STA'    
                            when a.GroupCode = 'MA' then 'Malaysia Airlines'    
                            when a.GroupCode = 'CI' then 'Christchurch Airport'    
                            when a.GroupCode = 'FA' then 'Flavour'    
                            when a.GroupCode = 'TM' then 'Travel Managers'    
                            when a.GroupCode IN ('AA', 'BK', 'CB', 'WT') or (a.GroupCode = 'TS' and a.AlphaCode not in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068','TSN0077')) then 'Cover-More Indies'    
                            when a.GroupCode = 'TS' and a.AlphaCode in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068','TSN0077') then 'Cover-More Directs'    
                            when a.GroupCode = 'AZ' then 'Air NZ'    
                            when a.GroupCode in ('AM','SA') then 'IAG NZ'    
                            when a.GroupCode = 'FM' then 'Farmers Mutual Group'    
                            when a.GroupCode = 'PO' then 'P&O Cruises'    
                            when a.GroupCode = 'VA' then 'Virgin'    
                            when a.GroupCode = 'WP' then 'Westpac NZ'    
                            when a.GroupCode = 'VL' then 'Mosaic'    
                            when a.GroupCode = 'CR' then 'Cruise Republic'    
                            when a.GroupCode = 'TK' then 'Ticketek'    
                            when a.GroupCode = 'AR' then 'Affiliate Referrers'    
       WHEN a.Groupcode='WJ' THEN 'Webjet'    
                            else 'Other'    
                        end    
                    when a.CountryKey = 'UK' then    
                        case    
                            when a.GroupCode in ('FL') then 'Flight Centre'    
                            when a.GroupCode in ('AA', 'ST', 'TN') then 'Independents'    
                            when a.GroupCode in ('OT') then 'One Travel Insurance'    
                            when a.GroupCode = 'TB' then 'Travelbag'    
                            when a.GroupCode = 'MA' then 'Malaysia Airlines'    
                            when a.GroupCode = 'AT' then 'Advantage Travel'    
                            when a.GroupCode = 'RC' then 'Right Cover'    
                            when a.GroupCode = 'WT' then 'Worldchoice'    
                            when a.GroupCode = 'HW' then 'Harvey World'    
                            when a.GroupCode = 'AF' then 'Arsenal FC'    
                            when a.GroupCode = 'CM' then 'Direct Sales'    
                            when a.GroupCode = 'GL' then 'Global'    
                            when a.GroupCode = 'AZ' then 'Air NZ'    
       WHEN a.Groupcode='WJ' THEN 'Webjet'    
                            else 'Other'    
                        end    
                    when a.CountryKey in ('MY','SG') then 'Malaysia Airlines'    
                    when a.CountryKey = 'CN' then        
                        case    
                            when a.GroupCode = 'CM' then 'Direct'    
                            when a.GroupCode = 'PY' then 'Palm You'    
                            when a.GroupCode = 'QN' then 'Qunar'    
                            when a.GroupCode = 'SB' then 'SAIB'    
       WHEN a.Groupcode='WJ' THEN 'Webjet'    
                            else 'Other'    
                        end    
                    when a.CountryKey = 'ID' and a.GroupCode = 'SN' then 'Simas Net'    
                    when a.CountryKey = 'US' and a.GroupCode = 'FL' then 'Flight Center'    
     WHEN a.Groupcode='WJ' THEN 'Webjet'    
                    else 'Other'    
                end    
            ),    
            ABN = a.ABN,    
            AccountName = a.AccountName,    
            AccountNumber = a.AccountNumber,    
            AccountsEmail = a.AccountsEmail,    
            AcctMgrCallFreqID = a.AcctMgrCallFreqID,    
            AcctMgrCallFrequency = a.AcctMgrCallFrequency,    
            AcctOfficerEmail = a.AcctOfficerEmail,    
            AcctOfficerFirstName = a.AcctOfficerFirstName,    
            AcctOfficerLastName = a.AcctOfficerLastName,    
            AcctOfficerTitle = a.AcctOfficerTitle,    
            AdminExecID = a.AdminExecID,    
            AdminExecName = a.AdminExecName,    
            AgreementDate = a.AgreementDate,    
            AlphaCode = a.AlphaCode,    
            ASICCheckDate = a.ASICCheckDate,    
            ASICNumber = a.ASICNumber,    
            BDMCallFreqID = a.BDMCallFreqID,    
            BDMCallFrequency = a.BDMCallFrequency,    
            Branch = a.Branch,    
            BSB = a.BSB,    
            CCSaleOnly = a.CCSaleOnly,    
            CloseDate = a.CloseDate,    
            CommencementDate = a.CommencementDate,    
            CompanyKey = a.CompanyKey,    
            ContactEmail = a.ContactEmail,    
            ContactFax = a.ContactFax,    
            ContactFirstName = a.ContactFirstName,    
            ContactInitial = a.ContactInitial,    
            ContactLastName = a.ContactLastName,    
            ContactMailPostCode = a.ContactMailPostCode,    
            ContactMailState = a.ContactMailState,    
            ContactMailSuburb = a.ContactMailSuburb,    
            ContactManagerEmail = a.ContactManagerEmail,    
            ContactPhone = a.ContactPhone,    
            ContactPOBox = a.ContactPOBox,    
            ContactPostCode = a.ContactPostCode,    
            ContactState = a.ContactState,    
            ContactStreet = a.ContactStreet,    
            ContactSuburb = a.ContactSuburb,    
            ContactTitle = a.ContactTitle,    
            CountryKey = a.CountryKey,    
            DomainID = a.DomainID,    
            DomainKey = a.DomainKey,    
            EncryptedAccountNumber = a.AccountNumber,    
            FSGCategory = a.FSGCategory,    
            FSGCategoryID = a.FSGCategoryID,    
            FSRType = a.FSRType,    
            FSRTypeID = a.FSRTypeID,    
            GroupCode = a.GroupCode,    
            GroupDomainID = a.GroupDomainID,    
            GroupEmail = a.GroupEmail,    
            GroupFax = a.GroupFax,    
            GroupMailPostCode = a.GroupMailPostCode,    
            GroupMailState = a.GroupMailState,    
            GroupMailSuburb = a.GroupMailSuburb,    
            GroupPhone = a.GroupPhone,    
            GroupPOBox = a.GroupPOBox,    
            GroupPostCode = a.GroupPostCode,    
            GroupStartDate = a.GroupStartDate,    
            GroupStreet = a.GroupStreet,    
            GroupSuburb = a.GroupSuburb,    
            LegalEntityName = a.LegalEntityName,    
            OutletID = a.OutletID,    
            OutletName = a.OutletName,    
            PaymentType = a.PaymentType,    
            PaymentTypeID = a.PaymentTypeID,    
            PotentialSales = a.PotentialSales,    
            SalesSegment = a.SalesSegment,    
            SalesTier = a.SalesTier,    
            SalesTierID = a.SalesTierID,    
            STARegion = a.STARegion,    
            STARegionID = a.STARegionID,    
            StatusRegion = a.StatusRegion,    
            StatusRegionID = a.StatusRegionID,    
            StatusValue = a.StatusValue,    
            SubGroupCode = a.SubGroupCode,    
            SubGroupEmail = a.SubGroupEmail,    
            SubGroupFax = a.SubGroupFax,    
            SubGroupMailPostCode = a.SubGroupMailPostCode,    
            SubGroupMailState = a.SubGroupMailState,    
            SubGroupMailSuburb = a.SubGroupMailSuburb,    
            SubGroupPhone = a.SubGroupPhone,    
            SubGroupPOBox = a.SubGroupPOBox,    
            SubGroupPostCode = a.SubGroupPostCode,    
            SubGroupStartDate = a.SubGroupStartDate,    
            SubGroupStreet = a.SubGroupStreet,    
            SubGroupSuburb = a.SubGroupSuburb,    
            TradingStatus = a.TradingStatus,    
            Website = a.Website,    
            AgencyGrading = a.AgencyGrading,    
            JVID = a.JVID,    
            JV = a.JV,    
            JVCode = a.JVCode,    
            ChannelID = a.ChannelID,    
            Channel = a.Channel,    
   SugarCRMID = a.SugarCRMID    
    from    
        [db-au-cmdwh].dbo.penOutlet b    
        inner join etl_penOutlet a on    
            b.OutletKey = a.OutletKey    
    
    
    /* get recode chains */    
    if object_id('tempdb..#newcode') is not null    
        drop table #newcode    
    
    ;with cte_newcode as    
    (    
        select    
            o.CountryKey,    
            o.CompanyKey,    
            o.OutletKey,    
            o.AlphaCode,    
            --STARSuper,    
            n.OutletKey NewOutletKey,    
            n.AlphaCode NewAlphaCode,    
            1 Depth    
        from    
            [db-au-cmdwh].dbo.penOutlet o    
            inner join [db-au-cmdwh].dbo.penOutlet n on    
                n.CountryKey = o.CountryKey and    
                n.CompanyKey = o.CompanyKey and    
                n.PreviousAlpha = o.AlphaCode and    
                n.OutletStatus = 'Current'    
        where    
            o.OutletStatus = 'Current' and    
            /* exclude TRIPS migrated alphas */    
            o.OutletID <> 0 and    
            n.OutletID <> 0    
    
        union all    
    
        select    
            o.CountryKey,    
            o.CompanyKey,    
            o.OutletKey,    
            o.AlphaCode,    
            --o.STARSuper,    
            n.OutletKey NewOutletKey,    
            n.AlphaCode NewAlphaCode,    
            o.Depth + 1 Depth    
        from    
            cte_newcode o    
            inner join [db-au-cmdwh].dbo.penOutlet n on    
                n.CountryKey = o.CountryKey and    
                n.CompanyKey = o.CompanyKey and    
                n.PreviousAlpha = o.NewAlphaCode and    
                n.AlphaCode <> o.AlphaCode and    
                n.OutletStatus = 'Current' and    
                n.OutletID <> 0    
    )    
    select *    
    into #newcode    
    from    
        cte_newcode    
    
    create clustered index idx on #newcode(OutletKey, Depth desc)    
    
    /* update outlet with latest key */    
    update o    
    set    
        o.LatestOutletKey = isnull(lo.NewOutletKey, o.OutletKey)    
    from    
        [db-au-cmdwh].dbo.penOutlet o    
        cross apply    
        (    
            select    
                count(roc.OutletKey) ReplacementCount    
            from    
                [db-au-cmdwh].dbo.penOutlet roc    
            where    
                roc.CountryKey = o.CountryKey and    
                roc.CompanyKey = o.CompanyKey and    
                roc.PreviousAlpha = o.AlphaCode and    
                roc.OutletStatus = 'Current'    
        ) roc    
        outer apply    
        (    
            select top 1    
                NewOutletKey    
            from    
                #newcode lo    
            where    
                roc.ReplacementCount <= 1 and /* assumption, if there are multiple replacement then alpha stay as is */    
                lo.OutletKey = o.OutletKey    
            order by    
                Depth desc    
        ) lo    
    where    
        o.OutletID <> 0    
    
    
    /* store lineage */    
    if object_id('[db-au-cmdwh].dbo.penOutletLineage') is null    
    begin    
            create table [db-au-cmdwh].dbo.[penOutletLineage]    
        (    
            [OutletKey] varchar(33) not null,    
            [Lineage] nvarchar(max) null    
        )    
    
        create nonclustered index idx_penOutlet_OutletKey on [db-au-cmdwh].dbo.penOutletLineage(OutletKey) include (Lineage)    
    
    end    
    
    truncate table [db-au-cmdwh].dbo.[penOutletLineage]    
    
    insert into [db-au-cmdwh].dbo.[penOutletLineage] with(tablockx)    
    (    
        OutletKey,    
        Lineage    
    )    
    select    
        o.OutletKey,    
        o.AlphaCode +    
        isnull(    
            ' - ' +    
            (    
                select    
                    lo.NewAlphaCode +    
                    case    
                        when Depth = max(Depth) over (partition by lo.OutletKey) then ''    
                        else ' - '    
                    end    
                from    
                    #newcode lo    
                where    
                    roc.ReplacementCount <= 1 and /* assumption, if there are multiple replacement then alpha stay as is */    
                    lo.OutletKey = o.OutletKey    
                order by    
                    Depth    
                for xml path('')    
            ),    
            ''    
        ) Lineage    
    from    
        [db-au-cmdwh].dbo.penOutlet o    
        cross apply    
        (    
            select    
                count(roc.OutletKey) ReplacementCount    
            from    
                [db-au-cmdwh].dbo.penOutlet roc    
            where    
                roc.CountryKey = o.CountryKey and    
                roc.CompanyKey = o.CompanyKey and    
                roc.PreviousAlpha = o.AlphaCode and    
                roc.OutletStatus = 'Current'    
        ) roc    
    where    
        o.OutletID <> 0 and    
        o.OutletStatus = 'Current'    
    
    drop table #etl_Outlet    
    
end 


GO
