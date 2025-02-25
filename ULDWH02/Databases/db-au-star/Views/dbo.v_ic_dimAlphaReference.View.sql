USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_dimAlphaReference]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_ic_dimAlphaReference]
as
select
    'Point in time' OutletReference, 
    OutletSK, 
    OutletSK ReferenceSK, 
    'PT' + convert(varchar(max), OutletSK) RefSK
from
    dimOutlet

union all

select
    'Latest alpha' OutletReference, 
    OutletSK, 
    LatestOutletSK ReferenceSK, 
    'LA' + convert(varchar(max), OutletSK) RefSK
from
    dimOutlet
GO
