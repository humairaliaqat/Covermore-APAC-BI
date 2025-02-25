USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0554]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0554]
    @Country varchar(2),
    @Company varchar(5) = 'All',
    @ReportingPeriod varchar(30),
    @StartDate date = null,
    @EndDate date = null,
    @BatchNo int = null
    
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0554
--  Author:         Leo
--  Date Created:   20140523
--  Description:    Returns direct debit payments based on date range or specific batch.
--  Parameters:     
--                  @Country, country code
--                  @Company, optional company code
--                  @ReportingPeriod, valid date range on batch modified time
--                  @StartDate, optional start of batch modified time
--                  @EndDate, optional end of batch modified time
--                  @BatchNo, optional batch number, higher precedence than date range
--                  
--  Change History: 
--                  20140523 - LS - Created
--                  20140530 - LS - only for blank email or opt out
--                  20140604 - LS - typo for user defined date range
--                  20140826 - LS - T12242 Global Claim, use clmPaymentBatch
--                  20150416 - LS - why is the @BatchNo not used? doohh
--                  20150417 - LS - F24015, words
--                  
/****************************************************************************************************/

--debug
--declare
--    @Country varchar(2),
--    @Company varchar(5),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date,
--    @BatchNo int
--select
--    @Country = 'AU',
--    @Company = 'All',
--    @ReportingPeriod = 'Yesterday',
--    @StartDate = null,
--    @EndDate = null,
--    @BatchNo = null

    set nocount on
    
    declare
        @rptStartDate date,
        @rptEndDate date

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
        cl.ClaimNo,
        cq.BatchNo,
        cq.ChequeNo,
        cn.Title Title,
        cn.FirstName,
        cn.Surname LastName,
        cn.AddressStreet Street,
        cn.AddressSuburb Suburb,
        cn.AddressState State,
        cn.AddressPostCode Postcode,
        cq.PaymentDate PayDate,
        cp.SectionCode,
        cp.Section,
        cq.CurrencyCode,
        cq.BillAmount,
        cq.ForeignExchangeRate,
        cq.Other,
        cq.AUDAmount,
        cq.DepreciationValue Depreciation,
        cq.Excess,
        cq.TotalValue Value,
        cq.ChequeWording Wording
    from
        clmPaymentBatch cq
        inner join clmName cn on
            cn.NameKey = cq.NameKey
        inner join clmClaim cl on
            cl.ClaimKey = cq.ClaimKey
        cross apply
        (
            select top 1 
                cs.SectionCode,
                cs.SectionDescription Section
            from
                clmPayment cp
                inner join clmSection cs on
                    cs.SectionKey = cp.SectionKey
            where
                cp.ClaimKey = cq.ClaimKey and
                cp.PaymentID = cq.PaymentID
        ) cp
        outer apply
        (
            select top 1
                CompanyKey
            from
                penOutlet o
            where
                o.CountryKey = cl.CountryKey and
                o.AlphaCode = cl.AgencyCode and
                o.OutletStatus = 'Current'
        ) o
        --inner join clmPayment cp on
        --    cp.ClaimKey = cl.ClaimKey and
        --    cp.BatchNo = cq.BatchNo and
        --    cp.PaymentID = cq.PayID
        --cross apply
        --(
        --    select top 1
        --        Title,
        --        FirstName,
        --        Surname,
        --        AddressStreet,
        --        AddressSuburb,
        --        AddressState,
        --        AddressPostCode
        --    from
        --        clmName cn 
        --    where
        --        cn.NameKey = cp.PayeeKey and
        --        cn.isPrimary = 1
        --    order by
        --        cn.NameID
        --) cn
    where
        cl.CountryKey = @Country and
        (
            @Company = 'All' or
            isnull(o.CompanyKey, 'CM') = @Company --corporate classified as CM
        ) and
        cq.PaymentMethod = 'DD' and
        (
            (
                isnull(@BatchNo, '') <> '' and
                cq.BatchNo = @BatchNo
            ) or
            (
                cq.PaymentModifiedDate >= @rptStartDate and
                cq.PaymentModifiedDate <  dateadd(day, 1, @rptEndDate) 
            ) 
        ) and
        cq.BatchStatus = 'PROC' and
        cq.PaymentStatus = 'PAID' and
        cq.isDeleted = 0 and
        (
            isnull(cn.Email, '') = '' or
            cn.isEmailOK = 0
        )
    order by
        cl.ClaimNo
        
end
GO
