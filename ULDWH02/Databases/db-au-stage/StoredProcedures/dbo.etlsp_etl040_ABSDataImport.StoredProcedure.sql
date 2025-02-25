USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl040_ABSDataImport]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_etl040_ABSDataImport]
as

SET NOCOUNT ON


/****************************************/
-- transform and load [db-au-cmdwh].dbo.usrABSData 
/****************************************/

--remove last 3 rows which are not valid records
delete [db-au-stage].dbo.etl_ABSDataImport
where Country is null or Country = ''

--UPDATE [db-au-stage].dbo.etl_ABSDataImport SET [Month] = '2019-10-01' -- EV - Adhoc to load missing Oct 2019 data

if object_id('[db-au-stage].dbo.etl_ABSData_Temp') is not null drop table [db-au-stage].dbo.etl_ABSData_Temp
select
	--case when [Month] like '%january%' then convert(datetime,right([Month],4)+'-01-01')
	--	 when [Month] like '%february%' then convert(datetime,right([Month],4)+'-02-01')
	--	 when [Month] like '%march%' then convert(datetime,right([Month],4)+'-03-01')
	--	 when [Month] like '%april%' then convert(datetime,right([Month],4)+'-04-01')
	--	 when [Month] like '%may%' then convert(datetime,right([Month],4)+'-05-01')
	--	 when [Month] like '%june%' then convert(datetime,right([Month],4)+'-06-01')
	--	 when [Month] like '%july%' then convert(datetime,right([Month],4)+'-07-01')
	--	 when [Month] like '%august%' then convert(datetime,right([Month],4)+'-08-01')
	--	 when [Month] like '%september%' then convert(datetime,right([Month],4)+'-09-01')
	--	 when [Month] like '%october%' then convert(datetime,right([Month],4)+'-10-01')
	--	 when [Month] like '%november%' then convert(datetime,right([Month],4)+'-11-01')
	--	 when [Month] like '%december%' then convert(datetime,right([Month],4)+'-12-01')
	--	 else convert(datetime,null)
	--end as [Month],		--convert to month year string to datetime
	convert(datetime,[Month],120) as [Month],
	case when DurationGroup in ('Under 1 week', 'Under 1 wk') then 'Under 1wk'
		 when DurationGroup in ('1 and under 2 weeks', '1 wk & under 2 wks') then '1 - 2wks'
		 when DurationGroup in ('2 weeks and under 1 month', '2 wks & under 1 mth') then '2 - 4wks'
		 when DurationGroup in ('1 and under 2 months', '1 & under 2 mths') then '1 - 2mths'
		 when DurationGroup in ('2 and under 3 months', '2 & under 3 mths') then '2 - 3mths'
		 when DurationGroup in ('3 and under 6 months', '3 & under 6 mths') then '3 - 6mths'
		 when DurationGroup in ('6 and under 12 months', '6 & under 12 mths') then '6 - 12mths'
		 else 'Unknown'
	end as DurationGroup,	
	case when AgeGroup = '0-16' then '0 - 16'
		 when AgeGroup = '17-24' then '17 - 24'
		 when AgeGroup = '25-34' then '25 - 34'
		 when AgeGroup = '35-49' then '35 - 49'
		 when AgeGroup = '50-59' then '50 - 59'
		 when AgeGroup = '60-64' then '60 - 64'
		 when AgeGroup = '65-69' then '65 - 69'
		 when AgeGroup = '70-74' then '70 - 74'
		 when AgeGroup = '75 years and over' then '> 75'
		 else 'Unknown'
	end as AgeGroup,
	Country,
	case when Country in ('Argentina','Brazil','Canada','Chile','Mexico','United States of America','USA','Other Americas') then 'Americas'
		 when Country in ('Egypt','Israel','Lebanon','Turkey','Unit Arab Emir','Other North Africa and the Middle East') then 'North Africa and the Middle East'
		 when Country in ('China','Hong Kong','Japan','Korea, South','Taiwan','Other North-East Asia') then 'North-East Asia'
		 when Country in ('Austria','France','Germany','Ireland','Netherlands','Sweden','Switzerland','UK, CIs & IOM','Other North-West Europe') then 'North-West Europe'
		 when Country in ('Australia','Cook Islands','Fiji','French Polynesia','French Poly','New Caledonia','New Zealand','Norfolk Island','Papua New Guinea','PNG','Samoa','Tonga','Vanuatu','Other Oceania and Antarctica') then 'Oceania and Antarctica'
		 when Country in ('Cambodia','Indonesia','Malaysia','Philippines','Singapore','Thailand','Timor-Leste','Vietnam','Other South-East Asia') then 'South-East Asia'
		 when Country in ('India','Nepal','Pakistan','Sri Lanka','Other Southern and Central Asia') then 'Southern and Central Asia'
		 when Country in ('Croatia','Greece','Italy','Poland','Spain','Other Southern and Eastern Europe') then 'Southern and Eastern Europe'
		 when Country in ('Mauritius','South Africa','Other Sub-Saharan Africa') then 'Sub-Saharan Africa'
		 else 'Unknown'
	end as CountryGroup,		--set CountryGroup
	Reason,
	convert(int,TravellerCount) as TravellersCount
into [db-au-stage].dbo.etl_ABSData_Temp	
from
	[db-au-stage].dbo.etl_ABSDataImport
where				--exclude CountryGroup totals
	Country not in ('Oceania and Antarctica',
					'Southern and Central Asia',
					'North-East Asia',
					'South-East Asia',
					'North-West Europe',
					'Southern and Eastern Europe',
					'North Africa and the Middle East',
					'Sub-Saharan Africa',
					'Americas')
					
					
if object_id('[db-au-cmdwh].dbo.usrABSData') is null
begin
	create table [db-au-cmdwh].dbo.usrABSData
	(
		[Month] datetime null,
		FYear varchar(7) null,
		CYear int null,
		DurationGroup nvarchar(50) null,
		AgeGroup nvarchar(50) null,
		Country nvarchar(200) null,
		CountryGroup nvarchar(200) null,
		Reason nvarchar(100) null,
		TravellersCount int null
	)
    create clustered index idx_usrABSData_Month on [db-au-cmdwh].dbo.usrABSData([Month])
end
else
begin
	delete a
	from 
		[db-au-cmdwh].dbo.usrABSData a
		join [db-au-stage].dbo.etl_ABSData_Temp b on 
			a.[Month] = b.[Month]
end
	

insert [db-au-cmdwh].dbo.usrABSData with(tablockx)
(
	[Month],
	FYear,
	CYear,
	DurationGroup,
	AgeGroup,
	Country,
	CountryGroup,
	Reason,
	TravellersCount
)    			
select
	[Month],
	convert(varchar,Year([db-au-cmdwh].dbo.fn_dtCurFiscalYearStart([Month]))) + '/' + right(convert(varchar,Year([db-au-cmdwh].dbo.fn_dtCurFiscalYearEnd([Month]))),2) as FYear,
	[db-au-cmdwh].dbo.fn_dtCurYearNum([Month]) as CYear,
	DurationGroup,
	AgeGroup,
	Country,
	CountryGroup,
	Reason,
	TravellersCount
from
	[db-au-stage].dbo.etl_ABSData_Temp		

GO
