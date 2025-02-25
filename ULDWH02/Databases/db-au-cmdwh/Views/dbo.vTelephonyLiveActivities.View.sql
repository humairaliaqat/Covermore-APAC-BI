USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyLiveActivities]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vTelephonyLiveActivities] 
as
select
    ltrim(rtrim(isnull(PERSON.FIRSTNAME,''))) + ' ' + LTRIM(RTRIM(isnull(PERSON.LASTNAME,''))) AgentName,
    ORGANIZATION.NAME TeamName,
    convert(date, dateadd(minute, startTZ.BIAS, fact.STARTTIME)) ActivityDate,
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) ActivityStartTime,
    dateadd(minute, endTZ.BIAS, fact.ENDTIME) ActivityEndTime,
    ACTIVITY.Name Activity,
    convert(float, datediff(minute, fact.STARTTIME, fact.ENDTIME)) / 60 ActualActivityTime,
    0 ScheduledActivityTime,
    0 ApprovedExceptionDuration, 
    0 UnapprovedExceptionDuration,
    0 QualityScore
from
    [ULWFM01].[BPMAINDB].dbo.ACTUALEVENTTIMELINE fact
    inner join [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM EMPLOYEE on
        EMPLOYEE.ID = fact.EMPLOYEEID
    inner join [ULWFM01].[BPMAINDB].dbo.PERSON on
        PERSON.ID = EMPLOYEE.PERSONID
    inner join [ULWFM01].[BPMAINDB].dbo.ACTIVITY on
        ACTIVITY.ID = fact.ACTIVITYID
    left join [ULWFM01].[BPMAINDB].dbo.WORKRESOURCEORGANIZATION on
        EMPLOYEE.ID = WORKRESOURCEORGANIZATION.WORKRESOURCEID and
        WORKRESOURCEORGANIZATION.STARTTIME <= fact.STARTTIME and
        (
            fact.STARTTIME < WORKRESOURCEORGANIZATION.ENDTIME or
            WORKRESOURCEORGANIZATION.ENDTIME is null
        )
    left join [ULWFM01].[BPMAINDB].dbo.ORGANIZATION on
        ORGANIZATION.ID = WORKRESOURCEORGANIZATION.ORGANIZATIONID
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as startTZ on
        (
            (
                startTZ.STARTTIME <= fact.STARTTIME and
                fact.STARTTIME < startTZ.ENDTIME
            ) or
            (
                startTZ.STARTTIME is null and
                startTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = startTZ.TIMEZONE
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as endTZ on
        (
            (
                endTZ.STARTTIME <= fact.ENDTIME and
                fact.ENDTIME < endTZ.ENDTIME
            ) or
            (
                endTZ.STARTTIME is null and
                endTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = endTZ.TIMEZONE
where
    fact.STARTTIME >= dateadd(hour, -11, convert(datetime, convert(date, getdate()))) and
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) >= convert(date, getdate())

union all

select
    ltrim(rtrim(isnull(PERSON.FIRSTNAME,''))) + ' ' + LTRIM(RTRIM(isnull(PERSON.LASTNAME,''))) AgentName,
    ORGANIZATION.NAME TeamName,
    convert(date, dateadd(minute, startTZ.BIAS, fact.STARTTIME)) ActivityDate,
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) ActivityStartTime,
    dateadd(minute, endTZ.BIAS, fact.ENDTIME) ActivityEndTime,
    ACTIVITY.Name Activity,
    0 ActualActivityTime,
    convert(float, datediff(minute, fact.STARTTIME, fact.ENDTIME)) / 60 ScheduledActivityTime,
    0 ApprovedExceptionDuration, 
    0 UnapprovedExceptionDuration,
    0 QualityScore
from
    [ULWFM01].[BPMAINDB].dbo.PLANNEDEVENTTIMELINE fact
    inner join [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM EMPLOYEE on
        EMPLOYEE.ID = fact.WORKRESOURCEID
    inner join [ULWFM01].[BPMAINDB].dbo.PERSON on
        PERSON.ID = EMPLOYEE.PERSONID
    inner join [ULWFM01].[BPMAINDB].dbo.ACTIVITY on
        ACTIVITY.ID = fact.ACTIVITYID
    left join [ULWFM01].[BPMAINDB].dbo.WORKRESOURCEORGANIZATION on
        EMPLOYEE.ID = WORKRESOURCEORGANIZATION.WORKRESOURCEID and
        WORKRESOURCEORGANIZATION.STARTTIME <= fact.STARTTIME and
        (
            fact.STARTTIME < WORKRESOURCEORGANIZATION.ENDTIME or
            WORKRESOURCEORGANIZATION.ENDTIME is null
        )
    left join [ULWFM01].[BPMAINDB].dbo.ORGANIZATION on
        ORGANIZATION.ID = WORKRESOURCEORGANIZATION.ORGANIZATIONID
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as startTZ on
        (
            (
                startTZ.STARTTIME <= fact.STARTTIME and
                fact.STARTTIME < startTZ.ENDTIME
            ) or
            (
                startTZ.STARTTIME is null and
                startTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = startTZ.TIMEZONE
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as endTZ on
        (
            (
                endTZ.STARTTIME <= fact.ENDTIME and
                fact.ENDTIME < endTZ.ENDTIME
            ) or
            (
                endTZ.STARTTIME is null and
                endTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE, 'Australia/Sydney') = endTZ.TIMEZONE
where
    fact.ISUNPUBLISHED = 0 and
    fact.STARTTIME >= dateadd(hour, -11, convert(datetime, convert(date, getdate()))) and
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) >= convert(date, getdate())

union all

select
    ltrim(rtrim(isnull(PERSON.FIRSTNAME,''))) + ' ' + LTRIM(RTRIM(isnull(PERSON.LASTNAME,''))) AgentName,
    ORGANIZATION.NAME TeamName,
    convert(date, dateadd(minute, startTZ.BIAS, fact.STARTTIME)) ActivityDate,
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) ActivityStartTime,
    dateadd(minute, endTZ.BIAS, fact.ENDTIME) ActivityEndTime,
    ACTIVITY.Name Activity,
    0 ActualActivityTime,
    0 ScheduledActivityTime,
    case
        when fact.ISAPPROVED = 1 then convert(float, datediff(minute, fact.STARTTIME, fact.ENDTIME))/60
        else 0
    end ApprovedExceptionDuration,
    case
        when fact.ISAPPROVED = 0 then convert(float, datediff(minute, fact.STARTTIME, fact.ENDTIME))/60
        else 0
    end UnapprovedExceptionDuration,
    0 QualityScore
from
    [ULWFM01].[BPMAINDB].dbo.ADHERENCEEXCEPTION fact
    inner join [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM EMPLOYEE on
        EMPLOYEE.ID = fact.EMPLOYEEID
    inner join [ULWFM01].[BPMAINDB].dbo.PERSON on
        PERSON.ID = EMPLOYEE.PERSONID
    inner join [ULWFM01].[BPMAINDB].dbo.ACTIVITY on
        ACTIVITY.ID = fact.PLANNEDACTIVITYID
    left join [ULWFM01].[BPMAINDB].dbo.WORKRESOURCEORGANIZATION on
        fact.EMPLOYEEID = WORKRESOURCEORGANIZATION.WORKRESOURCEID and
        WORKRESOURCEORGANIZATION.STARTTIME <= fact.STARTTIME and
        (
            fact.STARTTIME < WORKRESOURCEORGANIZATION.ENDTIME or
            WORKRESOURCEORGANIZATION.ENDTIME is null
        )
    left join [ULWFM01].[BPMAINDB].dbo.ORGANIZATION on
        ORGANIZATION.ID = WORKRESOURCEORGANIZATION.ORGANIZATIONID
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as startTZ on
        (
            (
                startTZ.STARTTIME <= fact.STARTTIME and
                fact.STARTTIME < startTZ.ENDTIME
            ) or
            (
                startTZ.STARTTIME is null and
                startTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE,'Australia/Sydney') = startTZ.TIMEZONE
    left join [ULWFM01].[BPMAINDB].dbo.TIMEZONEAM as endTZ on
        (
            (
                endTZ.STARTTIME <= fact.ENDTIME and
                fact.ENDTIME < endTZ.ENDTIME
            ) or
            (
                endTZ.STARTTIME is null and
                endTZ.ENDTIME is null
            )
        ) and
        isnull(ORGANIZATION.TIMEZONE,'Australia/Sydney') = endTZ.TIMEZONE
where
    fact.STARTTIME >= dateadd(hour, -11, convert(datetime, convert(date, getdate()))) and
    dateadd(minute, startTZ.BIAS, fact.STARTTIME) >= convert(date, getdate())
GO
