USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_policycustomer]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rawsp_policycustomer]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max) = null,
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

/****************************************************************************************************/
--  Name:          rawsp_policycustomer
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract policy's customer data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--
--  Change History:
--                  20111024 - LS - Created
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20130530 - LS - Case 18562, add extra parameter for agency code in csv
--
/****************************************************************************************************/
--uncomment to debug
/*
declare
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max),
    @DateRange varchar(30),
    @StartDate date,
    @EndDate date
select
    @Country = 'AU',
    @AgencyGroup = 'MB',
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

    select
        p.PolicyNo,
        c.CustomerID,
        c.MemberNumber,
        isnull(c.isPrimary, 0) isPrimary,
        c.DateOfBirth,
        c.AgeAtDateOfIssue,
        c.PersonIsAdult,
        c.Title,
        c.FirstName,
        c.Initial,
        c.LastName,
        c.AddressStreet,
        c.AddressSuburb,
        c.AddressState,
        c.AddressPostCode,
        c.AddressCountry,
        c.Phone,
        c.WorkPhone,
        c.Email
    from
        Agency a
        inner join Policy p on
            p.AgencyKey = a.AgencyKey
        inner join Customer c on
            c.CustomerKey = p.CustomerKey
    where
        a.CountryKey = @Country and
        a.AgencyGroupCode = @AgencyGroup and
        a.AgencyStatus = 'Current' and
        p.IssuedDate >= @dataStartDate and
        p.IssuedDate <  dateadd(day, 1, @dataEndDate) and

        (
            isnull(@AgencyCodes, '') = '' or
            a.AgencyCode in
            (
                select Item
                from
                    dbo.fn_DelimitedSplit8K(@AgencyCodes, ',')
            )
        )

end

GO
