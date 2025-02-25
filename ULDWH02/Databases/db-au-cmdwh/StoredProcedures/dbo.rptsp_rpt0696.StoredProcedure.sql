USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0696]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0696]	
									@DateRange varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_rpt0696
--  Author:         Atit Wajanasomboonkul
--  Date Created:   20151124
--  Description:    This stored procedure returns policy count and claim count for RACQ 30 and under
--
--  Parameters:		@DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@Timezone: valid timezone code eg. AUS Eastern Standard Time
--   
--  Change History: 20151124 - AW - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @IncidentCountry varchar(100)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @TimeZone varchar(100)
select @Country = 'AU', @IncidentCountry = 'USA%', @DateRange = 'Last 6 Months', @StartDate = null, @EndDate = null, @TimeZone = 'AUS Eastern Standard Time'
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
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

SELECT Isnull(quote.QuoteDate, policy.PostingDate)         IssueDate,
       Isnull(quote.alphacode, policy.alphacode)           AlphaCode, 
       Isnull(quote.outletname, policy.outletname)         OutletName, 
       Isnull(quote.storecode, policy.storecode)           StoreCode, 
       Isnull(quote.consultantname, policy.consultantname) ConsultantName, 
       quote.quotecount, 
       policy.policycount, 
       policy.commission, 
       policy.sellprice, 
       policy.premium,
	   @rptStartDate StartDate,
	   @rptEndDate EndDate	   
FROM   (SELECT qs.QuoteDate,
			   o.alphacode, 
               o.outletname, 
               qs.storecode, 
               usr.firstname + ' ' + usr.lastname ConsultantName, 
               Sum(quotecount)                    QuoteCount         
        FROM   [db-au-cmdwh]..penquotesummary qs WITH (nolock) 
               INNER JOIN [db-au-cmdwh]..penoutlet o 
                       ON qs.outletalphakey = o.outletalphakey 
                          AND o.outletstatus = 'Current' 
               INNER JOIN [db-au-cmdwh]..penuser usr 
                       ON qs.userkey = usr.userkey 
                          AND usr.userstatus = 'Current' 
               LEFT OUTER JOIN [db-au-cmdwh]..usrcdgquotealpha cqa 
                            ON o.outletalphakey = cqa.outletalphakey 
        WHERE  quotedate BETWEEN convert(datetime,@rptStartDate) AND convert(datetime,@rptEndDate)
               AND ( qs.purchasepath = '30 And Under' 
                      OR cqa.businessunit = 'AAA-RACQ30' ) 
        GROUP  BY qs.QuoteDate,
				  o.alphacode, 
                  o.outletname, 
                  qs.storecode, 
                  usr.firstname + ' ' + usr.lastname) quote 
       FULL OUTER JOIN 
	   (SELECT pt.PostingDate,
	           out.alphacode, 
               out.outletname, 
               pt.storecode, 
               usr.firstname + ' ' + usr.lastname ConsultantName , 
			Sum(pt.basepolicycount)            PolicyCount, 
			Sum(vp.[agency commission])        Commission, 
			Sum(vp.[sell price])               SellPrice, 
			Sum(vp.[premium])                  Premium 
		FROM   [db-au-cmdwh]..penpolicytranssummary pt 
			INNER JOIN [db-au-cmdwh]..penoutlet out 
				ON pt.outletalphakey = out.outletalphakey 
					AND out.outletstatus = 'Current' 
			LEFT OUTER JOIN [db-au-cmdwh]..penuser usr 
				ON pt.userkey = usr.userkey 
					AND usr.userstatus = 'Current' 
			INNER JOIN [db-au-cmdwh].dbo.vpenguinpolicypremiums vp 
				ON pt.policytransactionkey = vp.policytransactionkey 
		WHERE  pt.purchasepath = '30 And Under' 
			AND out.groupname = 'RACQ' 
			AND pt.countrykey = 'AU' 
			AND pt.PostingDate BETWEEN convert(datetime,@rptStartDate) AND convert(datetime,@rptEndDate)
		GROUP  BY pt.PostingDate,
		          out.alphacode, 
				  out.outletname, 
				  pt.storecode, 
				  usr.firstname + ' ' + usr.lastname) policy 
	ON quote.alphacode = policy.alphacode 
		AND quote.outletname = policy.outletname 
		AND Isnull(quote.storecode, '') = Isnull(policy.storecode, '') 
		AND quote.consultantname = policy.consultantname 
		AND quote.QuoteDate = policy.PostingDate


------------------------------

GO
