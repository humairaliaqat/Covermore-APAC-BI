USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_ClaimSummary_ClaimsFinalised]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_CBA_ClaimSummary_ClaimsFinalised]		
	@SDate date = null,
	@EDate date = null,
	@GroupCode varchar(2) = 'CB'	
as
BEGIN
	SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           CBA_ClaimSummary
--  Author:         ME
--  Date Created:   20180821
--  Description:    Return Claim data for certain period  
--
--  Parameters:     NA
--   
--  Change History: 20180523 - ME - Created 
--                  
/****************************************************************************************************/

--uncomment to debug
	--DECLARE 	@StartDate datetime = null,
	--			@EndDate datetime = null,
	--			@GroupCode varchar(2) = 'CB'

	DECLARE @Country NVARCHAR(10) = 'AU'

	DECLARE @StartDate DATE = IsNull(@SDate, DateAdd(day,1,EOMONTH(GetDate(),-1))) --(SELECT CAST(DATEADD(MM,-6,GETDATE()) AS DATE))
	DECLARE @EndDate DATE = IsNull(@EDate, DateAdd(day,-1,GetDate()))--(SELECT CAST(GETDATE() AS DATE))
	print @StartDate
	print @EndDate

	SELECT UPPER(dest.Destination) AS Destination,
		   coun.ISO2Code
	INTO #Country
	FROM
		( SELECT Destination,
			     Max(LoadID) AS LoadID
		  FROM   [db-au-cba].[dbo].[dimDestination]
		  GROUP  BY Destination) dest
	OUTER APPLY ( SELECT TOP 1 ISO2Code
				  FROM [db-au-cba].[dbo].[dimDestination]
				  WHERE LoadID = dest.LoadID
					 AND Destination = dest.Destination) Coun

	SELECT CAST([Date] AS DATE) AS [Date],
		   CAST(EOMONTH([Date]) AS DATE) AS [MonthEnd]
	INTO #Calendar
	FROM [db-au-cba].dbo.Calendar
	WHERE [Date] BETWEEN @StartDate AND @EndDate

	CREATE CLUSTERED INDEX [IX_Date] ON #Calendar
	(
		[Date] ASC
	)
	

	select        
		cl.ClaimKey, 
		cl.ClaimNo as [Claim Number],  
		cl.OutletKey,
		cl.ReceivedDate as [Received Date],
		case
			when cl.FinalisedDate is null then 0
			else 1
		end IsFinalised,
		convert(date, ce.EventDate) as [Event Date],
		loc.Destination as [Event Country],
		loc.ISO2Code,
		datediff(day,ce.EventDate,cl.ReceivedDate) as [Notification lag],
		cbb.BenefitCategory as [Benefit Category],
		(isnull(cp.PaidPayment, 0) + isnull(cp.RecoveredPayment, 0)) * (1 - cs.isDeleted) as [Paid Recovered Payment],
		(isnull(cp.PaidPayment, 0) + isnull(cp.RecoveredPayment, 0) + isnull(cs.EstimateValue, 0)) * (1 - cs.isDeleted) as [Claim Value],
		cl.FirstNilDate	as [First Nil Date],
		cl.FinalisedDate as [Finalised Date],
		ca.AssessmentOutcome as [Assessment Outcome],
		datediff(day,cl.ReceivedDate,cl.FinalisedDate)	as [Claim Finalised Age],
		CASE 
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) <= 10 THEN CAST(datediff(day,cl.ReceivedDate,cl.FinalisedDate) as varchar)
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 11 AND 15 THEN '11 - 15'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 16 AND 20 THEN '16 - 20'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 21 AND 30 THEN '21 - 30'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 31 AND 40 THEN '31 - 40'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 41 AND 50 THEN '41 - 50'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 51 AND 60 THEN '51 - 60'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 61 AND 70 THEN '61 - 70'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 71 AND 80 THEN '71 - 80'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) BETWEEN 81 AND 90 THEN '81 - 90'
			WHEN datediff(day,cl.ReceivedDate,cl.FinalisedDate) >= 91 THEN '91+'
		END as [Claim Finalised Age Band],
		datediff(day,cl.ReceivedDate,cl.FirstNilDate) as [Claim First Nil Age],
		p.ProductDisplayName	as [Product]
	from 
		[db-au-cba].dbo.clmClaim cl
		inner join [db-au-cba].dbo.penOutlet o on
			cl.OutletKey = o.OutletKey AND O.OutletStatus = 'Current'
		inner join #Calendar c on
			CAST(cl.FinalisedDate as date) = c.Date
		inner join [db-au-cba].dbo.penPolicy p on
			cl.PolicyNo = p.PolicyNumber and
			cl.CountryKey = p.CountryKey and
			p.CompanyKey = o.CompanyKey
		inner join [db-au-cba].dbo.vClaimAssessmentOutcome ca on
			ca.ClaimKey = cl.ClaimKey
		inner join [db-au-cba].dbo.clmSection cs on
			cs.ClaimKey = cl.ClaimKey
		left join [db-au-cba].dbo.clmEvent ce on
			ce.EventKey = cs.EventKey
		left join #Country loc	on
			loc.Destination = ce.EventCountryName
		left join [db-au-cba]..vclmBenefitCategory cbb on
			cbb.BenefitSectionKey = cs.BenefitSectionKey
		outer apply
		(
			select  
				sum(
					case
						when cp.PaymentStatus = 'PAID' then cp.PaymentAmount
						else 0
					end
				) PaidPayment,
				sum(
					case
						when cp.PaymentStatus = 'RECY' then cp.PaymentAmount
						else 0
					end
				) RecoveredPayment
			from
				[db-au-cba].dbo.clmPayment cp
			where
				cp.SectionKey = cs.SectionKey and
				cp.isDeleted = 0
		) cp
	where o.GroupCode = @GroupCode

END

GO
