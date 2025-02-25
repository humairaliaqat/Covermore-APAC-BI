USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_quotecustomer]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rawsp_quotecustomer]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

/****************************************************************************************************/
--  Name:          rawsp_quotecustomer
--  Author:        Leonardus Setyabudi
--  Date Created:  20111020
--  Description:   This stored procedure extract quote's customer data for given parameters
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
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    select
        qc.QuoteID,
        qc.CustomerID,
        qc.IsPrimary,
        qc.Age,
        qc.PersonIsAdult,
        qc.HasEMC
    from
        Agency a
        inner join Quote q on
            q.AgencyKey = a.AgencyKey
        inner join QuoteCustomer qc on
            qc.QuoteCountryKey = q.QuoteCountryKey
    where
        a.CountryKey = @Country and
        a.AgencyGroupCode = @AgencyGroup and
        a.AgencyStatus = 'Current' and
        (
            CreateDate >= @dataStartDate and
            CreateDate <  dateadd(day, 1, @dataEndDate)
        )

    union

    select
        qc.QuoteID,
        qc.CustomerID,
        qc.IsPrimary,
        qc.Age,
        qc.PersonIsAdult,
        qc.HasEMC
    from
        Agency a
        inner join Policy p on
            p.AgencyKey = a.AgencyKey
        inner join Quote q on
            q.PolicyKey = p.PolicyKey
        inner join QuoteCustomer qc on
            qc.QuoteCountryKey = q.QuoteCountryKey
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
