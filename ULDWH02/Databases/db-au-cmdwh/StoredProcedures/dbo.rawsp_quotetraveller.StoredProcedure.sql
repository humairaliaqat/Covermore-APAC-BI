USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_quotetraveller]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_quotetraveller]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max) = null,
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null 
  
as

Begin
SET NOCOUNT ON


/****************************************************************************************************/
--  Name:          rawsp_quotetraveller
--  Author:        Linus Tor
--  Date Created:  20140212
--  Description:   Based on rawsp_quote and rawsp_quotecustomer procedures.
--				   This stored procedure extract quote and quote traveller data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL 
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20140212 - LT - Created
--					20140415 - LT - Changed reference by UpdateTime to CreateDate. UpdateTime is not populated in tblQuote
--					20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--					20190305 - YY - REQ1060 - Add a column "Channel"
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
	@DateRange = 'Month-To-Date'
*/


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
	q.QuoteID,
	c.CustomerID,
	qc.isPrimary,
	qc.Age,
	qc.PersonIsAdult as isAdult,
	qc.hasEMC,
	c.Title,
	c.FirstName,
	c.LastName,
	c.DOB,
	c.AddressLine1 + ' ' + c.AddressLine2 as Street,
	c.Town as Suburb,
	c.[State],
	c.Postcode,
	c.Country,
	c.WorkPhone,
	case when c.HomePhone is null then c.MobilePhone
		 else c.HomePhone
	end as HomeMobilePhone,
	c.EmailAddress,
	c.OptFurtherContact,
	c.MemberNumber,
	q.SessionID,
	q.AgencyCode,
	q.StoreCode,
	q.ConsultantName,
	q.UserName,
	q.CreateDate,
	q.Area,
	q.Destination,
	q.DepartureDate,
	q.ReturnDate,
	q.Duration,
	q.isExpo,
	q.isAgentSpecial,
	q.PromoCode,
	q.CANXFlag as isCANX,
	q.PolicyNo as PolicyNumber,
	q.NumberOfChildren as ChildrenCount,
	q.NumberOfAdults as AdultsCount,
	q.NumberOfPersons as TravellersCount,
	q.isSaved,
	q.SaveStep,
	q.QuoteSaveDate,
	q.ProductCode,
	q.QuotedPrice,
	o.Channel	   
from
	penQuote q
	inner join penQuoteCustomer qc on
		q.QuoteCountryKey = qc.QuoteCountryKey
	left join penCustomer c on
		qc.CustomerKey = c.CustomerKey
	inner join penOutlet o on
		q.OutletAlphaKey = o.OutletAlphaKey and
		o.OutletStatus = 'Current'	
where 
    o.CountryKey = @Country and
	o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    q.CreateDate >= @dataStartDate and
    q.CreateDate < dateadd(day,1,@dataEndDate) and
    (
        isnull(@AgencyCodes, '') = '' or
        o.AlphaCode in
        (
            select Item
            from
                dbo.fn_DelimitedSplit8K(@AgencyCodes, ',')
        )
    )

End
GO
