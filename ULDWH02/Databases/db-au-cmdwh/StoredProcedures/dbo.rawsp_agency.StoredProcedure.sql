USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_agency]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_agency]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:           rawsp_agency
--  Author:         Leonardus Setyabudi
--  Date Created:   20111020
--  Description:    This stored procedure extract agency data for given parameters
--  Parameters:     @Country: Country Code; e.g. AU
--                  @AgencyGroup: Agency group code; e.g. AP, FL 
--                  @DateRange: Value is valid date range
--                  @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                  @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20111020 - LS - Created
--                  20111024 - LS - bug fix, duplicate data (Agency Status)
--                  20140130 - LS - migrate to penguin data set
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

    select
        CountryKey,
        AlphaCode AgencyCode,
        isnull(SuperGroupName, '') AgencySuperGroupName,
        GroupCode AgencyGroupCode,
        isnull(GroupName, '') AgencyGroupName,
        isnull(SubGroupCode, '') AgencySubGroupCode,
        isnull(SubGroupName, '') AgencySubGroupName,
        isnull(StateSalesArea, '') AgencyGroupState,
        isnull(Branch, '') Branch,
        isnull(OutletName, '') AgencyName,
        '' AgencyComment,
        '' AgencyStatusCode,
        isnull(TradingStatus, '') AgencyStatusName,
        OutletStartDate AgencyStartDate,
        OutletEndDate AgencyClosedDate,
        LastUpdate LastModifiedDate,
        AgreementDate,
        ASICCheckDate DateASICChecked,
        isnull(FSRType, '') FSRType,
        isnull(ASICNumber, 0) ASICNumber,
        isnull(LegalEntityName, '') LegalEntity,
        isnull(ABN, '') ABN,
        '' CustomerServiceInitial,
        isnull(ContactTitle, '') ContactTitle,
        isnull(ContactFirstName, '') ContactFirstName,
        '' ContactMiddleInitial,
        isnull(ContactLastName, '') ContactLastName,
        isnull(ContactEmail, '') ContactEmail,
        isnull(ContactStreet, '') AddressStreet,
        isnull(ContactSuburb, '') AddressSuburb,
        isnull(ContactState, '') AddressState,
        isnull(ContactPostCode, '') AddressPostCode,
        isnull(ContactPhone, '') Phone,
        isnull(ContactFax, '') Fax,
        isnull(convert(varchar, BDMID), '') BDMCode,
        isnull(BDMName, '') BDMName,
        isnull(SalesTier, '') SalesTier,
        isnull(SalesSegment, '') SalesSegment,
        isnull(PotentialSales, 0) PotentialSales,
        0 FSGMinimumCommission,
        0 FSGMaxCommission,
        isnull(BDMCallFrequency, 0) CallFrequency,
        isnull(convert(varchar, AcctManagerID), '') AccountMgrCode,
        isnull(AcctManagerName, '') AccountMgrName,
        isnull(AcctMgrCallFrequency, 0) AccountMgrCallFrequency
    from 
        penOutlet o
        cross apply
        (
            select 
                max(c.CommentDate) LastUpdate
            from
                penAutoComment c
            where
                c.OutletKey = o.OutletKey
        ) c
    where 
        CountryKey = @Country and
        GroupCode = @AgencyGroup and
        OutletStatus = 'Current' and
        c.LastUpdate >= @dataStartDate and
        c.LastUpdate <  dateadd(day, 1, @dataEndDate)

end
GO
