USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0729]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0729]

	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
	
as

--exec [rptsp_rpt0729] '_User Defined', '2013-01-01', '2015-12-31'
/****************************************************************************************************/
--  Name:           rptsp_rpt0729
--  Author:         Ganesh Parab
--  Date Created:   20151218
--  Description:    This stored procedure outputs PM backlog report that covers the change date from one 
--					TFS status to another which is currently available in TFS history section with the
--					other rest of the details
--
--  Change History: 20151214 - GP - Created   
--  Change History: 20151218 - GP - Modified - Added Extra Columns
--  Change History: 20160118 - GP - Calculate and display the elapsed time from the last status to current date if the status is not “Done”
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate,
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange;

with cte_workhistory as

	(
	
	select
		y.ID,
		Title,
		y.[Changed Date],	
		y.State,
		case when PreviousID<>y.ID then 'Not Available' else PreviousState end [PreviousState],
		PreviousID,
		(case when PreviousID<>y.ID then NULL else LAG(y.[Changed Date], 1,0) OVER (ORDER BY y.ID) end) [Previous Changed Date],
		LEAD(y.[ID], 1, 0) OVER (order by y.ID) NextID, Rev, rank_s
		--case when State = (LAG([PreviousState], 1, 0) OVER (order by ID,dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time')))
		--	then '2099-01-01' else [Changed Date] end test
	--select *

	from
		(
			select
				ID,
				Title,
				[Changed Date],
				State,
				LAG([State], 1, 0) OVER (order by ID,dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time')) [PreviousState],
				LAG([ID], 1, 0) OVER (order by ID,dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time')) [PreviousID], Rev
			from
			(
				select
					ID,
					Title,
					dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time') as [Changed Date],
					State, Rev
				from [bhtfs01].tfs_covermore.dbo.WorkItemsWere wiw	
				where	
					[Work Item Type] in ('PM Product Backlog Item') --and ID = 9288
					and [Changed Date] between @rptStartDate and @rptEndDate
					--and ID = 15139
				union
				select
					ID,
					Title,
					dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time') as [Changed Date],
					State, Rev
				from [bhtfs01].tfs_covermore.dbo.WorkItemsLatest wil	
				where	
					[Work Item Type] in ('PM Product Backlog Item')
					and [Changed Date] between @rptStartDate and @rptEndDate
					--and ID = 15139
			) x
		) y
	left outer join
		(
			select f.ID, min([Changed Date]) [Changed Date], State, dense_rank() over (partition by id order by min([Changed Date])) rank_s
			from 
				(
				select
					ID,
					dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time') as [Changed Date],
					State
				from [bhtfs01].tfs_covermore.dbo.WorkItemsWere wiw	
				where	
					[Work Item Type] in ('PM Product Backlog Item') --and ID = 9288
					and [Changed Date] between @rptStartDate and @rptEndDate
					--and ID = 15139
				union
				select
					ID,
					dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time') as [Changed Date],
					State
				from [bhtfs01].tfs_covermore.dbo.WorkItemsLatest wil	
				where	
					[Work Item Type] in ('PM Product Backlog Item')
					and [Changed Date] between @rptStartDate and @rptEndDate
				) f
			group by ID, State
		) t
	on t.ID = y.ID
		and t.State = y.State
	where 
		y.state <> (case when PreviousID<>y.ID then 'Not Available' else PreviousState end)
	) 

select
	x.ID,
	Title,
	[Changed Date] ChangedDate,	
	State,
	[Max Changed Date] [PreviousChangedDate],
	[PreviousState],
	rank_s PreviousID,
	--case when Id <> NextID then null else [Duration in current Status] end [DurationincurrentStatus],
	case when (x.Id <> NextID and State = 'Done') then null
		when (x.Id <> NextID and State <> 'Done') then datediff(DD,[Changed Date],getdate())
		else [Duration in current Status] end [DurationincurrentStatus],
	[Rank State] [RankState],
	[Created Date] [CreatedDate],
	[Revised Date] [RevisedDate],
	[Category],
	[Project Requester] [ProjectRequester],
	[P&L Owner] [PnLOwner],
	[Business Priority] [BusinessPriority],
	[Created By] [CreatedBy],
	[Assigned To] [AssignedTo],
	[Changed By] [ChangedBy],

	NodeName,
	Current_Title NodeType,
	AreaPath,
	TeamProject,

	IterationName,
	--IterationPath,
	[Current Status] IterationPath,
	
	[Delivery Sequence] [DeliverySequence],
	[BA],

	[Remaining Estimate] [RemainingEstimate],
	[Estimate (Dev)] [EstimateDev],
	[Estimate (Test)] [EstimateTest],		-- EMC - Locking Down EMC Assessment Numbers e.g.
	[Estimate (BI)] [EstimateBI],
	[Estimate (BA)] [EstimateBA],
	[Estimate (External)] [EstimateExternal],	-- PM Product Backlog Item 14953:Price Change Flight Centre (NZ) e.g.
	[Project Cost] [ProjectCost],
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate 
from
	(
	select cte.ID,
		cte.Title,
		cte.[Changed Date],	
		cte.State,
		[Previous Changed Date],
		[PreviousState],
		PreviousID,
		LEAD(
			(case 
			when PreviousState='Not Available' 
			then 1
			when convert(date, [Previous Changed Date]) = convert(date, cte.[Changed Date])
			then 1
			else isnull(datediff(DD,cte.[Previous Changed Date],cte.[Changed Date]),0)end), 1, 0) OVER (order by cte.ID, cte.[Changed Date]) [Duration in current Status],
			
		row_number() over (partition by cte.id order by cte.[Changed Date]) [Rank State],
		dense_rank() over (partition by cte.id order by cte.state) [Rank State1],
		NextID,
		rank_s,
		cte.Rev,
		res.[Created Date],
		res.[Revised Date],
		res.[Category],
		res.[Project Requester],
		res.[P&L Owner],
		res.[Business Priority],
		res.[Created By],
		res.[Assigned To],
		res.[Changed By],

		res.NodeName,
		res.NodeType,
		res.AreaPath,
		res.TeamProject,

		res.IterationName,
		res.IterationPath,
		 
		res.[Delivery Sequence],
		res.[BA],
		res.[Current Status],

		res.[Remaining Estimate],
		res.[Estimate (Dev)],
		res.[Estimate (Test)],		-- EMC - Locking Down EMC Assessment Numbers e.g.
		[Estimate (BI)],
		res.[Estimate (BA)],
		res.[Estimate (External)],	-- PM Product Backlog Item 14953:Price Change Flight Centre (NZ) e.g.
		res.[Project Cost],
		res.[Title] Current_Title
	from cte_workhistory cte
	inner join
		(
			select
				wil.ID,
				wil.Title,
				wil.[Work Item Type],
				wil.[Created Date],
				wil.[Revised Date],
				wil.[Changed Date],
				wil.[Category],
				wil.[Project Requester],
				wil.[P&L Owner],
				wil.[Business Priority],
				cb.DisplayPart as [Created By],
				at.DisplayPart as [Assigned To],
				chb.DisplayPart as [Changed By],

				ar.[Node Name] as NodeName,
				ar.[Node Type] as NodeType,
				ar.[Area Path] as AreaPath,
				ar.[Team Project] as TeamProject,

				it.[Node Name] as IterationName,
				it.[Iteration Path] as IterationPath,
				 
				wil.[Delivery Sequence],
				wil.[BA],
				wil.[Current Status],

				wil.[Remaining Estimate],
				wil.[Estimate (Dev)],
				wil.[Estimate (Test)],		-- EMC - Locking Down EMC Assessment Numbers e.g.
				[Estimate (BI)],
				wil.[Estimate (BA)],
				wil.[Estimate (External)],	-- PM Product Backlog Item 14953:Price Change Flight Centre (NZ) e.g.
				wil.[Project Cost],
				rev

		from
			(
				--select 
				--	ID,
				--	max(Title) Title,
				--	max([Work Item Type]) [Work Item Type],
				--	max(dbo.xfn_ConvertUTCToLocal([Created Date],'AUS Eastern Standard Time')) as [Created Date],
				--	max(dbo.xfn_ConvertUTCToLocal([Revised Date],'AUS Eastern Standard Time')) as [Revised Date],
				--	max(dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time')) as [Changed Date],
				--	max(Fld10065) [Category],
				--	max(Fld10072) [Project Requester],
				--	max(Fld10083) [P&L Owner],
				--	max(Fld10081) [Business Priority],
				--	max(Fld10119) [Delivery Sequence],
				--	max(Fld10082) [BA],
				--	max([State]) [Current Status],
				--	max(AreaID) AreaID,
				--	max(IterationID) IterationID,
				--	max(Fld33_Normalized) Fld33_Normalized,
				--	max(Fld24_Normalized) Fld24_Normalized,
				--	max(Fld9_Normalized) Fld9_Normalized,
				--	max(Fld10166) [Remaining Estimate],
				--	max(Fld10031) [Estimate (Dev)],
				--	max(Fld10076) [Estimate (Test)],		
				--	max(Fld10071) [Estimate (BI)],
				--	max(Fld10077) [Estimate (BA)],
				--	max(Fld10114) [Estimate (External)],
				--	max(Fld10070) [Project Cost],
				--	max(rev) rev
				--from [bhtfs01].tfs_covermore.dbo.WorkItemswere
				--where
				--	[Work Item Type] in ('PM Product Backlog Item')
				--		--and ID = 15139
				--group by ID
				--Union
				select 
					ID,
					max(Title) Title,
					max([Work Item Type]) [Work Item Type],
					max(dbo.xfn_ConvertUTCToLocal([Created Date],'AUS Eastern Standard Time')) as [Created Date],
					max(dbo.xfn_ConvertUTCToLocal([Revised Date],'AUS Eastern Standard Time')) as [Revised Date],
					max(dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time')) as [Changed Date],
					max(Fld10065) [Category],
					max(Fld10072) [Project Requester],
					max(Fld10083) [P&L Owner],
					max(Fld10081) [Business Priority],
					max(Fld10119) [Delivery Sequence],
					max(Fld10082) [BA],
					max([State]) [Current Status],
					max(AreaID) AreaID,
					max(IterationID) IterationID,
					max(Fld33_Normalized) Fld33_Normalized,
					max(Fld24_Normalized) Fld24_Normalized,
					max(Fld9_Normalized) Fld9_Normalized,
					max(Fld10166) [Remaining Estimate],
					max(Fld10031) [Estimate (Dev)],
					max(Fld10076) [Estimate (Test)],		
					max(Fld10071) [Estimate (BI)],
					max(Fld10077) [Estimate (BA)],
					max(Fld10114) [Estimate (External)],
					max(Fld10070) [Project Cost],
					max(rev) rev
				from [bhtfs01].tfs_covermore.dbo.WorkItemslatest
				where
					[Work Item Type] in ('PM Product Backlog Item')
					and [Changed Date] between @rptStartDate and @rptEndDate
				group by ID
			) wil
			
				left outer join [bhtfs01].tfs_covermore.dbo.xxTree ar
					on ar.ID = wil.AreaID
				left outer join [bhtfs01].tfs_covermore.dbo.xxTree it
					on it.ID = wil.IterationID
				left outer join [bhtfs01].tfs_covermore.dbo.Constants cb
					on cb.ConstID = wil.Fld33_Normalized
				left outer join [bhtfs01].tfs_covermore.dbo.Constants at
					on at.ConstID = wil.Fld24_Normalized
				left outer join [bhtfs01].tfs_covermore.dbo.Constants chb
					on chb.ConstID = wil.Fld9_Normalized
			) res
		on cte.id = res.id
			--and cte.rev = res.rev
	
	) x
inner join
	(
	select ID, max([Changed Date]) [Max Changed Date]
	from cte_workhistory
	group by ID
	) a
on x.id = a.id
--where x.ID = 9865
order by
	x.ID,
	[Changed Date];
GO
