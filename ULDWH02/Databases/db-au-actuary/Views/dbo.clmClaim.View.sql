USE [db-au-actuary]
GO
/****** Object:  View [dbo].[clmClaim]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[clmClaim] AS 
SELECT
     cc.[CountryKey]
    ,cc.[ClaimKey]
    ,cc.[PolicyKey]
    --,cc.[AgencyKey]
    ,cc.[ClaimNo]
    --,cc.[CreatedBy]
    ,cc.[CreateDate]
    --,cc.[OfficerName]
    ,cc.[StatusCode]
    ,cc.[StatusDesc]
    ,cc.[ReceivedDate]
    --,cc.[Authorisation]
    --,cc.[ActionDate]
    --,cc.[ActionCode]
    ,cc.[FinalisedDate]
    --,cc.[ArchiveBox]
    --,cc.[PolicyID]
    ,cc.[PolicyNo]
    ,cc.[PolicyProduct]
    --,cc.[AgencyCode]
    ,cc.[PolicyPlanCode]
    ,cc.[IntDom]
    ,cc.[Excess]
    ,cc.[SingleFamily]
    ,cc.[PolicyIssuedDate]
    ,cc.[AccountingDate]
    ,cc.[DepartureDate]
    ,cc.[ArrivalDate]
    ,cc.[NumberOfDays]
    --,cc.[ITCPremium]
    --,cc.[EMCApprovalNo]
    --,cc.[GroupPolicy]
    ,cc.[LuggageFlag]
    --,cc.[HRisk]
    --,cc.[CaseNo]
    ,cc.[Comment]
    --,cc.[ClaimProduct]
    --,cc.[ClaimPlan]
    --,cc.[RecoveryType]
    --,cc.[RecoveryOutcome]
    ,cc.[OnlineClaim]
    --,cc.[RecoveryTypeDesc]
    --,cc.[RecoveryOutcomeDesc]
    --,cc.[OnlineConsultant]
    --,cc.[OnlineAlpha]
    --,cc.[CultureCode]
    ,cc.[ClaimGroupCode]
    ,cc.[PolicyTransactionKey]
    --,cc.[OutletKey]
    --,cc.[DomainID]
    --,cc.[BIRowID]
    --,cc.[CreateBatchID]
    --,cc.[UpdateBatchID]
    --,cc.[CreateDateTimeUTC]
    --,cc.[ReceivedDateTimeUTC]
    --,cc.[ActionDateTimeUTC]
    --,cc.[FinalisedDateTimeUTC]
    --,cc.[PolicyOffline]
    --,cc.[MasterPolicyNumber]
    --,cc.[GroupName]
    --,cc.[AgencyName]
    ,cc.[FirstNilDate]
    --,cc.[CaseKey]
    --,ce.[CountryKey]
    --,ce.[ClaimKey]
    --,ce.[EventKey]
    --,ce.[EventID]
    --,ce.[ClaimNo]
    --,ce.[EMCID]
    ,ce.[PerilCode]
    ,ce.[PerilDesc]
    --,ce.[EventCountryCode]
    --,ce.[EventCountryName]
    ,ce.[EventDate]
    ,ce.[EventDesc]
    --,ce.[CreateDate]
    --,ce.[CreatedBy]
    --,ce.[CaseID]
    ,ce.[CatastropheCode]
    ,ce.[CatastropheShortDesc]
    ,ce.[CatastropheLongDesc]
    --,ce.[BIRowID]
    --,ce.[CreateBatchID]
    --,ce.[UpdateBatchID]
    --,ce.[EventDateTimeUTC]
    --,ce.[CreateDateTimeUTC]
    ,cs.[MedicalSectionCount]
    ,cs.[CancellationSectionCount]
    ,cs.[AdditionalExpensesSectionCount]
    ,cs.[LuggageSectionCount]
    ,cs.[OtherSectionCount]
    ,cs.[SectionCount]
FROM      [uldwh02].[db-au-cmdwh].[dbo].[clmClaim] cc WITH (NOLOCK)
OUTER APPLY (
    SELECT TOP 1 * 
    FROM [uldwh02].[db-au-cmdwh].[dbo].[clmEvent] ce WITH (NOLOCK)
    WHERE cc.[ClaimKey] = ce.[ClaimKey]
    ORDER BY ce.[CreateDate] DESC
    ) ce
LEFT JOIN (
    SELECT a.[ClaimKey]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Medical'            ,1,0)) AS [MedicalSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Cancellation'       ,1,0)) AS [CancellationSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Additional Expenses',1,0)) AS [AdditionalExpensesSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Luggage'            ,1,0)) AS [LuggageSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Other'              ,1,0)) AS [OtherSectionCount]
          ,COUNT(*)                                                        AS [SectionCount]
    FROM      [uldwh02].[db-au-cmdwh].[dbo].[clmSection]          a WITH (NOLOCK)
    LEFT JOIN [uldwh02].[db-au-cmdwh].[dbo].[vclmBenefitCategory] b WITH (NOLOCK) ON a.[BenefitSectionKey] = b.[BenefitSectionKey]
    GROUP BY [ClaimKey]
    ) cs ON cc.[ClaimKey] = cs.[ClaimKey]
WHERE CAST(ce.[EventDate] as date) >= '2017-01-01'

UNION ALL

SELECT
     cc.[CountryKey]
    ,cc.[ClaimKey]
    ,cc.[PolicyKey]
    --,cc.[AgencyKey]
    ,cc.[ClaimNo]
    --,cc.[CreatedBy]
    ,cc.[CreateDate]
    --,cc.[OfficerName]
    ,cc.[StatusCode]
    ,cc.[StatusDesc]
    ,cc.[ReceivedDate]
    --,cc.[Authorisation]
    --,cc.[ActionDate]
    --,cc.[ActionCode]
    ,cc.[FinalisedDate]
    --,cc.[ArchiveBox]
    --,cc.[PolicyID]
    ,cc.[PolicyNo]
    ,cc.[PolicyProduct]
    --,cc.[AgencyCode]
    ,cc.[PolicyPlanCode]
    ,cc.[IntDom]
    ,cc.[Excess]
    ,cc.[SingleFamily]
    ,cc.[PolicyIssuedDate]
    ,cc.[AccountingDate]
    ,cc.[DepartureDate]
    ,cc.[ArrivalDate]
    ,cc.[NumberOfDays]
    --,cc.[ITCPremium]
    --,cc.[EMCApprovalNo]
    --,cc.[GroupPolicy]
    ,cc.[LuggageFlag]
    --,cc.[HRisk]
    --,cc.[CaseNo]
    ,cc.[Comment]
    --,cc.[ClaimProduct]
    --,cc.[ClaimPlan]
    --,cc.[RecoveryType]
    --,cc.[RecoveryOutcome]
    ,cc.[OnlineClaim]
    --,cc.[RecoveryTypeDesc]
    --,cc.[RecoveryOutcomeDesc]
    --,cc.[OnlineConsultant]
    --,cc.[OnlineAlpha]
    --,cc.[CultureCode]
    ,cc.[ClaimGroupCode]
    ,cc.[PolicyTransactionKey]
    --,cc.[OutletKey]
    --,cc.[DomainID]
    --,cc.[BIRowID]
    --,cc.[CreateBatchID]
    --,cc.[UpdateBatchID]
    --,cc.[CreateDateTimeUTC]
    --,cc.[ReceivedDateTimeUTC]
    --,cc.[ActionDateTimeUTC]
    --,cc.[FinalisedDateTimeUTC]
    --,cc.[PolicyOffline]
    --,cc.[MasterPolicyNumber]
    --,cc.[GroupName]
    --,cc.[AgencyName]
    ,cc.[FirstNilDate]
    --,cc.[CaseKey]
    --,ce.[CountryKey]
    --,ce.[ClaimKey]
    --,ce.[EventKey]
    --,ce.[EventID]
    --,ce.[ClaimNo]
    --,ce.[EMCID]
    ,ce.[PerilCode]
    ,ce.[PerilDesc]
    --,ce.[EventCountryCode]
    --,ce.[EventCountryName]
    ,ce.[EventDate]
    ,ce.[EventDesc]
    --,ce.[CreateDate]
    --,ce.[CreatedBy]
    --,ce.[CaseID]
    ,ce.[CatastropheCode]
    ,ce.[CatastropheShortDesc]
    ,ce.[CatastropheLongDesc]
    --,ce.[BIRowID]
    --,ce.[CreateBatchID]
    --,ce.[UpdateBatchID]
    --,ce.[EventDateTimeUTC]
    --,ce.[CreateDateTimeUTC]
    ,cs.[MedicalSectionCount]
    ,cs.[CancellationSectionCount]
    ,cs.[AdditionalExpensesSectionCount]
    ,cs.[LuggageSectionCount]
    ,cs.[OtherSectionCount]
    ,cs.[SectionCount]
FROM      [azsyddwh02].[db-au-cba].[dbo].[clmClaim] cc WITH (NOLOCK)
OUTER APPLY (
    SELECT TOP 1 * 
    FROM [azsyddwh02].[db-au-cba].[dbo].[clmEvent] ce WITH (NOLOCK)
    WHERE cc.[ClaimKey] = ce.[ClaimKey]
    ORDER BY ce.[CreateDate] DESC
    ) ce
LEFT JOIN (
    SELECT a.[ClaimKey]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Medical'            ,1,0)) AS [MedicalSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Cancellation'       ,1,0)) AS [CancellationSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Additional Expenses',1,0)) AS [AdditionalExpensesSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Luggage'            ,1,0)) AS [LuggageSectionCount]
          ,SUM(IIF(b.[ActuarialBenefitGroup] = 'Other'              ,1,0)) AS [OtherSectionCount]
          ,COUNT(*)                                                        AS [SectionCount]
    FROM      [azsyddwh02].[db-au-cba].[dbo].[clmSection]          a WITH (NOLOCK)
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[vclmBenefitCategory] b WITH (NOLOCK) ON a.[BenefitSectionKey] = b.[BenefitSectionKey]
    GROUP BY [ClaimKey]
    ) cs ON cc.[ClaimKey] = cs.[ClaimKey]
WHERE CAST(ce.[EventDate] as date) >= '2017-01-01'
;
GO
