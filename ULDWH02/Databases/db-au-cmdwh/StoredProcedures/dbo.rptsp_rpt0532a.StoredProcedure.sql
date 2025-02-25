USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0532a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0532a]
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0532a
--  Author:         Linus Tor
--  Date Created:   20140319
--  Description:    This stored procedure returns products that are in data warehouse but not in 
--					Policy Star.
--  Parameters:     
--
--  Change History: 20140319 - LT - Created
--                  20140926 - LS - F21933, remove test environment reference
--
/****************************************************************************************************/


if object_id('tempdb..#rpt0532a_products') is not null drop table #rpt0532a_products
select distinct
	p.CountryKey,
	p.CompanyKey,
	isnull(p.CountryKey,'') + '-' + isnull(p.CompanyKey,'') + '' + convert(varchar,isnull(p.DomainID,0)) + '-' + isnull(p.ProductCode,'') + '-' + isnull(p.ProductName,'') + '-' + isnull(p.ProductDisplayName,'') + '-' + isnull(pp.PlanName,'') as ProductKey,
	p.ProductCode,
	p.ProductName,
	p.ProductDisplayName,
	p.DomainID,
	pp.PlanName,
	'' as ProductType,
	'' as ProductGroup,
	'' as PolicyType,
	'' as ProductClassification,
	'' as FinanceProductCode,
	'' as FinanceProductCodeOld
into #rpt0532a_products	
from 
	[db-au-cmdwh].dbo.penProduct p
	join [db-au-cmdwh].dbo.penProductPlan pp on 
		p.CountryKey = pp.CountryKey and
		p.CompanyKey = pp.CompanyKey and
		p.ProductCode = pp.ProductCode		
order by 
	p.CountryKey,
	p.CompanyKey,
	p.ProductCode
	
	
if object_id('tempdb..#productkey') is not null drop table #productkey
select distinct ProductKey 
into #productkey
from [db-au-star].dbo.dimProduct


--select data for Crystal Reports
if (select count(*) from #rpt0532a_products where ProductKey not in (select ProductKey from #productkey)) = 0
begin
	select 
		convert(varchar(2),null) as CountryKey,
		convert(varchar(5),null) as CompanyKey,
		convert(varchar(100),null) as ProductKey,
		convert(nvarchar(50),null) as ProductCode,
		convert(nvarchar(50),null) as ProductName,
		convert(nvarchar(50),null) as ProductDisplayName,
		convert(int,null) as DomainID,
		convert(nvarchar(50),null) as PlanName,
		convert(nvarchar(50),null) as ProductType,
		convert(nvarchar(100),null) as ProductGroup,
		convert(nvarchar(50),null) as PolicyType,
		convert(nvarchar(100),null) as ProductClassification,
		convert(nvarchar(50),null) as FinanceProductCode,
		convert(nvarchar(50),null) as FinanceProductCodeOld
end
else
begin
	select
		convert(varchar(2),CountryKey) as CountryKey,
		convert(varchar(5),CompanyKey) as CompanyKey,
		convert(varchar(100),ProductKey) as ProductKey,
		convert(nvarchar(50),ProductCode) as ProductCode,
		convert(nvarchar(50),ProductName) as ProductName,
		convert(nvarchar(50),ProductDisplayName) as ProductDisplayName,
		convert(int,DomainID) as DomainID,
		convert(nvarchar(50),PlanName) as PlanName,
		convert(nvarchar(50),ProductType) as ProductType,
		convert(nvarchar(100),ProductGroup) as ProductGroup,
		convert(nvarchar(50),PolicyType) as PolicyType,
		convert(nvarchar(100),ProductClassification) as ProductClassification,
		convert(nvarchar(50),FinanceProductCode) as FinanceProductCode,
		convert(nvarchar(50),FinanceProductCodeOld) as FinanceProductCodeOld 
	from 
		#rpt0532a_products 
	where ProductKey not in (select ProductKey from #productkey)
end	
					
--drop temp tables
drop table #rpt0532a_products	
drop table #productkey


GO
