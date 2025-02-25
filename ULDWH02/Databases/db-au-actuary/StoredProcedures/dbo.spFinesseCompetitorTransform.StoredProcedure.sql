USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[spFinesseCompetitorTransform]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spFinesseCompetitorTransform] @DateRange varchar(30),
													@StartDate varchar(10),
													@EndDate varchar(10),
													@Region varchar(10),
													@SourceTable varchar(30)										
as
SET NOCOUNT ON
									
/**********************************************************************************************************************************/
--  Name:           spFinesseCompetitorTransform
--  Author:         RB
--  Date Created:   20180712
--  Description:    Transform Traveller's Data for the reporting period.
--  Parameters:     @DateRange: standard date range or _User Defined, or NULL
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2018-01-01
--					@Region: ???
--					@SourceTable: name of table to be transformed and loaded in [db-au-actuary] database.
--  Change History:
--					20180712 - RB - Created
--					20180719 - RB - Updated to reflect correct product and competitor in case of no Product - defaulted to 'Default'
--					20180719 - RB - Updated to handle invalid dates with '0001' year format
/***********************************************************************************************************************************/


--uncomment to debug
/*
declare @SourceTable varchar(30)
declare @Region varchar(10)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = null, @StartDate = null, @EndDate = null, @Region = null, @SourceTable = 'FinesseTravelDataAUSJun18'
*/

DECLARE @SrcTab varchar(30)
DECLARE @stmt nvarchar(4000)
DECLARE @QryStmt varchar(4000)
DECLARE @FinesseQryStmt1  nvarchar(3500)
DECLARE @FinesseQryStmt2  nvarchar(4000)
DECLARE @FinesseQry  nvarchar(4000)
DECLARE @CompNm varchar(255)
DECLARE @Comp varchar(255)
DECLARE @CompPr varchar(255)
DECLARE @CompeCol1 varchar(255)
DECLARE @CompeCol2 varchar(255)
DECLARE @CompeCol3 varchar(255)
DECLARE @SrcTableNm varchar(30)
DECLARE @QryLoad varchar(5000)
DECLARE @FinesseLoadQry varchar(5000)
DECLARE @RunId integer
DECLARE @StepNum integer
DECLARE @SqlQryStmt varchar(4000)
DECLARE @LogDt datetime
DECLARE @RowStmt varchar(5000)
DECLARE @PatFound smallint
DECLARE @Pat varchar(50)
DECLARE @PatLoc integer
DECLARE @ExceptionCompetitors varchar(5000)
DECLARE @ExcepPatLoc integer

SELECT @RunId=1

if object_id('[db-au-workspace].dbo.FinesseLogger') is null 
	CREATE TABLE [db-au-workspace].dbo.FinesseLogger (RunId integer,
													StepNum integer,
													SqlQryStmt varchar(4000),
													LogDt datetime
													)
			
	ELSE
	 SELECT @RunId = COALESCE(MAX(RunId),0)+1 from [db-au-workspace].dbo.FinesseLogger
		
--Get source table
if CONCAT('N',@Region)='N'
	select @Region='AUS'

if CONCAT('No Value',@SourceTable) = 'No Value' 
	select @SrcTab = CONCAT('FinesseTravelData',@Region)
else 
	select @SrcTab = @SourceTable
	
	if object_id('tempdb..##RBTabDef') is not null drop table 	[db-au-workspace].##RBTabDef
		CREATE TABLE [db-au-workspace].##RBTabDef ( TABLE_NAME varchar(255),COLUMN_NAME varchar(255))		

--Build Dynamic Query tO Load all the Table Names and Column names into Temp table RBTabDef.
	
	SELECT @stmt = 'INSERT INTO [db-au-workspace].##RBTabDef /*[db-au-workspace].##RBTabDef*/ (TABLE_NAME,COLUMN_NAME ) SELECT T.TABLE_NAME,C.COLUMN_NAME FROM [db-au-actuary].INFORMATION_SCHEMA.TABLES T 
					INNER JOIN [db-au-actuary].INFORMATION_SCHEMA.COLUMNS C ON  C.TABLE_CATALOG=T.TABLE_CATALOG 
					AND C.TABLE_NAME=T.TABLE_NAME WHERE T.TABLE_CATALOG =''db-au-actuary'' and T.TABLE_NAME LIKE ''%' + @SrcTab + 
					'%'' GROUP BY T.TABLE_NAME , C.COLUMN_NAME order by T.TABLE_NAME , C.COLUMN_NAME;'
	
	SELECT @StepNum =1 , @SqlQryStmt =@stmt ,@LogDt =CURRENT_TIMESTAMP
	INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )



--Load all the Table Names and Column names into Temp table RBTabDef.
	EXEC sp_executesql @stmt ,N'@SrcTab NVARCHAR(255)', @SrcTab = @SrcTab
	
--Build Dynamic Query To Load all the SELECT STATEMENTS INTO Temp table ##RBQryTab.
   
   if object_id('tempdb..##RBQryTab') is not null drop table [db-au-workspace].##RBQryTab
    
	SELECT DISTINCT 
			min(All_Comp.COLUMN_NAME) over (partition by All_Comp.Competitors order by All_Comp.Competitors) AS CompetitorColumn1,
			max(All_Comp.COLUMN_NAME) over (partition by All_Comp.Competitors order by All_Comp.Competitors) AS CompetitorColumn2,
			P.COLUMN_NAME AS CompetitorColumn3, All_Comp.Competitors AS CompetitorName,All_Comp.SrcTbNm AS SrcTbNm 
		INTO [db-au-workspace].##RBQryTab
	FROM     
	(
		select Column_name,SUBSTRING(RTRIM(Column_name),1,LEN(RTRIM(COLUMN_NAME))-8) As Competitors, TABLE_NAME AS  SrcTbNm
		from [db-au-workspace].##RBTabDef where COLUMN_NAME like '%Premium' 
		union 
		select Column_name,SUBSTRING(RTRIM(Column_name),1,LEN(RTRIM(COLUMN_NAME))-10) As Competitors ,TABLE_NAME AS  SrcTbNm
		from [db-au-workspace].##RBTabDef where COLUMN_NAME like '%Timestamp' 
		union 
		select Column_name,SUBSTRING(RTRIM(Column_name),1,LEN(RTRIM(COLUMN_NAME))-6) As Competitors ,TABLE_NAME AS  SrcTbNm
		from [db-au-workspace].##RBTabDef where COLUMN_NAME like '%Notes' 
		) All_Comp
  left outer join 	
		(select Column_name,SUBSTRING(RTRIM(Column_name),1,LEN(RTRIM(COLUMN_NAME))-8) As Competitors,
		  TABLE_NAME AS SrcTbNm 
		from [db-au-workspace].##RBTabDef where COLUMN_NAME like '%Premium' 
		) P on All_Comp.Competitors=P.Competitors
			AND All_Comp.SrcTbNm = P.SrcTbNm

--Build list of all Companies to derive CompetitorName and CompetitorProduct

		if object_id('[db-au-workspace].dbo.FinesseAllCompanies') is not null drop table [db-au-workspace].dbo.FinesseAllCompanies
			SELECT distinct 1 AS UNI_JOIN ,CompanyName into [db-au-workspace].dbo.FinesseAllCompanies  from  [db-au-star].dbo.dimPolicy 

--Build list of all Product patterns to derive CompetitorName and CompetitorProduct


		if object_id('[db-au-workspace].dbo.FinesseAllPatterns') is not null drop table [db-au-workspace].dbo.FinesseAllPatterns
			CREATE TABLE FinesseAllPatterns(PatternId integer identity(1,1),
											PatternText varchar(100))
			insert into FinesseAllPatterns(patterntext)	values ('FI NAB Comprehensive'),
			('Multi Trip Medical'),('Multi Trip Premium'),('Single Trip Medical'),('Single Trip Premium'),
			('Frequent Traveller Comprehensive'),('Bare Essentials'),('Multi Trip Comprehensive'),
			('Multi Trip OptionsPlan'),('Single Trip OptionsPlan'),('Multi Trip TravelsurePlan'), ('Single Trip TravelsurePlan'),
			('Under 30 Annual Multi'),('Under 30 Single Trip'),('Australia Only'),('The Works'),
			('Budget Direct'),('National Seniors' ),('Extra Travel Care'),('Total Travel Care'),
			('Aus Cancellation'),('Australian Comprehensive'),('International Comprehensive'),
			 ('OptionsPlan'),('TravelsurePlan'), ('Joey'),('Travel Care'), ('Deluxe'), ('Premier'), ('Explorer'),
			( 'Medical'), ('Comprehensive'),('Frequent'),
			 ('Annual'), ('Bare') , ('Essential'),   ('Elite'),   ('Domestic'),
			 ('Premium'),   ('Budget'),   ('Basic'),   ('Mid') ,
			 ('Top'),   ('Direct'),   ('Economy'),   ('Standard') ,
			('Super'),   ('Prestige'),   ('Multi'),   (  'Single'), 
			  ('TID'),   ( 'Mature'),    
			  ('Gold'),   ( 'Silver'),   ( 'Adventurer'), 
			  ('Trekker'),   ( 'Pioneer'),   ( 'Wanderer'),   ('Big Red'), 
			 ('Frequent'),   ('Eastern'), ('Rock Wallaby'),  ('Wallaby'),   ('Senior'),
			 ('Cancellation'),   ('Rental'),('Saver'), ('Savers'),   ('Under'),
			    ('Extra'),   ( 'Total'),   ( 'Classic'),('Cancellation')
				

	--Build list of Exception patterns to derive CompetitorName and CompetitorProduct
		  --select @ExceptionCompetitors=	CONCAT('National Seniors' ,',', 'Budget Direct')
		
	--DECLARE CurPat CURSOR FOR SELECT PatternText FROM [db-au-workspace].dbo.FinesseAllPatterns 

	/*Start Logging*/
				SELECT @StepNum =2 , @SqlQryStmt ='Built Cursor with Search patterns' ,@LogDt =CURRENT_TIMESTAMP
				INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
				/*End of Logging*/	


		/*Start Logging*/
				SELECT @StepNum =3 , @SqlQryStmt =@FinesseQry ,@LogDt =CURRENT_TIMESTAMP
				INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
				/*End of Logging*/		

--Read each row from [db-au-workspace].##RBQryTab and build Select Query to get data from Table(s)
--Using the queries built , load into Data Extraction table [db-au-workspace].##RBQryTabAll.

	   if object_id('tempdb..##RBQryTabAll') is not null drop table [db-au-workspace].##RBQryTabAll
			CREATE TABLE [db-au-workspace].##RBQryTabAll ( Qrytext nvarchar(4000),
															SrcTable VARCHAR(30))

		SELECT @FinesseQryStmt1 = 'SELECT convert(varchar(30),[Period]) as [Period],dateadd(d,-1,dateadd(m,1,convert(datetime,''''01-'''' + [Period]))) as PeriodEndDate,convert(varchar(50),[Sample Number]) as [SampleNumber],convert(varchar(50),[Factor]) as [Factor],convert(varchar(100),[State]) as [State],convert(varchar(200),[Destination]) as [Destination],convert(varchar(50),[International Domestic]) as [InternationalDomestic],convert(varchar(50),[Travel Group]) as TravelGroup,convert(int,[Number of Adults]) as NumberOfAdults,convert(int,[Number of Children]) as NumberOfChildren,convert(int,[Age of oldest adult]) as AgeOfOldestAdult,convert(int,[Age of second oldest adult]) as AgeOfSecondOldestAdult,convert(int,[Age of oldest dependent]) as AgeOfOldestDependent,convert(int,[Age of second oldest dependent]) as AgeOfSecondOldestDependent,convert(int,[Age of third oldest dependent]) as AgeOfThirdOldestDependent,convert(int,[Travel Duration]) as TravelDuration,convert(varchar(50),[Travel Duration Bands]) as TravelDurationBands,convert(varchar(50),[Destination Region]) as DestinationRegion,convert(int,[Lead Time]) as LeadTime,convert(varchar(50),[Profile]) as [Profile],convert(varchar(50),[Age of oldest adult - Band]) as AgeOfOldestAdultBand,convert(varchar(50),[Age of second oldest adult - Band]) as AgeOfSecondOldestAdultBand,convert(varchar(50),[Age of oldest dependent - Band]) as AgeOfOldestDependentBand,convert(varchar(50),[Age of second oldest dependent - Band]) as AgeOfSecondOldestDependentBand,convert(varchar(50),[Age of third oldest dependent - Band]) as AgeOfThirdOldestDependentBand,convert(varchar(50),[Travel Duration - Band]) as TravelDurationBand,convert(varchar(50),[Lead time - Band]) as LeadTimeBand,convert(varchar(50),[Single Multi Trip - Band]) as SingleMultiTripBand,'	
				SELECT @FinesseQryStmt2 = NULL
	
	DECLARE CurTxSrc CURSOR FOR SELECT CompetitorName, CompetitorColumn3 as CompetitorColumn3  , CompetitorColumn2 , left(ltrim(rtrim(CompetitorColumn1)),200) as CompetitorColumn1, SrcTbNm 
								FROM [db-au-workspace].##RBQryTab ;
	OPEN CurTxSrc 
		FETCH NEXT FROM CurTxSrc INTO @CompNm,@CompeCol3, @CompeCol2 , @CompeCol1 , @SrcTableNm
		WHILE @@FETCH_STATUS = 0  
			BEGIN 
				IF @@FETCH_STATUS <> 0   PRINT '         <<None>>'       
				ELSE
				BEGIN
					SELECT @PatFound=0 /*Reinitialize PatFound Flag*/
						/*Start Logging*/
						SELECT @StepNum =3 , @SqlQryStmt =CONCAT('Reinitialize PatFound Flag',@PatFound),@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
						/*End of Logging*/		
					DECLARE CurPat CURSOR FOR SELECT PatternText FROM [db-au-workspace].dbo.FinesseAllPatterns ORDER BY PatternId ASC; 
						OPEN CurPat 
							FETCH NEXT FROM CurPat INTO @Pat
								WHILE @PatFound = 0 AND @@FETCH_STATUS = 0 
								BEGIN 
									  IF @@FETCH_STATUS <> 0   PRINT '         <<None>>' 
										ELSE
										BEGIN
											SELECT @PatLoc=0,@CompPr=NULL,@Comp=NULL
											  --SELECT @ExcepPatLoc = PATINDEX(CONCAT('%',@Pat,'%'),@CompNm) 
											SELECT @PatLoc = PATINDEX(CONCAT('%',@Pat,'%'),@CompNm) 
											  IF @PatLoc > 1  select @PatFound = 1 ,@Comp=LTRIM(RTRIM(SUBSTRING(@CompNm,1,PATINDEX(CONCAT('%',@Pat,'%'),@CompNm)-1))),
																@CompPr= SUBSTRING(@CompNm,PATINDEX(CONCAT('%',@Pat,'%'),@CompNm),LEN(@CompNm)-PATINDEX(CONCAT('%',@Pat,'%'),@CompNm)+1)
												else if @PatLoc = 1 select @PatFound = 1, @Comp=@CompNm , @CompPr='DEFAULT'
												else select @PatFound = 0
												/*Start Logging*/
												SELECT @StepNum =3 , @SqlQryStmt =CONCAT('In pattern search ', @CompNm,' searched ', @Pat,' Index is ', @PatLoc, ',flag is ', @PatFound,'.Product is ',@CompPr ),@LogDt =CURRENT_TIMESTAMP
												INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
												/*End of Logging*/		
							  				END	
											FETCH NEXT FROM CurPat INTO @Pat
		     							 END
									  CLOSE CurPat 
									DEALLOCATE CurPat
										if @PatLoc < 1 SELECT @Comp=@CompNm , @CompPr='DEFAULT' ,@PatFound = 1
										/*Start Logging*/
												SELECT @StepNum =3 , @SqlQryStmt =CONCAT('Out of pattern search for  ', @CompNm,' searched ', @Pat,' Index is ', @PatLoc, ',flag is ', @PatFound,'.Product is ',@CompPr ),@LogDt =CURRENT_TIMESTAMP
												INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
										/*End of Logging*/		
				SELECT @FinesseQryStmt2 =  CONCAT(@FinesseQryStmt1  ,'''''' ,@Comp,'''''', ' AS Competitor,' ,'''''' ,@CompPr,'''''', ' AS CompetitorProduct,' ,'[' , @CompeCol3  , '],' , '[' , @CompeCol2 , '],' , '[' , @CompeCol1 , '],' ,'''''' ,@SrcTableNm,'''''', ' AS SourceTable '  , ' FROM [db-au-actuary].ws.' , @SrcTableNm)
				 
				 SELECT @FinesseQry= 'INSERT INTO [db-au-workspace].##RBQryTabAll VALUES (' + '''' + @FinesseQryStmt2  + ''',' +  '''' + @SrcTableNm + '''' +')' 
				/*Start Logging*/
				SELECT @StepNum =3 , @SqlQryStmt =@FinesseQry ,@LogDt =CURRENT_TIMESTAMP
				INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
				/*End of Logging*/
					EXEC sp_executesql @FinesseQry ,N'@FinesseQryStmt2 nvarchar(4000)', @FinesseQryStmt2 = @FinesseQryStmt2
				
				END
		FETCH NEXT FROM CurTxSrc INTO @CompNm , @CompeCol3, @CompeCol2 , @CompeCol1 , @SrcTableNm
		END  
	CLOSE CurTxSrc 
    DEALLOCATE CurTxSrc 

	

	
	  --Backup FinesseTravel Data as FinesseTravelData_CurrentTimestamp
		if object_id('tempdb.dbo.##FinesseTravelDataBkp') is not null DROP TABLE ##FinesseTravelDataBkp 
	  		SELECT * INTO ##FinesseTravelDataBkp FROM [db-au-actuary].ws.FinesseTravelData 


--Read FinesseQry Table Row Wise and load all data into FinesseStage table along with source table name. 	
		if object_id('tempdb..##RBFinStgTab') is not null drop table [db-au-workspace].##RBFinStgTab
		create table [db-au-workspace].##RBFinStgTab
		(			
			[Period] [varchar](30) NULL,
			[PeriodEndDate] datetime NULL,
			[SampleNumber] [varchar](50) NULL,
			[Factor] [varchar](50) NULL,
			[State] [varchar](100) NULL,
			[Destination] [varchar](200) NULL,
			[InternationalDomestic] [varchar](50) NULL,
			[TravelGroup] [varchar](50) NULL,
			[NumberOfAdults] [int] NULL,
			[NumberOfChildren] [int] NULL,
			[AgeOfOldestAdult] [int] NULL,
			[AgeOfSecondOldestAdult] [int] NULL,
			[AgeOfOldestDependent] [int] NULL,
			[AgeOfSecondOldestDependent] [int] NULL,
			[AgeOfThirdOldestDependent] [int] NULL,
			[TravelDuration] [int] NULL,
			[TravelDurationBands] [varchar](50) NULL,
			[DestinationRegion] [varchar](50) NULL,
			[LeadTime] [int] NULL,
			[Profile] [varchar](50) NULL,
			[AgeOfOldestAdultBand] [varchar](50) NULL,
			[AgeOfSecondOldestAdultBand] [varchar](50) NULL,
			[AgeOfOldestDependentBand] [varchar](50) NULL,
			[AgeOfSecondOldestDependentBand] [varchar](50) NULL,
			[AgeOfThirdOldestDependentBand] [varchar](50) NULL,
			[TravelDurationBand] [varchar](50) NULL,
			[LeadTimeBand] [varchar](50) NULL,
			[SingleMultiTripBand] [varchar](50) NULL,
			[Competitor] [varchar](50) NOT NULL,
			[CompetitorProduct] [varchar](100) NOT NULL,
			[CompetitorPremium] [varchar] (30) NULL,
			[CompetitorTimeStamp] VARCHAR(100) NULL,
			[CompetitorNotes] [varchar](1000) NULL,
			[SourceTable] [varchar] (200) NOT NULL
		)
				
			/*Start Logging*/
				SELECT @StepNum =4 , @SqlQryStmt ='Created Table ##RBFinStgTab',@LogDt =CURRENT_TIMESTAMP
				INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
				/*End of Logging*/

				/*Start Logging*/
						SELECT @StepNum =5 , @SqlQryStmt ='Start Loading RBFinStgTab' ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
						/*End lOGGING*/

	DECLARE CurTxLoad CURSOR FOR SELECT Qrytext FROM [db-au-workspace].##RBQryTabAll ;
		OPEN CurTxLoad 
			FETCH NEXT FROM CurTxLoad INTO @QryLoad
			 WHILE @@FETCH_STATUS = 0  
				BEGIN 
					IF @@FETCH_STATUS <> 0   PRINT '         <<None>>'       
					ELSE
					BEGIN
					SELECT @FinesseLoadQry= 'INSERT INTO [db-au-workspace].##RBFinStgTab  ' + @QryLoad
						/*Start Logging*/
						SELECT @StepNum =5 , @SqlQryStmt =@FinesseLoadQry ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
						/*End lOGGING*/
					EXEC (@FinesseLoadQry)
				END
		      FETCH NEXT FROM CurTxLoad INTO @QryLoad
			END  
		CLOSE CurTxLoad 
		DEALLOCATE CurTxLoad

			
	
	  --For testing purpose , FinesseTravel Data is stored in workspace database as FinesseTravelData 
	
	/*Start Logging*/
						SELECT @StepNum =6 , @SqlQryStmt ='Create Final Table' ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
	
		if object_id('[db-au-actuary].ws.FinesseTravelData') is null 
		begin
	  		create table [db-au-actuary].ws.FinesseTravelData
			(
				[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,	
				[Period] [varchar](30) NULL,
				[PeriodEndDate] datetime NULL,
				[SampleNumber] [varchar](50) NULL,
				[Factor] [varchar](50) NULL,
				[State] [varchar](100) NULL,
				[Destination] [varchar](200) NULL,
				[InternationalDomestic] [varchar](50) NULL,
				[TravelGroup] [varchar](50) NULL,
				[NumberOfAdults] [int] NULL,
				[NumberOfChildren] [int] NULL,
				[AgeOfOldestAdult] [int] NULL,
				[AgeOfSecondOldestAdult] [int] NULL,
				[AgeOfOldestDependent] [int] NULL,
				[AgeOfSecondOldestDependent] [int] NULL,
				[AgeOfThirdOldestDependent] [int] NULL,
				[TravelDuration] [int] NULL,
				[TravelDurationBands] [varchar](50) NULL,
				[DestinationRegion] [varchar](50) NULL,
				[LeadTime] [int] NULL,
				[Profile] [varchar](50) NULL,
				[AgeOfOldestAdultBand] [varchar](50) NULL,
				[AgeOfSecondOldestAdultBand] [varchar](50) NULL,
				[AgeOfOldestDependentBand] [varchar](50) NULL,
				[AgeOfSecondOldestDependentBand] [varchar](50) NULL,
				[AgeOfThirdOldestDependentBand] [varchar](50) NULL,
				[TravelDurationBand] [varchar](50) NULL,
				[LeadTimeBand] [varchar](50) NULL,
				[SingleMultiTripBand] [varchar](50) NULL,
				[Competitor] [varchar](100) NOT NULL,
				[CompetitorProduct] [varchar](100) NOT NULL,
				[CompetitorPremium] money   NULL,
				[CompetitorTimeStamp] datetime NULL,
				[CompetitorNotes] [varchar](1000) NULL
		  )
		
		create clustered index idx_FinesseTravelData_BIRowID on [db-au-actuary].ws.FinesseTravelData(BIRowID)
		create nonclustered index idx_FinesseTravelData_PeriodEndDate on [db-au-actuary].ws.FinesseTravelData(PeriodEndDate, [Period]) include (Destination, TravelGroup, Competitor)
		
		end

		  /* Earlier data will be deleted if newer versions have come */
		
		  SELECT @RowStmt=  'delete W from [db-au-actuary].ws.FinesseTravelData W inner join 
							 (select Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,NumberOfAdults,NumberOfChildren,AgeOfOldestAdult,AgeOfSecondOldestAdult,AgeOfOldestDependent,AgeOfSecondOldestDependent,AgeOfThirdOldestDependent,TravelDuration,TravelDurationBands,DestinationRegion,LeadTime,Profile,AgeOfOldestAdultBand,AgeOfSecondOldestAdultBand,AgeOfOldestDependentBand,AgeOfSecondOldestDependentBand,AgeOfThirdOldestDependentBand,TravelDurationBand,LeadTimeBand,SingleMultiTripBand,Competitor,CompetitorPremium, CompetitorNotes,
								 case when ((CompetitorTimeStamp > '''') AND (PATINDEX(''%/0001%'',CompetitorTimeStamp) < 1)) then
									convert(datetime, right(substring(CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp),charindex('' '',CompetitorTimeStamp) - charindex(''/'',CompetitorTimeStamp) + len('' '')),4) + ''-'' +
									  right(replace(''000''+left(CompetitorTimeStamp,2),''/'',''''),2) + ''-'' +
									  right(''00'' + substring(CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp)+1,charindex(''/'',CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp)+1)-charindex(''/'',CompetitorTimeStamp)-1),2) + '' '' + 
									  ltrim(rtrim(replace(substring(CompetitorTimeStamp,charindex('' '',CompetitorTimeStamp),charindex('' +'',CompetitorTimeStamp) - charindex('' '',CompetitorTimeStamp) + len('' +'')),'' +'',''''))),120
										)		else null  end as CompetitorTimeStamp 
							  FROM 
						  	   (
								 SELECT ROW_NUMBER() OVER (partition by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor 
										order by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor )
										RUNNER, 
										COUNT(NumberOfChildren) OVER (partition by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor 
										)CTR ,
										Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,NumberOfAdults,NumberOfChildren,AgeOfOldestAdult,AgeOfSecondOldestAdult,AgeOfOldestDependent,AgeOfSecondOldestDependent,AgeOfThirdOldestDependent,TravelDuration,TravelDurationBands,DestinationRegion,LeadTime,Profile,AgeOfOldestAdultBand,AgeOfSecondOldestAdultBand,AgeOfOldestDependentBand,AgeOfSecondOldestDependentBand,AgeOfThirdOldestDependentBand,TravelDurationBand,LeadTimeBand,SingleMultiTripBand,Competitor,CompetitorPremium, CompetitorNotes,CompetitorTimeStamp 
									from [db-au-workspace].##RBFinStgTab 
								) A where A.RUNNER=A.CTR 
							  ) S
								on W.Period = S.Period and W.PeriodEndDate=S.PeriodEndDate AND W.SampleNumber=S.SampleNumber AND W.Factor=S.Factor AND W.State=S.State AND W.Destination=S.Destination AND W.InternationalDomestic=S.InternationalDomestic
										AND W.TravelGroup=S.TravelGroup AND W.TravelDurationBands=S.TravelDurationBands AND W.DestinationRegion=S.DestinationRegion AND W.LeadTime=S.LeadTime
										AND W.Profile=S.Profile AND W.SingleMultiTripBand=S.SingleMultiTripBand AND W.Competitor=S.Competitor 
								'
		
		/*Start Logging*/
						SELECT @StepNum =7 , @SqlQryStmt =@RowStmt ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
			
			
					
	

			 EXEC(@RowStmt)

			 /*Start Logging*/
						SELECT @StepNum =8 , @SqlQryStmt =CONCAT('Executing - ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/

	      
		  /* Take the latest data based on the source table */
		  		 		
         SELECT @RowStmt='INSERT INTO [db-au-actuary].ws.FinesseTravelData (Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,
						NumberOfAdults,NumberOfChildren,AgeOfOldestAdult,AgeOfSecondOldestAdult,AgeOfOldestDependent,AgeOfSecondOldestDependent,AgeOfThirdOldestDependent,TravelDuration,
						TravelDurationBands,DestinationRegion,LeadTime,Profile,AgeOfOldestAdultBand,AgeOfSecondOldestAdultBand,AgeOfOldestDependentBand,AgeOfSecondOldestDependentBand,
						AgeOfThirdOldestDependentBand,TravelDurationBand,LeadTimeBand,SingleMultiTripBand,Competitor,CompetitorProduct,CompetitorPremium, CompetitorNotes,CompetitorTimeStamp)
					   (
						select Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,NumberOfAdults,NumberOfChildren,AgeOfOldestAdult,AgeOfSecondOldestAdult,AgeOfOldestDependent,AgeOfSecondOldestDependent,AgeOfThirdOldestDependent,TravelDuration,TravelDurationBands,DestinationRegion,LeadTime,Profile,AgeOfOldestAdultBand,AgeOfSecondOldestAdultBand,AgeOfOldestDependentBand,AgeOfSecondOldestDependentBand,AgeOfThirdOldestDependentBand,TravelDurationBand,LeadTimeBand,SingleMultiTripBand,Competitor,CompetitorProduct,CompetitorPremium, CompetitorNotes,
							case when ((CompetitorTimeStamp > '''') AND (PATINDEX(''%/0001%'',CompetitorTimeStamp) < 1)) then
								convert(datetime, right(substring(CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp),charindex('' '',CompetitorTimeStamp) - charindex(''/'',CompetitorTimeStamp) + len('' '')),4) + ''-'' +
								  right(replace(''000''+left(CompetitorTimeStamp,2),''/'',''''),2) + ''-'' +
								  right(''00'' + substring(CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp)+1,charindex(''/'',CompetitorTimeStamp,charindex(''/'',CompetitorTimeStamp)+1)-charindex(''/'',CompetitorTimeStamp)-1),2) + '' '' + 
								  ltrim(rtrim(replace(substring(CompetitorTimeStamp,charindex('' '',CompetitorTimeStamp),charindex('' +'',CompetitorTimeStamp) - charindex('' '',CompetitorTimeStamp) + len('' +'')),'' +'',''''))),120
									 )else null end as CompetitorTimeStamp 
							FROM 
							(SELECT ROW_NUMBER() OVER (partition by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor 
								order by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor )
							  RUNNER, 
								COUNT(NumberOfChildren) OVER (partition by Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,TravelDurationBands,DestinationRegion,LeadTime,Profile,SingleMultiTripBand,Competitor 
								)CTR ,
							  Period,PeriodEndDate,SampleNumber,Factor,State,Destination,InternationalDomestic,TravelGroup,NumberOfAdults,NumberOfChildren,AgeOfOldestAdult,AgeOfSecondOldestAdult,AgeOfOldestDependent,AgeOfSecondOldestDependent,AgeOfThirdOldestDependent,TravelDuration,TravelDurationBands,DestinationRegion,LeadTime,Profile,AgeOfOldestAdultBand,AgeOfSecondOldestAdultBand,AgeOfOldestDependentBand,AgeOfSecondOldestDependentBand,AgeOfThirdOldestDependentBand,TravelDurationBand,LeadTimeBand,SingleMultiTripBand,Competitor,CompetitorProduct,CompetitorPremium, CompetitorNotes,CompetitorTimeStamp 
								from [db-au-workspace].##RBFinStgTab 
							  ) A where A.RUNNER=A.CTR 
						)' 

			/*Start Logging*/
					SELECT @StepNum =9 , @SqlQryStmt =@RowStmt ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
			
			EXEC(@RowStmt)
			/*Start Logging*/
						SELECT @StepNum =10 , @SqlQryStmt =CONCAT('Executing - ',@RowStmt) ,@LogDt =CURRENT_TIMESTAMP
						INSERT INTO [db-au-workspace].dbo.FinesseLogger VALUES(@RunId , @StepNum ,@SqlQryStmt ,@LogDt )	
			/*End lOGGING*/
		
			

drop table ##FinesseTravelDataBkp
drop table ##RBFinStgTab
drop table ##RBQryTabAll
drop table ##RBTabDef	


GO
