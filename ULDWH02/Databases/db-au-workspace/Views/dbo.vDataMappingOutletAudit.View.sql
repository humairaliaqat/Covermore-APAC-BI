USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vDataMappingOutletAudit]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 CREATE   view [dbo].[vDataMappingOutletAudit] as

-- Created by RL
-- [db-au-workspace]..vDataMappingOutletAudit
-- Outlet channel, JV, and distributorID audit
-- Comparing [db-au-star] with [AU_PenguinSharp_Active], [AU_TIP_PenguinSharp_Active], [UK_PenguinSharp_Active], [US_PenguinSharp_Active]
-- Check item 1: Unmapped new outlets in Penguin (StarChannelID = -1)
-- Check item 2: Channel difference between Star and Penguin
-- Check item 3: JV difference between Star and Penguin
-- Check item 4: if default JV of SubGroup is different from its outlet JV
-- Check item 5: For AU domain only, if distributor of SubGroup is NULL
-- Updated: 20160907 v1


with cteAU as (
select * from openquery ([db-au-penguinsharp.aust.covermore.com.au], '
select d.DomainId, d.CountryCode
, g.Code as GroupCode, g.Name as GroupName
, sg.Code as SubGrouCode, sg.Name as SubGroupName
, o.OutletId, o.AlphaCode, o.OutletName, o.StatusValue, rs.Value as StatusValueDesc, o.CommencementDate, o.OutletTypeID, ot.OutletType
, (select count(*) from [AU_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId) as ConsultantCount
, (select count(*) from [AU_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId and u.[Login] = ''webuser'') as WebuserCount
, (select Code from [AU_PenguinSharp_Active]..tblJointVenture where JointVentureId = sg.JointVentureId) as SubGroupDefaultJVCode
, (select Code from [AU_PenguinSharp_Active]..tblDistributor where DistributorId = sg.DistributorId) as SubGroupDistributor
, jv.Code as JVCode, jv.Name as JVDesc
, r.Code ChannelID, r.Value as ChannelDesc
, i.FirstName + '' '' + i.LastName as BDM
, d.CountryCode + ''-CM'' + cast(d.DomainId as varchar(2)) + ''-'' + o.AlphaCode as OutletAlphaKey
--select count(*)
from [AU_PenguinSharp_Active]..tblOutlet o
inner join [AU_PenguinSharp_Active]..tblDomain d on d.DomainId = o.DomainId
inner join [AU_PenguinSharp_Active]..tblSubGroup sg on sg.ID = o.SubGroupID
inner join [AU_PenguinSharp_Active]..tblGroup g on g.ID = sg.GroupID
inner join [AU_PenguinSharp_Active]..tblReferenceValue rs on rs.ID = o.StatusValue
inner join [AU_PenguinSharp_Active]..tblOutletType ot on ot.OutletTypeID = o.OutletTypeID
left join [AU_PenguinSharp_Active]..tblOutletContactInfo i on i.OutletID = o.OutletId
left join [AU_PenguinSharp_Active]..tblOutlet_OTC otc on otc.OutletID = o.OutletId
left join [AU_PenguinSharp_Active]..tblReferenceValue r on r.id = otc.ChannelId
left join [AU_PenguinSharp_Active]..tblJointVenture jv on jv.JointVentureId = o.JointVentureId
')
)
--select * from cteAU
, cteTIP as (
select * from openquery ([db-au-penguinsharp.aust.covermore.com.au], '
select d.DomainId, d.CountryCode
, g.Code as GroupCode, g.Name as GroupName
, sg.Code as SubGrouCode, sg.Name as SubGroupName
, o.OutletId, o.AlphaCode, o.OutletName, o.StatusValue, rs.Value as StatusValueDesc, o.CommencementDate, o.OutletTypeID, ot.OutletType
, (select count(*) from [AU_TIP_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId) as ConsultantCount
, (select count(*) from [AU_TIP_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId and u.[Login] = ''webuser'') as WebuserCount
, (select Code from [AU_TIP_PenguinSharp_Active]..tblJointVenture where JointVentureId = sg.JointVentureId) as SubGroupDefaultJVCode
, (select Code from [AU_TIP_PenguinSharp_Active]..tblDistributor where DistributorId = sg.DistributorId) as SubGroupDistributor
, jv.Code as JVCode, jv.Name as JVDesc
, r.Code ChannelID, r.Value as ChannelDesc
, i.FirstName + '' '' + i.LastName as BDM
, d.CountryCode + ''-CM'' + cast(d.DomainId as varchar(2)) + ''-'' + o.AlphaCode as OutletAlphaKey
--select count(*)
from [AU_TIP_PenguinSharp_Active]..tblOutlet o
inner join [AU_TIP_PenguinSharp_Active]..tblDomain d on d.DomainId = o.DomainId
inner join [AU_TIP_PenguinSharp_Active]..tblSubGroup sg on sg.ID = o.SubGroupID
inner join [AU_TIP_PenguinSharp_Active]..tblGroup g on g.ID = sg.GroupID
inner join [AU_TIP_PenguinSharp_Active]..tblReferenceValue rs on rs.ID = o.StatusValue
inner join [AU_TIP_PenguinSharp_Active]..tblOutletType ot on ot.OutletTypeID = o.OutletTypeID
left join [AU_TIP_PenguinSharp_Active]..tblOutletContactInfo i on i.OutletID = o.OutletId
left join [AU_TIP_PenguinSharp_Active]..tblOutlet_OTC otc on otc.OutletID = o.OutletId
left join [AU_TIP_PenguinSharp_Active]..tblReferenceValue r on r.id = otc.ChannelId
left join [AU_TIP_PenguinSharp_Active]..tblJointVenture jv on jv.JointVentureId = o.JointVentureId
')
)
--select * from cteTIP
, cteUK as (
select * from openquery ([SQLIREPRODAGL01], '
select d.DomainId, d.CountryCode
, g.Code as GroupCode, g.Name as GroupName
, sg.Code as SubGrouCode, sg.Name as SubGroupName
, o.OutletId, o.AlphaCode, o.OutletName, o.StatusValue, rs.Value as StatusValueDesc, o.CommencementDate, o.OutletTypeID, ot.OutletType
, (select count(*) from [UK_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId) as ConsultantCount
, (select count(*) from [UK_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId and u.[Login] = ''webuser'') as WebuserCount
, (select Code from [UK_PenguinSharp_Active]..tblJointVenture where JointVentureId = sg.JointVentureId) as SubGroupDefaultJVCode
, (select Code from [UK_PenguinSharp_Active]..tblDistributor where DistributorId = sg.DistributorId) as SubGroupDistributor
, jv.Code as JVCode, jv.Name as JVDesc
, r.Code ChannelID, r.Value as ChannelDesc
, i.FirstName + '' '' + i.LastName as BDM
, d.CountryCode + ''-CM'' + cast(d.DomainId as varchar(2)) + ''-'' + o.AlphaCode as OutletAlphaKey
--select count(*)
from [UK_PenguinSharp_Active]..tblOutlet o
inner join [UK_PenguinSharp_Active]..tblDomain d on d.DomainId = o.DomainId
inner join [UK_PenguinSharp_Active]..tblSubGroup sg on sg.ID = o.SubGroupID
inner join [UK_PenguinSharp_Active]..tblGroup g on g.ID = sg.GroupID
inner join [UK_PenguinSharp_Active]..tblReferenceValue rs on rs.ID = o.StatusValue
inner join [UK_PenguinSharp_Active]..tblOutletType ot on ot.OutletTypeID = o.OutletTypeID
left join [UK_PenguinSharp_Active]..tblOutletContactInfo i on i.OutletID = o.OutletId
left join [UK_PenguinSharp_Active]..tblOutlet_OTC otc on otc.OutletID = o.OutletId
left join [UK_PenguinSharp_Active]..tblReferenceValue r on r.id = otc.ChannelId
left join [UK_PenguinSharp_Active]..tblJointVenture jv on jv.JointVentureId = o.JointVentureId
')
)
--select * from cteUK
, cteUS as (
select * from openquery ([AZUSSQL02], '
select d.DomainId, d.CountryCode
, g.Code as GroupCode, g.Name as GroupName
, sg.Code as SubGrouCode, sg.Name as SubGroupName
, o.OutletId, o.AlphaCode, o.OutletName, o.StatusValue, rs.Value as StatusValueDesc, o.CommencementDate, o.OutletTypeID, ot.OutletType
, (select count(*) from [US_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId) as ConsultantCount
, (select count(*) from [US_PenguinSharp_Active]..tblUser u where u.OutletId = o.OutletId and u.[Login] = ''webuser'') as WebuserCount
, (select Code from [US_PenguinSharp_Active]..tblJointVenture where JointVentureId = sg.JointVentureId) as SubGroupDefaultJVCode
, (select Code from [US_PenguinSharp_Active]..tblDistributor where DistributorId = sg.DistributorId) as SubGroupDistributor
, jv.Code as JVCode, jv.Name as JVDesc
, r.Code ChannelID, r.Value as ChannelDesc
, i.FirstName + '' '' + i.LastName as BDM
, d.CountryCode + ''-CM'' + cast(d.DomainId as varchar(2)) + ''-'' + o.AlphaCode as OutletAlphaKey
--select count(*)
from [US_PenguinSharp_Active]..tblOutlet o
inner join [US_PenguinSharp_Active]..tblDomain d on d.DomainId = o.DomainId
inner join [US_PenguinSharp_Active]..tblSubGroup sg on sg.ID = o.SubGroupID
inner join [US_PenguinSharp_Active]..tblGroup g on g.ID = sg.GroupID
inner join [US_PenguinSharp_Active]..tblReferenceValue rs on rs.ID = o.StatusValue
inner join [US_PenguinSharp_Active]..tblOutletType ot on ot.OutletTypeID = o.OutletTypeID
left join [US_PenguinSharp_Active]..tblOutletContactInfo i on i.OutletID = o.OutletId
left join [US_PenguinSharp_Active]..tblOutlet_OTC otc on otc.OutletID = o.OutletId
left join [US_PenguinSharp_Active]..tblReferenceValue r on r.id = otc.ChannelId
left join [US_PenguinSharp_Active]..tblJointVenture jv on jv.JointVentureId = o.JointVentureId
')
)
--select * from cteUS

-- AU
select cteAU.*
, do.OutletAlphaKey as StarOutletAlphaKey
, do.TradingStatus as StarTradingStatus
, do.SuperGroupName as StarSuperGroup
, do.JV as StartJVCode, do.JVDesc as StarJVDesc
, case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end as StarChannelID
, do.Channel as StarChannelDesc
from [db-au-star]..dimOutlet do
left join cteAU on cteAU.OutletAlphaKey = do.OutletAlphaKey COLLATE Latin1_General_CI_AS
where do.isLatest = 'Y'
and (do.JV COLLATE Latin1_General_CI_AS <> cteAU.JVCode 
or (case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end) <> cteAU.ChannelID -- check jv and channel mapping
or (cteAU.SubGroupDefaultJVCode <> do.JV COLLATE Latin1_General_CI_AS and do.TradingStatus <> 'Closed') -- check default JV for sub group
or (cteAU.SubGroupDistributor is null and cteAU.CountryCode = 'AU'   -- check distributor code for AU domain
	and cteAU.GroupCode <> 'ST')   -- AU STA is no longer active, no need to be assigned with a distributorID, hence should be excluded
--or cteAU.OutletAlphaKey is null
)
-- TIP
union
select cteTIP.*
, do.OutletAlphaKey as StarOutletAlphaKey
, do.TradingStatus as StarTradingStatus
, do.SuperGroupName as StarSuperGroup
, do.JV as StartJVCode, do.JVDesc as StarJVDesc
, case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end as StarChannelID
, do.Channel as StarChannelDesc
from [db-au-star]..dimOutlet do
left join cteTIP on cteTIP.OutletAlphaKey = do.OutletAlphaKey COLLATE Latin1_General_CI_AS
where do.isLatest = 'Y'
and (do.JV COLLATE Latin1_General_CI_AS <> cteTIP.JVCode 
or (case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end) <> cteTIP.ChannelID
or (cteTIP.SubGroupDefaultJVCode <> do.JV COLLATE Latin1_General_CI_AS and do.TradingStatus <> 'Closed')
or (cteTIP.SubGroupDistributor is null and cteTIP.CountryCode = 'AU')
--or cteTIP.OutletAlphaKey is null
)
-- UK
union
select cteUK.*
, do.OutletAlphaKey as StarOutletAlphaKey
, do.TradingStatus as StarTradingStatus
, do.SuperGroupName as StarSuperGroup
, do.JV as StartJVCode, do.JVDesc as StarJVDesc
, case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end as StarChannelID
, do.Channel as StarChannelDesc
from [db-au-star]..dimOutlet do
left join cteUK on cteUK.OutletAlphaKey = do.OutletAlphaKey COLLATE Latin1_General_CI_AS
where do.isLatest = 'Y'
and (do.JV COLLATE Latin1_General_CI_AS <> cteUK.JVCode 
or (case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end) <> cteUK.ChannelID
or (cteUK.SubGroupDefaultJVCode <> do.JV COLLATE Latin1_General_CI_AS and do.TradingStatus <> 'Closed')
--or cteUK.OutletAlphaKey is null
)
-- US
union
select cteUS.*
, do.OutletAlphaKey as StarOutletAlphaKey
, do.TradingStatus as StarTradingStatus
, do.SuperGroupName as StarSuperGroup
, do.JV as StartJVCode, do.JVDesc as StarJVDesc
, case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end as StarChannelID
, do.Channel as StarChannelDesc
from [db-au-star]..dimOutlet do
left join cteUS on cteUS.OutletAlphaKey = do.OutletAlphaKey COLLATE Latin1_General_CI_AS
where do.isLatest = 'Y'
and (do.JV COLLATE Latin1_General_CI_AS <> cteUS.JVCode 
or (case when do.Channel = 'Retail' then 70
when do.Channel = 'Call Centre' then 71
when do.Channel = 'Website White-Label' then 72
when do.Channel = 'Integrated' then 73
when do.Channel = 'Mobile' then 74
when do.Channel = 'Point of Sale' then 75
else -1 end) <> cteUS.ChannelID
or (cteUS.SubGroupDefaultJVCode <> do.JV COLLATE Latin1_General_CI_AS and do.TradingStatus <> 'Closed')
--or cteUS.OutletAlphaKey is null
)


GO
