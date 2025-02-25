USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0532b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0532b]
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0532b
--  Author:         Linus Tor
--  Date Created:   20140319
--  Description:    This stored procedure returns outlets that are in data warehouse but not in 
--					Policy Star.
--  Parameters:     
--
--  Change History: 20140319 - LT - Created
--                  20140926 - LS - F21933, remove test environment reference
--					20150518 - LT - Added outlets where latest outlet SuperGroupName is blank
--
/****************************************************************************************************/



if object_id('tempdb..#OutletODS') is not null drop table #OutletODS
select
	o.CountryKey,
	o.DomainID,
	o.SuperGroupName,
	o.GroupCode,
	o.GroupName,
	o.SubGroupCode,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	'' as Distributor,
	'' as JV,
	'' as Channel
into #OutletODS	
from 
	[db-au-cmdwh].dbo.penOutlet o
where
	o.OutletStatus = 'Current'


select
	o.CountryKey,
	o.DomainID,
	o.SuperGroupName,
	o.GroupCode,
	o.GroupName,
	o.SubGroupCode,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	o.Distributor,
	o.JV,
	o.Channel
from
	#OutletODS o
where
	not exists (select o.AlphaCode	 
				from
					[db-au-star].dbo.dimOutlet o
				)
union
				
select distinct
	o.Country as CountryKey,
	dom.DomainID,
	lo.SuperGroupName,
	lo.GroupCode,
	lo.GroupName,
	lo.SubGroupCode,
	lo.SubGroupName,
	lo.AlphaCode,
	lo.OutletName,
	'' as Distributor,
	'' as JV,
	'' as Channel
from
	[db-au-star].dbo.factPolicyTransaction p
	join [db-au-star].dbo.dimDomain dom on p.DomainSK = dom.DomainSK
	join [db-au-star].dbo.dimOutlet o on p.OutletSK = o.OutletSK
	outer apply
	(
		select top 1 SuperGroupName, AlphaCode, GroupCode, GroupName, SubGroupCode, SubGroupName, OutletName
		from [db-au-star].dbo.dimOutlet
		where OutletSK = o.LatestOutletSK
	) lo
where	
	lo.SuperGroupName = '' and
    o.OutletSK <> -1 and
	o.AlphaCode <> '' and
	o.AlphaCode <> 'TBCADO'
GO
