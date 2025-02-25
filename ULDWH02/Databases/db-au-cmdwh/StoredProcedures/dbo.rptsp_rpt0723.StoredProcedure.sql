USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0723]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0723]   @DateRange varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0723
--  Author:         Atit Wajanasomboonkul
--  Date Created:   20151126
--  Description:    This stored procedure returns sales data for HelloWorld B2C Outlet
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20151126 - AW - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate date = null
declare @rptEndDate date = null

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from vDateRange
	where DateRange = @DateRange

SELECT groupname, 
       subgroupname, 
       date, 
	   AlphaCode,
       OutletName,
	   @rptStartDate StartDate,
	   @rptEndDate EndDate,
       Sum(policycount)           PolicyCount, 
       Sum(agencycommission)      AgencyCommission, 
       Sum(sellprice)             SellPrice, 
       Sum(yago_policycount)      YAGO_PolicyCount, 
       Sum(yago_agencycommission) YAGO_AgencyCommission, 
       Sum(yago_sellprice)        YAGO_SellPrice, 
       Sum(quotecount)            QuoteCount, 
       Sum(yago_quotecount)       YAGO_QuoteCount 
FROM   (SELECT lo.groupname, 
               lo.subgroupname, 
			   lo.AlphaCode,
			   lo.OutletName,
               qs.quotedate       Date, 
               0                  PolicyCount, 
               0                  AgencyCommission, 
               0                  SellPrice, 
               0                  YAGO_PolicyCount, 
               0                  YAGO_AgencyCommission, 
               0                  YAGO_SellPrice, 
               Sum(qs.quotecount) QuoteCount, 
               0                  YAGO_QuoteCount 
        FROM   [db-au-cmdwh]..penquotesummary qs 
		       INNER JOIN [db-au-cmdwh]..penOutlet o
					   ON qs.outletalphakey = o.outletalphakey 
						  AND o.OutletStatus = 'Current' 
               INNER JOIN [db-au-cmdwh]..penOutlet lo 
                       ON lo.OutletKey = o.LatestOutletKey
                          AND (lo.SuperGroupName = 'Stella' or lo.GroupName = 'Traveller''s Choice')
						  AND lo.GroupName In ('Concorde Transonic','helloworld associates','helloworld franchise','helloworld affiliates')
						  AND lo.OutletType = 'B2C'
						  AND lo.OutletStatus = 'Current' 
						  AND lo.CountryKey = 'AU'
        WHERE  quotedate BETWEEN @rptStartDate and @rptEndDate
        GROUP  BY lo.groupname, 
                  lo.subgroupname, 
                  qs.quotedate,
				  lo.AlphaCode,
				  lo.OutletName
        UNION ALL 
        SELECT lo.groupname, 
               lo.subgroupname, 
			   lo.AlphaCode,
			   lo.OutletName,
               Dateadd(year, 1, quotedate) Date, 
               0                           PolicyCount, 
               0                           AgencyCommission, 
               0                           SellPrice, 
               0                           YAGO_PolicyCount, 
               0                           YAGO_AgencyCommission, 
               0                           YAGO_SellPrice, 
               0                           QuoteCount, 
               Sum(qs.quotecount)          YAGO_QuoteCount 
        FROM   [db-au-cmdwh]..penquotesummary qs 
		       INNER JOIN [db-au-cmdwh]..penOutlet o
					   ON qs.outletalphakey = o.outletalphakey 
						  AND o.OutletStatus = 'Current' 
               INNER JOIN [db-au-cmdwh]..penOutlet lo 
                       ON lo.OutletKey = o.LatestOutletKey
                          AND (lo.SuperGroupName = 'Stella' or lo.GroupName = 'Traveller''s Choice')
						  AND lo.GroupName In ('Concorde Transonic','helloworld associates','helloworld franchise','helloworld affiliates')
						  AND lo.OutletType = 'B2C'
						  AND lo.OutletStatus = 'Current' 
						  AND lo.CountryKey = 'AU'
        WHERE  Dateadd(year, 1, quotedate) BETWEEN @rptStartDate and @rptEndDate
        GROUP  BY lo.groupname, 
                  lo.subgroupname, 
                  qs.quotedate,
				  lo.AlphaCode,
				  lo.OutletName 
        UNION ALL 
        SELECT lo.groupname, 
               lo.subgroupname, 
			   lo.AlphaCode,
			   lo.OutletName,
               ps.postingdate                        Date, 
               Sum(ps.newpolicycount)                PolicyCount, 
               Sum(ps.commission + ps.grossadminfee) AgencyCommission, 
               Sum(ps.grosspremium)                  SellPrice, 
               0                                     YAGO_PolicyCount, 
               0                                     YAGO_AgencyCommission, 
               0                                     YAGO_SellPrice, 
               0                                     QuoteCount, 
               0                                     YAGO_QuoteCount 
        FROM   [db-au-cmdwh]..penpolicytranssummary ps 
		       INNER JOIN [db-au-cmdwh]..penOutlet o
					   ON ps.outletalphakey = o.outletalphakey 
						  AND o.OutletStatus = 'Current' 
               INNER JOIN [db-au-cmdwh]..penOutlet lo 
                       ON lo.OutletKey = o.LatestOutletKey
                          AND (lo.SuperGroupName = 'Stella' or lo.GroupName = 'Traveller''s Choice')
						  AND lo.GroupName In ('Concorde Transonic','helloworld associates','helloworld franchise','helloworld affiliates')
						  AND lo.OutletType = 'B2C'
						  AND lo.OutletStatus = 'Current' 
						  AND lo.CountryKey = 'AU'
        WHERE  ps.postingdate BETWEEN @rptStartDate and @rptEndDate
        GROUP  BY lo.groupname, 
                  lo.subgroupname, 
                  ps.postingdate,
				  lo.AlphaCode,
				  lo.OutletName 
        UNION ALL 
        SELECT lo.groupname, 
               lo.subgroupname, 
			   lo.AlphaCode,
			   lo.OutletName,
               ps.yagopostingdate                    Date, 
               0                                     PolicyCount, 
               0                                     AgencyCommission, 
               0                                     SellPrice, 
               Sum(ps.newpolicycount)                YAGO_PolicyCount, 
               Sum(ps.commission + ps.grossadminfee) YAGO_AgencyCommission, 
               Sum(ps.grosspremium)                  YAGO_SellPrice, 
               0                                     QuoteCount, 
               0                                     YAGO_QuoteCount 
        FROM   [db-au-cmdwh]..penpolicytranssummary ps 
		       INNER JOIN [db-au-cmdwh]..penOutlet o
					   ON ps.outletalphakey = o.outletalphakey 
						  AND o.OutletStatus = 'Current' 
               INNER JOIN [db-au-cmdwh]..penOutlet lo 
                       ON lo.OutletKey = o.LatestOutletKey
                          AND (lo.SuperGroupName = 'Stella' or lo.GroupName = 'Traveller''s Choice')
						  AND lo.GroupName In ('Concorde Transonic','helloworld associates','helloworld franchise','helloworld affiliates')
						  AND lo.OutletType = 'B2C'
						  AND lo.OutletStatus = 'Current' 
						  AND lo.CountryKey = 'AU'
        WHERE  ps.yagopostingdate BETWEEN @rptStartDate and @rptEndDate
        GROUP  BY lo.groupname, 
                  lo.subgroupname, 
                  ps.yagopostingdate,
				  lo.AlphaCode,
				  lo.OutletName) a 
GROUP  BY groupname, 
          subgroupname, 
          date,
		  AlphaCode,
		  OutletName 
GO
