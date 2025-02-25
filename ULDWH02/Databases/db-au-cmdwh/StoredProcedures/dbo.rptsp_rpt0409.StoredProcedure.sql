USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0409]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0409]
    @Country varchar(2),  
    @LetterType varchar(25),
    @ReportingPeriod varchar(30),  
    @StartDate varchar(10) = null,  
    @EndDate varchar(10) = null  

as  
begin  
  
/****************************************************************************************************/  
--  Name:           dbo.[rptsp_rpt0409]  
--  Author:         Leonardus Setyabudi  
--  Date Created:   20130219
--  Description:    This stored procedure returns corporate policies with expiry date within specified
--                  date range.
--  Parameters:       
--                  @Country, Country code AU|NZ|UK
--                  @LetterType, Agent Other|Client Other|Client Direct
--                  @ReportingPeriod 
--                  @StartDate 
--                  @EndDate 
--
--  Change History: 
--                  20130219 - LS - Created 
--		    20160428 - SD - changed Agency table reference to penOutlet 
--                    
/****************************************************************************************************/  
  
--uncomment to debug  
--declare 
--    @Country varchar(2),
--    @LetterType varchar(25),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10)  
--select   
--    @Country = 'AU',  
--    @LetterType = 'Agent Other',
--    @ReportingPeriod = 'Date +6 weeks',
--    @StartDate = null,   
--    @EndDate = null  
  
    set nocount on  
  
    declare @rptStartDate datetime  
    declare @rptEndDate datetime  
  
    /* get reporting dates */  
    if @ReportingPeriod = '_User Defined'  
        select   
            @rptStartDate = @StartDate,   
            @rptEndDate = @EndDate  
  
    else  
        select   
            @rptStartDate = StartDate,   
            @rptEndDate = EndDate  
        from   
            [db-au-cmdwh].dbo.vDateRange  
        where   
            DateRange = @ReportingPeriod  

    
    select 
        q.QuoteID,
        q.PolicyNo,
        q.PolicyExpiryDate,
        c.CompanyName,
	o.AlphaCode [AgencyCode],
	o.OutletName [AgencyName],
	o.ContactStreet [AgentStreet], 
	o.ContactSuburb [AgentSuburb], 
	o.ContactState [AgentState], 
	o.ContactPostCode [AgentPostCode],
        ClientFirstName,
        ClientContact,
        ClientStreet,
        ClientSuburb,
        ClientState,
        ClientPostCode,
        GSTGross,
        SalesExGST
    from
        corpQuotes q
        inner join corpCompany c on
            c.CompanyKey = q.CompanyKey
        cross apply
        (
            select
                sum(GSTGross) GSTGross,
                sum(UWSaleExGST) SalesExGST
            from
                corpTaxes tx
            where
                tx.QuoteKey = q.QuoteKey and
                tx.PropBal in ('P', 'B')
        ) tx
        outer apply
		(
			select
				top 1
				AlphaCode,
				OutletName,
				ContactStreet, 
				ContactSuburb, 
				ContactState, 
				ContactPostCode
			from
				penOutlet po
			where
				(po.CountryKey  + '-' + po.AlphaCOde) = q.AgencyKey and
				OutletStatus = 'Current'
		) o
        outer apply
        (
            select 
                ltrim(rtrim(FirstName)) ClientFirstName,
                case
                    when isnull(Title, '') <> '' then Title + ' '
                    else ''
                end +
                case
                    when isnull(FirstName, '') <> '' then FirstName + ' '
                    else ''
                end +
                Surname ClientContact,
                Street ClientStreet,
                upper(Suburb) ClientSuburb,
                upper(State) ClientState,
                PostCode ClientPostCode
            from
                corpContact cc
            where
                cc.QuoteKey = q.QuoteKey and
                ContactType = 'C'
        ) cc
    where
        isPolicy = 1 and
        q.CountryKey = @Country and
        PolicyExpiryDate >= @rptStartDate and
        PolicyExpiryDate <  dateadd(day, 1, @rptEndDate) and
        (
            (
                @LetterType = 'Agent Other' and
				o.AlphaCode not like 'CMN%'
            ) or
            (
                @LetterType = 'Client Other' and
                o.AlphaCode not like 'CMN%'
            ) or
            (
                @LetterType = 'Client Direct' and
                o.AlphaCode like 'CMN%'
            )
        )
        
end

GO
