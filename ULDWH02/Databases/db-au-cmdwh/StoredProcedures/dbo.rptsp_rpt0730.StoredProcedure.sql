USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0730]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[rptsp_rpt0730]
	@DateRange varchar(30),
	@StartDate varchar(10) = null,
	@EndDate varchar(10) = null
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0730
--  Author:         Saurabh Date
--  Date Created:   20160201
--  Description:    This stored procedure returns the number of AMT letters per product
--  Parameters:     @DateRange: Value is valid date range
--                  @StartDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20160201 - SD - Changed the stored procedure to provide capability of choosing different date ranges
--
/****************************************************************************************************/


--uncomment to Debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Next Month', @StartDate = null, @EndDate = null
*/



	DECLARE @Results table (
		StoredProcName varchar(30),
		ReportTitle varchar(100),
		RecordCount int,
		Period varchar(30),
		StartDate datetime,
		EndDate datetime
	)

	Declare @Temp_RPT0283_Results table (
		AgencyCode varchar(30),
		AgencyGroupname varchar(100),
		AgencyName varchar(255),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		ContactTitle varchar(10),
		ContactFirstName varchar(100),
		ContactLastName	varchar(100),
		ContactStreet varchar(255),
		ContactSuburb varchar(255),
		Contactstate varchar(20),
		ContactPostCode varchar(20),
		Country varchar(20),
		PolicyNo varchar(50),
		ProductCode varchar(50),
		RenewalDate datetime,
		Title varchar(10),
		FirstName varchar(100),
		LastName varchar(100),
		StartDate datetime,
		EndDate datetime
	)
	DECLARE @RptRange varchar(30),
			@SDate datetime,
			@EDate datetime,
			@SDate2 varchar(10),
			@EDate2 varchar(10)

/* get reporting dates */
if @DateRange = '_User Defined'
	select 
		@rptRange = @DateRange,
		@SDate = @StartDate,
		@EDate = @EndDate,
		@SDate2 = @StartDate,
		@EDate2 = @EndDate
else
	select	
			@rptRange = @DateRange,
			@SDate = StartDate, 
			@EDate = EndDate
	from	[db-au-cmdwh].dbo.vDateRange
	where	DateRange = @DateRange;


	insert into @Temp_RPT0283_Results
	exec [rptsp_rpt0283] @Country='AU', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0283', 'RPT0283 - Business Renewal - AMT Agent' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange
	
	Declare @Temp_RPT0284_Results table (
		AgencyCode varchar(30),
		AgencyGroupname varchar(100),
		AgencyName varchar(255),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		ContactTitle varchar(10),
		ContactFirstName varchar(100),
		ContactLastName	varchar(100),
		ContactStreet varchar(255),
		ContactSuburb varchar(255),
		Contactstate varchar(20),
		ContactPostCode varchar(20),
		Country varchar(20),
		PolicyNo varchar(50),
		ProductCode varchar(50),
		ProductDesc varchar(255),
		RenewalDate datetime,
		Title varchar(10),
		FirstName varchar(100),
		LastName varchar(100),
		StartDate datetime,
		EndDate datetime
	)



	insert into @Temp_RPT0284_Results
	exec [rptsp_rpt0284] @Country='AU', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0284', 'RPT0284 - Business Renewal - AMT Agent for Client' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	insert into @Temp_RPT0284_Results
	exec [rptsp_rpt0284a] @Country='AU', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0284a', 'RPT0284a - Business Renewal - AMT Agent for Business Client' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange

	Declare @Temp_RPT0285_Results table (
		PolicyNo varchar(50),
		ProductCode varchar(50),
		ProductType varchar(255),
		RenewalDate datetime,
		AgencyCode varchar(30),
		AgencyName varchar(255),
		AgencyGroupname varchar(100),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		AgencyTitle varchar(10),
		AgencyFirstName varchar(100),
		AgencyLastName	varchar(100),
		AgencyStreet varchar(255),
		AgencySuburb varchar(255),
		AgencyState varchar(20),
		AgencyPostCode varchar(20),
		AgencyPhone varchar(20),
		AgencyCountry varchar(20),
		CustTitle varchar(10),
		CustFirstName varchar(100),
		CustLastName varchar(100),
		CustStreet varchar(255),
		CustSuburb varchar(255),
		CustState varchar(20),
		CustPostCode varchar(20),
		CustCountry varchar(20),
		StartDate datetime,
		EndDate datetime
	)


	insert into @Temp_RPT0285_Results
	exec [rptsp_rpt0285a] @Country='AU', @LetterType='Closed Agents & STA', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0285a', 'RPT0285a - Business Renewal - AMT Client - Closed Agents & STA' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	insert into @Temp_RPT0285_Results
	exec [rptsp_rpt0285a] @Country='AU', @LetterType='Flight Centre, Directs, & Brokers', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0285a', 'RPT0285a - Business Renewal - AMT Client - FL, Direct, & Brokers' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange

	Declare @Temp_RPT0285d_Results table (
		PolicyNo varchar(50),
		ProductCode varchar(50),
		ProductType varchar(255),
		PolicyState datetime,
		RenewalDate datetime,
		TripType varchar(50),
		AgencyCode varchar(30),
		AgencyName varchar(255),
		AgencyGroupname varchar(100),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		AgencyTitle varchar(10),
		AgencyFirstName varchar(100),
		AgencyLastName	varchar(100),
		AgencyStreet varchar(255),
		AgencySuburb varchar(255),
		AgencyState varchar(20),
		AgencyPostCode varchar(20),
		AgencyPhone varchar(20),
		AgencyCountry varchar(20),
		CustTitle varchar(10),
		CustFirstName varchar(100),
		CustLastName varchar(100),
		CustStreet varchar(255),
		CustSuburb varchar(255),
		CustState varchar(20),
		CustPostCode varchar(20),
		CustCountry varchar(20),
		StartDate datetime,
		EndDate datetime
	)



	insert into @Temp_RPT0285d_Results
	exec [rptsp_rpt0285d] @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0285d', 'RPT0285d - Business Renewal - AMT Client FL' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange

	Declare @Temp_RPT0285e_Results table (
		PolicyNo varchar(50),
		ProductCode varchar(50),
		ProductType varchar(255),
		PolicyState datetime,
		RenewalDate datetime,
		TripType varchar(50),
		AgencyCode varchar(30),
		AgencyName varchar(255),
		AgencyGroupname varchar(100),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		AgencyTitle varchar(10),
		AgencyFirstName varchar(100),
		AgencyLastName	varchar(100),
		AgencyStreet varchar(255),
		AgencySuburb varchar(255),
		AgencyState varchar(20),
		AgencyPostCode varchar(20),
		AgencyPhone varchar(20),
		AgencyCountry varchar(20),
		CustTitle varchar(10),
		CustFirstName varchar(100),
		CustLastName varchar(100),
		DOB datetime,
		CustStreet varchar(255),
		CustSuburb varchar(255),
		CustState varchar(20),
		CustPostCode varchar(20),
		CustCountry varchar(20),
		StartDate datetime,
		EndDate datetime
	)


	insert into @Temp_RPT0285e_Results
	exec [rptsp_rpt0285e] @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0285e', 'RPT0285e - Business Renewal - AMT Client Medibank' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	insert into @Temp_RPT0285d_Results
	exec [rptsp_rpt0285g] @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0285g', 'RPT0285g - Business Renewal - AMT Client JTG & Indies' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange

	Declare @Temp_RPT0286_Results table (
		AgencyCode varchar(30),
		AgencyGroupname varchar(100),
		AgencyName varchar(255),
		SubGroupname varchar(255),
		SuperGroupName varchar(255),
		ContactTitle varchar(10),
		ContactFirstName varchar(100),
		ContactLastName	varchar(100),
		ContactPhone varchar(100),
		ContactStreet varchar(255),
		ContactSuburb varchar(255),
		Contactstate varchar(20),
		ContactPostCode varchar(20),
		Country varchar(20),
		PolicyNo varchar(50),
		ProductCode varchar(50),
		ProductDesc varchar(255),
		RenewalDate datetime,
		CustTitle varchar(10),
		CustFirstName varchar(100),
		CustLastName varchar(100),
		CustStreet varchar(255),
		CustSuburb varchar(255),
		CustState varchar(20),
		CustPostCode varchar(20),
		CustCountry varchar(20),
		StartDate datetime,
		EndDate datetime
	)


	insert into @Temp_RPT0286_Results
	exec [rptsp_rpt0286] @Country='AU', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0286', 'RPT0286 - Business Renewal - AMT Business Client' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange

	Declare @Temp_RPT0409_Results table (
		quoteid bigint,
		PolicyNo varchar(50),
		PolicyExpiryDate datetime,
		CompanyName varchar(100),
		AgencyCode varchar(30),
		AgencyName varchar(255),
		AgentStreet varchar(255),
		AgentSuburb varchar(255),
		AgentState varchar(20),
		AgentPostCode varchar(20),
		ClientFirstName varchar(100),
		ClientContact varchar(100),
		ClientStreet varchar(255),
		ClientSuburb varchar(255),
		ClientState varchar(20),
		ClientPostCode varchar(20),
		GSTGross money,
		SalesExGST money
	)


	insert into @Temp_RPT0409_Results
	exec [rptsp_rpt0409] @Country='AU', @LetterType='Agent Other', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0409', 'RPT0409 - Corporate Renewal - Agent Other Sales' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	insert into @Temp_RPT0409_Results
	exec [rptsp_rpt0409] @Country='AU', @LetterType='Client Direct', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0409', 'RPT0410 - Corporate Renewal - Client Direct Sales' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	insert into @Temp_RPT0409_Results
	exec [rptsp_rpt0409] @Country='AU', @LetterType='Client Other', @ReportingPeriod= @rptRange, @StartDate = @SDate2, @EndDate = @EDate2

	insert into @Results
	select 'rptsp_rpt0409', 'RPT0411 - Corporate Renewal - Client Other Sales' as name, IsNull(@@ROWCOUNT,0) as [RecordCount], CONVERT(varchar, @SDate, 103) + ' to ' + CONVERT(varchar, @EDate, 103), IsNull(@SDate,StartDate), IsNull(@EDate,EndDate)
	from [db-au-cmdwh].dbo.vDateRange 
	where DateRange = @rptRange


	select * from @Results where [RecordCount]>0;





GO
