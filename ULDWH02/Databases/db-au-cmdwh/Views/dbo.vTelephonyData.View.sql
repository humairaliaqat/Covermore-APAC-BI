USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyData]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vTelephonyData] 
as

/****************************************************************************************************
  Name:          vTelephonyData
  Author:        LL
  Date Created:  20190328
  Description:   This view captures telephony call data
  
  Change History:	20190328 - LL - created, this is to replace vTelephonyCallData, using cisCalls
					20190409 - DM - Added Team for Outgoing calls
****************************************************************************************************/

select --top 100
    cd.SessionID,
    cd.SessionSequence,
    cd.ContactType,
    cd.ContactDisposition,
    cd.DispositionReason,

    convert(date, cd.CallStartDateTime) CallDate,
    cd.CallStartDateTime,
    cd.CallEndDateTime,
    cd.CallResult,

    coalesce(cd.Agent,cd.DestinationAgent,cd.OriginatorAgent) AgentName,
    cd.SupervisorFlag,
    coalesce(ca.TeamName,cd.Team) as Team,
    o.OrganisationName,
    ApplicationName, 
    case
        when cd.CallStartDateTime < '2016-08-01' then cm.Company
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
        when CSQName = 'CC_CBA_Group' AND cd.DestinationNumber IN ('5646','5679','5680','5641','5060') THEN 'Commonwealth Bank'
        when CSQName = 'CC_CBA_Group' AND cd.DestinationNumber IN ('5624','5632','5633','5615','5061') THEN 'BankWest'
        when ApplicationName = 'AUCustomerServiceCBA' THEN 'Commonwealth Bank'
        when ApplicationName = 'AUMedicalAssistanceCBA' THEN 'Commonwealth Bank'
        when ApplicationName = 'AUCustomerServiceBankwest' THEN 'BankWest'
        else 'Other'
    end Company,

    --origin
    cd.OriginatorType,
    cd.OriginatorAgent,
    cd.OriginatorExt,
    cd.OriginatorNumber,

    --destination
    cd.DestinationType,
    cd.DestinationAgent,
    cd.DestinationExt,
    cd.DestinationNumber,

    cd.TargetType,
    cd.GatewayNumber,
    cd.DialedNumber,

    --queue
    cd.CSQName,
    cd.QueueHandled,
    cd.QueueAbandoned,
    cd.ServiceLevelPercentage,
    cd.MetServiceLevel,

    1 CallsPresented,
    case
        when 
            cd.TargetType = 'CSQ' and
            cd.RingTime >= 0 and 
            cd.TalkTime = 0 
        then 1
        else 0
    end RNA,
    cd.Transfer,
    cd.Redirect,
    cd.Conference,

    cd.QueueTime,
    cd.RingTime,
    cd.TalkTime,
    cd.HoldTime,
    cd.WorkTime,
    cd.WrapUpTime,

    VarCSQName,
    VarEXT,
    VarClassification,
    VarIVROption,
    VarIVRReference,
    VarWrapUp,
    WrapUpData,
    AccountNumber,
    CallerEnteredDigits

from
    cisCalls cd 
    cross apply
    (
        select
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
                when charindex('AU_CS_CBA_',CSQName) > 0 THEN 'Commonwealth Bank'
                when charindex('AU_CBA_', CSQName) > 0 THEN 'Commonwealth Bank'
                when charindex('CC_CBA_', CSQName) > 0 THEN 'Commonwealth Bank'
                when charindex('AU_CS_BW_',CSQName) > 0 THEN 'BankWest'
                when charindex('AU_BW_', CSQName) > 0 THEN 'BankWest'
                else 'Other'
            end Company
    ) cm
    outer apply
    (
        select top 1
            vt.EmployeeKey,
            vt.OrganisationKey
        from
            [db-au-cmdwh]..verTeam vt
        where
            vt.UserName = cd.LoginID and
            vt.EndDate >= convert(date, cd.CallStartDateTime)
        order by
            vt.EndDate desc
    ) vt
	outer apply --mod: 20190409
    (
        select top 1
            ca.AgentLogin,
            ca.TeamName
        from
            [db-au-cmdwh]..cisAgent ca
        where
            cd.[OriginatorID] = ca.AgentID
    ) ca
    left join verOrganisation o on
        o.OrganisationKey = vt.OrganisationKey

GO
