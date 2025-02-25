USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_star_factPortfolio]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_star_factPortfolio]
    @Start date,
    @End date
    
as
begin

--declare 
--    @start date,
--    @end date
--select
--    @start = '2014-10-01',
--    @end = '2014-10-31'

    set nocount on

    if object_id('[db-au-star]..factPortfolio') is null
    begin
    
        create table [db-au-star]..factPortfolio
        (
            [BIRowID] bigint not null identity(1,1),
	        [Date_SK] int not null,
            [Business_Unit_SK] int not null,
	        [AgeBandSK] int not null,
	        [AreaSK] int not null,
	        [DestinationSK] int not null,
	        [DomainSK] int not null,
	        [DurationSK] int not null,
	        [OutletSK] int not null,
	        [ProductSK] int not null,
            [PolicySK] int not null,
	        [ProfitDriverSK] int null,
	        [PortfolioValue] money null
        )
        
        create clustered index idx_factPortfolio_BIRowID on [db-au-star]..factPortfolio (BIRowID)
        create nonclustered index idx_factPortfolio_Date on [db-au-star]..factPortfolio (Date_SK)
        create nonclustered index idx_factPortfolio_OutletSK on [db-au-star]..factPortfolio (OutletSK) include (BIRowID,Date_SK,Business_Unit_SK,AgeBandSK,AreaSK,DestinationSK,DomainSK,DurationSK,ProductSK,ProfitDriverSK,PortfolioValue)

    end    


    if object_id('tempdb..#factPortfolio') is not null
        drop table #factPortfolio

    select 
        Date_SK,
        Business_Unit_SK,
        AgeBandSK,
        AreaSK,
        DestinationSK,
        DomainSK,
        DurationSK,
        OutletSK,
        ProductSK,
        PolicySK,
        ProfitDriverSK,
        sum(isnull(PortfolioValue, 0)) PortfolioValue
    into #factPortfolio
    from
        (
            select 
                t.Date_SK,
                isnull(bu.Business_Unit_SK, -1) Business_Unit_SK,
                isnull(fpt.AgeBandSK, -1) AgeBandSK,
                isnull(fpt.AreaSK, -1) AreaSK,
                isnull(fpt.DestinationSK, -1) DestinationSK,
                isnull(dom.DomainSK, -1) DomainSK,
                isnull(fpt.DurationSK, -1) DurationSK,
                isnull(o.OutletSK, -1) OutletSK,
                isnull(fpt.ProductSK, isnull(dp.ProductSK, -1)) ProductSK,
                isnull(fpt.PolicySK, -1) PolicySK,
                convert(money, [Policy Count]) [Policy Count],
                convert(money, [Premium]) [Premium],
                convert(money, [Distributor Recovery]) [Distributor Recovery],
                convert(money, -[Agency Commission]) [Agency Commission],
                convert(money, -[Override]) [Override],
                convert(money, -[Merchant Fee]) [Merchant Fee],
                convert(money, -[Arrangement Fee]) [Arrangement Fee],
                convert(money, -[Pay Per Click]) [Pay Per Click],
                convert(money, -[Assistance Fees]) [Assistance Fees],
                convert(money, -[Underwriter Net]) [Underwriter Net],
                --convert(money, -[Ultimate Claims Expense]) [Claims Expense],
                --convert(money, -[Incurred Underlying]) [Underlying Claims Expense],
                --convert(money, -[Incurred Large]) [Large Claims Expense],
                --convert(money, -[Incurred Cat]) [Catastrophe Claims Expense],
                --convert(money, -[Projected Claims Expense]) [Projected Claims Expense],
                convert(money, 0) [Underlying Claims Expense],
                convert(money, 0) [Large Claims Expense],
                convert(money, 0) [Catastrophe Claims Expense],
                convert(money, 0) [Projected Claims Expense],
                convert(money, -[Underwriter Margin]) [Underwriter Margin],
                convert(money, -[Direct Employment Expenses]) [Direct Employment Expenses],
                convert(money, -[Direct Other Expenses]) [Direct Other Expenses],
                convert(money, -[Advertising, Research & Promotion]) [Advertising, Research & Promotion],
                convert(money, -[Printing & Postage]) [Printing & Postage],
                convert(money, -[Overhead Employment Expenses]) [Overhead Employment Expenses],
                convert(money, -[Overhead Other Expenses]) [Overhead Other Expenses],
                convert(money, -[GL Agent Commission]) [GL Agent Commission],
                convert(money, -[GL Distributor Recovery]) [GL Distributor Recovery],
                convert(money, -[GL Premium Income]) [GL Premium Income],
                convert(money, -[GL Agency Overrides]) [GL Agency Overrides],
                convert(money, [Commission Received - Care]) [Commission Received - Care],
                convert(money, -[Affiliate Commission]) [Affiliate Commission]
            from
                [db-au-cmdwh]..penPolicyPortfolio t
                --outer apply
                --(
                --    select top 1
                --        [Ultimate Cat] + [Ultimate Large] + [Ultimate Underlying] [Ultimate Claims Expense],
                --        [Incurred Cat],
                --        [Incurred Large],
                --        [Incurred Underlying],
                --        [Projected Cat] + [Projected Large] + [Projected Underlying] [Projected Claims Expense]
                --    from
                --        [db-au-cmdwh]..penPolicyClaimCost pcc
                --    where
                --        pcc.PolicyTransactionKey = t.PolicyTransactionKey
                --) ppc
                outer apply
                (
                    select top 1 
                        AgeBandSK,
                        AreaSK,
                        DestinationSK,
                        DurationSK,
                        ProductSK,
                        PolicySK
                    from
                        [db-au-star]..factPolicyTransaction fpt
                    where
                        fpt.PolicyTransactionKey = t.PolicyTransactionKey
                ) fpt
                outer apply
                (
                    select top 1 
                        ProductSK 
                    from 
                        [db-au-star]..dimProduct dp
                    where 
                        t.[Product Code] = 'CMC' and
                        dp.[ProductCode] = t.[Product Code]
                ) dp
                outer apply
                (
                    select top 1
                        o.OutletSK,
                        o.Country
                    from
                        [db-au-star].dbo.dimOutlet o
                    where
                        o.OutletAlphaKey = isnull(t.OutletAlphaKey, '') and
                        t.[Posting Date] >= o.ValidStartDate and
                        t.[Posting Date] <  dateadd(day, 1, o.ValidEndDate)
                ) o
                outer apply
                (
                    select top 1
                        dom.DomainSK
                    from
                        [db-au-star].dbo.dimDomain dom
                    where
                        dom.CountryCode = o.Country
                ) dom
                outer apply
                (
                    select top 1 
                        bu.Business_Unit_SK
                    from
                        [db-au-star]..Dim_Business_Unit bu
                    where
                        bu.Business_Unit_Code = t.[Business Unit]
                ) bu
            where
                t.[Posting Date] >= @Start and
                t.[Posting Date] <  dateadd(day, 1, @End)
                
            union all
            
            select 
                t.Date_SK,
                isnull(bu.Business_Unit_SK, -1) Business_Unit_SK,
                isnull(fpt.AgeBandSK, -1) AgeBandSK,
                isnull(fpt.AreaSK, -1) AreaSK,
                isnull(fpt.DestinationSK, -1) DestinationSK,
                isnull(dom.DomainSK, -1) DomainSK,
                isnull(fpt.DurationSK, -1) DurationSK,
                isnull(o.OutletSK, -1) OutletSK,
                isnull(fpt.ProductSK, isnull(dp.ProductSK, -1)) ProductSK,
                isnull(fpt.PolicySK, -1) PolicySK,
                convert(money, 0) [Policy Count],
                convert(money, 0) [Premium],
                convert(money, 0) [Distributor Recovery],
                convert(money, 0) [Agency Commission],
                convert(money, 0) [Override],
                convert(money, 0) [Merchant Fee],
                convert(money, 0) [Arrangement Fee],
                convert(money, 0) [Pay Per Click],
                convert(money, 0) [Assistance Fees],
                convert(money, 0) [Underwriter Net],
                convert(money, -[Incurred Underlying]) [Underlying Claims Expense],
                convert(money, -[Incurred Large]) [Large Claims Expense],
                convert(money, -[Incurred Cat]) [Catastrophe Claims Expense],
                convert(money, 0) [Projected Claims Expense],
                convert(money, 0) [Underwriter Margin],
                convert(money, 0) [Direct Employment Expenses],
                convert(money, 0) [Direct Other Expenses],
                convert(money, 0) [Advertising, Research & Promotion],
                convert(money, 0) [Printing & Postage],
                convert(money, 0) [Overhead Employment Expenses],
                convert(money, 0) [Overhead Other Expenses],
                convert(money, 0) [GL Agent Commission],
                convert(money, 0) [GL Distributor Recovery],
                convert(money, 0) [GL Premium Income],
                convert(money, 0) [GL Agency Overrides],
                convert(money, 0) [Commission Received - Care],
                convert(money, 0) [Affiliate Commission]
            from
                [db-au-cmdwh]..penPolicyClaimCost t
                outer apply
                (
                    select top 1 
                        AgeBandSK,
                        AreaSK,
                        DestinationSK,
                        DurationSK,
                        ProductSK,
                        PolicySK
                    from
                        [db-au-star]..factPolicyTransaction fpt
                    where
                        fpt.PolicyTransactionKey = t.PolicyTransactionKey
                ) fpt
                outer apply
                (
                    select top 1 
                        ProductSK 
                    from 
                        [db-au-star]..dimProduct dp
                    where 
                        dp.[ProductCode] = 'CMC'
                ) dp
                outer apply
                (
                    select top 1 
                        OutletAlphaKey
                    from
                        [db-au-cmdwh]..penPolicyTransSummary pt 
                    where
                        pt.PolicyTransactionKey = t.PolicyTransactionKey
                ) pt
                outer apply
                (
                    select top 1
                        o.OutletSK,
                        o.Country
                    from
                        [db-au-star].dbo.dimOutlet o
                    where
                        o.OutletAlphaKey = isnull(pt.OutletAlphaKey, '') and
                        t.[Incurred Date] >= o.ValidStartDate and
                        t.[Incurred Date] <  dateadd(day, 1, o.ValidEndDate)
                ) o
                outer apply
                (
                    select top 1
                        dom.DomainSK
                    from
                        [db-au-star].dbo.dimDomain dom
                    where
                        dom.CountryCode = o.Country
                ) dom
                outer apply
                (
                    select top 1 
                        [Business Unit]
                    from
                        [db-au-cmdwh]..penPolicyPortfolio ppf
                    where
                        ppf.PolicyTransactionKey = t.PolicyTransactionKey
                ) ppf
                outer apply
                (
                    select top 1 
                        bu.Business_Unit_SK
                    from
                        [db-au-star]..Dim_Business_Unit bu
                    where
                        bu.Business_Unit_Code = ppf.[Business Unit]
                ) bu
            where
                t.[Incurred Date] >= @Start and
                t.[Incurred Date] <  dateadd(day, 1, @End)
            
        ) t
        unpivot 
        (
            PortfolioValue for
                PortfolioDriver in
                (
                    [Policy Count],
                    [Premium],
                    [Distributor Recovery],
                    [Agency Commission],
                    [Override],
                    [Merchant Fee],
                    [Arrangement Fee],
                    [Pay Per Click],
                    [Assistance Fees],
                    [Underwriter Net],
                    --[Claims Expense],
                    [Underlying Claims Expense],
                    [Large Claims Expense],
                    [Catastrophe Claims Expense],
                    [Projected Claims Expense],
                    [Underwriter Margin],
                    [Direct Employment Expenses],
                    [Direct Other Expenses],
                    [Advertising, Research & Promotion],
                    [Printing & Postage],
                    [Overhead Employment Expenses],
                    [Overhead Other Expenses],
                    [GL Agent Commission],
                    [GL Distributor Recovery],
                    [GL Premium Income],
                    [GL Agency Overrides],
                    [Commission Received - Care],
                    [Affiliate Commission]
                )
        ) ut
        outer apply
        (
            select top 1
                ProfitDriverSK
            from
                [db-au-star]..dimProfitDriver drv
            where
                drv.ProfitDriverCode = ut.PortfolioDriver
        ) drv
    group by
        Date_SK,
        Business_Unit_SK,
        AgeBandSK,
        AreaSK,
        DestinationSK,
        DomainSK,
        DurationSK,
        OutletSK,
        ProductSK,
        PolicySK,
        ProfitDriverSK


    begin transaction

    begin try

        delete 
        from
            [db-au-star]..factPortfolio
        where
            Date_SK in
            (
                select
                    d.Date_SK
                from
                    [db-au-star]..dim_Date d
                where
                    d.[Date] >= @Start and
                    d.[Date] <  dateadd(day, 1, @End) 
            )

        insert into [db-au-star]..factPortfolio with(tablock)
        (
            Date_SK,
            Business_Unit_SK,
            AgeBandSK,
            AreaSK,
            DestinationSK,
            DomainSK,
            DurationSK,
            OutletSK,
            ProductSK,
            PolicySK,
            ProfitDriverSK,
            PortfolioValue
        )
        select 
            Date_SK,
            Business_Unit_SK,
            AgeBandSK,
            AreaSK,
            DestinationSK,
            DomainSK,
            DurationSK,
            OutletSK,
            ProductSK,
            PolicySK,
            ProfitDriverSK,
            PortfolioValue
        from
            #factPortfolio
        where
            PortfolioValue <> 0


    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'factPortfolio data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = -1,
            @PackageID = 'factPortfolio'

    end catch

    if @@trancount > 0
        commit transaction

end

GO
