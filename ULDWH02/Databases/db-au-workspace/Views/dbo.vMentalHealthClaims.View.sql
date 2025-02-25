USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vMentalHealthClaims]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vMentalHealthClaims] as
select 
    t.*,
    cat.value('code[1]', 'varchar(max)') Classification,
    cat.value('abs_relevance[1]', 'float') Relevance
from
    [db-au-workspace]..clmClaimMentalhealth t
    outer apply
    (
        select 
            convert(xml, replace(t.MHClassification, '"utf-8"', '"utf-16"')) ClassificationXML
    ) tx
    outer apply ClassificationXML.nodes('/response/category_list/category') as class(cat)
--where
--    MHClassification is not null and
--    MHClassification like '%MENTAL%'
--order by
--    10 desc

GO
