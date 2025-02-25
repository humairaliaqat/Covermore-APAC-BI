USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_quotetraveller_MBFree]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_quotetraveller_MBFree]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null 
  
as

Begin
SET NOCOUNT ON

/****************************************************************************************************/
--  Name:          rawsp_quotetraveller_MBFree
--  Author:        Yi Yang
--  Date Created:  20190110
--  Description:   This stored procedure extract quote traveller data from GCP.
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

declare @dataStartDate date
declare @dataEndDate date
 
declare @dataStartDate_s varchar(10)
declare @dataEndDate_s varchar(10)

declare @openqry varchar(8000)


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
        [db-au-cmdwh]..vDateRange
    where 
        DateRange = @DateRange
 

set @dataStartDate_s = CAST(@dataStartDate AS char(10))
set @dataEndDate_s = CAST(@dataEndDate AS char(10))
 
set  @openqry = '
if object_id(''[db-au-workspace]..tmp_freemium'', ''U'') is not null
drop table [db-au-workspace]..tmp_freemium;

select 
	q.QuoteID as QuoteID,
	q.QuoteID as CustomerID,
	''1'' as isPrimary,
	q.Age as Age,
	(case when q.isAdult = ''true'' 
		then 1 else 0 end 
	) as isAdult,
	(case when emc.Addon is not null 
		then 1
		else 0
		end
	) as hasEMC,
	q.Title as Title,
	q.FirstName as FirstName,
	q.LastName as LastName,
	q.DOB as DOB,
	(q.Street1 + '' '' + q.Street2) as Street,
	q.Suburb as Suburb,
	q.State as State,
	q.Postcode as Postcode,
	q.Country as Country,
	q.Phone1 as Phone1,
	q.Phone2 as Phone2,
	q.EmailAddress as EmailAddress,
	(case when q.OptFurtherContact = ''true''
		then 1 else 0 end ) as OptFurtherContact,
	q.MemberNumber as MemberNumber,
	q.QuoteID as SessionID,
	q.AgencyCode as AgencyCode,
	'' '' as StoreCode,
	q.ConsultantName as ConsultantName,
	q.UserName as UserName,
	q.QuoteSavedDate as CreatDate,
	q.regionID as Area,
	q.Destination as Destination,
	q.DepartureDate as DepartureDate,
	q.ReturnDate as ReturnDate,
	q.Duration as Duration,
	'' '' as isExpo,
	'' '' as isAgentSpecial,
	pm.PromoCode as PromoCode,
	(case when ad.Addon is not null 
		then 1
		else 0
		end
	) as isCANX,
	
	q.PolicyNo as PolicyNumber,
	r.ChildrenCount as ChildrenCount,
	r.AdultsCount as AdultsCount,
	r.TravellersCount as TravellersCount,
	(case when q.QuoteSavedDate is not null 
		then 1
		else 0
		end
	) as isSaved,
	'' '' as SaveStep,
	q.QuoteSavedDate as QuoteSavedDate,
	q.ProductID as ProductCode,
	q.QuotedPrice as QuotedPrice
into 
	[db-au-workspace].dbo.tmp_freemium																										
from
    openquery(
    gcp,
    ''
    SELECT 
        json_extract(s.data, ''''$.id'''') as QuoteID,
        json_extract(s.data, ''''$.travellers'''') as Travellers,
        json_extract(s.data, ''''$.appliedPromoCodes'''') as PromoCode,
        json_extract(s.data, ''''$.addons'''') as Addon,
 
        json_extract(s.data, ''''$.travellers[0].isPrimary'''') as isPrimary,
        json_extract(s.data, ''''$.travellers[0].age'''') as Age,
        json_extract(s.data, ''''$.travellers[0].isAdult'''') as isAdult,
        json_extract(s.data, ''''$.travellers[0].title'''') as Title,
        json_extract(s.data, ''''$.travellers[0].firstName'''') as FirstName,
        json_extract(s.data, ''''$.travellers[0].lastName'''') as LastName,
        json_extract(s.data, ''''$.travellers[0].dateOfBirth'''') as DOB,
        json_extract(s.data, ''''$.travellers[0].addons'''') as ptAddon,
 
        json_extract(s.data,  ''''$.contact.address.street1'''') as Street1,
        json_extract(s.data,  ''''$.contact.address.street2'''') as Street2,
        json_extract(s.data,  ''''$.contact.address.suburb'''') as Suburb,
        json_extract(s.data,  ''''$.contact.address.state'''') as State,
        json_extract(s.data,  ''''$.contact.address.postCode'''') as Postcode,
        json_extract(s.data,  ''''$.contact.address.country'''') as Country,
        json_extract(s.data,  ''''$.contact.phoneNumbers[0].number'''') as Phone1,
        json_extract(s.data,  ''''$.contact.phoneNumbers[1].number'''') as Phone2,
        json_extract(s.data, ''''$.contact.email'''') as EmailAddress,
        json_extract(s.data, ''''$.contact.optInMarketing'''') as OptFurtherContact,
        json_extract(s.data, ''''$.travellers[0].memberId'''') as MemberNumber,
        json_extract(s.data, ''''$.issuer.affiliateCode'''') as AgencyCode,
        json_extract(s.data, ''''$.issuer.consultant'''') as ConsultantName,
        json_extract(s.data, ''''$.issuer.consultant'''') as UserName,
        json_extract(s.data, ''''$.trip.destinationCountryCodes[0]'''') as Destination,
        json_extract(s.data, ''''$.trip.startDate'''') as DepartureDate,
        json_extract(s.data, ''''$.trip.endDate'''') as ReturnDate,
        json_extract(s.data, ''''$.trip.regionID'''') as regionID,
        json_extract(s.data, ''''$.quote.duration'''') as Duration,
        json_extract(s.data, ''''$.quoteDate'''') as QuoteSavedDate,
        json_extract(s.data, ''''$.quote.productID'''') as ProductID,
        json_extract(s.data, ''''$.quote.policyPrice.price.gross'''') as QuotedPrice,
        p.PolicyNo
    
    FROM 
        `cover-more-data-and-analytics.cmbq_prod.impulse_archive_sessions` s
        left join `cover-more-data-and-analytics.cmbq_prod.impulse_archive_policies` p 
            on (s.id = p.session_id) and (p.issueddate >= s.transaction_time and p.issueddate < timestamp_add(s.transaction_time, interval 2 day))
    WHERE 
        transaction_time >= '''''+@dataStartDate_s+''''' and transaction_time < timestamp_add('''''+@dataEndDate_s+''''', interval 1 day)
        and json_extract(s.data, ''''$.businessUnitID'''') = ''''32''''
        and json_extract(s.data, ''''$.quote.productID'''') in (''''1215'''', ''''1216'''')
    '') q 
    cross apply 
        (select 
            sum
            (
                case when json_value(r.[value], ''$.isAdult'') = ''false'' then 1
                else 0
                end
            ) ChildrenCount,    
 
            sum
            (
                case when json_value(r.[value],''$.isAdult'') = ''true'' then 1
                else 0
                end
            ) AdultsCount,    
 
            count(r.[key]) as TravellersCount
     
        from 
            OPENJSON(JSON_QUERY(q.Travellers, ''$'')) as r
 
        ) r
 
        outer  apply 
            (select 
                top 1
                json_value(pm.[value],''$'') as PromoCode
 
            from 
                OPENJSON(JSON_QUERY(q.PromoCode, ''$'')) as pm
                
            ) pm
 
        outer apply 
        (select 
            top 1
            json_value(ad.[value], ''$.addon.code'') as Addon
        from 
            OPENJSON(JSON_QUERY(q.Addon, ''$'')) ad
        where json_value(ad.[value], ''$.addon.code'') = ''CANX''
        ) ad
 
        outer apply 
        (select 
            top 1
            json_value(emc.[value], ''$.addon.code'') as Addon
        from 
            OPENJSON(JSON_QUERY(q.ptAddon, ''$'')) emc
 
        where json_value(emc.[value], ''$.addon.code'') = ''EMC''
 
        ) emc
 
'
--print @openqry

exec (@openqry) at BHDWH03

select
		replace(ft.QuoteID,'"','') as QuoteID,
		replace(ft.CustomerID,'"','') as CustomerID,
		ft.isPrimary,
		ft.Age,
		ft.isAdult,
		ft.hasEMC,
		replace(ft.Title,'"','') as Title,	
		replace(ft.FirstName,'"','') as FirstName,
		replace(ft.LastName, '"','') as LastName,
		replace(ft.DOB, '"','') as DOB,
		replace(ft.Street, '"','') as Street,
		replace(ft.Suburb, '"','') as Suburb,
		replace(ft.State, '"','') as State,
		replace(ft.Postcode, '"','') as Postcode,
		replace(ft.Country, '"','') as Country,
		replace(ft.Phone1, '"','') as Phone1,
		replace(ft.Phone2, '"','') as Phone2,
		replace(ft.EmailAddress, '"','') as EmailAddress,
		ft.OptFurtherContact,
		replace(ft.MemberNumber, '"','') as MemberNumber,
		replace(ft.SessionID, '"','') as SessionID,
		replace(ft.AgencyCode, '"','') as AgencyCode,
		ft.StoreCode,
		replace(ft.ConsultantName, '"','') as ConsultantName,
		replace(ft.UserName, '"','') as UserName,
		replace(ft.CreatDate, '"','') as CreatDate,
		rg.Region as Area,
		dt.DestinationCountry as Destination,
		replace(ft.DepartureDate, '"','') as DepartureDate,
		replace(ReturnDate, '"','') as ReturnDate,
		ft.Duration,
		ft.isExpo,
		ft.isAgentSpecial,
		replace(ft.PromoCode, '"','') as PromoCode,
		ft.isCANX,
		ft.PolicyNumber,
		ft.ChildrenCount,
		ft.AdultsCount,
		ft.TravellersCount,
		ft.isSaved,
		ft.SaveStep,
		replace(ft.QuoteSavedDate, '"','') as QuoteSavedDate,
		ft.ProductCode,
		ft.QuotedPrice 
	from 
		[bhdwh03].[db-au-workspace].dbo.tmp_freemium as ft
		join [uldwh02].[db-au-cmdwh].dbo.cdgRegion as rg on (ft.Area = rg.RegionID)
		cross apply (
			select 
				top 1 DestinationCountry
			from 
				[uldwh02].[db-au-cmdwh].dbo.cdgDestination as dt 
			where 
				replace(ft.Destination, '"','') = dt.DestinationCountryCode
			) as dt


end
GO
