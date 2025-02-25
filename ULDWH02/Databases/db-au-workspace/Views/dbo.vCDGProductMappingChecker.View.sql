USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vCDGProductMappingChecker]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vCDGProductMappingChecker] as
select *
from
    [db-au-cmdwh]..cdgProduct p
    outer apply
    (
        select top 1 
            ProductKey
        from
            [db-au-cmdwh]..usrCDGQuoteProduct qp
        where
            qp.ProductID = p.ProductID
    ) pk
where
    pk.ProductKey is null
GO
