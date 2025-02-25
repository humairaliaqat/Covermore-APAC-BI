USE [db-au-actuary]
GO
/****** Object:  View [cng].[vEmcApplications]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vEmcApplications] AS
WITH 
[Conditions] AS (
    SELECT
         [ApplicationKey]
        ,STUFF((SELECT ', ' + [Condition]
                FROM [db-au-cmdwh].[dbo].[emcMedical] b WITH(NOLOCK)
                WHERE a.[ApplicationKey] = b.[ApplicationKey]
                ORDER BY [Condition]
                FOR XML PATH('')
                ),1,1,'') AS [Conditions]
    FROM [db-au-cmdwh].[dbo].[emcMedical] a WITH(NOLOCK)
    GROUP BY [ApplicationKey]
),

[emcApplications] AS (
    SELECT
         a.[CountryKey]
        ,a.[ApplicationKey]
        ,a.[CompanyKey]
        ,a.[AgencyKey]
        ,a.[OutletAlphaKey]
        ,a.[AssessorKey]
        ,a.[CreatorKey]
        ,a.[ApplicationID]
        ,a.[RecordID]
        ,a.[ApplicationType]
        ,a.[AgencyCode]
        ,a.[AssessorID]
        ,a.[Assessor]
        ,a.[CreatorID]
        ,a.[Creator]
        ,a.[Priority]
        ,a.[CreateDate]
        ,a.[ReceiveDate]
        ,a.[AssessedDate]
        ,a.[IsEndorsementSigned]
        ,a.[EndorsementDate]
        ,a.[ApplicationStatus]
        ,a.[ApprovalStatus]
        ,a.[AgeApprovalStatus]
        ,a.[MedicalRisk]
        ,a.[AreaName]
        ,a.[AreaCode]
        ,a.[ScreeningVersion]
        ,a.[PlanCode]
        --,a.[ProductCode]
        ,a.[ProductType]
        ,a.[DepartureDate]
        ,a.[ReturnDate]
        ,a.[TripDuration]
        ,a.[Destination]
        ,a.[TravellerCount]
        ,a.[ValuePerTraveller]
        ,a.[TripType]
        ,a.[PolicyNo]
        ,a.[OtherInsurer]
        ,a.[InputType]
        ,a.[FileLocation]
        ,a.[FileLocationDate]
        ,a.[ClaimNo]
        ,a.[ClaimDate]
        ,a.[IsClaimRelatedToEMC]
        ,a.[IsDeclarationSigned]
        ,a.[IsAnnualBusinessPlan]
        ,a.[IsApplyingForEMCCover]
        ,a.[IsApplyingForCMCover]
        ,a.[IsSendOutcomeByEmail]
        ,a.[HasAgeDestinationDuration]
        ,a.[IsDutyOfDisclosure]
        ,a.[IsCruise]
        ,a.[IsAnnualMultiTrip]
        ,a.[IsWinterSport]
        ,a.[IsOnlineAssessment]
        ,a.[OnlineAssessment]
        ,a.[EMCPremium]
        ,a.[AgePremium]
        ,a.[Excess]
        ,a.[GeneralLimit]
        ,a.[PaymentDuration]
        ,a.[RestrictedConditions]
        ,a.[OtherRestrictions]
        ,a.[PaymentComments]
        ,a.[IsAwaitingMedicalReview]
        ,a.[HasBeenTreatedLast12Months]
        ,a.[HasVisitedDoctorLast90Days]
        ,a.[IsSeekingMedicalOverseas]
        ,a.[IsTravellingAgainstMedicalAdvice]
        ,a.[HasDiagnosedTerminalCondition]
        ,a.[HasReceviedAdviceTerminalCondition]
        ,a.[MedicalTotalCount]
        ,a.[MedicalApprovedCount]
        ,a.[MedicalAutoAcceptCount]
        ,a.[MedicalDeniedCount]
        ,a.[MedicalAwaitingAssessmentCount]
        ,a.[MedicalNotAssessedCount]
        ,a.[CreateDateOnly]
        ,a.[AssessedDateOnly]
        ,a.[IsMultipleDestinations]
        ,a.[IsAccepted]
        ,b.[Conditions]
        ,c.[SuperGroupName]
        ,c.[JV]
    FROM      [db-au-cmdwh].[dbo].[emcApplications] a WITH(NOLOCK)
    LEFT JOIN [Conditions]                          b WITH(NOLOCK) ON b.[ApplicationKey] = a.[ApplicationKey]
    LEFT JOIN [db-au-cmdwh].[dbo].[penOutlet]       c WITH(NOLOCK) ON c.[OutletAlphaKey] = a.[OutletAlphaKey] AND c.[OutletStatus] = 'Current'
    WHERE CAST([CreateDate] as date) >= '2017-01-01'
    --WHERE c.[SuperGroupName] = 'BUPA'
    --WHERE a.[ApplicationKey] IN ('AU-13882512','AU-13882513','AU-13931115','AU-13931116')
),

[penPolicyEMC] AS (
    SELECT 
         a.*
        ,b.[PolicyTravellerKey]
        ,b.[PolicyTransactionKey]
        ,c.[PolicyKey]
        ,d.[PolicyNumber] AS [BasePolicyNumber]
        ,c.[PolicyNumber]
        ,c.[ProductCode]
        ,c.[TransactionStatus]
        ,c.[IssueTime]
        ,c.[OutletAlphaKey] AS [PolicyOutletAlphaKey]
        ,e.[SuperGroupName] AS [PolicySuperGroupName]
        ,e.[JV]             AS [PolicyJV]
        ,f.[GrossPremium]   AS [EMCGrossPremium]
    FROM      [db-au-cmdwh].[dbo].[penPolicyEMC]                  a WITH(NOLOCK)
    LEFT JOIN [db-au-cmdwh].[dbo].[penPolicyTravellerTransaction] b WITH(NOLOCK) ON a.[PolicyTravellerTransactionKey] = b.[PolicyTravellerTransactionKey]
    LEFT JOIN [db-au-cmdwh].[dbo].[penPolicyTransSummary]         c WITH(NOLOCK) ON b.[PolicyTransactionKey]          = c.[PolicyTransactionKey]
    LEFT JOIN [db-au-cmdwh].[dbo].[penPolicyTransSummary]         d WITH(NOLOCK) ON c.[PolicyKey]                     = d.[PolicyKey]      AND d.[TransactionType] = 'Base' AND d.[TransactionStatus] = 'Active'
    LEFT JOIN [db-au-cmdwh].[dbo].[penOutlet]                     e WITH(NOLOCK) ON c.[OutletAlphaKey]                = e.[OutletAlphaKey] AND e.[OutletStatus] = 'Current'
    LEFT JOIN (SELECT [PolicyKey],[AddOnText]
                     ,SUM([GrossPremium]) AS [GrossPremium]
               FROM [db-au-cmdwh].[dbo].[penPolicyTransAddOn] WITH(NOLOCK)
               GROUP BY [PolicyKey],[AddOnText])                  f              ON c.[PolicyKey]                     = f.[PolicyKey]      AND a.[EMCRef] = f.[AddOnText]
    --WHERE e.[SuperGroupName] = 'BUPA'
    --WHERE a.[EMCApplicationKey] IN ('AU-13882512','AU-13882513','AU-13931115','AU-13931116')
),

[emcApplications_penPolicyEMC] AS (
    SELECT
         CHECKSUM(a.[CreateDate],a.[DepartureDate],a.[ReturnDate],a.[Destination],a.[AreaName],a.[TripType]) AS [QuoteKey]
        ,a.*
        ,b.[PolicyTravellerTransactionKey]
        ,b.[PolicyTravellerKey]
        ,b.[FirstName]
        ,b.[LastName]
        ,b.[DOB]
        ,b.[PolicyTransactionKey]
        ,b.[PolicyKey]
        ,b.[BasePolicyNumber]
        ,b.[PolicyNumber]
        ,b.[ProductCode]
        ,b.[TransactionStatus]
        ,b.[IssueTime]
        ,b.[PolicyOutletAlphaKey]
        ,b.[PolicySuperGroupName]
        ,b.[PolicyJV]
        ,b.[PremiumIncrease]
        ,b.[EMCGrossPremium]
        ,a.[ApprovalStatus] AS [EMCApproved]
        ,CASE WHEN b.[BasePolicyNumber] IS NULL     THEN 'Not Purchased'
              WHEN b.[TransactionStatus] = 'Active' THEN 'Purchased - Active'
                                                    ELSE 'Purchased - Cancelled'
         END AS [PolicyPurchased]
        ,CASE WHEN a.[ApprovalStatus] = 'NotCovered' AND b.[BasePolicyNumber] IS NULL THEN 'Not Covered - Not Purchased'
              WHEN a.[ApprovalStatus] = 'Covered'    AND b.[BasePolicyNumber] IS NULL THEN 'Covered - Not Purchased'
              WHEN a.[ApprovalStatus] = 'NotCovered'                                  THEN 'Not Covered - Purchased'
              WHEN a.[IsAccepted] = 0                                                 THEN 'Covered - Declined - Purchased'
                                                                                      ELSE 'Covered - Accepted - Purchased'
         END AS [EMCAccepted]

    FROM [emcApplications] a
    OUTER APPLY (
        --Join latest policy transaction
        SELECT TOP 1 *
        FROM [penPolicyEMC] b
        WHERE a.[ApplicationKey] = b.[EMCApplicationKey]
        ORDER BY [IssueTime] DESC
    ) b
),

[Conditions_CBA] AS (
    SELECT
         [ApplicationKey]
        ,STUFF((SELECT ', ' + [Condition]
                FROM [azsyddwh02].[db-au-cba].[dbo].[emcMedical] b WITH(NOLOCK)
                WHERE a.[ApplicationKey] = b.[ApplicationKey]
                ORDER BY [Condition]
                FOR XML PATH('')
                ),1,1,'') AS [Conditions]
    FROM [azsyddwh02].[db-au-cba].[dbo].[emcMedical] a WITH(NOLOCK)
    GROUP BY [ApplicationKey]
),

[emcApplications_CBA] AS (
    SELECT
         a.[CountryKey]
        ,a.[ApplicationKey]
        ,a.[CompanyKey]
        ,a.[AgencyKey]
        ,a.[OutletAlphaKey]
        ,a.[AssessorKey]
        ,a.[CreatorKey]
        ,a.[ApplicationID]
        ,a.[RecordID]
        ,a.[ApplicationType]
        ,a.[AgencyCode]
        ,a.[AssessorID]
        ,a.[Assessor]
        ,a.[CreatorID]
        ,a.[Creator]
        ,a.[Priority]
        ,a.[CreateDate]
        ,a.[ReceiveDate]
        ,a.[AssessedDate]
        ,a.[IsEndorsementSigned]
        ,a.[EndorsementDate]
        ,a.[ApplicationStatus]
        ,a.[ApprovalStatus]
        ,a.[AgeApprovalStatus]
        ,a.[MedicalRisk]
        ,a.[AreaName]
        ,a.[AreaCode]
        ,a.[ScreeningVersion]
        ,a.[PlanCode]
        --,a.[ProductCode]
        ,a.[ProductType]
        ,a.[DepartureDate]
        ,a.[ReturnDate]
        ,a.[TripDuration]
        ,a.[Destination]
        ,a.[TravellerCount]
        ,a.[ValuePerTraveller]
        ,a.[TripType]
        ,a.[PolicyNo]
        ,a.[OtherInsurer]
        ,a.[InputType]
        ,a.[FileLocation]
        ,a.[FileLocationDate]
        ,a.[ClaimNo]
        ,a.[ClaimDate]
        ,a.[IsClaimRelatedToEMC]
        ,a.[IsDeclarationSigned]
        ,a.[IsAnnualBusinessPlan]
        ,a.[IsApplyingForEMCCover]
        ,a.[IsApplyingForCMCover]
        ,a.[IsSendOutcomeByEmail]
        ,a.[HasAgeDestinationDuration]
        ,a.[IsDutyOfDisclosure]
        ,a.[IsCruise]
        ,a.[IsAnnualMultiTrip]
        ,a.[IsWinterSport]
        ,a.[IsOnlineAssessment]
        ,a.[OnlineAssessment]
        ,a.[EMCPremium]
        ,a.[AgePremium]
        ,a.[Excess]
        ,a.[GeneralLimit]
        ,a.[PaymentDuration]
        ,a.[RestrictedConditions]
        ,a.[OtherRestrictions]
        ,a.[PaymentComments]
        ,a.[IsAwaitingMedicalReview]
        ,a.[HasBeenTreatedLast12Months]
        ,a.[HasVisitedDoctorLast90Days]
        ,a.[IsSeekingMedicalOverseas]
        ,a.[IsTravellingAgainstMedicalAdvice]
        ,a.[HasDiagnosedTerminalCondition]
        ,a.[HasReceviedAdviceTerminalCondition]
        ,a.[MedicalTotalCount]
        ,a.[MedicalApprovedCount]
        ,a.[MedicalAutoAcceptCount]
        ,a.[MedicalDeniedCount]
        ,a.[MedicalAwaitingAssessmentCount]
        ,a.[MedicalNotAssessedCount]
        ,a.[CreateDateOnly]
        ,a.[AssessedDateOnly]
        ,a.[IsMultipleDestinations]
        ,a.[IsAccepted]
        ,b.[Conditions]
        ,c.[SuperGroupName]
        ,c.[JV]
    FROM      [azsyddwh02].[db-au-cba].[dbo].[emcApplications] a WITH(NOLOCK)
    LEFT JOIN [Conditions_CBA]                                 b WITH(NOLOCK) ON b.[ApplicationKey] = a.[ApplicationKey]
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[penOutlet]       c WITH(NOLOCK) ON c.[OutletAlphaKey] = a.[OutletAlphaKey] AND c.[OutletStatus] = 'Current'
    WHERE CAST([CreateDate] as date) >= '2017-01-01'
),

[penPolicyEMC_CBA] AS (
    SELECT 
         a.*
        ,b.[PolicyTravellerKey]
        ,b.[PolicyTransactionKey]
        ,c.[PolicyKey]
        ,d.[PolicyNumber] AS [BasePolicyNumber]
        ,c.[PolicyNumber]
        ,c.[ProductCode]
        ,c.[TransactionStatus]
        ,c.[IssueTime]
        ,c.[OutletAlphaKey] AS [PolicyOutletAlphaKey]
        ,e.[SuperGroupName] AS [PolicySuperGroupName]
        ,e.[JV]             AS [PolicyJV]
        ,f.[GrossPremium]   AS [EMCGrossPremium]
    FROM      [azsyddwh02].[db-au-cba].[dbo].[penPolicyEMC]                  a WITH(NOLOCK)
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[penPolicyTravellerTransaction] b WITH(NOLOCK) ON a.[PolicyTravellerTransactionKey] = b.[PolicyTravellerTransactionKey]
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[penPolicyTransSummary]         c WITH(NOLOCK) ON b.[PolicyTransactionKey]          = c.[PolicyTransactionKey]
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[penPolicyTransSummary]         d WITH(NOLOCK) ON c.[PolicyKey]                     = d.[PolicyKey]      AND d.[TransactionType] = 'Base' AND d.[TransactionStatus] = 'Active'
    LEFT JOIN [azsyddwh02].[db-au-cba].[dbo].[penOutlet]                     e WITH(NOLOCK) ON c.[OutletAlphaKey]                = e.[OutletAlphaKey] AND e.[OutletStatus] = 'Current'
    LEFT JOIN (SELECT b.[PolicyKey],a.[AddOnText]
                     ,SUM(a.[GrossPremium]) AS [GrossPremium]
               FROM [azsyddwh02].[db-au-cba].[dbo].[penPolicyTransAddOn]     a WITH(NOLOCK)
               JOIN [azsyddwh02].[db-au-cba].[dbo].[penPolicyTransSummary]   b WITH(NOLOCK) ON a.[PolicyTransactionKey] = b.[PolicyTransactionKey]
               GROUP BY [PolicyKey],[AddOnText])                             f              ON c.[PolicyKey]                     = f.[PolicyKey]      AND a.[EMCRef] = f.[AddOnText]
),

[emcApplications_penPolicyEMC_CBA] AS (
    SELECT
         CHECKSUM(a.[CreateDate],a.[DepartureDate],a.[ReturnDate],a.[Destination],a.[AreaName],a.[TripType]) AS [QuoteKey]
        ,a.*
        ,b.[PolicyTravellerTransactionKey]
        ,b.[PolicyTravellerKey]
        ,b.[FirstName]
        ,b.[LastName]
        ,b.[DOB]
        ,b.[PolicyTransactionKey]
        ,b.[PolicyKey]
        ,b.[BasePolicyNumber]
        ,b.[PolicyNumber]
        ,b.[ProductCode]
        ,b.[TransactionStatus]
        ,b.[IssueTime]
        ,b.[PolicyOutletAlphaKey]
        ,b.[PolicySuperGroupName]
        ,b.[PolicyJV]
        ,b.[PremiumIncrease]
        ,b.[EMCGrossPremium]
        ,a.[ApprovalStatus] AS [EMCApproved]
        ,CASE WHEN b.[BasePolicyNumber] IS NULL     THEN 'Not Purchased'
              WHEN b.[TransactionStatus] = 'Active' THEN 'Purchased - Active'
                                                    ELSE 'Purchased - Cancelled'
         END AS [PolicyPurchased]
        ,CASE WHEN a.[ApprovalStatus] = 'NotCovered' AND b.[BasePolicyNumber] IS NULL THEN 'Not Covered - Not Purchased'
              WHEN a.[ApprovalStatus] = 'Covered'    AND b.[BasePolicyNumber] IS NULL THEN 'Covered - Not Purchased'
              WHEN a.[ApprovalStatus] = 'NotCovered'                                  THEN 'Not Covered - Purchased'
              WHEN a.[IsAccepted] = 0                                                 THEN 'Covered - Declined - Purchased'
                                                                                      ELSE 'Covered - Accepted - Purchased'
         END AS [EMCAccepted]

    FROM [emcApplications_CBA] a
    OUTER APPLY (
        --Join latest policy transaction
        SELECT TOP 1 *
        FROM [penPolicyEMC_CBA] b
        WHERE a.[ApplicationKey] = b.[EMCApplicationKey]
        ORDER BY [IssueTime] DESC
    ) b
)

SELECT * ,ROW_NUMBER() OVER (PARTITION BY [QuoteKey] ORDER BY [EMCAccepted],[ApplicationKey]) AS [Rank] FROM [emcApplications_penPolicyEMC]
UNION ALL
SELECT * ,ROW_NUMBER() OVER (PARTITION BY [QuoteKey] ORDER BY [EMCAccepted],[ApplicationKey]) AS [Rank] FROM [emcApplications_penPolicyEMC_CBA]
--ORDER BY [QuoteKey],[ApplicationKey]

--Summary   
--SELECT 
--     EOMONTH([CreateDate])                              AS [CreateDate]
--    ,COUNT(DISTINCT [QuoteKey])                         AS [Quote Count]
--    ,COUNT(DISTINCT IIF([TransactionStatus] =  'Active',[BasePolicyNumber],NULL)) AS [Purchased - Active]
--    ,COUNT(DISTINCT IIF([TransactionStatus] <> 'Active',[BasePolicyNumber],NULL)) AS [Purchased - Cancelled]
--    ,COUNT(DISTINCT IIF([BasePolicyNumber] IS NULL     ,[QuoteKey]        ,NULL)) AS [Not Purchased]

--    ,COUNT(*)                                       AS [Application Count]
--    ,SUM(IIF([ApprovalStatus]='Covered',1,0))       AS [Covered]
--    ,SUM(IIF([ApprovalStatus]='NotCovered',1,0))    AS [Not Covered]
--    ,SUM(IIF([EMCAccepted]='Covered - Purchased - Accepted',1,0))       AS [Covered - Purchased - Accepted]
--    ,SUM(IIF([EMCAccepted]='Covered - Purchased - NotAccepted',1,0))    AS [Covered - Purchased - NotAccepted]
--    ,SUM(IIF([EMCAccepted]='Covered - Not Purchased',1,0))              AS [Covered - Not Purchased]
--    ,SUM(IIF([EMCAccepted]='Not Covered - Purchased',1,0))              AS [Not Covered - Purchased]
--    ,SUM(IIF([EMCAccepted]='Not Covered - Not Purchased',1,0))          AS [Not Covered - Not Purchased]

--FROM [emcApplications-Policy]
--GROUP BY EOMONTH([CreateDate])
--ORDER BY EOMONTH([CreateDate])
;
GO
