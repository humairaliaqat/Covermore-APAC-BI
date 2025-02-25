USE [db-au-actuary]
GO
/****** Object:  View [cng].[vClaim_Header_Extra]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vClaim_Header_Extra] AS
SELECT
     a.*
    ,b.[CreditCard]
    ,c.[FirstName]
    ,c.[Surname]
    ,c.[DOB]
    ,d.[Conditions]
    ,e.[AssessmentOutcome] AS [vAssessmentOutcome]
    ,e.[Vulnerable Customer Information]
    ,e.[Primary Denial Reason]
    ,e.[Secondary Denial Reason]
    ,e.[Tertiary Denial Reason]
    ,e.[Respond Complaint Lodged]
    ,e.[Claim Withdrawal Reason]
    ,e.[FTG Applied]
    ,e.[Indemnity Decision]
    ,e.[PrimaryClaimant]
FROM      [db-au-actuary].[cng].[Claim_Header]          a
LEFT JOIN [db-au-actuary].[cng].[Tmp_clmOnlineClaim]    b ON a.[ClaimKey]   = b.[ClaimKey]
LEFT JOIN [db-au-actuary].[cng].[Tmp_clmClaimSummary]   c ON a.[SectionKey] = c.[SectionKey]
LEFT JOIN [db-au-actuary].[cng].[Tmp_EmcApplications]   d ON a.[PolicyKey]  = d.[PolicyKey] AND a.[ProductCode] = d.[ProductCode] AND CAST(c.[DOB] as date) = CAST(d.[DOB] as date)
OUTER APPLY (
    SELECT TOP 1 *
    FROM [db-au-actuary].[cng].[Tmp_vClaimAssessmentOutcome] e 
    WHERE a.[ClaimKey] = e.[ClaimKey]
    ORDER BY [ClaimKey],[CreateDate],[AssessmentOutcome]
    ) e
;
GO
