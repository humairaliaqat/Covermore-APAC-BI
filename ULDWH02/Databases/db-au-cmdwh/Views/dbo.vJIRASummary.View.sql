USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vJIRASummary]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vJIRASummary]
as
select --top 1000
    i.IssueKey,
    i.IssueSummary,
    i.IssuePriority,
    coalesce
    (
        (
            select top 1 
                ld.DisplayName
            from
                usrLDAP ld
            where
                ld.EmailAddress = i.ReporterEmail
        ),
        i.ReporterEmail
    ) Reporter,
    coalesce
    (
        (
            select top 1 
                ld.DisplayName
            from
                usrLDAP ld
            where
                ld.EmailAddress = i.AssigneeEmail
        ),
        i.AssigneeName,
        'Unassigned'
    ) Assignee,
    i.CreatedDate,
    i.DueDate,
    i.LastUpdatedDate,
    i.IssueStatus,
    case
        when i.IssueStatus in 
            (
                'Reopened',
                'Awaiting Prioritisation',
                'Open'
            ) then 'Backlog'
        when i.IssueStatus in 
            (
                'Pending',
                'Testing'
            ) then 'WIP'
        when i.IssueStatus in 
            (
                'Closed',
                'Resolved',
                'Done'
            ) then 'Completed'
        when i.IssueStatus in 
            (
                'Waiting for customer',
                'WAITING FEEDBACK'
            ) then 'UAT / Waiting Feedback'
        else 'Undefined'
    end IssueStatusGroup,
    case 
        when i.IssueProjectKey = 'DAB' then 'Project'
        when l.ObjectType in ('ETL') then 'Maintenance'
        when l.ActivityType in ('Admin', 'Access', 'Bug', 'DQ', 'Investigate', 'Performance', 'Provide', 'Question', 'Reconciliation', 'Schedule') then 'Maintenance'
        else 'Enhancement'
    end ItemGroup,
    coalesce
    (
        try_convert(int, i.Effort),
        try_convert(int, i.StoryPoints),
        0
    ) EffortPoint,
    coalesce
    (
        try_convert(int, i.Effort),
        try_convert(int, i.StoryPoints),
        0
    ) / 2.0 EffortDays,
    coalesce
    (
        try_convert(decimal(10,2), i.Effort_Done),
        0
    ) / 2.0 ActualEffortDays,
    (
        coalesce
        (
            try_convert(int, i.Effort),
            try_convert(int, i.StoryPoints),
            0
        ) / 2.0 
    ) -
    (
        coalesce
        (
            try_convert(decimal(10,2), i.Effort_Done),
            0
        ) / 2.0 
    ) RemainingEffortDays,
    l.*
from
    JiraIssues i
    cross apply
    (
        select 
            max
            (
                case
                    when t.Item like 'B:%' then replace(t.Item, 'B:', '')
                    else null 
                end 
            ) BusinessUnit,
            max
            (
                case
                    when t.Item like 'D:%' then replace(t.Item, 'D:', '')
                    else null 
                end 
            ) Team,
            max
            (
                case
                    when t.Item like 'T:%' then replace(t.Item, 'T:', '')
                    else null 
                end 
            ) ActivityType,
            max
            (
                case
                    when t.Item like 'A:%' then replace(t.Item, 'A:', '')
                    else null 
                end 
            ) ObjectType,
            max
            (
                case
                    when t.Item like 'R:%' then replace(t.Item, 'R:', '')
                    else null 
                end 
            ) ObjectReference,
            max
            (
                case
                    when t.Item like 'P:%' then replace(t.Item, 'P:', '')
                    else null 
                end 
            ) Platform,
            max
            (
                case
                    when t.Item like 'G:%' then replace(t.Item, 'G:', '')
                    else null 
                end 
            ) Partner,
            max
            (
                case
                    when t.Item like 'O:%' then replace(t.Item, 'O:', '')
                    else null 
                end 
            ) Tags
        from
            dbo.fn_DelimitedSplit8K(i.IssueLabels, ',') t
    ) l
where
    i.IssueType <> 'EPIC' and
    i.isLatest = 'Y' and
    i.IssueProjectKey in ('REQ', 'DAB') and
    i.IssueStatus <> 'Deleted' and    
    --moved
    not exists
    (
        select 
            null
        from
            JiraIssues r
        where
            r.JiraIssueId = i.JiraIssueId and
            r.LastUpdatedDate > i.LastUpdatedDate
    )


GO
