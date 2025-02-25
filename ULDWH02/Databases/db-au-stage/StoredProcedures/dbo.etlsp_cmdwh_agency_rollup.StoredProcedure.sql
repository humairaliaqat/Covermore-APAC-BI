USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_agency_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_cmdwh_agency_rollup]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:
Prerequisite:
Description:
Change History:
                20130129 - LS - case 18180, NZ: use the same TRIPS schema as AU
                20130312 - LT - excluded Right Cover alphas from AU
                20130412 - LT - amended NZ SuperGroup definition
                20130918 - LT - Changed AU FLNation reference backt o FCCountrys table
                20131205 - LS - case 19805, new supergroup; Air NZ 
                20140102 - LS - add Helloworld to Stella (Ben's email)
				20140102 - LT - added IAL to AgencySuperGroupName
				20150128 - LT - added IAG NZ and Farmers Mutual Group super group
				20150421 - LT - changed ASICNumber to varchar(50) in Agency table definition
				20150706 - LT - added Simas Net as supergroup where GroupCode = SN
				20150917 - LT - added P&O Cruises as supergroup where GroupCode = PO
*************************************************************************************************************************************/

    set nocount on

    /* ETL logic
    --1. combine CLREG from AU, NZ, & UK
    --2. find agency that are new or had modification(s) to the key Agency attributes
    --3. set old agency to 'Not Current', and set the AgencyEndDate to ETL date
    --4. insert new/modified agency records into [db-au-cmdwh].dbo.Agency table
    */


    --1. Combine CLREG records from AU, NZ, and UK
    if object_id('[db-au-stage].dbo.etl_agency') is not null drop table [db-au-stage].dbo.etl_agency
    select
      convert(varchar(500),null) as AgencyHashKey,
      'AU' as CountryKey,
      'AU-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
      convert(varchar(25),case when c.CLGROUP = 'FL' then 'Flight Centre'
           when c.CLGROUP = 'CT' then 'TCIS'
           when c.CLGROUP in ('AA','AH','AE','IH','TW') then 'Independents'
           when c.CLGROUP in ('TI','TT','HW','HF','HA') then 'Stella'
           when c.CLGROUP = 'ST' then 'STA'
           when c.CLGROUP in ('XA','XF','ZA') then 'Brokers'
           when c.CLGROUP in ('CM','IU') then 'Direct'
           when c.CLGROUP = 'AP' then 'Australia Post'
           when c.CLGROUP = 'MB' then 'Medibank'
           when c.CLGROUP in ('RV','RC','RQ','RT','NR','AW','RA','AN') then 'AAA'
           when c.CLGROUP = 'MA' then 'Malaysia Airlines'
           when c.CLGROUP = 'AZ' then 'Air NZ'
           when c.CLGROUP in ('NI','SO','SE') then 'IAL'
		   when c.CLGROUP = 'SN' then 'Simas Net'
		   when c.CLGROUP = 'PO' then 'P&O Cruises'
           else 'Other'
      end) as AgencySuperGroupName,
      c.CLGROUP as AgencyGroupCode,
      (select top 1 left(Descript,25) from [db-au-stage].dbo.trips_agencygroup_au where Code = c.CLGROUP) as AgencyGroupName,
      c.AgencySubGroup as AgencySubGroupCode,
      (select top 1 left(Description,50) from [db-au-stage].dbo.trips_agencysubgroup_au t where t.CLGROUP = c.CLGROUP and SUBGRCODE = c.AgencySubGroup) as AgencySubGroupName,
      c.CLALPHA as AgencyCode,
      left(c.CLCONAM,50) as AgencyName,
      left(c.CLBRAN,60) as Branch,
      c.FCCountry as FLCountryCode,
      (select top 1 left(CDescript, 30) from [db-au-stage].dbo.trips_fccountry_au where CID = c.FCCountry and c.CLGROUP = 'FL' and InUse = 1) as FLCountryName,
      (select top 1 NationID from [db-au-stage].dbo.trips_fccountry_au where CID = c.FCCountry and c.CLGROUP = 'FL' and InUse = 1) as FLNationCode,

    /*
    -- 2011-09-22, LS, rely on tblnation for nation name. Penguin push caused fccountry nation populated with id instead of name. AU specific.
      (select top 1 Nation from [db-au-stage].dbo.trips_fccountry_au where CID = c.FCCountry and c.CLGROUP = 'FL' and InUse = 1) as FLNationName,
    */
    /*
      convert(varchar(20), (
        select top 1 n.Nation_Name
        from [db-au-stage].dbo.trips_fccountry_au fc
          inner join [db-au-stage].dbo.trips_nation_au n on n.Nationid = fc.Nationid
        where fc.CID = c.FCCountry and c.CLGROUP = 'FL' and fc.InUse = 1
      )) as FLNationName,
	*/
	/* 20130918 - LT - Changed FLNation back to reading from FCCountrys table */
	  convert(varchar(20),(select top 1 Nation from [db-au-stage].dbo.trips_fccountry_au where CID = c.FCCountry and c.CLGROUP = 'FL' and Inuse = 1)) as FLNationName,
      left(c.CLPHONE,12) as Phone,
      left(c.CLFAX,12) as Fax,
      (select top 1 left(Descript,20) from [db-au-stage].dbo.trips_state_au where Code = c.CLGRSTATE) as AgencyGroupState,
      left(c.CLCUSTSERV,3) as CustomerServiceInitial,
      left(c.CLCON1,4) as ContactTitle,
      left(c.CLCON4,25) as ContactFirstName,
      left(c.CLCON2,4) as ContactMiddleInitial,
      left(c.CLCON3,25) as ContactLastName,
      left(c.EMAIL,60) as ContactEmail,
      left(c.CLCOMM,100) as AgencyComment,
      left(c.CLPROS,2) as AgencyStatusCode,
      (select top 1 left([Description],50) from [db-au-stage].dbo.trips_codesclpros_au where Code = c.CLPROS) as AgencyStatusName,
      convert(varchar,c.CLSCODE) as BDMCode,
      (select top 1 left(ExecName,20) from [db-au-stage].dbo.trips_bdm_au where Code = c.CLSCODE) as BDMName,
      c.CLACCOUNTMGRID as AccountMgrCode,
      (select top 1 left(FullName,100) from [db-au-stage].dbo.trips_accountmgr_au where AccountMgrId = c.CLACCOUNTMGRID) as AccountMgrName,
      c.CMAA as AgreementDate,
      c.TSSAA as DateASICChecked,
      left(c.FSRTYPE,4) as FSRType,
      c.ASIC_NUMBER as ASICNumber,
      left(c.LEGALENTITY,100) as LegalEntity,
      left(c.CLABN,24) as ABN,
      c.CCCOMMPAYTYPEID as CommissionPayTypeID,
      c.FSGMINCOMMISSION as FSGMinimumCommission,
      c.FSGMAXCOMMISSION as FSGMaxCommission,
      c.CLDMOD as LastModifiedDate,
      left(c.CLMODBY,2) as ModifiedByInitial,
      left(c.CLADD1,75) as AddressStreet,
      left(c.CLADD2,25) as AddressSuburb,
      left(c.CLADD3,3) as AddressState,
      convert(varchar,c.CLPOST) as AddressPostCode,
      c.CLCLOSEDATE as AgencyClosedDate,
      left(c.CLPREVALPHA,7) as AgencyPreviousAlpha,
      left(c.CLCALLFREQ,3) as CallFrequency,
      left(convert(varchar,c.SalesSegment),50) as SalesSegment,
      c.PotentialSales,
      left(c.AMCALLFREQ,3) as AccountMgrCallFrequency,
      left(c.SalesTier,50) as SalesTier,
      c.CConly,
      (select top 1 RgnDesc from [db-au-stage].dbo.trips_tblSTARegions_au where RgnID = c.STARegionID and InUse = 1) as STARegion,
      (select top 1 BDMName from [db-au-stage].dbo.trips_bdmexternal_au where BDMId = c.ExternalBDMId and InUseFlag = 1) as ExternalBDMName,
      c.ExternalID ExternalAgencyCode
    into [db-au-stage].dbo.etl_agency
    from
      [db-au-stage].dbo.trips_clreg_au c
    where c.CLALPHA not in ('RCN0000','RCN0001','RCN0002')	--excludes Right Cover test alphas. Right Cover SHOULDNT BE IN AU TRIPS IN THE FIRST PLACE!!!!

    union all

    select
      convert(varchar(500),null) as AgencyHashKey,
      'NZ' as CountryKey,
      'NZ-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
      convert(varchar(25),case when c.CLGROUP = 'FL' then 'Flight Centre'
		 when c.CLGROUP in ('AT','GO','GH','HS','HW','UT','WA') then 'Stella'
		 when c.CLGROUP = 'ST' then 'STA'
		 when c.CLGROUP = 'MA' then 'Malaysia Airlines'
		 when c.CLGROUP = 'CI' then 'Christchurch Airport'
		 when c.CLGROUP = 'FA' then 'Flavour'
		 when c.CLGROUP = 'TM' then 'Travel Managers'
		 when c.CLGROUP = 'AA' or (c.CLGROUP = 'TS' and c.CLALPHA not in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068')) then 'Cover-More Indies'
		 when c.CLGROUP = 'TS' and c.CLALPHA in ('TSZ0000','TSZ0033','TSZ0083','TSZ0068') then 'Cover-More Directs'
         when c.CLGROUP = 'AZ' then 'Air NZ'
         when c.CLGROUP in ('AM','SA') then 'IAG NZ'
         when c.CLGROUP = 'FM' then 'Farmers Mutual Group'
		 when c.CLGROUP = 'PO' then 'P&O Cruises'
		 else 'Other'
	  end) as AgencySuperGroupName,
      c.CLGROUP as AgencyGroupCode,
      (select top 1 left(Descript,25) from [db-au-stage].dbo.trips_agencygroup_nz where Code = c.CLGROUP) as AgencyGroupName,
      c.AgencySubGroup as AgencySubGroupCode,
      (select top 1 left(Description,50) from [db-au-stage].dbo.trips_agencysubgroup_nz t where t.CLGROUP = c.CLGROUP and SUBGRCODE = c.AgencySubGroup) as AgencySubGroupName,
      c.CLALPHA as AgencyCode,
      left(c.CLCONAM,50) as AgencyName,
      left(c.CLBRAN,60) as Branch,
      c.FCCountry as FLCountryCode,
      (select top 1 left(CDescript, 30) from [db-au-stage].dbo.trips_fccountry_nz where CID = c.FCCountry and c.CLGROUP = 'FL' and InUse = 1) as FLCountryName,
      (select top 1 NationID from [db-au-stage].dbo.trips_fccountry_nz where CID = c.FCCountry and c.CLGROUP = 'FL' and InUse = 1) as FLNationCode,
      convert(varchar(20), (
        select top 1 n.Nation_Name
        from [db-au-stage].dbo.trips_fccountry_nz fc
          inner join [db-au-stage].dbo.trips_nation_nz n on n.Nationid = fc.Nationid
        where fc.CID = c.FCCountry and c.CLGROUP = 'FL' and fc.InUse = 1
      )) as FLNationName,
      left(c.CLPHONE,12) as Phone,
      left(c.CLFAX,12) as Fax,
      'NZ' as AgencyGroupState,
      left(c.CLCUSTSERV,3) as CustomerServiceInitial,
      left(c.CLCON1,4) as ContactTitle,
      left(c.CLCON4,25) as ContactFirstName,
      left(c.CLCON2,4) as ContactMiddleInitial,
      left(c.CLCON3,25) as ContactLastName,
      left(c.EMAIL,60) as ContactEmail,
      left(c.CLCOMM,100) as AgencyComment,
      left(c.CLPROS,2) as AgencyStatusCode,
      (select top 1 left([Description],50) from [db-au-stage].dbo.trips_codesclpros_nz where Code = c.CLPROS) as AgencyStatusName,
      convert(varchar,c.CLSCODE) as BDMCode,
      (select top 1 left(ExecName,20) from [db-au-stage].dbo.trips_bdm_nz where Code = c.CLSCODE) as BDMName,
      c.CLACCOUNTMGRID as AccountMgrCode,
      (select top 1 left(FullName,100) from [db-au-stage].dbo.trips_accountmgr_nz where AccountMgrId = c.CLACCOUNTMGRID) as AccountMgrName,
      c.CMAA as AgreementDate,
      c.TSSAA as DateASICChecked,
      left(c.FSRTYPE,4) as FSRType,
      c.ASIC_NUMBER as ASICNumber,
      left(c.LEGALENTITY,100) as LegalEntity,
      left(c.CLABN,24) as ABN,
      c.CCCOMMPAYTYPEID as CommissionPayTypeID,
      c.FSGMINCOMMISSION as FSGMinimumCommission,
      c.FSGMAXCOMMISSION as FSGMaxCommission,
      c.CLDMOD as LastModifiedDate,
      left(c.CLMODBY,2) as ModifiedByInitial,
      left(c.CLADD1,75) as AddressStreet,
      left(c.CLADD2,25) as AddressSuburb,
      left(c.CLADD3,3) as AddressState,
      convert(varchar,c.CLPOST) as AddressPostCode,
      c.CLCLOSEDATE as AgencyClosedDate,
      left(c.CLPREVALPHA,7) as AgencyPreviousAlpha,
      left(c.CLCALLFREQ,3) as CallFrequency,
      left(convert(varchar,c.SalesSegment),50) as SalesSegment,
      c.PotentialSales,
      left(c.AMCALLFREQ,3) as AccountMgrCallFrequency,
      left(c.SalesTier,50) as SalesTier,
      c.CConly,
      null as STARegion,
      (select top 1 BDMName from [db-au-stage].dbo.trips_bdmexternal_nz where BDMId = c.ExternalBDMId and InUseFlag = 1) as ExternalBDMName,
      c.ExternalID ExternalAgencyCode
    from
      [db-au-stage].dbo.trips_clreg_nz c


    union all


    select
      convert(varchar(500),null) as AgencyHashKey,
      'UK' as CountryKey,
      'UK-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
      convert(varchar(25),case when c.CLGROUP in ('FL') then 'Flight Centre'
           when c.CLGROUP in ('AA') then 'Independents'
           when c.CLGROUP in ('OT') then 'One Travel Insurance'
           when c.CLGROUP = 'TB' then 'Travelbag'
           when c.CLGROUP = 'MA' then 'Malaysia Airlines'
           when c.CLGROUP = 'AT' then 'Advantage Travel'
           when c.CLGROUP = 'RC' then 'Right Cover'
           when c.CLGROUP = 'WT' then 'Worldchoice'
           when c.CLGROUP = 'HW' then 'Harvey World'
           when c.CLGROUP = 'AF' then 'Arnold Fisher'
           when c.CLGROUP = 'CM' then 'Direct Sales'
           when c.CLGROUP = 'GL' then 'Global'
           when c.CLGROUP = 'AZ' then 'Air NZ'
           else 'Other'
      end) as AgencySuperGroupName,
      c.CLGROUP as AgencyGroupCode,
      (select top 1 left(Descript,25) from [db-au-stage].dbo.trips_agencygroup_uk where Code = c.CLGROUP) as AgencyGroupName,
      c.AgencySubGroup as AgencySubGroupCode,
      (select top 1 left(Description,50) from [db-au-stage].dbo.trips_agencysubgroup_uk t where t.CLGROUP = c.CLGROUP and SUBGRCODE = c.AgencySubGroup) as AgencySubGroupName,
      c.CLALPHA as AgencyCode,
      left(c.CLCONAM,50) as AgencyName,
      left(c.CLBRAN,60) as Branch,
      c.FCCountry as FLCountryCode,
      (select top 1 left(CDescript, 30) from [db-au-stage].dbo.trips_fccountry_uk where CID = c.FCCountry and c.CLGROUP = 'FL') as FLCountryName,
      null as FLNationCode,
      null as FLNationName,
      left(c.CLPHONE,12) as Phone,
      left(c.CLFAX,12) as Fax,
      'UK' as AgencyGroupState,
      left(c.CLCUSTSERV,3) as CustomerServiceInitial,
      left(c.CLCON1,4) as ContactTitle,
      left(c.CLCON4,25) as ContactFirstName,
      left(c.CLCON2,4) as ContactMiddleInitial,
      left(c.CLCON3,25) as ContactLastName,
      left(c.EMAIL,60) as ContactEmail,
      left(c.CLCOMM,100) as AgencyComment,
      left(c.CLPROS,2) as AgencyStatusCode,
      (select top 1 left([Description],50) from [db-au-stage].dbo.trips_codesclpros_uk where Code = c.CLPROS) as AgencyStatusName,
      convert(varchar,c.CLSCODE) as BDMCode,
      (select top 1 left(ExecName,20) from [db-au-stage].dbo.trips_bdm_uk where Code = c.CLSCODE) as BDMName,
      null as AccountMgrCode,
      null as AccountMgrName,
      c.CMAA as AgreementDate,
      null as DateASICChecked,
      left(c.FSRTYPE,4) as FSRType,
      c.ASIC_NUMBER as ASICNumber,
      left(c.LEGALENTITY,100) as LegalEntity,
      left(c.CLABN,24) as ABN,
      c.CCCOMMPAYTYPEID as CommissionPayTypeID,
      null as FSGMinimumCommission,
      null as FSGMaxCommission,
      c.CLDMOD as LastModifiedDate,
      left(c.CLMODBY,2) as ModifiedByInitial,
      left(c.CLADD1,75) as AddressStreet,
      left(c.CLADD2,25) as AddressSuburb,
      left(c.CLADD3,3) as AddressState,
      convert(varchar,c.CLPOST) as AddressPostCode,
      c.CLCLOSEDATE as AgencyClosedDate,
      left(c.CLPREVALPHA,7) as AgencyPreviousAlpha,
      left(c.CLCALLFREQ,3) as CallFrequency,
      null as SalesSegment,
      null as PotentialSales,
      null as AccountMgrCallFrequency,
      null as SalesTier,
      null as CConly,
      null as STARegion,
      null ExternalBDMName,
      null ExternalAgencyCode
    from
      [db-au-stage].dbo.trips_clreg_uk c

    union all

    select
      convert(varchar(500),null) as AgencyHashKey,
      'MY' as CountryKey,
      'MY-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
      case when c.CLGROUP = 'MA' then 'Malaysia Airlines'
           else null
      end as AgencySuperGroupName,
      c.CLGROUP as AgencyGroupCode,
      (select top 1 left(Descript,25) from [db-au-stage].dbo.trips_agencygroup_my where Code = c.CLGROUP) as AgencyGroupName,
      c.AgencySubGroup as AgencySubGroupCode,
      (select top 1 left(Description,50) from [db-au-stage].dbo.trips_agencysubgroup_my t where t.CLGROUP = c.CLGROUP and SUBGRCODE = c.AgencySubGroup) as AgencySubGroupName,
      c.CLALPHA as AgencyCode,
      left(c.CLCONAM,50) as AgencyName,
      left(c.CLBRAN,60) as Branch,
      c.FCCountry as FLCountryCode,
      null FLCountryName,
      null FLNationCode,
      null  as FLNationName,
      left(c.CLPHONE,12) as Phone,
      left(c.CLFAX,12) as Fax,
      (select top 1 left(Descript,20) from [db-au-stage].dbo.trips_state_my where Code = c.CLGRSTATE) as AgencyGroupState,
      left(c.CLCUSTSERV,3) as CustomerServiceInitial,
      left(c.CLCON1,4) as ContactTitle,
      left(c.CLCON4,25) as ContactFirstName,
      left(c.CLCON2,4) as ContactMiddleInitial,
      left(c.CLCON3,25) as ContactLastName,
      left(c.EMAIL,60) as ContactEmail,
      left(c.CLCOMM,100) as AgencyComment,
      left(c.CLPROS,2) as AgencyStatusCode,
      (select top 1 left([Description],50) from [db-au-stage].dbo.trips_codesclpros_my where Code = c.CLPROS) as AgencyStatusName,
      convert(varchar,c.CLSCODE) as BDMCode,
      (select top 1 left(ExecName,20) from [db-au-stage].dbo.trips_bdm_my where Code = c.CLSCODE) as BDMName,
      c.CLACCOUNTMGRID as AccountMgrCode,
      (select top 1 left(FullName,100) from [db-au-stage].dbo.trips_accountmgr_my where AccountMgrId = c.CLACCOUNTMGRID) as AccountMgrName,
      c.CMAA as AgreementDate,
      c.TSSAA as DateASICChecked,
      left(c.FSRTYPE,4) as FSRType,
      c.ASIC_NUMBER as ASICNumber,
      left(c.LEGALENTITY,100) as LegalEntity,
      left(c.CLABN,24) as ABN,
      c.CCCOMMPAYTYPEID as CommissionPayTypeID,
      c.FSGMINCOMMISSION as FSGMinimumCommission,
      c.FSGMAXCOMMISSION as FSGMaxCommission,
      c.CLDMOD as LastModifiedDate,
      left(c.CLMODBY,2) as ModifiedByInitial,
      left(c.CLADD1,75) as AddressStreet,
      left(c.CLADD2,25) as AddressSuburb,
      left(c.CLADD3,3) as AddressState,
      convert(varchar,c.CLPOST) as AddressPostCode,
      c.CLCLOSEDATE as AgencyClosedDate,
      left(c.CLPREVALPHA,7) as AgencyPreviousAlpha,
      left(c.CLCALLFREQ,3) as CallFrequency,
      left(convert(varchar,c.SalesSegment),50) as SalesSegment,
      c.PotentialSales,
      left(c.AMCALLFREQ,3) as AccountMgrCallFrequency,
      left(c.SalesTier,50) as SalesTier,
      c.CConly,
      null as STARegion,
      (select top 1 BDMName from [db-au-stage].dbo.trips_bdmexternal_my where BDMId = c.ExternalBDMId and InUseFlag = 1) as ExternalBDMName,
      c.ExternalID ExternalAgencyCode
    from
      [db-au-stage].dbo.trips_clreg_my c

    union all

    select
      convert(varchar(500),null) as AgencyHashKey,
      'SG' as CountryKey,
      'SG-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
      case when c.CLGROUP = 'MA' then 'Malaysia Airlines'
           else null
      end as AgencySuperGroupName,
      c.CLGROUP as AgencyGroupCode,
      (select top 1 left(Descript,25) from [db-au-stage].dbo.trips_agencygroup_sg where Code = c.CLGROUP) as AgencyGroupName,
      c.AgencySubGroup as AgencySubGroupCode,
      (select top 1 left(Description,50) from [db-au-stage].dbo.trips_agencysubgroup_sg t where t.CLGROUP = c.CLGROUP and SUBGRCODE = c.AgencySubGroup) as AgencySubGroupName,
      c.CLALPHA as AgencyCode,
      left(c.CLCONAM,50) as AgencyName,
      left(c.CLBRAN,60) as Branch,
      c.FCCountry as FLCountryCode,
      null FLCountryName,
      null FLNationCode,
      null  as FLNationName,
      left(c.CLPHONE,12) as Phone,
      left(c.CLFAX,12) as Fax,
      (select top 1 left(Descript,20) from [db-au-stage].dbo.trips_state_sg where Code = c.CLGRSTATE) as AgencyGroupState,
      left(c.CLCUSTSERV,3) as CustomerServiceInitial,
      left(c.CLCON1,4) as ContactTitle,
      left(c.CLCON4,25) as ContactFirstName,
      left(c.CLCON2,4) as ContactMiddleInitial,
      left(c.CLCON3,25) as ContactLastName,
      left(c.EMAIL,60) as ContactEmail,
      left(c.CLCOMM,100) as AgencyComment,
      left(c.CLPROS,2) as AgencyStatusCode,
      (select top 1 left([Description],50) from [db-au-stage].dbo.trips_codesclpros_sg where Code = c.CLPROS) as AgencyStatusName,
      convert(varchar,c.CLSCODE) as BDMCode,
      (select top 1 left(ExecName,20) from [db-au-stage].dbo.trips_bdm_sg where Code = c.CLSCODE) as BDMName,
      c.CLACCOUNTMGRID as AccountMgrCode,
      (select top 1 left(FullName,100) from [db-au-stage].dbo.trips_accountmgr_sg where AccountMgrId = c.CLACCOUNTMGRID) as AccountMgrName,
      c.CMAA as AgreementDate,
      c.TSSAA as DateASICChecked,
      left(c.FSRTYPE,4) as FSRType,
      c.ASIC_NUMBER as ASICNumber,
      left(c.LEGALENTITY,100) as LegalEntity,
      left(c.CLABN,24) as ABN,
      c.CCCOMMPAYTYPEID as CommissionPayTypeID,
      c.FSGMINCOMMISSION as FSGMinimumCommission,
      c.FSGMAXCOMMISSION as FSGMaxCommission,
      c.CLDMOD as LastModifiedDate,
      left(c.CLMODBY,2) as ModifiedByInitial,
      left(c.CLADD1,75) as AddressStreet,
      left(c.CLADD2,25) as AddressSuburb,
      left(c.CLADD3,3) as AddressState,
      convert(varchar,c.CLPOST) as AddressPostCode,
      c.CLCLOSEDATE as AgencyClosedDate,
      left(c.CLPREVALPHA,7) as AgencyPreviousAlpha,
      left(c.CLCALLFREQ,3) as CallFrequency,
      left(convert(varchar,c.SalesSegment),50) as SalesSegment,
      c.PotentialSales,
      left(c.AMCALLFREQ,3) as AccountMgrCallFrequency,
      left(c.SalesTier,50) as SalesTier,
      c.CConly,
      null as STARegion,
      (select top 1 BDMName from [db-au-stage].dbo.trips_bdmexternal_sg where BDMId = c.ExternalBDMId and InUseFlag = 1) as ExternalBDMName,
      c.ExternalID ExternalAgencyCode
    from
      [db-au-stage].dbo.trips_clreg_sg c


    --update agency super group where it was null in the previous section
    update [db-au-stage].dbo.etl_agency
    set AgencySuperGroupName = AgencyGroupName
    where
        CountryKey in ('AU','NZ') and
        AgencySuperGroupName is null


    --update agency with AgencyHashKey values
    --20120109, LS, add agency name to hash key. Agencies were not supposed to change their names, this is for UK where they changed agencies name for web sales.
    update [db-au-stage].dbo.etl_Agency
    set AgencyHashKey  =
      (
        AgencyKey COLLATE DATABASE_DEFAULT  + '-' +
        isNull(AgencySuperGroupName COLLATE DATABASE_DEFAULT ,' ') + '-' +
        isNull(AgencyGroupCode COLLATE DATABASE_DEFAULT ,' ') + '-' +
        isNull(AgencyGroupCode COLLATE DATABASE_DEFAULT ,' ') + '-' +
        isNull(AgencySubGroupCode COLLATE DATABASE_DEFAULT ,' ') + '-' +
        isNull(AgencyName COLLATE DATABASE_DEFAULT ,' ') + '-' +
        isNull(Branch,' ') + '-' +
        isNull(FLCountryCode,' ') + isNull(FLCountryName,' ') + '-' +
        isNull(convert(varchar,FLNationCode),' ') + '-' +
        isNull(FLNationName,' ') + '-' +
        isNull(AgencyGroupState,' ') + '-' +
        isNull(AgencyStatusCode,' ') + '-' +
        isNull(BDMCode,' ') + '-' +
        isNull(BDMName,' ') + '-' +
        isNull(convert(varchar,AccountMgrCode),' ') + '-' +
        isNull(AccountMgrName,' ') + '-' +
        isNull(STARegion,' ') + '-' +
        isNull(SalesSegment,' ') + '-' +
        isNull(SalesTier,' ') + '-' +
        isNull(convert(varchar,PotentialSales),' ')
      )


    --create Agency table if not already created
    if object_id('[db-au-cmdwh].dbo.Agency') is null
    begin
      create table [db-au-cmdwh].dbo.Agency
      (
        AgencySKey bigint identity(1000,1) not null,
        AgencyStatus varchar(20) not null,
        AgencyStartDate datetime null,
        AgencyEndDate datetime null,
        AgencyHashKey varchar(500) null,
        CountryKey varchar(2) not null,
        AgencyKey varchar(10) not null,
        AgencySuperGroupName varchar(25) null,
        AgencyGroupCode varchar(2) null,
        AgencyGroupName varchar(25) null,
        AgencySubGroupCode varchar(2) null,
        AgencySubGroupName varchar(50) null,
        AgencyCode varchar(7) null,
        AgencyName varchar(50) null,
        Branch varchar(60) null,
        FLCountryCode varchar(30) null,
        FLCountryName varchar(30) null,
        FLNationCode tinyint null,
        FLNationName varchar(20) null,
        Phone varchar(12) null,
        Fax varchar(12) null,
        AgencyGroupState varchar(20) null,
        CustomerServiceInitial varchar(3) null,
        ContactTitle varchar(4) null,
        ContactFirstName varchar(25) null,
        ContactMiddleInitial varchar(4) null,
        ContactLastName varchar(25) null,
        ContactEmail varchar(60) null,
        AgencyComment varchar(100) null,
        AgencyStatusCode varchar(2) null,
        AgencyStatusName varchar(50) null,
        BDMCode varchar(30) null,
        BDMName varchar(20) null,
        AccountMgrCode int null,
        AccountMgrName varchar(100) null,
        AgreementDate datetime null,
        DateASICChecked datetime null,
        FSRType varchar(4) null,
        ASICNumber varchar(50) null,
        LegalEntity varchar(100) null,
        ABN varchar(24) null,
        CommissionPayTypeID int null,
        FSGMinimumCommission float null,
        FSGMaxCommission float null,
        LastModifiedDate datetime null,
        ModifiedByInitial varchar(2) null,
        AddressStreet varchar(75) null,
        AddressSuburb varchar(25) null,
        AddressState varchar(3) null,
        AddressPostCode varchar(30) null,
        AgencyClosedDate datetime null,
        AgencyPreviousAlpha varchar(7) null,
        CallFrequency varchar(3) null,
        SalesSegment varchar(50) null,
        PotentialSales money null,
        AccountMgrCallFrequency varchar(3) null,
        SalesTier varchar(50) null,
        CCOnly bit NULL,
        STARegion varchar(50) null,
        ExternalBDMName varchar(40) null,
        ExternalAgencyCode varchar(20) null
      )

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencySKey')
        drop index idx_Agency_AgencySKey on Agency.AgencySKey

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyHashKey')
        drop index idx_Agency_AgencyHashKey on Agency.AgencyHashKey

      if exists(select name from sys.indexes where name = 'idx_Agency_CountryKey')
        drop index idx_Agency_CountryKey on Agency.CountryKey

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyKey')
        drop index idx_Agency_AgencyKey on Agency.AgencyKey

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyCode')
        drop index idx_Agency_AgencyCode on Agency.AgencyCode

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyGroupCode')
        drop index idx_Agency_AgencyGroupCode on Agency.AgencyGroupCode

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencySubGroupCode')
        drop index idx_Agency_AgencySubGroupCode on Agency.AgencySubGroupCode

      if exists(select name from sys.indexes where name = 'idx_Agency_FLCountryName')
        drop index idx_Agency_FLCountryName on Agency.FLCountryName

      if exists(select name from sys.indexes where name = 'idx_Agency_FLNationName')
        drop index idx_Agency_FLNationName on Agency.FLNationName

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyStatusCode')
        drop index idx_Agency_AgencyStatusCode on Agency.AgencyStatusCode

      if exists(select name from sys.indexes where name = 'idx_Agency_AgencyGroupState')
        drop index idx_Agency_AgencyGroupState on Agency.AgencyGroupState


      create index idx_Agency_AgencySKey on [db-au-cmdwh].dbo.Agency(AgencySKey)
      create index idx_Agency_AgencyHashKey on [db-au-cmdwh].dbo.Agency(AgencyHashKey)
      create index idx_Agency_CountryKey on [db-au-cmdwh].dbo.Agency(CountryKey)
      create index idx_Agency_AgencyKey on [db-au-cmdwh].dbo.Agency(AgencyKey)
      create index idx_Agency_AgencyCode on [db-au-cmdwh].dbo.Agency(AgencyCode)
      create index idx_Agency_AgencyGroupCode on [db-au-cmdwh].dbo.Agency(AgencyGroupCode)
      create index idx_Agency_AgencySubGroupCode on [db-au-cmdwh].dbo.Agency(AgencySubGroupCode)
      create index idx_Agency_FLCountryName on [db-au-cmdwh].dbo.Agency(FLCountryName)
      create index idx_Agency_FLNationName on [db-au-cmdwh].dbo.Agency(FLNationName)
      create index idx_Agency_AgencyStatusCode on [db-au-cmdwh].dbo.Agency(AgencyStatusCode)
      create index idx_Agency_AgencyGroupState on [db-au-cmdwh].dbo.Agency(AgencyGroupState)
    end



    --get agencies that are new or had hashkey changed since last ETL run
    if object_id('tempdb..#etl_agency') is not null drop table #etl_agency
    select    a.*
    into #etl_agency
    from
        [db-au-stage].dbo.etl_Agency a
    where
        a.AgencyHashKey not in (select AgencyHashKey from [db-au-cmdwh].dbo.Agency where AgencyStatus = 'Current')



    --update Agency to Not Current, and set the AgencyEndDate to 2 days before ETL run date
    update [db-au-cmdwh].dbo.Agency
    set AgencyStatus = 'Not Current' COLLATE DATABASE_DEFAULT, AgencyEndDate = convert(datetime,convert(varchar(10),dateadd(d,-2,getdate()),120))
    where
        AgencyKey in (select AgencyKey COLLATE DATABASE_DEFAULT from #etl_agency) and
        AgencyStatus = 'Current' COLLATE DATABASE_DEFAULT



    --insert new/modified agency
    insert into [db-au-cmdwh].dbo.Agency with (tablock)
    (
        AgencyStatus,
        AgencyStartDate,
        AgencyEndDate,
        AgencyHashKey,
        CountryKey,
        AgencyKey,
        AgencySuperGroupName,
        AgencyGroupCode,
        AgencyGroupName,
        AgencySubGroupCode,
        AgencySubGroupName,
        AgencyCode,
        AgencyName,
        Branch,
        FLCountryCode,
        FLCountryName,
        FLNationCode,
        FLNationName,
        Phone,
        Fax,
        AgencyGroupState,
        CustomerServiceInitial,
        ContactTitle,
        ContactFirstName,
        ContactMiddleInitial,
        ContactLastName,
        ContactEmail,
        AgencyComment,
        AgencyStatusCode,
        AgencyStatusName,
        BDMCode,
        BDMName,
        AccountMgrCode,
        AccountMgrName,
        AgreementDate,
        DateASICChecked,
        FSRType,
        ASICNumber,
        LegalEntity,
        ABN,
        CommissionPayTypeID,
        FSGMinimumCommission,
        FSGMaxCommission,
        LastModifiedDate,
        ModifiedByInitial,
        AddressStreet,
        AddressSuburb,
        AddressState,
        AddressPostCode,
        AgencyClosedDate,
        AgencyPreviousAlpha,
        CallFrequency,
        SalesSegment,
        PotentialSales,
        AccountMgrCallFrequency,
        SalesTier,
        CCOnly,
        STARegion,
        ExternalBDMName,
        ExternalAgencyCode

    )
    select
        'Current' as AgencyStatus,
        convert(datetime,convert(varchar(10),dateadd(d,-1,getdate()),120)) AgencyStartDate,
        null as AgencyEndDate,
        a.AgencyHashKey,
        a.CountryKey,
        a.AgencyKey,
        a.AgencySuperGroupName,
        a.AgencyGroupCode,
        a.AgencyGroupName,
        a.AgencySubGroupCode,
        a.AgencySubGroupName,
        a.AgencyCode,
        a.AgencyName,
        a.Branch,
        a.FLCountryCode,
        a.FLCountryName,
        a.FLNationCode,
        a.FLNationName,
        a.Phone,
        a.Fax,
        a.AgencyGroupState,
        a.CustomerServiceInitial,
        a.ContactTitle,
        a.ContactFirstName,
        a.ContactMiddleInitial,
        a.ContactLastName,
        a.ContactEmail,
        a.AgencyComment,
        a.AgencyStatusCode,
        a.AgencyStatusName,
        a.BDMCode,
        a.BDMName,
        a.AccountMgrCode,
        a.AccountMgrName,
        a.AgreementDate,
        a.DateASICChecked,
        a.FSRType,
        a.ASICNumber,
        a.LegalEntity,
        a.ABN,
        a.CommissionPayTypeID,
        a.FSGMinimumCommission,
        a.FSGMaxCommission,
        a.LastModifiedDate,
        a.ModifiedByInitial,
        a.AddressStreet,
        a.AddressSuburb,
        a.AddressState,
        a.AddressPostCode,
        a.AgencyClosedDate,
        a.AgencyPreviousAlpha,
        a.CallFrequency,
        a.SalesSegment,
        a.PotentialSales,
        a.AccountMgrCallFrequency,
        a.SalesTier,
        a.CCOnly,
        a.STARegion,
        a.ExternalBDMName,
        a.ExternalAgencyCode
    from
        [db-au-stage].dbo.etl_Agency a
    where
        a.AgencyHashKey in (select AgencyHashKey from #etl_agency)

    --update agencies where hashkey are not new or not modified
    --these fields needs to be updated in case they were changed
    update [db-au-cmdwh].dbo.Agency
    set    Phone = a.Phone,
        Fax = a.Fax,
        CustomerServiceInitial = a.CustomerServiceInitial,
        ContactTitle = a.ContactTitle,
        ContactFirstName = a.ContactFirstName,
        ContactMiddleInitial = a.ContactMiddleInitial,
        ContactLastName = a.ContactLastName,
        ContactEmail = a.ContactEmail,
        AgencyComment = a.AgencyComment,
        AgreementDate = a.AgreementDate,
        DateASICChecked = a.DateASICChecked,
        FSRType = a.FSRType,
        ASICNumber = a.ASICNumber,
        LegalEntity = a.LegalEntity,
        ABN = a.ABN,
        CommissionPayTypeID = a.CommissionPayTypeID,
        FSGMinimumCommission = a.FSGMinimumCommission,
        FSGMaxCommission = a.FSGMaxCommission,
        LastModifiedDate = a.LastModifiedDate,
        ModifiedByInitial = a.ModifiedByInitial,
        AddressStreet = a.AddressStreet,
        AddressSuburb = a.AddressSuburb,
        AddressState = a.AddressState,
        AddressPostCode = a.AddressPostCode,
        AgencyClosedDate = a.AgencyClosedDate,
        AgencyPreviousAlpha = a.AgencyPreviousAlpha,
        CallFrequency = a.CallFrequency,
        SalesSegment = a.SalesSegment,
        PotentialSales = a.PotentialSales,
        AccountMgrCallFrequency =  a.AccountMgrCallFrequency,
        SalesTier = a.SalesTier,
        CCOnly = a.CCOnly,
        AgencyStatusName = a.AgencyStatusName
    from
        [db-au-cmdwh].dbo.Agency b
        join [db-au-stage].dbo.etl_Agency a on
            b.AgencyKey COLLATE DATABASE_DEFAULT = a.AgencyKey COLLATE DATABASE_DEFAULT
    where
        b.AgencyHashKey not in (select AgencyHashKey from #etl_Agency)


    drop table #etl_agency



-- The following is a temporary measure to populate Agency columns with respective Penguin columns
-- due to Penguin not correctly pushing agency details to TRIPS.
-- The step will be obsolete once TRIPS is switched off at end of November 2013
update [db-au-cmdwh].dbo.Agency
set
        FLCountryName = left(o.FCArea,30),
        FLNationName = left(o.FCNation,20),
        AgencyStatusName = left(o.TradingStatus,50),
        BDMName = left(o.BDMName,20),
        AccountMgrName = left(o.AcctManagerName,100),
        ExternalBDMName = left(o.ExternalBDMName,40),
        ExternalAgencyCode = left(o.ExtID,20)
from
	[db-au-cmdwh].dbo.Agency a
	join [db-au-cmdwh].dbo.penOutlet o on
		a.CountryKey = o.CountryKey and
		a.AgencyCode = o.AlphaCode and
		a.AgencyStatus = 'Current' and
		o.OutletStatus = 'Current'
		        
end


GO
