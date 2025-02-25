USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[clmPayeeSegment]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[clmPayeeSegment]
as
select 
    cn.NameKey,    
    Segment
from
    [db-au-cmdwh]..clmName cn
    cross apply
    (
        select
            isnull(Firstname, '') + ' ' +
            isnull(Surname, '') +  ' ' +
            isnull(AccountName, '') +  ' ' +
            isnull(BusinessName, '') +  ' ' +
            isnull(AddressStreet, '') Names
    ) n
    cross apply
    (
        select
            case
                when cn.isThirdParty = 0 and isnull(cn.Firstname, '') <> '' then 'Individual'
                when Names like '%gmmi%' then 'Cost Containment'
                when Names like '%g e m%' then 'Cost Containment'
                when Names like '%gem%' then 'Cost Containment'
                when Names like '%cost contain%' then 'Cost Containment'
                when Names like '%customer%care%' then 'Assistance Service'
                when Names like '%assistance%' then 'Assistance Service'
                when Names like '%AA International%' then 'Assistance Service'
                when Names like '%medical assist%' then 'Assistance Service'
                when Names like '%japan assist%' then 'Assistance Service'
                when Names like '%filo diretto%' then 'Assistance Service'
                when Names like '%euro%cent%' then 'Assistance Service'
                when Names like '%hospital%' then 'Medical Service'
                when Names like '%health%' then 'Medical Service'
                when Names like '%medical%' then 'Medical Service'
                when Names like '%clinic%' then 'Medical Service'
                when Names like '%clinique%' then 'Medical Service'
                when Names like '%physio%' then 'Medical Service'
                when Names like '%ambulance%' then 'Medical Service'
                when Names like '%ambluance%' then 'Medical Service'
                when Names like '%travmin bangkok%' then 'Medical Service'
                when Names like 'dr %' then 'Medical Service'
                when Names like '% dr %' then 'Medical Service'
                when Names like '%general practice%' then 'Medical Service'
                when Names like '%physio%' then 'Medical Service'
                when Names like '%patholo%' then 'Medical Service'
                when Names like '%radiolo%' then 'Medical Service'
                when Names like '%koh samui hosp%' then 'Medical Service'
                when Names like '%rescue%' then 'Emergency'
                when Names like '%heli%' then 'Emergency'
                when Names like '%evac%' then 'Emergency'
                when Names like '%camera%' then 'Electronic'
                when Names like '%computer%' then 'Electronic'
                when Names like '%electr%' then 'Electronic'
                when Names like '%jb hi_fi%' then 'Electronic'
                when Names like '%jb comm%' then 'Electronic'
                when Names like '%techhead%' then 'Electronic'
                when Names like '%harvey%norman%' then 'Electronic'
                when Names like '%hill%stewart%' then 'Electronic'
                when Names like '%photo%video%' then 'Electronic'
                when Names like '%noel leem%' then 'Electronic'
                when Names like '%Carnival Australia%' then 'Transportation'
                when Names like '%Carnival plc%' then 'Transportation'
                when Names like '%aviat%' then 'Transportation'
                when Names like '%flight%' then 'Transportation'
                when Names like '%travel%' then 'Transportation'
                when Names like '%translat%' then 'Translation'
                when Names like '%lingui%' then 'Translation'
                when Names like '% ling.%' then 'Translation'
                when Names like '%language%' then 'Translation'
                when Names like '%dima tis%' then 'Translation'
                when Names like '%FOS%' then 'Complaint'
                when Names like '%ombudsman%' then 'Complaint'
                when Names like '%centricity%' then 'Investigation'
                when Names like '%investig%' then 'Investigation'
                when Names like '%bank%' then 'Financial Service'
                when Names like '%western union%' then 'Financial Service'
                when Names like '%custom house%' then 'Financial Service'
                when Names like '%finance%' then 'Financial Service'
                when Names like '%barclay%' then 'Financial Service'
                when Names like '%associates%' then 'Legal Service'
                when Names like '%legal%' then 'Legal Service'
                when Names like '%lawyer%' then 'Legal Service'
                when Names like '%McLarens Young%' then 'Legal Service'
                when Names like '%N.I.R.S.%' then 'Insurance Service'
                when Names like '%insurance%' then 'Insurance Service'
                when Names like '%jewel%' then 'Jewellery'
                when Names like '%celcom int%' then 'Retail'
                else 'Unknown'
            end Segment
    ) ns
GO
