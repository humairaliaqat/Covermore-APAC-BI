USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetPolicyDomainKeys]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_GetPolicyDomainKeys]
(
    @PolicyID int,
    @CRMUserID int,
    @ConsultantID int,
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
20130613 - LT - CRMUser no longer has DomainID, set default domain to 7 (AU)
20130614 - LS - TFS 7664/8556/8557, UK Penguin
20130809 - LS - bug fix, don't set default domain id, let it find out from tblPolicy
20160321 - LT - Penguin 18.0, added US Penguin instance
*/

/*
note:
tblPolicy & tblPolicyTransaction are fact tables, they only have data within ETL date range, each call to this function should be aware of this.
workaround built in below codes to get domain id from dimension tables when applicable.
*/

    declare @domainid int

    --if @CRMUserID is not null
    --begin

    --    select @domainid = 7

    --end

	if @CountrySet = 'AU'
	begin

        if @domainid is null and @ConsultantID is not null
        begin

            if @CompanyKey = 'CM'
                select top 1
                    @domainid = DomainID
                from
                    penguin_tblUser_aucm u
                    inner join penguin_tblOutlet_aucm o on
                        o.OutletId = u.OutletId
                where
                    u.UserId = @ConsultantID

            else if @CompanyKey = 'TIP'
                select top 1
                    @domainid = DomainID
                from
                    penguin_tblUser_autp u
                    inner join penguin_tblOutlet_autp o on
                        o.OutletId = u.OutletId
                where
                    u.UserId = @ConsultantID

        end

        if @domainid is null
        begin

            if @CompanyKey = 'CM'
                select top 1
                    @domainid = p.DomainID
                from
                    penguin_tblPolicy_aucm p
                where
                    p.PolicyID = @PolicyID

            else if @CompanyKey = 'TIP'
                select top 1
                    @domainid = p.DomainID
                from
                    penguin_tblPolicy_autp p
                where
                    p.PolicyID = @PolicyID

        end
        
    end
    
    else if @CountrySet = 'UK'
    begin
    
        if @domainid is null and @ConsultantID is not null
        begin

            select top 1
                @domainid = DomainID
            from
                penguin_tblUser_ukcm u
                inner join penguin_tblOutlet_ukcm o on
                    o.OutletId = u.OutletId
            where
                u.UserId = @ConsultantID

        end

        if @domainid is null
        begin

            select top 1
                @domainid = p.DomainID
            from
                penguin_tblPolicy_ukcm p
            where
                p.PolicyID = @PolicyID

        end
	end

    else if @CountrySet = 'US'
    begin
    
        if @domainid is null and @ConsultantID is not null
        begin

            select top 1
                @domainid = DomainID
            from
                penguin_tblUser_uscm u
                inner join penguin_tblOutlet_uscm o on
                    o.OutletId = u.OutletId
            where
                u.UserId = @ConsultantID

        end

        if @domainid is null
        begin

            select top 1
                @domainid = p.DomainID
            from
                penguin_tblPolicy_uscm p
            where
                p.PolicyID = @PolicyID

        end        
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
