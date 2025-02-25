USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_mb_sunglasses_promo]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_mb_sunglasses_promo]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as

/****************************************************************************************************/
--  Name:           dbo.rawsp_mb_sunglasses_promo
--  Author:         Leonardus Li
--  Date Created:   20190709
--  Description:    This stored procedure returns Medibank policy holders details who have purchased
--					travel insurance using Sunglass Hut promo codes
--
--  Change History: 20190709 - LL - Created
--					20190719 - LT - Added additional policyholder details as per request (REQ-1886)
--
/****************************************************************************************************/


begin

    set nocount on

	--uncomment to debug
/*	
	declare @DateRange varchar(30)
	declare @StartDate date
	declare @EndDate date
	select @DateRange = 'Month-To-Date'
*/

    declare @dataStartDate date
    declare @dataEndDate date

    /* get dates */
    if @DateRange = '_User Defined'
        select
            @dataStartDate = @StartDate,
            @dataEndDate = @EndDate

    else
        select
            @dataStartDate = StartDate,
            @dataEndDate = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    
    select --top 5 
        ptv.FirstName,
        ptv.LastName,
		ptv.DOB,
		ptv.MemberNumber,
        lower(ptv.EmailAddress) EmailAddress,
        case
            when isnull(rtrim(ptv.AddressLine1), '') <> '' then 
                upper
                (
                    isnull(rtrim(ptv.AddressLine1), '') + ' ' +
                    isnull(rtrim(ptv.Suburb), '') + ' ' +
                    isnull(rtrim(ptv.State), '') + ' ' + 
                    isnull(rtrim(ptv.PostCode), '')
                )
            else ''
        end PostalAddress,
        (
            select top 1
                ptp.PromoCode
            from
                penPolicyTransactionPromo ptp with(nolock)
            where
                ptp.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptp.IsApplied = 1 and
                ptp.PromoCode in ('SGH50', 'P50SGH')
        ) PromoCode
    from
        penPolicy p with(nolock)
        inner join penPolicyTransSummary pt with(nolock) on
            pt.PolicyKey = p.PolicyKey
        inner join penPolicyTraveller ptv with(nolock) on
            ptv.PolicyKey = p.PolicyKey
        inner join penOutlet o with(nolock) on
            o.OutletAlphaKey = p.OutletAlphaKey
    where
        o.OutletStatus = 'Current' and
        o.CountryKey = 'AU' and
        o.GroupCode = 'MB' and
        pt.TransactionType = 'Base' and
        pt.TransactionStatus = 'Active' and
        pt.PostingDate >= @dataStartDate and
        pt.PostingDate <  dateadd(day, 1, @dataEndDate) and
        ptv.isPrimary = 1 and
        isnull(rtrim(ltrim(ptv.MemberNumber)), '') <> '' and
        p.ProductCode = 'MBC' and
        exists
        (
            select
                null
            from
                penPolicyTransactionPromo ptp with(nolock)
            where
                ptp.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptp.IsApplied = 1 and
                ptp.PromoCode in ('SGH50', 'P50SGH')
        )

end
GO
