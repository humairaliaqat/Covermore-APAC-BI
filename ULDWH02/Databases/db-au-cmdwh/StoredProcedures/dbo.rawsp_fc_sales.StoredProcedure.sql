USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_fc_sales]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_fc_sales]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin


/****************************************************************************************************/
--  Name:          rawsp_fc_sales
--  Author:        PW
--  Date Created:  20150908
--  Description:   
--  Parameters:    @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--
--  Change History: 20150908 - LS - put in SP
--                  20160106 - LS - change to transaction level (Tom Kyte)
--                  20160310 - LS - add PolicyType
--
/****************************************************************************************************/
--uncomment to debug
/*
declare
    @DateRange varchar(30),
    @StartDate date,
    @EndDate date
select
    @DateRange = '_User Defined',
    @StartDate = '2015-05-05',
    @EndDate = '2015-05-05'
*/

    set nocount on

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

    select --top 1000
        o.EGMNation Brand,
        o.FCArea Area,
        o.FCNation Nation,
        isnull(p.PrimaryCountry, '') Destination,
        o.AlphaCode,
        isnull(o.ExtID, '') T3Code,
        o.OutletName StoreName,
        p.PolicyNumber,
        pt.PolicyNumber TransactionNumber,
        convert(date, pt.PostingDate) TransactionDate,
        p.AreaType,
        p.TripType,
        (pp.Premium) Premium,
        (pt.BasePolicyCount) BasePolicyCount,
        (pt.TravellersCount) TravellersCount,
        p.ProductDisplayName PolicyType
    from 
        penpolicytranssummary pt
        inner join penpolicy p on 
            pt.PolicyKey = p.PolicyKey
        inner join penoutlet o on 
            pt.OutletAlphaKey = o.OutletAlphaKey and 
            o.OutletStatus = 'Current'
        inner join vPenguinPolicyPremiums pp on
            pp.PolicyTransactionKey = pt.PolicyTransactionKey
    where 
        o.CountryKey = 'AU' and
        o.SuperGroupName = 'Flight Centre' and 
        pt.PostingDate >= @dataStartDate and
        pt.PostingDate <  dateadd(day, 1, @dataEndDate)
    --group by
    --    o.EGMNation,
    --    o.FCArea,
    --    o.FCNation,
    --    isnull(p.PrimaryCountry, ''),
    --    o.AlphaCode,
    --    isnull(o.ExtID, ''),
    --    o.OutletName,
    --    convert(date, pt.PostingDate),
    --    p.AreaType,
    --    p.TripType

end
GO
