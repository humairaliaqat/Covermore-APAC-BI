USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880i]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- MDM Unconsolidated Party
CREATE PROCEDURE [dbo].[rptsp_rpt0880i]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880i
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Monitoring - MDM Unconsolidated Party
--  Parameters:     N/A
/****************************************************************************************************/
select PartyID
, PartyConsolidationID
, DistributorCode
, PartyStatus
, Comment
, CommentGroup
, PartySourceSystem
, ProductSourceSystem
, ProductType
, ProductPartyRole
, ProductReferenceNumber
, PartyCreateDateGroup
, PartyCreateDate
, PartyUpdateDate
, PartyName
, FullName
, Title
, FirstName
, MiddleName
, LastName
, Gender
, DOB
, Age
, Email
, EmailStatus
, PersonalPriEmail
, PersonalPriEmailStatus
, PersonalSecEmail
, PersonalSecEmailStatus
, Phone
, PhoneStatus
, PriPhone
, PriPhoneStatus
, SecPhone
, SecPhoneStatus
, PriAddrSystem
, PriAddr
, PriAddrStatus
, SecAddrSystem
, SecAddr
, SecAddrStatus
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select mp.ROWID_OBJECT as PartyID
, mp.CONSOLIDATION_IND as PartyConsolidationID
, mp.DIST_CD as DistributorCode
, mp.STATUS as PartyStatus
, mp.COMMENTS as Comment
, left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(mp.COMMENTS, ''0'', ''x''), ''1'', ''x''), ''2'', ''x''), ''3'', ''x''), ''4'', ''x''), ''5'', ''x''), ''6'', ''x''), ''7'', ''x''), ''8'', ''x''), ''9'', ''x''), 250) as CommentGroup
, mp.LAST_ROWID_SYSTEM as PartySourceSystem
, mprd.LAST_ROWID_SYSTEM as ProductSourceSystem
, mprd.PROD_TYP as ProductType
, mprd.PRTY_ROLE as ProductPartyRole
, mprd.PROD_REF_NO as ProductReferenceNumber
, case when datediff(HOUR, mp.CREATE_DATE, getdate()) <= 0 then ''A: This Hour''
	when datediff(DAY, mp.CREATE_DATE, getdate()) <= 0 then ''B: Today''
	when datediff(WEEK, mp.CREATE_DATE, getdate()) <= 0 then ''C: This Week''
	when datediff(MONTH, mp.CREATE_DATE, getdate()) <= 0 then ''D: This Month''
	when datediff(YEAR, mp.CREATE_DATE, getdate()) <= 0 then ''E: This Year''
	when datediff(YEAR, mp.CREATE_DATE, getdate()) <= 1 then ''F: Last Year''
	else ''G: Other'' end as PartyCreateDateGroup
, mp.CREATE_DATE as PartyCreateDate
, mp.LAST_UPDATE_DATE as PartyUpdateDate
, mp.PRTY_NM as PartyName
, mpd.IND_NM as FullName
, mpd.TITLE as Title
, mpd.FRST_NM as FirstName
, mpd.MID_NM as MiddleName
, mpd.LST_NM as LastName
, mpd.GNDR as Gender
, try_convert(datetime, mpd.DOB) as DOB
, mpd.AGE as Age
, coalesce(mpepp.EMAIL_VAL, mpeps.EMAIL_VAL) Email
, coalesce(mpepp.STATUS, mpeps.STATUS) EmailStatus
, mpepp.EMAIL_VAL as PersonalPriEmail
, mpepp.STATUS as PersonalPriEmailStatus
, mpeps.EMAIL_VAL as PersonalSecEmail
, mpeps.STATUS as PersonalSecEmailStatus
, coalesce(mppp.FULL_PH_VAL, mpps.FULL_PH_VAL) Phone
, coalesce(mppp.STATUS, mpps.STATUS) PhoneStatus
, mppp.FULL_PH_VAL as PriPhone
, mppp.STATUS as PriPhoneStatus
, mpps.FULL_PH_VAL as SecPhone
, mpps.STATUS as SecPhoneStatus
, mpap.LAST_ROWID_SYSTEM as PriAddrSystem
, mpap.Addr as PriAddr
, mpap.STATUS as PriAddrStatus
, mpas.LAST_ROWID_SYSTEM as SecAddrSystem
, mpas.Addr as SecAddr
, mpas.STATUS as SecAddrStatus
from [MDM_Distributor]..C_PARTY mp with (nolock)
inner join [MDM_Distributor]..C_PRTY_IND_DTL mpd with (nolock) on mpd.PRTY_FK = mp.ROWID_OBJECT
outer apply (select top 1 prd.LAST_ROWID_SYSTEM, prd.PROD_TYP, prd.PRTY_ROLE, prd.PROD_REF_NO
	from [MDM_Distributor]..C_PARTY_PRODUCT_TXN prd with (nolock)
	where prd.PRTY_FK = mp.ROWID_OBJECT
	order by prd.CREATE_DATE desc
	) mprd
outer apply (select top 1 pe.EMAIL_TYP, pe.EMAIL_VAL, pe.STATUS
	from [MDM_Distributor]..C_PARTY_EMAIL pe with (nolock)
	where pe.PRTY_FK = mp.ROWID_OBJECT
	and pe.EMAIL_TYP = ''Personal Primary''
	order by pe.CREATE_DATE desc
	) mpepp
outer apply (select top 1 pe.EMAIL_TYP, pe.EMAIL_VAL, pe.STATUS
	from [MDM_Distributor]..C_PARTY_EMAIL pe with (nolock)
	where pe.PRTY_FK = mp.ROWID_OBJECT
	and pe.EMAIL_TYP = ''Personal Secondary''
	order by pe.CREATE_DATE desc
	) mpeps
outer apply (select top 1 pp.FULL_PH_VAL, pp.PH_TYP, pp.STATUS
	from [MDM_Distributor]..C_PARTY_PHONE pp with (nolock)
	where pp.PRTY_FK = mp.ROWID_OBJECT
	and pp.PH_TYP = ''Primary''
	order by pp.CREATE_DATE desc
	) mppp
outer apply (select top 1 pp.FULL_PH_VAL, pp.PH_TYP, pp.STATUS
	from [MDM_Distributor]..C_PARTY_PHONE pp with (nolock)
	where pp.PRTY_FK = mp.ROWID_OBJECT
	and pp.PH_TYP = ''Secondary''
	order by pp.CREATE_DATE desc
	) mpps
outer apply (select top 1 pa.LAST_ROWID_SYSTEM, pa.STATUS
	, isnull(pa.ADDR_LINE1, '''') + ''|'' + isnull(pa.ADDR_LINE2, '''') + ''|'' + isnull(pa.CITY, '''') + ''|'' + isnull(pa.CNTRY, '''') + ''|'' + isnull(pa.CNTRY_CD, '''') + ''|'' + isnull(pa.POST_CD, '''') as Addr
	FROM [MDM_Distributor]..C_PARTY_ADDRESS pa with (nolock)
	where pa.PRTY_FK = mp.ROWID_OBJECT
	and pa.ADDR_TYP = ''Primary''
	order by pa.CREATE_DATE desc
	) mpap
outer apply (select top 1 pa.LAST_ROWID_SYSTEM, pa.STATUS
	, isnull(pa.ADDR_LINE1, '''') + ''|'' + isnull(pa.ADDR_LINE2, '''') + ''|'' + isnull(pa.CITY, '''') + ''|'' + isnull(pa.CNTRY, '''') + ''|'' + isnull(pa.CNTRY_CD, '''') + ''|'' + isnull(pa.POST_CD, '''') as Addr
	FROM [MDM_Distributor]..C_PARTY_ADDRESS pa with (nolock)
	where pa.PRTY_FK = mp.ROWID_OBJECT
	and pa.ADDR_TYP = ''Secondary''
	order by pa.CREATE_DATE desc
	) mpas
where mp.CONSOLIDATION_IND <> 1
order by mp.CREATE_DATE desc, mp.ROWID_OBJECT')

GO
