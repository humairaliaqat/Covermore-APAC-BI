USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entPrimaryScore]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_entPrimaryScore]
as
begin

    update ec
    set
        PrimaryScore = 
            case
                when SanctionScore >= 30 then 2000
                else 0
            end +
            isnull(bl.Score, 0) + isnull(fl.FlagScore, 0)
    from
        [db-au-cmdwh]..entCustomer ec
        outer apply
        (
            select top 1 
                9001 Score
            from
                [db-au-cmdwh]..entBlacklist bl
            where
                bl.CustomerID = ec.CustomerID
        ) bl
        outer apply
        (
            select
                InvestigationFraudCount * 2000 +
                InvestigationWithdrawnCount * 750 +
                InvestigationDeniedCount * 500 +
                InvestigationNoResponseCount * 200 +
                MedicalCount * 400 +
                LocationCount * 300 +
                SectionCount * 300 +
                HighValueCount * 500 +
                MultipleElecCount * 300 +
                ElectronicCount * 200 +
                NoProofCount * 200 +
                NoReportCount * 200 +
                CrimeCount * 200
                FlagScore
            from
                (
                    select 
                        sum(convert(int, MedicalCostFlag)) MedicalCount,
                        sum(convert(int, LocationRedFlag)) LocationCount,
                        sum(convert(int, SectionRedFlag)) SectionCount,
                        sum(convert(int, HighValueLuggageRedFlag)) HighValueCount,
                        sum(convert(int, MultipleElectronicRedFlag)) MultipleElecCount,
                        sum(convert(int, OnlyElectronicRedFlag)) ElectronicCount,
                        sum(convert(int, NoProofRedFlag)) NoProofCount,
                        sum(convert(int, NoReportRedFlag)) NoReportCount,
                        sum(convert(int, CrimeVictimRedFlag)) CrimeCount,
                        sum(InvestigationWithdrawnCount) InvestigationWithdrawnCount,
                        sum(InvestigationDeniedCount) InvestigationDeniedCount,
                        sum(InvestigationFraudCount) InvestigationFraudCount,
                        sum(InvestigationNoResponseCount) InvestigationNoResponseCount
                    from
                        [db-au-cmdwh]..vEnterpriseClaimList t
                    where
                        t.CustomerID = ec.CustomerID
                ) t
        ) fl
    where
        ec.UpdateBatchID in
        (
            select 
                Batch_ID
            from
                [db-au-log]..Batch_Run_Status
            where
                Subject_Area = 'EnterpriseMDM ODS' and
                Batch_Start_Time >= dateadd(day, -1, convert(date, getdate())) and
                Batch_Start_Time >= '2017-01-19'
        ) or
        ec.CustomerID in
        (
            select 
                ep.CustomerID
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.ClaimKey = cl.ClaimKey
            where
                cl.CreateDate >= dateadd(day, -7, convert(date, getdate()))

            union 

            select 
                ep.CustomerID
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                    pt.PolicyTransactionKey = cl.PolicyTransactionKey
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.PolicyKey = pt.PolicyKey
            where
                cl.CreateDate >= dateadd(day, -4, convert(date, getdate()))

            union 

            select 
                ep.CustomerID
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..clmClaimIncurredMovement cim with(nolock) on
                    cim.ClaimKey = cl.ClaimKey
                inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                    pt.PolicyTransactionKey = cl.PolicyTransactionKey
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.PolicyKey = pt.PolicyKey
            where
                cim.IncurredDate >= dateadd(day, -3, convert(date, getdate()))
        )




end








GO
