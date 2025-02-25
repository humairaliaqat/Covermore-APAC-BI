USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_liveteleclaims]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_dashboard_liveteleclaims]
as
begin
--20240622, SB, As part of claims Uplift(E5 classic to E5 connect) source details and User details were updated according to respective joins (CHG0039218).

    declare @utcdate datetime
    set @utcdate = dbo.xfn_ConvertLocaltoUTC(convert(date, getdate()), 'AUS Eastern Standard Time')

    if object_id('tempdb..#liveclaim') is not null
        drop table #liveclaim

    select 
        c.KLCLAIM ClaimNo,
        CaseOfficer,
        c.KLCREATED RegisterDate,
        oc.AlphaCode,
        oc.ConsultantName
    into #liveclaim
    from
        [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLREG c
        left join [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.tblOnlineClaims oc on
            oc.ClaimId = c.KLCLAIM
        outer apply
        (
            select top 1
                KSNAME CaseOfficer
            from
                [db-au-penguinsharp.aust.covermore.com.au].CLAIMS.dbo.KLSECURITY cs
            where
                cs.KS_ID = c.KLCREATEDBY_ID and
                cs.KSDOMAINID = c.KLDOMAINID
        ) co
    where
        c.KLDOMAINID = 7 and
        KLCREATED >= @utcdate

    ;with cte_newclaim as
    (
        select 
            ClaimNo,
            case
                when CaseOfficer = 'Online Submitted' then isnull(DisplayName, '')
                else CaseOfficer collate database_default
            end CreatedBy
        from
            #liveclaim lc
            outer apply
            (
                select top 1 
                    DisplayName
                from
                    usrLDAP
                where
                    UserName = lc.ConsultantName collate database_default
            ) u

        union

        select
            ClaimNo,
            u.DisplayName
        from
            [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.Work w with(nolock)
            inner join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.Category2 wt with(nolock) on
                wt.Id = w.Category2_Id
            cross apply
            (
                select
                    PropertyValue ClaimNo
                from
                    [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkProperty wp with(nolock)
                where
                    wp.Work_Id = w.Id and
                    wp.Property_Id = 'ClaimNumber' and
                    wp.PropertyValue is not null and
                    wp.PropertyValue <> ''
            ) c
			outer apply  --Userdetails added as part of Claims uplift (CHG0039218): SB
			(
			    select top 1
			        ur.UserName collate database_default AssignedUser
			    from
			        [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.[User] ur
			    where
			        ur.Id = w.AssignedUser
			) us
            outer apply
            (
                select top 1 
                    DisplayName
                from
                    usrLDAP
                where
                    UserName = replace(us.AssignedUser, 'covermore\', '') collate database_default
            ) u
        where
            (
                wt.Name like '%claim%' 
        
                --additional child items, not sure what's the impact yet
                or wt.Name in ('Phone Call', 'Complaints', 'Recovery', 'Investigation')
        
            ) and
            w.Status_Id = 1 and
            w.Category1_Id = 2 /*AU*/ and
            w.CreationDate >= convert(date, getdate()) and
            exists
            (
                select
                    null
                from
                    [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkProperty wp with(nolock)
                where
                    wp.Work_Id = w.Id and
                    wp.Property_Id = 'ClaimType' and
                    wp.PropertyValue in (272, 273) --Teleclaims, AssistanceTeleclaims
            ) 

    )
    select 
        CreatedBy,
        count(distinct ClaimNo) NewClaimCount
    from
        cte_newclaim
    where
        CreatedBy in
        (    
            select 
                DisplayName
            from
                [db-au-workspace]..live_dashboard_claims_officer
            where
                TeleFlag = 1
        )
    group by
        CreatedBy

end




GO
