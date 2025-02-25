USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vPenguinPolicyUWPremiums]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vPenguinPolicyUWPremiums]

/*
20140205, LS,   split from vPenguinPolicyPremiums
20140217, LS,   case 20022, AZ & MA
20140226, LS,   Alice's email 20140226: GUG for AirNZ, IAL & youGo = Premium
20140226, LS,   Graham's email 20140227: GUG for NZ MA & AirNZ = Premium
20140228, LS,   UK CM set multiplier to 1.1042 (previously 1.0)
20140303, LS,   Add override (applies to UK only atm)
                Add Gross Up
                bug fix on PEM, add NZE & NZO
20140304, LS,   bug fix, NZ PEM
                Net Adjustment Factor, taken from Penguin.TRIPSGetOutletPercentages
                [Unadjusted Admin Fee] -> [Unadjusted Agency Commission (excl GST)]
20140529, LS,   AAA GUG update, Graham's email verification on 20140528
20140627, LS,   21157, set yougo to be the same as FCT
20140630, LS,   20023, set CR to [Risk Nett] * 1.9431
20141003, LS,   21848, change AAA rate and introduce UW Rate
20141013, LS,   22140, change MA GUG on period >= 2014-07-01 (calendar date)
20141015, LS,   21848, AAA rate should be Risk Net/0.45
20150318, LS,   23618, new helloworld products (NCC, GMC)
20150330, LS,   23790, NZ IAG
20150511, LS,   24350, NZ FC
20150529, LS,   T16768, NZ others (excl FC)
20150713, LS,   T16768, NZ others (excl FC), updated list
20151001, LS,   T19552, NZ GUG revision
20151126, LS,   T20784, P&O and Virgin
20160107, LS,   CMH
20160114, LT,	INC0001781, Added Westpac NZ  (RiskNett / 0.6)
20160224, LT,	Penguin 17.5, Added GUG for Aunt Betty products (ABW, ABD, ABI) in AU Domain
20160224, LS,   correction to ABD & ABW factor, should be 1.948 instead of 1.9348
20160229, LS,   HWI, same factor as NCC (Graham M)
20160309, RL,	Adding US domain section, US FC Liberty Product Code (FTE, FTO)
20160511, RL,	Adding CN domain section, GUG by product code (CND, CNI)
20160602, RL,	Domain(NZ) ProductCode(NZV) GUGFactor(1.88)
20160728, RL,   Add BYOJet and HIF for AU
20160831, RL,   FC Cruiseabout CX-Cruiseabout Cruise for AU (FCC)
20161026, RL,	FC Cruiseabout for NZ (NZC)
20161207, RL,	Ticketek (TTI)
20180601, LL,   UK Malaysia Airlines
*/

as
select
    pt.PolicyTransactionKey,
    prd.[Reported NAP],
    case
        when o.CountryKey = 'AU' then au.[Base Nett]
        when o.CountryKey = 'NZ' then nz.[Base Nett]
        when o.CountryKey = 'UK' then uk.[Base Nett]
        when o.CountryKey = 'US' then us.[Base Nett]
        when o.CountryKey = 'CN' then cn.[Base Nett]
       else [Premium]
    end [Pricing Exposure Measure],
    case
        when o.CountryKey = 'AU' then au.[Base Nett]
        when o.CountryKey = 'NZ' then nz.[Base Nett]
        when o.CountryKey = 'UK' then uk.[Base Nett]
        when o.CountryKey = 'US' then us.[Base Nett]
        when o.CountryKey = 'CN' then cn.[Base Nett]
        else [Premium]
    end - [Premium] [Gross Up],
    case
        when o.CountryKey = 'AU' then au.[Sell Price Override]
        when o.CountryKey = 'NZ' then nz.[Sell Price Override]
        when o.CountryKey = 'UK' then uk.[Sell Price Override]
        when o.CountryKey = 'US' then us.[Sell Price Override]
        when o.CountryKey = 'CN' then cn.[Sell Price Override]
        else 0
    end [Sell Price Override],
    case
        when o.CountryKey = 'AU' then au.[Base Nett]
        when o.CountryKey = 'NZ' then nz.[Base Nett]
        when o.CountryKey = 'UK' then uk.[Base Nett]
        when o.CountryKey = 'US' then us.[Base Nett]
        when o.CountryKey = 'CN' then cn.[Base Nett]
        else [Premium]
    end * UWRate [UW Rate]
from
    penPolicyTransSummary pt
    inner join vPenguinPolicyPremiums pp on
        pp.PolicyTransactionKey = pt.PolicyTransactionKey
    inner join penOutlet o on
        o.OutletStatus = 'Current' and
        o.OutletAlphaKey = pt.OutletAlphaKey
    outer apply
    (
        select
            sum( 
                case
                    when AddOnGroup = 'Medical' then pta.UnAdjGrossPremium
                    else 0
                end 
            ) [Medical Premium]
        from 
            [db-au-cmdwh]..penPolicyTransAddOn pta
        where
            pta.PolicyTransactionKey = pt.PolicyTransactionKey
    ) pta
    outer apply
    (
        select top 1
            (1 - (ppp.Discount) / 100) [Net Adjustment Factor],
            UWRate
        from
            [db-au-cmdwh]..penPolicy p
            inner join [db-au-cmdwh]..penProductPlan ppp on
                ppp.OutletKey = o.OutletKey and
                ppp.ProductId = p.ProductID
            outer apply
            (
                select top 1 
                    Age
                from
                    penPolicyTraveller ptv
                where
                    ptv.PolicyKey = p.PolicyKey and
                    ptv.isPrimary = 1
            ) ptv
            outer apply
            (
                select top 1
                    uwr.UWRate
                from
                    [db-au-cmdwh]..usrUWRate uwr
                where
                    uwr.CountryKey = o.CountryKey and
                    uwr.CompanyKey = o.CompanyKey and
                    uwr.GroupCode = o.GroupCode and
                    uwr.Excess = p.Excess and
                    uwr.Area = p.AreaNumber and
                    uwr.MinimumAge <= ptv.Age and
                    uwr.MaximumAge >= ptv.Age
            ) uwr
        where
            p.PolicyKey = pt.PolicyKey
    ) naf
    cross apply
    (
        select
            o.SuperGroupName [Super Group],
            o.GroupCode [Group Code],
            o.AlphaCode [Alpha],
            pt.IssueDate [Issue Date],
            pt.ProductCode [Product Code],
            pt.CommissionTier [Commission Tier],
            1 / (1 - (pt.VolumeCommission) / 100) [Volume Percentage],
            isnull(pt.GrossAdminFee, 0) [Unadjusted Admin Fee],
            isnull(pta.[Medical Premium], 0) [Unadjusted Medical Premium]
    ) pra
    cross apply
    (
        select
            case
                when o.CountryKey = 'AU' then [NAP]
                when o.CountryKey = 'NZ' then [NAP]
                when o.CountryKey = 'UK' then [Unadjusted NAP]
                when o.CountryKey = 'US' then [NAP]
                when o.CountryKey = 'CN' then [NAP]
               else [Premium]
            end as [Reported NAP]
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
                    when [Group Code] = 'CM' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'FL' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'ST' then [Reported NAP] / 1.1042 
                    when [Group Code] = 'TN' then [Reported NAP] / 1.1042
                    when [Group Code] = 'AZ' then [Premium]
                    when [Group Code] = 'MA' then [Risk Nett]
                    else 0
                end
            end [Base Nett],
            case
                when [Group Code] = 'FL' then [Sell Price (excl GST)] * 0.0566 
                when [Group Code] = 'TN' then [NAP (incl Tax)] * 0.05
                when [Group Code] = 'AT' then [NAP (incl Tax)] * 0.025
                when [Group Code] = 'AF' then [NAP (incl Tax)] * 0.1
                else 0
            end [Sell Price Override]
    ) uk
    cross apply
    (
        select
            case
				when [Product Code] in ('TTI') then [Risk Nett] * 1										--20161207, RL, Ticketek
				when [Product Code] in ('FCC') then [Risk Nett] * 1.6854							    --20160831, RL, FC Cruiseabout CX-Cruiseabout Cruise
				when [Product Code] in ('BJD', 'BJW') then [Risk Nett] * 1.948							--20160728, RL, BYOJet
				when [Product Code] in ('BJI') then [Risk Nett] * 3.5613								--20160728, RL, BYOJet
				when [Product Code] in ('HIF') then [Risk Nett] * 1.9431								--20160728, RL, HIF
				when [Product Code] in ('ABW','ABD') then [Risk Nett] * 1.948							--20160224, LT, Aunt Betty
				when [Product Code] = 'ABI' then [Risk Nett] * 3.5613									--20160224, LT, Aunt Betty
                when [Super Group] in ('Virgin') then [Risk Nett]
                when [Product Code] in ('PNO') then [Risk Nett] * 1.9394
                when [Group Code] = 'MA' and [Issue Date] >= '2014-07-01' then [Risk Nett] * 2.14758274351439
                when [Super Group] in ('AAA') then [Risk Nett]/ 0.45
                when [Super Group] in ('Australia Post', 'Medibank') then
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
                        when [Product Code] = 'CMT' and [Group Code] = 'IU' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) * 1.9394
                        when [Product Code] = 'CMT' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) * 0.9 * 1.9394
                        when [Product Code] = 'CME' and [Group Code] = 'CM' then [Unadjusted Sell Price (excl GST)] * 1.5415
                        when [Product Code] = 'CME' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) * 0.9 * 1.9454
                        when [Product Code] = 'CMB' then [Unadjusted Sell Price (excl GST)]
                        when [Product Code] = 'CMS' then [Unadjusted Sell Price (excl GST)]
                        when [Product Code] = 'STA' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) * 1.808
                        when [Product Code] = 'CMO' and [Group Code] = 'IH' then  ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / 0.7
                        when [Product Code] = 'CMO' and [Risk Nett] = 0 then	
                        case	
                            when [Commission Tier] = 'CO-0' then [Unadjusted Sell Price (excl GST)]
                            else 	
                            case 	
                                when [Volume Percentage] is null then [Unadjusted Sell Price (excl GST)]
                                else ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) * [Volume Percentage]
                            end
                        end
                        else [Risk Nett] / 0.6
                    end
                    /*on or after 2012-11-01*/
                    else	
                    case	
                        when [Group Code] = 'AZ' then [Premium]
                        when [Group Code] = 'YG' then [Risk Nett] * 1.9480
                        when [Group Code] = 'CR' then [Risk Nett] * 1.9431
                        when [Group Code] = 'SO' then [Premium]
                        when [Group Code] = 'SE' then [Premium]
                        when [Group Code] = 'NI' then [Premium]
                        when [Product Code] = 'CMH' then [Risk Nett] * 2.0086
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
                        when [Product Code] = 'NCC' then [Risk Nett] * 1.94310
                        when [Product Code] = 'GMC' then [Risk Nett] * 1.97890
                        when [Product Code] = 'HWI' then [Risk Nett] * 1.94310
                        else [Unadjusted Sell Price (excl GST)]
                    end
                end		
            end [Base Nett],
            0 [Sell Price Override]
    ) au
    cross apply
    (
        select
            case
				when [Product Code] = 'NZV' then [Risk Nett] * 1.88												--20160602, RL, Volo
				when [Super Group] in ('Westpac NZ') then [Risk Nett] / 0.6										--20160114, LT, Westpac NZ 
                when [Super Group] in ('Virgin') then [Risk Nett]
                when [Product Code] in ('PNO') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6 / 1.08
                when 
                    [Group Code] = 'FL' and 
                    [Issue Date] >= '2015-04-01' and 
                    [Product Code] in ('NZE', 'CME', 'NZO', 'CMO') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6 / 1.08
                    

                when [Group Code] not in ('CI', 'AR') and [Product Code] in ('NZE', 'CME', 'NZO', 'CMO') and [Issue Date] >= '2015-05-13' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6 / 1.08

                when [Group Code] = 'AZ' then [Premium]
                when [Group Code] = 'MA' and [Issue Date] >= '2014-07-01' then [Risk Nett] * 1.8096
                when [Group Code] = 'MA' then [Premium]
                
                WHEN [Product Code] = 'NZC' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.4887 / 1.08           --20161026 FC Cruiseabout for NZ (NZC)
				when [Product Code] = 'IAG' then [NAP] * 1.883831
                when [Product Code] = 'CMB' then [Unadjusted Sell Price (excl GST)]
                when [Product Code] = 'CMS' then [Unadjusted Sell Price (excl GST)]
                when [Product Code] = 'CMC' then [Unadjusted Sell Price (excl GST)] 
                when [Product Code] = 'CMT' and isnull([Net Adjustment Factor], 0) = 0 then 
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
                when [Product Code] = 'CMT' then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6 
                when [Product Code] in ('CME', 'NZE') and isnull([Net Adjustment Factor], 0) = 0 then 
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
                when [Product Code] in ('CME', 'NZE') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6 
                when [Product Code] in ('CMO', 'NZO') and isnull([Net Adjustment Factor], 0) = 0 then [Unadjusted Sell Price (excl GST)]
                when [Product Code] in ('CMO', 'NZO') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6
                when [Product Code] in ('CMU', 'CMA') then ([Unadjusted Sell Price (excl GST)] - [Unadjusted Agency Commission (excl GST)]) / [Net Adjustment Factor] / 0.6
                else [Unadjusted Sell Price (excl GST)]
            end [Base Nett],
            0 [Sell Price Override]
    ) nz
    cross apply
    (
        select
            case
				when [Product Code] = 'FTE' then [Risk Nett] * 1 
				when [Product Code] = 'FTO' then [Risk Nett] * 1 
				else [Risk Nett]
            end [Base Nett],
            0 [Sell Price Override]
    ) us
    cross apply
    (
        select
            case
				when [Product Code] = 'CND' then [Risk Nett] * 1 
				when [Product Code] = 'CNI' then [Risk Nett] * 1 
				else [Risk Nett]
            end [Base Nett],
            0 [Sell Price Override]
    ) cn


GO
