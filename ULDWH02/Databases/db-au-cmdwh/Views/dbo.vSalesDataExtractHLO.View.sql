USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vSalesDataExtractHLO]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vSalesDataExtractHLO] as
select 
    t.*,
	o.*
from
    usrSalesDataExtractHLO t with(nolock)
    outer apply
    (
        select top 1 
			Branch,
            StateSalesArea
        from
            [db-au-star]..dimOutlet do
        where
            do.Country = t.CountryCode and
            do.AlphaCode = t.AlphaCode and
            do.GroupName = t.GroupName
    ) o
where
    Date >= '2013-07-01'

GO
