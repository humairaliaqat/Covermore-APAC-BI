USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Customer]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Customer]
    @Customer EVSearch readonly,
    @Refresh bit = 0

as
begin

    insert into [db-au-workspace].[opsupport].[ev_customer]
    (
        [CustomerID],
        [MergedTo],
        [CreateDate],
        [UpdateDate],
        [Status],
        [CustomerName],
        [CustomerRole],
        [Title],
        [FirstName],
        [MidName],
        [LastName],
        [Gender],
        [MaritalStatus],
        [DOB],
        [isDeceased],
        [CurrentAddress],
        [CurrentEmail],
        [CurrentContact],
        [SortID],
        [PrimaryScore],
        [SecondaryScore],
        [RiskCategory],
        [ForceFlag],
        [BlockFlag],
        [Alias],
        [Comment],
        [isEmployee]
    )
    select 
        [CustomerID],
        [MergedTo],
        [CreateDate],
        [UpdateDate],
        [Status],
        isnull(lp.LastRecordedName, ec.CustomerName) CustomerName,
        [CustomerRole],
        [Title],
        ec.[FirstName],
        [MidName],
        ec.[LastName],
        [Gender],
        [MaritalStatus],
        isnull([DOB], '1900-01-01') [DOB],
        [isDeceased],
        [CurrentAddress],
        [CurrentEmail],
        [CurrentContact],
        isnull(ForceFlag, 0) * 10000 + isnull(BlockFlag, 0) * 100000 + isnull(ClaimScore, PrimaryScore) [SortID],
        isnull(ClaimScore, PrimaryScore) PrimaryScore,
        SecondaryScore,
        case
            when isnull(BlockScore, 0) > 0 then 'Blocked'
            when ec.ClaimScore >= 3000 then 'Very high risk'
            when ec.ClaimScore >= 500 then 'High risk'
            when ec.ClaimScore >= 10 then 'Medium risk'

            when ec.PrimaryScore >= 5000 then 'Very high risk'
            when ec.SecondaryScore >= 6000 then 'Very high risk by association'
            when ec.PrimaryScore >= 3000 then 'High risk'
            when ec.SecondaryScore >= 4000 then 'High risk by association'
            when ec.PrimaryScore > 1500 then 'Medium risk'
            when ec.SecondaryScore > 2000 then 'Medium risk by association'
            else 'Low risk'
        end RiskCategory,
        isnull(ForceFlag, -1) ForceFlag,
        isnull(BlockFlag, 0) BlockFlag,
        ea.Alias,

        case
            when isnull(bl.BlockScore, 0) > 0 then '<span>BLOCKED!</span><p/><p/>'
            when ForceFlag = 1 then '<span>Multiple consecutive annual policies</span><p/><p/>'
            else ''
        end +
        case
            when ec.ClaimScore >= 3000 then '<span>Very high risk</span><p/>'
            when ec.ClaimScore >= 500 then '<span>High risk</span><p/>'
            when ec.ClaimScore >= 10 then '<span>Medium risk</span><p/>'

            when ec.PrimaryScore - isnull(bl.BlockScore, 0) >= 5000 then '<span>Very high risk</span><p/>'
            when ec.SecondaryScore >= 5000 then '<span>Very high risk by association</span><p/>'
            when ec.PrimaryScore - isnull(bl.BlockScore, 0) >= 2000 then '<span>High risk</span><p/>'
            when ec.SecondaryScore >= 2000 then '<span>High risk by association</span><p/>'
            when ec.PrimaryScore - isnull(bl.BlockScore, 0) > 750 then '<span>Medium risk</span><p/>'
            when ec.SecondaryScore > 750 then '<span>Medium risk by association</span><p/>'
            else ''--'Low Risk'
        end +
        '<span>' + isnull(bl.Reason, '') + '</span><p/>' + 
        '<span>' +
        case
            when bl.Reason is not null then ''
            else
                isnull
                (
                    (
                        select 
                            convert(varchar, count(ClaimNo)) + ' category ' + Classification + ' claims'
                        from
                            [db-au-cmdwh].[dbo].vEnterpriseClaimClassification with(nolock)
                        where
                            ClaimKey in
                            (
                                select 
                                    ClaimKey
                                from
                                    [db-au-cmdwh].[dbo].entPolicy ep with(nolock)
                                where
                                    ep.CustomerID = ec.CustomerID
                                    --ec.CUstomerName = 'katrine hermansen'
                            ) and
                            Classification in ('Red', 'Amber', 'Yellow')
                        group by
                            Classification
                        order by
                            case
                                when Classification = 'Red' then 1
                                when Classification = 'Amber' then 2
                                when Classification = 'Yellow' then 3
                                else 4
                            end
                        for xml path ('')
                    ),
                    ''
                )
        end + 
        '</span><p/>' +
        '<span>' +
        case
            when isnull(SanctionScore, 0) < 5 then ''
            when SanctionScore < 10 then 'Low risk Sanction check, matched last name and year of birth'
            when SanctionScore < 15 then 'Low risk Sanction check, matched last name, year and month of birth'
            when SanctionScore < 25 then 'Low risk Sanction check, matched combination of names, within 1 day variance of date of birth'
            when SanctionScore < 30 then 'Medium risk Sanction check, matched last name, same date of birth'
            else 'High risk Sanction check, matched combination of names, same data of birth'
        end +
        '</span>'
        Comment,
        case
            when
                exists
                (
                    select 
                        null
                    from
                        [db-au-cmdwh].dbo.usrAttrition a with(nolock)
                    where
                        a.EmployeeName like '%' + ns.FirstName + '%' and
                        a.EmployeeName like '%' + ns.LastName + '%' and
                        a.DOB = ec.DOB
                )
            then 1
            else 0
        end [isEmployee]

    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        cross apply
        (
            select
                max(convert(int, r.ForceInclude)) ForceFlag
            from 
                @Customer r
            where
                r.CustomerID = ec.CustomerID 
        ) f
        outer apply
        (
            select top 1 
                9001 BlockScore,
                1 BlockFlag,
                Reason
            from
                [db-au-cmdwh].dbo.entBlacklist bl with(nolock)
            where
                bl.CustomerID = ec.CustomerID
        ) bl
        outer apply
        (
            select top 1 
                isnull(ltrim(rtrim(ptv.FirstName)) + ' ', '') + isnull(ltrim(rtrim(ptv.LastName)), '') LastRecordedName
            from
                [db-au-cmdwh].[dbo].[entPolicy] ep with(nolock)
                inner join [db-au-cmdwh].[dbo].[penPolicy] p with(nolock) on
                    p.PolicyKey = ep.PolicyKey
                inner join [db-au-cmdwh].[dbo].[penPolicyTraveller] ptv with(nolock) on
                    ptv.PolicyKey = p.PolicyKey and
                    ptv.PolicyTravellerKey = ep.Reference
            where
                ep.CustomerID = ec.CustomerID and
                p.ProductName not like '%base%'
            order by
                p.IssueDate desc
        ) lp
        outer apply
        (
            select top 1 
                [db-au-cmdwh].dbo.fn_ProperCase(ea.Alias) Alias
            from
                [db-au-cmdwh].dbo.entAlias ea with(nolock)
            where
                ea.CustomerID = ec.CustomerID and
                lower(ea.Alias) <> lower(isnull(lp.LastRecordedName, ec.CustomerName))
        ) ea

        cross apply 
        (
            select 
                max
                (
                    case
                        when ItemNumber = 1 then lower(Item)
                        else null
                    end
                ) FirstName,
                coalesce
                (
                    max
                    (
                        case
                            when ItemNumber = 5 then lower(Item)
                            else null
                        end
                    ),
                    max
                    (
                        case
                            when ItemNumber = 4 then lower(Item)
                            else null
                        end
                    ),
                    max
                    (
                        case
                            when ItemNumber = 3 then lower(Item)
                            else null
                        end
                    ),
                    max
                    (
                        case
                            when ItemNumber = 2 then lower(Item)
                            else null
                        end
                    )
                ) LastName
            from
                [db-au-cmdwh].dbo.fn_DelimitedSplit8K(replace(isnull(lp.LastRecordedName, ec.CustomerName), ',', ''), ' ') r
        ) ns

    where
        ec.CustomerID = isnull(ec.MergedTo, ec.CustomerID) and
        (
            ClaimScore >= 10 or
            (
                ClaimScore is null and
                (
                    PrimaryScore > 1000 or
                    SecondaryScore > 1500
                )
            ) or
            ForceFlag = 1 or
            @Refresh = 0
        ) and
        ec.CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        ) and
        ec.CustomerID not in
        (
            select 
                CustomerID
            from
                [db-au-workspace].[opsupport].[ev_customer]
        )

        and
        not
        (
            ec.MidName = 'base' and
            ec.FirstName in ('Bankwest', 'Cba')
        )

end
GO
