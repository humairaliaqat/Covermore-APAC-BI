USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0282_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0282_Test_INC0319227]    
    @Country varchar(3),            --required AU, NZ, UK, or ALL
    @Underwriter varchar(10),       --required GLA, VERO, TIP, ETI, UKU, OTHER, or ALL
    @PolicyGroup varchar(30),       --required Leisure, Corporate, or ALL
    @PaymentStatus varchar(200),    --required 1 or more payment statuses
    @WhatDate varchar(30),          --required Payment Modified Date, Paymet Create Date, or Cheque Payment Date
    @ReportingPeriod varchar(30),   --required standard date range
    @StartDate varchar(10) = null,  --required if @ReportingPeriod = '_User Defined'
    @EndDate varchar(10) = null,    --required if @ReportingPeriod = '_User Defined'
    @ClaimNo varchar(200) = null,   --optional 1 or more Claim numbers (use comma separator)
    @BatchNo varchar(200) = null    --optional 1 or more Batch numbers (user comma separator)

as
begin
/****************************************************************************************************/
--    Name:             dbo.rptsp_rpt0282
--    Author:           Linus Tor
--    Date Created:     20120130
--    Description:      This stored procedure returns claims payments as per paramater values
--
--    Parameters:       @Country:           Required. Value is AU, NZ, UK, or ALL
--                      @Underwriter:       Required. Value is GLA, VERO, TIP, ETI, UKU, OTHER, or ALL
--                      @PolicyGroup:       Required. Value is Leisure, Corporate, or ALL
--                      @PaymentStatus:     Required. Value is one or more separated by comma
--                      WhatDate:           Required. Value is Payment Modified Date, Payment Create Date, Cheque Payment Date 
--                      ReportingPeriod:    Required. Value is standard date range
--                      StartDate:          Required if ReportingPeriod = _User Defined. Value is date value eg 2012-01-01
--                      EndDate:            Required if ReportingPeriod = _User Defined. Value is date value eg 2012-01-01
--                      ClaimNo:            Optional. Value is 1 or more claim number (separated by comma)
--                      BatchNo:            Optional. Value is 1 or more batch number (separated by comma)
--    
--    Change History:   20120130 - LT - Created
--                      20140916 - LT - Fogbugz #21879 - Add EventDate to report
--                      20150922 - LT - Fixed Underwriter definition error
--                      20160411 - LS - refactoring prior to any fixes
--                      20160411 - LS - replace legacy Agency with penOutlet
--                                      update UW definition
--                                      remove dynamic sql
--						20160420 - GP - Incident - INC0007240 - Requestor - Fioni Theodora - added 2 columns - 1) Plan 2) Trip Type
--                      20160422 - LS - notorious legacy alphas in UK, coalesce this with legacy Agency table
--                      20160926 - LS - don't check deleted section for NZ old system (it's closed, whatever happened .. happened)
--                                      ref: SN INC0017276 
--						20161219 - LT - Updated TIP UW definition to include AHM
--						20170601 - LT - Updated UW definition as part of Zurich UW changeover
--						20170630 - LT - Updated UW definition for APOTC
--						20171101 - LT - Updated UW definition for ETI and ERV
--                    
/****************************************************************************************************/


--uncomment to debug
/*
declare @Country varchar(3)
declare @Underwriter varchar(10)
declare @PolicyGroup varchar(30)
declare @PaymentStatus varchar(200)
declare @WhatDate varchar(30)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @ClaimNo varchar(200)
declare @BatchNo varchar(200)
select 
    @Country = 'AU', 
    @Underwriter = 'GLA', 
    @PolicyGroup = 'Leisure', 
    @PaymentStatus = 'PAID,STOP, FAIL , RECY', 
    @WhatDate = null, 
    @ReportingPeriod =  null, 
    @StartDate = null, 
    @EndDate = null, 
    @ClaimNo = null, 
    @BatchNo = null
*/

    set nocount on
       
    declare 
        @WhereCountry varchar(500),
        @WhereUnderwriter varchar(500),
        @WherePolicyGroup varchar(500),
        @WherePaymentStatus varchar(500),
        @WhereWhatDate varchar(500),
        @rptStartDate datetime,
        @rptEndDate datetime,
        @WhereClaimNo varchar(500),
        @WhereBatchNo varchar(500),  
        @SQL varchar(8000)


    /* Process @ReportingPeriod parameter */
    if @ReportingPeriod = '_User Defined'
    select 
        @rptStartDate = convert(smalldatetime,@StartDate), 
        @rptEndDate = convert(smalldatetime,@EndDate)

    else if @ReportingPeriod is null or @ReportingPeriod = ''
        select 
            @rptStartDate = '1900-01-01', 
            @rptEndDate = '9999-12-31'
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod                                                                        


    select --top 1000
        uw.Underwriter,
        pg.PolicyGroup,
        AccountingDate,
        c.ClaimNo,
        c.PolicyProduct,
        c.PolicyNo,
        c.PolicyIssuedDate,
        c.ReceivedDate,
        c.PolicyPlanCode,
        c.AgencyCode,
        coalesce(o.AgencyGroupCode, lo.AgencyGroupCode, '') AgencyGroupCode,
        coalesce(o.AgencyGroupState, lo.AgencyGroupState, '') AgencyGroupState,
        e.EventCountryName,
        e.CatastropheCode,
        s.SectionID,
        s.SectionCode,
        p.PaymentID,
        p.ModifiedDate,
        p.GoodServ,
        p.TPLoc,
        p.PayeeType,
        p.PayeeID,
        p.DEPR,
        p.Taxable,
        p.BatchNo,
        p.PaymentStatus,
        ch.PaymentDate,
        ch.ChequeNo,
        ch.TransactionType,
        n.Title,
        n.Firstname,
        n.Surname,
        n.BusinessName,
        n.ITCPCT,
        p.PaymentAmount,
        p.ExcessAmount,
        p.GST,
        p.DAMOutcome,
        p.ITCAdjustedAmount,
        p.GSTOutcome,
        p.ITCOutcome,
        p.DEPV,
        p.OtherDesc,
        e.EventID,                
        e.CatastropheShortDesc,
        e.CaseID,
        c.IntDom,
        e.EventDesc,
        e.EventDate,

		isnull(pt.PlanName, '') PlanName,
		isnull(pt.TripType, '') TripType,

        convert(datetime,convert(varchar(10),@rptStartDate,120)) as rptStartDate,
        convert(datetime,convert(varchar(10),@rptEndDate,120)) as rptEndDate

    --into [db-au-workspace]..RPT0282_GLA_new
    from
        [db-au-cmdwh].dbo.clmPayment p 
        left join [db-au-cmdwh].dbo.clmSection s on 
            s.SectionKey = p.SectionKey
        left join [db-au-cmdwh].dbo.clmEvent e on 
            e.EventKey = p.EventKey 
        inner join [db-au-cmdwh].dbo.clmClaim c on
            c.ClaimKey = p.ClaimKey
        outer apply
        (
            select top 1 *
            from
                [db-au-cmdwh].dbo.clmSecheque ch
            where
                p.ChequeKey = ch.ChequeKey
        ) ch
        outer apply
        (
            select top 1 *
            from
                [db-au-cmdwh].dbo.clmName n
            where
                p.PayeeKey = n.NameKey 
        ) n
        outer apply
        (
            select top 1
                o.GroupCode AgencyGroupCode,
                o.StateSalesArea AgencyGroupState,
				o.AlphaCode
            from
                [db-au-cmdwh].dbo.penOutlet o
            where
                o.OutletStatus = 'Current' and
                o.OutletKey = c.OutletKey
        ) o
        outer apply
        (
            select top 1
                o.AgencyGroupCode,
                a.AgencyGroupState 
            from
                [db-au-cmdwh].dbo.Agency a
            where
                a.AgencyStatus = 'Current' and
                a.AgencyKey = c.AgencyKey
        ) lo

		outer apply
        (
            select top 1
                p.PlanName,
                p.TripType
            from
                [db-au-cmdwh].dbo.penPolicyTransSummary pt
                inner join [db-au-cmdwh].dbo.penPolicy p on
                    p.PolicyKey = pt.PolicyKey
            where
                pt.PolicyTransactionKey = c.PolicyTransactionKey
        ) pt

        outer apply
        (
            select
                case 
                    when c.CountryKey in ('AU', 'NZ') and o.AgencyGroupCode in ('AH','AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN') and (c.PolicyIssuedDate < '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and c.PolicyIssuedDate < '2017-07-01')) then 'TIP-GLA'
					when c.CountryKey in ('AU', 'NZ') and o.AgencyGroupCode in ('AH','AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN','KG','BP') and (c.PolicyIssuedDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and c.PolicyIssuedDate >= '2017-07-01')) then 'TIP-ZURICH'
                    when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate between '2002-08-23' and '2009-06-30' then 'VERO'
                    when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate >= '2009-07-01' and c.PolicyIssuedDate < '2017-06-01' then 'GLA'
					when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate >= '2017-06-01' then 'ZURICH'
                    when c.CountryKey in ('UK') and c.PolicyIssuedDate >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when c.CountryKey in ('UK') and c.PolicyIssuedDate >= '2017-07-01' then 'ERV'
                    when c.CountryKey in ('UK') and c.PolicyIssuedDate < '2009-09-01' then 'UKU'
                    when c.CountryKey in ('MY', 'SG') then 'ETIQA'
                    when c.CountryKey in ('CN') then 'CCIC'
                    when c.CountryKey in ('ID') then 'Simas Net'
                    else 'OTHER'
                end Underwriter
        ) uw
        outer apply
        (
            select
                case 
                    when c.PolicyProduct = 'CMC' then 'Corporate' 
                    else 'Leisure' 
                end PolicyGroup
        ) pg
    where
        (
            isnull(s.isDeleted, 0) = 0
        ) and
        p.isDeleted = 0 and
        (
            isnull(@Country, '') in ('', 'ALL') or
            c.CountryKey = isnull(@Country, '')
        ) and
        (
            isnull(@Underwriter, '') in ('', 'ALL') or
            uw.Underwriter = isnull(@Underwriter, '')
        ) and
        (
            isnull(@PolicyGroup, '') in ('', 'ALL') or
            pg.PolicyGroup = isnull(@PolicyGroup, '')
        ) and
        (
            isnull(@PaymentStatus, '') in ('', 'ALL') or
            p.PaymentStatus in 
            (
                select 
                    ltrim(rtrim(Item))
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@PaymentStatus, ',')
            )
        ) and
        (
            (
                isnull(@WhatDate, 'Payment Modified Date') = 'Payment Modified Date' and
                (
                    p.ModifiedDate is null or
                    (
                        p.ModifiedDate >= @rptStartDate and
                        p.ModifiedDate <  dateadd(day, 1, @rptEndDate)
                    )
                )
            ) or
            (
                isnull(@WhatDate, 'Payment Modified Date') = 'Payment Create Date' and
                p.CreatedDate >= @rptStartDate and
                p.CreatedDate <  dateadd(day, 1, @rptEndDate)
            ) or
            (
                isnull(@WhatDate, 'Payment Modified Date') = 'Cheque Payment Date' and
                ch.PaymentDate >= @rptStartDate and
                ch.PaymentDate <  dateadd(day, 1, @rptEndDate)
            )
        ) and
        (
            isnull(@ClaimNo, '') in ('', 'ALL') or
            c.ClaimNo in 
            (
                select 
                    try_convert(int, ltrim(rtrim(Item)))
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@ClaimNo, ',')
            )
        ) and
        (
            isnull(@BatchNo, '') in ('', 'ALL') or
            p.BatchNo in 
            (
                select 
                    ltrim(rtrim(Item))
                from
                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@BatchNo, ',')
            )
        )



end

GO
