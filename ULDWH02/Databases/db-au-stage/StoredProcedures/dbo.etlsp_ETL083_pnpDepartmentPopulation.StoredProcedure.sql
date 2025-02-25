USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDepartmentPopulation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL083_pnpDepartmentPopulation]
as
begin

    --20180119, LL, put in SP

    declare cf cursor local for
    select 
        FunderSK
    from
        [db-au-dtc]..pnpServiceEvent sf with(nolock)
    where
        sf.StartDatetime >= dateadd(day, -7, getdate())

    union

    select 
        FunderSK
    from
        [db-au-dtc]..pnpFunderPopulation with(nolock)
    where
        UpdatedDatetime >= dateadd(day, -7, getdate())


    declare @fundersk int

    open cf

    fetch next from cf into @fundersk
    while @@fetch_status = 0
    begin

        --begin transaction populate

        --begin try

            delete 
            from 
                [db-au-dtc]..pnpDepartmentPopulation
            where
                FunderSK = @fundersk

            ;with cte_department as
            (
                select 
                    f.FunderSK,
                    f.FunderID,
                    f.PrimaryIndustry,
                    f.Funder,
                    fd.ParentDepartmentSK,
                    fd.Department,
                    fd.FunderDepartmentSK,
                    'Overall' SubDepartment
                from
                    [db-au-dtc]..pnpFunder f with(nolock)
                    inner join [db-au-dtc]..pnpFunderDepartment fd with(nolock) on
                        fd.FunderSK = f.FunderSK
                where
                    f.FunderSK = @fundersk and
                    fd.ParentDepartmentSK is null

                union all 

                select 
                    f.FunderSK,
                    f.FunderID,
                    f.PrimaryIndustry,
                    f.Funder,
                    fd.ParentDepartmentSK,
                    r.Department,
                    fd.FunderDepartmentSK,
                    fd.Department SubDepartment
                from
                    [db-au-dtc]..pnpFunder f with(nolock)
                    inner join [db-au-dtc]..pnpFunderDepartment fd with(nolock) on
                        fd.FunderSK = f.FunderSK
                    inner join [db-au-dtc]..pnpFunderDepartment r with(nolock) on
                        r.FunderDepartmentSK = fd.ParentDepartmentSK
                where
                    f.FunderSK = @fundersk

                union all 

                select 
                    f.FunderSK,
                    f.FunderID,
                    f.PrimaryIndustry,
                    f.Funder,
                    null ParentDepartmentSK,
                    'Overall' Department,
                    -f.FunderSK FunderDepartmentSK,
                    'Overall' SubDepartment
                from
                    [db-au-dtc]..pnpFunder f with(nolock)
                where
                    f.FunderSK = @fundersk
            )
            insert into [db-au-dtc]..pnpDepartmentPopulation
            (
	            [FunderSK],
	            [FunderID],
	            [PrimaryIndustry],
	            [Funder],
	            [ParentDepartmentSK],
	            [Department],
	            [FunderDepartmentSK],
	            [SubDepartment],
	            [PopulationDate],
	            [Population]
            )
            select
	            t.[FunderSK],
	            t.[FunderID],
	            t.[PrimaryIndustry],
	            t.[Funder],
	            t.[ParentDepartmentSK],
	            t.[Department],
	            t.[FunderDepartmentSK],
	            t.[SubDepartment],
                d.[Date] PopulationDate,
                isnull
                (
                    case
                        when FunderDepartmentSK > 0 then coalesce(DepartmentPopulation, 0) 
                        else coalesce(OrganisationPopulation, 0) 
                    end,
                    0
                ) Population
            from
                cte_department t
                cross apply
                (
                    select
                        dateadd(year, -1, convert(varchar(7), min(PopulationDate), 120) + '-01') StartDate,
                        dateadd(year, 1, convert(varchar(7), getdate(), 120) + '-01') EnDate
                    from
                        [db-au-dtc]..pnpFunderPopulation
                    where
                        FunderSK = t.FunderSK
                ) pd
                inner join [db-au-cmdwh]..Calendar d on
                    datepart(day, d.[Date]) = 1 and
                    d.[Date] >= pd.StartDate and
                    d.[Date] <= pd.EnDate
                outer apply
                (
                    select top 1 
                        fp.Population DepartmentPopulation
                    from
                        [db-au-dtc]..pnpFunderPopulation fp with(nolock)
                    where
                        fp.FunderSK = t.FunderSK and
                        fp.FunderDepartmentSK = t.FunderDepartmentSK and
                        fp.PopulationStartDate <  dateadd(month, 1, d.[Date]) and
                        fp.PopulationEndDate   >= dateadd(day, -1, dateadd(month, 1, d.[Date])) and
                        fp.DeletedDatetime is null
                    order by
                        fp.PopulationStartDate desc
                ) dp
                outer apply
                (
                    select top 1 
                        fp.Population OrganisationPopulation
                    from
                        [db-au-dtc]..pnpFunderPopulation fp with(nolock)
                    where
                        fp.FunderSK = t.FunderSK and
                        fp.FunderDepartmentSK is null and
                        fp.PopulationStartDate <  dateadd(month, 1, d.[Date]) and
                        fp.PopulationEndDate   >= dateadd(day, -1, dateadd(month, 1, d.[Date])) and
                        fp.DeletedDatetime is null
                    order by
                        fp.PopulationStartDate desc
                ) op
            --where
            --    --PrimaryIndustry is not null and
            --    exists
            --    (
            --        select
            --            null
            --        from
            --            [db-au-dtc]..pnpServiceEvent se with(nolock)
            --        where
            --            se.FunderSK = t.FunderSK and
            --            se.StartDatetime >= dateadd(month, -2, d.[Date]) and
            --            se.StartDatetime <  dateadd(month, 4, d.[Date])
            --    )

        --end try

        --begin catch

        --    if @@trancount > 0
        --        rollback transaction populate

        --end catch

        --if @@trancount > 0
        --    commit transaction populate

        fetch next from cf into @fundersk

    end


    close cf
    deallocate cf

end
GO
