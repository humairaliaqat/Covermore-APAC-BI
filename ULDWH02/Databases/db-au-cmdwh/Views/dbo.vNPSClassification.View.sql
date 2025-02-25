USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vNPSClassification]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vNPSClassification] as
select 
    t.BIRowID,
    --pt.PolicyTransactionKey,
    --cl.ClaimKey,
    --ma.CaseKey,
    cat.value('code[1]', 'varchar(max)') Classification,
    cat.value('abs_relevance[1]', 'float') Relevance,
    dense_rank() over (partition by BIRowID order by cat.value('abs_relevance[1]', 'float') desc) RelevanceRank
from
    npsData t
    --cross apply
    --(
    --    select top 1 
    --        PolicyTransactionKey
    --    from    
    --        [db-au-cmdwh]..penPolicyTransSummary pt
    --    where
    --        pt.CountryKey = t.DomainCountry and
    --        pt.PolicyNumber = t.[Policy No]
    --) pt
    --outer apply
    --(
    --    select top 1 
    --        Claimkey
    --    from
    --        [db-au-cmdwh]..clmClaim cl
    --    where
    --        cl.CountryKey = t.DomainCountry and
    --        cl.ClaimNo = try_convert(int, t.[Claim No])
    --) cl
    --outer apply
    --(
    --    select 
    --        cc.CaseKey
    --    from
    --        [db-au-cmdwh]..cbCase cc
    --    where
    --        cc.CaseNo = t.[MA Case No]
    --) ma
    outer apply
    (
        select 
            convert(xml, replace(t.Classification, '"utf-8"', '"utf-16"')) ClassificationXML,
            convert(xml, replace(t.Topic, '"utf-8"', '"utf-16"')) TopicXML
    ) tx
    outer apply ClassificationXML.nodes('/response/category_list/category') as class(cat)
where
    Classification is not null 


GO
