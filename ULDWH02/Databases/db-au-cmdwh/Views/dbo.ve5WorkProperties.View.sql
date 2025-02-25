USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[ve5WorkProperties]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   view [dbo].[ve5WorkProperties] as
select 
    Work_ID,
    wp.Company,
    GroupCode AgencyGroup,
    wp.ComplaintDateLodged,
    wp.ComplaintDescriptionEnter,
    wp.ComplaintFOSCasenumber,
    wp.ComplaintFOSDateCompleted,
    wp.ComplaintFOSDateLodged,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintFOSOutcome) ComplaintFOSOutcome,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintFrom) ComplaintFrom,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintOutcome) ComplaintOutcome,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintResolved) ComplaintResolved,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintResponseType) ComplaintResponseType,
    wp.ComplaintsAlphaCode,
    wp.ComplaintsBusinessHours,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintsDepartment) ComplaintsDepartment,
    wp.ComplaintsEmail,
    wp.ComplaintsEMCNumber,
    wp.ComplaintsFirstName,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintsLicensee) ComplaintsLicensee,
    wp.ComplaintsLinkedClaimNo,
    wp.ComplaintsPhone,
    wp.ComplaintsPolicyNumber,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintsPolicyType) ComplaintsPolicyType,
    wp.ComplaintsPostCode,
    wp.ComplaintsState,
    wp.ComplaintsStreet,
    wp.ComplaintsSuburb,
    wp.ComplaintsSurname,
    wp.ComplaintsTitle,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintsUnderwriter) ComplaintsUnderwriter,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ComplaintType) ComplaintType,
    wp.GroupDescription,
    wp.PhoneCallToFrom,
    wp.PhoneCallName,
    wp.PhoneCallReason,
    (select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = ReasonForComplaint) as ReasonForComplaint,
    wp.TotalEstimateValue,
    wp.TotalPaid,
    wp.AddOns,
    wp.SectionChecklist,
    wp.FirstNameClaimant1,
    wp.SurnameClaimant1,
	--Added Claim Type into this view by Saurabh Date on 03/09/2018, based on Brad Pinknney's JIRA request REQ-340
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ClaimType) as ClaimType,
	-- start CHG0035673
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.VulnerableCustomerType) as VulnerableCustomerType,
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.PrimaryDenialReason) as PrimaryDenialReason,
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.SecondaryDenialReason) as SecondaryDenialReason,
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.TertiaryDenialReason) as TertiaryDenialReason,
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.RespondComplaintLodged) as RespondComplaintLodged,
	(select top 1 wi.Name from [db-au-cmdwh].[dbo].e5WorkItems_v3 wi where wi.Domain = wi.Domain and wi.ID = wp.ClaimWithdrawalReason) as ClaimWithdrawalReason
	-- end CHG0035673	
from 
    [db-au-cmdwh].[dbo].e5Work_v3 w
    outer apply
    (
        select 
            max(case when Property_ID = 'Company' then try_convert(nvarchar(255), PropertyValue) else null end) Company,
            max(case when Property_ID = 'GroupCode' then try_convert(nvarchar(255), PropertyValue) else null end) GroupCode,
            max(case when Property_ID = 'ComplaintDateLodged' then try_convert(date, PropertyValue) else null end) ComplaintDateLodged,
            max(case when Property_ID = 'ComplaintDescriptionEnter' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintDescriptionEnter,
            max(case when Property_ID = 'ComplaintFOSCasenumber' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintFOSCasenumber,
            max(case when Property_ID = 'ComplaintFOSDateCompleted' then try_convert(date, PropertyValue) else null end) ComplaintFOSDateCompleted,
            max(case when Property_ID = 'ComplaintFOSDateLodged' then try_convert(date, PropertyValue) else null end) ComplaintFOSDateLodged,
            max(case when Property_ID = 'ComplaintFOSOutcome' then try_convert(int, PropertyValue) else null end) ComplaintFOSOutcome,
            max(case when Property_ID = 'ComplaintFrom' then try_convert(int, PropertyValue) else null end) ComplaintFrom,
            max(case when Property_ID = 'ComplaintOutcome' then try_convert(int, PropertyValue) else null end) ComplaintOutcome,
            max(case when Property_ID = 'ComplaintResolved' then try_convert(int, PropertyValue) else null end) ComplaintResolved,
            max(case when Property_ID = 'ComplaintResponseType' then try_convert(int, PropertyValue) else null end) ComplaintResponseType,
            max(case when Property_ID = 'ComplaintsAlphaCode' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsAlphaCode,
            max(case when Property_ID = 'ComplaintsBusinessHours' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsBusinessHours,
            max(case when Property_ID = 'ComplaintsDepartment' then try_convert(int, PropertyValue) else null end) ComplaintsDepartment,
            max(case when Property_ID = 'ComplaintsEmail' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsEmail,
            max(case when Property_ID = 'ComplaintsEMCNumber' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsEMCNumber,
            max(case when Property_ID = 'ComplaintsFirstName' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsFirstName,
            max(case when Property_ID = 'ComplaintsLicensee' then try_convert(int, PropertyValue) else null end) ComplaintsLicensee,
            max(case when Property_ID = 'ComplaintsLinkedClaimNo' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsLinkedClaimNo,
            max(case when Property_ID = 'ComplaintsPhone' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsPhone,
            max(case when Property_ID = 'ComplaintsPolicyNumber' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsPolicyNumber,
            max(case when Property_ID = 'ComplaintsPolicyType' then try_convert(int, PropertyValue) else null end) ComplaintsPolicyType,
            max(case when Property_ID = 'ComplaintsPostCode' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsPostCode,
            max(case when Property_ID = 'ComplaintsState' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsState,
            max(case when Property_ID = 'ComplaintsStreet' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsStreet,
            max(case when Property_ID = 'ComplaintsSuburb' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsSuburb,
            max(case when Property_ID = 'ComplaintsSurname' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsSurname,
            max(case when Property_ID = 'ComplaintsTitle' then try_convert(nvarchar(255), PropertyValue) else null end) ComplaintsTitle,
            max(case when Property_ID = 'ComplaintsUnderwriter' then try_convert(int, PropertyValue) else null end) ComplaintsUnderwriter,
            max(case when Property_ID = 'ComplaintType' then try_convert(int, PropertyValue) else null end) ComplaintType,
            max(case when Property_ID = 'GroupDescription' then try_convert(nvarchar(255), PropertyValue) else null end) GroupDescription,
            max(case when Property_ID = 'PhoneCallToFrom' then try_convert(nvarchar(255), PropertyValue) else null end) PhoneCallToFrom,
            max(case when Property_ID = 'PhoneCallName' then try_convert(nvarchar(255), PropertyValue) else null end) PhoneCallName,
            max(case when Property_ID = 'PhoneCallReason' then try_convert(nvarchar(255), PropertyValue) else null end) PhoneCallReason,
            max(case when Property_ID = 'ReasonForComplaint' then try_convert(int, PropertyValue) else null end) ReasonForComplaint,
            max(case when Property_ID = 'TotalEstimateValue' then try_convert(money, PropertyValue) else null end) TotalEstimateValue,
            max(case when Property_ID = 'TotalPaid' then try_convert(money, PropertyValue) else null end) TotalPaid,
            max(case when Property_ID = 'AddOns' then try_convert(nvarchar(255), PropertyValue) else null end) AddOns,
            max(case when Property_ID = 'SectionChecklist' then try_convert(nvarchar(255), PropertyValue) else null end) SectionChecklist,
            max(case when Property_ID = 'FirstNameClaimant1' then try_convert(nvarchar(255), PropertyValue) else null end) FirstNameClaimant1,
            max(case when Property_ID = 'SurnameClaimant1' then try_convert(nvarchar(255), PropertyValue) else null end) SurnameClaimant1,
			--Added Claim Type into this view by Saurabh Date on 03/09/2018, based on Brad Pinknney's JIRA request REQ-340
			max(case when Property_ID = 'ClaimType' then try_convert(nvarchar(255), PropertyValue) else null end) ClaimType,
			-- start CHG0035673
			max(case when Property_ID = 'VulnerableCustomerType' then try_convert(int, PropertyValue) else null end) VulnerableCustomerType,
			max(case when Property_ID = 'PrimaryDenialReason' then try_convert(int, PropertyValue) else null end) PrimaryDenialReason,
			max(case when Property_ID = 'SecondayDenialReason' then try_convert(int, PropertyValue) else null end) SecondaryDenialReason,
			max(case when Property_ID = 'TertiaryDenialReason' then try_convert(int, PropertyValue) else null end) TertiaryDenialReason,
			max(case when Property_ID = 'RespondComplaintLodged' then try_convert(int, PropertyValue) else null end) RespondComplaintLodged,
			max(case when Property_ID = 'ClaimWithdrawalReason' then try_convert(int, PropertyValue) else null end) ClaimWithdrawalReason
        --- end CHG0035673
		from
            [db-au-cmdwh].[dbo].e5WorkProperties_v3 wp
        where
            wp.Work_ID = w.Work_ID and
            wp.Property_ID in
            (
                'Company',
                'GroupCode',
                'ComplaintDateLodged',
                'ComplaintDescriptionEnter',
                'ComplaintFOSCasenumber',
                'ComplaintFOSDateCompleted',
                'ComplaintFOSDateLodged',
                'ComplaintFOSOutcome',
                'ComplaintFrom',
                'ComplaintOutcome',
                'ComplaintResolved',
                'ComplaintResponseType',
                'ComplaintsAlphaCode',
                'ComplaintsBusinessHours',
                'ComplaintsDepartment',
                'ComplaintsEmail',
                'ComplaintsEMCNumber',
                'ComplaintsFirstName',
                'ComplaintsLicensee',
                'ComplaintsLinkedClaimNo',
                'ComplaintsPhone',
                'ComplaintsPolicyNumber',
                'ComplaintsPolicyType',
                'ComplaintsPostCode',
                'ComplaintsState',
                'ComplaintsStreet',
                'ComplaintsSuburb',
                'ComplaintsSurname',
                'ComplaintsTitle',
                'ComplaintsUnderwriter',
                'ComplaintType',
                'GroupDescription',
                'PhoneCallToFrom',
                'PhoneCallName',
                'PhoneCallReason',
                'ReasonForComplaint',
                'TotalEstimateValue',
                'TotalPaid',
                'AddOns',
                'SectionChecklist',
                'FirstNameClaimant1',
                'SurnameClaimant1',
				--Added Claim Type into this view by Saurabh Date on 03/09/2018, based on Brad Pinknney's JIRA request REQ-340
				'ClaimType',
				-- start CHG0035673
				'VulnerableCustomerType',
				'PrimaryDenialReason',
				'SecondayDenialReason',
				'TertiaryDenialReason',
				'RespondComplaintLodged',
				'ClaimWithdrawalReason'
				--end CHG0035673
            )
    ) wp
GO
