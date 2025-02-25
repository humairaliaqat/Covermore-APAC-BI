USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactClaimActivity]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE view [dbo].[vfactClaimActivity] as  
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
where concat(f.ClaimKey,f.ActivityID) not in   
(select concat(ClaimKey,ActivityID) from factClaimActivity where ClaimKey in ('AU-129186')  
and ActivityID in('AUV3D9693540-09FB-4648-B996-F2EC1262FF53') ) 
  
  
GO
