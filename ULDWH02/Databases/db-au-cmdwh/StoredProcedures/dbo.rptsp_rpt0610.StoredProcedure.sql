USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0610]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0610]
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null
    
as
begin
--20150306, LS, F23429, change last estimate = 0 to first nil estimate

    set nocount on
    
    declare 
        @rptStartDate datetime,
        @rptEndDate datetime  

    /* get reporting dates */  
    if @ReportingPeriod = '_User Defined'  
        select 
            @rptStartDate = @StartDate, 
            @rptEndDate = @EndDate  
        
    else  
        select   
            @rptStartDate = StartDate,   
            @rptEndDate = EndDate  
        from   
            vDateRange  
        where   
            DateRange = @ReportingPeriod

    select 
        cl.ReceivedDate [Claim Received Date],
        cl.ClaimNo [Claim Number],
        ce.EventDesc [Description of Event],
        ce.EventCountryName [Country of Event],
        cs.SectionDescription [Section],
        FirstNilEstimateDate [Date Estimate Reduced to 0],
        cp.Payee,
        cp.PayeeType [Payee Type],
        cp.PaymentDate [Payment Date],
        cp.AmountAUD [Amount AUD],
        cp.AmountFX [Amount FX],
        cp.CurrencyCode [Currency],
        @rptStartDate StartDate,
        @rptEndDate EndDate
    from
        clmClaim cl
        inner join clmEvent ce on
            ce.ClaimKey = cl.ClaimKey
        inner join clmSection cs on
            cs.EventKey = ce.EventKey and
            cs.SectionCode = 'MED'
        cross apply
        (
            select top 1 
                EHCreateDate FirstNilEstimateDate,
                EHEstimateValue FirstNilEstimate
            from
                clmEstimateHistory ceh
            where
                ceh.SectionKey = cs.SectionKey and
                ceh.EHEstimateValue = 0
            order by 
                EHCreateDate
        ) ceh
        cross apply
        (
            select top 1
                peh.EHEstimateValue PreviousEstimate
            from
                clmEstimateHistory peh
            where
                peh.SectionKey = cs.SectionKey and
                peh.EHCreateDate < ceh.FirstNilEstimateDate
            order by
                peh.EHCreateDate desc
        ) peh
        outer apply
        (
            select
                case
                    when isThirdParty = 1 and isnull(BusinessName, '') <> '' then BusinessName
                    else isnull(Firstname + ' ', '') + Surname
                end Payee,
                case
                    when isThirdParty = 1 then 'Third Party'
                    else 'Private Individual'
                end PayeeType,
                convert(date, cp.ModifiedDate) PaymentDate,
                sum(isnull(AUDAmount, 0)) AmountAUD,
                sum(isnull(BillAmount, 0)) AmountFX,
                --cp.Rate FXRate,
                cp.CurrencyCode
            from
                clmPayment cp
                inner join clmName cn on
                    cn.NameKey = cp.PayeeKey
            where
                cp.SectionKey = cs.SectionKey and
                cp.PaymentStatus = 'PAID'
            group by
                case
                    when isThirdParty = 1 and isnull(BusinessName, '') <> '' then BusinessName
                    else isnull(Firstname + ' ', '') + Surname
                end,
                case
                    when isThirdParty = 1 then 'Third Party'
                    else 'Private Individual'
                end,
                convert(date, cp.ModifiedDate),
                --cp.Rate,
                cp.CurrencyCode
        ) cp
        --cross apply
        --(
        --    select
        --        max(LastEstimateDate) LastEstimateDate,
        --        sum(isnull(LastEstimate, EstimateValue)) LastEstimateValue
        --    from
        --        clmSection cs
        --        outer apply
        --        (
        --            select top 1 
        --                EHCreateDate LastEstimateDate,
        --                EHEstimateValue LastEstimate
        --            from
        --                clmEstimateHistory ceh
        --            where
        --                ceh.SectionKey = cs.SectionKey
        --            order by 
        --                EHCreateDate desc
        --        ) ceh
        --    where
        --        cs.ClaimKey = cl.ClaimKey and
        --        cs.SectionCode = 'MED' and
        --        cs.IsDeleted = 0
        --) cs
    where
        cl.CountryKey = 'AU' and
        FirstNilEstimateDate >= @rptStartDate and
        FirstNilEstimateDate <  dateadd(day, 1, @rptEndDate) and
        --online claims are created with first estimate = 0, we don't want these first estimates
        isnull(peh.PreviousEstimate, 0) <> 0
    order by 1, 2
    
end
GO
