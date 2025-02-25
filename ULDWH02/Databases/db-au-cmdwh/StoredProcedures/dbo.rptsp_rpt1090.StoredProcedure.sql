USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1090]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[rptsp_rpt1090] 
@DateRange varchar(30),
@StartDate varchar(10), 
@EndDate varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;


-- ================================================
---- Name:	rptsp_rpt1090
---- Description:	Rental Car Protection (site) Claims Report
---- Author:	Molly Ma
---- Date Created:	20191011
---- Description: This stored procedure extract the claim related payments for RCP
---- Parameters: @DateRange: Value is valid date range
-- @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
-- @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd	
---- Change History: 20191030 update the formula for calculating ClaimLife
-- ================================================

	declare @dataStartDate datetime
	declare @dataEndDate datetime
	declare @Countrykey varchar(5)

	/* initialise dates */
	if @DateRange = '_User Defined'
		select @dataStartDate = @StartDate, @dataEndDate = @EndDate
	else
		select @dataStartDate = StartDate, @dataEndDate = EndDate
		from [db-au-cmdwh].dbo.vDateRange
		where DateRange = @DateRange

	select 
	po.OutletName
	,po.GroupName
	,po.SubGroupName
	,w.ClaimNumber
	,pp.Countrykey
	,w.WorkType
	,pp.TripType
	,pp.PolicyNumber
	,wc.ClaimDescription
	,wc.ClaimCountry
	,ou.EventLocation
	,ou.EventCountry
	,ou.PerilDescription as IncidentType 
	,ou.AdditionalDetail as IncidentDesc 
	,w.ClaimantFirstName + ' ' + w.ClaimantSurname as ClaimantName 
	,wc.Street + ' ' + wc.Suburb + ' ' + wc.State as PolicyHolderAddress 
	,cc.StatusDesc as CurrentStage 
	,w.CreationDate as DateReceived 
	,cc.FirstNilDate as DateIncidentClosed 
	,cp.PaidPayment as TotalPaid 
	,cp.RecoveredPayment as TotalRecovered 
	,cp.EstimateValue as TotalReserved
	,pp.areaName as PlanName 
	,[dbo].[fn_GetUnderWriterCode] (pp.companyKey, pp.countryKey, pp.AlphaCode, pp.IssueDate) AS Insurer 
	--,case 
	--	when cc.StatusDesc='Finalised' then datediff(day,w.Creationdate,cc.FirstNilDate)
	--	ELSE datediff(day,w.CreationDate,getdate())
	--end as ClaimLife
	,case 
		when w.StatusName = 'Complete' then datediff(day,w.Creationdate,cc.FirstNilDate)
		when w.Statusname= 'Rejected'  then 0
		ELSE datediff(day,w.CreationDate,getdate())
	end as ClaimLife
	,CASE
		WHEN w.claimdescription like '%rental van%' then 'Van'
		WHEN w.claimdescription like '%CamperVan%' then 'CamperVan'
		WHEN w.claimdescription like '%Motor%' then 'Motorhome'
		ELSE 'Car'
	END as VehicleType
	,@dataStartDate
	,@dataEndDate
	from 
	[db-au-cmdwh].[dbo].[e5Work_v3] w 
	inner join clmClaim cc on cc.ClaimNo=w.ClaimNumber 
	inner join penPolicy pp on cc.PolicyNo=pp.PolicyNumber 
	Left Join [dbo].[clmOnlineClaimEvent] ou on w.Claimkey=ou.claimkey 
	left join penOutlet po on pp.OutletAlphaKey = po.OutletAlphaKey and po.OutletStatus = 'Current' /* New */
	inner Join [dbo].[vClaimAssessmentOutcome] ouc on w.claimkey=ouc.claimkey 
	outer apply (
		select 
			sum( 
				case 
					when cp.PaymentStatus = 'PAID' then cp.PaymentAmount 
					else 0 
				end *	(1 - cs.isDeleted) 
			) PaidPayment, 
			sum( 
				case 
					when cp.PaymentStatus = 'RECY' then cp.PaymentAmount 
					else 0 
				end *(1 - cs.isDeleted) 
			) RecoveredPayment, 
			sum(distinct isnull(cs.EstimateValue, 0) * (1 - cs.isDeleted)) EstimateValue, 
			sum(distinct isnull(cs.RecoveryEstimateValue, 0) * (1 - cs.isDeleted)) RecoveryEstimateValue 
		from [db-au-cmdwh].dbo.clmSection cs 
		Left Join [db-au-cmdwh].dbo.clmPayment cp on cp.SectionKey = cs.SectionKey and cp.isDeleted = 0 
		 where cs.ClaimKey = w.ClaimKey 
	 ) cp 
	 outer apply ( 
		 select 
		 max(case when wp.Property_ID = 'EventCountry' then try_convert(varchar(50), wp.PropertyValue) else '0' end) ClaimCountry, 
		 max(case when wp.Property_ID = 'ClaimDescription' then try_convert(varchar(50), wp.PropertyValue) else '0' end) claimDescription, 
		 max(case when wp.Property_ID = 'Company' then try_convert(varchar(50), wp.PropertyValue) else '0' end) Company, 
		 max(case when wp.Property_ID = 'State' then try_convert(varchar(50), wp.PropertyValue) else '0' end) State, 
		 max(case when wp.Property_ID = 'Street' then try_convert(varchar(50), wp.PropertyValue) else '0' end) Street, 
		 max(case when wp.Property_ID = 'Suburb' then try_convert(varchar(50), wp.PropertyValue) else '0' end) Suburb 
		 from [dbo].[e5WorkProperties_v3] wp 
		 where 
		 wp.Work_ID=w.Work_ID 
	 ) wc 
	where workType in ('recovery','Claim') and 
	po.GroupName = 'Halo'
	--pp.PolicyNumber like 'RCP%' and 
	--wc.claimDescription <> '0' 
	Order by 1 
END

GO
