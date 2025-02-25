USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetEMCDomainKeys]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetEMCDomainKeys]
(
    @ClientID int,
    @CountrySet varchar(5)
)
returns @output table
(
    CountryKey varchar(2),
    TimeZone varchar(50)
)
as
begin
/*
    20140318, LS,   TFS 9410, create
*/

    declare
        @countrykey varchar(2),
        @domainid int,
        @tz varchar(50)

	if @CountrySet = 'AU'
	begin
	
		select top 1
			@domainid = c.Domainid
		from
		    emc_EMC_tblEMCApplications_AU e
			inner join emc_EMC_Companies_AU c on
			    c.Compid = e.CompID
		where
			ClientID = @ClientID

	end

	else if @CountrySet = 'UK'
	begin
	
		select top 1
			@domainid = c.Domainid
		from
		    emc_UKEMC_tblEMCApplications_UK e
			inner join emc_UKEMC_Companies_UK c on
			    c.Compid = e.CompID
		where
			ClientID = @ClientID
			
	end
	
	select top 1
		@countrykey = CountryCode,
		@tz = d.TimeZoneCode
	from
		[db-au-cmdwh]..usrDomain d
	where
		d.DomainID = @domainid

		
	if @countrykey is null
	begin
	
	    select 
	        @countrykey = e.CountryKey
	    from
	        [db-au-cmdwh]..emcApplications e
	    where
	        e.ApplicationID = @ClientID
	
	end
	
    set @countrykey = isnull(@countrykey, 'AU')
    set @tz = isnull(@tz, 'AUS Eastern Standard Time')

    insert into @output
    (
        CountryKey,
        TimeZone
    )
    select
        @countrykey,
        @tz

    return

end
GO
