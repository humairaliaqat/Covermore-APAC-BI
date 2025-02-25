USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0687]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0687]

@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)

as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0687
--  Author:         Linus Tor
--  Date Created:   20150930
--  Description:    This stored procedure returns TFS PM Product Backlog outstanding work items
--  Parameters:     
--   
--  Change History: 20150930 - LT - Created
--
/****************************************************************************************************/

--exec [rptsp_rpt0687] '_User Defined', '2015-10-01', '2015-10-31'


--DECLARE
--@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)

declare @rptStartDate datetime
declare @rptEndDate datetime

--SET @DateRange = '_User Defined'
--SET @StartDate = '2016-01-01'
--SET @EndDate = '2016-01-01'

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
		m.ID as WorkID,
		m.[Created Date] as CreatedDate,
		m.[Changed Date] as ChangedDate,
		m.[Authorized Date] as AuthorizedDate,
		m.[State],
		m.[Reason],	
		m.[Fld10084],
		m.Title as Title,
		m.[Work Item Type] as WorkItemType,
		m.[Fld10104],
		m.[Fld10020],
		m.[Fld10056],
		m.[Fld10078],
		m.[Fld10072],
		m.[Fld10083],
		m.[Fld10065],
		m.[Fld10081],
		m.[Fld10082],
		m.AreaID,
		m.IterationID,
		m.Fld33_Normalized,
		m.Fld24_Normalized,
		m.Fld9_Normalized,
		m.Rev


	from
		(
			select x.*
			from
				(
				select *
				from [bhtfs01].tfs_covermore.dbo.WorkItemsWere
				union
				select *
				from [bhtfs01].tfs_covermore.dbo.WorkItemsLatest
				) x
			inner join
				(
					select id, max([Changed Date]) max_ChangedDate, min([Changed Date]) min_ChangedDate
					from
						(
						select id, [Changed Date], state from [bhtfs01].tfs_covermore.dbo.WorkItemsWere
						where 
							--id in (13747) and
							[Work Item Type] = 'PM Product Backlog Item'
							and [State] not in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
							and
							(convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= @rptEndDate
							OR
							convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112)
								between convert(varchar, @rptStartDate, 112) and convert(varchar, @rptEndDate, 112)
							)
							and Id not in
								(
								select distinct Id
								from [bhtfs01].tfs_covermore.dbo.WorkItemsWere
								where
									[Work Item Type] = 'PM Product Backlog Item'
									and [State] in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
									and convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= convert(varchar, @rptEndDate, 112)
								union
								select distinct Id
								from [bhtfs01].tfs_covermore.dbo.WorkItemslatest
								where
									[Work Item Type] = 'PM Product Backlog Item'
									and [State] in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
									and convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= convert(varchar, @rptEndDate, 112)
								)

						Union
						select id, [Changed Date], state from [bhtfs01].tfs_covermore.dbo.WorkItemsLatest
						where 
							--id in (13747) and
							[Work Item Type] = 'PM Product Backlog Item'
							and [State] not in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
							and
							(convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= @rptEndDate
							OR
							convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112)
								between convert(varchar, @rptStartDate, 112) and convert(varchar, @rptEndDate, 112)
							and Id not in
								(
								select distinct Id from [bhtfs01].tfs_covermore.dbo.WorkItemsWere
								where
									[Work Item Type] = 'PM Product Backlog Item'
									and [State] in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
									and convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= convert(varchar, @rptEndDate, 112)
								union
								select distinct Id
								from [bhtfs01].tfs_covermore.dbo.WorkItemslatest
								where
									[Work Item Type] = 'PM Product Backlog Item'
									and [State] in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
									and convert(varchar, dbo.xfn_ConvertUTCToLocal([Changed Date],'AUS Eastern Standard Time'), 112) <= convert(varchar, @rptEndDate, 112)
								)
							)
						) x
					group by id
				) y
			on x.id = y.id
				and x.[Changed Date] = y.max_ChangedDate
		) m

	)

select
	a.WorkID,
	a.CreatedDate,
	a.ChangedDate,
	a.AuthorizedDate,
	a.[State],
	a.[Reason],	
	a.Priority,
	a.Title,
	a.WorkItemType,
	a.NodeName,
	a.NodeType,
	a.AreaPath,
	a.TeamProject,
	a.IterationName,
	a.IterationPath,
	a.CreatedBy,
	a.AssignedTo,
	a.ChangedBy,
	a.TagName,
	a.Effort,
	a.RemainingEffort,
	a.Activity ,
	a.[Type],
	a.Requestor ,
	a.[Owner],
	a.[Category],
	a.[BusinessPriority],
	a.[BA],
	a.RelatedWorkID,
	a.RelatedCreatedDate,
	a.RelatedChangedDate,
	a.RelatedAuthorizedDate,
	a.RelatedState,
	a.RelatedReason,
	a.RelatedTitle,
	a.RelatedWorkItemType,
	@rptStartDate rptStartDate, 
	@rptEndDate rptEndDate
from
(
	select 
		wil.WorkID as WorkID,
		wil.CreatedDate as CreatedDate,
		wil.ChangedDate as ChangedDate,
		wil.AuthorizedDate as AuthorizedDate,
		wil.[State],
		wil.[Reason],	
		wil.[Fld10084] Priority,
		wil.Title as Title,
		wil.WorkItemType as WorkItemType,
		Area.NodeName,
		Area.NodeType,
		Area.AreaPath,
		Area.TeamProject,
		Iteration.IterationName,
		Iteration.IterationPath,
		createdBy.[Name] as CreatedBy,
		AssignedTo.[Name] as AssignedTo,
		ChangedBy.[Name] as ChangedBy,
		tag.TagName,
		wil.[Fld10104] as Effort,
		wil.[Fld10020] as RemainingEffort,
		wil.[Fld10056] as Activity ,
		wil.[Fld10078] as [Type],
		wil.[Fld10072] as Requestor ,
		wil.[Fld10083] as [Owner],
		wil.[Fld10065] as [Category],
		wil.[Fld10081] as [BusinessPriority],
		wil.[Fld10082] as [BA],
		related.RelatedWorkID,
		related.RelatedCreatedDate,
		related.RelatedChangedDate,
		related.RelatedAuthorizedDate,
		related.RelatedState,
		related.RelatedReason,
		related.RelatedTitle,
		related.RelatedWorkItemType
	from
		cte_workhistory wil
		outer apply			--get Area details
		(
			select top 1 [Node Name] as NodeName, [Node Type] as NodeType, [Area Path] as AreaPath, [Team Project] as TeamProject
			from [bhtfs01].tfs_covermore.dbo.xxTree
			where ID = wil.AreaID
		) Area
		outer apply			--get Iteration details
		(
			select top 1 [Node Name] as IterationName, [Iteration Path] as IterationPath
			from [bhtfs01].tfs_covermore.dbo.xxTree
			where ID = wil.IterationID
		) Iteration
		outer apply			--get CreatedBy user
		(
			select top 1 DisplayPart as [Name]
			from [bhtfs01].tfs_covermore.dbo.Constants
			where ConstID = wil.Fld33_Normalized
		) CreatedBy
		outer apply			--get AssignedTo user
		(
			select top 1 DisplayPart as [Name]
			from [bhtfs01].tfs_covermore.dbo.Constants
			where ConstID = wil.Fld24_Normalized
		) AssignedTo
		outer apply			--get ChangedBy user
		(
			select top 1 DisplayPart as [Name]
			from [bhtfs01].tfs_covermore.dbo.Constants
			where ConstID = wil.Fld9_Normalized
		) ChangedBy
		outer apply			--get related tasks
		(
			select distinct
				wl.workid as RelatedWorkID,
				wl.[CreatedDate] as RelatedCreatedDate,
				wl.[ChangedDate] as RelatedChangedDate,
				wl.[AuthorizedDate] as RelatedAuthorizedDate,
				wl.[State] RelatedState,
				wl.[Reason] RelatedReason,
				wl.Title RelatedTitle,
				wl.[WorkItemType] as RelatedWorkItemType
			from
				[bhtfs01].tfs_covermore.dbo.LinksLatest ll
				join  cte_workhistory wl on ll.TargetID = wl.workid
			where
				ll.SourceID = wil.workID
		) related
		outer apply			--get BI tags
		(
			select tags.*
			from
			(
				select
					row_number() over (partition by convert(int,pv.ArtifactID) order by pv.ChangedDate desc) Idx, 
					td.Name as TagName, 
					convert(int,pv.ArtifactId) as WorkItemId, 
					pv.ChangedDate,
					pv.IntValue
				from
					[bhtfs01].tfs_covermore.dbo.tbl_TagDefinition td
					inner join [bhtfs01].tfs_covermore.dbo.tbl_PropertyDefinition pd on
						pd.Name = 'Microsoft.TeamFoundation.Tagging.TagDefinition.' + convert(nvarchar(255),td.TagId)
					inner join [bhtfs01].tfs_covermore.dbo.tbl_PropertyValue pv ON 
						pv.PropertyId = pd.PropertyId
				where
					td.Name = 'BI'
			  ) tags  
			  where 
				tags.WorkItemId = wil.WorkID and 
				tags.Idx = 1 and
				tags.IntValue = 0
		) tag
	where
		wil.WorkItemType = 'PM Product Backlog Item' and
		wil.[State] not in ('Done','Cancelled','Not Approved','Deferred','Deleted','Not Approved/Deferred')
		--and wil.workid in ( 13747)
) a
GO
