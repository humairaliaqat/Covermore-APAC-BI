USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0734]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0734]
as


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0734
--  Author:         Linus Tor
--  Date Created:   20160201
--  Description:    This stored procedure returns SPANCO data from Salesforce.com
--
--  Change History: 20160201 - LT - created
--                  20160407 - LT - filtered results to latest opportunity record per client.
--									changed LastModifiedDate and LastModifiedBy logic
--					20160720 - LT - Exclude Pending stage name from result set.
/****************************************************************************************************/

SET NOCOUNT ON



;with cte_opportunity
as
(
	select
		row_number() over (partition by a.AccountName order by o.LastModifiedDate desc) as RowID,
		o.OpportunityID,
		o.RecordType,
		o.OpportunityName,
		o.description,
		o.StageName,
		o.Amount,		
		o.Probability,
		o.ExpectedRevenue,
		o.EstimatedAnnualRevenue,
		o.CloseDate,
		o.NextStep,
		o.LeadSource,
		o.isClosed,
		o.isWon,
		o.ForecastCategoryName,
		o.hasOpportunityLineItem,
		o.[Owner],
		o.CreatedDate,
		o.CreatedBy,
		case when lm.LastModifiedDate is null then o.LastModifiedDate
			 when lm.LastModifiedDate < o.LastModifiedDate then o.LastModifiedDate
			 else lm.LastModifiedDate
		end as LastModifiedDate,
		case when lm.LastModifiedDate is null then o.LastModifiedBy
		     when lm.LastModifiedDate < o.LastModifiedDate then o.LastModifiedBy
			 else lm.LastModifiedBy
		end as LastModifiedBy,
		o.LastActivityDate,
		o.FiscalQuarter,
		o.FiscalYear,
		o.Fiscal,
		o.LastViewedDate,
		o.LastReferencedDate,
		o.BusinessType,
		o.GrossWrittenPremium,
		o.LaunchDate,
		o.Product,
		o.Solution,
		a.AccountID,
		a.AccountName as Client,
		a.DomainCode as Country,
		a.CompanyCode,
		a.SalesQuadrant,
		u.[Profile]
	from 
		sfOpportunity o
		inner join sfAccount a on o.AccountId = a.AccountID	
		inner join sfUser u on o.[Owner] = u.Name		
		outer apply
		(
			select Top 1 LastModifiedBy, LastModifiedDate
			from sfTask
			where AccountID = o.AccountID
			order by LastModifiedDate desc
		) lm
	where			
		u.[Profile] = 'Blue Sky' and
		o.StageName <> 'Pending'		
)
select
	o.Country,
	o.Client,
	ISNULL(LEFT(PARSENAME(REPLACE(RTRIM(REPLACE(o.LastModifiedBy, ' ', ' ')), ' ', '.'), 4), 1) + '', '') 
	+ ISNULL(LEFT(PARSENAME(REPLACE(RTRIM(REPLACE(o.LastModifiedBy, ' ', ' ')), ' ', '.'), 3), 1) + '', '') 
	+ ISNULL(LEFT(PARSENAME(REPLACE(RTRIM(REPLACE(o.LastModifiedBy, ' ', ' ')), ' ', '.'), 2), 1) + '', '') 
	+ ISNULL(LEFT(PARSENAME(REPLACE(RTRIM(REPLACE(o.LastModifiedBy, ' ', ' ')), ' ', '.'), 1), 1) + '', '')
	+ ' - '  + replace(convert(varchar(7),o.LastModifiedDate,113),' ','') + convert(varchar(2),o.LastModifiedDate,2) as LastContact,
	o.LastModifiedDate,
	o.BusinessType,
	o.EstimatedAnnualRevenue as EstimatedAnnualRevenue,
	o.ExpectedRevenue as EstimatedRevenue,
	o.StageName as SPANCOName,
	o.Probability/100 as SPANCOPct,
	convert(datetime,o.LaunchDate) as LaunchDate,
	convert(varchar(8000),o.[Description]) as Comment,
	o.ExpectedRevenue as SPANCOValue,
	d.FiscalYear,
	case when o.LaunchDate is null then 0
		 when convert(datetime,o.LaunchDate) >= d.NextFiscalYearStart then 0
		 when convert(datetime,o.LaunchDate) < d.NextFiscalYearStart then (o.ExpectedRevenue / 12) * datediff(month,convert(datetime,o.LaunchDate),d.NextFiscalYearStart)
		 else 0
	end as EstimatedRevenueFY
from 
	cte_opportunity o
	outer apply
	(
		select top 1 NextFiscalYearStart, 'FY ' + right(year(CurFiscalYearStart),2) + '/' + right(year(CurFiscalYear),2) as FiscalYear
		from calendar 
		where 
			date = convert(varchar(10),dateadd(d,-1,getdate()),120) 
	) d
where 
	o.RowID = 1						--get only last opportunity record for each client
GO
