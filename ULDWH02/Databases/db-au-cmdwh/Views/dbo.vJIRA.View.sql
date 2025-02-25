USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vJIRA]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vJIRA] as
select 
    i.JiraIssueKey,
    i.IssueSummary,
    convert(varchar(4000), i.IssueDescription) IssueDescription,
    [dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.CreatedDate, 'Central Standard Time'),'AUS Eastern Standard Time') CreatedDate,
    [dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.DueDate, 'Central Standard Time'),'AUS Eastern Standard Time') DueDate,
    [dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.LastUpdatedDate, 'Central Standard Time'),'AUS Eastern Standard Time') LastUpdatedDate,
    i.IssueStatus,
    i.IssueProjectName,
    i.ReporterEmail,
    coalesce
    (
        (
            select top 1 
                l.DisplayName
            from
                usrLDAP l
            where
                l.EmailAddress = i.ReporterEmail
        ),
        (
            select top 1
                u.displayName
            from
                JiraUsers u
            where
                u.emailAddress = i.ReporterEmail
        ),
        'N/A'
    ) Reporter,
    --i.ReporterName,
    --i.ReporterEmail,
    coalesce
    (
        (
            select top 1 
                l.DisplayName
            from
                usrLDAP l
            where
                l.EmailAddress = i.AssigneeEmail
        ),
        (
            select top 1
                u.displayName
            from
                JiraUsers u
            where
                u.emailAddress = i.AssigneeEmail
        ),
        'N/A'
    ) Assignee,
    --i.AssigneeName,
    --i.AssigneeEmail,
    --c.AuthorEmailAddress,
    convert(varchar(4000), c.Body) Comment,
     [dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](c.CreatedDate , 'Central Standard Time'),'AUS Eastern Standard Time') CommentDate,
    coalesce
    (
        (
            select top 1 
                l.DisplayName
            from
                usrLDAP l
            where
                l.EmailAddress = c.AuthorEmailAddress
        ),
        (
            select top 1
                u.displayName
            from
                JiraUsers u
            where
                u.emailAddress = c.AuthorEmailAddress
        ),
        'N/A'
    ) CommentAuthor,
	CASE i.IssueStatus
		WHEN 'Open' THEN 0
		WHEN 'Reopened' THEN 0
		WHEN 'Waiting for customer' THEN 0
		WHEN 'Evaluating' THEN 1
		WHEN 'Pending' THEN 1
		WHEN 'To Do' THEN 1
		WHEN 'Awaiting Prioritisation' THEN 2
		WHEN 'Backlog' THEN 2
		WHEN 'Discover' THEN 2
		WHEN 'In UAT' THEN 2
		WHEN 'Testing' THEN 2
		WHEN 'Shape' THEN 3
		WHEN 'Closed' THEN 4
		WHEN 'Done' THEN 4
		ELSE 5
	END IssueStatusOrder
from
    JiraIssues i
    --left join cte_user u on
    --    u.name = i.ReporterName or
    --    u.emailAddress = i.ReporterEmail
    left join JiraComments c on
        c.JiraIssueKey = i.JiraIssueKey and c.isLatest = 'Y'
where
    i.isLatest = 'Y'
GO
