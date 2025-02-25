USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0292]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0292]
    @Country varchar(2) = 'AU',
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @ClaimStatus varchar(50) = 'All',
    @MinimumPayment int = 0
                      
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0292
--  Author:         Leonardus Setyabudi
--  Date Created:   20120217
--  Description:    This stored procedure returns claims marked as potential recovery on specified period
--  Parameters:     @Country: Country code, currently only applies to AU
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriodUpTo = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriodUpTo = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @ClaimStatus: Filter on latest claim status (All, Current, Finalised)
--                  @MinimumPayment: Filter on payment made on claim (PAID only)
--   
--  Change History: 20120217 - LS - Created
--                  20120430 - LS - Case 17314, add Claim Status
--                  20120810 - LS - Case 17782, add filters
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @ClaimStatus varchar(50)
declare @MinimumPayment int
select 
    @Country = 'AU',
    @ReportingPeriod = 'Last 6 Months', 
    @StartDate = null, 
    @EndDate = null,
    @ClaimStatus = 'Finalised',
    @MinimumPayment = 500
*/

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime, @StartDate), 
            @rptEndDate = convert(smalldatetime, @EndDate)

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from [db-au-cmdwh].dbo.vDateRange
        where DateRange = @ReportingPeriod

    select
        acl.ClaimNo,
        cs.Name AuditUserName,
        AuditDateTime,
        case
            when AuditAction = 'I' then 'Create'
            when AuditAction = 'U' then 'Update'
            else 'Undefined'
        end AuditAction,
        case
            when acl.RecoveryType = 1 then 'Potential Recovery'
            else ''
        end RecoveryType,
        cl.StatusDesc ClaimStatus,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    from 
        clmAuditClaim acl
        inner join clmSecurity cs on 
            cs.CountryKey = acl.CountryKey and
            cs.Login = acl.AuditUserName
        inner join clmClaim cl on 
            cl.ClaimKey = acl.ClaimKey
        outer apply
        (
            select sum(PaymentAmount) Paid
            from 
                clmPayment cp
            where
                cp.ClaimKey = cl.ClaimKey and
                cp.PaymentStatus in ('PAID')
        ) cp
    where 
        acl.CountryKey = @Country and
        AuditDateTime >= @rptStartDate and
        AuditDateTime <  dateadd(day, 1, @rptEndDate) and
        acl.RecoveryType > 0 and
        not exists
        (
            select null
            from clmAuditClaim t
            where 
                t.ClaimKey = acl.ClaimKey and
                t.AuditDateTime < acl.AuditDateTime and
                t.RecoveryType > 0
        ) and
        (
            @ClaimStatus = 'All' or
            cl.StatusDesc = @ClaimStatus
        ) and
        (
            @MinimumPayment = 0 or
            isnull(Paid, 0) > @MinimumPayment
        )
    order by AuditDateTime, ClaimNo
  
end
GO
