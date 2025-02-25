USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0532c]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0532c]
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0532c
--  Author:         Linus Tor
--  Date Created:   20140319
--  Description:    This stored procedure returns SalesForce that are in data warehouse but not in 
--					Policy Star.
--  Parameters:     
--
--  Change History: 20140319 - LT - Created
--                  20140926 - LS - F21933, remove test environment reference
--
/****************************************************************************************************/


if object_id('tempdb..#bdm') is not null drop table #bdm
select distinct BDMName 
into #bdm
from 
	[db-au-star].dbo.dimOutlet
	

select distinct
	o.CountryKey,
	o.DomainID,
	o.BDMName,
	'' as FullName,
	'' as PositionTitle,
	'' as DistributorManager,
	'' as TerritoryManager,
	'' as NationalManager
from 
	[db-au-cmdwh].dbo.penOutlet o
where
	o.BDMName not in (select BDMName from #bdm)
order by 
	o.CountryKey,
	o.BDMName

drop table #bdm	
GO
