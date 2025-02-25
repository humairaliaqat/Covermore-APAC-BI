USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0018]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0018]	
    @SampleNumber int,
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
    
as
begin

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0018
--	Author:			Linus Tor
--	Date Created:	20110315
--	Description:	This stored procedure returns risk assessment data that fall within the parameter values
--	Parameters:		@SampleNumber: enter a sample size number in integer
--					@ReportingPeriod: any date range in vDateRange view. if User Defined, enter StartDate and EndDate parameters
--					@StartDate: Format: YYYY-MM-DD eg 2011-01-01
--					@EndDate: Format: YYYY-MM-DD eg 2011-01-01
--
--	Change History:	20100409 - LT - Migrated from WILLS.trips.dbo.SQL155_Compliance_Sampling
--					20110315 - LT - Migrated from OXLEY.RPTDB.dbo.rptsp_rpt0018
--                  20140116 - LS - Migrate to penguin data
--                                  refactor, optimise
--
/****************************************************************************************************/

--uncomment to debug
/*
declare 
    @SampleNumber int,
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
select 
    @SampleNumber = 3500, 
    @ReportingPeriod = 'Last Week', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @ReportingPeriod = 'User Defined'
        select 
            @rptStartDate = convert(date, @StartDate), 
            @rptEndDate = convert(date, @EndDate)
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    /* clean up temp table */
    if object_id('tempdb..#samples') is not null
        drop table #samples

    select top (convert(int, @SampleNumber * 0.5))
        pt.PolicyTransactionKey
    into #samples
    from
        penPolicyTransSummary pt
        inner join penOutlet o on
	        o.OutletStatus = 'Current' and
	        o.OutletAlphaKey = pt.OutletAlphaKey
    where
        o.CountryKey = 'AU' and
        pt.TransactionType in ('Base', 'Extension') and
        pt.TransactionStatus = 'Active' and
        pt.IssueDate between @rptStartDate and @rptEndDate and
        o.StateSalesArea = 'New South Wales'
    order by
        newid()

    insert into #samples
    select top (convert(int, @SampleNumber * 0.2))
        pt.PolicyTransactionKey
    from
        penPolicyTransSummary pt
        inner join penOutlet o on
	        o.OutletStatus = 'Current' and
	        o.OutletAlphaKey = pt.OutletAlphaKey
    where
        o.CountryKey = 'AU' and
        pt.TransactionType in ('Base', 'Extension') and
        pt.TransactionStatus = 'Active' and
        pt.IssueDate between @rptStartDate and @rptEndDate and
        o.StateSalesArea = 'Victoria'
    order by
        newid()

    insert into #samples
    select top (convert(int, @SampleNumber * 0.2))
        pt.PolicyTransactionKey
    from
        penPolicyTransSummary pt
        inner join penOutlet o on
	        o.OutletStatus = 'Current' and
	        o.OutletAlphaKey = pt.OutletAlphaKey
    where
        o.CountryKey = 'AU' and
        pt.TransactionType in ('Base', 'Extension') and
        pt.TransactionStatus = 'Active' and
        pt.IssueDate between @rptStartDate and @rptEndDate and
        o.StateSalesArea = 'Queensland'
    order by
        newid()

    insert into #samples
    select top (convert(int, @SampleNumber * 0.1))
        pt.PolicyTransactionKey
    from
        penPolicyTransSummary pt
        inner join penOutlet o on
	        o.OutletStatus = 'Current' and
	        o.OutletAlphaKey = pt.OutletAlphaKey
    where
        o.CountryKey = 'AU' and
        pt.TransactionType in ('Base', 'Extension') and
        pt.TransactionStatus = 'Active' and
        pt.IssueDate between @rptStartDate and @rptEndDate and
        o.StateSalesArea not in ('New South Wales', 'Victoria', 'Queensland')
    order by
        newid()

    select
        pt.PolicyNumber PolicyNo,
        ptv.Title,
        ptv.FirstName,
        ptv.LastName,
        ptv.DOB DateOfBirth,
        o.AlphaCode AgencyCode,
        o.OutletName AgencyName,
        u.Initial ConsultantInitial,
        o.Branch,
        case 
            when isnull(ptv.HomePhone, '') = '' then ptv.WorkPhone
            else ptv.HomePhone
        end Phone,
        o.StateSalesArea [State],
        pt.IssueDate IssuedDate,
        p.TripStart DepartureDate,
        p.TripEnd ReturnDate,
        @rptStartDate rptStartDate,
        @rptEndDate rptEndDate
    from
        #samples t
        inner join penPolicyTransSummary pt on
            pt.PolicyTransactionKey = t.PolicyTransactionKey
        inner join penPolicy p on
            p.PolicyKey = pt.PolicyKey
        inner join penOutlet o on
	        o.OutletStatus = 'Current' and
	        o.OutletAlphaKey = pt.OutletAlphaKey
        inner join penPolicyTraveller ptv on
	        ptv.PolicyKey = pt.PolicyKey and
	        ptv.isPrimary = 1 /* this is not in the original sp */
	    left join penUser u on
	        u.UserStatus = 'Current' and
	        u.UserKey = pt.UserKey
	order by
	    1

    /* clean up temp table */
    if object_id('tempdb..#samples') is not null
        drop table #samples


end




GO
