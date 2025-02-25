USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonySales]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vTelephonySales] as


select 
    isnull(u.FirstName + ' ' + u.LastName, 'Unknown') AgentName,
    isnull(og.OrganisationName, 'Unknown') TeamName, 
    case
		when o.GroupName = 'Cover-More' then 'CoverMore'
		when o.GroupName = 'RACQ' then 'AAA'
		--Inclusion of additional groups - SD - 20170214 (INC0023603)
		when o.AlphaCOde = 'MBN0011' Then 'Medibank'
		when o.AlphaCOde = 'VAA0003' or o.AlphaCode = 'VAA0004' Then 'Virgin'
		when o.AlphaCOde = 'AHN0002' Then 'AHM'
		when o.AlphaCOde = 'YGN0002' Then 'YouGo'
		when o.AlphaCOde = 'PON0010' Then 'Princess'
		when o.AlphaCOde = 'PON0003' Then 'P&O'
		when o.AlphaCOde = 'NTA0002' Then 'Westfund'
		else o.GroupName
	end Company,
    pt.PolicyTransactionKey,
    pt.PolicyNumber,
    pt.PostingDate,
    GrossPremium - TaxAmountGST - TaxAmountSD Premium, 
    GrossPremium SellPrice,
    pt.BasePolicyCount PolicyCount
from
    penPolicyTransSummary pt
    inner join penOutlet o on
        o.OutletAlphaKey = pt.OutletAlphaKey and
        o.OutletStatus = 'Current'
    left outer join penUser u on
        u.UserKey = pt.UserKey and
        u.UserStatus = 'Current'
    outer apply
    (
        select top 1 
            OrganisationName
        from 
            verTeam vt
            inner join verOrganisation o on
                o.OrganisationKey = vt.OrganisationKey
        where
            vt.UserName = pt.CRMUserName or
            vt.UserName = replace(u.[Login], '_AU', '')
    ) og
where
    pt.PostingDate >= '2011-07-01' and
    (
        o.GroupCode IN  ('PH','PA') or
        o.AlphaCode in ('APN0002', 'APN0003', 'APN0004', 'RQN0001','CMFL000','CMN0000','CMN0516','CMN0521', 'MBN0011', 'VAA0003', 'VAA0004', 'AHN0002', 'YGN0002', 'PON0001', 'PON0010', 'PON0003', 'NTA0002', 'HHN0001','HHN0002')
    ) and
    o.CountryKey = 'AU' and
    isnull(u.[Login],'') not in ('mobileuser', 'webuser')
GO
