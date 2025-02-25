USE [db-au-workspace]
GO
/****** Object:  View [dbo].[dimCustomer]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[dimCustomer] 
as
select --top 1000 
    convert(int, CustomerID) CustomerID,
    Customer,
    Deceased,
    isnull(Gender, 'Unknown') Gender,
    case
        when datediff(day, getdate(), nxb.NextBirthday) < 32 then 1
        when datediff(day, nxb.LastBirthday, getdate()) < 8 then 1
        else 0
    end NearBirthday,
    DateOfBirth,
    age.CurrentAge,
    isnull(nxb.LastBirthday, '1990-01-01') LastBirthday,
    isnull(nxb.NextBirthday, '1990-01-01') NextBirthday,
    isnull(Phone1, '') Phone,
    isnull(Phone2, '') AlternativePhone,
    isnull(AddressLine, '') Address,
    isnull(Suburb, '') Suburb,
    isnull(State, '') State,
    isnull(PostCode, '') PostCode,
    isnull(EmailAddress, '') Email
from
    mdmCustomer c
    cross apply
    (
        select
            isnull(
                floor(
                    (
                        datediff(month, c.DateOfBirth, getdate()) -
                        case
                            when datepart(day, c.DateOfBirth) < datepart(day, getdate()) then 1
                            else 0
                        end
                    ) /
                    12
                ) ,
                0
            ) CurrentAge
    ) age
    cross apply
    (
        select 
            dateadd(year, age.CurrentAge, convert(date, c.DateOfBirth)) LastBirthday,
            dateadd(year, age.CurrentAge + 1, convert(date, c.DateOfBirth)) NextBirthday
    ) nxb

union all

select
    -1 CustomerID,
    'Unknown' Customer,
    'Unknown' Deceased,
    'Unknown' Gender,
    0 NearBirthday,
    '1990-01-01' DateOfBirth,
    0 CurrentAge,
    '1990-01-01' LastBirthday,
    '1990-01-01' NextBirthday,
    '' Phone,
    '' AlternativePhone,
    '' Address,
    '' Suburb,
    '' State,
    '' PostCode,
    '' Email


--alter view factCustomerTransaction
--as
--select --top 1000 
--    fpt.DateSK,
--    fpt.DomainSK,
--    fpt.OutletSK,
--    fpt.PolicySK,
--    fpt.AreaSK,
--    fpt.DestinationSK,
--    fpt.DurationSK,
--    fpt.ProductSK,
--    CustomerID,
--    TxSellPrice + AoSellPrice + EmcSellPrice + PaoSellPrice PolicyValue,

--    AoSellPrice + PaoSellPrice AddonValue,
--    EmcSellPrice EMCValue,
--    0 ClaimValue
--from
--    [db-au-workspace]..custPolicy p with(nolock)
--    inner join [db-au-workspace]..mdmCustomerTxn mx with(nolock) on
--        mx.TransactionRef = p.PolicyTravellerKey and
--        mx.SourceSystem = 'Penguin'
--    inner join [db-au-star]..factPolicyTransaction fpt with(nolock) on
--        fpt.PolicyTransactionKey = p.PolicyTransactionKey

--union all

--select --top 1000 
--    fpt.DateSK,
--    fpt.DomainSK,
--    fpt.OutletSK,
--    fpt.PolicySK,
--    fpt.AreaSK,
--    fpt.DestinationSK,
--    fpt.DurationSK,
--    fpt.ProductSK,
--    CustomerID,
--    isnull(dcl.ClaimSK, -1) ClaimSK,
--    null ComplaintRef,
--    null AssistanceRef,
--    0 PolicyValue,
--    0 AddonValue,
--    0 EMCValue,
--    ClaimValue
--from
--    [db-au-workspace]..custClaim cl with(nolock)
--    inner join [db-au-workspace]..mdmCustomerTxn mx with(nolock) on
--        mx.TransactionRef = cl.NameKey and
--        mx.SourceSystem = 'Claims'
--    inner join [db-au-star]..factPolicyTransaction fpt with(nolock) on
--        fpt.PolicyTransactionKey = cl.PolicyTransactionKey
--    left join [db-au-star]..dimClaim dcl with(nolock) on
--        dcl.ClaimKey = cl.ClaimKey

--union all

--select --top 1000 
--    *
--from
--    (
--        select 
--            fpt.DateSK,
--            fpt.DomainSK,
--            fpt.OutletSK,
--            fpt.PolicySK,
--            fpt.AreaSK,
--            fpt.DestinationSK,
--            fpt.DurationSK,
--            fpt.ProductSK,
--            CustomerID,
--            null ClaimSK,
--            w.Reference ComplaintRef,
--            null AssistanceRef,
--            0 PolicyValue,
--            0 AddonValue,
--            0 EMCValue,
--            0 ClaimValue
--        from
--            [db-au-workspace]..mdmCustomerTxn t
--            inner join [db-au-cmdwh]..e5Work w  with(nolock) on
--                w.Work_ID = t.TransactionRef
--            cross apply
--            (
--                select top 1 
--                    cl.PolicyTransactionKey
--                from
--                    [db-au-cmdwh]..clmClaim cl with(nolock)
--                where
--                    cl.ClaimKey = w.ClaimKey
--            ) c
--            inner join [db-au-star]..factPolicyTransaction fpt with(nolock) on
--                fpt.PolicyTransactionKey = c.PolicyTransactionKey
--        where   
--            sourcesystem = 'GIGYA'

--        union

--        select 
--            fpt.DateSK,
--            fpt.DomainSK,
--            fpt.OutletSK,
--            fpt.PolicySK,
--            fpt.AreaSK,
--            fpt.DestinationSK,
--            fpt.DurationSK,
--            fpt.ProductSK,
--            CustomerID,
--            null ClaimSK,
--            w.Reference ComplaintRef,
--            null AssistanceRef,
--            0 PolicyValue,
--            0 AddonValue,
--            0 EMCValue,
--            0 ClaimValue
--        from
--            [db-au-workspace]..mdmCustomerTxn t
--            inner join [db-au-cmdwh]..e5Work w  with(nolock) on
--                w.Work_ID = t.TransactionRef
--            cross apply
--            (
--                select top 1 
--                    pt.PolicyTransactionKey
--                from
--                    [db-au-cmdwh]..penPolicyTransSummary pt with(nolock)
--                    inner join [db-au-cmdwh]..penOutlet o with(nolock) on
--                        o.OutletAlphaKey = pt.OutletAlphaKey and
--                        o.OutletStatus = 'Current'
--                where
--                    pt.PolicyNumber = w.PolicyNumber and
--                    o.AlphaCode = w.AgencyCode and
--                    o.CountryKey = w.Country
--            ) pt
--            inner join [db-au-star]..factPolicyTransaction fpt with(nolock) on
--                fpt.PolicyTransactionKey = pt.PolicyTransactionKey 
--        where   
--            sourcesystem = 'GIGYA'
--    ) t

--union all

--select --top 1000 
--    fpt.DateSK,
--    fpt.DomainSK,
--    fpt.OutletSK,
--    fpt.PolicySK,
--    fpt.AreaSK,
--    fpt.DestinationSK,
--    fpt.DurationSK,
--    fpt.ProductSK,
--    CustomerID,
--    null ClaimSK,
--    null ComplaintRef,
--    cc.CaseKey AssistanceRef,
--    0 PolicyValue,
--    0 AddonValue,
--    0 EMCValue,
--    0 ClaimValue
--from
--    [db-au-workspace]..mdmCustomerTxn t with(nolock)
--    inner join [db-au-cmdwh]..cbCase cc with(nolock) on
--        cc.CaseKey = t.TransactionRef
--    cross apply
--    (
--        select top 1 
--            p.PolicyTransactionKey
--        from
--            [db-au-cmdwh]..cbPolicy p with(nolock)
--        where
--            p.CaseKey = cc.CaseKey
--    ) p
--    inner join [db-au-star]..factPolicyTransaction fpt with(nolock) on
--        fpt.PolicyTransactionKey = p.PolicyTransactionKey
--where   
--    sourcesystem = 'EMC'

--go

GO
