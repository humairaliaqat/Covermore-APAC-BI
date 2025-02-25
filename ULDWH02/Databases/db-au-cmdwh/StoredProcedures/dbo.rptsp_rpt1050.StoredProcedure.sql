USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1050]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1050]	@User varchar(200),
								@DateRange varchar(30),
								@StartDate datetime,
								@EndDate datetime
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt1050
--	Author:			Linus Tor
--	Date Created:	20190218
--	Description:	This stored procedure returns jabber history by user and date range
--
--	Parameters:		@User:		jabber user message sent to and from. format: xxxx.xxxx@covermore.com
--					@DateRange: default date range or '_User Defined'
--					@StartDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--					@EndDate:	if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--	
--	Change History:	20110811 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @User varchar(200)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @User = 'linus.tor', @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @SQL varchar(8000)

/* get reporting dates */
if @DateRange = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @DateRange

select @User = @User + '%'


select distinct
	tou.ToJID as ToUser,
	fromu.FromJID as FromUser,
	convert(varchar(19),j.SentDate,120) as SentDate,
	j.BodyString,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	usrJabberHistory j
	cross apply
	(
		select item as ToJID
		from dbo.fn_DelimitedSplit8K(j.ToJID,'/')	
		where itemNumber = 1		
	) tou
	cross apply
	(
		select Item as FromJID
		from dbo.fn_DelimitedSplit8K(j.FromJID,'/')
		where ItemNumber = 1
	) fromu
where
	(
		j.ToJID like @User or
		j.FromJID like @User
	) and
	(
		j.SentDate >= @rptStartDate and
		j.SentDate < dateadd(d,1,@rptEndDate)
	) and
	j.BodyString > ''
order by convert(varchar(19),j.SentDate,120)

GO
