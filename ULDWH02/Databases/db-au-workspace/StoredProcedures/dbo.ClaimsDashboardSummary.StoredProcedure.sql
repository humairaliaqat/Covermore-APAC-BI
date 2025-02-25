USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[ClaimsDashboardSummary]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[ClaimsDashboardSummary]
    @Month date

as
begin
    
    --declare @month date
    --set @month = '2016-07-01'

    declare @sql varchar(max)
    declare @fyperiod varchar(7)
    declare @fyperiodlag varchar(7)
    declare @sunperiod int
    declare @icube 
        table 
        (
            [Category] varchar(100),
            [Section] varchar(100),
            [Pre First Nil Payment] float,
            [Pre First Nil Avg Payment] float,
            [Pre First Nil Count] float,
            [Post First Nil Count] float,
            [Reopen Rate] float,
            [Avg Claim Value] float,
            [Total Claim Payment] float,
            [Incurred] float,
            [Claim Count] float
        )
    declare @icube_received
        table 
        (
            [Category] varchar(100),
            [Section] varchar(100),
            [Claim Count] float
        )
    declare @pcube 
        table 
        (
            [Policy Count] float,
            [Sell Price] float
        )
    declare @opex float
    

    set nocount on

    set @month = convert(date, convert(varchar(8), @month, 120) + '01')

    select 
        @sunperiod = SUNPeriod,
        @fyperiod = left(SUNPeriod, 4) + '-' + right(SUNPeriod, 2)
    from
        [db-au-cmdwh]..Calendar
    where
        [Date] = @month

    select 
        @fyperiodlag = left(SUNPeriod, 4) + '-' + right(SUNPeriod, 2)
    from
        [db-au-cmdwh]..Calendar
    where
        [Date] = dateadd(month, -4, @month)

    /*policy - start*/
    set @sql =
    '
    select
        *
    from
        openquery(
            POLICYCUBE,
            ''
            select 
                {
                    [Measures].[Policy Count],
                    [Measures].[Sell Price]
                } on columns
            from 
                [Policy Cube] 
            where 
                (
                    [Domain].[Country Code].&[AU],
                    [Date].[Fiscal Date Hierarchy].[Fiscal Year Month].&[' + @fyperiodlag + ']
                )
            ''
        )
    '

    insert into @pcube
    exec (@sql)
    /*policy - end*/

    /*opex - start*/

    if object_id('tempdb..#opex') is not null
        drop table #opex

    select 
        @opex = sum(-GLAmount)
    from
     --   [db-au-cmdwh]..glTransactions gl with(nolock)
  --      inner join [db-au-cmdwh]..Calendar dd with(nolock) on
		 [db-au-cmdwh]..glTransactions gl 
        inner join [db-au-cmdwh]..Calendar dd on
            dd.SUNPeriod = gl.Period and
            datepart(day, dd.[Date]) = 1
    where
        gl.ScenarioCode = 'A' and
        gl.BusinessUnit = 'IAU' and
        gl.Period = @sunperiod and
        gl.AccountCode in 
        (
            select 
                Descendant_Code
            from
                [db-au-star]..vAccountAncestors aa
            where
                aa.Account_Code = 'PAT'
        ) and
        gl.DepartmentCode = '24'

    /*opex - end*/

    /*all*/
    set @sql =
    '
    select
        ''ALL'',
        ''ALL'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns
            from 
                [Insurance Cube]
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '

    insert into @icube
    exec (@sql)

    /*all category by section*/
    set @sql =
    '
    select
        ''ALL'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows 
            from 
                [Insurance Cube]
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '

    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''ALL'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows 
            from 
                [Insurance Cube]
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)

    /**/

    /*catastrophe*/
    set @sql =
    '
    select
        ''CAT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows 
            from 
                [Insurance Cube]
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + '],
                    [Claim Event].[Event Hierarchy].[Event Type].&[Catastrophe]    
                )
            ''
        )
    '

    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''CAT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows 
            from 
                [Insurance Cube]
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + '],
                    [Claim Event].[Event Hierarchy].[Event Type].&[Catastrophe]    
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)

    /*major international*/
    set @sql =
    '
    select
        ''Major INT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[], 
                                [Product].[Plan Type].&[Other], 
                                [Product].[Plan Type].&[International], 
                                [Product].[Plan Type].&[Domestic Inbound] 
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[75000], 
                                [Claim].[Last Incurred Band].&[200000], 
                                [Claim].[Last Incurred Band].&[500000], 
                                [Claim].[Last Incurred Band].&[500001] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
    
    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''Major INT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[], 
                                [Product].[Plan Type].&[Other], 
                                [Product].[Plan Type].&[International], 
                                [Product].[Plan Type].&[Domestic Inbound] 
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[75000], 
                                [Claim].[Last Incurred Band].&[200000], 
                                [Claim].[Last Incurred Band].&[500000], 
                                [Claim].[Last Incurred Band].&[500001] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)


    /*major domestic*/
    set @sql =
    '
    select
        ''Major DOM'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[Domestic]
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[75000], 
                                [Claim].[Last Incurred Band].&[200000], 
                                [Claim].[Last Incurred Band].&[500000], 
                                [Claim].[Last Incurred Band].&[500001] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
    
    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''Major DOM'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[Domestic]
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[75000], 
                                [Claim].[Last Incurred Band].&[200000], 
                                [Claim].[Last Incurred Band].&[500000], 
                                [Claim].[Last Incurred Band].&[500001] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)


    /*minor international*/
    set @sql =
    '
    select
        ''Minor INT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[], 
                                [Product].[Plan Type].&[Other], 
                                [Product].[Plan Type].&[International], 
                                [Product].[Plan Type].&[Domestic Inbound] 
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[25000], 
                                [Claim].[Last Incurred Band].&[15000], 
                                [Claim].[Last Incurred Band].&[5000], 
                                [Claim].[Last Incurred Band].&[1500], 
                                [Claim].[Last Incurred Band].&[Unknown] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
    
    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''Minor INT'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[], 
                                [Product].[Plan Type].&[Other], 
                                [Product].[Plan Type].&[International], 
                                [Product].[Plan Type].&[Domestic Inbound] 
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[25000], 
                                [Claim].[Last Incurred Band].&[15000], 
                                [Claim].[Last Incurred Band].&[5000], 
                                [Claim].[Last Incurred Band].&[1500], 
                                [Claim].[Last Incurred Band].&[Unknown] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)


    /*minor international*/
    set @sql =
    '
    select
        ''Minor DOM'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            with
            member [Measures].[Total Claim Payment] as [Measures].[Claim Payment] - [Measures].[Claim Recovery]
            member [Measures].[Reopen Rate] as 
                case 
                    when [Measures].[Pre First Nil Count] = 0 then 0 
                    else [Measures].[Post First Nil Count] / [Measures].[Pre First Nil Count]
                end
            select 
                { 
                    [Measures].[Pre First Nil Payment],
                    [Measures].[Pre First Nil Avg Payment],
                    [Measures].[Pre First Nil Count],
                    [Measures].[Post First Nil Count],
                    [Measures].[Reopen Rate],
                    [Measures].[Avg Claim Value],
                    [Measures].[Total Claim Payment],
                    [Measures].[Incurred],
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[Domestic]
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[25000], 
                                [Claim].[Last Incurred Band].&[15000], 
                                [Claim].[Last Incurred Band].&[5000], 
                                [Claim].[Last Incurred Band].&[1500], 
                                [Claim].[Last Incurred Band].&[Unknown] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Date].[Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
    
    insert into @icube
    exec (@sql)

    set @sql =
    '
    select
        ''Minor DOM'',
        *
    from
        openquery(
            INSURANCECUBE,
            ''
            select 
                { 
                    [Measures].[Claim Count]
                } on columns, 
                ( 
                    { 
                        drilldownlevel({[Benefit].[Benefit Hierarchy].[All]},,,include_calc_members)
                    } 
                ) on rows
            from 
                (
                    select 
                        ( 
                            { 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Unknown], 
                                [Claim Event].[Event Hierarchy].[Event Type].&[Non-Catastrophe] 
                            }, 
                            { 
                                [Product].[Plan Type].&[Domestic]
                            }, 
                            { 
                                [Claim].[Last Incurred Band].&[25000], 
                                [Claim].[Last Incurred Band].&[15000], 
                                [Claim].[Last Incurred Band].&[5000], 
                                [Claim].[Last Incurred Band].&[1500], 
                                [Claim].[Last Incurred Band].&[Unknown] 
                            }                        
                        ) on columns 
                    from 
                        [Insurance Cube]
                ) 
            where 
                ( 
                    [Domain].[Country Code].&[AU], 
                    [Claim].[Receipt Date Hierarchy].[Receipt Fiscal Year Month].&[' + @fyperiod + ']
                )
            ''
        )
    '
        
    insert into @icube_received
    exec (@sql)


    if object_id('tempdb..##claimdashboardsummary') is not null --nested insert exec workaround
        drop table ##claimdashboardsummary


    select 
        @Month Period,
        [Category],
        s.[Section],
        sum(isnull([Pre First Nil Payment], 0)) [Claim Payments (First Closure)],
        case
            when sum(isnull([Pre First Nil Count], 0)) = 0 then 0
            else sum(isnull([Pre First Nil Payment], 0)) / sum(isnull([Pre First Nil Count], 0))
        end [Avg Claims (First Closure)],
        sum(isnull([Pre First Nil Count], 0)) [Claim Count (First Closure)],
        sum(isnull([Post First Nil Count], 0)) [Claim Count (Reopen)],
        case
            when sum(isnull([Pre First Nil Count], 0)) = 0 then 0
            else sum(isnull([Post First Nil Count], 0)) / sum(isnull([Pre First Nil Count], 0))
        end [Reopen Rate],
        sum(isnull([Incurred], 0)) [Claim Value],
        case
            when sum(isnull(t.[Claim Count], 0)) = 0 then 0
            else sum(isnull([Incurred], 0)) / sum(isnull(t.[Claim Count], 0))
        end [Avg Claim Value],
        sum(isnull([Total Claim Payment], 0)) [Total Claim Payment],
        avg(isnull(ox.CostPerClaim, 0)) [Cost per Claim],
        sum(isnull(ox.CostPerClaim, 0) * isnull([Pre First Nil Count], 0)) [Cost to Process],
        sum(isnull(r.[Claim Count], 0)) [Claim Count],
        avg(isnull(p.[Policy Count], 0)) [Policy Count],
        case
            when avg(isnull(p.[Policy Count], 0)) = 0 then 0
            else sum(isnull(r.[Claim Count], 0)) / avg(isnull(p.[Policy Count], 0))
        end [Claims Attachment Rate],
        avg(isnull(p.[Sell Price], 0)) [Sell Price],
        case
            when avg(isnull(p.[Sell Price], 0)) = 0 then 0
            else sum(isnull([Total Claim Payment], 0)) / avg(isnull(p.[Sell Price], 0))
        end [Loss Ratio]
    into ##claimdashboardsummary
    from
        @icube t
        cross apply
        (
            select
                case
                    when t.Section = 'Unknown' then 'Other'
                    else t.Section
                end Section
        ) s
        cross apply
        (
            select 
                case
                    when isnull([Pre First Nil Count], 0) = 0 then 0
                    else @opex / isnull([Pre First Nil Count], 0)
                end CostPerClaim
            from
                @icube ox
            where
                [Category] = 'ALL' and
                [Section] = 'ALL'
        ) ox
        cross apply
        (
            select 
                [Policy Count],
                [Sell Price]
            from
                @pcube p
        ) p
        cross apply
        (
            select 
                r.[Claim Count]
            from
                @icube_received r
            where
                r.Category = t.Category and
                isnull(r.Section, '') = isnull(t.Section, '')
        ) r
    --where
    --    [Category] <> 'ALL'
    group by
        [Category],
        s.[Section]

    select *
    from
        ##claimdashboardsummary

end
GO
