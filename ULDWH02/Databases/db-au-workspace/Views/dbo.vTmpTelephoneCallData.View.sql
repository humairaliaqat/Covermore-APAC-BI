USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vTmpTelephoneCallData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vTmpTelephoneCallData]
as

/****************************************************************************************************/
--  Name:          vTelephonyCallData
--  Author:        Leonardus Setyabudi
--  Date Created:  20150101
--  Description:   This view captures telephony call data in real time
--  
--  Change History: 20150101 - LS - Created
--					20150527 - LT - Amended Company case statement for Australia Post. It was including
--									DTC CSQ name (eg DTC_EAP_Centre, DTC_EAP_Rebook)
--					20151009 - LT - F#26668 Amended Company case statement to include helloworld and P&O
--					20151030 - LT - Added Virgin to CSQName
--                  20160823 - LL - routing updates
--
/****************************************************************************************************/

with cte_calls
as
(
    select 
        case
            when e.EmployeeName = 'Unknown' and isnull(a.AgentName, '') <> '' then a.AgentName
            else e.EmployeeName
        end AgentName,
        o.OrganisationName Team, 
        case
            when cd.CallStartDateTime < '2016-08-01' then cs.Company
            when ApplicationName = 'AUClaimsInternal' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceAAA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'AUCustomerServiceAP' then 'Australia Post'
            when ApplicationName = 'AUCustomerServiceCM' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceHIF' then 'HIF'
            when ApplicationName = 'AUCustomerServiceHW' then 'helloworld'
            when ApplicationName = 'AUCustomerServiceIAL' then 'IAL'
            when ApplicationName = 'AUCustomerServiceMB' then 'Medibank'
            when ApplicationName = 'AUCustomerServicePO' then 'P&O'
            when ApplicationName = 'AUCustomerServicePrincess' then 'Princess'
            when ApplicationName = 'AUCustomerServiceRAA_SA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRAC_WA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACQ_QLD' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACV_VIC' then 'AAA'
            when ApplicationName = 'AUCustomerServiceTele_Claims' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceTele_Sales' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceVA' then 'Virgin'
            when ApplicationName = 'AUDTC' then 'Employee Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceInternal' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceWestpacNZ' then 'Medical Assistance'
            when ApplicationName = 'CNMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'IS_Service_Desk' then 'CoverMore Global Service'
            when ApplicationName = 'MYMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'NZCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'NZCustomerServiceCM' then 'CoverMore NZ'
            when ApplicationName = 'NZCustomerServiceIAG_AMI' then 'IAG'
            when ApplicationName = 'NZCustomerServiceIAG_STATE' then 'IAG'
            when ApplicationName = 'NZCustomerServicePO' then 'P&O'
            when ApplicationName = 'NZCustomerServiceWestpac' then 'Westpac'
            else 'Other'
        end Company,
        cs.CSQName,
        convert(date, cd.CallStartDateTime) CallDate,
        cd.CallStartDateTime,
        cd.CallEndDateTime,
        cd.Disposition,
        cd.OriginatorNumber,
        cd.DestinationNumber,
        cd.CalledNumber,
        cd.OrigCalledNumber,
        cd.CallsPresented,
        cd.CallsHandled,
        cd.CallsAbandoned,
        cd.RingTime,
        cd.TalkTime,
        cd.HoldTime,
        cd.WorkTime,
        cd.WrapUpTime,
        cd.QueueTime,
        cd.MetServiceLevel,
        cd.Transfer,
        cd.Redirect,
        cd.Conference,
        0 RNA
    from
        [db-au-cmdwh].dbo.cisCallData cd with(index(idx_cisCallData_CallTimes))
        cross apply
        (
            select top 1
                case when CSQName in ('AU_CS_120CM_Sales','AU_CS_7030_Sales','AU_CS_120_Sales','AU_CS_LOWVOL_Sales') then 'Telephony Sales'
					 else CSQName
				end as CSQName,
                case
		            when charindex('IS_Service_Desk', CSQName) > 0 then 'CoverMore Global Service'
                    when charindex('CS_TIP_', CSQName) > 0 then 'TIP'
                    when charindex('CC_', CSQName) > 0 then 'Medical Assistance'
                    when charindex('Medical_Assistance', CSQName) > 0 then 'Medical Assistance'
                    when charindex('EMC_CM', CSQName) > 0 then 'Medical Assistance'
                    when charindex('MA_', CSQName) > 0 then 'Medical Assistance'
                    when charindex('DTC_', CSQName) > 0 then 'Employee Assistance'
                    when charindex('CS_AP_', CSQName) > 0 then 'Australia Post'
                    when charindex('Claims_AP', CSQName) > 0 then 'Australia Post'
                    when charindex('EMC_AP', CSQName) > 0 then 'Australia Post'
                    when charindex('CS_MB_', CSQName) > 0 then 'Medibank'
                    when charindex('Claims_MB', CSQName) > 0 then 'Medibank'
                    when charindex('EMC_MB', CSQName) > 0 then 'Medibank'
                    when charindex('CS_AirNZ_', CSQName) > 0 then 'Air New Zealand'
                    when charindex('CS_IAG_', CSQName) > 0 then 'IAG'
                    when charindex('CS_PO_', CSQName) > 0 then 'P&O'
                    when charindex('CS_AAA_', CSQName) > 0 then 'AAA'
		            when charindex('CS_VA_', CSQName) > 0 then 'Virgin'
                    when charindex('CS_IAL_', CSQName) > 0 then 'IAL'  
		            when charindex('CS_HW_', CSQName) > 0 then 'helloworld'		
                    when charindex('CS_YG_', CSQName) > 0 then 'YouGo'
                    when charindex('CS_ZU_', CSQName) > 0 then 'Zurich'
                    when charindex('NZ_', CSQName) > 0 then 'CoverMore NZ'
                    when charindex('CS_CM_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_TELE_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_TAGT_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_CUST_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_AB_', CSQName) > 0 then 'CoverMore'
                    when charindex('Claims_CM', CSQName) > 0 then 'CoverMore'
                    when charindex('AU_CS_', CSQName) > 0 then 'CoverMore'
                    when charindex('AR_CM', CSQName) > 0 then 'CoverMore'
                    when charindex('Cover-More Lobby Reception', CSQName) > 0 then 'CoverMore'
                    when charindex('SS_', CSQName) > 0 then 'CoverMore'
                    when charindex('Tele_Claims', CSQName) > 0 then 'CoverMore'
                    when charindex('MY_', CSQName) > 0 then 'CoverMore MY'
                    else 'Other'
                end Company
            from
                [db-au-cmdwh].dbo.cisCSQ cs
            where
                cs.CSQKey = cd.CSQKey
        ) cs
        inner join [db-au-cmdwh].dbo.verEmployee e on
            e.EmployeeKey = cd.EmployeeKey
        inner join [db-au-cmdwh].dbo.verOrganisation o on
            o.OrganisationKey = cd.OrganisationKey
        outer apply
        (
            select top 1 
                AgentName
            from
                [db-au-cmdwh].dbo.cisAgent a
            where
                a.AgentKey = cd.AgentKey
        ) a

    union all

    select 
        case
            when e.EmployeeName = 'Unknown' and isnull(a.AgentName, '') <> '' then a.AgentName
            else e.EmployeeName
        end AgentName,
        o.OrganisationName Team, 
        case
            when cd.CallStartDateTime < '2016-08-01' then cs.Company
            when ApplicationName = 'AUClaimsInternal' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceAAA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'AUCustomerServiceAP' then 'Australia Post'
            when ApplicationName = 'AUCustomerServiceCM' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceHIF' then 'HIF'
            when ApplicationName = 'AUCustomerServiceHW' then 'helloworld'
            when ApplicationName = 'AUCustomerServiceIAL' then 'IAL'
            when ApplicationName = 'AUCustomerServiceMB' then 'Medibank'
            when ApplicationName = 'AUCustomerServicePO' then 'P&O'
            when ApplicationName = 'AUCustomerServicePrincess' then 'Princess'
            when ApplicationName = 'AUCustomerServiceRAA_SA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRAC_WA' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACQ_QLD' then 'AAA'
            when ApplicationName = 'AUCustomerServiceRACV_VIC' then 'AAA'
            when ApplicationName = 'AUCustomerServiceTele_Claims' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceTele_Sales' then 'CoverMore'
            when ApplicationName = 'AUCustomerServiceVA' then 'Virgin'
            when ApplicationName = 'AUDTC' then 'Employee Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceACE02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceInternal' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage01' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceTriage02' then 'Medical Assistance'
            when ApplicationName = 'AUMedicalAssistanceWestpacNZ' then 'Medical Assistance'
            when ApplicationName = 'CNMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'IS_Service_Desk' then 'CoverMore Global Service'
            when ApplicationName = 'MYMedicalAssistance' then 'Medical Assistance'
            when ApplicationName = 'NZCustomerServiceANZ' then 'Air New Zealand'
            when ApplicationName = 'NZCustomerServiceCM' then 'CoverMore NZ'
            when ApplicationName = 'NZCustomerServiceIAG_AMI' then 'IAG'
            when ApplicationName = 'NZCustomerServiceIAG_STATE' then 'IAG'
            when ApplicationName = 'NZCustomerServicePO' then 'P&O'
            when ApplicationName = 'NZCustomerServiceWestpac' then 'Westpac'
            else 'Other'
        end Company,
        cs.CSQName,
        convert(date, cd.CallStartDateTime) CallDate,
        cd.CallStartDateTime,
        cd.CallEndDateTime,
        cd.Disposition,
        cd.OriginatorNumber,
        cd.DestinationNumber,
        cd.CalledNumber,
        cd.OrigCalledNumber,
        0 CallsPresented,
        0 CallsHandled,
        0 CallsAbandoned,
        0 RingTime,
        0 TalkTime,
        0 HoldTime,
        0 WorkTime,
        0 WrapUpTime,
        0 QueueTime,
        0 MetServiceLevel,
        0 Transfer,
        0 Redirect,
        0 Conference,
        cd.RingNoAnswer RNA
    from
        [db-au-cmdwh].dbo.cisRNA cd with(index(idx_cisRNA_CallTimes))
        cross apply
        (
            select top 1
                case when CSQName in ('AU_CS_120CM_Sales','AU_CS_7030_Sales','AU_CS_120_Sales','AU_CS_LOWVOL_Sales') then 'Telephony Sales'
					 else CSQName
				end as CSQName,
                case
		            when charindex('IS_Service_Desk', CSQName) > 0 then 'CoverMore Global Service'
                    when charindex('CS_TIP_', CSQName) > 0 then 'TIP'
                    when charindex('CC_', CSQName) > 0 then 'Medical Assistance'
                    when charindex('Medical_Assistance', CSQName) > 0 then 'Medical Assistance'
                    when charindex('EMC_CM', CSQName) > 0 then 'Medical Assistance'
                    when charindex('MA_', CSQName) > 0 then 'Medical Assistance'
                    when charindex('DTC_', CSQName) > 0 then 'Employee Assistance'
                    when charindex('CS_AP_', CSQName) > 0 then 'Australia Post'
                    when charindex('Claims_AP', CSQName) > 0 then 'Australia Post'
                    when charindex('EMC_AP', CSQName) > 0 then 'Australia Post'
                    when charindex('CS_MB_', CSQName) > 0 then 'Medibank'
                    when charindex('Claims_MB', CSQName) > 0 then 'Medibank'
                    when charindex('EMC_MB', CSQName) > 0 then 'Medibank'
                    when charindex('CS_AirNZ_', CSQName) > 0 then 'Air New Zealand'
                    when charindex('CS_IAG_', CSQName) > 0 then 'IAG'
                    when charindex('CS_PO_', CSQName) > 0 then 'P&O'
                    when charindex('CS_AAA_', CSQName) > 0 then 'AAA'
		            when charindex('CS_VA_', CSQName) > 0 then 'Virgin'
                    when charindex('CS_IAL_', CSQName) > 0 then 'IAL'  
		            when charindex('CS_HW_', CSQName) > 0 then 'helloworld'		
                    when charindex('CS_YG_', CSQName) > 0 then 'YouGo'
                    when charindex('CS_ZU_', CSQName) > 0 then 'Zurich'
                    when charindex('NZ_', CSQName) > 0 then 'CoverMore NZ'
                    when charindex('CS_CM_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_TELE_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_TAGT_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_CUST_', CSQName) > 0 then 'CoverMore'
                    when charindex('CS_AB_', CSQName) > 0 then 'CoverMore'
                    when charindex('Claims_CM', CSQName) > 0 then 'CoverMore'
                    when charindex('AU_CS_', CSQName) > 0 then 'CoverMore'
                    when charindex('AR_CM', CSQName) > 0 then 'CoverMore'
                    when charindex('Cover-More Lobby Reception', CSQName) > 0 then 'CoverMore'
                    when charindex('SS_', CSQName) > 0 then 'CoverMore'
                    when charindex('Tele_Claims', CSQName) > 0 then 'CoverMore'
                    when charindex('MY_', CSQName) > 0 then 'CoverMore MY'
                    else 'Other'
                end Company
            from
                [db-au-cmdwh].dbo.cisCSQ cs
            where
                cs.CSQKey = cd.CSQKey
        ) cs
        inner join [db-au-cmdwh].dbo.verEmployee e on
            e.EmployeeKey = cd.EmployeeKey
        inner join [db-au-cmdwh].dbo.verOrganisation o on
            o.OrganisationKey = cd.OrganisationKey
        outer apply
        (
            select top 1 
                AgentName
            from
                [db-au-cmdwh].dbo.cisAgent a
            where
                a.AgentKey = cd.AgentKey
        ) a
)
select 
    *,
    case 
		when Company in
        (
            'CoverMore Global Service',
            'TIP',
            'Medical Assistance',
            'Employee Assistance',
            'Air New Zealand',
            'IAG',
            'P&O',
            'AAA',
            'CoverMore NZ',
            'CoverMore MY',
            'Virgin',
            'Princess',
            'Westpac',
            'HIF',
            'IAL',
            'Other'
        --) then 0
        ) then 1
        else 1
    end IncludeInCSDashboard
from
    cte_calls












GO
