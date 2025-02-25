USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_propello_customer]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_propello_customer]
    @DateRange varchar(30) = 'Yesterday',
    @StartDate date = null,
    @EndDate date = null

as
begin
--20161101, LL, productionised

    set nocount on

    declare
        @start date,
        @end date

    if @DateRange = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @DateRange

    ;with
    cte_base as
    (
        select --top 1000
            cl.ClaimKey,
            p.PolicyKey,
            p.PolicyNumber,
            p.CountryKey + '-' + p.PolicyNumber [POLICY_ID]
        from
            [db-au-cmdwh].dbo.clmClaim cl with(nolock)
            --deliberate inner join, exclude CMC and PNR as Propello needs customer data
            inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
            inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                p.PolicyKey = pt.PolicyKey
        where
            cl.CountryKey in ('AU','NZ') and
            p.IssueDate >= '2011-07-01' and
            (
                (
                    cl.CreateDate >= @start and
                    cl.CreateDate <  dateadd(day, 1, @end)
                ) 
                --send customer only on claim create date
                --or
                --exists
                --(
                --    select
                --        null
                --    from
                --        [db-au-cmdwh].dbo.clmAuditPayment cap with(nolock)
                --    where
                --        cap.ClaimKey = cl.ClaimKey and
                --        cap.PaymentStatus = 'PAID' and
                --        cap.AuditDateTime >= @start and
                --        cap.AuditDateTime <  dateadd(day, 1, @end)
                --)
            )
    ),
    cte_out as
    (
        select --top 1000
            ptv.CountryKey [COUNTRY],
            ptv.PolicyTravellerKey [CUSTOMER_ID],
            b.[POLICY_ID],
            isnull(ptv.Title, '') [TITLE],
            isnull(ptv.FirstName, '') [FIRST_NAME],
            isnull(ptv.LastName, '') [SURNAME],
            isnull(convert(varchar(10), ptv.DOB, 120), '') [DATE_OF_BIRTH],
            isnull(ptv.AddressLine1, '') [ADDRESS],
            case
                when ptv.CountryKey = 'AU' then isnull(ptv.Suburb, '') 
                else ''
            end [SUBURB],
            case
                when ptv.CountryKey = 'AU' then isnull(ptv.State, '') 
                else ''
            end [STATE],
            case
                when ptv.CountryKey = 'NZ' then isnull(ptv.Suburb, '') 
                else ''
            end [TOWN/CITY],
            isnull(ptv.PostCode, '') [POSTCODE],
            isnull(ptv.HomePhone, '') [PHONE],
            coalesce(ptv.WorkPhone, ptv.MobilePhone, '') [MOBILE],
            isnull(ptv.EmailAddress, '') [EMAIL],
            case
                when ptv.isPrimary = 1 then 'Y'
                else 'N'
            end [PRIMARY],
            case
                when exists
                    (
                        select 
                            null
                        from
                            [db-au-cmdwh].dbo.penPolicyTravellerTransaction ptt with(nolock)
                            inner join [db-au-cmdwh].dbo.penPolicyEMC pe with(nolock) on
                                pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
                        where
                            ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
                    ) 
                then 'Y'
                else 'N'
            end [EMC],
            isnull(ptv.MemberNumber, '') [MEMBERSHIP]
        from
            (
                select distinct
                    PolicyKey,
                    [POLICY_ID]
                from
                    cte_base b
            ) b
            inner join [db-au-cmdwh].dbo.penPolicyTraveller ptv with(nolock) on
                ptv.PolicyKey = b.PolicyKey
    )
    select
        'customer_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
        0 xDataValuex,
        cast('COUNTRY|CUSTOMER_ID|POLICY_ID|TITLE|FIRST_NAME|SURNAME|DATE_OF_BIRTH|ADDRESS|SUBURB|STATE|TOWN/CITY|POSTCODE|PHONE|MOBILE|EMAIL|PRIMARY|EMC|MEMBERSHIP' as nvarchar(max)) Data
        
    union all

    select
        'customer_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        [CUSTOMER_ID] xDataIDx,
        0 xDataValuex,
        cast
        (
            isnull([COUNTRY], '') + '|' +
            isnull([CUSTOMER_ID], '') + '|' +
            isnull([POLICY_ID], '') + '|' +
            isnull([TITLE], '') + '|' +
            isnull([FIRST_NAME], '') + '|' +
            isnull([SURNAME], '') + '|' +
            isnull([DATE_OF_BIRTH], '') + '|' +
            isnull([ADDRESS], '') + '|' +
            isnull([SUBURB], '') + '|' +
            isnull([STATE], '') + '|' +
            isnull([TOWN/CITY], '') + '|' +
            isnull([POSTCODE], '') + '|' +
            isnull([PHONE], '') + '|' +
            isnull([MOBILE], '') + '|' +
            isnull([EMAIL], '') + '|' +
            isnull([PRIMARY], '') + '|' +
            isnull([EMC], '') + '|' +
            isnull([MEMBERSHIP], '') 
            as nvarchar(max)
        ) Data
    from
        cte_out

    --union all

    --select
    --    'customer_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
    --    convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
    --    0 xDataValuex,
    --    N'κόσμε'
    --    --nchar(0xFEFF) Data

end


--exec rawsp_propello_customer
--    @StartDate = '2016-10-01',
--    @EndDate = '2016-10-02'
GO
