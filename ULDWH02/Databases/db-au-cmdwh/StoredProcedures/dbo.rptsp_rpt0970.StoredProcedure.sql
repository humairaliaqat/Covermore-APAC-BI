USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0970]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0970]	@Country varchar(3),
									@SuperGroup varchar(100),
									@BDM varchar(100)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0970
--  Author:         Linus Tor
--  Date Created:   20180202
--  Description:    This stored procedure returns personal best sales for store and consultant 
--
--  Parameters:     @Country: Required. Valid country code (AU, NZ, UK etc..)
--					@SuperGroup: Required. Valid super group name
--					@BDM: Optional. Valid BDM name
--   
--  Change History: 20180202 - LT - Created
--					20180718 - YY -	For Store Best Sales: All outlets with previous alpha will be summarised to their latest outlet
--								  - For Consultant Best Sales: It will show consultant’s best sales for all stores he/she has been working 	
--                  20200108 - HL - REQ-3081. Added condition to select only ACTIVE status Users
/****************************************************************************************************/

--uncomment to debug
--/*
--declare @Country varchar(3)
--declare @SuperGroup varchar(100)
--declare @BDM varchar(100)
--select @Country = 'AU', @SuperGroup = 'Flight Centre', @BDM = null
--*/

declare @rptStartDate datetime
declare @rptEndDate datetime

select @rptStartDate = '2012-07-01',															--start of Penguin
	   @rptEndDate = dateadd(d,-1,convert(datetime,convert(varchar(8),getdate(),120)+'01'))		--last day of previous month

-- Get the latest store for each consultant
IF OBJECT_ID('tempdb..#temp_ls', 'U') IS NOT NULL 
  DROP TABLE #temp_ls;
  
with cte_ls 
as
(
select  
o1.FCNation, o1.FCArea, o1.AlphaCode, o1.OutletName, o1.BDMName, o1.SubGroupName,
u1.OutletAlphaKey, firstname, lastname, UserStatus ,UserID,
row_number() over(partition by u1.FirstName + ' ' + u1.LastName
		  order by u1.UserID desc) rn
from penUser  as u1
inner join penOutlet as o1 on (u1.OutletAlphaKey = o1.OutletAlphaKey) and o1.OutletStatus = 'Current'
where	u1.userStatus = 'Current' and 
        u1.Status = 'Active' and                                                             -- Added condition to select only ACTIVE status Users
		o1.CountryKey = @Country and
		o1.SuperGroupName = @SuperGroup and
		(
			isnull(@BDM, 'All') = 'All' or
			o1.BDMName = @BDM
		)
)
select * 
into 
	#temp_ls 
from 
	cte_ls 
where 
	rn = 1


;with cte_sales
as
(
select
		'Store' as PersonalBest,
		--o.LatestOutletKey,
		lo.BDMName,
		lo.FCNation as [Nation],
		lo.FCArea as [Area],
		lo.AlphaCode,
		lo.OutletName,
		lo.SubGroupName,
		NULL as Consultant,
		convert(datetime,convert(varchar(8),pts.IssueDate,120)+'01') as [Month],
		sum(pts.GrossPremium) as SellPrice,
		sum(pts.NewPolicyCount) as PolicyCount,
		row_number() over(partition by o.LatestOutletKey order by sum(pts.GrossPremium) desc) rn
	from
		penPolicyTransSummary pts
		inner join penOutlet o on pts.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
		outer apply 
			(select top 1 
			FCNation, FCArea, AlphaCode, OutletName, BDMName, SubGroupName
			from penOutlet as o1 
			where o1.LatestOutletKey = o.LatestOutletKey
			order by OutletSKey desc
			) lo		-- Latest store for the same LatestOutletKey
	where
		o.CountryKey = @Country and
		o.SuperGroupName = @SuperGroup and
		(
			isnull(@BDM, 'All') = 'All' or 
			o.BDMName = @BDM
		) and
		pts.PostingDate >= @rptStartDate and
		pts.PostingDate < dateadd(d,1,@rptEndDate)
		
	group by
		o.LatestOutletKey,
		lo.BDMName,
		lo.FCNation,
		lo.FCArea,
		lo.AlphaCode,
		lo.OutletName,
		lo.SubGroupName,
		convert(datetime,convert(varchar(8),pts.IssueDate,120)+'01') 
	union all

	select
		'Consultant' as PersonalBest,
		ls.BDMName,
		ls.FCNation as [Nation],
		ls.FCArea as [Area],
		ls.AlphaCode,
		ls.OutletName,
		ls.SubGroupName,
		u.FirstName + ' ' + u.LastName as Consultant,
		convert(datetime,convert(varchar(8),pts.IssueDate,120)+'01') as [Month],
		sum(pts.GrossPremium) as SellPrice,
		sum(pts.NewPolicyCount) as PolicyCount,
		row_number() over(partition by u.FirstName + ' ' + u.LastName  order by sum(pts.GrossPremium) desc) rn
	from
		penPolicyTransSummary as pts
		inner join penOutlet as o on pts.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
		inner join penUser as u on pts.UserKey = u.UserKey and u.UserStatus = 'Current'
		inner join #temp_ls as ls on u.FirstName = ls.FirstName and u.LastName = ls.LastName
		
	where
		o.CountryKey = @Country and
		o.SuperGroupName = @SuperGroup and
		(
			isnull(@BDM, 'All') = 'All' or
			o.BDMName = @BDM
		) and
		pts.PostingDate >= @rptStartDate and
		pts.PostingDate < dateadd(d,1,@rptEndDate)

	group by
		ls.BDMName,
		ls.FCNation,
		ls.FCArea,
		ls.AlphaCode,
		ls.OutletName,
		ls.SubGroupName,
		u.FirstName + ' ' + u.LastName,
		convert(datetime,convert(varchar(8),pts.IssueDate,120)+'01')
)


select
	cte.PersonalBest,
	cte.BDMName,
	cte.Nation,
	cte.Area,
	cte.AlphaCode,
	cte.OutletName,
	cte.SubGroupName,
	cte.Consultant,
	cte.[Month],
	cte.SellPrice,
	cte.PolicyCount,
	@Country as Country,
	@SuperGroup as SuperGroup,
	@BDM as BDM,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from
	cte_sales cte
where
	cte.rn = 1
order by
	cte.PersonalBest desc,
	cte.BDMName,
	cte.Nation,
	cte.Area,
	cte.AlphaCode,
	cte.OutletName,
	cte.SubGroupName,
	cte.Consultant,
	cte.[Month],
	cte.SellPrice







GO
