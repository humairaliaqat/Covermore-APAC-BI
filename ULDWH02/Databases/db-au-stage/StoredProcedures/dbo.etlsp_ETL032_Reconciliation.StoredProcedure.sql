USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_Reconciliation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_Reconciliation]
as
begin

/****************************************************************************************************/
--  Name:           etlsp_ETL032_Reconciliation
--  Author:         Leonardus S
--  Date Created:   20140910
--  Description:    This stored procedure build policy cube recon tables, depends on sucessful run of ETL032
--  Parameters:     
--
--  Change History: 20140910 - LS - created
--                  20150204 - LS - change factQuoteTransaction -> factQuoteSummary
--
/****************************************************************************************************/


    --ODS policy
    if object_id('[db-au-workspace]..ETL032_recon_odspolicy') is not null
        drop table [db-au-workspace]..ETL032_recon_odspolicy

    select 
        pt.CountryKey [Country],
        coalesce(o.AlphaCode, right(OutletAlphaKey, charindex('-', reverse(pt.OutletAlphaKey)) - 1), 'UNKNOWN') [Alpha],
        isnull(JVCode, 'UNKNOWN') [JV],
        convert(date, convert(varchar(8), PostingDate, 120) + '01') [Month],
        sum(pp.Premium) [Premium],
        sum(pp.[Sell Price]) [Sell Price],
        sum(pp.[GST on Sell Price]) [GST],
        sum(BasePolicyCount) [Policy Count]
    into [db-au-workspace]..ETL032_recon_odspolicy
    from
        [db-au-cmdwh]..penPolicyTransSummary pt
        outer apply
        (
            select top 1
                AlphaCode,
                jv.JVCode
            from
                [db-au-cmdwh]..penOutlet o
                inner join [db-au-cmdwh]..vpenOutletJV jv on
                    jv.OutletKey = o.OutletKey
            where
                o.OutletAlphaKey = pt.OutletAlphaKey and
                o.OutletStatus = 'Current'
        ) o
        inner join [db-au-cmdwh]..vPenguinPolicyPremiums pp on
            pp.PolicyTransactionKey = pt.PolicyTransactionKey
    where
        PostingDate < convert(date, getdate())
    group by
        pt.CountryKey,
        coalesce(o.AlphaCode, right(OutletAlphaKey, charindex('-', reverse(pt.OutletAlphaKey)) - 1), 'UNKNOWN'),
        isnull(JVCode, 'UNKNOWN'),
        convert(date, convert(varchar(8), PostingDate, 120) + '01')

    create nonclustered index idx_alpha on [db-au-workspace]..ETL032_recon_odspolicy ([Country], [Alpha], [Month]) include([JV], [Premium], [Sell Price], [GST], [Policy Count])
    create nonclustered index idx_jv on [db-au-workspace]..ETL032_recon_odspolicy ([JV], [Month]) include([Premium], [Sell Price], [GST], [Policy Count])

    --ODS quote
    if object_id('[db-au-workspace]..ETL032_recon_odsquote') is not null
        drop table [db-au-workspace]..ETL032_recon_odsquote

    select 
        q.CountryKey [Country],
        coalesce(o.AlphaCode, right(OutletAlphaKey, charindex('-', reverse(q.OutletAlphaKey)) - 1), 'UNKNOWN') [Alpha],
        isnull(JVCode, 'UNKNOWN') [JV],
        convert(date, convert(varchar(8), CreateDate, 120) + '01') [Month],
        count(q.QuoteKey) [Quote Count]
    into [db-au-workspace]..ETL032_recon_odsquote
    from
        [db-au-cmdwh]..penQuote q
        outer apply
        (
            select top 1
                AlphaCode,
                jv.JVCode
            from
                [db-au-cmdwh]..penOutlet o
                inner join [db-au-cmdwh]..vpenOutletJV jv on
                    jv.OutletKey = o.OutletKey
            where
                o.OutletAlphaKey = q.OutletAlphaKey and
                o.OutletStatus = 'Current'
        ) o
    where
        CreateDate < convert(date, getdate())
    group by
        q.CountryKey,
        coalesce(o.AlphaCode, right(OutletAlphaKey, charindex('-', reverse(q.OutletAlphaKey)) - 1), 'UNKNOWN'),
        isnull(JVCode, 'UNKNOWN'),
        convert(date, convert(varchar(8), CreateDate, 120) + '01')

    create nonclustered index idx_alpha on [db-au-workspace]..ETL032_recon_odsquote ([Country], [Alpha], [Month]) include([JV], [Quote Count])
    create nonclustered index idx_jv on [db-au-workspace]..ETL032_recon_odsquote ([JV], [Month]) include([Quote Count])

    --STAR policy
    if object_id('[db-au-workspace]..ETL032_recon_starpolicy') is not null
        drop table [db-au-workspace]..ETL032_recon_starpolicy

    select 
        o.Country [Country],
        isnull(o.AlphaCode, 'UNKNOWN') [Alpha],
        isnull(o.JV, 'UNKNOWN') [JV],
        d.CurMonthStart [Month],
        sum(pt.Premium) [Premium],
        sum(pt.SellPrice) [Sell Price],
        sum(pt.PremiumGST) [GST],
        sum(pt.PolicyCount) [Policy Count]
    into [db-au-workspace]..ETL032_recon_starpolicy
    from
        [db-au-star]..factPolicyTransaction pt
        inner join [db-au-star]..dimOutlet o on
            o.OutletSK = pt.OutletSK
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = pt.DateSK
    where
        d.[Date] < convert(date, getdate())
    group by
        o.Country,
        o.AlphaCode,
        o.JV,
        d.CurMonthStart

    create nonclustered index idx_alpha on [db-au-workspace]..ETL032_recon_starpolicy ([Country], [Alpha], [Month]) include([JV], [Premium], [Sell Price], [GST], [Policy Count])
    create nonclustered index idx_jv on [db-au-workspace]..ETL032_recon_starpolicy ([JV], [Month]) include([Premium], [Sell Price], [GST], [Policy Count])

    --STAR quote
    if object_id('[db-au-workspace]..ETL032_recon_starquote') is not null
        drop table [db-au-workspace]..ETL032_recon_starquote
        
    select 
        o.Country [Country],
        isnull(o.AlphaCode, 'UNKNOWN') [Alpha],
        isnull(o.JV, 'UNKNOWN') [JV],
        d.CurMonthStart [Month],
        sum(q.QuoteCount) [Quote Count]
    into [db-au-workspace]..ETL032_recon_starquote
    from
        [db-au-star]..factQuoteSummary q
        inner join [db-au-star]..dimOutlet o on
            o.OutletSK = q.OutletSK
        inner join [db-au-star]..Dim_Date d on
            d.Date_SK = q.DateSK
    where
        d.[Date] < convert(date, getdate())
    group by
        o.Country,
        o.AlphaCode,
        o.JV,
        d.CurMonthStart

    create nonclustered index idx_alpha on [db-au-workspace]..ETL032_recon_starquote ([Country], [Alpha], [Month]) include([JV], [Quote Count])
    create nonclustered index idx_quote on [db-au-workspace]..ETL032_recon_starquote ([JV], [Month]) include([Quote Count])


    --Policy Cube
    if object_id('[db-au-workspace]..ETL032_recon_policycube') is not null
        drop table [db-au-workspace]..ETL032_recon_policycube
        
    declare @sql varchar(max)
    set @sql =
        '
        select 
            convert(varchar, "[Domain].[Country Code].[Country Code].[MEMBER_CAPTION]") [Country],
            case
                when rtrim(convert(varchar, "[Outlet].[JV].[JV].[MEMBER_CAPTION]")) = '''' then ''UNKNOWN''
                else rtrim(convert(varchar, "[Outlet].[JV].[JV].[MEMBER_CAPTION]"))
            end [JV],
            case
                when rtrim(convert(varchar, "[Outlet].[Alpha Code].[Alpha Code].[MEMBER_CAPTION]")) = '''' then ''UNKNOWN''
                else convert(varchar, "[Outlet].[Alpha Code].[Alpha Code].[MEMBER_CAPTION]")
            end [Alpha],
            convert(date, convert(varchar(max), "[Date].[Calendar Year Month].[Calendar Year Month].[MEMBER_CAPTION]") + ''-01'') [Month],
            case
                when charindex(''E-'', "[Measures].[Sell Price]") > 0 then 0
                when isnumeric("[Measures].[Sell Price]") = 1 then convert(money, "[Measures].[Sell Price]")
                else 0
            end [Sell Price],
            case
                when charindex(''E-'', "[Measures].[Premium]") > 0 then 0
                when isnumeric("[Measures].[Premium]") = 1 then convert(money, "[Measures].[Premium]") 
                else 0
            end [Premium],
            case
                when charindex(''E-'', "[Measures].[Premium GST]") > 0 then 0
                when isnumeric("[Measures].[Premium GST]") = 1 then convert(money, "[Measures].[Premium GST]")
                else 0
            end [GST],
            case
                when charindex(''E-'', "[Measures].[Policy Count]") > 0 then 0
                when isnumeric("[Measures].[Policy Count]") = 1 then convert(int, "[Measures].[Policy Count]") 
                else 0
            end [Policy Count],
            case
                when charindex(''E-'', "[Measures].[Quote Count]") > 0 then 0
                when isnumeric("[Measures].[Quote Count]") = 1 then convert(int, "[Measures].[Quote Count]") 
                else 0
            end [Quote Count]
        into [db-au-workspace]..ETL032_recon_policycube
        from
            openquery(
                POLICYCUBE,
                ''
                select 
                    { 
                        [Measures].[Sell Price],
                        [Measures].[Premium],
                        [Measures].[Premium GST],
                        [Measures].[Policy Count],
                        [Measures].[Quote Count]
                    } on columns, 
                    non empty { 
                        (
                            [Domain].[Country Code].children,
                            [Outlet].[JV].children,
                            [Outlet].[Alpha Code].children,
                            exists
                            (
                                [Date].[Calendar Year Month].children,
                                {
                                    except
                                    (
                                        [Date].[Date].children,
                                        [Date].[Date].&[' + replace(convert(varchar(10), getdate(), 120), '-', '') + ']
                                    )
                                }
                            )
                        ) 
                    } on rows 
                from 
                    [Policy Cube] 
                ''
            )
        '
        
    exec(@sql)

    --GL Cube
    if object_id('[db-au-workspace]..ETL032_recon_glcube') is not null
        drop table [db-au-workspace]..ETL032_recon_glcube
        
    select 
        case
            when rtrim(convert(varchar, "[Joint Venture].[Joint Venture Code].[Joint Venture Code].[MEMBER_CAPTION]")) = '' then 'UNKNOWN'
            else convert(varchar, "[Joint Venture].[Joint Venture Code].[Joint Venture Code].[MEMBER_CAPTION]")
        end [JV],
        convert(date, right([DateString], 4) + '-' + substring([DateString], 4, 2) + '-01') [Month],
        case
            when charindex('E-', "[Account].[Account Code].&[691]") > 0 then 0
            when isnumeric("[Account].[Account Code].&[691]") = 1 then -convert(money, "[Account].[Account Code].&[691]") 
            else 0
        end [Premium],
        case
            when charindex('E-', "[Account].[Account Code].&[388]") > 0 then 0
            when isnumeric("[Account].[Account Code].&[388]") = 1 then convert(int, "[Account].[Account Code].&[388]") 
            else 0
        end [Policy Count]
    into [db-au-workspace]..ETL032_recon_glcube
    from
        openquery(
            GLCUBE,
            '
            select 
                { 
                    [Account].[Account Code].&[691],
                    [Account].[Account Code].&[388]
                } on columns, 
                non empty { 
                    ( 
                        [Joint Venture].[Joint Venture Code].children,
                        [Date].[Date].children
                    ) 
                } on rows 
            from 
                [Finance_GL] 
            where 
                ( 
                    [Measures].[General Ledger Amount],
                    --IAU
                    [Business Unit].[Business Unit Code].&[17], 
                    --Actuals 
                    union([Scenario].[Scenario Code].&[A], [Scenario].[Scenario Code].&[C]),
                    --Remove Corporate Policies 
                    except( 
                        [GL Product].[GL Product Code].children, 
                        [GL Product].[GL Product Code].&[CMC] 
                    ) 
                ) 
            '
        ) t
        cross apply
        (
            select
                convert(varchar(max), "[Date].[Date].[Date].[MEMBER_CAPTION]") [DateString]
        ) ds

end
GO
