USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ETL050_FCTicket_PenguinSummary]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_ETL050_FCTicket_PenguinSummary]
as
begin

    declare
        @outletid int,
        @month date,
        @ticketcount int

    declare c_ticket cursor local for
        select 
            o.OutletID,
            convert(date, convert(varchar(8), t.IssueDate, 120) + '01') [Month],
            count(t.DocumentNumber) TicketCount
        from 
            [db-au-cmdwh].dbo.fltTickets t
            inner join [db-au-cmdwh].dbo.penOutlet o on
                o.OutletKey = t.OutletKey and
                o.OutletStatus = 'Current'
        where 
	        t.TicketType = 'Issued' and
	        t.RefundedDate is null and
	        t.TravelType in ('International', 'TransTasman') and
	        (
		        (
                    t.Domain = 'NZ' and 
                    t.DocumentType <> 'EMD'
                ) or
		        t.DocumentType not in ('EMD','VMPD')
	        ) and
            t.OriginAirportCountryName = 
            case
                when o.CountryKey = 'AU' then 'Australia' 
                when o.CountryKey = 'NZ' then 'New Zealand' 
            end and
            o.SuperGroupName = 'Flight Centre' and
            o.CountryKey in ('AU', 'NZ') and
            t.IssueDate >= convert(date, convert(varchar(8), dateadd(month, -14, getdate()), 120) + '01')
        group by
            o.OutletID,
            convert(date, convert(varchar(8), t.IssueDate, 120) + '01')

    open c_ticket

    fetch next from c_ticket into @outletid, @month, @ticketcount

    while @@fetch_status = 0
    begin

        exec [DB-AU-PENGUINSHARP].[AU_PenguinSharp_Active].dbo.[wsUpdateOutletTicket]
            @OutletId = @outletid,
	        @Date = @month,
	        @TicketCount = @ticketcount

        fetch next from c_ticket into @outletid, @month, @ticketcount

    end

    close c_ticket
    deallocate c_ticket

end
GO
