USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0724]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0724]	@DateReference varchar(50),
									@DateRange varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0724
--  Author:         Linus Tor
--  Date Created:   20151127
--  Description:    This stored procedure outputs TFS PM Product backlog items at point in time
--
--  Parameters:		@DateReference:	Required. One of Created Date, Changed Date, Authorised Date
--					@DateRange:		Required. Standard date range or _User Defined
--					@StartDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--					@EndDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--   
--  Change History: 20151127 - LT - Created
--					20160317 - PW - Added Testing Effort
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateReference varchar(50)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null, @DateReference = 'Created Date'
*/

declare @SQL varchar(8000)
declare @rptStartDate datetime
declare @rptEndDate datetime
declare @WhereDateReference varchar(200)


/* initialise dates */
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate,
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

/* initialise date reference */
if @DateReference = 'Created Date'
	select @WhereDateReference = 'wil.[Created Date] '
else if @DateReference = 'Changed Date'
	select @WhereDateReference = 'wil.[Changed Date] '
else if @DateReference = 'Authorised Date'
	select @WhereDateReference = 'wil.[Authorized Date] '
else
	select @WhereDateReference = 'wil.[Created Date] '		--default if value not supplied


select 
	wil.ID as WorkID, 
	dbo.xfn_ConvertUTCToLocal(wil.[Created Date],'AUS Eastern Standard Time') as CreatedDate, 
	dbo.xfn_ConvertUTCToLocal(wil.[Changed Date],'AUS Eastern Standard Time') as ChangedDate,	
	dbo.xfn_ConvertUTCToLocal(wil.[Authorized Date],'AUS Eastern Standard Time') as AuthorizedDate,
	wil.[State], 
	wil.[Reason], 
	wil.[Fld10084] Priority, 
	wil.Title as Title, 
	wil.[Work Item Type] as WorkItemType, 
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
	wil.[Fld10079] as TestingEffort,
	wil.[Fld10031] as EstimateDev,
	wil.[Fld10071] as EstimateBI,
	wil.[Fld10076] as EstimateTest,
	wil.[Fld10077] as EstimateBA,
	wil.[Fld10114] as EstimateExternal,
	wil.[Fld10056] as Activity , 
	wil.[Fld10078] as [Type], 
	wil.[Fld10072] as Requestor,
	wil.[Fld10083] as [Owner], 
	wil.[Fld10065] as [Category],
	wil.[Fld10081] as [BusinessPriority], 
	wil.[Fld10082] as [BA],
	@DateReference as DateReference,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate 
from 
	[bhtfs01].tfs_covermore.dbo.WorkItemsLatest wil
	outer apply			--get Area details
	(select top 1 [Node Name] as NodeName, [Node Type] as NodeType, [Area Path] as AreaPath, [Team Project] as TeamProject
		from [bhtfs01].tfs_covermore.dbo.xxTree
		where ID = wil.AreaID
	) Area
	outer apply			--get Iteration details
	(select top 1 [Node Name] as IterationName, [Iteration Path] as IterationPath
		from [bhtfs01].tfs_covermore.dbo.xxTree
		where ID = wil.IterationID
	) Iteration
	outer apply			--get CreatedBy user
	(select top 1 DisplayPart as [Name]
		from [bhtfs01].tfs_covermore.dbo.Constants
		where ConstID = wil.Fld33_Normalized
	) CreatedBy
	outer apply			--get AssignedTo user
	(select top 1 DisplayPart as [Name]
		from [bhtfs01].tfs_covermore.dbo.Constants
		where ConstID = wil.Fld24_Normalized
	) AssignedTo
	outer apply			--get ChangedBy user
	(select top 1 DisplayPart as [Name]
		from [bhtfs01].tfs_covermore.dbo.Constants
		where ConstID = wil.Fld9_Normalized
	) ChangedBy
	outer apply			--get BI tags
	(select tags.*
		from
		(select
			row_number() over (partition by convert(int,pv.ArtifactID) order by pv.ChangedDate desc) Idx, 
			td.Name as TagName, 
			convert(int,pv.ArtifactId) as WorkItemId, 
			pv.ChangedDate,
			pv.IntValue
		from [bhtfs01].tfs_covermore.dbo.tbl_TagDefinition td
			inner join [bhtfs01].tfs_covermore.dbo.tbl_PropertyDefinition pd on
				pd.Name = 'Microsoft.TeamFoundation.Tagging.TagDefinition.' + convert(nvarchar(255),td.TagId)
			inner join [bhtfs01].tfs_covermore.dbo.tbl_PropertyValue pv ON 
				pv.PropertyId = pd.PropertyId
		where td.Name = 'BI'
		) tags  
		where tags.WorkItemId = wil.ID and 
			tags.Idx = 1 and
			tags.IntValue = 0
		) tag
	where
	(
		(
			case when @DateReference = 'Created Date' then wil.[Created Date] 
				 when @DateReference = 'Changed Date' then wil.[Changed Date]
				 when @DateReference = 'Authorised Date' then wil.[Authorized Date]
				 else wil.[Created Date]
			end
		) between convert(varchar(20),dbo.xfn_ConvertLocalToUTC(@rptStartDate,'AUS Eastern Standard Time'),120) and convert(varchar(20),dbo.xfn_ConvertLocalToUTC(@rptEndDate,'AUS Eastern Standard Time'),120)
	)





GO
