USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[sp_EarningDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_EarningDataSet]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           sp_EarningDataSet
--  Author:         Linus Tor
--  Date Created:   20161120
--  Description:    This stored procedure inserts data into [db-au-actuary].[dbo].[EarningDataSet]
--
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20161120 - LT - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2009-07-01', @EndDate = '2016-12-31'
*/

declare @rptStartDate date
declare @rptEndDate date

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange



if object_id('[db-au-workspace].dbo.tmp_EarningDataSetPolicy') is not null drop table [db-au-workspace].dbo.tmp_EarningDataSetPolicy
select
	o.SuperGroupName,
	p.PolicyNumber,
	pts.PolicyTransactionKey,
	ppp.Premium,
	ppp.NAP,
	p.IssueDate,
	p.PolicyStart as DepartureDate,
	p.PolicyEnd as ReturnDate,
	p.TripType,
	p.AreaType as PlanType,
	trav.OldestAge
into [db-au-workspace].dbo.tmp_EarningDataSetPolicy
from
	[db-au-cmdwh].dbo.penPolicy p
	inner join [db-au-cmdwh].dbo.penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey 
	inner join [db-au-cmdwh].dbo.vPenguinPolicyPremiums ppp on pts.PolicyTransactionKey = ppp.PolicyTransactionKey
	outer apply
	(
		select top 1
			SuperGroupName
		from
			[db-au-star].dbo.dimOutlet
		where
			OutletAlphaKey = p.OutletAlphaKey
	) o
	outer apply
	(
		select max(Age) as OldestAge
		from [db-au-cmdwh].dbo.penPolicyTraveller
		where PolicyKey = p.PolicyKey
	) trav
where
	p.CountryKey = 'AU' and	
	p.IssueDate >= @rptStartDate and
	p.IssueDate < dateadd(d,1,@rptEndDate)


if object_id('[db-au-workspace].dbo.tmp_EarningDataSet') is not null drop table [db-au-workspace].dbo.tmp_EarningDataSet
select
	ROW_NUMBER() OVER (PARTITION BY p.PolicyNumber ORDER BY PolicyNumber) RNK,
	p.SuperGroupName,
	p.PolicyNumber,
	claim.ClaimNumber,
	claim.EventID,
	claim.SectionID,
	claim.ActuarialBenefitGroup,
	sum(p.Premium) as Premium,
	sum(p.NAP) as NAP,
	claim.LossDate,
	p.IssueDate,
	p.DepartureDate,
	p.ReturnDate,
	p.TripType,
	p.PlanType,
	p.OldestAge,
	sum(claim.PaymentAmount) as PaidToDate,
	sum(claim.EstimateOutstanding) as EstimateOutstanding,
	sum(claim.IncurredClaimsCost) as IncurredClaimsCost
into [db-au-workspace].dbo.tmp_EarningDataSet
from
	[db-au-workspace].dbo.tmp_EarningDataSetPolicy p
	outer apply
	(
		select
			c.ClaimNo as ClaimNumber,
			e.EventID,
			e.EventDate as LossDate,
			s.SectionID,
			b.ActuarialBenefitGroup,
			sum(s.EstimateOutstanding) as EstimateOutstanding,
			sum(payment.PaymentAmount) as PaymentAmount,
			sum(s.EstimateOutstanding) + sum(payment.PaymentAmount) as IncurredClaimsCost
		from
			[db-au-cmdwh].dbo.clmClaim c
			inner join [db-au-cmdwh].dbo.clmEvent e on c.ClaimKey = e.ClaimKey
			outer apply
			(
				select SectionKey, SectionID, SectionDescription as Section, EstimateValue as EstimateOutstanding, BenefitSectionKey
				from [db-au-cmdwh].dbo.clmSection
				where
					EventKey = e.EventKey and
					isDeleted = 0
			) s
			outer apply
			(
				select top 1 ActuarialBenefitGroup
				from 
					[db-au-cmdwh].dbo.vclmBenefitCategory
				where
					BenefitSectionKey = s.BenefitSectionKey
			) b
			outer apply
			(
				select
					sum(PaymentAmount) as PaymentAmount
				from [db-au-cmdwh].dbo.clmPayment
				where
					SectionKey = s.SectionKey and
					isDeleted = 0 and
					PaymentStatus in ('Paid','Recy')
			) payment
		where
			c.PolicyTransactionKey = p.PolicyTransactionKey
		group by
			c.ClaimNo,
			e.EventID,
			e.EventDate,
			s.SectionID,
			b.ActuarialBenefitGroup
	) claim

group by
	p.SuperGroupName,
	p.PolicyNumber,
	p.IssueDate,
	p.DepartureDate,
	p.ReturnDate,
	p.TripType,
	p.PlanType,
	p.OldestAge,
	claim.ClaimNumber,
	claim.EventID,
	claim.LossDate,
	claim.SectionID,
	claim.ActuarialBenefitGroup


update [db-au-workspace].dbo.tmp_EarningDataSet
set Premium = 0,
	NAP = 0
where
	Rnk <> 1


--insert into [db-au-actuary] database.
if object_id('[db-au-actuary].dbo.EarningDataSet') is not null drop table [db-au-actuary].dbo.EarningDataSet
select * 
into [db-au-actuary].dbo.EarningDataSet
from [db-au-workspace].dbo.tmp_EarningDataSet


--drop temp tables
drop table [db-au-workspace].dbo.tmp_EarningDataSetPolicy
drop table [db-au-workspace].dbo.tmp_EarningDataSet


GO
