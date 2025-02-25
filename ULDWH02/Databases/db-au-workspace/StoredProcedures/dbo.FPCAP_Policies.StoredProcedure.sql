USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[FPCAP_Policies]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[FPCAP_Policies]
as
begin

    if object_id('tempdb..#fp') is not null
        drop table #fp

    select 
        p.PolicyNumber,
        p.IssueDate,
        p.StatusDescription PolicyStatus,
        pt.SellPrice,
        pt.CCPayment
    into #fp
    from
        [db-au-cmdwh]..penPolicy p with(nolock)
        cross apply
        (
            select 
                sum(pt.GrossPremium) SellPrice,
                sum(isnull(pp.Total, 0)) CCPayment
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
                left join [db-au-cmdwh]..penPayment pp with(nolock) on
                    pp.PolicyTransactionKey = pt.PolicyTransactionKey
            where
                pt.PolicyKey = p.PolicyKey
        ) pt
    where
        exists
        (
            select
                null
            from
                [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
                inner join [db-au-cmdwh]..penPolicyTransAddOn pta with(nolock) on
                    pta.PolicyTransactionKey = pt.PolicyTransactionKey
            where
                pta.AddOnGroup = 'Ancillary Products' and
                pt.PolicyKey = p.PolicyKey
        )

    if object_id('tempdb..#dump') is not null
        drop table #dump

    select *
    into #dump
    from
        [BHDWH03].[db-au-snapshot].[dbo].[impulse_archive_policies_idx]
    where
        PolicyNumber in
        (
            select 
                PolicyNumber
            from
                #fp
        )

    if object_id('tempdb..#json') is not null
        drop table #json

    select 
        BIRowID,
        data JSONString
    into #json
    from
        [BHDWH03].[db-au-snapshot].[dbo].[impulse_archive_policies]
    where
        BIRowID in
        (
            select 
                BIRowID
            from
                #dump
        )

    select 
        p.*,
        case
            when SellPrice = 0 then 0
            else FPSell
        end FPSell,
        json_value(j.JSONString, '$.payment.referenceNumber') WestPacRef
    from
        #json j
        inner join #dump d on
            d.BIRowID = j.BIrowID 
        inner join #fp p on
            p.PolicyNumber = d.PolicyNumber
        cross apply 
        (
            select 
                sum(try_convert(decimal(10,2), json_value(cs.value, '$.lineGrossPrice'))) FPSell
            from
                openjson(j.JSONString, '$.policyCostStatement.lineItems') cs
            where
                json_value(cs.value, '$.lineCategoryCode') = 'FPCAP'
        ) cs

end
GO
