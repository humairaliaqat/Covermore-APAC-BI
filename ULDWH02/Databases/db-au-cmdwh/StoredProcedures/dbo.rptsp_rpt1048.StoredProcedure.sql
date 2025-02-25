USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1048]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt1048]  
    @SuperGroup nvarchar(max),
    @Group nvarchar(max),
    @TripType nvarchar(50),
    @DateRange varchar(30),
    @StartDate datetime,
    @EndDate datetime

as
begin

/****************************************************************************************************/
--  Name:           rptsp_rpt1048
--  Author:         Saurabh Date
--  Date Created:   20190204
--  Description:    This stored procedure returns AMT customer details
--  Parameters:     @DateRange: standard date range or _User Defined
--                  @StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2019-01-01
--                  @EndDate  : if _User Defined. Format: YYYY-MM-DD eg. 2019-01-01
--   
--  Change History: 20190204 - SD - Created
--                  20190816 - LT - Added TripType parameter, and TripType column

/****************************************************************************************************/

--uncomment to debug
--declare 
--    @SuperGroup nvarchar(max) = 'Medibank',
--    @Group nvarchar(max) = 'All',
--    @TripType nvarchar(50) = 'All',
--    @DateRange varchar(30) = '_User Defined',
--    @StartDate date = '2018-02-01',
--    @EndDate date = '2018-02-15'

    set nocount on
                                    
    declare 
        @rptStartDate datetime,
        @rptEndDate datetime

    declare @out table
    (
	    [GroupName] [nvarchar](50) not null,
	    [SubGroupName] [nvarchar](50) null,
	    [AlphaCode] [nvarchar](20) not null,
	    [OutletName] [nvarchar](50) not null,
	    [Title] [nvarchar](50) null,
	    [FirstName] [nvarchar](100) null,
	    [LastName] [nvarchar](100) null,
        [DOB] [date] null,
	    [EmailAddress] [nvarchar](255) null,
	    [PolicyNumber] [varchar](50) null,
	    [IssueDate] [datetime] null,
	    [TripStart] [datetime] null,
	    [TripEnd] [datetime] null,
	    [PrimaryCountry] [nvarchar](max) null,
	    [ISO3Code] [varchar](3) null,
	    [SellPrice] [money] not null,
	    [ReportStartDate] [datetime] null,
	    [ReportEndDate] [datetime] null,
	    [TripType] [nvarchar](50) null
    )

    --get reporting dates
    if @DateRange = '_User Defined'
        select 
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange


    insert into @out
    (
	    [GroupName],
	    [SubGroupName],
	    [AlphaCode],
	    [OutletName],
	    [Title],
	    [FirstName],
	    [LastName],
        [DOB],
	    [EmailAddress],
	    [PolicyNumber],
	    [IssueDate],
	    [TripStart],
	    [TripEnd],
	    [PrimaryCountry],
	    [ISO3Code],
	    [SellPrice],
	    [ReportStartDate],
	    [ReportEndDate],
	    [TripType]
    )
    select 
        o.GroupName,
        o.SubGroupName,
        o.AlphaCode,
        o.OutletName,
        ptv.Title,
        ptv.FirstName,
        ptv.LastName,
        convert(date,ptv.DOB) DOB,
        ptv.EmailAddress,
        p.PolicyNumber,
        convert(datetime, p.IssueDate) IssueDate,
        convert(datetime,p.TripStart) TripStart,
        convert(datetime,p.TripEnd) TripEnd,
        p.PrimaryCountry,
        cc.ISO3Code,
        isnull(pt.SellPrice, 0) SellPrice,
        @rptStartDate [ReportStartDate],
        @rptEndDate [ReportEndDate],
        p.TripType
    from
        penPolicy p with(nolock)
        cross apply
        (
            select top 1
                ptv.Title,
                ptv.FirstName,
                ptv.LastName,
                ptv.EmailAddress,
                ptv.DOB
            from
                penPolicyTraveller ptv with(nolock)
            where
                ptv.PolicyKey = p.PolicyKey 
            order by
                isPrimary desc
        ) ptv
        inner join penOutlet o with(nolock) on
            o.OutletAlphaKey = p.OutletAlphaKey and
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1
                pc.ISO3Code
            from
                penCountry pc with(nolock)
            where 
            --Using TIP COuntry codes, as they seem to have mapped iso3 codes appropriately to destination country
                pc.CountryKey = 'AU' and
                pc.CompanyKey = 'TIP' and 
                pc.CountryName = p.PrimaryCountry
        ) cc
        cross apply
        (
            select 
                sum(pt.GrossPremium) SellPrice
            from
                penPolicyTransSummary pt with(nolock)
            where
                pt.PolicyKey = p.PolicyKey
        ) pt
    where
        o.CountryKey = 'AU' and
        (
            @SuperGroup = 'All' or
            o.SuperGroupName in
            (
            select 
                Item
            from
                dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
            )
        ) and
        (
            @Group = 'All' or
            o.GroupName in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@Group, ',')
            )
        ) and
        (
            @TripType = 'ALL' or
            p.TripType  in
            (
                select
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@TripType,',')
            )
        ) and
        p.IssueDate >= @rptStartDate and
        p.IssueDate <  dateadd(day, 1, @rptEndDate)

    declare @traveller table
    (
        PolicyNumber [varchar](50) null,
        IssueDate [datetime] null,
        PolicyKey [varchar](50) null
    )

    insert into @traveller
    (
        PolicyNumber,
        IssueDate,
        PolicyKey
    )
    select 
        t.PolicyNumber,
        convert(datetime,t.IssueDate) IssueDate,
        nptv.PolicyKey
    from
        @out t
        inner join penPolicyTraveller nptv with(nolock) on
            nptv.FirstName = t.FirstName and
            nptv.LastName = t.LastName and
            nptv.DOB = t.DOB and
            nptv.CountryKey = 'AU'

    declare @next table
    (
        PolicyNumber [varchar](50) null,
        NextPolicyNumber [varchar](50) null
    )

    insert into @next
    (
        PolicyNumber,
        NextPolicyNumber
    )
    select 
        t.PolicyNumber,
        np.PolicyNumber
    from
        @out t
        inner join penPolicy np with(nolock) on
            np.PreviousPolicyNumber = t.PolicyNumber and
            np.CountryKey = 'AU'

    insert into @next
    (
        PolicyNumber,
        NextPolicyNumber
    )
    select 
        t.PolicyNumber,
        p.PolicyNumber
    from
        @traveller t
        inner join penPolicy p with(nolock) on
            p.PolicyKey = t.PolicyKey
    where
        p.IssueDate > t.IssueDate

    select 
	    [GroupName],
	    [SubGroupName],
	    [AlphaCode],
	    [OutletName],
	    [Title],
	    [FirstName],
	    [LastName],
	    [EmailAddress],
	    [PolicyNumber],
	    [IssueDate],
	    [TripStart],
	    [TripEnd],
	    [PrimaryCountry],
	    [ISO3Code],
	    [SellPrice],
	    [ReportStartDate],
	    [ReportEndDate],
	    [TripType],
        (
            select distinct
                np.NextPolicyNumber +
                case
                    when np.NextPolicyNumber = max(np.NextPolicyNumber) over () then ''
                    else ','
                end
            from
                @next np
            where
                np.PolicyNumber = t.PolicyNumber and
                np.NextPolicyNumber <> t.PolicyNumber
            --order by
            --    np.PolicyNumber
            for xml path ('')
        ) NextPolicies
    from
        @out t


end
GO
