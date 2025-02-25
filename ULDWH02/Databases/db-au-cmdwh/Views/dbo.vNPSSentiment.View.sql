USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vNPSSentiment]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vNPSSentiment] as
select 
    t.BIRowID,
    --pt.PolicyTransactionKey,
    --cl.ClaimKey,
    --ma.CaseKey,
    response.value('score_tag[1]', 'varchar(max)') ScoreTag,
    response.value('agreement[1]', 'varchar(max)') Agreement,
    response.value('subjectivity[1]', 'varchar(max)') Subjectivity,
    response.value('confidence[1]', 'int') Confidence,
    response.value('irony[1]', 'varchar(max)') Irony
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
            convert(xml, replace(t.Topic, '"utf-8"', '"utf-16"')) TopicXML,
            convert(xml, replace(t.Sentiment, '"utf-8"', '"utf-16"')) SentimentXML
    ) tx
    outer apply SentimentXML.nodes('/response') as element(response)
    --outer apply entities.nodes('sementity/type') as etype(type)
    --outer apply [db-au-cmdwh].dbo.fn_DelimitedSplit8K(type.value('(text())[1]', 'varchar(max)'), '>') tt
where
    Classification is not null 

GO
