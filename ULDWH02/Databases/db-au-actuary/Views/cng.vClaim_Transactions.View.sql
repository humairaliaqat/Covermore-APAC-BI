USE [db-au-actuary]
GO
/****** Object:  View [cng].[vClaim_Transactions]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vClaim_Transactions] AS

/****************************************************************************************************/
--  Name:           vClaim_Transactions
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  2024-09-13 Add EventDescription and EventLocation from [clmOnlineClaimEvent] and [clmEvent]
--                  
/****************************************************************************************************/

WITH 
ClaimDataSet AS (
    SELECT 
        *
       ,CASE WHEN COALESCE(SUM([NetIncurredMovementIncRecoveries]) OVER (PARTITION BY [Domain Country],[ClaimKey],[SectionID] ORDER BY [IncurredTime]),0) >= 0.1 
              AND COALESCE(SUM([NetIncurredMovementIncRecoveries]) OVER (PARTITION BY [Domain Country],[ClaimKey],[SectionID] ORDER BY [IncurredTime] ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0) < 0.1
             THEN 1
             WHEN COALESCE(SUM([NetIncurredMovementIncRecoveries]) OVER (PARTITION BY [Domain Country],[ClaimKey],[SectionID] ORDER BY [IncurredTime]),0) < 0.1
              AND COALESCE(SUM([NetIncurredMovementIncRecoveries]) OVER (PARTITION BY [Domain Country],[ClaimKey],[SectionID] ORDER BY [IncurredTime] ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),0) >= 0.1
             THEN -1
             ELSE 0
        END AS [SectionCountNonNil]
    FROM [db-au-actuary].[cng].[Tmp_ClaimDataSet]
),

clmEvent AS (
    SELECT * FROM [db-au-actuary].[cng].[Tmp_clmEvent]
),

clmSection AS (
    SELECT * FROM [db-au-actuary].[cng].[Tmp_clmSection]
),

catCode AS (
    SELECT 
         [CountryCode] collate SQL_Latin1_General_CP1_CI_AS AS [CountryKey]
        ,[KC_CODE]     collate SQL_Latin1_General_CP1_CI_AS AS [CatastropheCode]
        ,[KCSHORT]     collate SQL_Latin1_General_CP1_CI_AS AS [CatastropheShortDesc]
        ,[KCLONG]      collate SQL_Latin1_General_CP1_CI_AS AS [CatastropheLongDesc]
    FROM [db-au-actuary].[cng].[Tmp_KLCatas]
),

e5CaseNote AS (
    SELECT * FROM [db-au-actuary].[cng].[Tmp_e5WorkCaseNote]
),

perilCode AS (
    SELECT [CountryKey] 
          ,[PerilCode]
          ,[PerilDesc]
          ,ROW_NUMBER() OVER (PARTITION BY [CountryKey],[PerilCode] ORDER BY COUNT(*) DESC) AS [Rank]
    FROM [db-au-actuary].[cng].[Tmp_clmEvent]
    GROUP BY [CountryKey],[PerilCode],[PerilDesc]
),

ctrn AS (
    SELECT 
         ROW_NUMBER() OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID] ORDER BY a.[IncurredTime] DESC) AS [Rank]

        ,a.[Domain Country] AS [DomainCountry]
        ,a.[Company]
        ,a.[OutletKey]
        ,a.[PolicyKey]
        ,a.[BasePolicyNo]
        ,a.[ClaimKey]
        ,a.[ClaimNo]
        ,a.[EventID]
        ,a.[SectionID]
        ,CONCAT(a.[Domain Country],'-',a.[ClaimNo],'-',a.[EventID],'-',a.[SectionID]) AS [SectionKey]
        ,a.[CustomerCareID]

        ,a.[StatusAtEndOfDay]
        ,a.[StatusAtEndOfMonth]
        ,a.[AssessmentOutcome]

        --,a.[EventDescription]
        ,REPLACE(
         COALESCE(       LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(IIF(b.[EventDesc]       ='',NULL,b.[EventDesc]       ))),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '))),'') + 
         COALESCE('. ' + LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(IIF(b.[EventLocation]   ='',NULL,b.[EventLocation]   ))),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '))),'') + 
         COALESCE('. ' + LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(IIF(b.[Detail]          ='',NULL,b.[Detail]          ))),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '))),'') + 
         COALESCE('. ' + LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(IIF(b.[AdditionalDetail]='',NULL,b.[AdditionalDetail]))),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '))),'') 
         + '.','..','.') AS [EventDescription]
        ,b.[EventLocation]
        ,a.[EventCountryCode]
        ,a.[EventCountryName]
        ,a.[EventSubContinent]
        ,a.[EventContinent]
        ,b.[CatastropheCode] AS [CATCode]
        --,CASE WHEN b.[CatastropheCode] NOT IN ('','CAT') THEN b.[CatastropheCode]
        --      WHEN ((LOWER(a.[EventDescription]) LIKE '%coron%' AND LOWER(a.[EventDescription]) LIKE '%virus%') OR 
        --             LOWER(a.[EventDescription]) LIKE '%covid%' OR
        --             LOWER(a.[EventDescription]) LIKE '%pcr%'   OR
        --             LOWER(a.[EventDescription]) LIKE '%c19%' )
        --           AND a.[LossDate] >= '2020-01-01' THEN 'COR1'
        --      ELSE b.[CatastropheCode]
        -- END AS [CATCode]
        ,c.[CatastropheShortDesc]
        ,c.[CatastropheLongDesc]
        ,a.[PerilCode]
        ,d.[PerilDesc]
        ,a.[SectionCode]
        ,e.[SectionDescription]
        ,e.[BenefitLimit]
        ,a.[BenefitSectionKey]
        ,a.[BenefitCategory]
        ,a.[ActuarialBenefitGroup]

        ,CAST(a.[IssueQuarter]    AS date) AS [IssueQuarter]
        ,CAST(a.[LossQuarter]     AS date) AS [LossQuarter]
        ,CAST(a.[ReceiptQuarter]  AS date) AS [ReceiptQuarter]
        ,CAST(a.[RegisterQuarter] AS date) AS [RegisterQuarter]
        ,CAST(a.[SectionQuarter]  AS date) AS [SectionQuarter]
        ,CAST(a.[IncurredQuarter] AS date) AS [IncurredQuarter]

        ,a.[IssueMonth]
        ,a.[LossMonth]
        ,a.[ReceiptMonth]
        ,a.[RegisterMonth]
        ,a.[SectionMonth]
        ,a.[IncurredMonth]

        ,a.[IssueDate]
        ,a.[LossDate]
        ,a.[ReceiptDate]
        ,a.[RegisterDate]
        ,a.[SectionDate]
        ,a.[IncurredDate]
        ,a.[IncurredTime]

        ,a.[IncurredAgeBand]
        ,a.[IssueDevelopmentMonth]
        ,a.[LossDevelopmentMonth]
        ,a.[ReceiptDevelopmentMonth]
        ,a.[IssueDevelopmentQuarter]
        ,a.[LossDevelopmentQuarter]
        ,a.[ReceiptDevelopmentQuarter]

        ,a.[OnlineClaimFlag]              AS [OnlineClaimFlag]
        ,a.[MedicalAssistanceClaimFlag]   AS [MedicalAssistanceClaimFlag]
        ,a.[ClaimMentalHealthFlag]        AS [MentalHealthClaimFlag]
        ,a.[ClaimLuggageFlag]             AS [LuggageClaimFlag]
        ,a.[ClaimElectronicsFlag]         AS [ElectronicsClaimFlag]
        ,a.[ClaimCruiseFlag]              AS [CruiseClaimFlag]
        ,a.[ClaimMopedFlag]               AS [MopedClaimFlag]
        ,a.[ClaimRentalCarFlag]           AS [RentalCarClaimFlag]
        ,a.[ClaimWinterSportFlag]         AS [WinterSportClaimFlag]
        ,a.[ClaimCrimeVictimFlag]         AS [CrimeVictimClaimFlag]
        ,a.[ClaimFoodPoisoningFlag]       AS [FoodPoisoningClaimFlag]
        ,a.[ClaimAnimalFlag]              AS [AnimalClaimFlag]
        --,IIF(LOWER(a.[EventDescription]) LIKE '%cancel for any reason%'
        --  OR LOWER(a.[EventDescription]) LIKE '%cfar%'
        --  OR LOWER(f.[CaseNote]) LIKE '%cancel for any reason%'
        --  OR LOWER(f.[CaseNote]) LIKE '%cfar%'
        --  OR a.[PerilCode] = 'CFR',1,0)   AS [CFARClaimFlag]

        ,a.[BIRowID]
        ,a.[PaymentID]
        ,a.[LocalCurrencyCode]
        ,a.[ExposureCurrencyCode]
        ,a.[OriginalCurrencyCode]
        ,a.[OriginalFXRate]
        ,a.[ForeignCurrencyCode]
        ,a.[ForeignCurrencyRate]
        ,a.[ForeignCurrencyRateDate]
        ,a.[USDRate]

        ,a.[SectionCount],a.[SectionCountNonNil]
        --,SUM(a.[SectionCount])        OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [SectionCount]
        --,SUM(a.[SectionCountNon Nil]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [SectionCountNonNil]

        ,a.[NetPaymentMovementIncRecoveries],a.[NetIncurredMovementIncRecoveries]
        --,SUM(a.[NetPaymentMovementIncRecoveries])  OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetPaymentMovementIncRecoveries]
        --,SUM(a.[NetIncurredMovementIncRecoveries]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetIncurredMovementIncRecoveries]

        ,a.[EstimateMovement],a.[PaymentMovement],a.[RecoveryMovement],a.[IncurredMovement]
        --,SUM(a.[EstimateMovement]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [EstimateMovement]
        --,SUM(a.[PaymentMovement])  OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [PaymentMovement]
        --,SUM(a.[RecoveryMovement]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [RecoveryMovement]
        --,SUM(a.[IncurredMovement]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [IncurredMovement]
        --,a.[EstimateAsAt],a.[PaymentAsAt],a.[RecoveryAsAt],a.[IncurredAsAt]

        ,a.[NetPaymentMovement],a.[NetRecoveryMovement],a.[NetIncurredMovement],a.[NetRealRecoveryMovement],a.[NetApprovedPaymentMovement]
        --,SUM(a.[NetPaymentMovement])         OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetPaymentMovement]
        --,SUM(a.[NetRecoveryMovement])        OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetRecoveryMovement]
        --,SUM(a.[NetIncurredMovement])        OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetIncurredMovement]
        --,SUM(a.[NetRealRecoveryMovement])    OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetRealRecoveryMovement]
        --,SUM(a.[NetApprovedPaymentMovement]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetApprovedPaymentMovement]
        --,a.[NetPaymentAsAt],a.[NetRecoveryAsAt],a.[NetIncurredAsAt],a.[NetRealRecoveryAsAt],a.[NetApprovedPaymentAsAt]

        ,a.[IncurredAtReference]
        ,a.[NetIncurredAtReference]
        ,a.[IncurredAtEOM]
        ,a.[NetIncurredAtEOM]
        ,a.[MaxIncurredEOM]
        ,a.[MaxNetIncurredEOM]
    
        --,a.[IncurredACS]
        ,a.[SizeAsAt]
        ,a.[Size500]
        ,a.[Size1k]
        ,a.[Size5k]
        ,a.[Size10k]
        ,a.[Size25k]
        ,a.[Size35k]
        ,a.[Size50k]
        ,a.[Size75k]
        ,a.[Size100k]

        ,a.[FXReferenceDate]
        ,a.[FXReferenceRate]
        ,a.[USDRateReference]
        ,a.[UsedFXCode]
        ,a.[UsedFXRateThen]
        ,a.[UsedFXRateNow]
        ,a.[FXConversion]

        ,a.[EstimateMovement_FX],a.[PaymentMovement_FX],a.[RecoveryMovement_FX],a.[IncurredMovement_FX]
        --,SUM(a.[EstimateMovement_FX]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [EstimateMovement_FX]
        --,SUM(a.[PaymentMovement_FX])  OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [PaymentMovement_FX]
        --,SUM(a.[RecoveryMovement_FX]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [RecoveryMovement_FX]
        --,SUM(a.[IncurredMovement_FX]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [IncurredMovement_FX]
        --,a.[EstimateAsAt_FX],a.[PaymentAsAt_FX],a.[RecoveryAsAt_FX],a.[IncurredAsAt_FX]

        ,a.[NetPaymentMovement_FX],a.[NetRecoveryMovement_FX],a.[NetIncurredMovement_FX],a.[NetRealRecoveryMovment_FX] AS [NetRealRecoveryMovement_FX],a.[NetApprovedPaymentMovement_FX]
        --,SUM(a.[NetPaymentMovement_FX])         OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetPaymentMovement_FX]
        --,SUM(a.[NetRecoveryMovement_FX])        OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetRecoveryMovement_FX]
        --,SUM(a.[NetIncurredMovement_FX])        OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetIncurredMovement_FX]
        --,SUM(a.[NetRealRecoveryMovment_FX])     OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetRealRecoveryMovement_FX]
        --,SUM(a.[NetApprovedPaymentMovement_FX]) OVER (PARTITION BY a.[Domain Country],a.[ClaimKey],a.[SectionID]) AS [NetApprovedPaymentMovement_FX]
        --,a.[NetPaymentAsAt_FX],a.[NetRecoveryAsAt_FX],a.[NetIncurredAsAt_FX],a.[NetRealRecoveryAsAt_FX],a.[NetApprovedPaymentAsAt_FX]

        ,a.[Underwriter]
        ,a.[PurchasePathGroup]
        ,a.[Channel]
        ,a.[Distributor]
        ,a.[AlphaCode]
        ,a.[GroupName]
        ,a.[JVCode]
        ,CASE WHEN a.[JV] = 'AHM - Medibank'      THEN 'ahm - Medibank'
              WHEN a.[JV] = 'BW WL'               THEN 'BW NAC'
              WHEN a.[JV] = 'Existing Clients'    THEN 'Bupa'
              WHEN a.[JV] = 'Integration'         THEN 'Malaysia Airlines'
              WHEN a.[JV] IS NULL                 THEN 'Unknown'
              ELSE a.[JV]
         END AS [JV]
        ,a.[ProductCode]

        ,a.[AreaType]
        ,a.[AreaName]
        ,a.[Destination]  
            
        ,a.[DepartureDate]
        ,a.[ReturnDate]

        ,a.[LeadTime]
        ,a.[LeadTimeBand]
        ,a.[LeadTimeGroup]

        ,a.[CancellationFlag]
        ,a.[CancellationCover]
        ,a.[CancellationCoverBand]

        ,a.[EMCFlag]
        ,a.[MaxEMCScore]
        ,a.[TotalEMCScore]

        ,a.[CruiseFlag]
        ,a.[ElectronicsFlag]
        ,a.[LuggageFlag]
        ,a.[MotorcycleFlag]
        ,a.[RentalCarFlag]
        ,a.[WinterSportFlag]

        --,a.[NumberOfRecords]

    FROM      ClaimDataSet  a
    LEFT JOIN clmEvent      b ON a.[ClaimKey] = b.[ClaimKey] AND a.[EventID] = b.[EventID]
    LEFT JOIN catCode       c ON a.[Domain Country] = c.[CountryKey] AND b.[CatastropheCode] = c.[CatastropheCode]
    LEFT JOIN perilCode     d ON a.[Domain Country] = d.[CountryKey] AND a.[PerilCode] = d.[PerilCode] AND d.[Rank] = 1
    LEFT JOIN clmSection    e ON CONCAT(a.[Domain Country],'-',a.[ClaimNo],'-',a.[EventID],'-',a.[SectionID]) = e.[SectionKey]
    --LEFT JOIN e5CaseNote    f ON a.[ClaimKey] = f.[ClaimKey]
)

SELECT 
     a.*
    ,CASE
        WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)<= '2020-11-30' THEN 'CAT'
        WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)>= '2020-12-01'
                                               AND CAST(a.[IssueDate] as date)<= '2023-06-30' THEN 'COV'
        WHEN a.[CATCode] NOT IN ('COR','COR1','CAT','CO1','MHC',' ')                          THEN 'CAT'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size50k] = 'Underlying' THEN 'ADD'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size50k] = 'Underlying' THEN 'CAN'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size50k] = 'Underlying' THEN 'MIS'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size50k] = 'Underlying' THEN 'MED'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size50k] = 'Underlying' THEN 'MIS'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size50k] = 'Large'      THEN 'ADD_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size50k] = 'Large'      THEN 'CAN_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size50k] = 'Large'      THEN 'MIS_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size50k] = 'Large'      THEN 'MED_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size50k] = 'Large'      THEN 'MIS_LGE'
                                                                                              ELSE 'OTH'
     END AS [Section]
    ,CASE
        WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)<= '2020-11-30' THEN 'CAT'
      --WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)>= '2020-12-01'
      --                                       AND CAST(a.[IssueDate] as date)<= '2023-06-30' THEN 'COV'
        WHEN a.[CATCode] NOT IN ('COR','COR1','CAT','CO1','MHC',' ')                          THEN 'CAT'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size50k] = 'Underlying' THEN 'ADD'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size50k] = 'Underlying' THEN 'CAN'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size50k] = 'Underlying' THEN 'MIS'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size50k] = 'Underlying' THEN 'MED'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size50k] = 'Underlying' THEN 'MIS'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size50k] = 'Large'      THEN 'ADD_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size50k] = 'Large'      THEN 'CAN_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size50k] = 'Large'      THEN 'MIS_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size50k] = 'Large'      THEN 'MED_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size50k] = 'Large'      THEN 'MIS_LGE'
                                                                                              ELSE 'OTH'
     END AS [Section2]
    ,CASE
        WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)<= '2020-11-30' THEN 'CAT'
        WHEN a.[CATCode]     IN ('COR','COR1') AND CAST(a.[IssueDate] as date)>= '2020-12-01'
                                               AND CAST(a.[IssueDate] as date)<= '2023-06-30' THEN 'COV'
        WHEN a.[CATCode] NOT IN ('COR','COR1','CAT','CO1','MHC',' ')                          THEN 'CAT'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size75k] = 'Underlying' THEN 'ADD'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size75k] = 'Underlying' 
         AND CAST(a.[LossDate] as date)> CAST(a.[DepartureDate] as date)                      THEN 'ON_CAN'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size75k] = 'Underlying' THEN 'PRE_CAN'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size75k] = 'Underlying' THEN 'LUG'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size75k] = 'Underlying' THEN 'MED'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size75k] = 'Underlying' THEN 'MIS'
        WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' AND a.[Size75k] = 'Large'      THEN 'ADD_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size75k] = 'Large'      
         AND CAST(a.[LossDate] as date)> CAST(a.[DepartureDate] as date)                      THEN 'ON_CAN_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        AND a.[Size75k] = 'Large'      THEN 'PRE_CAN_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Luggage'             AND a.[Size75k] = 'Large'      THEN 'LUG_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Medical'             AND a.[Size75k] = 'Large'      THEN 'MED_LGE'
        WHEN a.[ActuarialBenefitGroup] = 'Other'               AND a.[Size75k] = 'Large'      THEN 'MIS_LGE'
                                                                                              ELSE 'OTH'
     END AS [Section3]
    ,IIF(ROW_NUMBER() OVER (PARTITION BY a.[DomainCountry],a.[ClaimKey] ORDER BY a.[IncurredTime]) = 1,1,0) AS [ClaimCount]
  --,CASE WHEN a.[EstimateMovement] = 0 THEN a.[IncurredTime] ELSE '9999-12-31' END AS [FinalisedTime]

FROM ctrn a
--WHERE Rank = 1
;
GO
