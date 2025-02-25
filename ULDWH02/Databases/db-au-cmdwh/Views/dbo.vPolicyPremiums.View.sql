USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPolicyPremiums]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vPolicyPremiums]
as
select
    PolicyKey,
    pra.[Unadjusted Sell Price],
    pra.[Unadjusted GST on Sell Price],
    pra.[Unadjusted Stamp Duty on Sell Price],
    prb.[Unadjusted Sell Price (excl GST)],
    prb.[Unadjusted Premium],
    pra.[Unadjusted Agency Commission],
    pra.[Unadjusted GST on Agency Commission],
    pra.[Unadjusted Stamp Duty on Agency Commission],
    prb.[Unadjusted Agency Commission (excl GST)],
    prb.[Unadjusted Net Agency Commission],
    prc.[Unadjusted NAP],
    prc.[Unadjusted NAP (incl Tax)],
    pra.[Sell Price],
    pra.[GST on Sell Price],
    pra.[Stamp Duty on Sell Price],
    prb.[Sell Price (excl GST)],
    prb.[Premium],
    pra.[Agency Commission],
    pra.[GST on Agency Commission],
    pra.[Stamp Duty on Agency Commission],
    prb.[Agency Commission (excl GST)],
    prb.[Net Agency Commission],
    prc.[NAP],
    prc.[NAP (incl Tax)],
    pra.[Risk Nett],
    prd.[Reported NAP],
    case
        when a.CountryKey = 'AU' then au.[Base Nett]
        when a.CountryKey = 'NZ' then nz.[Base Nett]
        when a.CountryKey = 'UK' then uk.[Base Nett]
        else [Premium]
    end [Base Nett]
from
    Policy p
    inner join Agency a on
        a.AgencyKey = p.AgencyKey and
        a.AgencyStatus = 'Current'
    cross apply
    (
        select
            a.AgencySuperGroupName [Super Group],
            a.AgencyGroupCode [Group Code],
            a.AgencyCode [Alpha],
            p.IssuedDate [Issue Date],
            p.ProductCode [Product Code],
            p.CommissionTierID [Commission Tier],
            p.VolumePercentage [Volume Percentage],
            isnull(p.ActualAdminFee, 0) [Unadjusted Admin Fee],
            isnull(p.MedicalPremium, 0) [Unadjusted Medical Premium],
            isnull(p.GrossPremiumExGSTBeforeDiscount, 0) + isnull(p.GSTonGrossPremium, 0) [Unadjusted Sell Price],
            isnull(p.GSTonGrossPremium, 0) [Unadjusted GST on Sell Price],
            isnull(p.StampDuty, 0) [Unadjusted Stamp Duty on Sell Price],
            isnull(p.CommissionAmount, 0) + isnull(p.ActualAdminFee, 0) + isnull(p.GSTOnCommission, 0) [Unadjusted Agency Commission],
            isnull(p.GSTOnCommission, 0) [Unadjusted GST on Agency Commission],
            0 [Unadjusted Stamp Duty on Agency Commission],
            isnull(p.ActualGrossPremiumAfterDiscount, 0) + isnull(p.GSTonGrossPremium, 0) [Sell Price],
            isnull(p.GSTonGrossPremium, 0) [GST on Sell Price],
            isnull(p.StampDuty, 0) [Stamp Duty on Sell Price],
            isnull(p.ActualCommissionAfterDiscount, 0) + isnull(p.ActualAdminFeeAfterDiscount, 0) + isnull(p.GSTOnCommission, 0) [Agency Commission],
            isnull(p.GSTOnCommission, 0) [GST on Agency Commission],
            0 [Stamp Duty on Agency Commission],
            isnull(p.RiskNet, 0) [Risk Nett]
    ) pra
    cross apply
    (
        select
            pra.[Unadjusted Sell Price] - pra.[Unadjusted GST on Sell Price] [Unadjusted Sell Price (excl GST)],
            pra.[Unadjusted Sell Price] - pra.[Unadjusted GST on Sell Price] - [Unadjusted Stamp Duty on Sell Price] [Unadjusted Premium],
            pra.[Unadjusted Agency Commission] - pra.[Unadjusted GST on Agency Commission] [Unadjusted Agency Commission (excl GST)],
            pra.[Unadjusted Agency Commission] - pra.[Unadjusted GST on Agency Commission] - pra.[Unadjusted Stamp Duty on Agency Commission] [Unadjusted Net Agency Commission],
            pra.[Sell Price] - pra.[GST on Sell Price] [Sell Price (excl GST)],
            pra.[Sell Price] - pra.[GST on Sell Price] - [Stamp Duty on Sell Price] [Premium],
            pra.[Agency Commission] - pra.[GST on Agency Commission] [Agency Commission (excl GST)],
            pra.[Agency Commission] - pra.[GST on Agency Commission] - pra.[Stamp Duty on Agency Commission] [Net Agency Commission]
    ) prb
    cross apply
    (
        select
            prb.[Unadjusted Premium] - prb.[Unadjusted Net Agency Commission] [Unadjusted NAP],
            pra.[Unadjusted Sell Price] - pra.[Unadjusted Agency Commission] [Unadjusted NAP (incl Tax)],
            prb.[Premium] - prb.[Net Agency Commission] [NAP],
            pra.[Sell Price] - pra.[Agency Commission] [NAP (incl Tax)]
    ) prc
    cross apply
    (
        select
            case
                when a.CountryKey = 'AU' then prc.[NAP]
                when a.CountryKey = 'NZ' then prc.[NAP]
                when a.CountryKey = 'UK' then prc.[Unadjusted NAP]
                else [Premium]
            end [Reported NAP]
    ) prd
    cross apply
    (
        select
            case
                when [Issue Date] < '2013-10-01' then
                case
                    when [Group Code] = 'AA' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'AF' then [Reported NAP] / 1.1111 
                    when [Group Code] = 'AT' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'CM' then [Reported NAP] / 1 
                    when [Group Code] = 'FL' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'GL' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'RC' then [Reported NAP] / 1 
                    when [Group Code] = 'TB' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'WT' then [Reported NAP] / 1.1042
                    when [Group Code] = 'TN' then [Reported NAP] / 1.1042
                    else 0
                end
                else
                case
                    when [Group Code] = 'AA' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'AT' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'CM' then [Reported NAP] / 1 
                    when [Group Code] = 'FL' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'ST' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'TN' then [Reported NAP] / 1.1042
                    else 0
                end
            end [Base Nett]
    ) uk
    cross apply
    (
        select
            case 
                when [Super Group] in ('Australia Post', 'Medibank', 'AAA') then
                case 
                    when [Product Code] in ('APB', 'APC', 'API') then [NAP (incl Tax)] / 0.7
                    when [Alpha] = 'MBN0003' then [NAP (incl Tax)] / 0.7
                    else [Sell Price (excl GST)]
                end
                else
                case
                    when [Issue Date] < '2012-11-01' then
                    case 	
                        when [Product Code] = 'CMT' and [Group Code] = 'CM' then [Unadjusted Sell Price (excl GST)] * 1.5515
                        when [Product Code] = 'CMT' and [Group Code] = 'IU' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) * 1.9394
                        when [Product Code] = 'CMT' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) * 0.9 * 1.9394
                        when [Product Code] = 'CME' and [Group Code] = 'CM' then [Unadjusted Sell Price (excl GST)] * 1.5415
                        when [Product Code] = 'CME' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) * 0.9 * 1.9454
                        when [Product Code] = 'CMB' then [Unadjusted Sell Price (excl GST)]
                        when [Product Code] = 'CMS' then [Unadjusted Sell Price (excl GST)]
                        when [Product Code] = 'STA' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) * 1.808
                        when [Product Code] = 'CMO' and [Group Code] = 'IH' then  ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) / 0.7
                        when [Product Code] = 'CMO' and [Risk Nett] = 0 then	
                        case	
                            when [Commission Tier] = 'CO-0' then [Unadjusted Sell Price (excl GST)]
                            else 	
                            case 	
                                when [Volume Percentage] is null then [Unadjusted Sell Price (excl GST)]
                                else ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) * [Volume Percentage]
                            end
                        end
                        else [Risk Nett] / 0.6
                    end
                    /*on or after 2012-11-01*/
                    else	
                    case	
                        when [Product Code] = 'CMO' then [Risk Nett] * 1.666667
                        when [Product Code] = 'STA' then [Unadjusted NAP (incl Tax)] * 1.808
                        when [Product Code] = 'CMT' and [Group Code] = 'CM' then [Risk Nett] * 2.0086
                        when [Product Code] = 'CMT' then [Risk Nett] * 1.9394
                        when [Product Code] = 'CME' and [Group Code] = 'CM' then [Risk Nett] * 2.0086
                        when [Product Code] = 'CME' then [Risk Nett] * 1.9454
                        when [Product Code] = 'CMM' then [Risk Nett] * 1.9394
                        when [Product Code] = 'FCT' then [Risk Nett] * 1.9480
                        when [Product Code] = 'FCO' then [Risk Nett] * 1.6854
                        when [Product Code] = 'CBP' then 
                        case 
                            when [Issue Date] < '2012-12-01' then [Unadjusted NAP (incl Tax)] * 1.9789
                            else [Risk Nett] * 1.9789
                        end
                        when [Product Code] = 'CCP' then 
                        case 
                            when [Issue Date] < '2012-12-01' then [Unadjusted NAP (incl Tax)] * 1.9431
                            else [Risk Nett] * 1.9431
                        end
                        else [Unadjusted Sell Price (excl GST)]
                    end
                end		
            end [Base Nett]
    ) au
    cross apply
    (
        select
            case
                when [Product Code] = 'CMB' then [Unadjusted Sell Price (excl GST)]
                when [Product Code] = 'CMS' then [Unadjusted Sell Price (excl GST)]
                when [Product Code] = 'CMC' then [Unadjusted Sell Price (excl GST)] 
                when [Product Code] = 'CMT' and isnull(p.NetAdjustmentFactor, 0) = 0 then 
                case 
                    when [Unadjusted GST on Sell Price] = 0 then 
                    (
                        [Unadjusted Sell Price (excl GST)] -
                        [Unadjusted Medical Premium] -
                        [Unadjusted Admin Fee] -
                        (
                            [Unadjusted Sell Price (excl GST)] -
                            [Unadjusted Admin Fee] - 
                            [Unadjusted Medical Premium]
                        ) * 0.0896552
                    ) * 1.6447 +
                    [Unadjusted Medical Premium]
					else 
					(
					    [Unadjusted Sell Price (excl GST)] - 
					    [Unadjusted Medical Premium] -
					    (
					        (
					            [Unadjusted Sell Price] - 
					            [Unadjusted Admin Fee] -
					            [Unadjusted Medical Premium]
					        ) * 0.0896552 + 
					        [Unadjusted Admin Fee]
					    ) / 1.15
					) * 1.6447 + 
					[Unadjusted Medical Premium]
   				end
                when [Product Code] = 'CMT' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) / p.NetAdjustmentFactor / 0.6 
                when [Product Code] = 'CME' and isnull(p.NetAdjustmentFactor, 0) = 0 then 
                case 
                    when [Group Code] = 'ST' then [Unadjusted Sell Price (excl GST)]
                    else 
                    case 
                        when [Unadjusted GST on Sell Price] = 0 then 
                        (
                            [Unadjusted Sell Price (excl GST)] -
                            [Unadjusted Medical Premium] -
                            [Unadjusted Admin Fee] -
                            (
                                [Unadjusted Sell Price (excl GST)] -
                                [Unadjusted Admin Fee] - 
                                [Unadjusted Medical Premium]
                            ) * 0.0896552
                        ) * 1.6666 +
                        [Unadjusted Medical Premium]
                        else 
					    (
					        [Unadjusted Sell Price (excl GST)] - 
					        [Unadjusted Medical Premium] -
					        (
					            (
					                [Unadjusted Sell Price] - 
					                [Unadjusted Admin Fee] -
					                [Unadjusted Medical Premium]
					            ) * 0.0896552 + 
					            [Unadjusted Admin Fee]
					        ) / 1.15
					    ) * 1.6666 + 
					    [Unadjusted Medical Premium]
                    end											 
                end 
                when [Product Code] = 'CME' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Admin Fee]) / p.NetAdjustmentFactor / 0.6 
                when [Product Code] = 'CMO' and isnull(p.NetAdjustmentFactor, 0) = 0 then [Unadjusted Sell Price (excl GST)]
                when [Product Code] = 'CMO' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / p.NetAdjustmentFactor / 0.6
                when [Product Code] in ('CMU', 'CMA') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / p.NetAdjustmentFactor / 0.6
                else [Unadjusted Sell Price (excl GST)]
            end [Base Nett]
    ) nz
GO
