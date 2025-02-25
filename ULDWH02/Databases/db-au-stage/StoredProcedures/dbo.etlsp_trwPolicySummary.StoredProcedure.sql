USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_trwPolicySummary]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [db-au-stage]

CREATE procedure [dbo].[etlsp_trwPolicySummary]

@EIGUID				NVARCHAR(100),
@Package_ID			NVARCHAR(100),
@Package_Name		NVARCHAR(500),
@user_name			NVARCHAR(200),
@Category			NVARCHAR(50)

as

SET NOCOUNT ON

BEGIN
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, 0, @Category, '', '', 'Insert', 'trwPolicySummary', '',0,0
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicySummary', @user_name, 0, '', '', '', '', 'Package_Run_Details', 'Running', 'Process Dimension Facts - Policy', 'Insert', 0, 0, 3, 1, NULL, NULL, NULL

	Declare @From_CreatedDate date
	Declare @End_CreatedDate date

	select @From_CreatedDate = DeltaLoadStartDate, @End_CreatedDate = DeltaLoadToDate
	from ETL_trwPackageStatus where PackageID = 1 and PackageSubGroupID = 7


	if object_id('[db-au-stage].dbo.trwPolicySummaryTemp') is not null 
	BEGIN
		DROP TABLE [db-au-stage].dbo.trwPolicySummaryTemp 

		CREATE TABLE [db-au-stage].dbo.[trwPolicySummaryTemp] (
					[PolicyDetailID]					int,
					[PolicySK]							int,
					[EmployeeSK]						int,
					[AgentEmployeeSK]					int,
					[SellingPlanSK]						int,
					[InvoiceSK]							int,
					[PolicyNumber]						numeric(22, 0) null,
					[OrgStatus]							nvarchar(50) null,
					[CurStatus]							nvarchar(50) null,
					[Endorsement]						numeric(18, 0) null,
					[ActualPolicyCount]					int,
					EndorsementDate						date null,
					EndorsementDateTime					datetime null,
					YAGOEndorsementDate					date null,
					DateOfPolicyCancelled				date null,
					DateTimeOfPolicyCancelled			datetime null,
					YAGODateOfPolicyCancelled			date null,
					DateOfPolicy						date null,
					DateTimeOfPolicy					datetime null,
					YAGODateOfPolicy					date null,
					PassportNumber						nvarchar(50) null,
					DepartureDate						datetime null,
					Days								numeric(18, 0) null,
					DaySlab								nvarchar(50) null,
					ArrivalDate							datetime null,
					Name								nvarchar(50) null,
					DOB									datetime null,
					Age									numeric(18, 0) null,
					AgeSlab								nvarchar(50) null,
					TrawellTagNumber					numeric(18, 0) null,
					Nominee								nvarchar(50) null,
					Relation							nvarchar(50) null,
					PastIllness							nvarchar(1000) null,
					RestrictedCoverage					bit null,
					BasePremium							numeric(18, 2) null,
					Premium								numeric(18, 2) null,							
					RiderPercent						numeric(18, 2) null,
					RiderPremium						numeric(18, 2) null,
					NewPremium							numeric(18, 2) null,
					OldPremium							numeric(18, 2) null,
					TotalAmount							numeric(18, 2) null,
					ServiceTaxRate						numeric(18, 2) null,
					CESS1Rate							numeric(18, 2) null,
					CESS2Rate							numeric(18, 2) null,
					ServiceTax							numeric(18, 2) null,
					CESS1								numeric(18, 2) null,
					CESS2								numeric(18, 2) null,
					GrossAmount							numeric(18, 2) null,
					DiscountPercent						numeric(18, 2) null,
					DiscountAmount						numeric(18, 2) null,
					DiscountServiceTax					numeric(18, 2) null,
					DiscountCESS1						numeric(18, 2) null,
					DiscountCESS2						numeric(18, 2) null,
					NetServiceTax						numeric(18, 2) null,
					NetCESS1							numeric(18, 2) null,
					NetCESS2							numeric(18, 2) null,
					NetAmount							numeric(18, 2) null,
					OldRiderPremium						numeric(18, 2) null,
					OldTotalAmount						numeric(18, 2) null,
					ActualNewPremium					numeric(18, 2) null,
					ActualOldPremium					numeric(18, 2) null,
					ActualTotalAmount					numeric(18, 2) null,
					ActualServiceTax					numeric(18, 2) null,
					ActualCESS1							numeric(18, 2) null,
					ActualCESS2							numeric(18, 2) null,
					ActualGrossAmount					numeric(18, 2) null,
					ActualDiscountPercent				numeric(18, 2) null,
					ActualDiscountAmount				numeric(18, 2) null,
					ActualDiscountServiceTax			numeric(18, 2) null,
					ActualDiscountCESS1					numeric(18, 2) null,
					ActualDiscountCESS2					numeric(18, 2) null,
					ActualNetServiceTax					numeric(18, 2) null,
					ActualNetCESS1						numeric(18, 2) null,
					ActualNetCESS2						numeric(18, 2) null,
					ActualNetAmount						numeric(18, 2) null,
					Actualoldinsurancecost				numeric(18, 2) null,
					ActualNewinsurancecost				numeric(18, 2) null,
					Actualinsurancecost					numeric(18, 2) null,
					ActualTdsAmount						numeric(18, 2) null,
					ActualComissionAmount				numeric(18, 2) null,
					ActualoldTApremium					numeric(18, 2) null,
					ActualNewTApremium					numeric(18, 2) null,
					ActualTApremim						numeric(18, 2) null,
					Remarks								ntext null,
					CreatedDate							date null,
					CreatedDateTime						datetime null,
					YAGOCreatedDate						date null,
					pdfreference						nvarchar(max),
					ManualPremiumTotal					numeric(18, 2) null,
					ManualPremiumBasic					numeric(18, 2) null,
					ManualPremiumServiceTax				numeric(18, 2) null,
					sponsorname							nvarchar(max),
					sponsorrelation						nvarchar(max),
					Rider								nvarchar(max),
					[hashkey]						varbinary(50)
				)
	END
	ELSE
	BEGIN
			CREATE TABLE [db-au-stage].dbo.[trwPolicySummaryTemp] (
					[PolicyDetailID]					int,
					[PolicySK]							int,
					[EmployeeSK]						int,
					[AgentEmployeeSK]					int,
					[SellingPlanSK]						int,
					[InvoiceSK]							int,
					[PolicyNumber]						numeric(22, 0) null,
					[OrgStatus]							nvarchar(50) null,
					[CurStatus]							nvarchar(50) null,
					[Endorsement]						numeric(18, 0) null,
					[ActualPolicyCount]					int,
					EndorsementDate						date null,
					EndorsementDateTime					datetime null,
					YAGOEndorsementDate					date null,
					DateOfPolicyCancelled				date null,
					DateTimeOfPolicyCancelled			datetime null,
					YAGODateOfPolicyCancelled			date null,
					DateOfPolicy						date null,
					DateTimeOfPolicy					datetime null,
					YAGODateOfPolicy					date null,
					PassportNumber						nvarchar(50) null,
					DepartureDate						datetime null,
					Days								numeric(18, 0) null,
					DaySlab								nvarchar(50) null,
					ArrivalDate							datetime null,
					Name								nvarchar(50) null,
					DOB									datetime null,
					Age									numeric(18, 0) null,
					AgeSlab								nvarchar(50) null,
					TrawellTagNumber					numeric(18, 0) null,
					Nominee								nvarchar(50) null,
					Relation							nvarchar(50) null,
					PastIllness							nvarchar(1000) null,
					RestrictedCoverage					bit null,
					BasePremium							numeric(18, 2) null,
					Premium								numeric(18, 2) null,							
					RiderPercent						numeric(18, 2) null,
					RiderPremium						numeric(18, 2) null,
					NewPremium							numeric(18, 2) null,
					OldPremium							numeric(18, 2) null,
					TotalAmount							numeric(18, 2) null,
					ServiceTaxRate						numeric(18, 2) null,
					CESS1Rate							numeric(18, 2) null,
					CESS2Rate							numeric(18, 2) null,
					ServiceTax							numeric(18, 2) null,
					CESS1								numeric(18, 2) null,
					CESS2								numeric(18, 2) null,
					GrossAmount							numeric(18, 2) null,
					DiscountPercent						numeric(18, 2) null,
					DiscountAmount						numeric(18, 2) null,
					DiscountServiceTax					numeric(18, 2) null,
					DiscountCESS1						numeric(18, 2) null,
					DiscountCESS2						numeric(18, 2) null,
					NetServiceTax						numeric(18, 2) null,
					NetCESS1							numeric(18, 2) null,
					NetCESS2							numeric(18, 2) null,
					NetAmount							numeric(18, 2) null,
					OldRiderPremium						numeric(18, 2) null,
					OldTotalAmount						numeric(18, 2) null,
					ActualNewPremium					numeric(18, 2) null,
					ActualOldPremium					numeric(18, 2) null,
					ActualTotalAmount					numeric(18, 2) null,
					ActualServiceTax					numeric(18, 2) null,
					ActualCESS1							numeric(18, 2) null,
					ActualCESS2							numeric(18, 2) null,
					ActualGrossAmount					numeric(18, 2) null,
					ActualDiscountPercent				numeric(18, 2) null,
					ActualDiscountAmount				numeric(18, 2) null,
					ActualDiscountServiceTax			numeric(18, 2) null,
					ActualDiscountCESS1					numeric(18, 2) null,
					ActualDiscountCESS2					numeric(18, 2) null,
					ActualNetServiceTax					numeric(18, 2) null,
					ActualNetCESS1						numeric(18, 2) null,
					ActualNetCESS2						numeric(18, 2) null,
					ActualNetAmount						numeric(18, 2) null,
					Actualoldinsurancecost				numeric(18, 2) null,
					ActualNewinsurancecost				numeric(18, 2) null,
					Actualinsurancecost					numeric(18, 2) null,
					ActualTdsAmount						numeric(18, 2) null,
					ActualComissionAmount				numeric(18, 2) null,
					ActualoldTApremium					numeric(18, 2) null,
					ActualNewTApremium					numeric(18, 2) null,
					ActualTApremim						numeric(18, 2) null,
					Remarks								ntext null,
					CreatedDate							date null,
					CreatedDateTime						datetime null,
					YAGOCreatedDate						date null,
					pdfreference						nvarchar(max),
					ManualPremiumTotal					numeric(18, 2) null,
					ManualPremiumBasic					numeric(18, 2) null,
					ManualPremiumServiceTax				numeric(18, 2) null,
					sponsorname							nvarchar(max),
					sponsorrelation						nvarchar(max),
					Rider								nvarchar(max),
					[hashkey]							varbinary(50)
				)

	END

	create clustered index idx_trwPolicyTemp_PolicyDetailID on [db-au-stage].dbo.trwPolicySummaryTemp(policydetailid)
	create nonclustered index idx_trwPolicyTemp_PolicyID on [db-au-stage].dbo.trwPolicySummaryTemp(PolicySK)
	create nonclustered index idx_trwPolicyTemp_EmployeeID on [db-au-stage].dbo.trwPolicySummaryTemp(EmployeeSK)
	create nonclustered index idx_trwPolicyTemp_AgentEmployeeID on [db-au-stage].dbo.trwPolicySummaryTemp(AgentEmployeeSK)
	create nonclustered index idx_trwPolicyTemp_SellingPlanID on [db-au-stage].dbo.trwPolicySummaryTemp(SellingPlanSK)
	create nonclustered index idx_trwPolicyTemp_InvoiceID on [db-au-stage].dbo.trwPolicySummaryTemp(InvoiceSK)
	create nonclustered index idx_trwPolicyTemp_HashKey on [db-au-stage].dbo.trwPolicySummaryTemp(HashKey)

	insert into [db-au-stage].dbo.trwPolicySummaryTemp
		(policydetailid, PolicySK,EmployeeSK,AgentEmployeeSK,SellingPlanSK,InvoiceSK,PolicyNumber,OrgStatus,CurStatus,
		Endorsement,ActualPolicyCount,EndorsementDate,EndorsementDateTime,YAGOEndorsementDate,
		DateOfPolicyCancelled,DateTimeOfPolicyCancelled,YAGODateOfPolicyCancelled,
		DateOfPolicy, DateTimeOfPolicy,	YAGODateOfPolicy,
		PassportNumber,DepartureDate,Days,DaySlab,ArrivalDate,Name,DOB,Age,AgeSlab,TrawellTagNumber,Nominee,
		Relation,PastIllness,RestrictedCoverage,BasePremium,Premium,RiderPercent,RiderPremium,NewPremium,OldPremium,TotalAmount,ServiceTaxRate,CESS1Rate,CESS2Rate,ServiceTax,
		CESS1,CESS2,GrossAmount,DiscountPercent,DiscountAmount,DiscountServiceTax,DiscountCESS1,DiscountCESS2,NetServiceTax,NetCESS1,NetCESS2,NetAmount,OldRiderPremium,OldTotalAmount,ActualNewPremium,
		ActualOldPremium,ActualTotalAmount,ActualServiceTax,ActualCESS1,ActualCESS2,ActualGrossAmount,ActualDiscountPercent,ActualDiscountAmount,ActualDiscountServiceTax,ActualDiscountCESS1,
		ActualDiscountCESS2,ActualNetServiceTax,ActualNetCESS1,ActualNetCESS2,ActualNetAmount,Actualoldinsurancecost,ActualNewinsurancecost,Actualinsurancecost,ActualTdsAmount,
		ActualComissionAmount,ActualoldTApremium,ActualNewTApremium,ActualTApremim,Remarks,pdfreference,ManualPremiumTotal,ManualPremiumBasic,ManualPremiumServiceTax,sponsorname,
		sponsorrelation,CreatedDate,CreatedDateTime,YAGOCreatedDate,Rider)
	select b.policydetailid, a.policysk, d.EmployeeSK, c.AgentEmployeeSK, e.SellingPlanSK, f.InvoiceSK, a.PolicyNumber, a.Status, a.Status,
		Endorsement,
		case when Endorsement = 0 and a.Status in ('Active', 'EarlyArrive', 'Cancelled') then 1
		else 0
		end ActualActivePolicyCount,
		convert(date, EndorsementDate), EndorsementDate, convert(date, dateadd(year, 1, EndorsementDate)) YAGOEndorsementDate,
		case when Endorsement = 0 and a.Status in ('Active', 'EarlyArrive', 'Cancelled') then NULL
		else convert(date, b.CreatedDateTime)
		end,
		case when Endorsement = 0 and a.Status in ('Active', 'EarlyArrive', 'Cancelled') then NULL
		else b.CreatedDateTime
		end,
		case when Endorsement = 0 and a.Status in ('Active', 'EarlyArrive', 'Cancelled') then NULL
		else dateadd(year, 1, convert(date, b.CreatedDateTime))
		end,
		convert(date, DateOfPolicy), DateOfPolicy, convert(date, dateadd(year, 1, DateOfPolicy)) YAGODateOfPolicy,
		PassportNumber, DepartureDate, Days, da.DayBandDisplay, ArrivalDate, b.Name, DOB, b.Age, ageba.AgeBandDisplay, TrawellTagNumber, Nominee, Relation, PastIllness, RestrictedCoverage, BasePremium, Premium, RiderPercent, RiderPremium, NewPremium,
		OldPremium, TotalAmount, ServiceTaxRate, CESS1Rate, CESS2Rate, ServiceTax, CESS1, CESS2, GrossAmount, b.DiscountPercent, DiscountAmount, DiscountServiceTax, DiscountCESS1,
		DiscountCESS2, NetServiceTax, NetCESS1, NetCESS2, NetAmount, OldRiderPremium, OldTotalAmount, ActualNewPremium, ActualOldPremium, ActualTotalAmount, ActualServiceTax, ActualCESS1,
		ActualCESS2, ActualGrossAmount, ActualDiscountPercent, ActualDiscountAmount, ActualDiscountServiceTax, ActualDiscountCESS1, ActualDiscountCESS2, ActualNetServiceTax,
		ActualNetCESS1, ActualNetCESS2, ActualNetAmount, Actualoldinsurancecost, ActualNewinsurancecost, Actualinsurancecost, ActualTdsAmount, ActualComissionAmount, ActualoldTApremium,
		ActualNewTApremium, ActualTApremim, REPLACE(REPLACE(cast (b.Remarks as nvarchar(max)), char(10), ' '), char(13), ' ') Remarks,
		REPLACE(REPLACE(pdfreference, char(10), ' '), char(13), ' ') pdfreference, ManualPremiumTotal, ManualPremiumBasic, ManualPremiumServiceTax, sponsorname, sponsorrelation,
		convert(date, b.CreatedDateTime), b.CreatedDateTime, convert(date, dateadd(year, 1, b.CreatedDateTime)) YAGOCreatedDate,
		ISNULL(STUFF((SELECT ':' + M.Name FROM (select policyid, A.CostPlanID, A.Name, C.SellingPlanID
											FROM [db-au-cmdwh].dbo.[trwPolicyRider] A
											inner join [db-au-cmdwh].dbo.[trwSellingCostPlan] C
											on A.CostPlanID = C.CostPlanID
												and A.SellingPlanID = C.SellingPlanID
											left outer join [db-au-stage].dbo.trwdimPolicyDetail D with (nolock)
											on A.PolicyDetailID = D.PolicyDetailID
											--where D.PolicyID = 2353958
											) M
			Where e.CostPlanID = M.CostPlanID and e.SellingPlanID = M.SellingPlanID and a.policyid = M.policyid order by 1
			FOR XML PATH('')), 1, 1, ''), '') As Rider
	from [db-au-cmdwh].dbo.trwPolicy a
	inner join [db-au-stage].dbo.trwdimPolicyDetail b with (nolock)
	on a.policyid = b.policyid
	left outer join [db-au-cmdwh].dbo.trwAgentEmployee c with (nolock)
	on a.AgentEmployeeID = c.AgentEmployeeID
	left outer join [db-au-cmdwh].dbo.trwEmployee d with (nolock)
	on a.EmployeeID = d.EmployeeID
	left outer join [db-au-cmdwh].dbo.trwSellingCostPlan e with (nolock)
	on b.SellingPlanID = e.SellingPlanID
	left outer join [db-au-cmdwh].dbo.trwInvoice f with (nolock)
	on b.InvoiceID = f.InvoiceID
	left outer join [db-au-cmdwh].dbo.[trwPolicyRider] g with (nolock)
	on b.PolicyDetailID = g.PolicyDetailID
	left outer join [db-au-stage].dbo.trwdimAge ageba
	on ageba.age = b.age
	left outer join [db-au-stage].dbo.trwdimTravelDays da
	on b.days = da.[day]
	where convert(date, b.CreatedDateTime) >= @From_CreatedDate and convert(date, b.CreatedDateTime) <= @End_CreatedDate
	GROUP BY b.policydetailid, a.policysk, d.EmployeeSK, c.AgentEmployeeSK, e.SellingPlanSK, f.InvoiceSK, a.PolicyNumber, a.Status, a.Status,
		Endorsement, case when Endorsement = 0 and a.Status in ('Active', 'EarlyArrive', 'Cancelled') then 1
						else 0
						end,
		convert(date, EndorsementDate), EndorsementDate, convert(date, dateadd(year, 1, EndorsementDate)),
		convert(date, DateOfPolicy), DateOfPolicy, convert(date, dateadd(year, 1, DateOfPolicy)),
		PassportNumber, DepartureDate, Days, da.DayBandDisplay, ArrivalDate, b.Name, DOB, b.Age, ageba.AgeBandDisplay, TrawellTagNumber, Nominee, Relation, PastIllness, RestrictedCoverage, BasePremium, Premium, RiderPercent, RiderPremium, NewPremium,
		OldPremium, TotalAmount, ServiceTaxRate, CESS1Rate, CESS2Rate, ServiceTax, CESS1, CESS2, GrossAmount, b.DiscountPercent, DiscountAmount, DiscountServiceTax, DiscountCESS1,
		DiscountCESS2, NetServiceTax, NetCESS1, NetCESS2, NetAmount, OldRiderPremium, OldTotalAmount, ActualNewPremium, ActualOldPremium, ActualTotalAmount, ActualServiceTax, ActualCESS1,
		ActualCESS2, ActualGrossAmount, ActualDiscountPercent, ActualDiscountAmount, ActualDiscountServiceTax, ActualDiscountCESS1, ActualDiscountCESS2, ActualNetServiceTax,
		ActualNetCESS1, ActualNetCESS2, ActualNetAmount, Actualoldinsurancecost, ActualNewinsurancecost, Actualinsurancecost, ActualTdsAmount, ActualComissionAmount, ActualoldTApremium,
		ActualNewTApremium, ActualTApremim, REPLACE(REPLACE(cast (b.Remarks as nvarchar(max)), char(10), ' '), char(13), ' '),
		REPLACE(REPLACE(pdfreference, char(10), ' '), char(13), ' '), ManualPremiumTotal, ManualPremiumBasic, ManualPremiumServiceTax, sponsorname, sponsorrelation,
		convert(date, b.CreatedDateTime), b.CreatedDateTime, convert(date, dateadd(year, 1, b.CreatedDateTime)),
		e.CostPlanID, e.SellingPlanID, a.PolicyID
	UNION ALL
	select dt.policydetailid, a.policysk, d.EmployeeSK, c.AgentEmployeeSK, e.SellingPlanSK, f.InvoiceSK, a.PolicyNumber, a.Status, a.Status,
		Endorsement, -1, 
		convert(date, EndorsementDate), EndorsementDate, convert(date, dateadd(year, 1, EndorsementDate)) YAGOEndorsementDate,

		convert(date, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end),
		case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end,
		convert(date, dateadd(year, 1, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end)),

		--convert(date, cr.CreatedDateTime), cr.CreatedDateTime, convert(date, dateadd(year, 1, cr.CreatedDateTime)),
		convert(date, DateOfPolicy), DateOfPolicy, convert(date, dateadd(year, 1, DateOfPolicy)) YAGODateOfPolicy,
		PassportNumber, DepartureDate, Days, da.DayBandDisplay, ArrivalDate, dt.Name, DOB, dt.Age, ageba.AgeBandDisplay, TrawellTagNumber, Nominee, Relation, PastIllness, RestrictedCoverage, BasePremium, Premium, RiderPercent, RiderPremium, NewPremium,
		OldPremium, TotalAmount, ServiceTaxRate, CESS1Rate, CESS2Rate, ServiceTax, CESS1, CESS2, GrossAmount, dt.DiscountPercent, DiscountAmount, DiscountServiceTax, DiscountCESS1,
		DiscountCESS2, NetServiceTax, NetCESS1, NetCESS2, NetAmount, OldRiderPremium, OldTotalAmount, ActualNewPremium, ActualOldPremium, ActualTotalAmount, ActualServiceTax, ActualCESS1,
		ActualCESS2, ActualGrossAmount, ActualDiscountPercent, ActualDiscountAmount, ActualDiscountServiceTax, ActualDiscountCESS1, ActualDiscountCESS2, ActualNetServiceTax,
		ActualNetCESS1, ActualNetCESS2, ActualNetAmount, Actualoldinsurancecost, ActualNewinsurancecost, Actualinsurancecost, ActualTdsAmount, ActualComissionAmount, ActualoldTApremium,
		ActualNewTApremium, ActualTApremim, 'Cancelled: ' + REPLACE(REPLACE(cast (cr.Remarks as nvarchar(max)), char(10), ' '), char(13), ' ') Remarks,
		REPLACE(REPLACE(pdfreference, char(10), ' '), char(13), ' ') pdfreference, ManualPremiumTotal, ManualPremiumBasic, ManualPremiumServiceTax, sponsorname, sponsorrelation,

		convert(date, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end),
		case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end,
		convert(date, dateadd(year, 1, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end)),

		--convert(date, cr.CreatedDateTime), cr.CreatedDateTime, convert(date, dateadd(year, 1, cr.CreatedDateTime)) YAGOCreatedDate,
		ISNULL(STUFF((SELECT ':' + M.Name FROM (select policyid, A.CostPlanID, A.Name, C.SellingPlanID
											FROM [db-au-cmdwh].dbo.[trwPolicyRider] A
											inner join [db-au-cmdwh].dbo.[trwSellingCostPlan] C
											on A.CostPlanID = C.CostPlanID
												and A.SellingPlanID = C.SellingPlanID
											left outer join [db-au-stage].dbo.trwdimPolicyDetail D with (nolock)
											on A.PolicyDetailID = D.PolicyDetailID
											--where D.PolicyID = 2353958
											) M
			Where e.CostPlanID = M.CostPlanID and e.SellingPlanID = M.SellingPlanID and a.policyid = M.policyid order by 1
			FOR XML PATH('')), 1, 1, ''), '') As Rider
	from (
		select PolicyID, Remarks, CreatedDateTime from [db-au-stage].dbo.trwdimPolicyCancellationRequest with (nolock)
		where Status = 'Accepted'
		--where CreatedDateTime >= '2016-05-12'  and CreatedDateTime < '2016-05-18'
		) cr
	inner join [db-au-cmdwh].dbo.trwPolicy a with (nolock)
	on cr.PolicyID = a.PolicyID
	left outer join
		(
		select dtsg.*, dts.EndorsementDate,dts.PassportNumber,dts.InsuranceCategoryID,dts.SellingPlanID,dts.DepartureDate,dts.Days,dts.ArrivalDate,dts.Address1,dts.Address2,dts.City,
			dts.District,dts.State,dts.PinCode,dts.Country,dts.PhoneNo,dts.MobileNo,dts.EmailAddress,dts.UniversityName,dts.UniversityAddress,dts.Name,dts.DOB,dts.Age,dts.TrawellTagNumber,
			dts.Nominee,dts.Relation,dts.PastIllness,dts.RestrictedCoverage,dts.InvoiceID,dts.pdfreference,dts.sponsorname,dts.sponsorrelation,
			dts.BasePremium * -1 BasePremium,dts.Premium * -1 Premium,NewPremium * -1 NewPremium,OldPremium * -1 OldPremium, TotalAmount * -1 TotalAmount,
			ServiceTaxRate, CESS1Rate, CESS2Rate, ServiceTax, CESS1, CESS2, GrossAmount * -1 GrossAmount, DiscountPercent, DiscountAmount * -1 DiscountAmount, DiscountServiceTax,
			DiscountCESS1, DiscountCESS2, NetServiceTax, NetCESS1, NetCESS2, NetAmount * -1 NetAmount, OldTotalAmount * -1 OldTotalAmount, ActualNewPremium * -1 ActualNewPremium,
			ActualOldPremium * -1 ActualOldPremium, ActualServiceTax, ActualCESS1, ActualCESS2, ActualGrossAmount * -1 ActualGrossAmount,
			ActualDiscountPercent, ActualDiscountAmount * -1 ActualDiscountAmount, ActualDiscountServiceTax, ActualDiscountCESS1, ActualDiscountCESS2, ActualNetServiceTax, ActualNetCESS1, ActualNetCESS2,
			ActualTdsAmount * -1 ActualTdsAmount, ActualoldTApremium * -1 ActualoldTApremium, ActualTApremim * -1 ActualTApremim, ManualPremiumTotal * -1 ManualPremiumTotal,
			ManualPremiumBasic * -1 ManualPremiumBasic, ManualPremiumServiceTax, Actualoldinsurancecost * -1 Actualoldinsurancecost
		from [db-au-stage].dbo.trwdimPolicyDetail dts with (nolock)
		inner join
		(
			select policyid, max(PolicyDetailID) PolicyDetailID, max(Endorsement) Endorsement,
				sum(RiderPercent) * -1 RiderPercent, sum(RiderPremium) * -1 RiderPremium, sum(OldRiderPremium) * -1 OldRiderPremium, sum(ActualNetAmount) * -1 ActualNetAmount,
				sum(ActualTotalAmount) * -1 ActualTotalAmount, sum(ActualNewinsurancecost) * -1 ActualNewinsurancecost,
				sum(Actualinsurancecost) * -1 Actualinsurancecost, sum(ActualComissionAmount) * -1 ActualComissionAmount, sum(ActualNewTApremium) * -1 ActualNewTApremium
			from [db-au-stage].dbo.trwdimPolicyDetail d with (nolock)
			where d.PolicyID
					in (select distinct PolicyID from [db-au-stage].dbo.trwdimPolicyCancellationRequest with (nolock) where Status = 'Accepted')
			group by policyid
		) dtsg
		on dts.PolicyDetailID = dtsg.PolicyDetailID
	) dt
	on dt.PolicyID = a.PolicyID

	left outer join [db-au-cmdwh].dbo.trwAgentEmployee c
	on a.AgentEmployeeID = c.AgentEmployeeID
	left outer join [db-au-cmdwh].dbo.trwEmployee d
	on a.EmployeeID = d.EmployeeID
	left outer join [db-au-cmdwh].dbo.trwSellingCostPlan e
	on dt.SellingPlanID = e.SellingPlanID
	left outer join [db-au-cmdwh].dbo.trwInvoice f
	on dt.InvoiceID = f.InvoiceID
	left outer join [db-au-stage].dbo.trwdimAge ageba
	on ageba.age = dt.age
	left outer join [db-au-stage].dbo.trwdimTravelDays da
	on da.[day] = dt.days
	where convert(date, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end)
		>= @From_CreatedDate
		and convert(date, case when convert(date, a.ModifiedDateTime) > convert(date, cr.CreatedDateTime) then a.ModifiedDateTime else cr.CreatedDateTime end)
		<= @End_CreatedDate
	GROUP BY
		dt.policydetailid, a.policysk, d.EmployeeSK, c.AgentEmployeeSK, e.SellingPlanSK, f.InvoiceSK, a.PolicyNumber, a.Status, a.Status,
		Endorsement,
		convert(date, EndorsementDate), EndorsementDate, convert(date, dateadd(year, 1, EndorsementDate)),
		convert(date, DateOfPolicy), DateOfPolicy, convert(date, dateadd(year, 1, DateOfPolicy)),
		PassportNumber, DepartureDate, Days, da.DayBandDisplay, ArrivalDate, dt.Name, DOB, dt.Age, ageba.AgeBandDisplay, TrawellTagNumber, Nominee, Relation, PastIllness, RestrictedCoverage, BasePremium, Premium, RiderPercent, RiderPremium, NewPremium,
		OldPremium, TotalAmount, ServiceTaxRate, CESS1Rate, CESS2Rate, ServiceTax, CESS1, CESS2, GrossAmount, dt.DiscountPercent, DiscountAmount, DiscountServiceTax, DiscountCESS1,
		DiscountCESS2, NetServiceTax, NetCESS1, NetCESS2, NetAmount, OldRiderPremium, OldTotalAmount, ActualNewPremium, ActualOldPremium, ActualTotalAmount, ActualServiceTax, ActualCESS1,
		ActualCESS2, ActualGrossAmount, ActualDiscountPercent, ActualDiscountAmount, ActualDiscountServiceTax, ActualDiscountCESS1, ActualDiscountCESS2, ActualNetServiceTax,
		ActualNetCESS1, ActualNetCESS2, ActualNetAmount, Actualoldinsurancecost, ActualNewinsurancecost, Actualinsurancecost, ActualTdsAmount, ActualComissionAmount, ActualoldTApremium,
		ActualNewTApremium, ActualTApremim, REPLACE(REPLACE(cast (cr.Remarks as nvarchar(max)), char(10), ' '), char(13), ' '),
			REPLACE(REPLACE(pdfreference, char(10), ' '), char(13), ' '), ManualPremiumTotal, ManualPremiumBasic, ManualPremiumServiceTax, sponsorname, sponsorrelation,
		convert(date, cr.CreatedDateTime), cr.CreatedDateTime, convert(date, dateadd(year, 1, cr.CreatedDateTime)),a.ModifiedDateTime,
		e.CostPlanID, e.SellingPlanID, a.PolicyID


	declare @mergeoutput table (MergeAction varchar(50))
	declare
		@name varchar(50),
		@sourcecount int,
		@insertcount int,
		@updatecount int

	update [db-au-stage].dbo.trwPolicySummaryTemp
	set 
		HashKey = binary_checksum(policydetailid, PolicySK,EmployeeSK,AgentEmployeeSK,SellingPlanSK,InvoiceSK,PolicyNumber,OrgStatus,CurStatus,Endorsement,ActualPolicyCount,EndorsementDate,DateOfPolicy,PassportNumber,DepartureDate,Days,ArrivalDate,Name,DOB,Age,TrawellTagNumber,Nominee,
				Relation,PastIllness,RestrictedCoverage,BasePremium,Premium,RiderPercent,RiderPremium,NewPremium,OldPremium,TotalAmount,ServiceTaxRate,CESS1Rate,CESS2Rate,ServiceTax,
				CESS1,CESS2,GrossAmount,DiscountPercent,DiscountAmount,DiscountServiceTax,DiscountCESS1,DiscountCESS2,NetServiceTax,NetCESS1,NetCESS2,NetAmount,OldRiderPremium,OldTotalAmount,ActualNewPremium,
				ActualOldPremium,ActualTotalAmount,ActualServiceTax,ActualCESS1,ActualCESS2,ActualGrossAmount,ActualDiscountPercent,ActualDiscountAmount,ActualDiscountServiceTax,ActualDiscountCESS1,
				ActualDiscountCESS2,ActualNetServiceTax,ActualNetCESS1,ActualNetCESS2,ActualNetAmount,Actualoldinsurancecost,ActualNewinsurancecost,Actualinsurancecost,ActualTdsAmount,
				ActualComissionAmount,ActualoldTApremium,ActualNewTApremium,ActualTApremim,Remarks,pdfreference,ManualPremiumTotal,ManualPremiumBasic,ManualPremiumServiceTax,sponsorname,
				sponsorrelation,CreatedDateTime,Rider,DateOfPolicyCancelled,DateTimeOfPolicyCancelled,YAGODateOfPolicyCancelled)


	select
		@sourcecount = count(*)
	from
		[db-au-stage].dbo.trwPolicySummaryTemp

	if object_id('[db-au-cmdwh].dbo.trwPolicySummary') is null
	BEGIN

		CREATE TABLE [db-au-cmdwh].dbo.[trwPolicySummary] (
			[PolicySummarySK]					int identity(1,1) not null,
			[policydetailid]					int,
			[PolicySK]							int,
			[EmployeeSK]						int,
			[AgentEmployeeSK]					int,
			[SellingPlanSK]						int,
			[InvoiceSK]							int,
			[PolicyNumber]						numeric(22, 0) null,
			[OrgStatus]							nvarchar(50) null,
			[CurStatus]							nvarchar(50) null,
			[Endorsement]						numeric(18, 0) null,
			[ActualPolicyCount]					int,
			EndorsementDate						date null,
			EndorsementDateTime					datetime null,
			YAGOEndorsementDate					date null,
			DateOfPolicyCancelled				date null,
			DateTimeOfPolicyCancelled			datetime null,
			YAGODateOfPolicyCancelled			date null,
			DateOfPolicy						date null,
			DateTimeOfPolicy					datetime null,
			YAGODateOfPolicy					date null,
			PassportNumber						nvarchar(50) null,
			DepartureDate						datetime null,
			Days								numeric(18, 0) null,
			DaySlab								nvarchar(50) null,
			ArrivalDate							datetime null,
			Name								nvarchar(50) null,
			DOB									datetime null,
			Age									numeric(18, 0) null,
			AgeSlab								nvarchar(50) null,
			TrawellTagNumber					numeric(18, 0) null,
			Nominee								nvarchar(50) null,
			Relation							nvarchar(50) null,
			PastIllness							nvarchar(1000) null,
			RestrictedCoverage					bit null,
			BasePremium							numeric(18, 2) null,
			Premium								numeric(18, 2) null,							
			RiderPercent						numeric(18, 2) null,
			RiderPremium						numeric(18, 2) null,
			NewPremium							numeric(18, 2) null,
			OldPremium							numeric(18, 2) null,
			TotalAmount							numeric(18, 2) null,
			ServiceTaxRate						numeric(18, 2) null,
			CESS1Rate							numeric(18, 2) null,
			CESS2Rate							numeric(18, 2) null,
			ServiceTax							numeric(18, 2) null,
			CESS1								numeric(18, 2) null,
			CESS2								numeric(18, 2) null,
			GrossAmount							numeric(18, 2) null,
			DiscountPercent						numeric(18, 2) null,
			DiscountAmount						numeric(18, 2) null,
			DiscountServiceTax					numeric(18, 2) null,
			DiscountCESS1						numeric(18, 2) null,
			DiscountCESS2						numeric(18, 2) null,
			NetServiceTax						numeric(18, 2) null,
			NetCESS1							numeric(18, 2) null,
			NetCESS2							numeric(18, 2) null,
			NetAmount							numeric(18, 2) null,
			OldRiderPremium						numeric(18, 2) null,
			OldTotalAmount						numeric(18, 2) null,
			ActualNewPremium					numeric(18, 2) null,
			ActualOldPremium					numeric(18, 2) null,
			ActualTotalAmount					numeric(18, 2) null,
			ActualServiceTax					numeric(18, 2) null,
			ActualCESS1							numeric(18, 2) null,
			ActualCESS2							numeric(18, 2) null,
			ActualGrossAmount					numeric(18, 2) null,
			ActualDiscountPercent				numeric(18, 2) null,
			ActualDiscountAmount				numeric(18, 2) null,
			ActualDiscountServiceTax			numeric(18, 2) null,
			ActualDiscountCESS1					numeric(18, 2) null,
			ActualDiscountCESS2					numeric(18, 2) null,
			ActualNetServiceTax					numeric(18, 2) null,
			ActualNetCESS1						numeric(18, 2) null,
			ActualNetCESS2						numeric(18, 2) null,
			ActualNetAmount						numeric(18, 2) null,
			Actualoldinsurancecost				numeric(18, 2) null,
			ActualNewinsurancecost				numeric(18, 2) null,
			Actualinsurancecost					numeric(18, 2) null,
			ActualTdsAmount						numeric(18, 2) null,
			ActualComissionAmount				numeric(18, 2) null,
			ActualoldTApremium					numeric(18, 2) null,
			ActualNewTApremium					numeric(18, 2) null,
			ActualTApremim						numeric(18, 2) null,
			Remarks								ntext,
			CreatedDate							date null,
			CreatedDateTime						datetime null,
			YAGOCreatedDate						date null,
			pdfreference						nvarchar(max),
			ManualPremiumTotal					numeric(18, 2) null,
			ManualPremiumBasic					numeric(18, 2) null,
			ManualPremiumServiceTax				numeric(18, 2) null,
			sponsorname							nvarchar(max),
			sponsorrelation						nvarchar(max),
			Rider								nvarchar(max),
			[InsertDate]						datetime null,
			[updateDate]						datetime null,
			[hashkey]							varbinary(50) null
	)

	create clustered index idx_trwPolicy_PolicySummarySK on [db-au-cmdwh].dbo.trwPolicySummary(PolicySummarySK)
	create nonclustered index idx_trwPolicy_policydetailid on [db-au-cmdwh].dbo.trwPolicySummary(policydetailid)
	create nonclustered index idx_trwPolicy_PolicyID on [db-au-cmdwh].dbo.trwPolicySummary(PolicySK)
	create nonclustered index idx_trwPolicy_HashKey on [db-au-cmdwh].dbo.trwPolicySummary(HashKey)

	END

BEGIN TRANSACTION;

BEGIN TRY

	merge into [db-au-cmdwh].dbo.trwPolicySummary as DST
	using [db-au-stage].dbo.trwPolicySummaryTemp as SRC
	on (src.policydetailid = DST.policydetailid)

	when not matched by target then
	insert
	(
	policydetailid,
	PolicySK,
	EmployeeSK,
	AgentEmployeeSK,
	SellingPlanSK,
	InvoiceSK,
	PolicyNumber,
	OrgStatus,
	CurStatus,
	Endorsement,
	ActualPolicyCount,
	EndorsementDate,
	EndorsementDateTime,
	YAGOEndorsementDate,
	DateOfPolicyCancelled,
	DateTimeOfPolicyCancelled,
	YAGODateOfPolicyCancelled,
	DateOfPolicy,
	DateTimeOfPolicy,
	YAGODateOfPolicy,
	PassportNumber,
	DepartureDate,
	Days,
	DaySlab,
	ArrivalDate,
	Name,
	DOB,
	Age,
	AgeSlab,
	TrawellTagNumber,
	Nominee,
	Relation,
	PastIllness,
	RestrictedCoverage,
	BasePremium,
	Premium,
	RiderPercent,
	RiderPremium,
	NewPremium,
	OldPremium,
	TotalAmount,
	ServiceTaxRate,
	CESS1Rate,
	CESS2Rate,
	ServiceTax,
	CESS1,
	CESS2,
	GrossAmount,
	DiscountPercent,
	DiscountAmount,
	DiscountServiceTax,
	DiscountCESS1,
	DiscountCESS2,
	NetServiceTax,
	NetCESS1,
	NetCESS2,
	NetAmount,
	OldRiderPremium,
	OldTotalAmount,
	ActualNewPremium,
	ActualOldPremium,
	ActualTotalAmount,
	ActualServiceTax,
	ActualCESS1,
	ActualCESS2,
	ActualGrossAmount,
	ActualDiscountPercent,
	ActualDiscountAmount,
	ActualDiscountServiceTax,
	ActualDiscountCESS1,
	ActualDiscountCESS2,
	ActualNetServiceTax,
	ActualNetCESS1,
	ActualNetCESS2,
	ActualNetAmount,
	Actualoldinsurancecost,
	ActualNewinsurancecost,
	Actualinsurancecost,
	ActualTdsAmount,
	ActualComissionAmount,
	ActualoldTApremium,
	ActualNewTApremium,
	ActualTApremim,
	Remarks,
	CreatedDate,
	CreatedDateTime,
	YAGOCreatedDate,
	pdfreference,
	ManualPremiumTotal,
	ManualPremiumBasic,
	ManualPremiumServiceTax,
	sponsorname,
	sponsorrelation,
	Rider,
	InsertDate,
	updateDate,
	HashKey
	)
	values
	(
	SRC.policydetailid,
	SRC.PolicySK,
	SRC.EmployeeSK,
	SRC.AgentEmployeeSK,
	SRC.SellingPlanSK,
	SRC.InvoiceSK,
	SRC.PolicyNumber,
	SRC.OrgStatus,
	SRC.CurStatus,
	SRC.Endorsement,
	SRC.ActualPolicyCount,
	SRC.EndorsementDate,
	SRC.EndorsementDateTime,
	SRC.YAGOEndorsementDate,
	SRC.DateOfPolicyCancelled,
	SRC.DateTimeOfPolicyCancelled,
	SRC.YAGODateOfPolicyCancelled,
	SRC.DateOfPolicy,
	SRC.DateTimeOfPolicy,
	SRC.YAGODateOfPolicy,
	SRC.PassportNumber,
	SRC.DepartureDate,
	SRC.Days,
	SRC.DaySlab,
	SRC.ArrivalDate,
	SRC.Name,
	SRC.DOB,
	SRC.Age,
	SRC.AgeSlab,
	SRC.TrawellTagNumber,
	SRC.Nominee,
	SRC.Relation,
	SRC.PastIllness,
	SRC.RestrictedCoverage,
	SRC.BasePremium,
	SRC.Premium,
	SRC.RiderPercent,
	SRC.RiderPremium,
	SRC.NewPremium,
	SRC.OldPremium,
	SRC.TotalAmount,
	SRC.ServiceTaxRate,
	SRC.CESS1Rate,
	SRC.CESS2Rate,
	SRC.ServiceTax,
	SRC.CESS1,
	SRC.CESS2,
	SRC.GrossAmount,
	SRC.DiscountPercent,
	SRC.DiscountAmount,
	SRC.DiscountServiceTax,
	SRC.DiscountCESS1,
	SRC.DiscountCESS2,
	SRC.NetServiceTax,
	SRC.NetCESS1,
	SRC.NetCESS2,
	SRC.NetAmount,
	SRC.OldRiderPremium,
	SRC.OldTotalAmount,
	SRC.ActualNewPremium,
	SRC.ActualOldPremium,
	SRC.ActualTotalAmount,
	SRC.ActualServiceTax,
	SRC.ActualCESS1,
	SRC.ActualCESS2,
	SRC.ActualGrossAmount,
	SRC.ActualDiscountPercent,
	SRC.ActualDiscountAmount,
	SRC.ActualDiscountServiceTax,
	SRC.ActualDiscountCESS1,
	SRC.ActualDiscountCESS2,
	SRC.ActualNetServiceTax,
	SRC.ActualNetCESS1,
	SRC.ActualNetCESS2,
	SRC.ActualNetAmount,
	SRC.Actualoldinsurancecost,
	SRC.ActualNewinsurancecost,
	SRC.Actualinsurancecost,
	SRC.ActualTdsAmount,
	SRC.ActualComissionAmount,
	SRC.ActualoldTApremium,
	SRC.ActualNewTApremium,
	SRC.ActualTApremim,
	SRC.Remarks,
	SRC.CreatedDate,
	SRC.CreatedDateTime,
	SRC.YAGOCreatedDate,
	SRC.pdfreference,
	SRC.ManualPremiumTotal,
	SRC.ManualPremiumBasic,
	SRC.ManualPremiumServiceTax,
	SRC.sponsorname,
	SRC.sponsorrelation,
	SRC.Rider,
	getdate(),
	null,
	SRC.HashKey
	)

	--when matched and DST.HashKey <> SRC.HashKey then
	--update
	--set DST.PolicySK = SRC.PolicySK,
	--	DST.EmployeeSK = SRC.EmployeeSK,
	--	DST.AgentEmployeeSK = SRC.AgentEmployeeSK,
	--	DST.SellingPlanSK = SRC.SellingPlanSK,
	--	DST.InvoiceSK = SRC.InvoiceSK,
	--	DST.PolicyNumber = SRC.PolicyNumber,
	--	DST.CurStatus = SRC.CurStatus,
	--	DST.Endorsement = SRC.Endorsement,
	--	DST.EndorsementDate = SRC.EndorsementDate,
	--	DST.EndorsementDateTime = SRC.EndorsementDateTime,
	--	DST.YAGOEndorsementDate = SRC.YAGOEndorsementDate,
	--	DST.DateOfPolicyCancelled = SRC.DateOfPolicyCancelled,
	--	DST.DateTimeOfPolicyCancelled = SRC.DateTimeOfPolicyCancelled,
	--	DST.YAGODateOfPolicyCancelled = SRC.YAGODateOfPolicyCancelled,
	--	DST.DateOfPolicy = SRC.DateOfPolicy,
	--	DST.DateTimeOfPolicy = SRC.DateTimeOfPolicy,
	--	DST.YAGODateOfPolicy = SRC.YAGODateOfPolicy,
	--	DST.PassportNumber = SRC.PassportNumber,
	--	DST.DepartureDate = SRC.DepartureDate,
	--	DST.Days = SRC.Days,
	--	DST.DaySlab = SRC.DaySlab,
	--	DST.ArrivalDate = SRC.ArrivalDate,
	--	DST.Name = SRC.Name,
	--	DST.DOB = SRC.DOB,
	--	DST.Age = SRC.Age,
	--	DST.AgeSlab = SRC.AgeSlab,
	--	DST.TrawellTagNumber = SRC.TrawellTagNumber,
	--	DST.Nominee = SRC.Nominee,
	--	DST.Relation = SRC.Relation,
	--	DST.PastIllness = SRC.PastIllness,
	--	DST.RestrictedCoverage = SRC.RestrictedCoverage,
	--	DST.BasePremium = SRC.BasePremium,
	--	DST.Premium = SRC.Premium,
	--	DST.RiderPercent = SRC.RiderPercent,
	--	DST.RiderPremium = SRC.RiderPremium,
	--	DST.NewPremium = SRC.NewPremium,
	--	DST.OldPremium = SRC.OldPremium,
	--	DST.TotalAmount = SRC.TotalAmount,
	--	DST.ServiceTaxRate = SRC.ServiceTaxRate,
	--	DST.CESS1Rate = SRC.CESS1Rate,
	--	DST.CESS2Rate = SRC.CESS2Rate,
	--	DST.ServiceTax = SRC.ServiceTax,
	--	DST.CESS1 = SRC.CESS1,
	--	DST.CESS2 = SRC.CESS2,
	--	DST.GrossAmount = SRC.GrossAmount,
	--	DST.DiscountPercent = SRC.DiscountPercent,
	--	DST.DiscountAmount = SRC.DiscountAmount,
	--	DST.DiscountServiceTax = SRC.DiscountServiceTax,
	--	DST.DiscountCESS1 = SRC.DiscountCESS1,
	--	DST.DiscountCESS2 = SRC.DiscountCESS2,
	--	DST.NetServiceTax = SRC.NetServiceTax,
	--	DST.NetCESS1 = SRC.NetCESS1,
	--	DST.NetCESS2 = SRC.NetCESS2,
	--	DST.NetAmount = SRC.NetAmount,
	--	DST.OldRiderPremium = SRC.OldRiderPremium,
	--	DST.OldTotalAmount = SRC.OldTotalAmount,
	--	DST.ActualNewPremium = SRC.ActualNewPremium,
	--	DST.ActualOldPremium = SRC.ActualOldPremium,
	--	DST.ActualTotalAmount = SRC.ActualTotalAmount,
	--	DST.ActualServiceTax = SRC.ActualServiceTax,
	--	DST.ActualCESS1 = SRC.ActualCESS1,
	--	DST.ActualCESS2 = SRC.ActualCESS2,
	--	DST.ActualGrossAmount = SRC.ActualGrossAmount,
	--	DST.ActualDiscountPercent = SRC.ActualDiscountPercent,
	--	DST.ActualDiscountAmount = SRC.ActualDiscountAmount,
	--	DST.ActualDiscountServiceTax = SRC.ActualDiscountServiceTax,
	--	DST.ActualDiscountCESS1 = SRC.ActualDiscountCESS1,
	--	DST.ActualDiscountCESS2 = SRC.ActualDiscountCESS2,
	--	DST.ActualNetServiceTax = SRC.ActualNetServiceTax,
	--	DST.ActualNetCESS1 = SRC.ActualNetCESS1,
	--	DST.ActualNetCESS2 = SRC.ActualNetCESS2,
	--	DST.ActualNetAmount = SRC.ActualNetAmount,
	--	DST.Actualoldinsurancecost = SRC.Actualoldinsurancecost,
	--	DST.ActualNewinsurancecost = SRC.ActualNewinsurancecost,
	--	DST.Actualinsurancecost = SRC.Actualinsurancecost,
	--	DST.ActualTdsAmount = SRC.ActualTdsAmount,
	--	DST.ActualComissionAmount = SRC.ActualComissionAmount,
	--	DST.ActualoldTApremium = SRC.ActualoldTApremium,
	--	DST.ActualNewTApremium = SRC.ActualNewTApremium,
	--	DST.ActualTApremim = SRC.ActualTApremim,
	--	DST.Remarks = SRC.Remarks,
	--	DST.CreatedDate = SRC.CreatedDate,
	--	DST.CreatedDateTime = SRC.CreatedDateTime,
	--	DST.YAGOCreatedDate = SRC.YAGOCreatedDate,
	--	DST.pdfreference = SRC.pdfreference,
	--	DST.ManualPremiumTotal = SRC.ManualPremiumTotal,
	--	DST.ManualPremiumBasic = SRC.ManualPremiumBasic,
	--	DST.ManualPremiumServiceTax = SRC.ManualPremiumServiceTax,
	--	DST.sponsorname = SRC.sponsorname,
	--	DST.sponsorrelation = SRC.sponsorrelation,
	--	DST.Rider = SRC.Rider,
	--	DST.UpdateDate = getdate(),
	--	DST.HashKey = SRC.HashKey

		output $action into @mergeoutput;


		select
			@insertcount =
				isnull(sum(
					case
						when MergeAction = 'insert' then 1
						else 0
					end
				), 0),
			@updatecount =
				isnull(sum(
					case
						when MergeAction = 'update' then 1
						else 0
					end
				), 0)
		from
			@mergeoutput

		update [db-au-cmdwh].dbo.[trwPolicySummary]
			set ActualPolicyCount = case when Endorsement = 0 and OrgStatus in ('Active', 'EarlyArrive', 'Cancelled') then 1
										else 0
										end,
				DateOfPolicyCancelled = case when Endorsement = 0 and OrgStatus in ('Active', 'EarlyArrive', 'Cancelled') then NULL
											else convert(date, CreatedDateTime)
											end,
				DateTimeOfPolicyCancelled = case when Endorsement = 0 and OrgStatus in ('Active', 'EarlyArrive', 'Cancelled') then NULL
											else CreatedDateTime
											end,
				YAGODateOfPolicyCancelled = case when Endorsement = 0 and OrgStatus in ('Active', 'EarlyArrive', 'Cancelled') then NULL
											else dateadd(year, 1, convert(date, CreatedDateTime))
											end
		where ActualPolicyCount <> -1

		--update [db-au-cmdwh].dbo.[trwPolicySummary]
		--	set ActualPolicyCount = -1
		--where OrgStatus = 'Cancelled' and CurStatus = 'cancelled'
		
	--exec sp_generateetllog @EIGUID, @Package_ID, @Package_Name, @user_name, @sourcecount, @Category, '', '', 'Update', 'trwPolicySummary', '',@insertcount, @updatecount
	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicySummary', @user_name, @sourcecount, '', '', '', '', 'Package_Run_Details', 'Success', 'Process Dimension Facts - Policy', 'Update', @insertcount, @updatecount, 3, 1, NULL, NULL, NULL

END TRY

BEGIN CATCH
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
	DECLARE @insert_date	Datetime

	SET @insert_date = getdate()

	SET @ErrorMessage = 'Error Line: ' + convert(varchar, @ErrorLine) + ', Error Message: ' + @ErrorMessage + ', Error Severity: ' + convert(varchar, @ErrorSeverity) + ', Error State: ' + convert(varchar, @ErrorState)

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	exec [db-au-stage].dbo.etlsp_trwgenerateetllog @Package_ID, 'trwPolicySummary', @user_name, 0, @ErrorNumber, @ErrorMessage, 'trwPolicySummary', 'Process_etlsp_trwEmployee_DWH', 'Package_Error_Log', 'Failed', 'Process Dimension Facts - Policy', '', 0, 0, 3, 1, NULL, NULL, NULL

	exec [db-au-stage].dbo.etlsp_trwPackageStatus  'END', 3, 1, 'FAILED'
END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END


GO
