USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactBDMCalls]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vfactBDMCalls]
as
select  
    row_number() over (order by sfa.CallStartTime, sfa.CallID) BIRowID,
    ref.OutletReference,
    do.OutletSK,
    dd.Date_SK,
    isnull(ddo.DomainSK, -1) DomainSK,
    isnull(sfa.CallType, 'Unknown') CallType,
    isnull(sfa.CallCategory, 'Unknown') CallCategory,
    isnull(sfa.CallSubCategory, 'Unknown') CallSubCategory,
    1 CallCount,
    sfa.CallDuration
from
    [db-au-star]..dimOutlet do
    inner join [db-au-cmdwh]..sfAccount sf on
        sf.AgencyID = (do.Country + '.CMA.' + do.AlphaCode)
    inner join [db-au-cmdwh]..sfAgencyCall sfa on
        sfa.AccountID = sf.AccountID
    cross apply
    (
        select top 1 
            Date_SK
        from    
            [db-au-star]..Dim_Date dd
        where
            dd.[Date] = convert(date, CallStartTime)
    ) dd
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) ref
    outer apply
    (
        select top 1 
            ddo.DomainSK
        from
            dimDomain ddo
        where
            ddo.CountryCode = do.Country
    ) ddo
where
    sfa.CallStartTime >= '2011-07-01'


GO
