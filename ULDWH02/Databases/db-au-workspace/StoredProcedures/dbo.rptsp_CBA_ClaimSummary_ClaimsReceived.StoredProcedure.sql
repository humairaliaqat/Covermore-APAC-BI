USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_ClaimSummary_ClaimsReceived]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[rptsp_CBA_ClaimSummary_ClaimsReceived]		
											
as

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

	DECLARE @Country NVARCHAR(10) = 'AU'
	DECLARE @SuperGroup NVARCHAR(MAX) = 'Medibank'

	DECLARE @StartDate DATE = (SELECT CAST(DATEADD(MM,-6,GETDATE()) AS DATE))
	DECLARE @EndDate DATE = (SELECT CAST(GETDATE() AS DATE))


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
		eh.FirstEstimateDate	as [First Estimate Date],
		eh.FirstEstimateValue	as [First Estimate Value],
		p.ProductDisplayName	as [Product]

	from 
		[db-au-cba].dbo.penOutlet o
		inner join [db-au-cba].dbo.clmClaim cl on
			cl.OutletKey = o.OutletKey
		inner join [db-au-cba].dbo.penPolicy p on
			cl.PolicyNo = p.PolicyNumber and
			cl.CountryKey = p.CountryKey and
			p.CompanyKey = o.CompanyKey
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
	    outer apply
		(
		   select top 1
				EHCreateDate FirstEstimateDate,
				EHEstimateValue FirstEstimateValue,
				EHCreatedBy FirstEstimateCreator
		   from 
				[db-au-cba].dbo.clmEstimateHistory eh
		   where
				eh.SectionKey = cs.SectionKey
		   order by 
				EHCreateDate
		) eh
	where o.SuperGroupName = @SuperGroup
		and CAST(cl.ReceivedDate AS DATE) >= @StartDate

			


GO
