USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vAccessList]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[vAccessList] as
--20150227, LS, LDAP accounts may have duplicates (deleted records)
select 
    'CRM ' + cu.CountryKey [System],
    cu.UserName [Login],
    case
        when cu.StatusDescription = 'Active' then 'Yes'
        else 'No'
    end [Has Access],
    cu.Department + ' ' +
    case
        when cu.accesslevel = '1' then 'Read Only'
        when cu.accesslevel = '2' then 'Read Write'
        else cu.accesslevel
    end [Access Level],
    coalesce(u.DisplayName, isnull(cu.FirstName + ' ', '') + isnull(cu.LastName, ''), cu.UserName, '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    penCRMUser cu
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = cu.UserName
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u

union all

select
    'EMC' [System],
    s.[Login],
    case
        when 
            s.ValidFrom <= convert(date, getdate()) and
            s.ValidTo >= convert(date, getdate())
        then 'Yes'
        else 'No'
    end [Has Access],
    s.SecurityLevel [Access Level],
    coalesce(u.DisplayName, s.FullName, s.[Login], '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    emcSecurity s
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = s.Login
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u
    
union all

select
    'Claim ' + s.CountryKey [System],
    isnull(s.Name, '') [In App Name],
    case
        when s.isActive = 1 then 'Yes'
        else 'No'
    end [Has Access],
    isnull(s.LevelDesc, '') [Access Level],
    coalesce(u.DisplayName, s.Name, s.[Login], '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    clmSecurity s
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = s.Login
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u
    
union all
    
select 
    'e5' [System],
    s.tp_Login collate database_default [Login],
    case
        when s.tp_IsActive = 1 then 'Yes'
        else 'No'
    end [Has Access],
    (
        select distinct
            g.Title + '; '
        from
            e5.[WSS_Content_CoverMore_PRD].[dbo].[GroupMembership] gm
            inner join e5.[WSS_Content_CoverMore_PRD].[dbo].[Groups] g on
                g.ID = gm.GroupID
        where
            gm.MemberId = s.tp_ID
        for xml path('')
    ) [Access Level],
    coalesce(u.DisplayName, s.tp_Title collate database_default, s.tp_Login collate database_default, '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    e5.[WSS_Content_CoverMore_PRD].[dbo].[UserInfo] s
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = replace(s.tp_Login, 'covermore\', '') collate database_default
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u

union all

select
    'Carebase' [System],
    s.UserID [Login],
    --case
    --    when s.IsDisplayed = 1 then 'Yes'
    --    else 'No'
    --end 
    'Yes' [Has Access],
    s.SecurityGroup [Access Level],
    coalesce(u.DisplayName, isnull(s.FirstName + ' ', '') + isnull(s.Surname, ''), s.UserID, '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    cbUser s
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = s.UserID
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u

union all

select
    'Corporate ' + s.CountryKey [System],
    s.[Login],
    'Yes' [Has Access],
    s.SecurityLevel [Access Level],
    coalesce(u.DisplayName, s.FullName, s.[Login], '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    corpSecurity s
    outer apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = s.Login
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u

union all

select 
    'SAP BI' [System],
    s.Item [Login],
    case
        when exists
        (
            select 
                null
            from
                [db-au-bobjaudit].dbo.ADS_EVENT e
            where
                e.Start_Time >= dateadd(month, -6, getdate()) and
                e.Event_Type_ID = 1014 and --logon
                e.User_Name = u.UserName
        ) then 'Yes' 
        else 'No'
    end [Has Access],
    '' [Access Level],
    coalesce(u.DisplayName, '') [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    [db-au-bobj].dbo.CMS_Aliases7 t
    cross apply dbo.fn_DelimitedSplit8K(t.Alias, ':') s
    cross apply
    (
        select top 1
            u.*
        from
            usrLDAP u
        where
            u.UserName = s.Item
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) u
where
    s.ItemNumber = 3 and
    u.isActive = 1
    
union all

select 
    'Windows AD' [System],
    u.UserName [Login],
    case
        when isActive = 1 then 'Yes'
        else 'No'
    end [Has Access],
    case
        when isnull(isLocked, 0) = 1 then 'Account Locked; '
        else ''
    end +
    case
        when isnull(isPasswordRequired, 0) = 0 then 'No Password Required; '
        else ''
    end +
    case
        when isnull(isPasswordNeverExpired, 0) = 1 then 'Password Never Expired; '
        else ''
    end +
    case
        when isnull(isPasswordExpired, 0) = 1 then 'Password Expired; '
        else ''
    end +
    case
        when isnull(isInterDomainTrust, 0) = 1 then 'Interdomain Trusted; '
        else ''
    end +
    case
        when isnull(isTrustedForDelegation, 0) = 1 then 'Trusted for Delegation; '
        else ''
    end +
    case
        when AdminCount > 0 then 'Admin Group; '
        else ''
    end + 
    case
        when isnull(isPasswordExpired, 0) = 1 then 'Password Expired; '
        else ''
    end +
    case
        when BadPasswordCount >= 4 then 'High Failed Login Count; '
        else ''
    end [Access Level],
    coalesce(u.DisplayName, u.UserID) [Name],
    case
        when u.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(u.Department, '') Department,
    isnull(u.Manager, '') Manager
from
    usrLDAP u
where
    DeleteDateTime is null

union all

select 
    'SUN' [System],
    p.UserName [Login],
    case
        when p.IsDeleted is not null then 'No'
        when isnull(p.IsLocked, 0) > 0 then 'No'
        when isnull(p.IsSSOEnabled, 0) <> 0 or isnull(p.EnableStandAloneAuth, 0) <> 0 then 'Yes'
        else 'No'
    end [Has Access],
    case
        when p.FailedPasswordAttempts is not null then 'Failed password attempts;'
        else ''
    end +
    case
        when isnull(p.EnableStandAloneAuth, 0) = 1 then 'Stand alone authorisation;'
        else ''
    end +
    case
        when isnull(p.IsSSOEnabled, 0) = 1 then 'SSO enabled;'
        else ''
    end +
    case
        when isnull(p.ForceChangePassword, 0) <> 0 then 'Must change password;'
        else ''
    end +
    case
        when p.LastLogon is null then 'Never logged on;'
        when datediff(day, p.LastLogon, getdate()) > 60 then 'Hasn''t logged on for 2+ months;'
        else ''
    end +
    rtrim(p.UserDescription) + ';' +
    isnull(
        (
            select distinct 
                Item + ';'
            from
                dbo.fn_DelimitedSplit8K(g.GroupDescription, ',') gd
            for xml path('')
        ),
        ''
    ) [Access Level],    
    p.FullName [Name],
    case
        when au.isActive = 1 then 'Yes'
        else 'No'
    end [AD Active],
    isnull(au.Department, '') Department,
    isnull(au.Manager, '') Manager
from
    (
        select distinct
            [GUID]
        from
            [ULSQLSILV03].[SunSystemsSecurity].[dbo].[SECURITY_PROPERTIES]
    ) u
    outer apply
    (
        select 
            max(
                case
                    when [PROPNAME] = 'core.deleted' then [STRPROP]
                    else null
                end 
            ) IsDeleted,
            max(
                case
                    when [PROPNAME] = 'core.description' then [STRPROP]
                    else null
                end 
            ) UserDescription,
            max(
                case
                    when [PROPNAME] = 'core.emailaddress' then [STRPROP]
                    else null
                end 
            ) Email,
            max(
                case
                    when [PROPNAME] = 'core.enable-standauth' then [NUMPROP]
                    else null
                end 
            ) EnableStandAloneAuth,
            max(
                case
                    when [PROPNAME] = 'core.forceChangeAtNextLogin' then [NUMPROP]
                    else null
                end 
            ) ForceChangePassword,
            max(
                case
                    when [PROPNAME] = 'core.fullname' then [STRPROP]
                    else null
                end 
            ) FullName,
            max(
                case
                    when [PROPNAME] = 'core.groups' then [STRPROP]
                    else null
                end 
            ) UserGroups,
            max(
                case
                    when [PROPNAME] = 'core.lastLogonDate' then [STRPROP]
                    else null
                end 
            ) LastLogon,
            max(
                case
                    when [PROPNAME] = 'core.lockStatus' then [NUMPROP]
                    else null
                end 
            ) IsLocked,
            max(
                case
                    when [PROPNAME] = 'core.name' then [STRPROP]
                    else null
                end 
            ) UserName,
            max(
                case
                    when [PROPNAME] = 'core.passwordAttempts' then [STRPROP]
                    else null
                end 
            ) FailedPasswordAttempts,
            max(
                case
                    when [PROPNAME] = 'core.title' then [STRPROP]
                    else null
                end 
            ) Title,
            max(
                case
                    when [PROPNAME] = 'core.windows.account-name' then [STRPROP]
                    else null
                end 
            ) ADName,
            max(
                case
                    when [PROPNAME] = 'core.windows.enable-sso' then [STRPROP]
                    else null
                end 
            ) IsSSOEnabled,
            max(
                case
                    when [PROPNAME] = 'core.windows.upn' then [STRPROP]
                    else null
                end 
            ) UserDomainName
        from 
            [ULSQLSILV03].[SunSystemsSecurity].[dbo].[SECURITY_PROPERTIES] p
        where
            p.[GUID] = u.[GUID] and
            [PROPNAME] in
            (
                'core.deleted',
                'core.description',
                'core.emailaddress',
                'core.enable-standauth',
                'core.forceChangeAtNextLogin',
                'core.fullname',
                'core.groups',
                'core.lastLogonDate',
                'core.lockStatus',
                'core.name',
                'core.passwordAttempts',
                'core.title',
                'core.windows.account-name',
                'core.windows.enable-sso',
                'core.windows.upn'
            )
    ) p
    outer apply
    (
        select top 1 
            [GUIDDESCS] GroupDescription
        from
            [ULSQLSILV03].[SunSystemsSecurity].[dbo].[USER_SECURITY_REPORT] uv
        where
            uv.[GUID] = u.[GUID]
    ) g
    outer apply
    (
        select top 1
            l.*
        from
            usrLDAP l
        where
            l.UserID = p.UserDomainName collate database_default or
			l.DisplayName = p.FullName collate database_default
        order by 
            case
                when DeleteDateTime is null then 0
                else 1
            end                 
    ) au



GO
