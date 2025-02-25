USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_dimOutlet]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_ic_dimOutlet]
as
select --top 100
    do.*,
    case 
        when StateSalesArea in ('New South Wales', 'NSW', 'Australian Capital Territory', 'ACT') then 'NSW/ACT' 
        when StateSalesArea in ('Queensland', 'QLD', 'Western Australia', 'WA') then 'QLD/WA' 
        when StateSalesArea in ('Victoria', 'VIC', 'Tasmania', 'TAS', 'South Australia', 'SA', 'Northern Territory', 'NT') then 'VIC/TAS/SA/NT' 
        else 'Other' 
    end Territory, 
    do.AlphaLineage [Alpha Lineage],
    0 Percentile,
    '' OutletTier,
    0 OutletTierSort
from
    dimOutlet do
GO
