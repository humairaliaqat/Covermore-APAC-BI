USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0327]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0327]
  @Country varchar(2),
  @AgencyGroup varchar(5),
  @ReportingPeriod varchar(30),
  @StartDate varchar(10) = null,
  @EndDate varchar(10) = null

/****************************************************************************************************/
--  Name:           rptsp_rpt0327
--  Author:         Leonardus Setyabudi
--  Date Created:   20120522
--  Description:    This stored procedure returns list of Consultant accreditation on specified period
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: Enter Agency Group Code; e.g. MB
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--  
--  Change History: 20120522 - LS - Created
--					20130206 - LT - Changed SELECT statement to dynamic to cater for AAA Agency Groups
--
/****************************************************************************************************/

as
  
set nocount on



--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(5)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @AgencyGroup = 'AAA', @ReportingPeriod = 'Month-To-Date'
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime
declare @WhereAgencyGroup varchar(100)
declare @SQL varchar(8000)

/* get reporting dates */
if @ReportingPeriod = '_User Defined'
	select @rptStartDate = convert(date, @StartDate), @rptEndDate = convert(date, @EndDate)
else
	select @rptStartDate = StartDate, @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @ReportingPeriod

if @AgencyGroup = 'AAA' select @WhereAgencyGroup = 'o.SuperGroupName = ''AAA'''
else select @WhereAgencyGroup = 'o.GroupCode = '''+ @AgencyGroup + ''''

select @SQL = 'select o.GroupName, o.AlphaCode, o.OutletName, u.FirstName, u.LastName, u.Login, u.AccreditationNumber, u.AccreditationDate,
				u.DeclaredDate, u.RefereeName, case when u.ReasonableChecksMade = 1 then ''Yes'' else ''No'' end ChecksMade,
				convert(datetime,''' + convert(varchar(10),@rptStartDate,120) + ''') as StartDate, convert(datetime,''' + convert(varchar(10),@rptEndDate,120) + ''') as EndDate
			  from penUser u inner join penOutlet o on  o.OutletKey = u.OutletKey and o.OutletStatus = ''Current''
			  where UserStatus = ''Current'' and u.Status = ''Active'' and o.CountryKey = ''' + @Country + ''' and
				' + @WhereAgencyGroup + ' and convert(varchar(10),u.AccreditationDate,120) >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and
				convert(varchar(10),u.AccreditationDate,120) <  ''' + convert(varchar(10),dateadd(day, 1, @rptEndDate),120) + '''
			  order by 1, 6'

exec(@SQL)



GO
