USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_penguin_policy]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_penguin_policy]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null 
  
as
begin

/****************************************************************************************************/
--  Name:          rawsp_penguin_policy
--  Author:        Leonardus Setyabudi
--  Date Created:  20121129
--  Description:   This stored procedure extract penguin policy data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL 
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20121129 - LS - Created
--                  20120415 - LS - Case 18456, add promo field
--					20130806 - LT - Case 18803, Added MaxDuration column
--                  20130823 - LS - Case 18922, add GrossPremium (ajusted including tax)
--					20131202 - LT - Added isPrimary column to the extract.
--                  20170620 - LL - use posting date instead of issue date to filter, order by issue date
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select 
    @Country = 'AU', 
    @AgencyGroup = 'AP', 
    @DateRange = 'Current Month'
*/

    set nocount on

    declare @dataStartDate date
    declare @dataEndDate date

    /* get dates */
    if @DateRange = '_User Defined'
        select 
            @dataStartDate = @StartDate,
            @dataEndDate = @EndDate

    else
        select 
            @dataStartDate = StartDate, 
            @dataEndDate = EndDate
        from 
            [db-au-cmdwh].dbo.vDateRange
        where 
            DateRange = @DateRange

    select
        po.AlphaCode [Agency Code],
        po.OutletType [Sales Channel],
        po.OutletName [Agency Name],
        pt.PolicyNumber [Policy Number],
        replace(convert(varchar, convert(datetime, pt.IssueDate), 120), '-', '/') [Issued Date],
        pt.ProductCode [Product Code],
        p.PolicyType [Policy Type],
        convert(int, p.Excess) Excess,
        p.Area,
        p.PrimaryCountry [Destination],
        replace(convert(varchar, p.TripStart, 120), '-', '/') [Departure Date],
        replace(convert(varchar, p.TripEnd, 120), '-', '/') [Return Date],
        p.DaysCovered [Days Covered],
        pt.AdultsCount [Number of Adults Count],
        pt.ChildrenCount [Number of Children Count],
        pt.EMCCount [EMC Count],
        pt.WintersportCount [Wintersport Count],
        pt.RentalCarCount [Rental Car Count],
        pt.MotorcycleCount [Motorcycle Count],
        ptv.Title,
        ptv.FirstName [First Name],
        ptv.LastName [Last Name],
        replace(convert(varchar, ptv.DOB, 120), '-', '/') [Date of Birth],
        ptv.Age,
        ptv.AddressLine1 + 
        case
            when ltrim(rtrim(ptv.AddressLine2)) <> '' then ' ' + ptv.AddressLine2
            else ''
        end [Street],
        ptv.Suburb,
        ptv.State,
        ptv.PostCode [Post Code],
        ptv.EmailAddress [Email],
        ptv.HomePhone [Home Phone],
        ptv.WorkPhone [Work Phone],
        ptv.MobilePhone [Mobile Phone],
        ptv.OptFurtherContact [Opt Further Contact],
        replace(convert(varchar, convert(datetime, @dataStartDate), 120), '-', '/') [Date Range Start Date],
        replace(convert(varchar, convert(datetime, @dataEndDate), 120), '-', '/') [Date Range End Date],
        pt.TransactionType [Transaction Type],
        pt.TransactionStatus [Transaction Status],
        (
            select 
                ppr.PromoCode + 
                case
                    when ppr.PromoKey = max(ppr.PromoKey) over () then ''
                    else ','
                end
            from  
                penPolicyTransactionPromo ppr 
            where
                ppr.PolicyTransactionKey = pt.PolicyTransactionKey and
                ppr.IsApplied = 1
            order by PromoKey
            for xml path('')
        ) [Promo Codes],
        p.MaxDuration as [Max Duration],
        pt.GrossPremium SellPrice,
        ptv.isPrimary as [isPrimary]
    from
        penPolicyTransSummary pt
        inner join penPolicy p on 
            p.PolicyKey = pt.PolicyKey
        inner join penOutlet po on
            po.OutletAlphaKey = p.OutletAlphaKey
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = p.PolicyKey
    where
        po.OutletStatus = 'Current' and
        po.CountryKey = @Country and
        po.GroupCode = @AgencyGroup and
        pt.PostingDate >= @dataStartDate and
        pt.PostingDate <  dateadd(day, 1, @dataEndDate)
    order by
        pt.IssueDate,
        po.AlphaCode,
        pt.PolicyNumber,
        ptv.Title,
        ptv.FirstName,
        ptv.LastName
      
end

GO
