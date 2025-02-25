USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactPolicyAddon]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vfactPolicyAddon] as
select 
    t.*,
    ref.OutletReference
from
    [db-au-star]..factPolicyTransactionAddons t with(nolock)
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) ref
where
    DateSK >= 20150101



GO
