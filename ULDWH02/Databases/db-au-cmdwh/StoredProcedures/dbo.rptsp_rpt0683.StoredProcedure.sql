USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0683]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0683]    
    @ReportingPeriod varchar(30),    
    @StartDate varchar(10),
    @EndDate varchar(10)
    
as
begin


/****************************************************************************************************/
--    Name:           rptsp_rpt0683
--    Author:         Dane
--    Date Created:   20150916
--    Description:    This stored procedure includes the Flight Centre agents who sells a policy, 
--					  used for the Superhe000s campaign
--    Parameters:     
--                    @ReportingPeriod    --If value "_User Defined" enter Start Date and End Date
--                    @StartDate          --Enter Start Date (Format:YYYY-MM-DD Eg 2010-01-01)
--                    @EndDate            --Enter End Date   (Format:YYYY-MM-DD Eg 2010-01-01)
--    Change History: 20150916 - DM - Created.
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar (10)
declare @EndDate varchar (10)
select @ReportingPeriod = '_User Defined',@StartDate = '20150801', @EndDate = '20150831'
*/

    set nocount on 

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    --get reporting dates
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = @StartDate, 
            @rptEndDate = @EndDate
        
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from [db-au-cmdwh].dbo.vDateRange
        where DateRange = @ReportingPeriod

    select
        u.FirstName + ' ' + u.LastName as Consultant,
        o.OutletName as StoreName,
        ltrim(rtrim(o.ContactStreet)) + ', ' + ltrim(rtrim(o.ContactSuburb)) + ', ' + ltrim(rtrim(o.ContactState)) + ' ' + ltrim(rtrim(o.ContactPostCode)) as StoreAddress,
        o.ContactPhone as StorePhone,
        o.AlphaCode as AlphaCode,
        p.PolicyNumber,
        p.IssueDate,
        p.ProductDisplayName as Product,
        pt.GrossPremium as SellPrice,
        pt.TransactionStatus,
        o.FCNation,
        o.FCArea,
		o.GroupName,
		o.SubGroupName,
		o.BDMName,
		o.ExternalBDMName,
		o.StateSalesArea as [State],
        @rptStartDate as rptStartDate,
        @rptEndDate as rptEndDate,
		p.TripType
    from
        [db-au-cmdwh].dbo.penPolicy p
        inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt on 
            p.PolicyKey = pt.PolicyKey
        inner join [db-au-cmdwh].dbo.penOutlet o on
            p.OutletAlphaKey = o.OutletAlphaKey and
            o.OutletStatus = 'Current'
        inner join [db-au-cmdwh].dbo.penUser u on 
            pt.UserKey = u.UserKey and
            u.UserStatus = 'Current'
    where
        p.CountryKey = 'AU' and
        o.GroupName = 'Flight Centre' and
		o.SubGroupName in ('Flight Centre','Student Flights','Escape Travel','Cruiseabout','Travel Associates','Travel Money Oz','Escape Franchise') and
		o.OutletType = 'B2B' and
		u.ConsultantType = 'External' and
		p.AreaType = 'International' and
        pt.IssueDate >= @rptStartDate and 
        pt.IssueDate <  dateadd(day, 1, @rptEndDate) and
        pt.TransactionStatus in ('Active', 'Cancelled') and
        pt.TransactionType = 'Base'
end
GO
