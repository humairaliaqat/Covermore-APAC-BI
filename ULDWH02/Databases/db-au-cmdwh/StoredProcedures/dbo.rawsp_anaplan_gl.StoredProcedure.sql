USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_anaplan_gl]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_anaplan_gl]
    @DateRange varchar(30) = 'Current',
    @StartDate date = null,
    @EndDate date = null,
    @ParentGroup varchar(5) = 'CMG'

as
begin

    set nocount on


--	20180606 - LT - Fixed no header row issue when bcp data out.
--  20180628 - LL - separate ARG files
--  20180911 - LL - LAT


	--uncomment to debug
/*
    declare @DateRange varchar(30),  @StartDate date, @EndDate date
	select @DateRange = 'History', @StartDate = null, @EndDate = null
*/

    declare
        @start int,
        @end int

    if @DateRange = '_User Defined' 
        select 
            @start = min(SUNPeriod),
            @end = max(SUNPeriod)
        from
            [db-au-cmdwh]..Calendar
        where
            [Date] >= @StartDate and
            [Date] <  dateadd(day, 1, @EndDate)

    --20180605, LL, change from 2 FY to 3 CY
    else if @DateRange = 'History' --3 CY
    begin

        select 
            @start = max(SUNPeriod)
        from
            [db-au-cmdwh]..Calendar
        where
            [Date] = convert(date, convert(varchar, year(dateadd(month, -1, getdate())) - 3) + '-01-01')

        select 
            @end = max(SUNPeriod)
        from
            [db-au-cmdwh]..Calendar
        where
            [Date] = convert(date, dateadd(month, -1, getdate()))

    end


    else if @DateRange = 'Current' --2 months
        select 
            @start = min(SUNPeriod),
            @end = max(SUNPeriod)
        from
            [db-au-cmdwh]..Calendar
        where
            [Date] >= convert(date, dateadd(month, -1, getdate())) and
            [Date] <= convert(date, getdate())
    

	if object_id('tempdb..#gl') is not null 
        drop table #gl

    select --top 1000 
        case 
            when BusinessUnit = 'CMG' and sbu.BusinessUnitCode in ('CMG', 'HHC', 'USC', 'M05') then 'CMGG' 
            when BusinessUnit = 'ARG' and sbu.BusinessUnitCode in ('ARG') then 'ARGG' 
            when BusinessUnit = 'LAT' then sbu.BusinessUnitCode 
            else BusinessUnit 
        end [Business_Unit_Code],
        coalesce(jv.JVCode, cl.ClientCode, 'UN') [JV_Client_Code],
        isnull(ch.ChannelCode, 'UN') [Channel_Code],
        isnull(dp.DepartmentCode, 'UN') [Department_Code],
        isnull(pr.ProductCode, 'UN') [Product_Code],
        isnull(st.StateCode, 'UN') [State_Code],
        isnull(a.AccountCode, 'UN') [Account_Code],
        ScenarioCode [Scenario],
        case
            when JournalType in ('ZENMC') then 'JNL'
            when JournalType like 'Z%' and TransactionReference in ('DEPT2', 'DEPT3') then 'JNL'
            when JournalType like 'Z%' then 'ALO'
            else 'JNL'
        end [Journal_Type],
        isnull(sbu.BusinessUnitCode, 'UN') [Source_Business_Unit_Code],
        Period,
        left(datename(mm, d.[Date]), 3) + ' ' + datename(yyyy, d.[Date]) [Month],
        case
            when BusinessUnit = 'LAT' then OtherAmount
            else GLAmount 
        end [GL_Amount]
	into #gl
    from
        glTransactions gl with(nolock)
        cross apply
        (
            select top 1 
                d.[Date]
            from
                Calendar d with(nolock)
            where
                d.SUNPeriod = gl.Period
        ) d
        outer apply
        (
            select top 1 
                jv.JVCode
            from
                glJointVentures jv with(nolock)
            where
                jv.JVCode = gl.JointVentureCode
        ) jv
        outer apply
        (
            select top 1 
                cl.ClientCode
            from
                glClients cl with(nolock)
            where
                cl.ClientCode = gl.ClientCode
        ) cl
        outer apply
        (
            select top 1 
                ch.ChannelCode
            from
                glChannels ch with(nolock)
            where
                ch.ChannelCode = gl.ChannelCode
        ) ch
        outer apply
        (
            select top 1 
                dp.DepartmentCode
            from
                glDepartments dp with(nolock)
            where
                dp.DepartmentCode = gl.DepartmentCode
        ) dp
        outer apply
        (
            select top 1 
                pr.ProductCode
            from
                glProducts pr with(nolock)
            where
                pr.ProductCode = gl.ProductCode
        ) pr
        outer apply
        (
            select top 1 
                st.StateCode
            from
                glStates st with(nolock)
            where
                st.StateCode = gl.StateCode
        ) st
        outer apply
        (
            select top 1 
                a.AccountCode
            from
                glAccounts a with(nolock)
            where
                a.AccountCode = gl.AccountCode
        ) a
        outer apply
        (
            select top 1 
                sbu.BusinessUnitCode
            from
                glBusinessUnits sbu with(nolock)
            where
                sbu.BusinessUnitCode = gl.SourceCode
        ) sbu
    where
        ScenarioCode in ('A', 'C', 'F') and
        (
            (
                @ParentGroup = 'CMG' and
                (
			        BusinessUnit in
			        (
				        select 
					        BusinessUnitCode
				        from
					        glBusinessUnits with(nolock)
				        where
					        ParentBusinessUnitCode not in ('XIN', 'IND', 'ARG')
			        ) or
                    (
			            BusinessUnit = 'CMG' and 
                        sbu.BusinessUnitCode in ('CMG', 'HHC', 'USC', 'M05')
                    )
		        ) 
            ) 
            or
            (
                @ParentGroup = 'ARG' and
                
                BusinessUnit = 'ARG'
          --      (
			       -- BusinessUnit in
			       -- (
				      --  select 
					     --   BusinessUnitCode
				      --  from
					     --   glBusinessUnits with(nolock)
				      --  where
					     --   ParentBusinessUnitCode in ('ARG')
			       -- ) or
          --          (
			       --     BusinessUnit = 'ARG' and 
          --              sbu.BusinessUnitCode in ('ARG')
          --          )
		        --) 
            )
            or
            (
                @ParentGroup = 'LAT' and
                BusinessUnit = 'LAT'
            )
        ) and
        Period between @start and @end

	if object_id('tempdb..#glout') is not null 
        drop table #glout

    select 
        [Unique Key],
        [Business_Unit_Code],
        [JV_Client_Code],
        [Channel_Code],
        [Department_Code],
        [Product_Code],
        [State_Code],
        [Account_Code],
        [Scenario],
        [Journal_Type],
        [Source_Business_Unit_Code],
        [Period],
        [Month],
        sum([GL_Amount]) [GL_Amount]
	into #glout
    from
        #gl t
        cross apply
        (
            select
                rtrim([Business_Unit_Code]) + '-' +
                rtrim([JV_Client_Code]) + '-' +
                rtrim([Channel_Code]) + '-' +
                rtrim([Department_Code]) + '-' +
                rtrim([Product_Code]) + '-' +
                rtrim([State_Code]) + '-' +
                rtrim([Account_Code]) + '-' +
                rtrim([Scenario]) + '-' +
                rtrim([Journal_Type]) + '-' +
                rtrim([Source_Business_Unit_Code]) + '-' +
                convert(varchar(7), [Period]) [Unique Key]
        ) qid
    group by
        [Unique Key],
        [Business_Unit_Code],
        [JV_Client_Code],
        [Channel_Code],
        [Department_Code],
        [Product_Code],
        [State_Code],
        [Account_Code],
        [Scenario],
        [Journal_Type],
        [Source_Business_Unit_Code],
        [Period],
        [Month]


	if object_id('[db-au-workspace].dbo.fpa_gl_out') is not null 
        drop table [db-au-workspace].dbo.fpa_gl_out

	create table [db-au-workspace].dbo.fpa_gl_out
	(
		BIRowID bigint not null identity(1,1),
		[Unique Key] varchar(500) null,
		Business_Unit_Code varchar(50) null,
		JV_Client_Code varchar(50) null,
		Channel_Code varchar(50) null,
		Department_Code varchar(50) null,
		Product_Code varchar(50) null,
		State_Code varchar(50) null,
		Account_Code varchar(50) null,
		Scenario varchar(50) null,
		Journal_Type varchar(20) null,
		Source_Business_Unit_Code varchar(50) null,
		[Period] varchar(20) null,
		[Month] varchar(50) null,
		GL_Amount varchar(50) null
	)

	--insert header row
	insert [db-au-workspace].dbo.fpa_gl_out 
	(
		[Unique Key],
		Business_Unit_Code,
		JV_Client_Code,
		Channel_Code,
		Department_Code,
		Product_Code,
		State_Code,
		Account_Code,
		Scenario,
		Journal_Type,
		Source_Business_Unit_Code,
		[Period],
		[Month],
		GL_Amount
	)
	values
    (
        'Unique Key',
        'Business_Unit_Code',
        'JV_Client_Code',
        'Channel_Code' ,
        'Department_Code',
        'Product_Code',
        'State_Code',
        'Account_Code',
        'Scenario',
        'Journal_Type',
        'Source_Business_Unit_Code',
        'Period',
        'Month',
        'GL_Amount'
	)

	--insert data
	insert [db-au-workspace].dbo.fpa_gl_out
	(
		[Unique Key],
		Business_Unit_Code,
		JV_Client_Code,
		Channel_Code,
		Department_Code,
		Product_Code,
		State_Code,
		Account_Code,
		Scenario,
		Journal_Type,
		Source_Business_Unit_Code,
		[Period],
		[Month],
		GL_Amount
	)
    select
        [Unique Key],
        [Business_Unit_Code],
        [JV_Client_Code],
        [Channel_Code],
        [Department_Code],
        [Product_Code],
        [State_Code],
        [Account_Code],
        [Scenario],
        [Journal_Type],
        [Source_Business_Unit_Code],
        convert(varchar(10), Period),
        [Month],
        convert(varchar(50), isnull([GL_Amount], 0))
    from
        #glout



    if @ParentGroup = 'CMG'
    begin

        if @DateRange = 'Current' 
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL Current.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL Current.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL Current.txt"'

        end
       
        else
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL History.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL History.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\GL History.txt"'

        end

    end

    else if @ParentGroup = 'ARG'
    begin

        if @DateRange = 'Current' 
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL Current.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL Current.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL Current.txt"'

        end
       
        else
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL History.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL History.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\ARG GL History.txt"'

        end

    end

    else if @ParentGroup = 'LAT'
    begin

        if @DateRange = 'Current' 
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL Current.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL Current.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL Current.txt"'

        end
       
        else
        begin

            exec xp_cmdshell 'bcp "select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.fpa_gl_out order by BIRowID" queryout "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL History.txt" -S localhost -T -w'
            exec xp_cmdshell 'E:\ETL\Tool\7z.exe a -sdel -y "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL History.zip" "\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\LAT GL History.txt"'

        end

    end


end
GO
