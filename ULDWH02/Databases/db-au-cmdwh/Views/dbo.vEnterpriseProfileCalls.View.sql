USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseProfileCalls]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vEnterpriseProfileCalls]
as
select --top 1000
    ec.CustomerID,
    cmd.LocalStartTime CallDate,
    case
        when cmd.CaseKey is not null then 'Assistance'
        when cmd.ApplicationKey is not null then 'EMC'
        when cmd.ClaimKey is not null then 'Claim'
        else 'General'
    end CallType,
    cmd.Duration,
    cmd.Phone
from
    entCustomer ec with(nolock)
    cross apply
    (
        select distinct
            PolicyKey
        from
            entPolicy ep with(nolock)
        where
            ep.CustomerID = ec.CustomerID
    ) ep
    inner join penPolicyTransSummary pt with(nolock) on
        pt.PolicyKey = ep.PolicyKey
    inner join cisCallMetaData cmd with(nolock) on
        cmd.PolicyTransactionKey = pt.PolicyTransactionKey
--where
--    CustomerID = 1000294

GO
