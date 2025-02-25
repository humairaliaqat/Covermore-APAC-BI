USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyActivities]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vTelephonyActivities] 
as
select 
    isnull(e.EmployeeName, 'Unknown') AgentName,
    isnull(o.OrganisationName, 'Unknown') TeamName, 
    convert(date, vat.ActivityStartTime) ActivityDate,
    vat.ActivityStartTime,
    vat.ActivityEndTime,
    a.ActivityName Activity,
    case 
        when TimeLineType = 'Actuals' then ActivityTime 
        else 0 
    end ActualActivityTime, 
    case 
        when TimeLineType = 'Actuals' then 0 
        else ActivityTime 
    end ScheduledActivityTime, 
    0 ApprovedExceptionDuration, 
    0 UnapprovedExceptionDuration,
    0 QualityScore
from
    verActivityTimeline vat 
    left join verEmployee e on 
        e.EmployeeKey = vat.EmployeeKey 
    left join verOrganisation o on
        o.OrganisationKey = vat.OrganisationKey
    left join verActivity a on
        a.ActivityKey = vat.ActivityKey

union all

select
    isnull(e.EmployeeName, 'Unknown') AgentName,
    isnull(o.OrganisationName, 'Unknown') TeamName, 
    convert(date, va.ActivityStartTime) ActivityDate,
    va.ActivityStartTime,
    va.ActivityEndTime,
    a.ActivityName Activity,
    0 ActualActivityTime, 
    0 ScheduledActivityTime, 
    ApprovedExceptionDuration, 
    UnapprovedExceptionDuration,
    0 QualityScore
from
    verAdherence va 
    left join verEmployee e on 
        e.EmployeeKey = va.EmployeeKey 
    left join verOrganisation o on
        o.OrganisationKey = va.OrganisationKey
    left join verActivity a on
        a.ActivityKey = va.ActivityKey

union all

select
    isnull(e.EmployeeName, 'Unknown') AgentName,
    isnull(o.OrganisationName, 'Unknown') TeamName, 
    convert(date, vq.QualityStartTime) ActivityDate,
    vq.QualityStartTime,
    vq.QualityEndTime,
    'Quality' Activity,
    0 ActualActivityTime, 
    0 ScheduledActivityTime, 
    0 ApprovedExceptionDuration, 
    0 UnapprovedExceptionDuration,
    vq.QualityScore
from
    verQuality vq
    left join verEmployee e on 
        e.EmployeeKey = vq.EmployeeKey 
    left join verOrganisation o on
        o.OrganisationKey = vq.OrganisationKey


GO
