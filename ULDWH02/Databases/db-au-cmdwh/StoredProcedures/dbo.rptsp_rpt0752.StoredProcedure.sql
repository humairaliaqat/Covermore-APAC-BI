USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0752]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0752]    
    @DateRange varchar(30) = 'Month-To-Now',
    @StartDate date = null,
    @EndDate date = null

as
begin

--20170704, LL, reinstate, refactor

    set nocount on

    --uncomment to debug
    --declare
    --    @DateRange varchar(30) = 'Month-To-Now',
    --    @StartDate date = null,
    --    @EndDate date = null


    declare 
        @rptStartDate date,
        @rptEndDate date,
        @SQL varchar(max)

    /* get reporting dates */
    if @DateRange = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)
    else
        select 
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange


    if object_id('tempdb..#dump') is not null 
        drop table #dump

    select
        o.AlphaCode,
        convert(date, pt.PostingDate) as Date,
        sum(pt.GrossPremium) as SellPrice,
        sum(pt.NewPolicyCount) as PolicyCount,
        sum(pt.Commission) as Commission,
        sum(pt.AdjustedNet) as NetPrice,
        0 as QuoteCount
    into #dump
    from
        penOutlet o with(nolock)
        inner join penPolicyTransSummary pt with(nolock) on
            o.OutletAlphaKey = pt.OutletAlphaKey and 
            o.OutletStatus = 'Current'
    where
        o.CountryKey = 'US' and
        pt.PostingDate >= @rptStartDate and
        pt.PostingDate <  dateadd(day, 1, @rptEndDate) and
        pt.PostingDate <  convert(date, dbo.xfn_ConvertUTCtoLocal(dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time'))
    group by
        o.AlphaCode,
        convert(date, pt.PostingDate)

    insert into #dump
    select
        o.AlphaCode,
        q.CreateDate as Date,
        0 as SellPrice,
        0 as PolicyCount,
        0 as Commission,
        0 as NetPrice,
        count(
            distinct 
            case 
                when ParentQuoteID is null then QuoteID 
                else null 
            end
        ) as QuoteCount
    from
        penOutlet o with(nolock)
        inner join penQuote q with(nolock) on
            o.OutletAlphaKey = q.OutletAlphaKey and 
            o.OutletStatus = 'Current'
    where
        o.CountryKey = 'US' and
        q.CreateDate >= @rptStartDate and
        q.CreateDate <  dateadd(day, 1, @rptEndDate) and
        q.CreateDate <  convert(date, dbo.xfn_ConvertUTCtoLocal(dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time'))
    group by
        o.AlphaCode,
        q.CreateDate

    select @SQL = 
    '
    select    
        a.AlphaCode,
        convert(date, dbo.xfn_ConvertUTCtoLocal(a.Date, ''Eastern Standard Time'')) as Date,
        sum(a.SellPrice) as SellPrice,
        sum(a.PolicyCount) as PolicyCount,
        sum(a.Commission) as Commission,
        sum(a.NetPrice) as NetPrice,
        sum(a.QuoteCount) as QuoteCount
    from
        openquery
        (
            [AZUSSQL02],
            ''
                select
                    p.AlphaCode,
                    pt.TransactionDateTime as Date,
                    sum(pt.GrossPremium) as SellPrice,
                    sum(
                        case 
                            when ptt.[Type] = ''''Base'''' and pts.StatusDescription = ''''Active'''' then 1
                            when ptt.[Type] = ''''Base'''' and pts.StatusDescription like ''''%cancel%'''' then -1
                            else 0
                        end
                    ) PolicyCount,
                    sum(pt.TotalCommission) as Commission,
                    sum(pt.TotalNet) as NetPrice,
                    0 as QuoteCount
                from
                    [US_PenguinSharp_Active].dbo.tblPolicy p with(nolock)
                    inner join [US_PenguinSharp_Active].dbo.tblPolicyTransaction pt with(nolock) on 
                        p.PolicyID = pt.PolicyID
                    inner join [US_PenguinSharp_Active].dbo.tblPolicyTransactionType ptt with(nolock) on 
                        pt.TransactionType = ptt.ID
                    inner join [US_PenguinSharp_Active].dbo.tblPolicyTransactionStatus pts with(nolock) on 
                        pt.TransactionStatus = pts.ID
                where
                    pt.TransactionDateTime >= ''''' + convert(varchar(10), dbo.xfn_ConvertLocalToUTC(@rptStartDate, 'Eastern Standard Time'), 120) + ''''' and
                    pt.TransactionDateTime <  ''''' + convert(varchar(10), dbo.xfn_ConvertLocalToUTC(dateadd(day, 1, @rptEndDate), 'Eastern Standard Time'), 120) + ''''' and
                    pt.TransactionDateTime >= ''''' + convert(varchar(10), dbo.xfn_ConvertLocaltoUTC(convert(date, dbo.xfn_ConvertUTCtoLocal(dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time')), 'Eastern Standard Time'), 120) + '''''
                group by
                    p.AlphaCode,
                    pt.TransactionDateTime

                union all
        
                select
                    AlphaCode,
                    QuoteDate as Date,
                    0 as SellPrice,
                    0 as PolicyCount,
                    0 as Commission,
                    0 as NetPrice,
                    count
                    (
                        distinct 
                        case 
                            when ParentQuoteID is null then QuoteID 
                            else null 
                        end
                    ) as QuoteCount
                from
                    [US_PenguinSharp_Active].dbo.tblQuote with(nolock)
                where
                    QuoteDate >= ''''' + convert(varchar(10), dbo.xfn_ConvertLocalToUTC(@rptStartDate, 'Eastern Standard Time'), 120) + ''''' and
                    QuoteDate <  ''''' + convert(varchar(10), dbo.xfn_ConvertLocalToUTC(dateadd(day, 1, @rptEndDate), 'Eastern Standard Time'), 120) + ''''' and
                    QuoteDate >= ''''' + convert(varchar(10), dbo.xfn_ConvertLocaltoUTC(convert(date, dbo.xfn_ConvertUTCtoLocal(dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time')), 'Eastern Standard Time'), 120) + '''''
                group by
                    AlphaCode,
                    QuoteDate
            ''
        ) a
    group by
        a.AlphaCode,
        convert(date,dbo.xfn_ConvertUTCtoLocal(a.Date,''Eastern Standard Time''))
    '
    --print @sql
    insert into #dump
    exec(@SQL)

    select 
        oo.Country,
        oo.SuperGroupName,
        oo.GroupCode,
        oo.GroupName,
        oo.SubGroupCode,
        oo.SubGroupName,
        oo.OutletName,
        a.AlphaCode,
        oo.SalesChannel,
        a.[Date],
        a.SellPrice,
        a.PolicyCount,
        a.Commission,
        a.NetPrice,
        a.QuoteCount,
        @rptStartDate as StartDate,
        dateadd(d,-1,@rptEndDate) as EndDate
    from 
        #dump a
        outer apply
        (
            select top 1
                o.CountryKey as Country,
                o.SuperGroupName,
                o.GroupCode,
                o.GroupName,
                o.SubGroupCode,
                o.SubGroupName,
                o.OutletName,
                o.OutletType as SalesChannel
            from
                penOutlet o
            where
                o.CountryKey = 'US' and
                o.AlphaCode collate database_default = a.AlphaCode collate database_default and
                o.OutletStatus = 'Current'
        ) oo

end



GO
