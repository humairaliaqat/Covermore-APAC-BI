USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ParseEmail]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_ParseEmail]
(
    @Email varchar(max)
)
returns @formatted table 
(
    EmailAddress varchar(2048),
    UserID varchar(1024),
    UserPID varchar(1024),
    Domain varchar(1024),
    Formatted varchar(2048),
    Valid bit
)
as
begin

    insert into @formatted
    (
        EmailAddress,
        UserID,
        UserPID,
        Domain,
        Formatted,
        Valid
    )
    select top 1000 
        e.Email,
        u.uid,
        pid.pid,
        d.domain,
        pid.pid + '@' + d.domain,
        case
            when e.Email is null then 0
            when e.Email not like '%@%.%' then 0
            when e.Email like '%@%@%' then 0
            when e.Email like '%.' then 0
            when e.Email not like '[a-z,0-9]%' then 0
            when u.uid = '' then 0
            when d.domain = '' then 0
            when pid.pid = '' then 0
        end
    from
        (
            select
                nullif(lower(replace(@Email, ' ', '')), '') Email
        ) e
        cross apply
        (
            select 
                case
                    when charindex('@', Email) > 0 then left(Email, charindex('@', Email) - 1)
                    else null
                end uid
        ) u
        cross apply
        (
            select
                replace(replace(replace(
                case
                    when charindex('+', u.uid) > 0 then left(u.uid, charindex('+', u.uid) - 1)
                    else u.uid
                end, 
                '.', ''), '-', ''), '_', '') pid
        ) pid
        cross apply
        (
            select 
                case
                    when charindex('@', Email) > 0 then right(Email, len(Email) - charindex('@', Email))
                    else null
                end domain
        ) d

    return

end
GO
