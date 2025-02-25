USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_mapTicket]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_mapTicket]
as
begin

    set nocount on

    print '20170426, LL, no longer needed, taken care by the new FC ticket ETL'

    --if object_id('tempdb..#fixmapping') is not null
    --    drop table #fixmapping

    --select 
    --    --distinct
    --    --co.AlphaCode CurrentAlpha,
    --    --clo.AlphaCode CurrentLatestAlpha,
    --    --do.NewAlphaCode,
    --    --do.NewLatestAlphaCode
    
    --    --top 1000 
    --    ft.factTicketSK,
    --    ft.DateSK,
    --    --ft.OutletSK,
    --    --ft.Source,
    --    --ft.ReferenceNumber,
    --    --co.AlphaCode CurrentAlpha,
    --    --clo.AlphaCode CurrentLatestAlpha,
    --    --om.*,
    --    --do.*
    --    case
    --        when co.Country = 'AU' then do.NewOutletSK
    --        when co.Country = 'NZ' then donz.NewOutletSK
    --    end NewOutletSK
    --into #fixmapping
    --from
    --    [db-au-star]..factTicket ft
    --    inner join [db-au-star]..dimOutlet co on
    --        co.OutletSK = ft.OutletSK
    --    inner join [db-au-star]..dimOutlet clo on
    --        clo.OutletSK = co.LatestOutletSK
    --    outer apply
    --    (
    --        select top 1 *
    --        from
    --            [db-au-cmdwh]..vTicketOutletMapping om
    --        where
    --            om.Source = ft.Source and
    --            om.ReferenceNumber = ft.ReferenceNumber
    --    ) om
    --    outer apply
    --    (
    --        select top 1 
    --            do.OutletSK NewOutletSK,
    --            do.AlphaCode NewAlphaCode,
    --            dlo.AlphaCode NewLatestAlphaCode
    --        from
    --            [db-au-star]..dimOutlet do
    --            inner join [db-au-star]..dimOutlet dlo on
    --                dlo.OutletSK = do.LatestOutletSK and
    --                dlo.isLatest = 'Y'
    --        where
    --            do.isLatest = 'Y' and
    --            do.SuperGroupName = om.SuperGroup and
    --            do.ExternalID = om.ExternalID
    --        order by
    --            do.CommencementDate desc,
    --            do.ValidStartDate desc
    --    ) do
    --    outer apply
    --    (
    --        select top 1 
    --            do.OutletSK NewOutletSK
    --        from
    --            [db-au-workspace]..mapFCNZT3 r
    --            inner join [db-au-star]..dimOutlet do on
    --                do.AlphaCode = r.AlphaCode and
    --                do.Country = r.Country
    --            inner join [db-au-star]..dimOutlet dlo on
    --                dlo.OutletSK = do.LatestOutletSK and
    --                dlo.isLatest = 'Y'
    --        where
    --            r.Country = 'NZ' and
    --            r.[T3 Code] = om.ExternalID and
    --            do.isLatest = 'Y' and
    --            do.SuperGroupName = om.SuperGroup
    --        order by
    --            do.CommencementDate desc,
    --            do.ValidStartDate desc
    --    ) donz
    --where
    --    ft.Source <> 'Penguin' and
    --    clo.AlphaCode <> do.NewLatestAlphaCode



    ----select top 1000 
    ----    ExtID,
    ----    TradingStatus,
    ----    *
    ----from
    ----    [db-au-cmdwh]..penOutlet
    ----where
    ----    CountryKey = 'AU' and
    ----    OutletStatus = 'Current' and
    ----    AlphaCode in 
    ----    (
    ----        --'FLV1162',
    ----        --'FLV0250'

    ----        'FLQ0490',
    ----        'FLQ2066'
    ----    )


    ----select *
    ----from
    ----    #fixmapping r
    ----    inner join [db-au-star]..factTicket t on
    ----        t.factTicketSK = r.factTicketSK

    --update t
    --set
    --    t.OutletSK = r.NewOutletSK
    --from
    --    #fixmapping r
    --    inner join [db-au-star]..factTicket t on
    --        t.factTicketSK = r.factTicketSK

    --declare cDates cursor local for
    --    select distinct
    --        d.CurFiscalMonthStart
    --    from
    --        #fixmapping r
    --        inner join [db-au-star]..Dim_Date d on
    --            d.Date_SK = r.DateSK

    --declare @date date
    --declare @end date
    --declare @err varchar(max)


    --open cDates

    --fetch next from cDates into @date

    --while @@fetch_status = 0
    --begin

    --    set @end = dateadd(day, -1, dateadd(month, 1, @date))

    --    exec [db-au-workspace]..etlsp_SalesDataExtract
    --        @Country = 'AU',
    --        @SuperGroup = 'Helloworld,Flight Centre',
    --        @StartDate = @date,
    --        @EndDate = @end,
    --        @Measures = 'ticket'

    --    exec [db-au-workspace]..etlsp_SalesDataExtract
    --        @Country = 'NZ',
    --        @SuperGroup = 'Helloworld,Flight Centre',
    --        @StartDate = @date,
    --        @EndDate = @end,
    --        @Measures = 'ticket'

    --    set @err = convert(varchar(10), @date, 120) + char(9) + convert(varchar, getdate(), 120)

    --    raiserror(@err, 1, 1) with nowait

    --    fetch next from cDates into @date

    --end

    --close cDates
    --deallocate cDates

end
GO
