USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[spClaimDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spClaimDataSet]
    @Domain varchar(15) = 'AU',
    @FXReferenceDate date,
    @FXCode varchar(10) = 'Oanda'

as

begin

/****************************************************************************************************/
--  Name:           spClaimDataSet
--  Author:         Leonardus Li
--  Date Created:   20161120
--  Description:    
--
--  Parameters:     @Domain: AU or NZ, or both (AU,NZ)
--					@FXReferenceDate: valid date (eg yyyy-mm-dd 2017-05-05)
--					@FXCode: Oanda or Zurich
--   
--  Change History: 20161120 - LL - Created
--					20190429 - LT - Added AssessmentOutcome column at ClaimNo, EventID level to data set
--  CHG0039217-- SS ---Change the source of CATCode column and take it from ClmEvent table.                                  
/****************************************************************************************************/

    set nocount on

	--uncomment to debug
/*
    declare
        @Domain varchar(15) = 'AU,NZ',
        @FXReferenceDate date = '2019-04-01',
	    @FXCode varchar(10) = 'Zurich'
*/

    if object_id('tempdb..#claimdataset') is not null
        drop table #claimdataset

    select 
        c.[Domain Country],
        c.Company,
        c.OutletKey,
        c.PolicyKey,
        c.BasePolicyNo,
        dd.IssueDate,
        dm.IssueMonth,
        dq.IssueQuarter,
        c.ClaimKey,
        c.ClaimNo,
        dd.ReceiptDate,
        dm.ReceiptMonth,
        dq.ReceiptQuarter,
        dd.RegisterDate,
        dm.RegisterMonth,
        dq.RegisterQuarter,
        c.EventID,
        dd.LossDate,
        dm.LossMonth,
        dq.LossQuarter,
        c.CATCode,
        c.EventCountryCode,
        c.EventCountryName,
        c.PerilCode,
        c.MedicalAssistanceClaimFlag,
        c.OnlineClaimFlag,
        c.CustomerCareID,
        c.SectionID,
        dd.SectionDate,
        dm.SectionMonth,
        dq.SectionQuarter,
        c.SectionCode,
        c.BenefitSectionKey,
        c.PaymentID,
        c.IncurredTime,
        dd.IncurredDate,
        dm.IncurredMonth,
        dq.IncurredQuarter,

        case
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 7 then '1 week'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 14 then '2 weeks'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 21 then '3 weeks'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 28 then '4 weeks'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 60 then '2 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 90 then '3 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 120 then '4 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 150 then '5 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 180 then '6 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 210 then '7 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 240 then '8 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 270 then '9 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 300 then '10 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 330 then '11 months'
            when datediff(day, dd.SectionDate, dd.IncurredDate) <= 365 then '12 months'
            else '12+ months'
        end IncurredAgeBand,

        datediff(month, dm.ReceiptMonth, dm.IncurredMonth) ReceiptDevelopmentMonth,
        datediff(month, dm.IssueMonth, dm.IncurredMonth) IssueDevelopmentMonth,
        datediff(month, dm.LossMonth, dm.IncurredMonth) LossDevelopmentMonth,

        datediff(quarter, dq.ReceiptQuarter, dq.IncurredQuarter) ReceiptDevelopmentQuarter,
        datediff(quarter, dq.IssueQuarter, dq.IncurredQuarter) IssueDevelopmentQuarter,
        datediff(quarter, dq.LossQuarter, dq.IncurredQuarter) LossDevelopmentQuarter,

        c.StatusAtEndOfDay,
        c.StatusAtEndOfMonth,
        c.EstimateMovement,
        c.PaymentMovement,
        c.RecoveryMovement,
        c.EstimateMovement + c.PaymentMovement + c.RecoveryMovement IncurredMovement,
        c.NetPaymentMovement,
        c.NetRecoveryMovement,
        c.NetPaymentMovement + c.NetRecoveryMovement + c.EstimateMovement NetIncurredMovement,
        c.NetRealRecoveryMovement,
        c.NetApprovedPaymentMovement,


        c.LocalCurrencyCode,
        c.OriginalCurrencyCode,
        c.OriginalFXRate,
        c.ForeignCurrencyCode,
        c.ExposureCurrencyCode,
        c.ForeignCurrencyRate,
        c.USDRate,
        c.ForeignCurrencyRateDate,

		c.AssessmentOutcome					--20190429 - LT - New column

    into #claimdataset
    from
        (
            select
                c.[Domain Country],
                c.Company,
                c.OutletKey,
                c.PolicyKey,
                isnull(c.BasePolicyNumber, c.PolicyNo) BasePolicyNo,
                c.ClaimKey,
                c.ClaimNo,
                isnull(c.EventID, -999) EventID,
                --c.CATCode,
                ca.CATCode,    ----CHG0039217--Change the source of CATCode column and take it from ClmEvent table
                c.EventCountryCode,
                c.EventCountryName,
                c.PerilCode,
                c.MedicalAssistanceClaimFlag,
                c.OnlineClaimFlag,
                c.CustomerCareID,
                isnull(c.SectionID, -999) SectionID,
                c.SectionCode,
                c.BenefitSectionKey,
                isnull(c.PaymentID, -c.SectionID) PaymentID, --estimate movement doesn't have payment id
                c.IssueDate, 
                c.PolicyIssuedDate,
                c.ReceiptDate,
                c.RegisterDate,
                c.LossDate,
                c.SectionDate,
                c.IncurredTime,
                c.StatusAtEndOfDay,
                c.StatusAtEndOfMonth,
                sum(c.EstimateMovement) EstimateMovement,
                sum(c.PaymentMovement) PaymentMovement,
                sum(c.RecoveryMovement) RecoveryMovement,
                sum(c.EstimateMovement + c.PaymentMovement + c.RecoveryMovement) IncurredMovement,
                sum(c.NetPaymentMovement) NetPaymentMovement,
                sum(c.NetRecoveryMovement) NetRecoveryMovement,
                sum(c.NetPaymentMovement + c.NetRecoveryMovement + c.EstimateMovement) NetIncurredMovement,
                sum(c.NetRealRecoveryMovement) NetRealRecoveryMovement,
                sum(c.NetApprovedPaymentMovement) NetApprovedPaymentMovement,
                c.LocalCurrencyCode,
                c.Currency OriginalCurrencyCode,
                c.FXRate OriginalFXRate,
                c.ForeignCurrencyCode,
                ltrim(rtrim(isnull(c.ExposureCurrencyCode, ''))) ExposureCurrencyCode,
                c.ForeignCurrencyRate,
                c.USDRate,
                c.ForeignCurrencyRateDate,
				ca.AssessmentOutcome
            from
                [db-au-actuary].ws.ClaimIncurredMovement c
				outer apply
				(
					select				--20190429 - LT - Get assessment outcome. Assessment Outcome definition is taken from [db-au-cmdwh].dbo.vClaimAssessmentOutcome
						cl.ClaimKey,
						ce.EventID,
                        ce.CATCode,   --CHG0039217----Change the source of CATCode column and take it from ClmEvent table
						case
							when idr.IDRStatus in ('Active', 'Diarised') then 'Under Review'
							when inv.InvestigationStatus in ('Active', 'Diarised') then 'Under Review'
							when idr.IDRStatus = 'Complete' and isnull(idr.IDROutcome, '') <> '' then idr.IDROutcome
							when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%fraud%' then 'Fraud detected'
							when inv.InvestigationStatus = 'Complete' and inv.InvestigationOutcome like '%withdrawn%' then 'Claim withdrawn'
							when e5.AssessmentOutcome = 'Under Excess' and isnull(FPPayments, 0) = 0 then 'Under Excess'
							when isnull(FPPayments, 0) > 0 then 'Approved'
							when e5.AssessmentOutcome = 'Deny' and isnull(cp.FPPayments, 0) = 0 then 'Denied'
							when e5.AssessmentOutcome = 'Approve' and isnull(cp.FPPayments, 0) = 0 and isnull(cp.TPPayments, 0) = 0 then 'Denied'
							when e5.AssessmentOutcome = 'Approve' then 'Approved'
							when e5.AssessmentOutcome = 'No action required' and isnull(cp.FPPayments, 0) + isnull(cp.TPPayments, 0) > 0 then 'Approved'
							when e5.AssessmentOutcome = 'No action required' and isnull(cp.FPPayments, 0) = 0 and isnull(cp.TPPayments, 0) = 0 then 'Denied'
							when e5.CaseStatus = 'Complete' and isnull(cp.FPPayments, 0) + isnull(cp.TPPayments, 0) > 0 then 'Approved'
							when e5.CaseStatus = 'Complete' and isnull(cp.FPPayments, 0) = 0 and isnull(cp.TPPayments, 0) = 0 then 'Denied'
							when e5.CaseStatus in ('Active', 'Diarised') then 'Pending'
							when e5.CaseStatus = 'Rejected' then 'Merged to other claim'
							when cl.CreateDate < '2010-01-01' then 'Pre e5'
							when e5.AssessmentOutcome is null and isnull(cp.FPPayments, 0) = 0 and isnull(cp.TPPayments, 0) = 0 then 'No assessment'
							when e5.AssessmentOutcome is null and isnull(cp.FPPayments, 0) + isnull(cp.TPPayments, 0) > 0 then 'No assessment - Paid'
							when e5.CaseID is null then 'No assessment'
						end AssessmentOutcome
					from
						[db-au-cmdwh].dbo.clmClaim cl with(nolock)
						outer apply
						(
							select top 1 
								ce.EventID,
                                ce.CatastropheCode as CATCode     --CHG0039217----Change the source of CATCode column and take it from ClmEvent table
							from
								[db-au-cmdwh].dbo.clmEvent ce with(nolock)
							where
								ce.ClaimKey = cl.ClaimKey
						) ce
						outer apply
						(
							select top 1 
								w.Work_ID CaseID,
								w.Original_Work_ID,
								w.Reference CaseReference,
								w.StatusName CaseStatus,
								AssessmentOutcome
							from
								[db-au-cmdwh].dbo.e5Work w with(nolock)
								outer apply
								(
									select top 1
										wa.AssessmentOutcomeDescription AssessmentOutcome
									from
										[db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
									where
										wa.Work_ID = w.Work_ID and
										wa.CategoryActivityName = 'Assessment Outcome' and
										wa.CompletionDate is not null
									order by
										wa.CompletionDate desc
								) wa
							where
								w.ClaimKey = cl.ClaimKey and
								w.WorkType = 'Claim'
							order by
								w.CreationDate desc
						) e5
						outer apply
						(
							select top 1
								w.StatusName IDRStatus,
								w.Reference IDRReference,
								w.Work_ID IDRID,
								wa.Name IDROutcome
							from
								[db-au-cmdwh].dbo.e5Work w with(nolock)
								outer apply
								(
									select top 1
										wi.Name
									from
										[db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
										inner join [db-au-cmdwh].dbo.e5WorkActivityProperties wap with(nolock) on
											wap.WorkActivity_ID = wa.ID and
											wap.Property_ID = 'IDROutcome'
										inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
											wi.ID = wap.PropertyValue
									where
										wa.Work_ID = w.Work_ID and
										wa.CategoryActivityName = 'IDR Outcome' and
										wa.CompletionDate is not null
									order by
										wa.CompletionDate desc
								) wa
							where
								w.ClaimKey = cl.ClaimKey and
								WorkType = 'Complaints' and
								GroupType = 'IDR'
							order by
								CreationDate desc
						) idr
						outer apply
						(
							select top 1
								w.StatusName InvestigationStatus,
								w.Reference InvestigationReference,
								w.Work_ID InvestigationID,
								wa.Name InvestigationOutcome
							from
								[db-au-cmdwh].dbo.e5Work w with(nolock)
								outer apply
								(
									select top 1
										wi.Name
									from
										[db-au-cmdwh].dbo.e5WorkActivity wa with(nolock)
										inner join [db-au-cmdwh].dbo.e5WorkActivityProperties wap with(nolock) on
											wap.WorkActivity_ID = wa.ID and
											wap.Property_ID = 'InvestigationOutcome'
										inner join [db-au-cmdwh].dbo.e5WorkItems wi with(nolock) on
											wi.ID = wap.PropertyValue
									where
										wa.Work_ID = w.Work_ID and
										wa.CategoryActivityName = 'Investigation Outcome' and
										wa.CompletionDate is not null
									order by
										wa.CompletionDate desc
								) wa
							where
								w.ClaimKey = cl.ClaimKey and
								WorkType = 'Investigation'
							order by
								CreationDate desc
						) inv
						outer apply
						(
							select 
								sum
								(
									case
										when isnull(cn.isThirdParty, 0) = 0 then cp.PaymentAmount
										else 0
									end 
								) FPPayments,
								sum
								(
									case
										when isnull(cn.isThirdParty, 0) = 1 then cp.PaymentAmount
										else 0
									end 
								) TPPayments
							from
								[db-au-cmdwh].dbo.clmPayment cp with(nolock)
								inner join [db-au-cmdwh].dbo.clmName cn with(nolock) on
									cn.NameKey = cp.PayeeKey
							where
								cp.ClaimKey = cl.ClaimKey and
								cp.PaymentStatus in ('APPR', 'PAID')
						) cp
					where 
						cl.ClaimKey = c.ClaimKey and
						ce.EventID = c.EventID
				) ca
            where
                c.[Domain Country] in (select dm.Item from [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@Domain, ',') dm) and
                c.IncurredTime < dateadd(day, 1, @FXReferenceDate)
            --Alex doesn't want duplicate records in incurred time level (i.e. avoid incurred & fx version on different row)
            group by
                c.[Domain Country],
                c.Company,
                c.OutletKey,
                c.PolicyKey,
                isnull(c.BasePolicyNumber, c.PolicyNo),
                c.ClaimKey,
                c.ClaimNo,
                isnull(c.EventID, -999),
                --c.CATCode,
                ca.CATCode,     --CHG0039217----Change the source of CATCode column and take it from ClmEvent table.
                c.EventCountryCode,
                c.EventCountryName,
                c.PerilCode,
                c.MedicalAssistanceClaimFlag,
                c.OnlineClaimFlag,
                c.CustomerCareID,
                isnull(c.SectionID, -999),
                c.SectionCode,
                c.BenefitSectionKey,
                isnull(c.PaymentID, -c.SectionID), --estimate movement doesn't have payment id
                c.IssueDate, 
                c.PolicyIssuedDate,
                c.ReceiptDate,
                c.RegisterDate,
                c.LossDate,
                c.SectionDate,
                c.IncurredTime,
                c.StatusAtEndOfDay,
                c.StatusAtEndOfMonth,
                c.LocalCurrencyCode,
                c.Currency,
                c.FXRate,
                c.ForeignCurrencyCode,
                ltrim(rtrim(isnull(c.ExposureCurrencyCode, ''))),
                c.ForeignCurrencyRate,
                c.USDRate,
                c.ForeignCurrencyRateDate,
				ca.AssessmentOutcome
        ) c
        outer apply
        (
            select
                convert(date, isnull(c.IssueDate, c.PolicyIssuedDate)) IssueDate,
                convert(date, c.ReceiptDate) ReceiptDate,
                convert(date, c.RegisterDate) RegisterDate,
                convert(date, c.LossDate) LossDate,
                convert(date, c.SectionDate) SectionDate,
                convert(date, c.IncurredTime) IncurredDate
        ) dd
        outer apply
        (
            select
                case
                    when dd.IssueDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.IssueDate), dd.IssueDate)
                end IssueMonth,
                case
                    when dd.ReceiptDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.ReceiptDate), dd.ReceiptDate)
                end ReceiptMonth,
                case
                    when dd.RegisterDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.RegisterDate), dd.RegisterDate)
                end RegisterMonth,
                case
                    when dd.LossDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.LossDate), dd.LossDate)
                end LossMonth,
                case
                    when dd.SectionDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.SectionDate), dd.SectionDate)
                end SectionMonth,
                case
                    when dd.IncurredDate = '9999-12-31' then '9999-12-01'
                    else dateadd(day, 1 - datepart(day, dd.IncurredDate), dd.IncurredDate)
                end IncurredMonth
        ) dm
        outer apply
        (
            select
                case
                    when dd.IssueDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.IssueDate) + 1, 0))
                end IssueQuarter,
                case
                    when dd.ReceiptDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.ReceiptDate) + 1, 0))
                end ReceiptQuarter,
                case
                    when dd.RegisterDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.RegisterDate) + 1, 0))
                end RegisterQuarter,
                case
                    when dd.LossDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.LossDate) + 1, 0))
                end LossQuarter,
                case
                    when dd.SectionDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.SectionDate) + 1, 0))
                end SectionQuarter,
                case
                    when dd.IncurredDate = '9999-12-31' then '9999-10-01'
                    else dateadd(day, -1, dateadd(qq, datediff(qq, 0, dd.IncurredDate) + 1, 0))
                end IncurredQuarter
        ) dq


    alter table #claimdataset add BIRowID bigint identity(1,1)
    create index idx on #claimdataset (ClaimKey,SectionID,IncurredMonth) include (IncurredMovement,NetIncurredMovement)
    create index idx2 on #claimdataset (ClaimKey,SectionID,PaymentID,IncurredTime) include 
        (
			BIRowID,
            EstimateMovement,
            PaymentMovement,
            RecoveryMovement,
            IncurredMovement,
            NetPaymentMovement,
            NetRecoveryMovement,
            NetIncurredMovement,
            NetRealRecoveryMovement,
            NetApprovedPaymentMovement
        )

    if object_id('tempdb..#asat') is not null
        drop table #asat

    select
		BIRowID,
        EstimateAsAt,
        PaymentAsAt,
        RecoveryAsAt,
        IncurredAsAt,
        NetPaymentAsAt,
        NetRecoveryAsAt,
        NetIncurredAsAt,
        NetRealRecoveryAsAt,
        NetApprovedPaymentAsAt
    into #asat
    from
        #claimdataset t
        cross apply
        (
            select 
                sum(EstimateMovement) EstimateAsAt,
                sum(PaymentMovement) PaymentAsAt,
                sum(RecoveryMovement) RecoveryAsAt,
                sum(IncurredMovement) IncurredAsAt,
                sum(NetPaymentMovement) NetPaymentAsAt,
                sum(NetRecoveryMovement) NetRecoveryAsAt,
                sum(NetIncurredMovement) NetIncurredAsAt,
                sum(NetRealRecoveryMovement) NetRealRecoveryAsAt,
                sum(NetApprovedPaymentMovement) NetApprovedPaymentAsAt
            from
                #claimdataset r
            where
                r.ClaimKey = t.ClaimKey and
                r.SectionID = t.SectionID and
                r.PaymentID = t.PaymentID and
                r.IncurredTime <= t.IncurredTime
        ) r


    create index idx on #asat (BIRowID) include (EstimateAsAt,PaymentAsAt,RecoveryAsAt,IncurredAsAt,NetPaymentAsAt,NetRecoveryAsAt,NetIncurredAsAt,NetRealRecoveryAsAt,NetApprovedPaymentAsAt)

    if object_id('tempdb..#atreference') is not null
        drop table #atreference

    select
        ClaimKey,
        SectionID,
        sum(IncurredMovement) IncurredAtReference,
        sum(NetIncurredMovement) NetIncurredAtReference
    into #atreference
    from
        #claimdataset r
    group by
        ClaimKey,
        SectionID

    create index idx on #atreference (ClaimKey,SectionID) include (IncurredAtReference,NetIncurredAtReference)

    if object_id('tempdb..#inm') is not null
        drop table #inm

    select
        ClaimKey,
        SectionID,
        IncurredMonth,
        sum(IncurredMovement) IncurredInMonth,
        sum(NetIncurredMovement) NetIncurredInMonth
    into #inm
    from
        #claimdataset r
    group by
        ClaimKey,
        SectionID,
        IncurredMonth

    create index idx on #inm (ClaimKey,SectionID,IncurredMonth) include (IncurredInMonth,NetIncurredInMonth)

    if object_id('tempdb..#ateom') is not null
        drop table #ateom

    select
        ClaimKey,
        SectionID,
        IncurredMonth,
        IncurredAtEOM,
        NetIncurredAtEOM
    into #ateom
    from
        #inm t
        cross apply
        (
            select 
                sum(IncurredInMonth) IncurredAtEOM,
                sum(NetIncurredInMonth) NetIncurredAtEOM
            from
                #inm r
            where
                r.ClaimKey = t.ClaimKey and
                r.SectionID = t.SectionID and
                r.IncurredMonth <= t.IncurredMonth
        ) r

    create index idx on #ateom (ClaimKey,SectionID,IncurredMonth) include (IncurredAtEOM,NetIncurredAtEOM)

    if object_id('tempdb..#fx') is not null
        drop table #fx

    select distinct
        LocalCurrencyCode,
        ExposureCurrencyCode,
        cast(null as date) FXReferenceDate,
        cast(null as decimal(25,10)) FXReferenceRate,
        cast(null as decimal(25,10)) USDRateReference
    into #fx
    from
        #claimdataset c

    update c
    set
        FXReferenceDate = fx.FXDate,
        FXReferenceRate = fx.FXRate,
        USDRateReference = fusd.FXRate
    from
        #fx c
        outer apply dbo.fn_GetFXRate_Actuary(c.LocalCurrencyCode, c.ExposureCurrencyCode, @FXReferenceDate, @FXCode) fx
        outer apply dbo.fn_GetFXRate_Actuary(c.LocalCurrencyCode, 'USD', @FXReferenceDate, @FXCode) fusd

    create index idx on #fx (LocalCurrencyCode,ExposureCurrencyCode) include (FXReferenceDate,FXReferenceRate,USDRateReference)

    if object_id('tempdb..#cc') is not null
        drop table #cc

    select 
        BIRowID,
        case
            when row_number() over (partition by ClaimKey, SectionID order by IncurredTime) = 1 then 1
            else 0
        end SectionCount
    into #cc
    from
        #claimdataset

    create index idx on #cc (BIRowID) include (SectionCount) 


    if object_id('tempdb..#cds') is not null
        drop table #cds

    select --top 1000
        c.*,

        cc.SectionCount,

        atr.IncurredAtReference,
        atr.NetIncurredAtReference,
        aeom.IncurredAtEOM,
        aeom.NetIncurredAtEOM,
        aeomx.MaxIncurredEOM,
        aeomx.MaxNetIncurredEOM,
        fx.FXReferenceDate,
        fx.FXReferenceRate,
        fx.USDRateReference,
        fxc.FXConversion,
        fxc.UsedFXCode, --TODO: null any fx movement for anything before 1998 (no FX Rate avaialble)
        fxc.UsedFXRateThen,
        fxc.UsedFXRateNow,

        asat.EstimateAsAt,
        asat.PaymentAsAt,
        asat.RecoveryAsAt,
        asat.IncurredAsAt,
        asat.NetPaymentAsAt,
        asat.NetRecoveryAsAt,
        asat.NetIncurredAsAt,
        asat.NetRealRecoveryAsAt,
        asat.NetApprovedPaymentAsAt,

        asat.EstimateAsAt / fxc.FXConversion EstimateAsAt_FX,
        asat.PaymentAsAt / fxc.FXConversion PaymentAsAt_FX,
        asat.RecoveryAsAt / fxc.FXConversion RecoveryAsAt_FX,
        asat.IncurredAsAt / fxc.FXConversion IncurredAsAt_FX,
        asat.NetPaymentAsAt / fxc.FXConversion NetPaymentAsAt_FX,
        asat.NetRecoveryAsAt / fxc.FXConversion NetRecoveryAsAt_FX,
        asat.NetIncurredAsAt / fxc.FXConversion NetIncurredAsAt_FX,
        asat.NetRealRecoveryAsAt / fxc.FXConversion NetRealRecoveryAsAt_FX,
        asat.NetApprovedPaymentAsAt / fxc.FXConversion NetApprovedPaymentAsAt_FX
        
    into #cds
    from
        #claimdataset c
        outer apply
        (
            select 
                max(IncurredAtReference) IncurredAtReference,
                max(NetIncurredAtReference) NetIncurredAtReference
            from
                #atreference atr 
            where
                atr.ClaimKey = c.ClaimKey and
                atr.SectionID = c.SectionID
        ) atr
        outer apply
        (
            select 
                IncurredAtEOM,
                NetIncurredAtEOM
            from
                #ateom r
            where
                r.ClaimKey = c.ClaimKey and
                r.SectionID = c.SectionID and
                r.IncurredMonth = c.IncurredMonth
        ) aeom
        outer apply
        (
            select 
                max(IncurredAtEOM) MaxIncurredEOM,
                max(NetIncurredAtEOM) MaxNetIncurredEOM
            from
                #ateom r
            where
                r.ClaimKey = c.ClaimKey and
                r.SectionID = c.SectionID
        ) aeomx
        outer apply
        (
            select top 1
                FXReferenceDate,
                FXReferenceRate,
                USDRateReference
            from
                #fx r
            where
                r.LocalCurrencyCode = c.LocalCurrencyCode and
                r.ExposureCurrencyCode = c.ExposureCurrencyCode
        ) fx
        outer apply
        (
            select
                case
                    when 
                        isnull(c.ForeignCurrencyRate, 0) = 0 or
                        isnull(c.ExposureCurrencyCode, '') = '' 
                    then
                        case
                            when isnull(c.USDRate, 0) = 0 then 1
                            else fx.USDRateReference / c.USDRate
                        end
                    when isnull(c.ExposureCurrencyCode, '') = '' then 1
                    when 
                        fx.FXReferenceRate is null or
                        fx.FXReferenceRate = 0 or
                        (c.ForeignCurrencyRate / fx.FXReferenceRate) > 100 or --same currency, rebase value, e.g. TRY (Italian Lira)
                        --(fx.FXReferenceRate - isnull(c.ForeignCurrencyRate, 0)) / isnull(c.ForeignCurrencyRate, 0) > 0.5 --https://en.wikipedia.org/wiki/Hyperinflation, Definition
                        --20170529, Alex's email, redefine hyperinflation
                        (
                            datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) >= 2 and
                            (fx.FXReferenceRate / c.ForeignCurrencyRate) >= datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) 
                        )                     
                    then 
                        case
                            when isnull(c.USDRate, 0) = 0 then 1
                            else fx.USDRateReference / c.USDRate
                        end
                    else fx.FXReferenceRate / c.ForeignCurrencyRate
                end FXConversion,
                case
                    when 
                        isnull(c.ForeignCurrencyRate, 0) = 0 or
                        isnull(c.ExposureCurrencyCode, '') = '' 
                    then
                        case
                            when isnull(c.USDRate, 0) = 0 then c.ExposureCurrencyCode
                            else 'USD'
                        end
                    when 
                        fx.FXReferenceRate is null or
                        fx.FXReferenceRate = 0 or
                        (c.ForeignCurrencyRate / fx.FXReferenceRate) > 100 or --same currency, rebase value, e.g. TRY (Italian Lira)
                       --(fx.FXReferenceRate - isnull(c.ForeignCurrencyRate, 0)) / isnull(c.ForeignCurrencyRate, 0) > 0.5 --https://en.wikipedia.org/wiki/Hyperinflation, Definition
                        --20170529, Alex's email, redefine hyperinflation
                        (
                            datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) >= 2 and
                            (fx.FXReferenceRate / c.ForeignCurrencyRate) >= datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) 
                        )
                    then 
                        case
                            when isnull(c.USDRate, 0) = 0 then c.ExposureCurrencyCode
                            else 'USD'
                        end
                    else c.ExposureCurrencyCode
                end UsedFXCode,
                case
                    when 
                        isnull(c.ForeignCurrencyRate, 0) = 0 or
                        isnull(c.ExposureCurrencyCode, '') = '' 
                    then
                        case
                            when isnull(c.USDRate, 0) = 0 then fx.FXReferenceRate
                            else c.USDRate
                        end
                    when isnull(c.ExposureCurrencyCode, '') = '' then 1
                    when 
                        fx.FXReferenceRate is null or
                        fx.FXReferenceRate = 0 or
                        (c.ForeignCurrencyRate / fx.FXReferenceRate) > 100 or --same currency, rebase value, e.g. TRY (Italian Lira)
                        --(fx.FXReferenceRate - isnull(c.ForeignCurrencyRate, 0)) / isnull(c.ForeignCurrencyRate, 0) > 0.5 --https://en.wikipedia.org/wiki/Hyperinflation, Definition
                        --20170529, Alex's email, redefine hyperinflation
                        (
                            datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) >= 2 and
                            (fx.FXReferenceRate / c.ForeignCurrencyRate) >= datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) 
                        )
                    then 
                        case
                            when isnull(c.USDRate, 0) = 0 then fx.FXReferenceRate
                            else c.USDRate
                        end
                    else c.ForeignCurrencyRate
                end UsedFXRateThen,
                case
                    when 
                        isnull(c.ForeignCurrencyRate, 0) = 0 or
                        isnull(c.ExposureCurrencyCode, '') = '' 
                    then
                        case
                            when isnull(c.USDRate, 0) = 0 then fx.FXReferenceRate
                            else fx.USDRateReference
                        end
                    when isnull(c.ExposureCurrencyCode, '') = '' then 1
                    when 
                        fx.FXReferenceRate is null or
                        fx.FXReferenceRate = 0 or
                        (c.ForeignCurrencyRate / fx.FXReferenceRate) > 100 or --same currency, rebase value, e.g. TRY (Italian Lira)
                        --(fx.FXReferenceRate - isnull(c.ForeignCurrencyRate, 0)) / isnull(c.ForeignCurrencyRate, 0) > 0.5 --https://en.wikipedia.org/wiki/Hyperinflation, Definition
                        --20170529, Alex's email, redefine hyperinflation
                        (
                            datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) >= 2 and
                            (fx.FXReferenceRate / c.ForeignCurrencyRate) >= datediff(year, c.ForeignCurrencyRateDate, fx.FXReferenceDate) 
                        )
                    then 
                        case
                            when isnull(c.USDRate, 0) = 0 then fx.FXReferenceRate
                            else fx.USDRateReference
                        end
                    else fx.FXReferenceRate
                end UsedFXRateNow

        ) fxc
        outer apply
        (
            select
                r.SectionCount
            from
                #cc r
            where
                r.BIRowID = c.BIRowID
        ) cc
        cross apply
        (
            select top 1
                EstimateAsAt,
                PaymentAsAt,
                RecoveryAsAt,
                IncurredAsAt,
                NetPaymentAsAt,
                NetRecoveryAsAt,
                NetIncurredAsAt,
                NetRealRecoveryAsAt,
                NetApprovedPaymentAsAt
            from
                #asat asat
            where
                asat.BIRowID = c.BIRowID
        ) asat


    create index idx on #cds (ClaimKey,SectionID,PaymentID,IncurredTime desc,BIRowID desc) include 
    (
        EstimateAsAt_FX,
        PaymentAsAt_FX,
        RecoveryAsAt_FX,
        IncurredAsAt_FX,
        NetPaymentAsAt_FX,
        NetRecoveryAsAt_FX,
        NetIncurredAsAt_FX,
        NetRealRecoveryAsAt_FX,
        NetApprovedPaymentAsAt_FX
    )

    if object_id('[db-au-actuary].dataout.ClaimDataSet') is not null
        drop table [db-au-actuary].dataout.ClaimDataSet

    select --top 1000 
        t.*,
        t.EstimateAsAt_FX - isnull(r.EstimateAsAt_FX, 0) EstimateMovement_FX,
        t.PaymentAsAt_FX - isnull(r.PaymentAsAt_FX, 0) PaymentMovement_FX,
        t.RecoveryAsAt_FX - isnull(r.RecoveryAsAt_FX, 0) RecoveryMovement_FX,
        t.IncurredAsAt_FX - isnull(r.IncurredAsAt_FX, 0) IncurredMovement_FX,
        t.NetPaymentAsAt_FX - isnull(r.NetPaymentAsAt_FX, 0) NetPaymentMovement_FX,
        t.NetRecoveryAsAt_FX - isnull(r.NetRecoveryAsAt_FX, 0) NetRecoveryMovement_FX,
        t.NetIncurredAsAt_FX - isnull(r.NetIncurredAsAt_FX, 0) NetIncurredMovement_FX,
        t.NetRealRecoveryAsAt_FX - isnull(r.NetRealRecoveryAsAt_FX, 0) NetRealRecoveryMovment_FX,
        t.NetApprovedPaymentAsAt_FX - isnull(r.NetApprovedPaymentAsAt_FX, 0) NetApprovedPaymentMovement_FX
    
    into [db-au-actuary].dataout.ClaimDataSet

    from
        #cds t
        outer apply
        (
            select top 1 
                EstimateAsAt_FX,
                PaymentAsAt_FX,
                RecoveryAsAt_FX,
                IncurredAsAt_FX,
                NetPaymentAsAt_FX,
                NetRecoveryAsAt_FX,
                NetIncurredAsAt_FX,
                NetRealRecoveryAsAt_FX,
                NetApprovedPaymentAsAt_FX
            from
                #cds r
            where
                r.ClaimKey = t.ClaimKey and
                r.SectionID = t.SectionID and
                r.PaymentID = t.PaymentID and
                --handle duplicates
                r.IncurredTime <= t.IncurredTime and
                (
                    r.IncurredTime < t.IncurredTime or
                    r.BIRowID < t.BIRowID
                )
            order by
                ClaimKey,
                SectionID,
                IncurredTime desc,
                BIRowID desc
        ) r

    if object_id('[db-au-actuary].dataout.out_ClaimDataSet') is not null
        drop table [db-au-actuary].dataout.out_ClaimDataSet

    select --top 100 
        t.*,
        cb.BenefitCategory,
        cb.ActuarialBenefitGroup,
        cf.EventDescription,
        cf.MentalHealthFlag ClaimMentalHealthFlag,
        cf.LuggageFlag ClaimLuggageFlag,
        cf.ElectronicsFlag ClaimElectronicsFlag,
        cf.CruiseFlag ClaimCruiseFlag,
        cf.MopedFlag ClaimMopedFlag,
        cf.RentalCarFlag ClaimRentalCarFlag,
        cf.WinterSportFlag ClaimWinterSportFlag,
        cf.CrimeVictimFlag ClaimCrimeVictimFlag,
        cf.FoodPoisoningFlag ClaimFoodPoisoningFlag,
        cf.AnimalFlag ClaimAnimalFlag,
        dp.*,
        dc.*,

        do.Distributor,
        o.AlphaCode,
        o.GroupName,
        case
            when isnull(do.Channel, '') = '' then o.Channel
            else do.Channel
        end Channel,
        case
            when isnull(do.JVCode, '') = '' then o.JVCode
            else do.JVCode
        end JVCode,
        case
            when isnull(do.JV, '') = '' then o.JV
            else do.JV
        end JV,

        isnull(p.AreaName, '') AreaName,
        isnull(p.AreaType, '') AreaType,
        isnull(p.PrimaryCountry, '') Destination,
        p.ProductCode,
        p.DepartureDate,
        p.ReturnDate,



        1 NumberOfRecords,
        NetPaymentMovement + NetRecoveryMovement NetPaymentMovementIncRecoveries,
        NetPaymentMovement + NetRecoveryMovement + EstimateMovement NetIncurredMovementIncRecoveries,
        0 IncurredACS,
        case 
            when IncurredAtEOM < 1001 then '$0 - $1,000'
            when IncurredAtEOM < 5001 then '$1,001 - $5,000'
            when IncurredAtEOM < 10001 then '$5,001 - $10,000'
            when IncurredAtEOM < 25001 then '$10,001 - $25,000'
            when IncurredAtEOM < 35001 then '$25,001 - $35,000'
            when IncurredAtEOM < 50001 then '$35,001 - $50,000'
            when IncurredAtEOM < 75001 then '$50,001 - $75,000'
            when IncurredAtEOM < 100001 then '$75,001 - $100,000'
            else  '$100,001+'
        end SizeAsAt,
        case when MaxIncurredEOM > 500 then 'Large' else 'Underlying' end Size500,
        case when MaxIncurredEOM > 1000 then 'Large' else 'Underlying' end Size1k,
        case when MaxIncurredEOM > 5000 then 'Large' else 'Underlying' end Size5k,
        case when MaxIncurredEOM > 10000 then 'Large' else 'Underlying' end Size10k,
        case when MaxIncurredEOM > 25000 then 'Large' else 'Underlying' end Size25k,
        case when MaxIncurredEOM > 35000 then 'Large' else 'Underlying' end Size35k,
        case when MaxIncurredEOM > 50000 then 'Large' else 'Underlying' end Size50k,
        case when MaxIncurredEOM > 75000 then 'Large' else 'Underlying' end Size75k,
        case when MaxIncurredEOM > 100000 then 'Large' else 'Underlying' end Size100k,

        [db-au-cmdwh].dbo.fn_GetUnderWriterCode
        (
            t.Company,
            t.[Domain Country], 
            o.AlphaCode, 
            t.IssueDate
        ) Underwriter

    into [db-au-actuary].dataout.out_ClaimDataSet
    from
        [db-au-actuary].dataout.ClaimDataSet t with(nolock)
        outer apply
        (
            select top 1
                cb.ActuarialBenefitGroup,
                cb.BenefitCategory
            from
                [db-au-cmdwh]..vclmBenefitCategory cb with(nolock)
            where
                cb.BenefitSectionKey = t.BenefitSectionKey
        ) cb
        outer apply
        (
            select top 1
                cf.EventDescription,
                cf.MentalHealthFlag,
                cf.LuggageFlag,
                cf.ElectronicsFlag,
                cf.CruiseFlag,
                cf.MopedFlag,
                cf.RentalCarFlag,
                cf.WinterSportFlag,
                cf.CrimeVictimFlag,
                cf.FoodPoisoningFlag,
                cf.AnimalFlag
            from
                [db-au-cmdwh]..clmclaimFlags cf with(nolock)
            where
                cf.ClaimKey = t.ClaimKey
        ) cf
        outer apply
        (
            select top 1
                p.[Product Code] ProductCode,
                p.[Departure Date] DepartureDate,
                p.[Return Date] ReturnDate,
                p.[Area Name] AreaName,
                p.[Plan Type] AreaType,
                p.Destination PrimaryCountry
            from
                [db-au-actuary].ws.DWHDataSetSummary p with(nolock) 
            where
                p.PolicyKey = t.PolicyKey
        ) p
        outer apply
        (
            select top 1
                PurchasePathGroup,
                LeadTime,
                LeadTimeBand,
                LeadTimeGroup,
                CancellationCover,
                CancellationCoverBand,
                EMCFlag,
                MaxEMCScore,
                TotalEMCScore,
                CancellationFlag,
                CruiseFlag,
                ElectronicsFlag,
                LuggageFlag,
                MotorcycleFlag,
                RentalCarFlag,
                WinterSportFlag
            from
                [db-au-star]..vdimPolicy dp with(nolock)
            where
                dp.PolicyKey = t.PolicyKey
        ) dp
        outer apply
        (
            select top 1
                o.AlphaCode,
                o.GroupName,
                o.Channel,
                o.JVCode,
                o.JV
            from
                [db-au-cmdwh]..penOutlet o with(nolock)
            where
                o.OutletStatus = 'Current' and
                o.OutletKey = t.OutletKey
        ) o
        outer apply
        (
            select top 1
                do.Distributor,
                do.Channel,
                do.JV JVCode,
                do.JVDesc JV
            from
                [db-au-star]..dimOutlet do with(nolock)
            where
                do.OutletKey = t.OutletKey and
                do.isLatest = 'Y'
        ) do
        outer apply
        (
            select top 1
                dd.SubContinent EventSubContinent,
                dd.Continent EventContinent
            from
                [db-au-star]..dimDestination dd with(nolock)
            where
                dd.Destination = t.EventCountryName
        ) dc

    declare @sql varchar(max)

    set @sql =
    '
    if object_id(''[db-au-actuary].dataout.out_ClaimDataSet_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '_' + @FXCode + ''') is not null
        drop table [db-au-actuary].dataout.out_ClaimDataSet_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '_' + @FXCode

    exec(@sql)

    set @sql =
    '
    select *
    into [db-au-actuary].dataout.out_ClaimDataSet_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '_' + @FXCode + '
    from
        [db-au-actuary].dataout.out_ClaimDataSet
    '

    exec(@sql)

end


GO
