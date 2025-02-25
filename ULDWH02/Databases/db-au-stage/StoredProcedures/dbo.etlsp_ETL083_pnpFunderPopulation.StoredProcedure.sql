USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpFunderPopulation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpFunderPopulation
-- Changes:
--			20180719 - DM - Changed logic for populating Start and End dates. Since only doing an incremental Update needed to check and change the script to do outsite of the Merge Statement
--			20180810 - DM - Change to the Population End Date logic. Check comments for details. Now looking at Policy/Events dates
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpFunderPopulation]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    declare
    @batchid int,
    @start date,
    @end date,
    @name varchar(100),
    @sourcecount int,
    @insertcount int,
    @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-dtc].dbo.pnpFunderPopulation') is null
    begin
        create table [db-au-dtc].[dbo].[pnpFunderPopulation](
            FunderPopulationSK int identity(1,1) primary key,
            FunderSK int,
            FunderDepartmentSK int,
            FunderPopulationID varchar(50),
            [Population] int,
            PopulationDate date,
            PopulationStartDate date,
            PopulationEndDate date,
            Notes nvarchar(4000),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            DeletedDatetime datetime2,
            index idx_pnpFunderPopulation_FunderSK nonclustered (FunderSK),
            index idx_pnpFunderPopulation_FunderDepartmentSK nonclustered (FunderDepartmentSK),
            index idx_pnpFunderPopulation_FunderPopulationID nonclustered (FunderPopulationID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            f.FunderSK as FunderSK,
            fd.FunderDepartmentSK as FunderDepartmentSK,
            convert(varchar(50), fp.kfunderpopid) as FunderPopulationID,
            fp.[population] as [Population],
            fp.popdate as PopulationDate,
            cast(null as datetime) as PopulationStartDate,--case when lag(fp.popdate) over(partition by fp.kfunderid, fp.kfunderdeptid order by fp.popdate) is null then '1900-01-01' else fp.popdate end as PopulationStartDate,
            cast(null as datetime) as PopulationEndDate,--coalesce(dateadd(day, -1, lead(fp.popdate) over(partition by fp.kfunderid, fp.kfunderdeptid order by fp.popdate)), '9999-12-31') as PopulationEndDate,
            [db-au-stage].dbo.xfn_StripHTML(fp.popnotes) as Notes,
            --[db-au-stage].dbo.udf_StripHTML(fp.popnotes) as Notes,
            fp.slogin as CreatedDatetime,
            fp.slogmod as UpdatedDatetime
        into #src
        from
            penelope_frfunderpop_audtc fp
            outer apply (
                select top 1 FunderSK
                from [db-au-dtc].dbo.pnpFunder
                where FunderID = convert(varchar, fp.kfunderid)
                    and IsCurrent = 1
            ) f
            outer apply (
                select top 1 FunderDepartmentSK
                from [db-au-dtc].dbo.pnpFunderDepartment
                where FunderDepartmentID = convert(varchar, fp.kfunderdeptid)
            ) fd

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpFunderPopulation as tgt

        using #src
            on #src.FunderPopulationID = tgt.FunderPopulationID
        when matched then
            update set
                tgt.FunderSK = #src.FunderSK,
                tgt.FunderDepartmentSK = #src.FunderDepartmentSK,
                tgt.[Population] = #src.[Population],
                tgt.PopulationDate = #src.PopulationDate,
                tgt.PopulationStartDate = #src.PopulationStartDate,
                tgt.PopulationEndDate = #src.PopulationEndDate,
                tgt.Notes = #src.Notes,
                tgt.UpdatedDatetime = #src.UpdatedDatetime
        when not matched by target then
            insert (
                FunderSK,
                FunderDepartmentSK,
                FunderPopulationID,
                [Population],
                PopulationDate,
                PopulationStartDate,
                PopulationEndDate,
                Notes,
                CreatedDatetime,
                UpdatedDatetime
            )
            values (
                #src.FunderSK,
                #src.FunderDepartmentSK,
                #src.FunderPopulationID,
                #src.[Population],
                #src.PopulationDate,
                #src.PopulationStartDate,
                #src.PopulationEndDate,
                #src.Notes,
                #src.CreatedDatetime,
                #src.UpdatedDatetime
            )
        --20180812 - LL - change Deleted logic, reading the new id table
        --when not matched by source and tgt.FunderPopulationID not like 'CLI_%' then
        --    update set
        --        tgt.DeletedDatetime = current_timestamp

        output $action into @mergeoutput;

        --20180812 - LL - change Deleted logic, reading the new id table
        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            penelope_frfunderpop_audtc_id

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpFunderPopulation t
        where
            t.FunderPopulationID not like 'CLI_%' and
            t.FunderPopulationID not like 'DUMMY%' and
            t.DeletedDatetime is null

        --select @old, @new

        --if @new > @old - 200
        begin

            update t
            set
                DeletedDateTime = current_timestamp 
            from
                [db-au-dtc].dbo.pnpFunderPopulation t
            where
                t.FunderPopulationID not like 'CLI_%' and
                t.FunderPopulationID not like 'DUMMY%' and
                t.DeletedDatetime is null and
                not exists
                (
                    select
                        null
                    from
                        penelope_frfunderpop_audtc_id id
                    where
                        id.kfunderpopid = try_convert(bigint, t.FunderPopulationID)
                )

        end

        update t
        set
            DeletedDateTime = null
        from
            [db-au-dtc].dbo.pnpFunderPopulation t
        where
            t.FunderPopulationID not like 'CLI_%' and
            t.FunderPopulationID not like 'DUMMY%' and
            t.DeletedDatetime is not null and
            exists
            (
                select
                    null
                from
                    penelope_frfunderpop_audtc_id id
                where
                    id.kfunderpopid = try_convert(bigint, t.FunderPopulationID)
            )

		--20180719 - Change to the updating of Population Start and End dates
		--20180810 - Change to the Population End Date logic. Check comments for details. Now looking at Policy/Events dates
		;with latestFunderDates as (
			select p.FunderSK,
				min(Case CASE WHEN P.PolicyID like 'CLI%' THEN 'Closed' ELSE p.Status END
					WHEN 'Pending' THEN 1
					WHEN 'Closed' THEN 1
					WHEN 'Inactive' THEN 1
					WHEN 'Active' THEN 0
				end) as Status,
				EOMONTH(max(X.StartDatetime),0) as lastEventDate,
				max(isNull(pc.enddate, p.PublicPolicyEnd)) as PolicyEndDate
			--select *
			from [db-au-dtc].dbo.pnpPolicyCoverage pc with(nolock)
			join [db-au-dtc].dbo.pnpPolicy p with(nolock) on pc.PolicySK = p.PolicySK	
			outer apply(
					select se.StartDateTime
					from [db-au-dtc].dbo.pnpInvoiceLine il with(nolock)
					join [db-au-dtc].dbo.pnpServiceEventActivity sea with(nolock) on il.ServiceEventActivitySK = sea.ServiceEventActivitySK
					join [db-au-dtc].dbo.pnpServiceEvent se with(nolock) on sea.ServiceEventSK = se.ServiceEventSK
					join [db-au-dtc].dbo.pnpServiceFile sf with(nolock) on se.ServiceFileSK = sf.ServiceFileSK
					--and p.Status = 'Active'
					where SE.Status NOT IN ('Booked','Cancelled')
					and sf.Service in ('employeeAssist','managerAssist','Nutrition@DTC','legalAssist')
					and il.PolicyCoverageSK = pc.PolicyCoverageSK
				) X
			where p.Class = 'Group'
			--and p.fundersk = 7324
			GROUP BY p.FunderSK
		)
		,
		funderpop as (
			select FunderPopulationSK,
				PopulationStartDate = fp.PopulationDate,
				PopulationEndDate = 
				coalesce(
					--Day before Next population Date
					dateadd(day, -1, lead(fp.PopulationDate,1,null) over(partition by fp.fundersk, fp.FunderDepartmentSK order by fp.PopulationDate)), 
					--If an Active Policy can be found, 3 months from now
					case when fd.status = 0 then eomonth(getdate(), 3) ELSE 
						--if no active policy check the latest Policy End date, if <= 5 years then use this date
						CASE WHEN DateDiff(year, fd.PolicyEndDate, fp.PopulationDate) <= 5 THEN fd.PolicyEndDate END END,
					--if no policy end date then use the Last Event date month
					eomonth(lastEventDate),
					--if no events then contact open for a minimum of a year, use this date.
					DateAdd(day, -1, DateAdd(year,1,fp.PopulationDate))
					)
			from [db-au-dtc].dbo.pnpFunderPopulation fp
			left join latestFunderDates fd on fp.FunderSK = fd.FunderSK
			where DeletedDatetime is null 
		)
		--select * from funderpop order by fundersk, FunderDepartmentSK, PopulationDate
		--select *
		UPDATE FP
			SET PopulationStartDate = X.PopulationStartDate,
				PopulationEndDate = X.PopulationEndDate
		from [db-au-dtc].dbo.pnpFunderPopulation fp
		JOIN funderpop X ON fp.FunderPopulationSK = X.FunderPopulationSK

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

END




GO
