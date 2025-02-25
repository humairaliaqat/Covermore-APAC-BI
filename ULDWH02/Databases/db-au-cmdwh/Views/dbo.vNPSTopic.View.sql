USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vNPSTopic]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vNPSTopic] as
with
cte_topic as
(
    select 
        t.BIRowID,
        --pt.PolicyTransactionKey,
        --cl.ClaimKey,
        --ma.CaseKey,
        entities.value('form[1]', 'varchar(max)') Topic,
        entities.value('relevance[1]', 'int') Relevance,
        type.value('(text())[1]', 'varchar(max)') TopicType,
        --tt.ItemNumber,
        --max(tt.ItemNumber) over (partition by t.BIRowID) LastItem,
        --tt.Item
        TopicArea,
        LastAreaIndex
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
        outer apply TopicXML.nodes('/response/entity_list/entity') as element(entities)
        outer apply entities.nodes('sementity/type') as etype(type)
        --outer apply [db-au-cmdwh].dbo.fn_DelimitedSplit8K(type.value('(text())[1]', 'varchar(max)'), '>') tt
        outer apply
        (
            select
                type.value('(text())[1]', 'varchar(max)') TopicArea,
                charindex('>', reverse(type.value('(text())[1]', 'varchar(max)'))) LastAreaIndex
        ) ta
    where
        Classification is not null 
)
select 
    BIRowID,
    --PolicyTransactionKey,
    --ClaimKey,
    --CaseKey,
    Topic,
    --Item TopicArea,
    case
        when LastAreaIndex = 0 then TopicArea
        else ltrim(rtrim(right(TopicArea, LastAreaIndex - 1)))
    end TopicArea,
    Relevance
    --,
    --dense_rank() over (partition by BIRowID order by Relevance desc) RelevanceRank
from
    cte_topic


GO
