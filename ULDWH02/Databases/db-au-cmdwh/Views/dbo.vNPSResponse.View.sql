USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vNPSResponse]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vNPSResponse] as
select 
    t.BIRowID,
    t.SuperGroup,
    pt.PolicyTransactionKey,
    cl.ClaimKey,
    ma.CaseKey,
    t.OverallScore [Overall Score],
    isnull(t.[Q2a#  Score reason], '') [Score Comment],
    [db-au-cmdwh].dbo.fn_StrToInt(t.[Q3# And how likely are you to recommend to family, friends and c]) [Recommendation Score],
    t.ClmSFScore_Overall [Claim Score],
    isnull(t.[C5# Claim comment], '') [Claim Comment],
    case
        when 
            case
                when t.[M2# How satisfied were you with each of these aspects in the han] = 'Does not apply' then 0
                else 1
            end +
            case
                when t.[M2# How satisfied were you with each of these aspects in the ha1] = 'Does not apply' then 0
                else 1
            end +
            case
                when t.[M2# How satisfied were you with each of these aspects in the ha2] = 'Does not apply' then 0
                else 1
            end = 0 then 0
        else
            (
                [db-au-cmdwh].dbo.fn_StrToInt(t.[M2# How satisfied were you with each of these aspects in the han]) +
                [db-au-cmdwh].dbo.fn_StrToInt(t.[M2# How satisfied were you with each of these aspects in the ha1]) +
                [db-au-cmdwh].dbo.fn_StrToInt(t.[M2# How satisfied were you with each of these aspects in the ha2]) 
            ) * 1.0 /
            (
                case
                    when t.[M2# How satisfied were you with each of these aspects in the han] = 'Does not apply' then 0
                    else 1
                end +
                case
                    when t.[M2# How satisfied were you with each of these aspects in the ha1] = 'Does not apply' then 0
                    else 1
                end +
                case
                    when t.[M2# How satisfied were you with each of these aspects in the ha2] = 'Does not apply' then 0
                    else 1
                end
            )
        end [MA Score],
    isnull(t.[M3# Case comment], '') [MA Comment],
    [db-au-cmdwh].dbo.fn_StrToInt(t.[P3b# Overall how satisfied would you say you are with the Global]) [GlobalSIM Score],
    isnull(t.[Is there anything else about your experience with the Global SIM], '') [GlobalSIM Comment],
    RecommendedScore,
    ClmSFScore_Response,
    ClmSFScore_Engagement,
    ClmSFScore_StaffKnowledge,
    ClmSFScore_Timing,
    GlobalSIMSFScore,
    GlobalSIMRecScore,
    ResponsiveSFScore,
    EngagementSFScore,
    OverallSFScore
from
    npsData t
    outer apply
    (
        select top 1 
            PolicyTransactionKey
        from    
            [db-au-cmdwh]..penPolicyTransSummary pt
        where
            pt.CountryKey = t.DomainCountry and
            pt.PolicyNumber = t.[Policy No]
    ) pt
    outer apply
    (
        select top 1 
            Claimkey
        from
            [db-au-cmdwh]..clmClaim cl
        where
            cl.CountryKey = t.DomainCountry and
            cl.ClaimNo = try_convert(int, t.[Claim No])
    ) cl
    outer apply
    (
        select 
            cc.CaseKey
        from
            [db-au-cmdwh]..cbCase cc
        where
            cc.CaseNo = t.[MA Case No]
    ) ma




GO
