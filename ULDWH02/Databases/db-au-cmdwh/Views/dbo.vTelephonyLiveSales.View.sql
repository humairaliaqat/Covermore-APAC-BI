USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vTelephonyLiveSales]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   view [dbo].[vTelephonyLiveSales] 
as

select 
    isnull(OrganisationName, 'Unknown') TeamName,
    t.AgentName,
    t.PolicyNumber,
    dbo.xfn_ConvertUTCtoLocal(t.TransactionDateTime, 'AUS Eastern Standard Time') PostingDate,
    t.SellPrice,
    t.PolicyCount,
    t.UserName
from
    openquery
    (
        [db-au-penguinsharp.aust.covermore.com.au],
        '
        select 
            isnull(cu.FirstName + '' '' + cu.LastName, u.Firstname + '' '' + u.LastName) AgentName,
            isnull(cu.UserName, u.Login) UserName,
            pt.TransactionDateTime,
            pt.TripsPolicyNumber PolicyNumber,
            pt.GrossPremium SellPrice,
            case
                when pt.TransactionType = 1 and pt.TransactionStatus = 1 then 1
                when pt.TransactionType = 1 and pt.TransactionStatus <> 1 then -1
                else 0
            end PolicyCount
        from
            AU_PenguinSharp_Active.dbo.tblPolicy p 
            inner join AU_PenguinSharp_Active.dbo.tblPolicyTransaction pt on
                pt.PolicyID = p.PolicyID
            left join AU_PenguinSharp_Active.dbo.tblCRMUser cu on
                cu.ID = pt.CRMUserID
            left join AU_PenguinSharp_Active.dbo.tblUser u on
                u.UserId = pt.ConsultantID
        where
            p.DomainId = 7 and
            pt.TripsPolicyNumber is not null and
            p.AlphaCode like ''CM%'' and
            pt.TransactionDateTime >= dateadd(hour, -11, convert(datetime, convert(date, getdate()))) and
            (
                u.Login is null or
                u.Login not in (''webuser'', ''mobileuser'')
            )
            
        union all
        
        select 
            isnull(cu.FirstName + '' '' + cu.LastName, u.Firstname + '' '' + u.LastName) AgentName,
            isnull(cu.UserName, u.Login) UserName,
            pt.TransactionDateTime,
            pt.TripsPolicyNumber PolicyNumber,
            pt.GrossPremium SellPrice,
            case
                when pt.TransactionType = 1 and pt.TransactionStatus = 1 then 1
                when pt.TransactionType = 1 and pt.TransactionStatus <> 1 then -1
                else 0
            end PolicyCount
        from
            AU_TIP_PenguinSharp_Active.dbo.tblPolicy p 
            inner join AU_TIP_PenguinSharp_Active.dbo.tblPolicyTransaction pt on
                pt.PolicyID = p.PolicyID
            left join AU_TIP_PenguinSharp_Active.dbo.tblCRMUser cu on
                cu.ID = pt.CRMUserID
            left join AU_TIP_PenguinSharp_Active.dbo.tblUser u on
                u.UserId = pt.ConsultantID
        where
            p.DomainId = 7 and
            pt.TripsPolicyNumber is not null and
            p.AlphaCode in (''APN0002'', ''APN0003'', ''APN0004'', ''RQN0001'') and
            pt.TransactionDateTime >= dateadd(hour, -11, convert(datetime, convert(date, getdate()))) and
            (
                u.Login is null or
                u.Login not in (''webuser'', ''mobileuser'')
            )
        
        '
    ) t
    outer apply
    (
        select top 1 
            OrganisationName
        from 
            verTeam vt
            inner join verOrganisation o on
                o.OrganisationKey = vt.OrganisationKey
        where
            vt.UserName collate database_default = t.UserName collate database_default
    ) og
where
    dbo.xfn_ConvertUTCtoLocal(t.TransactionDateTime, 'AUS Eastern Standard Time') >= convert(date, getdate())



GO
