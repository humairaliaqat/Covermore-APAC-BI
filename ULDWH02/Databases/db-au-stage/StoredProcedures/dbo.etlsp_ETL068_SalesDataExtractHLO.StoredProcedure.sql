USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL068_SalesDataExtractHLO]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_ETL068_SalesDataExtractHLO]
    @Country varchar(5),
    @SuperGroup varchar(max),
    @StartDate date,
    @EndDate date,
    @Measures varchar(max) = ''

as


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20120209
Prerequisite:   Requires Penguin & Star ETL successfully completed.
Description:    This procedure extracts sales, quotes and demographics data for helloworld group.
				It does not contain ticket data (this can be added if required).
				
Change History:
                20160426 - LT - Modified from Leo's SP [db-au-workspace].dbo.etlsp_SalesDataExtract for helloworld.

*************************************************************************************************************************************/

--debug
--declare
--    @Country varchar(5),
--    @SuperGroup varchar(max),
--    @StartDate date,
--    @EndDate date,
--    @Measures varchar(max)

--select
--    @Country = 'AU',
--    @SuperGroup = 'helloworld',
--    @StartDate = '2013-07-01',
--    @EndDate = '2016-04-30'

    set nocount on

    if object_id('[db-au-cmdwh].dbo.usrSalesDataExtractHLO') is null
    begin

        create table [db-au-cmdwh].dbo.usrSalesDataExtractHLO
        (
            [BIRowID] bigint not null identity(1,1),

            [TransactionStatus] nvarchar(50) null,
            [TransactionType] nvarchar(50) null,

            [Date] datetime not null,
            [Fiscal_Year] int not null,
            [CurFiscalYearStart] datetime null,
            [CurFiscalYearEnd] datetime null,
            [CurQuarterStart] datetime null,
            [CurQuarterEnd] datetime null,
            [CurMonthStart] datetime null,
            [CurMonthEnd] datetime null,
            [LastMonthStart] datetime null,
            [LastMonthEnd] datetime null,
            [LastFiscalYearStart] datetime null,
            [LYCurFiscalMonthStart] datetime null,
            [TotalBusinessDays] int null,
            [RemainingBusinessDays] int null,

            [CountryCode] nvarchar(20) not null,
            [SuperGroupName] nvarchar(255) null,
            [GroupName] nvarchar(50) null,
            [SubGroupName] nvarchar(50) null,
            [AlphaCode] nvarchar(20) null,
            [OutletName] nvarchar(50) null,
            [LatestBDMName] nvarchar(100) null,

            [Duration] int not null,
            [ABSDurationBand] nvarchar(50) null,
            [AreaName] nvarchar(50) null,
            [AreaNumber] varchar(20) null,
            [AreaType] nvarchar(50) null,

            [Continent] nvarchar(100) null,
            [Destination] nvarchar(50) null,

            [Age] int not null,
            [ABSAgeBand] nvarchar(50) null,

            [ProductName] nvarchar(100) null,
            [PolicyType] nvarchar(50) null,
            [ProductClassification] nvarchar(100) null,
            [PlanType] nvarchar(50) null,
            [TripType] nvarchar(50) null,

            [Excess] money null,
            [CancellationCover] int null,

            [ConsultantName] nvarchar(100) null,
            [ConsultantType] nvarchar(50) null,
            [FirstSellDate] datetime null,
            [ConsultantSK] int not null,

            [Premium] float null,
            [SellPrice] float null,
            [Commission] float null,
            [PolicyCount] int null,
            [EMCPolicy] int not null,
            [QuoteCount] int not null,
            [QuoteSessionCount] int not null,
            [InternationalTravellersCount] int null,
            [InternationalChargedAdultsCount] int null,
            [InternationalPolicyCount] int null,
            [DomesticPolicyCount] int null,
            [LeadTime] int not null
        ) 

        create clustered index idx_SalesDataExtract_BIRowID on [db-au-cmdwh].dbo.usrSalesDataExtractHLO(BIRowID)
        create nonclustered index idx_SalesDataExtract_Date on [db-au-cmdwh].dbo.usrSalesDataExtractHLO(Date,CountryCode,SuperGroupName,TransactionType)

    end

    begin transaction

    begin try

        if object_id('tempdb..#dump') is not null
            drop table #dump

        --policy

        select
            d.[Date],
            d.Fiscal_Year,
            d.CurFiscalYearStart,
            d.CurFiscalYearEnd,
            d.CurQuarterStart,
            d.CurQuarterEnd,
            d.CurMonthStart,
            d.CurMonthEnd,
            d.LastFiscalYearStart,
            d.LastMonthStart,
            d.LastMonthEnd,
            d.LYCurFiscalMonthStart,
            d.TotalBusinessDays,
            d.RemainingBusinessDays,

            o.CountryCode,
            o.SuperGroupName, 
            o.GroupName, 
            o.SubGroupName, 
            o.AlphaCode, 
            o.OutletName, 
            o.LatestBDMName, 

            ProductSK,
            OutletSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            AgeBandSK,
            ConsultantSK,
            DomainSK,
            Premium,
            SellPrice,
            Commission,
            PolicyCount,
            TransactionStatus,
            TransactionType,
            0 QuoteCount,
            0 QuoteSessionCount,
            0 InternationalTravellersCount,
            InternationalChargedAdultsCount,
            InternationalPolicyCount,
            DomesticPolicyCount,

            case 
                when isnull(datediff(dd, p.IssueDate, p.TripStart), 0) < 0 then 0 
                else isnull(datediff(dd, p.IssueDate, p.TripStart), 0) 
            end LeadTime,
            p.Excess,
            p.CancellationCover,
            pt.MedicalCount EMCPolicy
        into #dump
        from 
            [db-au-star]..factPolicyTransaction pt
            inner join [db-au-star]..dimPolicy p on
                p.PolicySK = pt.PolicySK
            cross apply
            (
                select top 1 
                    ldo.Country CountryCode,
                    ldo.SuperGroupName, 
                    ldo.GroupName, 
                    ldo.SubGroupName, 
                    ldo.AlphaCode, 
                    ldo.OutletName, 
                    ldo.LatestBDMName
                from
                    [db-au-star]..dimOutlet do
                    inner join [db-au-star]..dimOutlet ldo on
                        ldo.OutletSK = do.LatestOutletSK
                where
                    do.OutletSK = pt.OutletSK
            ) o
            cross apply
            (
                select top 1 
                    dd.[Date],
                    dd.Fiscal_Year,
                    dd.CurFiscalYearStart,
                    dd.CurFiscalYear CurFiscalYearEnd,
                    dd.CurQuarterStart,
                    dd.CurQuarterEnd,
                    dd.CurMonthStart,
                    dd.CurMonthEnd,
                    dd.LastFiscalStart LastFiscalYearStart,
                    dd.LastMonthStart,
                    dd.LastMonthEnd,
                    dd.LYCurFiscalMonthStart,
                    dd.Total_Work_Days TotalBusinessDays,
                    dd.Remaining_Work_Days RemainingBusinessDays
                from
                    [db-au-star]..Dim_Date dd
                where
                    dd.Date_SK = pt.DateSK
            ) d
        where
            (
                isnull(@Measures, '') = '' or
                @Measures like '%policy%'
            ) and
            pt.DateSK >=  convert(varchar(8),@StartDate,112) and
            pt.DateSK <  convert(varchar(8),dateadd(day, 1, @EndDate),112) and
            (
                @Country = '' or
                o.CountryCode = @Country
            ) and
            (
                @SuperGroup = '' or
                o.SuperGroupName in 
                (
                    select
                        Item
                    from
                        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
                )
            )

        --quote
        insert into #dump
        select
            d.[Date],
            d.Fiscal_Year,
            d.CurFiscalYearStart,
            d.CurFiscalYearEnd,
            d.CurQuarterStart,
            d.CurQuarterEnd,
            d.CurMonthStart,
            d.CurMonthEnd,
            d.LastFiscalYearStart,
            d.LastMonthStart,
            d.LastMonthEnd,
            d.LYCurFiscalMonthStart,
            d.TotalBusinessDays,
            d.RemainingBusinessDays,

            o.CountryCode,
            o.SuperGroupName, 
            o.GroupName, 
            o.SubGroupName, 
            o.AlphaCode, 
            o.OutletName, 
            o.LatestBDMName, 

            ProductSK,
            OutletSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            AgeBandSK,
            ConsultantSK,
            DomainSK,
            0 Premium,
            0 SellPrice,
            0 Commission,
            0 PolicyCount,
            'Active' TransactionStatus,
            'Quote' TransactionType,
            QuoteCount,
            QuoteSessionCount,
            0 InternationalTravellersCount,
            0 InternationalChargedAdultsCount,
            0 InternationalPolicyCount,
            0 DomesticPolicyCount,

            0 LeadTime,
            0 Excess,
            0 CancellationCover,
            0 EMCPolicy
        from 
            [db-au-star]..factQuoteSummary q
            cross apply
            (
                select top 1 
                    ldo.Country CountryCode,
                    ldo.SuperGroupName, 
                    ldo.GroupName, 
                    ldo.SubGroupName, 
                    ldo.AlphaCode, 
                    ldo.OutletName, 
                    ldo.LatestBDMName
                from
                    [db-au-star]..dimOutlet do
                    inner join [db-au-star]..dimOutlet ldo on
                        ldo.OutletSK = do.LatestOutletSK
                where
                    do.OutletSK = q.OutletSK
            ) o
            cross apply
            (
                select top 1 
                    dd.[Date],
                    dd.Fiscal_Year,
                    dd.CurFiscalYearStart,
                    dd.CurFiscalYear CurFiscalYearEnd,
                    dd.CurQuarterStart,
                    dd.CurQuarterEnd,
                    dd.CurMonthStart,
                    dd.CurMonthEnd,
                    dd.LastFiscalStart LastFiscalYearStart,
                    dd.LastMonthStart,
                    dd.LastMonthEnd,
                    dd.LYCurFiscalMonthStart,
                    dd.Total_Work_Days TotalBusinessDays,
                    dd.Remaining_Work_Days RemainingBusinessDays
                from
                    [db-au-star]..Dim_Date dd
                where
                    dd.Date_SK = q.DateSK
            ) d
        where
            (
                isnull(@Measures, '') = '' or
                @Measures like '%quote%'
            ) and
            q.DateSK in 
            (
                select 
                    Date_SK 
                from 
                    [db-au-star]..Dim_Date rd
                where 
                    rd.[Date] >= @StartDate and 
                    rd.[Date] <  dateadd(day, 1, @EndDate)
            ) and
            (
                @Country = '' or
                o.CountryCode = @Country
            ) and
            (
                @SuperGroup = '' or
                o.SuperGroupName in 
                (
                    select
                        Item
                    from
                        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
                )
            )


          --demographic
        insert into #dump
        select
            d.[Date],
            d.Fiscal_Year,
            d.CurFiscalYearStart,
            d.CurFiscalYearEnd,
            d.CurQuarterStart,
            d.CurQuarterEnd,
            d.CurMonthStart,
            d.CurMonthEnd,
            d.LastFiscalYearStart,
            d.LastMonthStart,
            d.LastMonthEnd,
            d.LYCurFiscalMonthStart,
            d.TotalBusinessDays,
            d.RemainingBusinessDays,

            o.CountryCode,
            o.SuperGroupName, 
            o.GroupName, 
            o.SubGroupName, 
            o.AlphaCode, 
            o.OutletName, 
            o.LatestBDMName,       

            pt.ProductSK,
            OutletSK,
            AreaSK,
            DestinationSK,
            DurationSK,
            AgeBandSK,
            ConsultantSK,
            DomainSK,
            0 Premium,
            0 SellPrice,
            0 Commission,
            0 PolicyCount,
            'Active' TransactionStatus,
            'Demographic' TransactionType,
            0 QuoteCount,
            0 QuoteSessionCount,
            0 InternationalTravellersCount,
            0 InternationalChargedAdultsCount,
            0 InternationalPolicyCount,
            0 DomesticPolicyCount,

            case 
                when isnull(datediff(dd, p.IssueDate, p.TripStart), 0) < 0 then 0 
                else isnull(datediff(dd, p.IssueDate, p.TripStart), 0) 
            end LeadTime,
            p.Excess,
            p.CancellationCover,
            case
                when e.EMCCount = 0 then 0 
                else 1 
            end EMCPolicy
        from 
            [db-au-star]..dimPolicy p
            cross apply
            (
                select top 1
					pt.DateSK,
                    pt.OutletSK,
                    pt.AreaSK,
                    pt.DestinationSK,
                    pt.DurationSK,
                    pt.AgeBandSK,
                    pt.ConsultantSK,
                    pt.DomainSK,
                    pt.ProductSK
                from
                    [db-au-star]..factPolicyTransaction pt
                where
                    pt.PolicySK = p.PolicySK
            ) pt
            cross apply
            (
                select top 1 
                    ldo.Country CountryCode,
                    ldo.SuperGroupName, 
                    ldo.GroupName, 
                    ldo.SubGroupName, 
                    ldo.AlphaCode, 
                    ldo.OutletName, 
                    ldo.LatestBDMName
                from
                    [db-au-star]..dimOutlet do
                    inner join [db-au-star]..dimOutlet ldo on
                        ldo.OutletSK = do.LatestOutletSK
                where
                    do.OutletSK = pt.OutletSK
            ) o
            cross apply
            (
                select top 1 
                    dd.[Date],
                    dd.Fiscal_Year,
                    dd.CurFiscalYearStart,
                    dd.CurFiscalYear CurFiscalYearEnd,
                    dd.CurQuarterStart,
                    dd.CurQuarterEnd,
                    dd.CurMonthStart,
                    dd.CurMonthEnd,
                    dd.LastFiscalStart LastFiscalYearStart,
                    dd.LastMonthStart,
                    dd.LastMonthEnd,
                    dd.LYCurFiscalMonthStart,
                    dd.Total_Work_Days TotalBusinessDays,
                    dd.Remaining_Work_Days RemainingBusinessDays
                from
                    [db-au-star]..Dim_Date dd
                where
                    dd.Date_SK = pt.DateSK
            ) d
            inner join [db-au-star]..dimProduct dp on 
                dp.ProductSK = pt.ProductSK
            cross apply
            (
                select 
                    sum(pt.EMCCount) EMCCount
                from
                    [db-au-star]..factPolicyTransaction pt
                where
                    pt.PolicySK = p.PolicySK
            ) e
        where 
            (
                isnull(@Measures, '') = '' or
                @Measures like '%demo%'
            ) and
            dp.PlanType = 'International' and
            d.[Date] >=  @StartDate and
            d.[Date] <  dateadd(day, 1, @EndDate) and
            (
                @Country = '' or
                o.CountryCode = @Country
            ) and
            (
                @SuperGroup = '' or
                o.SuperGroupName in 
                (
                    select
                        Item
                    from
                        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
                )
            )

        --domain specific holidays
        update dd
        set
            TotalBusinessDays = datepart(day, CurMonthEnd) - isnull(Holidays, 0),
            RemainingBusinessDays = isnull(rd.RemainingBusinessDays, 0)
        from
            #dump dd
            outer apply
            (
                select 
                    count(*) Holidays
                from
                    [db-au-star]..Dim_Date r
                    outer apply
                    (
                        select top 1 
                            1 isPublicHoliday
                        from
                            [db-au-cmdwh]..usrPublicHoliday ph
                        where
                            ph.[Date] = r.[Date] and
                            ph.DomainCountry = CountryCode
                    ) ph
                where
                    r.CurMonthStart = dd.CurMonthStart and
                    (
                        r.isWeekend = 1 or
                        isnull(ph.isPublicHoliday, 0) = 1
                    )
            ) h
            outer apply
            (
                select 
                    sum
                    (
                        case
                            when r.isWeekend = 1 or isnull(ph.isPublicHoliday, 0) = 1 then 0
                            else 1
                        end
                    ) RemainingBusinessDays
                from
                    [db-au-star]..Dim_Date r
                    outer apply
                    (
                        select top 1 
                            1 isPublicHoliday
                        from
                            [db-au-cmdwh]..usrPublicHoliday ph
                        where
                            ph.[Date] = r.[Date] and
                            ph.DomainCountry = CountryCode
                    ) ph
                where
                    r.CurMonthStart = dd.CurMonthStart and
                    r.[Date] > dd.[Date]
            ) rd

        --wipe existing data in period
        delete 
        from
            [db-au-cmdwh].dbo.usrSalesDataExtractHLO
        where
            [Date] >= @StartDate and
            [Date] <  dateadd(day, 1, @EndDate) and
            (
                @Country = '' or
                [CountryCode] = @Country
            ) and
            (
                @SuperGroup = '' or
                SuperGroupName in 
                (
                    select
                        Item
                    from
                        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@SuperGroup, ',')
                )
            ) and
            (
                (
                    (
                        isnull(@Measures, '') = '' or
                        @Measures like '%demo%'
                    ) and
                    TransactionType = 'Demographic'
                ) or
                (
                    (
                        isnull(@Measures, '') = '' or
                        @Measures like '%quote%'
                    ) and
                    TransactionType = 'Quote'
                ) or
                (
                    (
                        isnull(@Measures, '') = '' or
                        @Measures like '%policy%'
                    ) and
                    TransactionType not in ('Demographic', 'Quote', 'Ticket')
                ) 
            )

        --store
        insert into [db-au-cmdwh].dbo.usrSalesDataExtractHLO with(tablock)
        (
            [TransactionStatus],
            [TransactionType],
            [Date],
            [Fiscal_Year],
            [CurFiscalYearStart],
            [CurFiscalYearEnd],
            [CurQuarterStart],
            [CurQuarterEnd],
            [CurMonthStart],
            [CurMonthEnd],
            [LastMonthStart],
            [LastMonthEnd],
            [LastFiscalYearStart],
            [LYCurFiscalMonthStart],
            [TotalBusinessDays],
            [RemainingBusinessDays],
            [CountryCode],
            [SuperGroupName],
            [GroupName],
            [SubGroupName],
            [AlphaCode],
            [OutletName],
            [LatestBDMName],
            [Duration],
            [ABSDurationBand],
            [AreaName],
            [AreaNumber],
            [AreaType],
            [Continent],
            [Destination],
            [Age],
            [ABSAgeBand],
            [ProductName],
            [PolicyType],
            [ProductClassification],
            [PlanType],
            [TripType],
            [Excess],
            [CancellationCover],
            [ConsultantName],
            [ConsultantType],
            [FirstSellDate],
            [ConsultantSK],
            [Premium],
            [SellPrice],
            [Commission],
            [PolicyCount],
            [EMCPolicy],
            [QuoteCount],
            [QuoteSessionCount],
            [InternationalTravellersCount],
            [InternationalChargedAdultsCount],
            [InternationalPolicyCount],
            [DomesticPolicyCount],
            [LeadTime]
        )
        select 
            [TransactionStatus],
            [TransactionType],
            [Date],
            [Fiscal_Year],
            [CurFiscalYearStart],
            [CurFiscalYearEnd],
            [CurQuarterStart],
            [CurQuarterEnd],
            [CurMonthStart],
            [CurMonthEnd],
            [LastMonthStart],
            [LastMonthEnd],
            [LastFiscalYearStart],
            [LYCurFiscalMonthStart],
            [TotalBusinessDays],
            [RemainingBusinessDays],
            [CountryCode],
            [SuperGroupName],
            [GroupName],
            [SubGroupName],
            [AlphaCode],
            [OutletName],
            [LatestBDMName],
            [Duration],
            [ABSDurationBand],
            [AreaName],
            [AreaNumber],
            [AreaType],
            [Continent],
            [Destination],
            [Age],
            [ABSAgeBand],
            [ProductName],
            [PolicyType],
            [ProductClassification],
            [PlanType],
            [TripType],
            [Excess],
            [CancellationCover],
            [ConsultantName],
            [ConsultantType],
            [FirstSellDate],
            t.[ConsultantSK],
            [Premium],
            [SellPrice],
            [Commission],
            [PolicyCount],
            [EMCPolicy],
            [QuoteCount],
            [QuoteSessionCount],
            [InternationalTravellersCount],
            [InternationalChargedAdultsCount],
            [InternationalPolicyCount],
            [DomesticPolicyCount],
            [LeadTime]
        from
            #dump t
            inner join [db-au-star]..dimArea a on 
                a.AreaSK = t.AreaSK
            inner join [db-au-star]..dimDestination d on 
                d.DestinationSK = t.DestinationSK
            inner join [db-au-star]..dimDuration dur on 
                dur.durationsk = t.durationsk
            inner join [db-au-star]..dimAgeBand age on 
                age.agebandsk = t.agebandsk
            inner join [db-au-star]..dimConsultant c on 
                c.consultantsk = t.consultantsk
            inner join [db-au-star]..dimProduct dp on 
                dp.ProductSK = t.ProductSK

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec [db-au-stage]..syssp_genericerrorhandler 'Sales Data Extract failed'

    end catch

    if @@trancount > 0
        commit transaction





GO
