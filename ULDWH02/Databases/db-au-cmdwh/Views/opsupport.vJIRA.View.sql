USE [db-au-cmdwh]
GO
/****** Object:  View [opsupport].[vJIRA]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [opsupport].[vJIRA] as
--Modifications
--20181107 - DM - Dates are now stored in AEST in DB. No need for conversions
--				- Added "PublicComment" key to comment JSON
select 
    i.JiraIssueKey,
    i.IssueSummary,
    convert(varchar(4000), i.IssueDescription) IssueDescription,
    --[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.CreatedDate, 'Central Standard Time'),'AUS Eastern Standard Time') CreatedDate,
	i.CreatedDate,
	case 
		when i.IssueStatus in ('Closed', 'Done') then i.LastUpdatedDate--[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.LastUpdatedDate, 'Central Standard Time'),'AUS Eastern Standard Time')
        else 
            isnull
            (
                i.DueDate,--[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.DueDate, 'Central Standard Time'),'AUS Eastern Standard Time'),
                dateadd(month, 6, i.CreatedDate)--[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.CreatedDate, 'Central Standard Time'),'AUS Eastern Standard Time'))
            ) 
    end DueDate,
    i.LastUpdatedDate,--[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](i.LastUpdatedDate, 'Central Standard Time'),'AUS Eastern Standard Time') LastUpdatedDate,
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
	END IssueStatusOrder,

    (
        select 
            convert(varchar(4000), c.Body) [Comment],
            c.CreatedDate [CommentDate], --[dbo].[xfn_ConvertUTCtoLocal]([dbo].[xfn_ConvertLocaltoUTC](c.CreatedDate , 'Central Standard Time'),'AUS Eastern Standard Time') [CommentDate],
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
            ) [CommentAuthor]
			,
			PublicComment
        from
            JiraComments c
        where
            c.JiraIssueKey = i.JiraIssueKey and 
            c.isLatest = 'Y' and
            c.PublicComment = 'Yes'
        order by
            c.CreatedDate desc
        for json auto
    ) CommentJSON

from
    JiraIssues i
    --left join cte_user u on
    --    u.name = i.ReporterName or
    --    u.emailAddress = i.ReporterEmail
    --left join JiraComments c on
    --    c.JiraIssueKey = i.JiraIssueKey and 
    --    c.isLatest = 'Y' and
    --    c.PublicComment = 'Yes'
where
    i.isLatest = 'Y' and
    (
        i.IssueKey like 'REQ%' or
        i.IssueKey like 'DAB%'
    )



GO
