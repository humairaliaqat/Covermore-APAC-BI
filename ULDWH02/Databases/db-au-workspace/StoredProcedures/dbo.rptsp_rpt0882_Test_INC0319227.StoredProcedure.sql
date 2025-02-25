USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0882_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0882_Test_INC0319227]	
									@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime,
									@Underwriter varchar(200),
									@Group nvarchar(max)
as
begin

    SET NOCOUNT ON  

	/****************************************************************************************************/
    --  Name:           dbo.rptsp_rpt0882
    --  Author:         Mercede Edrisi
    --  Date Created:   20171031
    --  Description:    Returns Zurich Claim scorecard details
    --					
    --  Parameters:     
    --                  @DateRange: required. valid date range or _User Defined
    --                  @StartDate: optional. required if date range = _User Defined
    --                  @EndDate: optional. required if date range = _User Defined
    --                  @Underwriter: optional. Valid Underwriter name
    --                  @Group: optional. Valid group name
	--
    --  Change History: 
    --                  20171031 - SD - Created on Mercede's behalf
	--					20180102 - SD - Corrected Age and MonthStart calculation while calculating outstanding claims
	--					20181101 - ME - Added @Group parameter. Fixed a float data type bug in avg calculations.

    /****************************************************************************************************/
  
	--uncomment to debug
	--uncomment to debug
    
    -- declare @DateRange varchar(30)
    --declare @StartDate datetime
    --declare @EndDate datetime
    --declare @Underwriter varchar(200)
    --select @DateRange = 'Last Month', @StartDate = null, @EndDate = null, @Underwriter = 'TIP-ZURICH,ZURICH'
    --declare @Group nvarchar(max) = 'All'
	


    /* get reporting dates */
    if @DateRange <> '_User Defined'
        select 
            @StartDate = StartDate, 
            @EndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange

		IF OBJECT_ID('tempdb..#Groups') IS NOT NULL DROP TABLE #Groups
		select
				Item
		INTO #Groups
		from
				[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Group, ',')

		IF OBJECT_ID('tempdb..#UW') IS NOT NULL DROP TABLE #UW
		select
				Item
		INTO #UW
		from
				[db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Underwriter, ',')


	--------------------------------------
	-- Operational indicators --
	--------------------------------------

	DECLARE @StartMonthID INT = (SELECT  MONTH(@StartDate) + (12 * YEAR(@StartDate)))
	DECLARE @EndtMonthID INT = (SELECT  MONTH(@EndDate) + (12 * YEAR(@EndDate)))
	
	---- Operational indicators per month
	IF OBJECT_ID('tempdb..#Operational') IS NOT NULL DROP TABLE #Operational
	SELECT
		  c.CountryKey,
		  MONTH(cm.IncurredDate) + (12 * YEAR(cm.IncurredDate)) AS MonthID,
		  sum(cm.NewCount) AS NewCount,
		  sum(cm.ClosedCount) AS ClosedCount,
		  sum(cm.ReopenedCount) AS ReopenedCount,
		  sum(cm.NewCount) + sum(cm.ReopenedCount) - sum(cm.ClosedCount) AS MonthOutstandingBalance,
		  Case
			When sum(cm.NewCount) = 0 then 0
			Else sum(cm.ClosedCount)/CAST(sum(cm.NewCount) AS FLOAT)
			End ClosureRatio,
		  Case
			When sum(cm.NewCount) = 0 then 0
			Else sum(cm.ReopenedCount)/CAST(sum(cm.NewCount) AS FLOAT)
			End ReopeningRatio,
			uw.Underwriter

	INTO 
		#Operational
	FROM
		[db-au-cmdwh].dbo.penOutlet o
		INNER JOIN [db-au-cmdwh].dbo.clmClaim c
			ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')
		INNER JOIN [db-au-cmdwh].dbo.clmClaimIntradayMovement cm  
			ON (cm.ClaimKey=c.ClaimKey)

outer apply (
select 
case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end as Underwriter)uw

	WHERE
		cm.IncurredDate between @StartDate and @EndDate
		AND
		(
		IsNull(@Underwriter, 'All') = 'All'
		or
		case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end in
			(
				select
					Item
				from
					#UW
			)
		) 
		AND
		(
		IsNull(@Group, 'All') = 'All'
		or
		o.GroupName in
			(SELECT Item FROM #Groups) 
		)
	GROUP BY
		c.CountryKey, 
		MONTH(cm.IncurredDate) + (12 * YEAR(cm.IncurredDate)),
		uw.Underwriter
	ORDER BY 
		1,
		2 

	IF OBJECT_ID('tempdb..#OutstandingClaims') IS NOT NULL DROP TABLE #OutstandingClaims
	CREATE TABLE 
		#OutstandingClaims 
		(CountryKey VARCHAR(5), 
		MonthID INT, 
		AvgOutstandingAge FLOAT, 
		OutstandingCount INT,
		Underwriter nvarchar(500) )

	DECLARE @Counter INT = @StartMonthID

	WHILE @Counter <= @EndtMonthID
	BEGIN


	INSERT INTO #OutstandingClaims
	SELECT  
		CountryKey,
		@Counter AS MonthId,
		SUM(Age)/CAST(COUNT(*) AS FLOAT) AS AvgOutstandingAge,
		COUNT(*) OutstandingCount,
		Underwriter		
	FROM
		(	
		SELECT  
			c.CountryKey,
			cm.ClaimKey,
			--Script modified on 02012018, Corrected Age calculation
			DATEDIFF(DD,c.CreateDate,EOMONTH(CAST( CAST(Case When @Counter%12 = 0 then ((@Counter/12) - 1) Else @Counter/12 End AS VARCHAR(4))+'/'+  CAST(Case When @Counter%12 = 0 then 12 Else @Counter%12 End AS VARCHAR(2))+'/'+'01' AS DATE))) AS Age,
			SUM(NewCount) + SUM(ReopenedCount) - SUM(ClosedCount) AS Outstanding,
			uw1.Underwriter				
		FROM
			[db-au-cmdwh].dbo.penOutlet o
			INNER JOIN [db-au-cmdwh].dbo.clmClaim c
				ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')
			INNER JOIN [db-au-cmdwh].dbo.clmClaimIntradayMovement cm  
				ON (cm.ClaimKey=c.ClaimKey)

outer apply (
select 
case 
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
					when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
					when ( o.CountryKey ) in ('CN') then 'CCIC'
					when ( o.CountryKey ) in ('ID') then 'Simas Net'
					else 'OTHER'
				end as Underwriter )uw1

		WHERE
			 MONTH(cm.IncurredDate) + (12 * YEAR(cm.IncurredDate))  <=  @Counter
			 AND
			 (
				IsNull(@Underwriter, 'All') = 'All'
				or
				case 
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
					when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
					when ( o.CountryKey ) in ('CN') then 'CCIC'
					when ( o.CountryKey ) in ('ID') then 'Simas Net'
					else 'OTHER'
				end in
					(
						select
							Item
						from
							#UW
					)
				)
			AND
			(
				IsNull(@Group, 'All') = 'All'
				or
				o.GroupName in
				(SELECT Item FROM #Groups) 
			)
		GROUP BY
			c.CountryKey, cm.ClaimKey, c.CreateDate,uw1.Underwriter
		HAVING
			SUM(NewCount) + SUM(ReopenedCount) - SUM(ClosedCount) > 0
		) res
	GROUP BY 
		CountryKey,
		Underwriter

		SET @Counter = @Counter + 1
	END

	--------------------------------------
		-- Severities and age indicators --
	--------------------------------------

	-- "Average paid on total closed" and "Average age of closed claims" indicators
	IF OBJECT_ID('tempdb..#SeveritiesAndAge') IS NOT NULL DROP TABLE #SeveritiesAndAge
	SELECT 
		CountryKey,
		MONTH(IncurredDate) + (12 * YEAR(IncurredDate)) AS MonthID,
		SUM(PaymentDelta) /SUM(CASE WHEN EndOfMonth = 1 AND Paid > 0 AND ClosedCount = 1 THEN 1 ELSE 0 END) AS AvgPaidOnClosed,
		SUM(CASE WHEN EndOfMonth = 1 AND ClosedCount = 1 THEN absoluteAge ELSE 0 END) /SUM(CASE WHEN EndOfMonth = 1 AND ClosedCount = 1 THEN 1 ELSE 0 END) AS AvgAgeOfClosedClaims,
		SUM(IncurredDelta) AS Incurred,
		Underwriter
	INTO 
		#SeveritiesAndAge	
	FROM 
		(SELECT
			c.CountryKey,			  
			c.ClaimKey,				  	 			  
			convert(date, cm.IncurredDate) AS IncurredDate,
			cm.absoluteAge + DATEDIFF(DD, c.CreateDate, FirstIncurredDate) AS absoluteAge,
			ROW_NUMBER() OVER (PARTITION BY cm.ClaimKey,MONTH(cm.IncurredDate) + (12 * YEAR(cm.IncurredDate)) ORDER BY cm.IncurredTime DESC) AS EndOfMonth,
			Paid, 
			ClosedCount, 
			PaymentDelta,		
			IncurredDelta,
			uw2.Underwriter			  	  	
		FROM
			[db-au-cmdwh].dbo.penOutlet o
			INNER JOIN [db-au-cmdwh].dbo.clmClaim c
				ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')
			INNER JOIN [db-au-cmdwh].dbo.clmClaimIntradayMovement cm  
				ON (cm.ClaimKey=c.ClaimKey)		
				
outer apply (
select 
case 
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
					when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
					when ( o.CountryKey ) in ('CN') then 'CCIC'
					when ( o.CountryKey ) in ('ID') then 'Simas Net'
					else 'OTHER'
				end as Underwriter )uw2			
						
  		WHERE
			 cm.IncurredDate between @StartDate and @EndDate
			 AND
			 (
				IsNull(@Underwriter, 'All') = 'All'
				or
				case 
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
					when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
					when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
					when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
					when ( o.CountryKey ) in ('CN') then 'CCIC'
					when ( o.CountryKey ) in ('ID') then 'Simas Net'
					else 'OTHER'
				end in
					(
						select
							Item
						from
							#UW
					)
				)
			AND
			(
				IsNull(@Group, 'All') = 'All'
				or
				o.GroupName in
				(SELECT Item FROM #Groups) 
			)
		) Res
	GROUP BY 
		CountryKey,
		MONTH(IncurredDate) + (12 * YEAR(IncurredDate)),
		Underwriter

	-- Average incurred on outstanding
	IF OBJECT_ID('tempdb..#SeveretiesIncurred') IS NOT NULL DROP TABLE #SeveretiesIncurred
	SELECT 
		s.CountryKey,
		s.MonthID,
		CASE 
			WHEN o.OutstandingCount > 0 THEN s.Incurred / o.OutstandingCount
			ELSE 0
		END AS AvgIncurredOnOutstanding,
		s.Underwriter
		 
	INTO 
		#SeveretiesIncurred
	FROM 
		#SeveritiesAndAge s
		INNER JOIN #OutstandingClaims o
			ON s.CountryKey = o.CountryKey
				AND s.MonthID = o.MonthID and s.Underwriter=o.Underwriter

	-- Average notification lag
	IF OBJECT_ID('tempdb..#NotificationLag') IS NOT NULL DROP TABLE #NotificationLag
	SELECT
		c.CountryKey,			  
		MONTH(c.CreateDate) + (12 * YEAR(c.CreateDate)) AS MonthID,
		SUM(CASE WHEN DATEDIFF(DD, ce.LossDate, c.CreateDate) > 0 THEN DATEDIFF(DD, ce.LossDate, c.CreateDate) ELSE 0 END) / SUM(CASE WHEN DATEDIFF(DD, ce.LossDate, c.CreateDate) > 0 THEN 1 ELSE 0 END)  AS AvgNotificationLag,
		uw3.Underwriter
	INTO 
		#NotificationLag	  
	FROM
		[db-au-cmdwh].dbo.penOutlet o
		INNER JOIN [db-au-cmdwh].dbo.clmClaim c
			ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')			
		CROSS APPLY 
		(
			SELECT 
				TOP 1 
				CAST(e.EventDate AS DATE) AS LossDate 
			FROM 
				[db-au-cmdwh].dbo.clmEvent e 
			WHERE 
				c.ClaimKey = e.ClaimKey 
			ORDER BY 
				e.CaseID DESC
		) ce

outer apply (
select
case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end as Underwriter )uw3

  	WHERE
		c.CreateDate between @StartDate and @EndDate
		AND
		(
		IsNull(@Underwriter, 'All') = 'All'
		or
		case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end in
			(
				select
					Item
				from
					#UW
			)
		)
	   AND
		(
			IsNull(@Group, 'All') = 'All'
			or
			o.GroupName in
			(SELECT Item FROM #Groups) 
		)
	GROUP BY
	   c.CountryKey,			  
	   MONTH(c.CreateDate) + (12 * YEAR(c.CreateDate)),
	   uw3.Underwriter

	-- Average age of outstanding claims


	-----------------------------------------------
		-- Recoveries and fraud indicators --
	-----------------------------------------------
	IF OBJECT_ID('tempdb..#FraudsAndRec') IS NOT NULL DROP TABLE #FraudsAndRec
	SELECT
		c.CountryKey,			  
		MONTH(p.ModifiedDate) + (12 * YEAR(p.ModifiedDate)) AS MonthID,			  
		SUM(
			CASE 
				WHEN p.PaymentStatus = 'RECY' THEN p.PaymentAmount
				ELSE 0
			END
			)	AS RecoveredAmount,
		SUM(
			CASE 
				WHEN ao.AssessmentOutcome = 'Fraud detected' AND p.PaymentStatus = 'PAID' THEN p.PaymentAmount
				ELSE 0
			END
			) AS FraudAmount ,
			uw4.Underwriter 	
	INTO 
		#FraudsAndRec
	FROM
		[db-au-cmdwh].dbo.clmPayment p
		INNER JOIN [db-au-cmdwh].dbo.clmClaim c
			ON (c.ClaimKey=p.ClaimKey)
		INNER JOIN [db-au-cmdwh].dbo.penOutlet o
			ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')
		INNER JOIN [db-au-cmdwh].dbo.vClaimAssessmentOutcome ao
			ON (c.ClaimKey=ao.ClaimKey)

outer apply (
select
case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end as Underwriter )uw4

	WHERE
		p.ModifiedDate between @StartDate and @EndDate
		AND
		(
		IsNull(@Underwriter, 'All') = 'All'
		or
		case 
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH','KG','BP') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
			when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
			when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
			when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
			when ( o.CountryKey ) in ('CN') then 'CCIC'
			when ( o.CountryKey ) in ('ID') then 'Simas Net'
			else 'OTHER'
		end in
			(
				select
					Item
				from
					#UW
			)
		)
		AND p.isDeleted = 0
		AND
		(
			IsNull(@Group, 'All') = 'All'
			or
			o.GroupName in
			(SELECT Item FROM #Groups) 
		)
	GROUP BY
		c.CountryKey,			  
		MONTH(p.ModifiedDate) + (12 * YEAR(p.ModifiedDate)),
		uw4.Underwriter	


	IF OBJECT_ID('tempdb..#TotalPaidOnTotalClosed') IS NOT NULL DROP TABLE #TotalPaidOnTotalClosed
	SELECT 
		CountryKey,
		MONTH(m.IncurredDate) + (12 * YEAR(m.IncurredDate)) AS MonthID,
		SUM(m.PaymentDelta) AS TotalPaidOnClosed,
		Underwriter				
	INTO 
		#TotalPaidOnTotalClosed	
	FROM 
		[db-au-cmdwh].dbo.clmClaimIntradayMovement m
		INNER JOIN 
		(SELECT
			c.CountryKey,			
			MONTH(IncurredDate) + (12 * YEAR(IncurredDate)) AS MonthID,  
			c.ClaimKey,				  	 			  			  
			ROW_NUMBER() OVER (PARTITION BY cm.ClaimKey,MONTH(IncurredDate) + (12 * YEAR(IncurredDate)) ORDER BY cm.IncurredTime DESC) AS EndOfMonth,			  
			ClosedCount,
			uw5.Underwriter
		FROM
			[db-au-cmdwh].dbo.penOutlet o
			INNER JOIN [db-au-cmdwh].dbo.clmClaim c
				ON (o.OutletKey=c.OutletKey and o.OutletStatus='Current')
			INNER JOIN [db-au-cmdwh].dbo.clmClaimIntradayMovement cm  
				ON (cm.ClaimKey=c.ClaimKey)	
outer apply (
select
case 
				when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
				when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
				when ( o.CountryKey ) in ('CN') then 'CCIC'
				when ( o.CountryKey ) in ('ID') then 'Simas Net'
				else 'OTHER'
			end as Underwriter	)uw5			
			
							
  		WHERE
			cm.IncurredDate between @StartDate and @EndDate
			AND
			(
			IsNull(@Underwriter, 'All') = 'All'
			or
			case 
				when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) < '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) < '2017-07-01')) then 'TIP-GLA'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( o.GroupCode ) in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','AH') and (( c.PolicyIssuedDate ) >= '2017-06-01' OR (( o.AlphaCode ) in ('APN0004','APN0005') and ( c.PolicyIssuedDate ) >= '2017-07-01')) then 'TIP-ZURICH'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) between '2002-08-23' and '2009-06-30' then 'VERO'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2009-07-01' and ( c.PolicyIssuedDate ) < '2017-06-01' then 'GLA'
				when ( o.CountryKey ) in ('AU', 'NZ') and ( c.PolicyIssuedDate ) >= '2017-06-01' then 'ZURICH'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) >= '2017-07-01' then 'ERV'
				when ( o.CountryKey ) in ('UK') and ( c.PolicyIssuedDate ) < '2009-09-01' then 'UKU'
				when ( o.CountryKey ) in ('MY', 'SG') then 'ETIQA'
				when ( o.CountryKey ) in ('CN') then 'CCIC'
				when ( o.CountryKey ) in ('ID') then 'Simas Net'
				else 'OTHER'
			end in
				(
					select
						Item
					from
						#UW
				)
			)
		   AND
			(
				IsNull(@Group, 'All') = 'All'
				or
				o.GroupName in
				(SELECT Item FROM #Groups) 
			)
		) Res
			ON m.ClaimKey = res.ClaimKey
				AND MonthID = MONTH(m.IncurredDate) + (12 * YEAR(m.IncurredDate))
				AND res.EndOfMonth = 1
				AND res.ClosedCount = 1
	GROUP BY 
		CountryKey,
		MONTH(m.IncurredDate) + (12 * YEAR(m.IncurredDate)),
		Underwriter

	IF OBJECT_ID('tempdb..#FraudsAndRecRatio') IS NOT NULL DROP TABLE #FraudsAndRecRatio
	SELECT 
		f.CountryKey, 
		f.MonthID,
		Case
			When p.TotalPaidOnClosed = 0 then 0
			Else f.RecoveredAmount / p.TotalPaidOnClosed
		End RecoveryRatio,
		Case
			When p.TotalPaidOnClosed = 0 then 0
			Else f.FraudAmount / p.TotalPaidOnClosed
		End FraudRatio,
		 f.Underwriter
	INTO 
		#FraudsAndRecRatio
	FROM
		#FraudsAndRec f
		INNER JOIN #TotalPaidOnTotalClosed p
			ON f.CountryKey = p.CountryKey
				AND f.MonthID = p.MonthID and f.Underwriter=p.Underwriter
	ORDER BY 
		CountryKey, 
		MonthID,
		Underwriter


	-----------------------------------------------
		-- Creating merged table --
	-----------------------------------------------

	SELECT  
		op.CountryKey,
		op.MonthID,
		--Script modified on 02012018, Corrected MonthStart calculation
		CAST( CAST(Case when op.MonthID%12 = 0 then ((op.MonthID/12) - 1) Else op.MonthID/12 End AS VARCHAR(4))+'/'+  CAST(Case When op.MonthID%12 = 0 then 12 Else op.MonthID%12 End AS VARCHAR(2))+'/'+'01' AS DATE) AS MonthStart,
		op.NewCount,
		op.ClosedCount,
		op.ReopenedCount,
		o.OutstandingCount,
		op.ClosureRatio,
		op.ReopeningRatio,
		s.AvgPaidOnClosed,
		si.AvgIncurredOnOutstanding,
		n.AvgNotificationLag,
		s.AvgAgeOfClosedClaims,
		o.AvgOutstandingAge AS AvgAgeOfOutstandingClaims,
		ABS(f.RecoveryRatio) AS RecoveryRatio,
		f.FraudRatio,
		@StartDate [StartDate],
		@EndDate [EndDate],
		op.Underwriter		 
	FROM 
		#Operational op
		INNER JOIN #OutstandingClaims o
			ON op.CountryKey = o.CountryKey
				AND op.MonthID = o.MonthID and op.Underwriter=o.Underwriter
		INNER JOIN #SeveritiesAndAge s
			ON op.CountryKey = s.CountryKey
				AND op.MonthID = s.MonthID and op.Underwriter=s.Underwriter
		INNER JOIN #SeveretiesIncurred si
			ON op.CountryKey = si.CountryKey
				AND op.MonthID = si.MonthID and op.Underwriter=si.Underwriter
		INNER JOIN #NotificationLag n
			ON op.CountryKey = n.CountryKey
				AND op.MonthID = n.MonthID and op.Underwriter=n.Underwriter
		INNER JOIN #FraudsAndRecRatio f
			ON op.CountryKey = f.CountryKey
				AND op.MonthID = f.MonthID and op.Underwriter=f.Underwriter
	ORDER BY 
		1, 
		2
End
GO
