USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpFunderDepartment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpFunderDepartment
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpFunderDepartment] 
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

	if object_id('[db-au-dtc].dbo.pnpFunderDepartment') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpFunderDepartment](
			FunderDepartmentSK int identity(1,1) primary key,
			ParentDepartmentSK int,
			FunderSK int,
			FunderDepartmentID varchar(50),
			ParentDepartmentID varchar(50),
			Department nvarchar(4000),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			[Description] nvarchar(4000),
			CreateBookItemID int,
			UpdateBookItemID int,
			[Population] int,
			PopulationDate date,
			[State] nvarchar(25),
			DepartmentLevel int,
			index idx_pnpFunderDepartment_ParentDepartmentSK nonclustered (ParentDepartmentSK),
			index idx_pnpFunderDepartment_FunderSK nonclustered (FunderSK),
			index idx_pnpFunderDepartment_FunderDepartmentID nonclustered (FunderDepartmentID),
			index idx_pnpFunderDepartment_ParentDepartmentID nonclustered (ParentDepartmentID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src
			
		select 
			f.FunderSK as FunderSK,
			convert(varchar, fd.kfunderdeptid) as FunderDepartmentID,
			convert(varchar, fd.parentdeptid) as ParentDepartmentID,
			fd.department as Department,
			fd.slogin as CreatedDatetime,
			fd.slogmod as UpdatedDatetime,
			fd.departmentdesc as [Description],
			fd.sloginby as CreateBookItemID,
			fd.slogmodby as UpdateBookItemID,
			fd.departmentpop as [Population],
			fd.departmentpopdate as PopulationDate,
			s.[state] as [State]
		into #src
		from 
			penelope_frfunderdept_audtc fd 
			left join penelope_lustatedept_audtc s on s.lustatedeptid = fd.lustatedeptid
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc].[dbo].[pnpFunder]
				where FunderId = convert(varchar,fd.kfunderid) 
					and IsCurrent = 1
			) f

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpFunderDepartment as tgt
		using #src
			on #src.FunderDepartmentID = tgt.FunderDepartmentID
		when matched then 
			update set 
				tgt.FunderSK = #src.FunderSK,
				tgt.ParentDepartmentID = #src.ParentDepartmentID,
				tgt.Department = #src.Department,
				tgt.CreatedDatetime = #src.CreatedDatetime,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.[Description] = #src.[Description],
				tgt.CreateBookItemID = #src.CreateBookItemID,
				tgt.UpdateBookItemID = #src.UpdateBookItemID,
				tgt.[Population] = #src.[Population],
				tgt.PopulationDate = #src.PopulationDate,
				tgt.[State] = #src.[State]
		when not matched by target then 
			insert (
				FunderSK,
				FunderDepartmentID,
				ParentDepartmentID,
				Department,
				CreatedDatetime,
				UpdatedDatetime,
				[Description],
				CreateBookItemID,
				UpdateBookItemID,
				[Population],
				PopulationDate,
				[State]
			)
			values (
				#src.FunderSK,
				#src.FunderDepartmentID,
				#src.ParentDepartmentID,
				#src.Department,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.[Description],
				#src.CreateBookItemID,
				#src.UpdateBookItemID,
				#src.[Population],
				#src.PopulationDate,
				#src.[State]
			)
			
		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		-- Lookup ParentDepartmentSK
		update fd
		set ParentDepartmentSK = pd.ParentDepartmentSK
		from [db-au-dtc].dbo.pnpFunderDepartment fd 
			outer apply (
				select top 1 FunderDepartmentSK as ParentDepartmentSK
				from [db-au-dtc].dbo.pnpFunderDepartment
				where FunderDepartmentID = fd.ParentDepartmentID
			) pd
		where ParentDepartmentID is not null

		-- Update department hierachy level
		;with cte as (
			select 
				a.FunderDepartmentSK,
				a.FunderDepartmentID,
				1 AS DepartmentLevel
			from [db-au-dtc]..pnpFunderDepartment as a
			where a.ParentDepartmentSK is null
			union all
			select 
				d.FunderDepartmentSK,
				d.FunderDepartmentID,
				c.DepartmentLevel + 1 as DepartmentLevel
			from [db-au-dtc]..pnpFunderDepartment d
				inner join cte c on c.FunderDepartmentID = d.ParentDepartmentID
			where 
				d.ParentDepartmentID is not null
		)
		update fd 
		set DepartmentLevel = cte.DepartmentLevel
		from 
			[db-au-dtc]..pnpFunderDepartment fd
			inner join cte on cte.FunderDepartmentSK = fd.FunderDepartmentSK


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
