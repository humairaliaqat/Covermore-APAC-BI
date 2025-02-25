USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimOutlet_integrated]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL032_dimOutlet_integrated]
as
begin

    if object_id('[db-au-star]..dimIntegratdOutlet') is null
    begin

        create table [db-au-star]..dimIntegratdOutlet
        (
            BIRowID bigint not null identity(1,1),
            OutletSK bigint
        )

        create unique clustered index cidx on [db-au-star]..dimIntegratdOutlet (BIRowID)
        create index idx on [db-au-star]..dimIntegratdOutlet (OutletSK)

    end

    truncate table [db-au-star]..dimIntegratdOutlet

    ;with 
    cte_quotebyage as
    (
        select --top 1000
            lo.OutletAlphaKey,
            AgeBandSK,
            sum(QuoteSessionCount) SessionCount
        from
            [db-au-star]..factQuoteSummary q
            inner join [db-au-star]..dimOutlet do on
                do.OutletSK = q.OutletSK
            inner join [db-au-cmdwh]..penOutlet ro on
                ro.OutletAlphaKey = do.OutletAlphaKey and
                ro.OutletStatus = 'Current'
            inner join [db-au-cmdwh]..penOutlet lo on
                lo.OutletKey = ro.LatestOutletKey and
                lo.OutletStatus = 'Current'
            inner join [db-au-star]..dimConsultant c on
                c.ConsultantSK = q.ConsultantSK
        where
            c.ConsultantName like '%web%user%'
        group by
            lo.OutletAlphaKey,
            AgeBandSK
    ),
    cte_agepct as
    (
        select --top 1000 
            OutletAlphaKey,
            AgeBandSK,
            SessionCount,
            case
                when sum(SessionCount) over (partition by OutletAlphaKey) = 0 then 0
                else SessionCount * 1.0 / sum(SessionCount) over (partition by OutletAlphaKey)
            end AgePct
        from
            cte_quotebyage
    ),
    cte_integrated as
    (
        select 
            OutletAlphaKey
        from
            cte_agepct q
        where
            AgePct > 0.70 and --if 70% of quotes are under a particular age, there's a big chance this is integrated
            SessionCount > 1000
    )
    insert into [db-au-star]..dimIntegratdOutlet (OutletSK)
    select 
        do.OutletSK
    from
        cte_integrated ci
        inner join [db-au-star]..dimOutlet do on
            do.OutletAlphaKey = ci.OutletAlphaKey

end
GO
