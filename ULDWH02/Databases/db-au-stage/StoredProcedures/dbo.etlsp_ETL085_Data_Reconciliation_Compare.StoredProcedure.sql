USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL085_Data_Reconciliation_Compare]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-05-22
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL085_Data_Reconciliation_Compare] 
	-- Add the parameters for the stored procedure here
	@SubjectArea varchar(50), 
	@Server varchar(10), 
	@ETLName varchar(50) = null,  
	@Target varchar(50) = null, 
	@PeriodStart char(10), 
	@PeriodEnd char(10),
	@FromSnapshot tinyint = 1
AS
BEGIN

	SET NOCOUNT ON;

	-- TODO logging

	-- declare variables
	declare @curMetadataID int
	declare @curETLName varchar(10) 
	declare @curTarget varchar(50)
	declare @curSource1 varchar(50)
	declare @curSource2 varchar(50)
	declare @curSource3 varchar(50)
	declare @curAllZero bit
	declare @Query1 varchar(max) = null
	declare @Query2 varchar(max) = null
	declare @Query3 varchar(max) = null
	declare @NumberOfSources int = 0

	declare @InvalidCount int
	declare @Valid tinyint

	-- prepare log tables for Recon if not exist
	if object_id('[db-au-log]..Data_Reconciliation_Summary') is null 
	create table [db-au-log]..Data_Reconciliation_Summary( 
		ID int identity(1, 1) primary key, 
		MetadataID	int, 
		CountryCode varchar(10), 
		Source1Value numeric(16,2), 
		Source2Value numeric(16,2), 
		Source3Value numeric(16,2), 
		[Date] date, 
		Valid tinyint, 
		InsertDatetime Datetime2, 
		UpdateDatetime Datetime2,
		Comment varchar(4000)  
	)

	if object_id('[db-au-log]..Data_Reconciliation_Invalid') is null 
	create table [db-au-log]..Data_Reconciliation_Invalid( 
		ID int identity(1, 1) primary key, 
		SummaryID int,
		MetadataID int, 
		CountryCode varchar(10), 
		Identifier varchar(100), 
		Source1Value numeric(16,2), 
		Source2Value numeric(16,2), 
		Source3Value numeric(16,2), 
		[Date] date, 
		InsertDatetime Datetime2, 
		UpdateDatetime Datetime2, 
		Comment varchar(4000) 
	)


	if @PeriodStart is null set @PeriodStart = convert(char(10), dateadd(day, -3, getdate()), 126)
	if @PeriodEnd is null set @PeriodEnd = convert(char(10), dateadd(day, 3, getdate()), 126)

	exec [db-au-stage]..[etlsp_ETL085_Data_Reconciliation_Stage] @SubjectArea, @Server, @FromSnapshot, @PeriodStart, @PeriodEnd
	

	-- get info from metadata table
	if object_id('tempdb..#Recon_Metadata') is not null 
        drop table #Recon_Metadata

	select *
	into #Recon_Metadata
	from [db-au-stage]..Recon_Metadata
	where Active = 1
		and SubjectArea = @SubjectArea
		and [Target] like '%' + coalesce(@Target, '') + '%'
	
	-- prepare cursor
	declare meta_cursor cursor for
		select 
			ID,
			ETLName,
			[Target],
			Source1,
			Source2,
			Source3,
			AllZero
		from 
			#Recon_Metadata
	
	-- loop through metadata table
	open meta_cursor   
	fetch next from meta_cursor into @curMetadataID, @curETLName, @curTarget, @curSource1, @curSource2, @curSource3, @curAllZero

	while @@FETCH_STATUS = 0   
	begin   
		
		-- pivot the raw data for the current metric
		exec [db-au-stage]..[etlsp_ETL085_Data_Reconciliation_Transform] @SubjectArea, @curTarget

		-- process date range
		if @PeriodStart is null and @PeriodEnd is null and coalesce(@curETLName, @ETLName) is not null
		begin 
			select top 1 
				@PeriodStart = convert(char(10), Batch_Date, 126),
				@PeriodEnd = convert(char(10), Batch_To_Date, 126)
			from 
				[db-au-log]..Batch_Run_Status
			where 
				Subject_Area = @ETLName
				and Batch_Status like 'Success%'
			order by 
				Batch_ID desc
		end


		set @NumberOfSources = 0


		if object_id('tempdb..##source1') is not null drop table ##source1
		if object_id('tempdb..##source2') is not null drop table ##source2
		if object_id('tempdb..##source3') is not null drop table ##source3

		set @Query1 = 
		'
		select 
			[Date], 
			CountryCode, 
			Identifier, 
			@Source as SourceValue
		-- into 
		from 
			##dr_pivot
		where 
			[Date] >= ''@PeriodStart'' 
			and [Date] < ''@PeriodEnd'' 
		'
		set @Query2 = @Query1
		set @Query3 = @Query1 


		-- process ##source1				
		if @curSource1 is not null
			begin
				set @NumberOfSources = @NumberOfSources + 1
				set @Query1 = replace(@Query1, '@Source', @curSource1)
				set @Query1 = replace(@Query1, '@PeriodStart', @PeriodStart)
				set @Query1 = replace(@Query1, '@PeriodEnd', @PeriodEnd)
				set @Query1 = replace(@Query1, '-- into', 'into ##source1')
				exec (@Query1)
			end


		-- process ##source2	
		if @curSource2 is not null
			begin
				set @NumberOfSources = @NumberOfSources + 1
				set @Query2 = replace(@Query2, '@Source', @curSource2)
				set @Query2 = replace(@Query2, '@PeriodStart', @PeriodStart)
				set @Query2 = replace(@Query2, '@PeriodEnd', @PeriodEnd)
				set @Query2 = replace(@Query2, '-- into', 'into ##source2')
				exec (@Query2)
			end


		-- process ##source3		
		if @curSource3 is not null
			begin
				set @NumberOfSources = @NumberOfSources + 1
				set @Query3 = replace(@Query3, '@Source', @curSource3)
				set @Query3 = replace(@Query3, '@PeriodStart', @PeriodStart)
				set @Query3 = replace(@Query3, '@PeriodEnd', @PeriodEnd)
				set @Query3 = replace(@Query3, '-- into', 'into ##source3')
				exec (@Query3)
			end


		-- ##source1, ##source2, ##source3
		--	countrycode
		--	identifier
		--	sourcevalue

		-- union all results into ##result
		if object_id('tempdb..##result') is not null drop table ##result

		create table ##result (
			Src varchar(20),
			[Date] date, 
			CountryCode varchar(10),
			Identifier varchar(50),
			SourceValue numeric(16,2)
		)

		if object_id('tempdb..##source1') is not null 
			insert into ##result
			select 
				'source1value',
				[Date], 
				cast(CountryCode COLLATE DATABASE_DEFAULT as nvarchar(20)) as CountryCode, 
				cast(Identifier COLLATE DATABASE_DEFAULT as nvarchar(50)) as Identifier, 
				SourceValue
			from 
				##source1

		if object_id('tempdb..##source2') is not null 
			insert into ##result
			select 
				'source2value',
				[Date], 
				cast(CountryCode COLLATE DATABASE_DEFAULT as nvarchar(20)) as CountryCode, 
				cast(Identifier COLLATE DATABASE_DEFAULT as nvarchar(50)) as Identifier, 
				SourceValue
			from 
				##source2
			
		if object_id('tempdb..##source3') is not null 
			insert into ##result
			select 
				'source3value',
				[Date], 
				cast(CountryCode COLLATE DATABASE_DEFAULT as nvarchar(20)) as CountryCode, 
				cast(Identifier COLLATE DATABASE_DEFAULT as nvarchar(50)) as Identifier, 
				SourceValue
			from 
				##source3

		
		-- prepare results temp table
		if object_id('tempdb..##temp_result') is not null drop table ##temp_result; 
		with p (CountryCode, [Date], source1value, source2value, source3value) as ( 
			select 
				CountryCode, 
				[Date], 
				sum(source1value) as source1value, 
				sum(source2value) as source2value, 
				sum(source3value) as source3value 
			from ( 
				select 
					CountryCode, 
					[Date], 
					source1value, 
					source2value, 
					source3value 
				from ##result 
				pivot (sum(sourcevalue) for src in (source1value, source2value, source3value)) as pvt 
			) x 
			group by 
				CountryCode, 
				[Date]
		) 
		select 
			p.CountryCode, 
			p.[Date], 
			round(p.source1value, 0) as Source1Value, 
			round(p.source2value, 0) as Source2Value, 
			round(p.source3value, 0) as Source3Value, 
			Valid = 
				case 
					when @curAllZero = 1 then 
						case 
							when min(round(f.x, 0)) = 0 and max(round(f.x, 0)) = 0 and (
								select count(*)
								from (values (p.source1value), (p.source2value), (p.source3value)) as v(col)
								where v.col is not null
								) = @NumberOfSources then 1 
							when isnull(p.source1value, 0) = 0 and isnull(p.source2value, 0) = 0 and isnull(p.source3value, 0) = 0 then 1 
							else 0
						end
					else --@curAllZero = 0
						case
							when min(round(f.x, 0)) = max(round(f.x, 0)) and (
								select count(*)
								from (values (p.source1value), (p.source2value), (p.source3value)) as v(col)
								where v.col is not null
								) = @NumberOfSources then 1 
							when isnull(p.source1value, 0) = 0 and isnull(p.source2value, 0) = 0 and isnull(p.source3value, 0) = 0 then 1 
							else 0
						end 
				end
		into ##temp_result 
		from 
			p cross apply (values (source1value), (source2value), (source3value)) as f (x) 
		group by 
			p.CountryCode, 
			p.[Date], 
			p.source1value, 
			p.source2value, 
			p.source3value 


		-- prepare country and date table (for create a record with null when there's no data on the day)
		if object_id('tempdb..##dr_countrydate') is not null drop table ##dr_countrydate

		if @SubjectArea = 'Penguin'
		begin 
			declare @Countries varchar(1000) = null, @SQL varchar(max) = null

			if @Server = 'AU' set @Countries = 'not in (''UK'', ''US'')'
			if @Server = 'UK' set @Countries = '= ''UK'''
			if @Server = 'US' set @Countries = '= ''US'''
			

			set @SQL = 
			'
			select 
				c.CountryCode, 
				d.[Date]
			into ##dr_countrydate
			from 
			(
				select 
					distinct CountryKey as CountryCode 
				from 
					[db-au-cmdwh]..[penDomain]
				where 
					CountryKey ' + @Countries + 
			') c
			cross join 
			(
				select 
					distinct [Date]
				from 
					##temp_result
			) d
			'
			
			exec(@SQL)			

		end


		-- merge to Data_Reconciliation_Summary table
		merge [db-au-log]..Data_Reconciliation_Summary t
		using (
			select 
				c.CountryCode, 
				c.[Date], 
				r.Source1Value, 
				r.Source2Value, 
				r.Source3Value, 
				r.Valid 
			from		
				##dr_countrydate c
				left join ##temp_result r on c.CountryCode = r.CountryCode and c.[Date] = r.[Date]
		) s
		on t.MetadataID = @curMetadataID and t.CountryCode = s.CountryCode and t.[Date] = s.[Date]
		when matched then 
			update set 
				t.Source1Value = s.Source1Value, 
				t.Source2Value = s.Source2Value, 
				t.Source3Value = s.Source3Value, 
				t.Valid = s.Valid, 
				t.UpdateDatetime = current_timestamp 
		when not matched by target then 
			insert ( 
				MetadataID, 
				CountryCode,  
				Source1Value, 
				Source2Value, 
				Source3Value, 
				[Date], 
				Valid, 
				InsertDatetime 
			)
			values (
				@curMetadataID,
				s.countrycode, 
				s.Source1Value, 
				s.Source2Value, 
				s.Source3Value, 
				s.[Date], 
				s.Valid, 
				current_timestamp
			)
		;


		-- prepare invalid results temp table
		if object_id('tempdb..##temp_invalid') is not null drop table ##temp_invalid
		select 
			p.CountryCode, 
			p.Identifier, 
			p.[Date], 
			round(p.source1value, 0) as Source1Value, 
			round(p.source2value, 0) as Source2Value, 
			round(p.source3value, 0) as Source3Value, 
			Valid = 
				case 
					when @curAllZero = 1 then 
						case 
							when min(round(f.x, 0)) = 0 and max(round(f.x, 0)) = 0 and (
								select count(*)
								from (values (p.source1value), (p.source2value), (p.source3value)) as v(col)
								where v.col is not null
								) = @NumberOfSources then 1 
							when isnull(p.source1value, 0) = 0 and isnull(p.source2value, 0) = 0 and isnull(p.source3value, 0) = 0 then 1 
							else 0
						end
					else --@curAllZero = 0
						case 
							when min(round(f.x, 0)) = max(round(f.x, 0)) and (
								select count(*)
								from (values (p.source1value), (p.source2value), (p.source3value)) as v(col)
								where v.col is not null
								) = @NumberOfSources then 1 
							when isnull(p.source1value, 0) = 0 and isnull(p.source2value, 0) = 0 and isnull(p.source3value, 0) = 0 then 1 
							else 0
						end 
				end
		into ##temp_invalid 
		from 
			(
				select 
					CountryCode, 
					Identifier, 
					[Date], 
					source1value, 
					source2value, 
					source3value 
				from ##result 
				pivot (sum(sourcevalue) for src in (source1value, source2value, source3value)) as pvt 
			) p
			cross apply (values (source1value), (source2value), (source3value)) as f (x) 
		group by 
			p.CountryCode, 
			p.identifier, 
			p.[Date], 
			p.source1value, 
			p.source2value, 
			p.source3value 

		
		-- merge invalid results into [db-au-log]..Data_Reconciliation_Invalid table
		merge [db-au-log]..Data_Reconciliation_Invalid t
		using (
			select 
				s.ID as SummaryID, 
				@curMetadataID as MetadataID,
				i.*
			from 
				##temp_invalid i
				outer apply (
					select top 1 ID 
					from [db-au-log]..Data_Reconciliation_Summary
					where MetadataID = @curMetadataID and CountryCode = i.CountryCode and [Date] = i.[Date]
				) s
		) s
		on 
			t.MetadataID = s.MetadataID 
			and t.CountryCode = s.countrycode 
			and t.Identifier = s.Identifier 
			and t.[Date] = s.[Date] 
		when matched and s.valid = 0 then 
			update set 
				t.Source1Value = s.source1value,
				t.Source2Value = s.source2value,
				t.Source3Value = s.source3value,
				t.UpdateDatetime = current_timestamp
		when matched and s.valid = 1 then 
			delete
		when not matched by target and s.valid = 0 then
			insert (
				SummaryID, 
				MetadataID, 
				CountryCode, 
				Identifier, 
				Source1Value, 
				Source2Value, 
				Source3Value, 
				[Date], 
				InsertDatetime
			)
			values (
				s.SummaryID, 
				@curMetadataID, 
				s.CountryCode, 
				s.Identifier, 
				s.Source1Value, 
				s.Source2Value, 
				s.Source3Value, 
				s.[Date], 
				current_timestamp
			)
		when not matched by source 
			and t.MetadataID = @curMetadataID 
			and ( t.[Date] >= @PeriodStart and t.[Date] < @PeriodEnd ) 
			and t.CountryCode in ( select distinct CountryCode from ##dr_countrydate ) then
			delete
		;
				
		fetch next from meta_cursor into @curMetadataID, @curETLName, @curTarget, @curSource1, @curSource2, @curSource3, @curAllZero

	end 

	close meta_cursor   
	deallocate meta_cursor


END
GO
