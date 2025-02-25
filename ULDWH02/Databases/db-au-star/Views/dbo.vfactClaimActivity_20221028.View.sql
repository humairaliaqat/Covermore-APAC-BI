USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactClaimActivity_20221028]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vfactClaimActivity_20221028] as
select --top 1000
    f.ActivityID, 
    convert(date, d.[Date]) DateSK, 
    f.DomainSK, 
    f.OutletSK, 
    f.AreaSK, 
    f.ProductSK, 
    f.ClaimSK, 
    f.ClaimEventSK, 
    f.ClaimKey, 
    f.PolicyTransactionKey, 
    f.e5Reference, 
    f.Activity, 
    f.CompletionDate, 
    f.CompletionUser, 
    f.ActivityOutcome, 
    f.CreateBatchID,
    isnull(ao.Name, '') Outcome
from
    factClaimActivity f 
    inner join Dim_Date as d on 
        d.Date_SK = f.Date_SK
    outer apply
    (
        select top 1 
            wi.Name
        from
            [db-au-cmdwh]..e5WorkItems wi
        where
            wi.ID = f.ActivityOutcome
    ) ao


GO
