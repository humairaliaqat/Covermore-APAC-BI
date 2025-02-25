USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetQuoteDomainKeys]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_GetQuoteDomainKeys]
(
    @QuoteID int,
    @CompanyKey varchar(5),
    @CountrySet varchar(5)
)
returns @output table
(
	CountrySet varchar(5),
    CountryKey varchar(2),
    CompanyKey varchar(5),
    DomainKey varchar(41),
    PrefixKey varchar(41),
    TimeZone varchar(50),
    DomainID int
)
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20160321 - LT - Penguin 18.0, added US Penguin instance

*/

    declare @domainid int

    if @CountrySet = 'AU'
    begin

        if @CompanyKey = 'CM'
            select top 1
                @domainid = q.DomainID
            from
                penguin_tblQuote_aucm q
            where
                q.QuoteID = @QuoteID

        else if @CompanyKey = 'TIP'
            select top 1
                @domainid = q.DomainID
            from
                penguin_tblQuote_autp q
            where
                q.QuoteID = @QuoteID
                
    end
    
    else if @CountrySet = 'UK'
    begin
    
        select top 1
            @domainid = q.DomainID
        from
            penguin_tblQuote_ukcm q
        where
            q.QuoteID = @QuoteID
            
    end

    else if @CountrySet = 'US'
    begin
    
        select top 1
            @domainid = q.DomainID
        from
            penguin_tblQuote_uscm q
        where
            q.QuoteID = @QuoteID
            
    end

    insert into @output
    (
		CountrySet,
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey,
        TimeZone,
        DomainID
    )
    select
		CountrySet,
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey,
        TimeZone,
        @domainid DomainID
    from
        dbo.fn_GetDomainKeys(@domainid, @CompanyKey, @CountrySet)

    return

end

GO
