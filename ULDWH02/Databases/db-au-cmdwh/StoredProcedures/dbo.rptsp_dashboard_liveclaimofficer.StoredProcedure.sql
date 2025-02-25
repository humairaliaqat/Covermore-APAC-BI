USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_liveclaimofficer]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_dashboard_liveclaimofficer]
--20240622, SB, As part of claims Uplift(E5 classic to E5 connect) source details and User details were updated according to respective joins (CHG0039218).
as
begin

    if object_id('tempdb..#users') is not null
        drop table #users

    select distinct
        replace(ue.EventUser, 'covermore\', '') collate database_default UserLogin,
        0 TELEFLag
    into #users
    from
        [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.WorkEvent we with(nolock)
        inner join [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.Work w with(nolock) on
            w.Id = we.Work_Id
		outer apply  --Userdetails added as part of Claims uplift (CHG0039218): SB
        (
            select top 1
                u.UserName collate database_default EventUser
            from
                [covermoresql.e5workflow.com,60500].[e5_Content_Covermore].dbo.[User] u
            where
                u.Id = we.EventUser
        ) ue
    where
        EventDate >= convert(date, getdate()) and
        Event_Id in (100, 800, 401) and
        w.Category1_Id = 2 /*AU*/


    insert into #users
    (
        UserLogin,
        TELEFLag
    )
    select 
        LoginID,
        case
            when CSQName like '%tele%claim%' then 1
            else 0
        end TELEFlag
    from
        [db-au-cmdwh]..vTelephonyLiveCallData
    where
        Team like '%claim%' or
        CSQName like '%claim%'

    insert into #users
    (
        UserLogin,
        TELEFLag
    )
    select 
        UserName,
        0 TELEFlag
    from
        usrldap
    where
        Department like '%claim%' and
        isActive = 1 and
        isnull(Company, '') not like '%NZ%' and
        DisplayName not like 'svc%' and
        LastLogon >= convert(datetime, convert(varchar(10), getdate(), 120) + ' 07:00:00')
    order by
        LastLogon desc

    ;with cte_team as
    (
        select 
            DisplayName,
            Department,
            isnull(Company, '') Company,
            JobTitle,
            case
                when JobTitle like '%leader%' then 0
                when Company like '%trawelltag%' then 1
                when Company like '%india%' then 1
                else 0
            end IndiaFlag,
            case
                when JobTitle like '%liaison%' then 0
                when JobTitle like '%leader%' then 0
                when JobTitle like '%claim%' and JobTitle like '%officer%' then 1
                when JobTitle like '%claim%' and JobTitle like '%major%' then 1
                else 0
            end COFlag,
            case
                when JobTitle like '%leader%' then 0
                when JobTitle like '%audit%' and JobTitle like '%officer%' then 1
                else 0
            end AOFlag,
            case
                when JobTitle like '%leader%' then 0
                when JobTitle like '%relation%' and JobTitle like '%officer%' then 1
                else 0
            end CROFlag,
            case
                when JobTitle like '%leader%' and Department like 'Claim%' then 1
                when JobTitle like '%SME%' then 1
                else 0
            end TLFlag,
            case
                when JobTitle like '%medical%' then 1
                else 0
            end RNFlag,
            case
                when sum(TELEFLag) > 0 then 1
                else 0
            end TeleFlag
        from
            #users u
            inner join usrLDAP l on
                l.UserName = UserLogin
        where
            isnull(Company, '') not like '%NZ%' and
            DisplayName not like 'svc%'
        group by
            DisplayName,
            Department,
            Company,
            JobTitle
    )
    select 
        DisplayName,
        Department,
        Company,
        JobTitle,
        IndiaFlag,
        f.TLFlag,
        f.TeleFlag,
        f.AuditFlag,
        f.COFlag,
        f.CROFlag,
        case
            when IndiaFlag + f.TLFlag + f.TeleFlag + f.AuditFlag + f.COFlag + f.CROFlag = 0 then 1
            else 0
        end OtherFlag
    from
        cte_team t
        cross apply
        (
            select
                case
                    when IndiaFlag = 1 then 0
                    else TLFlag
                end TLFlag,
                case
                    when IndiaFlag = 1 then 0
                    when TLFlag = 1 then 0
                    else TeleFlag
                end TeleFlag,
                case
                    when IndiaFlag = 1 then 0
                    when TLFlag = 1 then 0
                    else AOFlag
                end AuditFlag,
                case
                    when IndiaFlag = 1 then 0
                    when TLFlag = 1 then 0
                    when TeleFlag = 1 then 0
                    else COFlag
                end COFlag,
                case
                    when IndiaFlag = 1 then 0
                    when TLFlag = 1 then 0
                    when TeleFlag = 1 then 0
                    else CROFlag
                end CROFlag
        ) f

end


--if object_id('[db-au-workspace]..live_dashboard_claims_officer') is null
--    create table [db-au-workspace]..live_dashboard_claims_officer
--    (
--        DisplayName varchar(450),
--        Department varchar(255),
--        Company varchar(255),
--        JobTitle varchar(255),
--        IndiaFlag int,
--        TLFlag int,
--        TeleFlag int,
--        AuditFlag int,
--        COFlag int,
--        OtherFlag int
--    )

--truncate table [db-au-workspace]..live_dashboard_claims_officer

--insert into [db-au-workspace]..live_dashboard_claims_officer
--exec [db-au-cmdwh]..rptsp_dashboard_liveclaimofficer


GO
