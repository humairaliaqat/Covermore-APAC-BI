USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_quote]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rawsp_quote]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

/****************************************************************************************************/
--  Name:          rawsp_quote
--  Author:        Leonardus Setyabudi
--  Date Created:  20111020
--  Description:   This stored procedure extract quote data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--
--  Change History:
--                  20111020 - LS - Created
--                  20111024 - LS - bug fix, duplicate data (Agency Status)
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
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
    @DateRange = 'Yesterday'
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
            vDateRange
        where
            DateRange = @DateRange

    /* quotes created within period */
    select
        q.CountryKey,
        q.QuoteID,
        q.SessionID,
        q.AgencyCode,
        q.StoreCode,
        q.ConsultantName,
        q.UserName,
        q.CreateDate [CreatedDate],
        q.Area,
        q.Destination,
        q.DepartureDate,
        q.ReturnDate,
        q.IsExpo,
        q.IsAgentSpecial,
        q.PromoCode,
        q.CanxFlag,
        q.PolicyNo,
        q.NumberOfChildren,
        q.NumberOfAdults,
        q.NumberOfPersons,
        q.Duration
    from
        Agency a
        inner join Quote q on
            q.AgencyKey = a.AgencyKey
    where
        a.CountryKey = @Country and
        a.AgencyGroupCode = @AgencyGroup and
        a.AgencyStatus = 'Current' and
        (
            CreateDate >= @dataStartDate and
            CreateDate <  dateadd(day, 1, @dataEndDate)
        )

    union

    /* quotes converted within period */
    select
        q.CountryKey,
        q.QuoteID,
        q.SessionID,
        q.AgencyCode,
        q.StoreCode,
        q.ConsultantName,
        q.UserName,
        q.CreateDate [CreatedDate],
        q.Area,
        q.Destination,
        q.DepartureDate,
        q.ReturnDate,
        q.IsExpo,
        q.IsAgentSpecial,
        q.PromoCode,
        q.CanxFlag,
        q.PolicyNo,
        q.NumberOfChildren,
        q.NumberOfAdults,
        q.NumberOfPersons,
        q.Duration
    from
        Agency a
        inner join Policy p on
            p.AgencyKey = a.AgencyKey
        inner join Quote q on
            q.PolicyKey = p.PolicyKey
    where
        a.CountryKey = @Country and
        a.AgencyGroupCode = @AgencyGroup and
        a.AgencyStatus = 'Current' and
        (
            p.IssuedDate >= @dataStartDate and
            p.IssuedDate <  dateadd(day, 1, @dataEndDate)
        )

end

GO
