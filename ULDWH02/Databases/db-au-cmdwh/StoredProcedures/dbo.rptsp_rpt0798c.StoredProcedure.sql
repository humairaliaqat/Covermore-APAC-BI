USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0798c]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0798c]	@DateRange varchar(30),
					@StartDate datetime,
					@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:		dbo.rptsp_rpt0798c
--	Author:		Saurabh Date
--	Date Created:	20160928
--	Description:	This stored procedure returns call type visit count details across state and BDM
--	Parameters:	@DateRange: standard date range or _User Defined
--			@StartDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--			@EndDate: valid date value. Format: YYYY-MM-DD (eg. 2016-06-01)
--	
--	Change History:	20160928 - SD - Created
--			20161010 - SD - included Call category
--			20161028 - LT - Changed AccountID linkage to AgencyID linkage. AgencyID is the correct linkage to use.
--	
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/


declare @rptStartDateCY datetime
declare @rptEndDateCY datetime


/* get reporting dates */
if @DateRange = '_User Defined'
begin
    select 
        @rptStartDateCY = convert(smalldatetime,@StartDate),
        @rptEndDateCY = convert(smalldatetime,@EndDate)
end            
else
    select 
        @rptStartDateCY = StartDate, 
        @rptEndDateCY = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange



;with cte_salescall									--get all sales calls in selected date range
as
(
	select *	
	from sfAgencyCall
	where
		CallStartTime >= @rptStartDateCY and
		CallStartTime < dateadd(day,1,@rptEndDateCY) and
		left(AgencyID,2) = 'AU'	
) 


select
	left(a.AgencyID,2) as Country,
	a.AgencyID,
	a.AccountID,
	isnull(o.BDMName,a.BDMName) as BDMName,
	o.JV,
	o.SuperGroupName,
	a.GroupName,
	a.SubGroupName,
	a.AlphaCode,
	o.OutletAlphaKey,
	o.CommencementDate,
	a.TradingStatus,
	a.OutletName,
	o.Branch,
	o.Suburb,
	o.Postcode,
	o.[State],
	case when o.State in ('NSW','ACT') then 'NSW/ACT'
		 when o.State in ('SA','NT') then 'SA/NT'
		 when o.State in ('VIC','TAS') then 'VIC/TAS'
		 else o.State
	end as StateCombined,
	o.Phone,
	o.Email,
	isnull(a.Quadrant,'UNKNOWN') as Quadrant,
	lastcall.CallCategory,
	lastcall.CallSubCategory,
	lastcall.CallDuration,
	lastcall.CallComment,
	VisitCount.VisitCount
From
	sfAccount a
	outer apply								--get number of visits
	(
		select count(distinct CallNumber) as VisitCount
		from
			cte_salescall
		where
			AgencyID = a.AgencyID and
			CallStartTime >= @rptStartDateCY and
			CallStartTime < dateadd(day,1,@rptEndDateCY) 
	) VisitCount
	outer apply							--get additional agency details
	(
		select top 1
			lo.OutletAlphaKey,
			lo.CommencementDate,
			lo.Branch,
			lo.ContactSuburb as Suburb,
			lo.ContactPostCode as Postcode,
			case lo.StateSalesArea 
				when 'New South Wales' then 'NSW' 
				when 'Victoria' then 'VIC'
				when 'Western Australia' then 'WA'
				when 'Queensland' then 'QLD'
				when 'South Australia' then 'SA'
				when 'Northern Territory' then 'NT'
				when 'Tasmania' then 'TAS'
				when 'Australian Capital Territory' then 'ACT'
				else lo.StateSalesArea
			end as [State],
			lo.ContactPhone as Phone,
			lo.ContactEmail as Email,			
			lo.LatestBDMName as BDMName,
			lo.SuperGroupName,
			lo.JVDesc as JV
		from 
			[db-au-star].dbo.dimOutlet co
			inner join [db-au-star].dbo.dimOutlet lo on co.LatestOutletSK = lo.LatestOutletSK
		where 
			lo.AlphaCode = a.AlphaCode and
			lo.Country = left(a.AgencyID,2) and
			lo.TradingStatus = 'Stocked'
	) o
	outer apply								---get the latest call in period
	(
		select top 1
			cal.CallCategory,
			cal.CallSubCategory,
			cal.CallDuration,
			cal.CallComment
		from
			cte_salescall cal
		where
		    cal.AgencyID = a.AgencyID and		
			cal.CallStartTime >= @rptStartDateCY and
			cal.CallStartTime < dateadd(day,1,@rptEndDateCY) and
			cal.CallNumber = (select max(CallNumber)
							  from cte_salescall
							  where AgencyID = cal.AgencyID)
	) lastcall
where
	left(a.AgencyID,2) = 'AU' and
	a.TradingStatus in ('Stocked','Prospect') and
	a.OutletType = 'B2B' and
	o.SuperGroupName in ('Independents','Flight Centre','Helloworld')

GO
