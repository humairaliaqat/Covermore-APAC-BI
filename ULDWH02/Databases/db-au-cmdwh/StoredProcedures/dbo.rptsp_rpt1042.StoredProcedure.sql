USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1042]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1042]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null 
  
as

Begin
SET NOCOUNT ON

/****************************************************************************************************/
--  Name:          rptsp_rpt1042
--  Author:        Yi Yang
--  Date Created:  20190110
--  Description:   This stored procedure extract quote traveller data from GCP for MB Freemium.
--
--  Parameters:   
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20190110 - YY - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare 
    @DateRange varchar(30),
    @StartDate date,
    @EndDate date
select 
    @DateRange = '_User Defined',
    @StartDate = '2019-01-05',
    @EndDate = '2019-01-05'
*/

 set nocount on

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from vDateRange
	where DateRange = @DateRange


 
select
		ft.QuoteID,
		ft.CustomerID,
		ft.isPrimary,
		ft.Age,
		ft.isAdult,
		ft.hasEMC,
		ft.Title,	
		ft.FirstName,
		ft.LastName,
		left(ft.DOB, 10) as DOB,
		ft.Street,
		ft.Suburb,
		ft.State,
		ft.Postcode,
		ft.Country,
		ft.Phone1,
		ft.Phone2,
		ft.EmailAddress,
		ft.OptFurtherContact,
		ft.MemberNumber,
		ft.SessionID,
		ft.AgencyCode,
		ft.StoreCode,
		ft.ConsultantName,
		ft.UserName,
		left(ft.CreatDate,10) as CreatDate,
		rg.Region as Area,
		dt.DestinationCountry as Destination,
		left(ft.DepartureDate, 10) as DepartureDate,
		left(ReturnDate, 10) as ReturnDate,
		ft.Duration,
		ft.isExpo,
		ft.isAgentSpecial,
		ft.PromoCode,
		ft.isCANX,
		ft.PolicyNumber,
		ft.ChildrenCount,
		ft.AdultsCount,
		ft.TravellersCount,
		ft.isSaved,
		ft.SaveStep,
		left(ft.QuoteSavedDate, 10) as QuoteSavedDate,
		ft.ProductCode,
		ft.QuotedPrice,
		@rptStartDate as StartDate, 
		@rptEndDate as EndDate
	from 
		[bhdwh03].[db-au-cmdwh].dbo.vMBQuoteTraveller as ft
		join [db-au-cmdwh].dbo.cdgRegion as rg on (ft.Area = rg.RegionID)
		cross apply (
			select 
				top 1 DestinationCountry
			from 
				[db-au-cmdwh].dbo.cdgDestination as dt 
			where 
				ft.Destination = dt.DestinationCountryCode
			) as dt
	where
		ft.QuoteDate between @rptStartDate and dateadd(day, 1, @rptEndDate)
		
end

GO
