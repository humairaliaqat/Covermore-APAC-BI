USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactCustomer]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vfactCustomer] 
as
with
cte_ref as
(
    select
        'Point in time' OutletReference
    union all
    select 
        'Latest alpha' OutletReference
)
select --top 1000
    isnull(dd.CustomerID, -1) CustomerID,
    case
        when 
            exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entPolicy r
                    inner join [db-au-cmdwh]..penPolicy rp on
                        rp.PolicyKey = r.PolicyKey
                where
                    r.CustomerID = dd.CustomerID and
                    rp.IssueDate < p.IssueDate
            )
        then null
        else dd.CustomerID
    end NewCustomerID,
    fpt.DateSK, 
    fpt.DomainSK, 
    ref.OutletReference, 
    fpt.OutletSK, 
    fpt.PolicySK, 
    fpt.AreaSK, 
    fpt.DestinationSK, 
    fpt.DurationSK, 
    fpt.ProductSK, 
    case 
        when datediff([day], p.issuedate, p.tripstart) < - 1 then - 1 
        when datediff([day], p.issuedate, p.tripstart) > 2000 then - 1 
        else datediff([day], p.issuedate, p.tripstart) 
    end LeadTime
from
    [db-au-star]..factPolicyTransaction fpt 
    inner join [db-au-star]..dimPolicy p on 
        p.PolicySK = fpt.PolicySK
    inner join cte_ref ref on
        1 = 1
    left join [db-au-star]..dimDemography dd on
        dd.PolicyKey = p.PolicyKey
where
    fpt.DateSK >= 20150101 and
    p.Country in ('AU', 'NZ') and
    TransactionType = 'Base' and 
    TransactionStatus = 'Active'



GO
