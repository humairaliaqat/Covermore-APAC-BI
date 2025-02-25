USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_claim_support_assessment]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_dashboard_claim_support_assessment]
--with execute as 'covermore\appbobj'
--20240622, SB, As part of claims Uplift(E5 classic to E5 connect) source details and User details were updated according to respective joins (CHG0039218).

as
begin

    delete from [db-au-workspace].dbo.e5Assessments

    --create table [db-au-workspace].dbo.e5Assessments
    --(
    --    AssignedTo nvarchar(445),
    --    Reference int,
    --    ClaimNo varchar(50),
    --    CurrentStatus nvarchar(100),
    --    AssessmentDate date,
    --    AssessmentTime time,
    --    AssessedBy nvarchar(445),
    --    AssessmentOutcome nvarchar(445)
    --)

    insert into [db-au-workspace].dbo.e5Assessments
    select 
        isnull(la.DisplayName, 'Unknown') AssignedTo,
        w.Reference,
        convert(varchar(50), cl.ClaimNo) ClaimNo,
        s.name CurrentStatus,
        convert(date, wa.CompletionDate) AssessmentDate,
        convert(time, wa.CompletionDate) AssessmentTime,
        isnull(las.DisplayName, 'Unknown') AssessedBy,
        wap.name AssessmentOutcome
    --into #test
    from
        [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkActivity wa     
        inner join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.CategoryActivity ca      on
            ca.id = wa.CategoryActivity_Id
        inner join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.Work w      on
            w.Id = wa.Work_Id
        inner join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.status s      on
            s.id = w.status_id
        cross apply
        (
            select top 1
                wp.PropertyValue ClaimNo
            from
                [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkProperty wp     
            where
                wp.Work_Id = w.Id and
                wp.Property_Id = 'ClaimNumber' and
                wp.PropertyValue is not null and
                wp.PropertyValue <> ''
        ) cl
        outer apply
        (
            select top 1 
                li.Name
            from
                [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkActivityProperty wap     
                left join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.ListItem li      on
                    li.Id = wap.PropertyValue
            where
                wap.Work_Id = w.Id and
                wap.WorkActivity_Id = wa.Id and
                wap.Property_Id like '%outcome%'
        ) wap
		outer apply  --Userdetails added as part of Claims uplift (CHG0039218): SB
        (
            select top 1
                u.UserName collate database_default AssignedUser
            from
                [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.[User] u
            where
                u.Id = w.AssignedUser
        ) us
        outer apply
        (
            select top 1
                DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(us.AssignedUser collate database_default, 'covermore\', '')
        ) la
		outer apply  --Userdetails added as part of Claims uplift (CHG0039218): SB
        (
            select top 1
                u.UserName collate database_default CompletionUser
            from
                [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.[User] u
            where
                u.Id = wa.CompletionUser
        ) usco
        outer apply
        (
            select top 1
                DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(usco.CompletionUser collate database_default, 'covermore\', '')
        ) las
    where
        w.Category1_Id = 2 and
        wa.CompletionDate >= convert(date, getdate()) and
        ca.Name = 'Assessment Outcome'


end



GO
