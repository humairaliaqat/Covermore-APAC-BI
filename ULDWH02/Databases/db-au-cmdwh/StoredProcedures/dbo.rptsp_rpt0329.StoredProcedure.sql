USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0329]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0329]	
    @Country varchar(3),
    @Company varchar(5) = '%',
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
    
as
begin




/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0329
--	Author:			Linus Tor
--	Date Created:	20120601
--	Description:	This stored procedure returns consultant list where last modified date is in 
--					the reporting period.
--
--	Parameters:		@Country: value is AU, NZ, UK or %
--					@Company: value is CM, TIP, or %
--					@ReportingPeriod: value is any standard date range or '_User Defined'
--					@StartDate: Enter user defined start date. Format YYYY-MM-DD eg. 2010-01-01
--					@EndDate: Enter user defined end date. Format YYYY-MM-DD eg. 2010-01-01
--	
--	Change History:	20120601 - LT - Created
--                  20130624 - LS - Case 18632, additional fields
--                  20130814 - LS - Case 18994, use CreateDateTime instead of UserStart
--                                  todo: move this to webi, all fields are available in universe

--	Change History:	20160106 - GP - Updated
--                  20160106 - GP - Case 21499, additional fields, ASICCheck from penUser as ASIC B&D Register Result
--                  20160106 - GP - Case 21499, Replaced ASICNumber from penOutlet
--					20171205 - SD - INC0051471, Convert all text fields to upper case, Adelle Perry
--
/****************************************************************************************************/

--uncomment to debug
--declare 
--    @Country varchar(3),
--    @Company varchar(5),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10)
--select 
--    @Country = 'AU', 
--    @Company = '%', 
--    @ReportingPeriod = 'Yesterday', 
--    @StartDate = null, 
--    @EndDate = null'

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    select
	    u.CountryKey,
	    u.CompanyKey,
	    u.UserKey,
	    upper(o.AlphaCode) AlphaCode,
	    upper(o.OutletName) OutletName,
	    u.CreateDateTime LastModifiedDate,
	    upper(u.FirstName) FirstName,
	    upper(u.LastName) LastName,
	    upper(u.[Login]) [Login],
	    upper(u.Initial) Initial,
	    u.ASICNumber User_ASICNumber,
		o.ASICNumber Agency_ASICNumber,
	    u.AgreementDate,
	    u.AccreditationNumber,
	    u.AccreditationDate,
	    u.DeclaredDate,
	    upper(u.PreviouslyKnownAs) PreviouslyKnownAs,
	    u.YearsOfExperience,
	    u.DateOfBirth,
	    upper(u.[Status]) [Status],
	    @rptStartDate as rptStartDate,
	    @rptEndDate as rptEndDate,
		upper(isnull(u.ASICCheck, '')) ASICCheck
    from 
	    penUser u
	    inner join penOutlet o on
	        o.OutletKey = u.OutletKey and
	        o.OutletStatus = 'Current'
    where   
	    u.UserStatus = 'Current' and 
	    u.CountryKey = @Country and
	    u.CompanyKey like @Company and
	    u.[Status] = 'Active' and
	    u.CreateDateTime >= @rptStartDate and 
	    u.CreateDateTime <  dateadd(day, 1, @rptEndDate)
    order by
	    u.CreateDateTime
    	
end
GO
