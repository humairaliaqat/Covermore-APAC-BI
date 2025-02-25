USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vclmBenefitCategory]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vclmBenefitCategory] as
select 
    BenefitSectionKey,
    BenefitDesc,
    BenefitCategory,
    case
        when BenefitCategory is null then 'Unknown'
        when BenefitCategory like '%medical%' then 'Medical'
        when BenefitCategory like '%cancel%' then 'Cancellation'
        when BenefitCategory like 'luggage%' then 'Luggage'
        when BenefitCategory like '%additional%' then 'Additional Expenses'
        else 'Other'
    end ActuarialBenefitGroup,
    case
        when BenefitCategory is null then 'Unknown'
        when BenefitCategory like '%medical%' then 'Medical'
        when BenefitCategory like '%cancel%' then 'Cancellation'
        when BenefitCategory like 'luggage%' then 'Luggage'
        else 'Other'
    end OperationalBenefitGroup
from
    clmBenefit cb with(nolock)
    cross apply
    (
        select
            case
                /* UK */
                when cb.CountryKey = 'UK' and cb.CommonCategory in ('ACC') then 'Personal Accident and Death'
                when cb.CountryKey = 'UK' and cb.CommonCategory in ('HOSP') then 'Hospital Benefit'
                when cb.CountryKey = 'UK' and cb.CommonCategory in ('LEGAL') then 'Legal Expenses'
                when cb.CommonCategory in ('ABAN') then 'Abandoning Your Trip'
                when cb.CommonCategory in ('AVAL') then 'Avalanche Cover'
                when cb.CommonCategory in ('BMON') then 'Business Money'
                when cb.CommonCategory in ('BUSDE', 'BUSS') then 'Delayed Business Equipment'
                when cb.CommonCategory in ('BUSE') then 'Business Equipment'
                when cb.CommonCategory in ('CEQU') then 'Computer Equipment'
                when cb.CommonCategory in ('EXAM') then 'Exam Resit'
                when cb.CommonCategory in ('GOLF') then 'Golf Equipment'
                when cb.CommonCategory in ('HOME') then 'Cancellation'
                when cb.CommonCategory in ('MISDEP') then 'Missed Departure'
                when cb.CommonCategory in ('MUG') then 'Mugging'
                when cb.CommonCategory in ('PISTE') then 'Piste Closure'
                when cb.CommonCategory in ('SKI') then 'Personal Ski Equipment And Ski Hire'
                when cb.CommonCategory in ('SLOAN') then 'Student Loan'

                /* AU & NZ */
                when cb.CommonCategory in ('AC', 'ACC', 'CC', 'CDW', 'CURT', 'ETWC', 'EXP', 'LEGAL', 'LOD', 'NONMEDADD', 'MEDADD') then 'Additional Expenses'
                when cb.CommonCategory in ('CANX') then 'Cancellation'
                when cb.CommonCategory in ('HOSP') then 'Cash In Hospital'
                when cb.CommonCategory in ('DEATH', 'DISAB') then 'Death or Disability'
                when cb.CommonCategory in ('DELUG') then 'Delayed Luggage'
                when cb.CommonCategory in ('HIJACK') then 'Hijacking'
                when cb.CommonCategory in ('KIDNAP') then 'Kidnap and Ransom'
                when cb.CommonCategory in ('LOI') then 'Loss of Income'
                when cb.CommonCategory in ('LUGG', 'LUGP', 'TDC') then 'Luggage and Travel Documents'
                when cb.CommonCategory in ('MED') then 'Medical and Dental'
                when cb.CommonCategory in ('MONEY', 'THEFT') then 'Money'
                when cb.CommonCategory in ('LIAB') then 'Personal Liability'
                when cb.CommonCategory in ('CAR') then 'Rental Vehicle'
                when cb.CommonCategory in ('RES') then 'Resumption of Journey'
                when cb.CommonCategory in ('SEVT') then 'Special Events'
                when cb.CommonCategory in ('MCON', 'TDEL') then 'Travel Delay'
                when cb.CommonCategory in ('INS', 'INSOLVE') then 'Travel Services Provider Insolvency'
                when cb.CommonCategory in ('REMP') then 'Alternative Staff'

                when cb.BenefitCode in ('AC', 'ACC', 'CC', 'CDW', 'CURT', 'ETWC', 'EXP', 'LEGAL', 'LOD', 'NONMEDADD', 'MEDADD') then 'Additional Expenses'
                when cb.BenefitCode in ('CANX') then 'Cancellation'
                when cb.BenefitCode in ('HOSP') then 'Cash In Hospital'
                when cb.BenefitCode in ('DEATH', 'DISAB') then 'Death or Disability'
                when cb.BenefitCode in ('DELUG') then 'Delayed Luggage'
                when cb.BenefitCode in ('HIJACK') then 'Hijacking'
                when cb.BenefitCode in ('KIDNAP') then 'Kidnap and Ransom'
                when cb.BenefitCode in ('LOI') then 'Loss of Income'
                when cb.BenefitCode in ('LUGG', 'LUGP', 'TDC') then 'Luggage and Travel Documents'
                when cb.BenefitCode in ('MED') then 'Medical and Dental'
                when cb.BenefitCode in ('MONEY', 'THEFT') then 'Money'
                when cb.BenefitCode in ('LIAB') then 'Personal Liability'
                when cb.BenefitCode in ('CAR') then 'Rental Vehicle'
                when cb.BenefitCode in ('RES') then 'Resumption of Journey'
                when cb.BenefitCode in ('SEVT') then 'Special Events'
                when cb.BenefitCode in ('MCON', 'TDEL') then 'Travel Delay'
                when cb.BenefitCode in ('INS', 'INSOLVE') then 'Travel Services Provider Insolvency'
                when cb.BenefitCode in ('REMP') then 'Alternative Staff'

                when ltrim(rtrim(isnull(cb.CommonCategory, ''))) = '' then
                    case
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Additional Expenses') then 'Additional Expenses'
                        when rtrim(ltrim(cb.BenefitDesc)) like '%cancel%' then 'Cancellation'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Cash in Hospital', 'Hospital Incidentals') then 'Cash In Hospital'
                        when
                            rtrim(ltrim(cb.BenefitDesc)) like '%death%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%disability%'
                        then 'Death or Disability'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Airfare Compensation', 'Airfare Reimbursement') then 'Airfare'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Delayed Luggage Allowance') then 'Delayed Luggage'
                        when rtrim(ltrim(cb.BenefitDesc)) like '%hijack%' then 'Hijacking'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Kidnap and Ransom') then 'Kidnap and Ransom'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Loss of Income') then 'Loss of Income'
                        when
                            rtrim(ltrim(cb.BenefitDesc)) like 'luggage%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%docs%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%document%'
                        then 'Luggage and Travel Documents'
                        when
                            rtrim(ltrim(cb.BenefitDesc)) like '%medical%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%dental%'
                        then 'Medical and Dental'
                        when
                            rtrim(ltrim(cb.BenefitDesc)) like '%cash%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%money%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%theft%'
                        then 'Money'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Legal Expenses', 'Personal Liability') then 'Personal Liability'
                        when
                            rtrim(ltrim(cb.BenefitDesc)) like '%rental car%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%rental vehicle%' or
                            rtrim(ltrim(cb.BenefitDesc)) like '%hire car%'
                        then 'Rental Vehicle'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Resumption Of Journey', 'Alternative Transport Expenses', 'Continuation of Travel') then 'Resumption of Journey'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Special Events') then 'Special Events'
                        when rtrim(ltrim(cb.BenefitDesc)) like 'Travel Delay%' then 'Travel Delay'
                        when rtrim(ltrim(cb.BenefitDesc)) like '%insolvency%' then 'Travel Services Provider Insolvency'
                        when rtrim(ltrim(cb.BenefitDesc)) in ('Alternative Staff') then 'Alternative Staff'
                        else 'Miscellaneous Benefits'
                    end
                else 'Miscellaneous Benefits'
            end BenefitCategory
    ) bc




GO
