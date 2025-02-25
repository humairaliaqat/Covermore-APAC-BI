USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vBaliIncurred]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vBaliIncurred] as
select 
    SuperGroupName,
    JVDesc,
    cl.ClaimNo,
    CatastropheCode,
    cl.PolicyIssuedDate,
    ce.EventDate,
    cs.SectionCode,
    IncurredDate,
    IncurredAge,
    Estimate,
    Paid,
    IncurredValue,
    PreviousEstimate,
    PreviousPaid,
    PreviousIncurred,
    EstimateDelta,
    PaymentDelta,
    IncurredDelta
from
    [db-au-cmdwh]..vclmClaimSectionIncurred t with(nolock)
    inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
        cl.ClaimKey = t.ClaimKey
    inner join [db-au-cmdwh]..clmEvent ce with(nolock) on
        ce.ClaimKey = t.ClaimKey
    inner join [db-au-cmdwh]..clmSection cs with(nolock) on
        cs.SectionKey = t.SectionKey
    outer apply
    (
        select top 1 
            SuperGroupName,
            JVDesc
        from
            [db-au-star]..dimOutlet o with(nolock)
        where
            o.Country = cl.CountryKey and
            o.OutletKey = cl.OutletKey and
            o.isLatest = 'Y'
    ) o
where
    cl.CountryKey = 'AU' and
    CatastropheCode in ('BVC', 'BVA', 'ACB')
    --cl.ClaimNo = 883967
GO
