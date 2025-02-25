USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseProfileValue]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vEnterpriseProfileValue]
as
select 
    ec.CustomerID,
    isnull(cl.ClaimCount, 0) ClaimCount,
    isnull(cl.ClaimValue, 0) ClaimValue,
    isnull(p.PolicyCount, 0) PolicyCount,
    isnull(p.SellPrice, 0) SellPrice
from
    entCustomer ec with(nolock)
    outer apply
    (
        select 
            count(distinct cl.ClaimKey) ClaimCount,
            sum(ci.IncurredDelta) ClaimValue
        from
            penPolicyTransSummary pt with(nolock)
            inner join clmClaim cl with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join vclmClaimIncurred ci with(nolock) on
                ci.ClaimKey = cl.ClaimKey
        where
            pt.PolicyKey in
            (
                select
                    ep.PolicyKey
                from
                    entPolicy ep with(nolock)
                where
                    ep.CustomerID = ec.CustomerID
            )
    ) cl
    outer apply
    (
        select 
            sum(pt.NewPolicyCount) PolicyCount,
            sum(pt.GrossPremium) SellPrice
        from
            penPolicyTransSummary pt with(nolock)
        where
            pt.PolicyKey in
            (
                select
                    ep.PolicyKey
                from
                    entPolicy ep with(nolock)
                where
                    ep.CustomerID = ec.CustomerID
            )
    ) p
GO
