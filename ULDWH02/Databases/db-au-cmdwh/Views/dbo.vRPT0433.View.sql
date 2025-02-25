USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vRPT0433]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE   view [dbo].[vRPT0433] as
select
    ClaimNo,
    CreatedByName,
    dbo.xfn_ConvertUTCtoLocal(ModifiedDate, d.TimeZoneCode) ModifiedDate,
    PaymentStatus,
    Firstname,
    Surname,
    PaymentAmount,
    PayeeID,
    isThirdParty,
    BusinessName,
    CountryCode,
	GroupName
FROM
	OPENQUERY([db-au-penguinsharp.aust.covermore.com.au],'
		select
			cp.kpclaim_id ClaimNo,
			cu.ksname CreatedByName,
			cp.kpmoddt ModifiedDate,
			cp.kpstatus PaymentStatus,
			cn.knfirst Firstname,
			cn.knsurname Surname,
			sum(cp.kppayamt) PaymentAmount,
			cp.kppayee_id PayeeID,
			cn.knthirdparty isThirdParty,
			cn.knbusinessname BusinessName,
			cl.KLDOMAINID DomainID,
			Outlet.GroupName
		from
			CLAIMS.dbo.klpayments cp with(nolock)
			inner join CLAIMS.dbo.klreg cl with(nolock) on
				cl.klclaim = cp.kpclaim_id
			inner join CLAIMS.dbo.klnames cn on
				cn.kn_id = cp.kppayee_id
			left join CLAIMS.dbo.klsecurity cu on 
				cu.ks_id = cp.kpcreatedby_id
			left join (select O.AlphaCode, O.DomainId, S.Name as SubGroupName, G.Name as GroupName
						from AU_PenguinSharp_Active.dbo.tblOutlet O
						JOIN AU_PenguinSharp_Active.dbo.tblSubGroup S ON O.SubGroupID = S.ID
						JOIN AU_PenguinSharp_Active.dbo.tblGroup G ON S.GroupID = G.ID
						) Outlet on cl.KLALPHA = Outlet.AlphaCode AND cl.KLDOMAINID = outlet.DomainId
		where
			kpstatus in (''APHA'', ''PAPP'') and
			cl.kldomainid in (7, 8)
		group by
			cp.kpclaim_id,
			cu.ksname,
			cp.kpmoddt,
			cp.kpstatus,
			cn.knfirst,
			cn.knsurname,
			cp.kppayee_id,
			cn.knthirdparty,
			cn.knbusinessname,
			cl.KLDOMAINID,
			Outlet.GroupName
	') cl
    inner join [db-au-cmdwh]..usrDomain d on
        d.DomainId = cl.DomainID





GO
