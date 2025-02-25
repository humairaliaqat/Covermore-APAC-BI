USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0837]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0837]
    @ReportingPeriod varchar(30) = 'Last Month',
    @StartDate date = null,
    @EndDate date = null

as
begin

--20161207, LL, create

--declare
--    @ReportingPeriod varchar(30) = 'Last Month',
--    @StartDate date = null,
--    @EndDate date = null

    set nocount on

    declare 
        @start date,
        @end date

    if @ReportingPeriod = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod


    if object_id('tempdb..#transaction') is not null
        drop table #transaction

    select 
        p.CountryKey Country,
        'Policy' TransactionType,
        p.PolicyNumber TransactionReference,
        p.IssueDate TransactionDate,
        p.PolicyKey,
        ptv.PolicyTravellerKey Reference,
        ptv.FirstName + ' ' + ptv.LastName CustomerName,
        ptv.DOB
    into #transaction
    from
        [db-au-cmdwh]..penPolicy p with(nolock)
        inner join [db-au-cmdwh]..penPolicyTraveller ptv with(nolock) on
            ptv.PolicyKey = p.PolicyKey
    where
        p.CountryKey in ('AU', 'NZ', 'UK') and
        p.IssueDate >= @start and
        p.IssueDate <  dateadd(day, 1, @end)

    union all

    select 
        cp.CountryKey Country,
        'Claim' TransactionType,
        convert(varchar, cp.ClaimNo) TransactionReference,
        cp.ModifiedDate,
        pt.PolicyKey,
        cn.NameKey Reference,
        isnull(cn.Firstname + ' ', '') + isnull(cn.Surname, '') CustomerName,
        cn.DOB
    from
        [db-au-cmdwh]..clmPayment cp with(nolock)
        inner join [db-au-cmdwh]..clmName cn with(nolock) on
            cn.NameKey = cp.PayeeKey
        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
            cl.ClaimKey = cp.ClaimKey
        left join [db-au-cmdwh]..penPolicyTransaction pt with(nolock) on
            pt.PolicyTransactionKey = cl.PolicyTransactionKey
    where
        cp.CountryKey in ('AU', 'NZ', 'UK') and
        cp.ModifiedDate >= @start and
        cp.ModifiedDate <  dateadd(day, 1, @end)


    ;with
    cte_transaction as
    (
        select 
            t.Country,
            t.TransactionType,
            t.TransactionReference,
            t.TransactionDate,
            t.PolicyKey,
            t.Reference MDMReference,
            t.CustomerName,
            t.DOB,
            ns.Reference,
            ns.NameScore,
            isnull(ds.DOBScore, 0) DOBScore,
            ns.NameScore * ds.DOBScore Score
        from
            #transaction t
            outer apply
            (
                select
                    esn.Country,
                    esn.Reference,
                    sum
                    (
                        case
                            when esn.LastName = 1 and nf.LastName = 1 then 5
                            else 1
                        end 
                    ) NameScore
                from
                    (
                        select
                            NameFragment,
                            max(LastName) LastName
                        from
                            (
                                select
                                    isnull([db-au-workspace].dbo.fn_RemoveSpecialChars(r.Item), r.Item) NameFragment,
                                    case
                                        when r.ItemNumber = max(r.ItemNumber) over () then 1
                                        else 0
                                    end LastName
                                from
                                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(replace(t.CustomerName, '-', ''), ' ')  r
                            ) nf
                        group by
                            NameFragment
                    ) nf
                    inner join [db-au-cmdwh]..entSanctionedNames esn on
                        esn.Country = t.Country and
                        esn.NameFragment = nf.NameFragment
                group by
                    esn.Country,
                    esn.Reference

            ) ns
            outer apply
            (
                select top 1
                    case
                        when datediff(day, t.DOB, esd.DOB) = 0 then 5
                        when abs(datediff(day, t.DOB, esd.DOB)) = 1 then 3
                        when datepart(month, t.DOB) = esd.MOB then 2
                        else 1
                    end DOBScore
                from
                    [db-au-cmdwh]..entSanctionedDOB esd 
                where
                    esd.Country = ns.Country and
                    esd.Reference = ns.Reference and
                    esd.YOBStart <= datepart(year, t.DOB) and
                    esd.YOBEnd >= datepart(year, t.DOB)
                order by DOBScore desc
            ) ds
    ),
    cte_customer as
    (
        select 
            Country,
            TransactionType,
            TransactionReference,
            TransactionDate,
            PolicyKey,
            MDMReference,
            CustomerName,
            DOB,
            max(Score) Score
        from
            cte_transaction
        where
            Score >= 5
        group by
            Country,
            TransactionType,
            TransactionDate,
            TransactionReference,
            MDMReference,
            PolicyKey,
            CustomerName,
            DOB
    ),
    cte_highlight as
    (
        select 
            *,
            (
                select distinct
                    Reference + ','
                from
                    cte_transaction r
                where
                    r.Country = t.Country and
                    r.TransactionReference = t.TransactionReference and
                    r.TransactionType = t.TransactionType and
                    r.Score >= 5
                for xml path('')
            ) Refs
        from
            cte_customer t
    )
    select 
        *,
        case
            when Score < 10 then 'Low risk, matched last name and year of birth'
            when Score < 15 then 'Low risk, matched last name, year and month of birth'
            when Score < 25 then 'Low risk, matched combination of names, within 1 day variance of date of birth'
            when Score < 30 then 'Medium risk, matched last name, same date of birth'
            else 'High risk, matched combination of names, same data of birth'
        end Risk,
        @Start StartDate,
        @end EndDate
    from
        cte_highlight t
        outer apply
        (
            select top 1 
                CustomerID
            from
                entPolicy ep
            where
                ep.PolicyKey = t.PolicyKey and
                ep.Reference = t.MDMReference
        ) ep
    order by
        Country,
        Score desc,
        TransactionType,
        TransactionReference desc


end

GO
