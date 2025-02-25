USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0326]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0326]	@Country varchar(3),
									@Company varchar(5),
									@ReportingPeriod varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0326
--	Author:			Linus Tor
--	Date Created:	20120521
--	Description:	This stored procedure returns auto comments where the outlet status has been changed
--
--	Parameters:		@Country: value is AU, NZ, UK or %
--					@Company: value is CM, TIP, or %
--					@ReportingPeriod: value is any standard date range or '_User Defined'
--					@StartDate: Enter user defined start date. Format YYYY-MM-DD eg. 2010-01-01
--					@EndDate: Enter user defined end date. Format YYYY-MM-DD eg. 2010-01-01
--	
--	Change History:	20120521 - LT - Created
--                  20130809 - LS - Case 18834, add group
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(3)
declare @Company varchar(5)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @Company = '%', @ReportingPeriod = '_User Defined', @StartDate = '2012-02-01', @EndDate = '2012-02-29'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod


if object_id('tempdb..#rpt0326_raw') is not null drop table #rpt0326_raw
select
    a.OutletKey,
	a.CountryKey as Country,
	a.CompanyKey as Company,
	a.AlphaCode,
	c.FirstName,
	c.LastName,
	a.CommentDate,
	replace(substring(AutoComments,patindex('%Status changed%',AutoComments),100),'Status changed from ','') as AutoComment
into #rpt0326_raw	
from
	[db-au-cmdwh].dbo.penAutoComment a
	join [db-au-cmdwh].dbo.penCRMUser c on
		a.CSRKey = c.CRMUserKey
where
	a.CountryKey like @Country and
	a.CompanyKey like @Company and
	convert(varchar(10),a.CommentDate,120) between @rptStartDate and @rptEndDate and
	AutoComments like '%status changed from%' and
	(AutoComments like '%stocked%' or
	 AutoComments like '%prospect%' or
	 AutoComments like '%stocks withdrawn%' or
	 AutoComments like '%closed%')



 
if object_id('tempdb..#rpt0326_split') is not null drop table #rpt0326_split
select 
	a.*,
	1 as BeforeChangeStart,
	patindex('% to %',a.AutoComment) as BeforeChangeEnd,
	patindex('% to %',a.AutoComment)+4 as AfterChangeStart,
	patindex('%. %',a.AutoComment) as AfterChangeEnd
into #rpt0326_split	
from #rpt0326_raw a



select 
	a.Country,
	a.Company,
	a.AlphaCode,
	o.GroupName,
	a.FirstName + ' ' + a.LastName as CRMUser,
	a.CommentDate as DateChanged,	
	substring(AutoComment,BeforeChangeStart,BeforeChangeEnd) as BeforeChangeStatus,
	substring(AutoComment,AfterChangeStart,AfterChangeEnd-AfterChangeStart) as AfterChangeStatus,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from 
	#rpt0326_split a
	inner join penOutlet o on
	    o.OutletKey = a.OutletKey and
	    o.OutletStatus = 'Current'
order by 
    a.AlphaCode
	

drop table #rpt0326_raw
drop table #rpt0326_split	
GO
