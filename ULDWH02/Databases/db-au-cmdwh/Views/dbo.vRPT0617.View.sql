USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vRPT0617]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vRPT0617]
as
select 
    pt.CountryKey [Country],
    pt.CompanyKey [Company],
    di.JobCode [Job],
    pim.BusinessUnit [Business Unit],
    pt.PostingDate [Posting Date],
    pt.IssueDate [Issue Date],
    pt.PolicyNumber [Policy Number],
    pt.GrossPremium [Sell Price],
    pt.UnAdjGrossPremium - pt.GrossPremium [Discount],
    pt.Commission [Agency Commission],
    pt.GrossAdminFee [Admin Fee],
    pt.UnAdjGrossPremium [Penguin RRP],
    pim.UnAdjustedTotal [Imported RRP],
    abs(pim.UnAdjustedTotal - pim.PenguinUnAdjustedTotal) [RRP Variance]
from
    penPolicyTransSummary pt
    cross apply
    (
        select top 1 
            UnAdjustedTotal,
            AdjustedTotal,
            PenguinUnAdjustedTotal,
            BusinessUnit,
            DataImportKey
        from
            penPolicyImport pim
        where
            pim.Status = 'DONE' and
            pim.CountryKey = pt.CountryKey and
            pim.PolicyNumber = pt.PolicyNumber and
            pim.PolicyID = pt.PolicyID
    ) pim
    cross apply
    (
        select top 1 
            j.JobName,
            j.JobCode
        from
            penDataImport di
            inner join penJob j on
                j.CountryKey = pt.CountryKey and
                j.JobID = di.JobID
        where
            di.DataImportKey = pim.DataImportKey
    ) di
where
    --PostingDate >= '2015-01-01' and
    --PostingDate <  '2015-02-01' and
    abs(pim.UnAdjustedTotal - pim.PenguinUnAdjustedTotal) > 0.01
--order by
--    1, 2, 3, 4
GO
