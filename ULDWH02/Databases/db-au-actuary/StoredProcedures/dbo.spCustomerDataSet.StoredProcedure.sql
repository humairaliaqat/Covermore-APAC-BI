USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[spCustomerDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spCustomerDataSet]	@Domain varchar(2),
										@DateRange varchar(30),
										@StartDate date,
										@EndDate date
as

SET NOCOUNT ON

--uncomment to debug
/*
declare @Domain varchar(2)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select @Domain = 'AU', @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @mergeoutput table (MergeAction varchar(20))
declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


if object_id('[db-au-actuary].dataout.CustomerDataSet') is null
begin
	create table [db-au-actuary].dataout.CustomerDataSet
	(
		[PolicyTravellerKey] [varchar](41) NULL,
		[PolicyKey] [varchar](41) NULL,
		[FirstName] [nvarchar](100) NULL,
		[LastName] [nvarchar](100) NULL,
		[Age] [int] NULL,
		[DOB] [datetime] NULL,
		[isPrimary] [bit] NULL,
		[isAdult] [bit] NULL,
		[AdultCharge] [numeric](18, 5) NULL,
		[AddressLine1] [nvarchar](100) NULL,
		[AddressLine2] [nvarchar](100) NULL,
		[Suburb] [nvarchar](50) NULL,
		[Postcode] [nvarchar](50) NULL,
		[State] [nvarchar](100) NULL,
		[Country] [nvarchar](100) NULL,
		[HomePhone] [varchar](50) NULL,
		[MobilePhone] [varchar](50) NULL,
		[EmailAddress] [nvarchar](255) NULL,
		[OptFurtherContact] [bit] NULL,
		[MarketingConsent] [bit] NULL,
		[StateOfArrival] [varchar](100) NULL,
		[LoadDate] datetime NOT NULL,
		[UpdateDate] datetime NOT NULL
	)

	create clustered index idx_CustomerDataSet_PolicyTravellerKey on [db-au-actuary].dataout.CustomerDataSet(PolicyTravellerKey)
	create nonclustered index idx_CustomerDataSet_PolicyKey on [db-au-actuary].dataout.CustomerDataSet(PolicyKey)

end


if object_id('[db-au-workspace].dbo.tmp_CustomerDataSet') is not null drop table [db-au-workspace].dbo.tmp_CustomerDataSet

select
	ptr.PolicyTravellerKey,
	ptr.PolicyKey,
	ptr.FirstName,
	ptr.LastName,
	ptr.Age,
	ptr.DOB,
	ptr.isPrimary,
	ptr.isAdult,
	ptr.AdultCharge,
	ptr.AddressLine1,
	ptr.AddressLine2,
	ptr.Suburb,
	ptr.Postcode,
	ptr.State,
	ptr.Country,
	ptr.HomePhone,
	ptr.MobilePhone,
	ptr.EmailAddress,
	ptr.OptFurtherContact,
	ptr.MarketingConsent,
	ptr.StateOfArrival	
into [db-au-workspace].dbo.tmp_CustomerDataSet
from	
	[db-au-cmdwh].dbo.penPolicyTraveller ptr with(nolock)
where
	ptr.PolicyKey in
	(
		select distinct PolicyKey
		from [db-au-cmdwh].dbo.penPolicyTransSummary with(nolock)
		where
			CountryKey = @Domain and
			PostingDate >= @rptStartDate and
			PostingDate < dateadd(d,1,@rptEndDate)
	)


-- Merge statement
merge into [db-au-actuary].dataout.CustomerDataSet as DST
using [db-au-workspace].dbo.tmp_CustomerDataSet as SRC
on 
    (
        SRC.PolicyTravellerKey = DST.PolicyTravellerKey and
        SRC.PolicyKey = DST.PolicyKey
    )

-- inserting new records
when not matched by target then
insert
(
	[PolicyTravellerKey],
	[PolicyKey],
	[FirstName],
	[LastName],
	[Age],
	[DOB],
	[isPrimary],
	[isAdult],
	[AdultCharge],
	[AddressLine1],
	[AddressLine2],
	[Suburb],
	[Postcode],
	[State],
	[Country],
	[HomePhone],
	[MobilePhone],
	[EmailAddress],
	[OptFurtherContact],
	[MarketingConsent],
	[StateOfArrival],
	[LoadDate],
	[UpdateDate]
)
values
(
	SRC.[PolicyTravellerKey],
	SRC.[PolicyKey],
	SRC.[FirstName],
	SRC.[LastName],
	SRC.[Age],
	SRC.[DOB],
	SRC.[isPrimary],
	SRC.[isAdult],
	SRC.[AdultCharge],
	SRC.[AddressLine1],
	SRC.[AddressLine2],
	SRC.[Suburb],
	SRC.[Postcode],
	SRC.[State],
	SRC.[Country],
	SRC.[HomePhone],
	SRC.[MobilePhone],
	SRC.[EmailAddress],
	SRC.[OptFurtherContact],
	SRC.[MarketingConsent],
	SRC.[StateOfArrival],
    getdate(),
    getdate()
)
        
-- update existing records where data has changed
when matched then
update
set
	DST.[FirstName] = SRC.[FirstName],
	DST.[LastName] = SRC.[LastName],
	DST.[Age] = SRC.[Age],
	DST.[DOB] = SRC.[DOB],
	DST.[isPrimary] = SRC.[isPrimary],
	DST.[isAdult] = SRC.[isAdult],
	DST.[AdultCharge] = SRC.[AdultCharge],
	DST.[AddressLine1] = SRC.[AddressLine1],
	DST.[AddressLine2] = SRC.[AddressLine2],
	DST.[Suburb] = SRC.[Suburb],
	DST.[PostCode] = SRC.[Postcode],
	DST.[State] = SRC.[State],
	DST.[Country] = SRC.[Country],
	DST.[HomePhone] = SRC.[HomePhone],
	DST.[MobilePhone] = SRC.[MobilePhone],
	DST.[EmailAddress] = SRC.[EmailAddress],
	DST.[OptFurtherContact] = SRC.[OptFurtherContact],
	DST.[MarketingConsent] = SRC.[MarketingConsent],
	DST.[StateOfArrival] = SRC.[StateOfArrival],
	DST.UpdateDate = getdate()
	output $action into @mergeoutput;



--drop temp tables
drop table [db-au-workspace].dbo.tmp_CustomerDataSet
GO
