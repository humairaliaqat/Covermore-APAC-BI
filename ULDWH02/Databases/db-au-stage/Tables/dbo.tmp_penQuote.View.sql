USE [db-au-stage]
GO
/****** Object:  View [dbo].[tmp_penQuote]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[tmp_penQuote]
as
    select 
        QuoteKey,
        CreateTime,
        o.GroupName OutletGroup,
        datepart(hh, CreateTime) TransactionHour,
        case 
            when Destination = '' then null
            when Destination like 'São Tomé%' then 'Sao Tome and Principe' 
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(Destination)
        end Destination,
        datediff(day, convert(date, CreateTime), convert(date, DepartureDate)) LeadTime,
        datediff(day, convert(date, DepartureDate), convert(date, ReturnDate)) + 1 Duration,
        qc.TravellerAge,
        case
            when isnull(PolicyKey, '') = '' then 0
            else 1
        end ConvertedFlag,
        SessionID,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        case
            when PromoCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(PromoCode)
        end PromoCode,
        NumberOfAdults,
        NumberOfChildren,
        IsSaved,
        case
            when AgentReference = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(AgentReference)
        end AgentReference,
        QuotedPrice,
        ProductCode,
        case
            when CRMUserName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(CRMUserName)
        end CRMUserName,
        PreviousPolicyNumber,
        IsPriceBeat,
        ParentQuoteID
    from 
        [db-au-cmdwh].dbo.penQuote q with(nolock)
        inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
            o.OutletAlphaKey = q.OutletAlphaKey and
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1 
                qc.Age TravellerAge
            from
                [db-au-cmdwh].dbo.penQuoteCustomer qc with(nolock)
            where
                qc.QuoteCountryKey = q.QuoteCountryKey
            order by
                qc.QuoteCustomerID
        ) qc
    where 
        UserName = 'webuser'
GO
