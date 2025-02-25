USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vMedicalAssistanceRole]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vMedicalAssistanceRole]
as
select 
    u.UserKey,
    ad.UserName,
    ad.DisplayName,
    ad.Company,
    ad.Department,
    ad.JobTitle,
    cast(
        case
            when u.UserID = 'leonarduss' then N'屠龙者'
            when ad.JobTitle in 
                (
                    'Network Associate', 
                    'Telephony Support Specialist',
                    'Service Desk Analyst',
                    'Casual Information Services Intern'
                ) then 'IT'
            when 
                ad.JobTitle in 
                (
                    'Accounts Billing Officer',
                    'Accounts Processing Officer',
                    'Cost Containment Officer',
                    'Finance Business Partner',
                    'Accounts Receivable Officer',
                    'Accounts Payable Officer',
                    'Accounts Officer'
                )
            then 'Accounts'
            when 
                ad.JobTitle in 
                (
                    'Office Administrator',
                    'Office Manager',
                    'Receptionist Administrator',
                    'Admin Support',
                    'Quality, Risk & Audit Specialist',
                    'Customer Service Representative'
                ) or
                ad.Department in
                (
                    'Customer Care - Administration Assistant'
                )
            then 'Admin'
            when ad.JobTitle = 'EAP Centre Customer Service Team' then 'EAP Customer Service'
            when 
                ad.JobTitle in 
                (
                    'Assistance Coordinator',
                    'Case Manager',
                    'Concierge Leader',
                    'Key Client Specialist',
                    'Online Communication Case Manager',
                    'Senior Case Manager',
                    'Customer Care - Assistance Coordinator',
                    'Medical Assistance - Case Manager',
                    'Claims Liaison Officer',
                    'EMC Zurich CSR',
                    'Learning & Development Consultant - Assistance',
                    'Senior Systems Engineer',
                    'Group Operations Learning & Development Manager',
                    'Case Manager - Malaysia',
                    'Casual Case Manager',
                    'Customer Care - Case Manager'
                ) or
                ad.Department in
                (
                    'Customer Care - Assistance Coordinator',
                    'Medical Assistance',
                    'Customer Care - Assistance Co-ordinator',
                    'Med Assist Sydney'
                )
            then 'Case Manager'
            when 
                ad.JobTitle in 
                (
                    'Claims Officer',
                    'Insurance Specialist',
                    'Investigation Officer',
                    'SME',
                    'Claims SME',
                    'Assistant Claims Manager',
                    'Claims Manager',
                    'External Claims Officer',
                    'Team Leader-Insurance'
                )
            then 'Insurance Specialist'
            when 
                ad.JobTitle in 
                (
                    'Medical Officer',
                    'Clinical Manager Trauma'
                )
            then 'Medical Consultant'
            when 
                ad.JobTitle in 
                (
                    'Registered Nurse',
                    'Senior Registered Nurse',
                    'Education Clinical Nurse Specialist',
                    'Medical Assessor',
                    'EMC Registered Nurse'
                ) or
                ad.Department in
                (
                    'Customer Care - Registered Nurse'
                )
            then 'Registered Nurse'
            when 
                ad.JobTitle like 'Operations Supervisor%' or
                ad.JobTitle like 'Operations Manager%' or
                ad.JobTitle = 'Head of Operations'
            then 'Ops Supervisor'
            when 
                ad.JobTitle in 
                (
                    'Client Services Leader',
                    'Client Services Leader.',
                    'Night Shift Leader',
                    'Team Leader',
                    'National Account Manager',
                    'Medical Case Manager',
                    'Claims Team Leader',
                    'Claims Liaison Team Leader',
                    'Operations Team Leader',
                    'Team Leader-Assistance'
                )
            then 'Team Leader'
            when 
                ad.JobTitle in 
                (
                    'Travel Agent',
                    'Travel Agent Team Leader'
                )
            then 'Travel Agent'
            else 'Other'
        end 
        as nvarchar(max)
    ) MedicalAssistanceRole,
    ad.isActive
from
    cbUser u
    right outer join usrLDAP ad on
        ad.UserName = u.UserID







GO
