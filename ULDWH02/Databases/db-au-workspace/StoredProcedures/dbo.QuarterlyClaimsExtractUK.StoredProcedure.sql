USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[QuarterlyClaimsExtractUK]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[QuarterlyClaimsExtractUK]	@StartDate varchar(10), 
													@EndDate varchar(10), 
													@Mode varchar(4)
AS

SET NOCOUNT ON


/*
	Written by Tim Canham to replace RSA sprocs 9/11/2007
	@2009-10-29 : Jeevs - Included Mode Attribute
	-- @Mode = ALL, VERO, GLA
	
	@2010-03-12 : Jeevs - included 'ISIS' product in the product code exclusion in policy side 
					+ included LossCountry in claims side
					
	@2011-02-07 : Linus - replicated from [db-au-workspace].dbo.QuarterlyClaimsExtract and modified for UK Claims. Criteria  and calculations
						  remained as per AU/NZ stored procedure.			
	@2011-02-25 : Linus - Added function to extract data for VERO, GLA or ALL
	@2011-11-22 : Linus - Added claims RECY payments insertion as a separate statement because UK RECY payments are not linked to Section table
	@2012-01-12 : Linus - Added KPCREATEDDT because RECY payments may have null KPMODDT values in the Claims Payment select statements
	@2016-01-05 : Linus - Converted Policy Number fields to varchar(50)
	@2016-08-29 : Linus - Moved SP from OXLEY to ULDWH01 due to OXLEY unable to create linked server connection to AZEUSQL01
*/

--uncomment to debug
/*
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @Mode varchar(4)
select @StartDate = '2009-07-01', @EndDate = '2016-08-01', @Mode = 'VERO'
*/

if @Mode = 'ALL' select @StartDate = '2006-11-01'
DECLARE @Extension VARCHAR(10)

SET @Extension = CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '_' + CAST(MONTH(GETDATE()) AS VARCHAR(2)) + '_' + CAST(DAY(GETDATE()) AS VARCHAR(2))

-- ***** pre-run cleanup *****
--kill existing, if appropriate
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Claims_Events_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Claims_Events_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Estimates_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Estimates_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Payments_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Payments_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Claims_Events_Exception_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Claims_Events_Exception_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Estimates_Exception_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Estimates_Exception_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Payments_Exception_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[RSA_Extract_Payments_Exception_UK_' + @Extension + ']')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PolicySide_UK_' + @Extension + ']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('DROP TABLE [dbo].[PolicySide_UK_' + @Extension + ']')

if object_id('tempdb..#ClaimNums_GLA') is not null drop table #ClaimNums_GLA
if object_id('tempdb..#ClaimNums_ALL') is not null drop table #ClaimNums_ALL
if object_id('tempdb..#ClaimNums') is not null drop table #ClaimNums
if object_id('tempdb..#Sects') is not null drop table #Sects
if object_id('tempdb..#Sects_GLA') is not null drop table #Sects_GLA
if object_id('tempdb..#Sects_ALL') is not null drop table #Sects_ALL



--rename current to old
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Claims_Events_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Claims_Events_UK'', ''RSA_Extract_Claims_Events_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Estimates_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Estimates_UK'', ''RSA_Extract_Estimates_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Payments_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Payments_UK'', ''RSA_Extract_Payments_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Claims_Events_Exception_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Claims_Events_Exception_UK'', ''RSA_Extract_Claims_Events_Exception_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Estimates_Exception_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Estimates_Exception_UK'', ''RSA_Extract_Estimates_Exception_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RSA_Extract_Payments_Exception_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.RSA_Extract_Payments_Exception_UK'', ''RSA_Extract_Payments_Exception_UK_' + @Extension +'''')
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PolicySide_UK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	EXEC('sp_rename ''dbo.PolicySide_UK'', ''PolicySide_UK_' + @Extension +'''')


--Policy Side
IF @Mode = 'ALL'
BEGIN
-- Get ALL New, Extension and Add-on policies. PPNER IN (N,E,A)
      
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      INTO [db-au-workspace].dbo.PolicySide_UK
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left JOIN [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
	  WHERE (PPACT Between @StartDate And @EndDate)
      AND (PPREG.PPPOLTP Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS'))
      AND PPNER <> 'R'
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD
      
-- Get GLA & VERO cancellations
	INSERT INTO [db-au-workspace].dbo.PolicySide_UK(AccPeriod,  AgencyGroup, State, IssueDate, AutoManual, NERV, PolNo,
            PolType, [Plan], Excess, StartDate, EndDate, Duration_Days,
            Duration_Weeks, Duration_Months, [Sing, Fam, Duo], DOB, Gross_Written,
            GST_Gross, EMC, Luggage, Excess_Buyout, High_Risk,
            Rental_Car_Insurance_Excess, Gross_Ex_GST, Destination, Commission )
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left JOIN [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
      WHERE (PPACT Between @StartDate And @EndDate)
      AND (PPREG.PPPOLTP Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS'))
	  AND PPNER = 'R' AND
      PPPOLD IN (SELECT vp2.PPPOLYN FROM [IC201].uktrips.dbo.PPREG vp2)
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD
      HAVING (PPACT Between @StartDate And @EndDate)
END



IF @Mode = 'VERO'
BEGIN
-- Get VERO New, Extension, Add-on and cancellation policies where PPDISS < 1/7/09 
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      INTO [db-au-workspace].dbo.PolicySide_UK
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left JOIN [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD, PPPOLD
      HAVING (PPDISS < '2009-09-01') 
      AND(PPACT Between @StartDate And @EndDate)
      AND (PPREG.PPPOLTP Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS'))
      
	-- INCLUDE Cancellations issued >= 1/7/09 where the policy that was cancelled was issued < 1/7/09 (ie Cancellation of VERO policies)
	INSERT INTO [db-au-workspace].dbo.PolicySide_UK(AccPeriod, AgencyGroup, State, IssueDate, AutoManual, NERV, PolNo,
            PolType, [Plan], Excess, StartDate, EndDate, Duration_Days,
            Duration_Weeks, Duration_Months, [Sing, Fam, Duo], DOB, Gross_Written,
            GST_Gross, EMC, Luggage, Excess_Buyout, High_Risk,
            Rental_Car_Insurance_Excess, Gross_Ex_GST, Destination, Commission )
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left join [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
      WHERE PPDISS >= '2009-09-01' AND PPNER = 'R' AND 
			PPPOLD IN (SELECT vp2.PPPOLYN FROM [IC201].uktrips.dbo.PPREG vp2 WHERE (vp2.PPDISS < '2009-09-01'))
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD
      HAVING (PPACT Between @StartDate And @EndDate)
END


IF @Mode = 'GLA'
BEGIN
-- Get GLA New, Extension and Add-on policies - PPDISS >= 1/7/09 and PPNER IN (N,E,A)
      
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      INTO [db-au-workspace].dbo.PolicySide_UK
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left JOIN [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
	  WHERE PPDISS >= '2009-09-01' 
	  AND(PPACT Between @StartDate And @EndDate)
      AND (PPREG.PPPOLTP Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS'))
      AND PPNER <> 'R'
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD
      
-- Get GLA cancellations whilst excluding VERO Cancellations issued >= 1/7/09 where the policy that was cancelled was issued < 1/7/09 (ie Cancellation of VERO policies)
	INSERT INTO [db-au-workspace].dbo.PolicySide_UK(AccPeriod,  AgencyGroup, State, IssueDate, AutoManual, NERV, PolNo,
            PolType, [Plan], Excess, StartDate, EndDate, Duration_Days,
            Duration_Weeks, Duration_Months, [Sing, Fam, Duo], DOB, Gross_Written,
            GST_Gross, EMC, Luggage, Excess_Buyout, High_Risk,
            Rental_Car_Insurance_Excess, Gross_Ex_GST, Destination, Commission )
      SELECT PPACT AccPeriod, CLGROUP AgencyGroup, CLGRSTATE State, PPDISS IssueDate, 
      PPTIAS AutoManual, PPNER NERV, convert(varchar(50),PPREG.PPPOLYN) PolNo,
      PPREG.PPPOLTP PolType, PPPCODE "Plan", PPEXCESS Excess, PPDEP StartDate, PPRET EndDate,
      PPDAYS Duration_Days, PPWKS Duration_Weeks,
      PPMTHS Duration_Months, PPFAM "Sing, Fam, Duo",  min(PPDOB) DOB, 
      (case when pprgtgst is Null then ppprgt else (ppprgt+pprgtgst) end) Gross_Written, 
      PPRGTGST GST_Gross, 
      PPDETC  EMC, PPVTOT Luggage, 
      PPXSBYOUT Excess_Buyout, 
      PPHRTOT High_Risk, 
      PPHIRECARXS Rental_Car_Insurance_Excess, 
      PPPRGT Gross_Ex_GST,
      PPDESN Destination,
      PPPSD Commission
      FROM ([IC201].uktrips.dbo.PPREG PPREG
			left join [IC201].uktrips.dbo.CLREG CLREG ON 
				PPREG.PPALPHA = CLREG.CLALPHA) 
			left JOIN [IC201].uktrips.dbo.PPMULT PPMULT ON 
				convert(varchar(50),PPREG.PPPOLYN) = convert(varchar(50),PPMULT.PPPOLYN)
      WHERE PPDISS >= '2009-09-01' 
	  AND(PPACT Between @StartDate And @EndDate)
      AND (PPREG.PPPOLTP Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS'))
	  AND PPNER = 'R' AND
      PPPOLD IN (SELECT vp2.PPPOLYN FROM [IC201].uktrips.dbo.PPREG vp2 WHERE (vp2.PPDISS >= '2009-09-01'))
      GROUP BY PPACT, CLGROUP, CLGRSTATE, PPDISS, PPTIAS, PPNER, convert(varchar(50),PPREG.PPPOLYN), PPREG.PPPOLTP, PPPCODE, PPEXCESS, PPDEP, PPDAYS, PPWKS, PPMTHS, PPFAM, 
      PPVTOT, PPXSBYOUT, PPHRTOT, PPHIRECARXS, PPRET, PPDETC, PPRGTGST, PPPRGT, PPDESN, PPPSD
      HAVING (PPACT Between @StartDate And @EndDate)
END



-- ***** Claims side *****
IF @Mode = 'ALL'
BEGIN
	--1. claims for the period concerned
	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	into #ClaimNums_ALL
	FROM [IC201].ukclaims.dbo.KLREG
	WHERE 
	(KLAUTH <> 'V') AND 
	((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
	(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS')) AND
	((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))

	UNION ALL

	--include UK Claim.NET
	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	FROM [azeusql01].ukclaims.dbo.KLREG
	WHERE 
	(KLAUTH <> 'V') AND 
	((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
	(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS')) AND
	((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))


	--2. produce 1st permanent table claims_events
	SELECT #ClaimNums_ALL.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	INTO [db-au-workspace].dbo.RSA_Extract_Claims_Events_UK
	FROM 
		#ClaimNums_ALL 
		INNER JOIN [IC201].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 
	
	UNION ALL

	SELECT #ClaimNums_ALL.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	FROM 
		#ClaimNums_ALL 
		INNER JOIN [AZEUSQL01].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 
	ORDER BY KE_ID, ClaimNo

	--3a. pull out sections according to event
	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	into #Sects_ALL
	from 
		[db-au-workspace].dbo.RSA_Extract_Claims_Events_UK 
		inner join  [IC201].ukclaims.dbo.klsection on EventTransID = ksevent_id 

	UNION ALL

	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	from 
		[db-au-workspace].dbo.RSA_Extract_Claims_Events_UK 
		inner join  [AZEUSQL01].ukclaims.dbo.klsection on EventTransID = ksevent_id 
	order by ClaimNo, EventTransID, ks_id

	--3b. obtain section descriptions
	update #Sects_ALL
	set SectionDesc = kbdesc
	from
		#Sects_ALL, 
		[IC201].ukclaims.dbo.klbenefit
	where
	Product = kbprod and
	SectCode = kbcode and
	IssuedDt between kbvalidfrom and kbvalidto

	update #Sects_ALL
	set SectionDesc = kbdesc
	from 
		#Sects_ALL, 
		[AZEUSQL01].ukclaims.dbo.klbenefit
	where
		Product = kbprod and
		SectCode = kbcode and
		IssuedDt between kbvalidfrom and kbvalidto

	--3c. pull out estimate history for each section and make 2nd permanent table
	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt
	into [db-au-workspace].dbo.RSA_Extract_Estimates_UK
	FROM 
		#Sects_ALL 
		INNER JOIN [IC201].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate

	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt
	FROM 
		#Sects_ALL 
		INNER JOIN [AZEUSQL01].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate
	order by ClaimNo, EventTransID, SectTransID, ehcreated

	--4. get all the payments - use sects table so dont get repetitive data due to multiple estimate history entries
	-- truepaid = paids - gst
	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
		   convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
		   convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
		   convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
		   kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	INTO [db-au-workspace].dbo.RSA_Extract_Payments_UK
	FROM 
		#Sects_ALL 
		LEFT JOIN [IC201].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE 
		KPSTATUS In ('PAID','APPR') 
		AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values

	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
		   convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
		   convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
		   convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
		   kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	FROM 
		#Sects_ALL 
		LEFT JOIN [AZEUSQL01].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE 
		KPSTATUS In ('PAID','APPR') 
		AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
	ORDER BY  ClaimNo, EventTransID, SectTransID, kpmoddt

	
--5. get all RECY payments. NOTE: NZ Claims RECY payments are not linked to sections, therefore this step is required
--	 to capture RECY payments

--alter SecttransID to accept null values
ALTER TABLE [db-au-workspace].dbo.RSA_Extract_Payments_UK
	ALTER COLUMN SectTransID int NULL


INSERT [db-au-workspace].dbo.RSA_Extract_Payments_UK
SELECT 
	p.KPCLAIM_ID as ClaimNo, 
	p.KPEVENT_ID as EventTransID, 
	null as SectTransID, 
	p.KPAY_ID  PaymentTransID, 
	p.KPMODDT  PaidDt, 
	p.KPBILLAMT  BillAmt, 
	p.KPCURR Currency,
	p.KPRATE  ExchangeRt, 
	p.KPAUD  BillAmt_AUD, 
	p.KPDEPV  Depreciation, 
	p.KPOTHER Other, 
	p.KPEXCESS Excess,
	convert(money,case p.kpstatus WHEN 'PAID'  then p.kppayamt else 0 end) Paid,
	convert(money,case p.kpstatus WHEN 'APPR'  then p.kppayamt else 0 end) App,
	convert(money,case p.kpstatus when 'RECY' then p.kppayamt else 0 end) Recy,
	p.kpgst GST, 
	convert(money, case p.kpstatus WHEN 'PAID'  then p.kppayamt - p.kpgst else 0 end) TruePaid
FROM 
	#ClaimNums_ALL s									--replaced #Sects_ALL table so only 1 row is returned for each RECY payment
	join [IC201].ukclaims.dbo.KLPAYMENTS p	on s.ClaimNo = p.KPCLAIM_ID
WHERE 
	p.KPSTATUS = 'RECY' 
	AND (p.KPMODDT <= @EndDate or p.KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values

UNION ALL

SELECT 
	p.KPCLAIM_ID as ClaimNo, 
	p.KPEVENT_ID as EventTransID, 
	null as SectTransID, 
	p.KPAY_ID  PaymentTransID, 
	p.KPMODDT  PaidDt, 
	p.KPBILLAMT  BillAmt, 
	p.KPCURR Currency,
	p.KPRATE  ExchangeRt, 
	p.KPAUD  BillAmt_AUD, 
	p.KPDEPV  Depreciation, 
	p.KPOTHER Other, 
	p.KPEXCESS Excess,
	convert(money,case p.kpstatus WHEN 'PAID'  then p.kppayamt else 0 end) Paid,
	convert(money,case p.kpstatus WHEN 'APPR'  then p.kppayamt else 0 end) App,
	convert(money,case p.kpstatus when 'RECY' then p.kppayamt else 0 end) Recy,
	p.kpgst GST, 
	convert(money, case p.kpstatus WHEN 'PAID'  then p.kppayamt - p.kpgst else 0 end) TruePaid
FROM 
	#ClaimNums_ALL s									--replaced #Sects_ALL table so only 1 row is returned for each RECY payment
	join [AZEUSQL01].ukclaims.dbo.KLPAYMENTS p	on s.ClaimNo = p.KPCLAIM_ID
WHERE 
	p.KPSTATUS = 'RECY' 
	AND (p.KPMODDT <= @EndDate or p.KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
ORDER BY p.KPCLAIM_ID, p.KPEVENT_ID, p.kpmoddt


drop table #ClaimNums_ALL
drop table #Sects_ALL
END



IF @Mode = 'VERO'
BEGIN
	--1. claims for the period concerned
	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	into #ClaimNums
	FROM [IC201].ukclaims.dbo.KLREG
	WHERE 
		(KLAUTH <> 'V') AND 
		((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
		((KLDISS < '2009-09-01') OR (KLDISS IS NULL)) AND
		(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS') OR (KLPRODUCT is null)) AND
		((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))

	UNION ALL

	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	FROM [AZEUSQL01].ukclaims.dbo.KLREG
	WHERE 
		(KLAUTH <> 'V') AND 
		((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
		((KLDISS < '2009-09-01') OR (KLDISS IS NULL)) AND
		(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS') OR (KLPRODUCT is null)) AND
		((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))


	--2. produce 1st permanent table claims_events
	SELECT #ClaimNums.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	INTO [db-au-workspace].dbo.RSA_Extract_Claims_Events_UK
	FROM #ClaimNums INNER JOIN [IC201].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 

	UNION ALL

	SELECT #ClaimNums.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	FROM #ClaimNums INNER JOIN [AZEUSQL01].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 
	ORDER BY KE_ID, ClaimNo


	--3a. pull out sections according to event
	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	into #Sects
	from
		[db-au-workspace].dbo.RSA_Extract_Claims_Events_UK 
		inner join  [IC201].ukclaims.dbo.klsection on EventTransID = ksevent_id 

	UNION ALL

	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	from 
		[db-au-workspace].dbo.RSA_Extract_Claims_Events_UK 
		inner join  [AZEUSQL01].ukclaims.dbo.klsection on EventTransID = ksevent_id 
	order by ClaimNo, EventTransID, ks_id


	--3b. obtain section descriptions
	update #Sects
	set SectionDesc = kbdesc
	from
	#Sects, [IC201].ukclaims.dbo.klbenefit
	where
		Product = kbprod and
		SectCode = kbcode and
		IssuedDt between kbvalidfrom and kbvalidto

	update #Sects
	set SectionDesc = kbdesc
	from
		#Sects, [AZEUSQL01].ukclaims.dbo.klbenefit
	where
		Product = kbprod and
		SectCode = kbcode and
		IssuedDt between kbvalidfrom and kbvalidto


	--3c. pull out estimate history for each section and make 2nd permanent table
	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt
	into [db-au-workspace].dbo.RSA_Extract_Estimates_UK
	FROM 
		#Sects INNER JOIN [IC201].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate

	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt
	FROM 
		#Sects INNER JOIN [AZEUSQL01].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate
	order by ClaimNo, EventTransID, SectTransID, ehcreated

	--4. get all the payments - use sects table so dont get repetitive data due to multiple estimate history entries
	-- truepaid = paids - gst
	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, 
	KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
	convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
	convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
	convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
	kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	INTO [db-au-workspace].dbo.RSA_Extract_Payments_UK
	FROM #Sects LEFT JOIN [IC201].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE KPSTATUS In ('PAID','APPR') 
	AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values

	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, 
	KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
	convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
	convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
	convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
	kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	FROM #Sects LEFT JOIN [AZEUSQL01].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE KPSTATUS In ('PAID','APPR') 
	AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
	ORDER BY  ClaimNo, EventTransID, SectTransID, kpmoddt

	
--5. get all RECY payments. NOTE: NZ Claims RECY payments are not linked to sections, therefore this step is required
--	 to capture RECY payments

--alter SecttransID to accept null values
ALTER TABLE [db-au-workspace].dbo.RSA_Extract_Payments_UK
	ALTER COLUMN SectTransID int NULL


INSERT [db-au-workspace].dbo.RSA_Extract_Payments_UK
SELECT 
	p.KPCLAIM_ID as ClaimNo, 
	p.KPEVENT_ID as EventTransID, 
	null as SectTransID, 
	p.KPAY_ID  PaymentTransID, 
	p.KPMODDT  PaidDt, 
	p.KPBILLAMT  BillAmt, 
	p.KPCURR Currency,
	p.KPRATE  ExchangeRt, 
	p.KPAUD  BillAmt_AUD, 
	p.KPDEPV  Depreciation, 
	p.KPOTHER Other, 
	p.KPEXCESS Excess,
	convert(money,case p.kpstatus WHEN 'PAID'  then p.kppayamt else 0 end) Paid,
	convert(money,case p.kpstatus WHEN 'APPR'  then p.kppayamt else 0 end) App,
	convert(money,case p.kpstatus when 'RECY' then p.kppayamt else 0 end) Recy,
	p.kpgst GST, 
	convert(money, case p.kpstatus WHEN 'PAID'  then p.kppayamt - p.kpgst else 0 end) TruePaid
FROM 
	#ClaimNums s				--replaced #Sects table so only 1 row is returned for each RECY payment	
	join [IC201].ukclaims.dbo.KLPAYMENTS p	on s.ClaimNo = p.KPCLAIM_ID
WHERE 
	p.KPSTATUS = 'RECY' 
	AND (p.KPMODDT <= @EndDate or p.KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values

UNION ALL

SELECT 
	p.KPCLAIM_ID as ClaimNo, 
	p.KPEVENT_ID as EventTransID, 
	null as SectTransID, 
	p.KPAY_ID  PaymentTransID, 
	p.KPMODDT  PaidDt, 
	p.KPBILLAMT  BillAmt, 
	p.KPCURR Currency,
	p.KPRATE  ExchangeRt, 
	p.KPAUD  BillAmt_AUD, 
	p.KPDEPV  Depreciation, 
	p.KPOTHER Other, 
	p.KPEXCESS Excess,
	convert(money,case p.kpstatus WHEN 'PAID'  then p.kppayamt else 0 end) Paid,
	convert(money,case p.kpstatus WHEN 'APPR'  then p.kppayamt else 0 end) App,
	convert(money,case p.kpstatus when 'RECY' then p.kppayamt else 0 end) Recy,
	p.kpgst GST, 
	convert(money, case p.kpstatus WHEN 'PAID'  then p.kppayamt - p.kpgst else 0 end) TruePaid
FROM 
	#ClaimNums s				--replaced #Sects table so only 1 row is returned for each RECY payment	
	join [AZEUSQL01].ukclaims.dbo.KLPAYMENTS p	on s.ClaimNo = p.KPCLAIM_ID
WHERE 
	p.KPSTATUS = 'RECY' 
	AND (p.KPMODDT <= @EndDate or p.KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
ORDER BY p.KPCLAIM_ID, p.KPEVENT_ID, p.kpmoddt

drop table #ClaimNums
drop table #Sects
END


IF @Mode = 'GLA'
BEGIN
	--1. claims for the period concerned
	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	into #ClaimNums_GLA
	FROM [IC201].ukclaims.dbo.KLREG
	WHERE 
	(KLAUTH <> 'V') AND 
	((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
	(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS')) AND
	((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))

	UNION ALL

	SELECT KLCLAIM  ClaimNo, KLCREATED  EnteredDt, KLFINALDATE  FinalisedDt, KLDISS  IssuedDt, KLDEP  DeptDt, KLRET  RetDt, KLACT AcctPer, convert(varchar(50),KLPOLICY)  PolicyNo, 
	KLPRODUCT  Product, KLRECEIVED Received
	FROM [AZEUSQL01].ukclaims.dbo.KLREG
	WHERE 
	(KLAUTH <> 'V') AND 
	((KLACT  Between @StartDate And @EndDate) or (KLACT is null)) AND
	(KLPRODUCT Not In ('AUL','HPI','W','WAL','WAL1','WAL5','ISIS')) AND
	((KLRECEIVED Between @StartDate And @EndDate) OR (KLRECEIVED is null))

	--2. produce 1st permanent table claims_events
	SELECT #ClaimNums_GLA.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	INTO [db-au-workspace].dbo.RSA_Extract_Claims_Events_UK
	FROM #ClaimNums_GLA INNER JOIN [IC201].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 

	UNION ALL

	SELECT #ClaimNums_GLA.*, KE_ID EventTransID, kecatastrophe CatastropheCode, KEDLOSS LossDate, KEDESC Cause, KEPERIL PerilCode, KECOUNTRY LossCountry
	FROM #ClaimNums_GLA INNER JOIN [AZEUSQL01].ukclaims.dbo.KLEVENT ON ClaimNo = KECLAIM 
	ORDER BY KE_ID, ClaimNo

	--3a. pull out sections according to event
	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	into #Sects_GLA
	from [db-au-workspace].dbo.RSA_Extract_Claims_Events_UK inner join  [IC201].ukclaims.dbo.klsection on EventTransID = ksevent_id 

	UNION ALL

	select ClaimNo, EventTransID, ks_id SectTransID, kssectcode SectCode,  convert(varchar(50),' ') SectionDesc, Product, IssuedDt
	from [db-au-workspace].dbo.RSA_Extract_Claims_Events_UK inner join  [AZEUSQL01].ukclaims.dbo.klsection on EventTransID = ksevent_id 
	order by ClaimNo, EventTransID, ks_id

	--3b. obtain section descriptions
	update #Sects_GLA
	set SectionDesc = kbdesc
	from
	#Sects_GLA, [IC201].ukclaims.dbo.klbenefit
	where
		Product = kbprod and
		SectCode = kbcode and
		IssuedDt between kbvalidfrom and kbvalidto

	update #Sects_GLA
	set SectionDesc = kbdesc
	from
	#Sects_GLA, [AZEUSQL01].ukclaims.dbo.klbenefit
	where
		Product = kbprod and
		SectCode = kbcode and
		IssuedDt between kbvalidfrom and kbvalidto


	--3c. pull out estimate history for each section and make 2nd permanent table
	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, 
	EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt
	into [db-au-workspace].dbo.RSA_Extract_Estimates_UK
	FROM #Sects_GLA INNER JOIN [IC201].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate

	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, SectCode,  SectionDesc, 
	EH_ID EstHistID, EHESTIMATE Estimate, EHCREATED EstimateDt	
	FROM #Sects_GLA INNER JOIN [AZEUSQL01].ukclaims.dbo.KLESTHIST ON SectTransID = EHIS_ID
	WHERE EHCREATED <=@EndDate
	order by ClaimNo, EventTransID, SectTransID, ehcreated

	--4. get all the payments - use sects table so dont get repetitive data due to multiple estimate history entries
	-- truepaid = paids - gst
	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, 
	KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
	convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
	convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
	convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
	kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	INTO [db-au-workspace].dbo.RSA_Extract_Payments_UK
	FROM #Sects_GLA LEFT JOIN [IC201].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE KPSTATUS In ('PAID','APPR') 
	AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
	
	UNION ALL

	SELECT ClaimNo, EventTransID, SectTransID, KPAY_ID  PaymentTransID, KPMODDT  PaidDt, KPBILLAMT  BillAmt, KPCURR Currency, 
	KPRATE  ExchangeRt, KPAUD  BillAmt_AUD, KPDEPV  Depreciation, KPOTHER  Other, KPEXCESS  Excess, 
	convert(money,case kpstatus WHEN 'PAID'  then kppayamt else 0 end) Paid, 
	convert(money,case kpstatus WHEN 'APPR'  then kppayamt else 0 end) App, 
	convert(money,case kpstatus when 'RECY' then kppayamt else 0 end) Recy,
	kpgst GST, convert(money, case kpstatus WHEN 'PAID'  then kppayamt - kpgst else 0 end) TruePaid
	FROM #Sects_GLA LEFT JOIN [AZEUSQL01].ukclaims.dbo.KLPAYMENTS ON SectTransID = KPIS_ID
	WHERE KPSTATUS In ('PAID','APPR') 
	AND (KPMODDT <= @EndDate or KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
	ORDER BY  ClaimNo, EventTransID, SectTransID, kpmoddt


--5. get all RECY payments. NOTE: NZ Claims RECY payments are not linked to sections, therefore this step is required
--	 to capture RECY payments

--alter SecttransID to accept null values
ALTER TABLE [db-au-workspace].dbo.RSA_Extract_Payments_UK
	ALTER COLUMN SectTransID int NULL


INSERT [db-au-workspace].dbo.RSA_Extract_Payments_UK
SELECT 
	p.KPCLAIM_ID as ClaimNo, 
	p.KPEVENT_ID as EventTransID, 
	null as SectTransID, 
	p.KPAY_ID  PaymentTransID, 
	p.KPMODDT  PaidDt, 
	p.KPBILLAMT  BillAmt, 
	p.KPCURR Currency,
	p.KPRATE  ExchangeRt, 
	p.KPAUD  BillAmt_AUD, 
	p.KPDEPV  Depreciation, 
	p.KPOTHER Other, 
	p.KPEXCESS Excess,
	convert(money,case p.kpstatus WHEN 'PAID'  then p.kppayamt else 0 end) Paid,
	convert(money,case p.kpstatus WHEN 'APPR'  then p.kppayamt else 0 end) App,
	convert(money,case p.kpstatus when 'RECY' then p.kppayamt else 0 end) Recy,
	p.kpgst GST, 
	convert(money, case p.kpstatus WHEN 'PAID'  then p.kppayamt - p.kpgst else 0 end) TruePaid
FROM 
	#ClaimNums_GLA s					--replaced #Sects_GLA table so only 1 row is returned for each RECY payment	
	join [IC201].ukclaims.dbo.KLPAYMENTS p	on s.ClaimNo = p.KPCLAIM_ID
WHERE 
	p.KPSTATUS = 'RECY'  
	AND (p.KPMODDT <= @EndDate or p.KPCREATEDDT <= @EndDate)		--20120112_LT - added KPCREATEDDT because RECY payments may have null KPMODDT values
ORDER BY p.KPCLAIM_ID, p.KPEVENT_ID, p.kpmoddt


drop table #ClaimNums_GLA
drop table #Sects_GLA

END

GO
