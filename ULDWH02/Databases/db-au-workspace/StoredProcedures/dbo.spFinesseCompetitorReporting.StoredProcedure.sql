USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[spFinesseCompetitorReporting]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spFinesseCompetitorReporting] @DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10),
										@Competitor varchar(2000),
										@DiscountRate money,	
										@JV         varchar(50),
										@trip   varchar(2000)
as
SET NOCOUNT ON
									
/****************************************************************************************************/
--  Name:           spFinesseCompetitorReporting
--  Author:         RB
--  Date Created:   20180719
--  Description:    Report Traveller's Data for the reporting period.
--  Parameters:     @@DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--					@Competitor: Comma separated Competitor list can be provided for comparison
--  Change History: 20180719 - RB - Created
/****************************************************************************************************/

/*
declare @Competitor varchar(2000)
select @Competitor = 'AHM,Medibank,1Cover'

select
	'test'
from	
	[db-au-actuary].ws.FinesseTravelData f
where
	f.Competitor in (select item from [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Competitor,',')) and
	f.Period 
	*/
	
DECLARE @ExceptionFlag char(1)
DECLARE @DtRange varchar(30)
DECLARE @StDt varchar(10)
DECLARE @EndDt varchar(10)
DECLARE @CompList varchar(2000)
DECLARE @CompCount integer
DECLARE @CompIndex integer
DECLARE @PrevCompIndex integer
DECLARE @CompName varchar(200)
DECLARE @JVName varchar(50)
DECLARE @tripType varchar(2000)
DECLARE @StPos INTEGER
DECLARE @discount_Rate money
DECLARE @rptStartDate datetime
DECLARE @rptEndDate datetime
DECLARE @stmt nvarchar(4000)
DECLARE @QryStmt varchar(4000)
DECLARE @RunId integer
DECLARE @StepNum integer
DECLARE @SqlQry varchar(6000)
DECLARE @SqlQryStmt varchar(6000)
DECLARE @RepSqlQry VARCHAR(8000)
DECLARE @LogDt datetime
DECLARE @RowStmt varchar(8000)
DECLARE @from varchar(1000)
DECLARE @WhrClause varchar(2000)
DECLARE @IntSelect varchar(4000)
DECLARE @MainSelect varchar(4000)
DECLARE @ExceptionMsg varchar(4000)
DECLARE @Where varchar(2000)

SELECT @RunId=1,@ExceptionFlag='N' 

if object_id('[db-au-workspace].dbo.FinesseLogger') is null 
	CREATE TABLE [db-au-workspace].dbo.FinesseLogger (RunId integer,
													StepNum integer,
													SqlQryStmt varchar(4000),
													LogDt datetime
													)
	
ELSE
	 SELECT @RunId = COALESCE(MAX(RunId),0)+1 from [db-au-workspace].dbo.FinesseLogger
		
		
--Get Date Range
IF @DateRange = '_User Defined' 
		IF (CONCAT('N',@StartDate) = 'N' OR CONCAT('N',@EndDate) = 'N') 
			select @ExceptionFlag='Y',@rptStartDate = @StartDate, @rptEndDate= @EndDate,@ExceptionMsg='Please provide Start Date and End Date for Reporting.'
		ELSE select @ExceptionFlag='N',@rptStartDate = @StartDate, @rptEndDate= @EndDate  
ELSE			
	select @rptStartDate = StartDate, @rptEndDate= EndDate 	from [db-au-cmdwh].dbo.vDateRange where DateRange = @DateRange
				
			select @RowStmt=CONCAT('Reporting Start Date is:',@rptStartDate,'and End Date is:',@rptEndDate,' for date range:',@DateRange)
			/*Start Logging*/
						SELECT @StepNum =1 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/

--Get JV Name
set @JVName= @JV 
IF CONCAT('N',@JVName) = 'N' 
		select @ExceptionFlag='Y',@rptStartDate = @StartDate, @rptEndDate= @EndDate,@ExceptionMsg='Please provide JV Name for report generation.' 
ELSE			
	
				
			select @RowStmt=CONCAT('JV Name is:',@JVName)
			/*Start Logging*/
						SELECT @StepNum =2 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/

--Get Competitor List
set @CompList= @Competitor 
IF CONCAT('N',@Competitor) = 'N' 
		select @ExceptionFlag='Y',@rptStartDate = @StartDate, @rptEndDate= @EndDate,@ExceptionMsg='Please provide Competitor List (at least one Competitor) for report generation.' 
ELSE			
	
				
			select @RowStmt=CONCAT('Competitor List is:',@CompList)
			/*Start Logging*/
						SELECT @StepNum =3 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/

IF @ExceptionFlag='Y' 
		select @ExceptionMsg
else
	BEGIN 
		SELECT @discount_rate = @DiscountRate
		IF @discount_rate IS NULL SET @discount_Rate = 0.0
		SELECT @tripType = @trip
		IF @tripType IS NULL SELECT  @tripType= 'Single Trip'
		


	
		if object_id('tempdb..##quotes1') is not null drop table ##quotes1 
			Select * INTO ##quotes1 from [db-au-actuary].ws.FinesseTravelData q--[db-au-workspace].dbo.WorkFinesseTravelData q 
						where q.PeriodEndDate >= @rptStartDate and q.PeriodEndDate < dateadd(d,1,@rptEndDate)

		if object_id('tempdb..##destination_mapping') is not null drop table ##destination_mapping
			SELECT [destinationregion], [destination],destination2 INTO ##destination_mapping 
				FROM (Select [destinationregion], [destination],case when [destination] = 'UK' then 'UK'
																		when [destination] = 'Australia' then 'Australia'          
																		when [destination] = 'NZ' then 'NZ'
																		when [destinationregion] = 'North America' then 'Americas and Africa'
																		when [destinationregion] = 'South America' then 'Americas and Africa'
																		when [destinationregion] = 'Africa' then 'Americas and Africa'
																		when [destination] = 'Bali' then 'Indonesia'
																	else [destinationregion]	
																		end 
																	as destination2
						from ##quotes1   
						)D
						GROUP BY [destinationregion], [destination],destination2 
		
		select @RowStmt=CONCAT('Built Destination Mapping set for PeriodEndDate between:',@rptStartDate,' and ',@rptEndDate,' for date range:',@DateRange)
			/*Start Logging*/
						SELECT @StepNum =4 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/

		if object_id('tempdb..##age_oldest_adult_band') is not null drop table ##age_oldest_adult_band
			 SELECT [age of oldest adult] as[age of oldest adult]  ,[age of oldest adult - band2] as [age of oldest adult - band2] INTO ##age_oldest_adult_band 
					FROM (SELECT [ageofoldestadult] AS [age of oldest adult], case when [ageofoldestadult] >= 60 and [ageofoldestadult] <= 64  then '60-64'
												when [ageofoldestadult] >= 65 and [ageofoldestadult]<= 69  then '65-69'
												when [ageofoldestadult] >= 75 then '75+'
												else [ageofoldestadultband]
											end as [age of oldest adult - band2]
							from ##quotes1
						)A GROUP BY [age of oldest adult],[age of oldest adult - band2] 
				
		select @RowStmt=CONCAT('Built Age of Oldest Adult Band Mapping set for PeriodEndDate between:',@rptStartDate,' and ',@rptEndDate,' for date range:',@DateRange)
			/*Start Logging*/
						SELECT @StepNum =5 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
		
		SELECT @CompList = @Competitor
		
		if object_id('tempdb..##competitorsList') is not null drop table ##competitorsList
			select @CompCount=LEN(@CompList)-LEN(REPLACE(@CompList,',',''))+1
			SELECT item as item into ##competitorsList from [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@CompList,',')
		
		select @RowStmt=CONCAT('List of Competitors ',@CompList,' loaded into ##competitorsList. Number of Competitors for comparison:',@CompCount)
			
			/*Start Logging*/
						SELECT @StepNum =6 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
		
		if object_id('tempdb..##quotes2') is not null drop table ##quotes2
			select 
				q.period as [period]
				, a.[age of oldest adult - band2]
			   , q.destination
			   , q.[destinationregion]
				, d.destination2
				, q.[samplenumber] as [sample number]
				, q.[singlemultitripband] as [single multi trip - band]
				, q.[internationaldomestic] as [international domestic]
				, q.[traveldurationbands] as [travel duration bands]
				,q.[CompetitorPremium]  
				,q.[Competitor] as [CompetitorName]
				,q.[CompetitorProduct] as [Product]
				,@CompCount as CompCount				 
				into ##quotes2 from ##quotes1 q
								left join ##destination_mapping as d on q.[destination] = d.[destination]
								left join ##age_oldest_adult_band as a on q.[ageofoldestadult] = a.[age of oldest adult]
								where q.[Competitor] in (SELECT item from ##competitorsList)
		
		if object_id('tempdb..##quotes3') is not null drop table ##quotes3
				select period as [period], [age of oldest adult - band2] as [age of oldest adult - band2]
					, destination2 as [destination2], [sample number] as [sample number]
					, [single multi trip - band]
					, [international domestic]
					, [travel duration bands]
					,cast([CompetitorPremium] as money) as [CompetitorPremium]
					,case when cast(CompetitorPremium as money) <> 0 then 1 else 0 end as [CompetitorPremium ne 0] 
					,@CompCount as CompCount
					,[CompetitorName] as Competitor
					,[Product] as Product 
				into ##quotes3 
					from ##quotes2 
					
		if object_id('tempdb..##quotes4') is not null drop table ##quotes4 
			select *,
				[CompetitorPremium ne 0] as include_in_calc
				into ##quotes4 from ##quotes3
				
		if object_id('tempdb..##policies1') is not null drop table ##policies1

		SELECT @WhrClause= CONCAT(' [domain country] = ''AU'' and [JV Description] =''',@JVName, ''' and [issue date] >= ''', 
									@rptStartDate,''' and [issue date] < dateadd(d,1,''',@rptEndDate,''') and [trip type] IN (',@tripType,')')

			SELECT @JVName , @rptStartDate ,@rptEndDate,@tripType

		 select policykey
				, case 
					when [oldest age] <= 19 then '<20'
					when [oldest age] between 20 and 24 then '20-24'
					when [oldest age] between 25 and 29 then '25-29'
					when [oldest age] between 30 and 39 then '30-39'
					when [oldest age] between 40 and 49 then '40-49'
					when [oldest age] between 50 and 59 then '50-59'
					when [oldest age] between 60 and 64 then '60-64'
					when [oldest age] between 65 and 69 then '65-69'
					when [oldest age] between 70 and 74 then '70-74'
					when [oldest age] >= 75 then '75+'
					end
					as [age_band]
				, case 
					when [trip duration] <= 7 then '0 to 7'
					when [trip duration] between 8 and 14 then '8 to 14'
					when [trip duration] between 15 and 21 then '15 to 21'
					when [trip duration] between 22 and 28 then '22 to 28'
					when [trip duration] between 29 and 35 then '29 to 35'
					when [trip duration] between 36 and 42 then '36 to 42'
					when [trip duration] between 43 and 49 then '43 to 49'
					when [trip duration] between 50 and 56 then '50 to 56'
					when [trip duration] between 57 and 63 then '57 to 63'
					when [trip duration] between 64 and 70 then '64 to 70'
					when [trip duration] between 71 and 77 then '71 to 77'
					when [trip duration] between 78 and 84 then '78 to 84'
					when [trip duration] between 85 and 91 then '85 to 91'
					when [trip duration] between 92 and 98 then '92 to 98'
					when [trip duration] between 99 and 105 then '99 to 105'
					when [trip duration] between 106 and 140 then '106 to 140'
					when [trip duration] between 141 and 365 then '141 to 365'
					end
					as [duration_band]
				,case [destination]
					when 'Afghanistan' then 'Europe'
					when 'Albania' then 'Europe'
					when 'All of Africa' then 'Americas and Africa'
					when 'All of Asia' then 'Asia'
					when 'All of Europe' then 'Europe'
					when 'All of North America' then 'Americas and Africa'
					when 'All of South America' then 'Americas and Africa'
					when 'All of South Pacific' then 'Oceania'
					when 'All of the Americas' then 'Americas and Africa'
					when 'All of the Middle East' then 'Europe'
					when 'All of the Pacific' then 'Oceania'
					when 'All of UK' then 'UK'
					when 'American Samoa' then 'Oceania'
					when 'Andorra' then 'Europe'
					when 'Antarctica (Cruising)' then 'Antarctica'
					when 'Antarctica-Sightseeing Flight' then 'Antarctica'
					when 'Anywhere in the world' then 'Americas and Africa'
					when 'Argentina' then 'Americas and Africa'
					when 'Armenia' then 'Europe'
					when 'Aruba' then 'Americas and Africa'
					when 'Australia' then 'Australia'
					when 'Austria' then 'Europe'
					when 'Azerbaijan' then 'Europe'
					when 'Bahamas' then 'Americas and Africa'
					when 'Bahrain' then 'Europe'
					when 'Bangladesh' then 'Asia'
					when 'Barbados' then 'Americas and Africa'
					when 'Belarus' then 'Europe'
					when 'Belgium' then 'Europe'
					when 'Belize' then 'Americas and Africa'
					when 'Bermuda' then 'Americas and Africa'
					when 'Bhutan' then 'Europe'
					when 'Bolivia' then 'Americas and Africa'
					when 'Bosnia' then 'Europe'
					when 'Botswana' then 'Americas and Africa'
					when 'Brazil' then 'Americas and Africa'
					when 'Brunei' then 'Asia'
					when 'Bulgaria' then 'Europe'
					when 'Burundi' then 'Americas and Africa'
					when 'Cambodia' then 'Asia'
					when 'Cameroon' then 'Americas and Africa'
					when 'Canada' then 'Americas and Africa'
					when 'Caribbean' then 'Americas and Africa'
					when 'Cayman Islands' then 'Americas and Africa'
					when 'Central African Republic' then 'Americas and Africa'
					when 'Chile' then 'Americas and Africa'
					when 'China' then 'Asia'
					when 'Colombia' then 'Americas and Africa'
					when 'Cook Islands' then 'Oceania'
					when 'Costa Rica' then 'Americas and Africa'
					when 'Croatia' then 'Europe'
					when 'Cruise – Asia' then 'Asia'
					when 'Cruise – Europe' then 'Europe'
					when 'Cruise – Pacific' then 'Oceania'
					when 'Cruise – Worldwide' then 'Americas and Africa'
					when 'Cuba' then 'Americas and Africa'
					when 'Cyprus' then 'Europe'
					when 'Czech Republic' then 'Europe'
					when 'Denmark' then 'Europe'
					when 'Domestic Cruise' then 'Australia'
					when 'Dominican Rep.' then 'Americas and Africa'
					when 'East Timor' then 'oceania'
					when 'Ecuador' then 'Americas and Africa'
					when 'Egypt' then 'Americas and Africa'
					when 'El Salvador' then 'Americas and Africa'
					when 'England' then 'UK'
					when 'Eritrea' then 'Americas and Africa'
					when 'Estonia' then 'Europe'
					when 'Ethiopia' then 'Americas and Africa'
					when 'Federated States of Micronesia' then 'oceania'
					when 'Fiji' then 'oceania'
					when 'Finland' then 'Europe'
					when 'France' then 'Europe'
					when 'French Polynesia' then 'oceania'
					when 'Georgia' then 'Europe'
					when 'Germany' then 'Europe'
					when 'Ghana' then 'Americas and Africa'
					when 'Gibraltar' then 'Europe'
					when 'Greece' then 'Europe'
					when 'Greenland' then 'europe'
					when 'Grenada' then 'Americas and Africa'
					when 'Guam' then 'oceania'
					when 'Guatemala' then 'Americas and Africa'
					when 'Guernsey (Channel Islands)' then 'UK'
					when 'Guinea' then 'Oceania'
					when 'Haiti' then 'Oceania'
					when 'Herzegovina' then 'Europe'
					when 'Honduras' then 'Americas and Africa'
					when 'Hong Kong' then 'Asia'
					when 'Hungary' then 'Europe'
					when 'Iceland' then 'Europe'
					when 'India' then 'Asia'
					when 'Indonesia' then 'Indonesia'
					when 'Iran' then 'Europe'
					when 'Iraq' then 'Europe'
					when 'Israel' then 'Europe'
					when 'Italy' then 'Europe'
					when 'Ivory Coast' then 'Americas and Africa'
					when 'Jamaica' then 'Americas and Africa'
					when 'Japan' then 'Asia'
					when 'Jersey (Channel Island)' then 'UK'
					when 'Jordan' then 'Europe'
					when 'Kazakhstan' then 'Europe'
					when 'Kenya' then 'Americas and Africa'
					when 'Kiribati' then 'Oceania'
					when 'Korea (south)' then 'Asia'
					when 'Kosovo' then 'Europe'
					when 'Kuwait' then 'Europe'
					when 'Kyrgyzstan' then 'Europe'
					when 'Laos' then 'Asia'
					when 'Latvia' then 'Europe'
					when 'Lebanon' then 'Europe'
					when 'Lesotho' then 'Americas and Africa'
					when 'Liechtenstein' then 'Europe'
					when 'Lithuania' then 'Europe'
					when 'Luxembourg' then 'Europe'
					when 'Macau' then 'Asia'
					when 'Macedonia' then 'Europe'
					when 'Madagascar' then 'Americas and Africa'
					when 'Malawi' then 'Americas and Africa'
					when 'Malaysia' then 'Asia'
					when 'Maldives' then 'Asia'
					when 'Malta' then 'Europe'
					when 'Martinique' then 'Americas and Africa'
					when 'Mauritius' then 'Americas and Africa'
					when 'Mexico' then 'Americas and Africa'
					when 'Moldova' then 'Europe'
					when 'Monaco' then 'Europe'
					when 'Mongolia' then 'Europe'
					when 'Montenegro' then 'Europe'
					when 'Morocco' then 'Americas and Africa'
					when 'Mozambique' then 'Americas and Africa'
					when 'Myanmar (Burma)' then 'Asia'
					when 'Namibia' then 'Americas and Africa'
					when 'Nauru' then 'Oceania'
					when 'Nepal' then 'Asia'
					when 'Netherlands' then 'Europe'
					when 'Netherlands Antilles' then 'Americas and Africa'
					when 'New Caledonia' then 'Oceania'
					when 'New Zealand' then 'New Zealand'
					when 'Nicaragua' then 'Americas and Africa'
					when 'Nigeria' then 'Americas and Africa'
					when 'Norfolk Island' then 'Australia'
					when 'Northern Ireland' then 'UK'
					when 'Norway' then 'Europe'
					when 'Oman' then 'Europe'
					when 'Pakistan' then 'Europe'
					when 'Palau' then 'Oceania'
					when 'Palestine' then 'Europe'
					when 'Panama' then 'Americas and Africa'
					when 'Papua New Guinea' then 'Oceania'
					when 'Paraguay' then 'Americas and Africa'
					when 'Peru' then 'Americas and Africa'
					when 'Philippines' then 'Asia'
					when 'Poland' then 'Europe'
					when 'Portugal' then 'Europe'
					when 'Puerto Rico' then 'Americas and Africa'
					when 'Qatar' then 'Europe'
					when 'Republic of Ireland' then 'UK'
					when 'Reunion' then 'Americas and Africa'
					when 'Romania' then 'Europe'
					when 'Russia' then 'Europe'
					when 'Rwanda' then 'Americas and Africa'
					when 'Samoa' then 'Oceania'
					when 'Saudi Arabia' then 'Europe'
					when 'Scotland' then 'UK'
					when 'Senegal' then 'Americas and Africa'
					when 'Serbia' then 'Europe'
					when 'Seychelles' then 'Americas and Africa'
					when 'Sierra Leone' then 'Americas and Africa'
					when 'Singapore' then 'Asia'
					when 'Slovakia' then 'Europe'
					when 'Slovenia' then 'Europe'
					when 'Solomon Islands' then 'Oceania'
					when 'Somalia' then 'Americas and Africa'
					when 'South Africa' then 'Americas and Africa'
					when 'South Korea' then 'Asia'
					when 'South West Pacific Cruise' then 'Oceania'
					when 'Spain' then 'Europe'
					when 'Sri Lanka' then 'Europe'
					when 'St. Kitts-Nevis' then 'Americas and Africa'
					when 'St. Lucia' then 'Americas and Africa'
					when 'St. Vincent & Grenadines' then 'Americas and Africa'
					when 'Sudan' then 'Americas and Africa'
					when 'Swaziland' then 'Americas and Africa'
					when 'Sweden' then 'Europe'
					when 'Switzerland' then 'Europe'
					when 'Syria' then 'Europe'
					when 'Taiwan' then 'Asia'
					when 'Tanzania' then 'Americas and Africa'
					when 'Thailand' then 'Asia'
					when 'Tonga' then 'Oceania'
					when 'Trinidad & Tobago' then 'Americas and Africa'
					when 'Tunisia' then 'Americas and Africa'
					when 'Turkey' then 'Europe'
					when 'Turkmenistan' then 'Europe'
					when 'Uganda' then 'Americas and Africa'
					when 'Ukraine' then 'Europe'
					when 'United Arab Emirates' then 'Europe'
					when 'United States of America' then 'Americas and Africa'
					when 'Uruguay' then 'Americas and Africa'
					when 'Uzbekistan' then 'Europe'
					when 'Vanuatu' then 'Oceania'
					when 'Venezuela' then 'Americas and Africa'
					when 'Vietnam' then 'Asia'
					when 'Wales' then 'UK'
					when 'Western Samoa' then 'Oceania'
					when 'Yemen' then 'Europe'
					when 'Zambia' then 'Americas and Africa'
					when 'Zimbabwe' then 'Americas and Africa'
					end
					as [destination2]
				into ##policies1 
				from 
				[uldwh02].[db-au-actuary].dbo.dwhdatasetsummary 
				where  [domain country] = 'AU' and [JV Description] =@JVName
				and [issue date] >= @rptStartDate and [issue date] < dateadd(d,1,@rptEndDate) 
				   and [trip type] IN (@tripType)
				
		IF (@tripType IS NULL ) 
			BEGIN
			SELECT DISTINCT @JVName as JV,Competitor,Product,Period,Age,Duration,Area,[Average Premium],[Average Premium] * (1-@discount_rate) as [Discounted comprehensive prem],	
							PolicyCount
					FROM 
					(SELECT 		
					Competitor,Product,q.period as Period,AVG(CompetitorPremium) OVER (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
													 as [Average Premium]	,
					p.[destination2] as Area,	p.[duration_band] as Duration,	
					q.[age of oldest adult - band2] AS [Age] ,
					count(PolicyKey) over (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
					as PolicyCount
					FROM 
					##quotes4 q left join ##policies1 as p 
						on q.[age of oldest adult - band2] = p.age_band
						and q.[travel duration bands] = p.duration_band
						and q.destination2 = p.destination2 
						where 
							include_in_calc = 1 
							and [single multi trip - band] = 'Single Trip'
							and [international domestic] = 'International'
					)P1

				select @RowStmt='SELECT DISTINCT @JVName as JV,Competitor,Product,Period,Age,Duration,Area,[Average Premium],[Average Premium] * (1-@discount_rate) as [Discounted comprehensive prem],	
							PolicyCount
					FROM 
					(SELECT 		
					Competitor,Product,q.period as Period,AVG(CompetitorPremium) OVER (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
													 as [Average Premium]	,
					p.[destination2] as Area,	p.[duration_band] as Duration,	
					q.[age of oldest adult - band2] AS [Age] ,
					count(PolicyKey) over (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
					as PolicyCount
					FROM 
					##quotes4 q left join ##policies1 as p 
						on q.[age of oldest adult - band2] = p.age_band
						and q.[travel duration bands] = p.duration_band
						and q.destination2 = p.destination2 
						where 
							include_in_calc = 1 
									and [single multi trip - band] = ''Single Trip''
									and [international domestic] = ''International''
									)P1'
			END
		ELSE 
			BEGIN
			SELECT DISTINCT @JVName as JV,Competitor,Product,Period,Age,Duration,Area,[Average Premium],[Average Premium] * (1-@discount_rate) as [Discounted comprehensive prem],	
							PolicyCount
					FROM 
					(SELECT 		
					Competitor,Product,q.period as Period,AVG(CompetitorPremium) OVER (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
													 as [Average Premium]	,
					p.[destination2] as Area,	p.[duration_band] as Duration,	
					q.[age of oldest adult - band2] AS [Age] ,
					count(PolicyKey) over (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
					as PolicyCount
					FROM 
					##quotes4 q left join ##policies1 as p 
						on q.[age of oldest adult - band2] = p.age_band
						and q.[travel duration bands] = p.duration_band
						and q.destination2 = p.destination2 
						where 
							include_in_calc = 1 
							and [single multi trip - band] = 'Single Trip'
							)P1
					
			
			select @RowStmt='SELECT DISTINCT @JVName as JV,Competitor,Product,Period,Age,Duration,Area,[Average Premium],[Average Premium] * (1-@discount_rate) as [Discounted comprehensive prem],	
							PolicyCount
					FROM 
					(SELECT 		
					Competitor,Product,q.period as Period,AVG(CompetitorPremium) OVER (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
													 as [Average Premium]	,
					p.[destination2] as Area,	p.[duration_band] as Duration,	
					q.[age of oldest adult - band2] AS [Age] ,
					count(PolicyKey) over (partition by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band]
													order by q.[age of oldest adult - band2],Competitor,Product,p.[destination2], p.[duration_band])
					as PolicyCount
					FROM 
					##quotes4 q left join ##policies1 as p 
						on q.[age of oldest adult - band2] = p.age_band
						and q.[travel duration bands] = p.duration_band
						and q.destination2 = p.destination2 
						where 
							include_in_calc = 1 
							and [single multi trip - band] =''Single Trip''
							)P1'
			END
			/*Start Logging*/
						SELECT @StepNum =7 , @SqlQryStmt =CONCAT('Procedure spFinesseCompetitorReporting: ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/


		
	END
		
GO
