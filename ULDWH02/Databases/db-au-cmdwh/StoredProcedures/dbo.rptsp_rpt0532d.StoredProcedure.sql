USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0532d]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0532d] as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0532d
--  Author:         Peter Zhuo
--  Date Created:   20160112
--  Description:    This stored procedure returns Outlets with same LatestOutletKey having stocked trading status, 
--					and still selling policies in the last 90 days
--
--					The rule is only the latest outlet should be stocked and selling.
--
--  Parameters:     
--
--  Change History: 20160112 - PZ - Created
--                  
--
/****************************************************************************************************/



;with zz0 as
(
select
	bb.LatestOutletKey,
	bb.CountryKey as Country,
	bb.CompanyKey as Company,
	bb.AlphaCode,
	bb.PreviousAlpha,
	bb.OutletKey,
	bb.OutletAlphaKey,
	bb.TradingStatus,
	bb.CommencementDate,
	[Total Gross Premium in 90 days] = sum(pt.GrossPremium)
from
		(--bb
		select
			o.CountryKey,
			o.CompanyKey,
			o.LatestOutletKey,
			o.OutletKey,
			o.PreviousAlpha,
			o.AlphaCode,
			o.OutletAlphaKey,
			o.TradingStatus,
			o.CommencementDate
		from dbo.penoutlet o
		cross apply
				(--aa /* Find all LatestOutletKey which belongs to more than one current and stocked outlet */
				select
					o.LatestOutletKey
				from penoutlet o
				where
					o.OutletStatus = 'current'
					and o.TradingStatus = 'stocked'
				group by
					o.LatestOutletKey
				having
					count(*) > 1
				)as aa
		where
			o.LatestOutletKey = aa.LatestOutletKey
			and o.OutletStatus = 'current'
			and o.TradingStatus = 'stocked'
		)as bb
inner join dbo.penPolicyTransSummary pt on bb.OutletAlphaKey = pt.OutletAlphaKey
where
	--pt.PostingDate >= '2015-12-01'
	datediff(D,pt.PostingDate,getdate()) <= 90  /* Check if these outlets are selling policies within the last 90 days */
group by
	bb.LatestOutletKey,
	bb.CountryKey,
	bb.CompanyKey,
	bb.AlphaCode,
	bb.PreviousAlpha,
	bb.OutletKey,
	bb.OutletAlphaKey,
	bb.TradingStatus,
	bb.CommencementDate
having 
	sum(pt.GrossPremium) > 0 /* Only show outlets that are selling */
)

,zz1 as /* Get the final list of outlets */
(
select
	zz0.*
from
	(--aa
	select
		zz0.LatestOutletKey
	from zz0
	group by
		zz0.LatestOutletKey
	having
		count(*) > 1	
	)as aa
inner join zz0 on aa.LatestOutletKey = zz0.LatestOutletKey
)



select /* Add some additional information - Last Posting Date, Last Sell price etc. */
	zz1.*,
	bb.[Last Posting Date],
	bb.[Last Sell price]
from
	(--bb
	select
		aa.OutletAlphaKey,
		[Last Posting Date] = aa.PostingDate,
		[Last Sell price] = aa.GrossPremium
	from
		(--aa
		select
			pt.PostingDate,
			pt.OutletAlphaKey,
			pt.GrossPremium,
			[x] = ROW_NUMBER() over(partition by pt.OutletAlphaKey order by pt.PostingDate desc, pt.GrossPremium desc)
		from dbo.penPolicyTransSummary pt
		inner join zz1 on pt.OutletAlphaKey = zz1.OutletAlphaKey
		where
			datediff(D,pt.PostingDate,getdate()) <= 90
		)as aa
	where
		aa.[x] = 1
	)as bb
inner join zz1 on bb.OutletAlphaKey = zz1.OutletAlphaKey

order by
	zz1.LatestOutletKey,
	bb.[Last Posting Date] desc
GO
