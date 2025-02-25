USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_anaplan_gl_new]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rawsp_anaplan_gl_new]	@ParentGroup varchar(5) = 'CMG',
												@DateRange varchar(30) = 'Current',											
												@StartDate date = null,
												@EndDate date = null

as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           dbo.rawsp_anaplan_gl_new
--  Author:         Leonardus Li / Linus Tor
--  Date Created:   20181019
--  Description:    This stored procedure outputs the following data files for anaplan in zip format:
--					[ParentGroup]_GL_[DateRange].zip
--					If @DateRange = History:
--						[ParentGroup_Account.zip
--						[ParentGroup_Product.zip
--						[ParentGroup_BUJVMap.zip
--						[ParentGroup_BUDepMap.zip
--						[ParentGroup_BUDepJVMap.zip
--					
--  Parameters:     @ParentGroup: Required. CMG, ARG, LAT
--					@DateRange: Required. Current or History
--                  @StartDate: Optional. Default null
--					@EndDate: Optional. Default null
--
--  Change History: 20181019 - LT - Created. Based on dbo.rawsp_anaplan_gl stored proc by Leo.
--					20190117 - LT - When running for LAT parent group, changed [Unique Key] structure to:
--									Source_Business_Unit_Code + JV_Client_Code + Department_Code + Product_Code + State_Code + Account_Code + Scenario + Journal_Type + Period
--					20190205 - LT - Included BusinessUnit = CMG and SourceBusinessUnit = BIC for CMGG-xx-xx-xx..
--					20190311 - LT - Amended JournalType defintion to include ZENTB, ZENTC, ZENTD.
--					20190430 - LT - Reverted JournalType definition back to original
--					20190517 - LT - Changed output path to \\bhanaplan01\anaplan data
--					20190517 - LT - Changed output path to \\bhanaplan01\anaplan data
--					20201812 - HL - INC0184297 - Added Project_Code column to the GL files output
--									Changed [Unique Key] structure for CMG and LAT to:
--									Source_Business_Unit_Code + JV_Client_Code + Department_Code + Product_Code + State_Code + Project_Code + Account_Code + Scenario + Journal_Type + Period
--					20211202 - HL - INC0189611 - Added WTC BU to the GL files output
--                  20232011 - HL - INC0303876 - Added JournalType ('ZENTC','ZENTD') to be included in 'JNL'.
--					20240305 -SB - INC0314014 -  Anaplan source data file issue - LAT
/****************************************************************************************************/

--uncomment to debug
/*
declare @ParentGroup varchar(5)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select @ParentGroup = 'CMG', @DateRange = 'History', @StartDate = null, @EndDate = null
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

select 
    case 
        when BusinessUnit = 'CMG' and sbu.BusinessUnitCode in ('CMG', 'HHC', 'USC', 'M05','BIC') then 'CMGG' 
        when BusinessUnit = 'ARG' and sbu.BusinessUnitCode in ('ARG') then 'ARGG' 
		when BusinessUnit = 'WTC' and sbu.BusinessUnitCode in ('WTC') then 'WTC'  -- Added WTC BU 
        when BusinessUnit = 'LAT' then sbu.BusinessUnitCode 
        else BusinessUnit 
    end [Business_Unit_Code],
    coalesce(jv.JVCode, cl.ClientCode, 'UN') [JV_Client_Code],
    isnull(ch.ChannelCode, 'UN') [Channel_Code],
    isnull(dp.DepartmentCode, 'UN') [Department_Code],
    isnull(pr.ProductCode, 'UN') [Product_Code],
    isnull(st.StateCode, 'UN') [State_Code],
	isnull(pj.ProjectCode, 'UN') [Project_Code],
    isnull(a.AccountCode, 'UN') [Account_Code],
    ScenarioCode [Scenario],
	case
		when JournalType in ('ZENMC','ZENTB','ZENTC','ZENTD') then 'JNL'
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
            pj.ProjectCode
        from
            [db-au-cmdwh]..[glProjects] pj with(nolock)
        where
            pj.ProjectCode = gl.ProjectCode
    ) pj
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
                    sbu.BusinessUnitCode in ('CMG', 'HHC', 'USC', 'M05','BIC')
                )
		    ) 
        ) 
        or
        (
            @ParentGroup = 'ARG' and                
            BusinessUnit = 'ARG'
        )
        or														-- Added for WTC BU change
		(
            @ParentGroup = 'WTC' and                
            BusinessUnit = 'WTC'
        )
        or														
        (
            @ParentGroup = 'LAT' and
            BusinessUnit = 'LAT'
			
			--temporary filter: include only PAT accounts for LAT
			and	a.AccountCode in 
				(
					select distinct Descendant_Code
					from [db-au-star].dbo.vAccountAncestors
					where Account_Code in ('PAT','MEMO')
				)
        )
    ) and
    [Period] between @start and @end


if object_id('[db-au-workspace].dbo.tmp_glout') is not null 
    drop table [db-au-workspace].dbo.tmp_glout

select 
    [Unique Key],
    [Business_Unit_Code],
    [JV_Client_Code],
    [Channel_Code],
    [Department_Code],
    [Product_Code],
    [State_Code],
	[Project_Code],
    [Account_Code],
    [Scenario],
    [Journal_Type],
    [Source_Business_Unit_Code],
    [Period],
    [Month],
    sum([GL_Amount]) [GL_Amount],
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[JV_Client_Code]) [BU_JV],
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) [BU_Dept],
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) + '_' + convert(varchar,[JV_Client_Code]) [BU_Dept_JV]
into [db-au-workspace].dbo.tmp_glout
from
    #gl t
    cross apply
    (
        select
			case when @ParentGroup <> 'LAT' then
						rtrim([Business_Unit_Code]) + '-' +
						rtrim([JV_Client_Code]) + '-' +
						rtrim([Channel_Code]) + '-' +
						rtrim([Department_Code]) + '-' +
						rtrim([Product_Code]) + '-' +
						rtrim([State_Code]) + '-' +
						rtrim([Project_Code]) + '-' +
						rtrim([Account_Code]) + '-' +
						rtrim([Scenario]) + '-' +
						rtrim([Journal_Type]) + '-' +
						rtrim([Source_Business_Unit_Code]) + '-' +
						convert(varchar(7), [Period])
				else	--LATAM Unique Key structure
						rtrim([Source_Business_Unit_Code]) + '-' +
						rtrim([JV_Client_Code]) + '-' +
						rtrim([Channel_Code]) + '-' +
						rtrim([Department_Code]) + '-' +
						rtrim([Product_Code]) + '-' +
						rtrim([State_Code]) + '-' +
						rtrim([Project_Code]) + '-' +
						rtrim([Account_Code]) + '-' +
						rtrim([Scenario]) + '-' +
						rtrim([Journal_Type]) + '-' +						
						convert(varchar(7), [Period])						
			end	 [Unique Key]
    ) qid
group by
    [Unique Key],
    [Business_Unit_Code],
    [JV_Client_Code],
    [Channel_Code],
    [Department_Code],
    [Product_Code],
    [State_Code],
	[Project_Code],
    [Account_Code],
    [Scenario],
    [Journal_Type],
    [Source_Business_Unit_Code],
    [Period],
    [Month],
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[JV_Client_Code]),
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]),
	convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) + '_' + convert(varchar,[JV_Client_Code])


if object_id('[db-au-workspace].dbo.tmp_glout_export') is not null 
    drop table [db-au-workspace].dbo.tmp_glout_export

create table [db-au-workspace].dbo.tmp_glout_export
(
	BIRowID bigint not null identity(1,1),
	[Unique Key] varchar(500) null,
	Business_Unit_Code varchar(50) null,
	JV_Client_Code varchar(50) null,
	Channel_Code varchar(50) null,
	Department_Code varchar(50) null,
	Product_Code varchar(50) null,
	State_Code varchar(50) null,
	Project_Code varchar(50) null,
	Account_Code varchar(50) null,
	Scenario varchar(50) null,
	Journal_Type varchar(20) null,
	Source_Business_Unit_Code varchar(50) null,
	[Period] varchar(20) null,
	[Month] varchar(50) null,
	GL_Amount varchar(50) null,
	BU_JV varchar(50) null,
	BU_Dept varchar(50) null,
	BU_Dept_JV varchar(50) null	
)

--insert header row
insert [db-au-workspace].dbo.tmp_glout_export
(
	[Unique Key],
	Business_Unit_Code,
	JV_Client_Code,
	Channel_Code,
	Department_Code,
	Product_Code,
	State_Code,
	Project_Code,
	Account_Code,
	Scenario,
	Journal_Type,
	Source_Business_Unit_Code,
	[Period],
	[Month],
	GL_Amount,
	BU_JV,
	BU_Dept,
	BU_Dept_JV
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
	'Project_Code',
    'Account_Code',
    'Scenario',
    'Journal_Type',
    'Source_Business_Unit_Code',
    'Period',
    'Month',
    'GL_Amount',
	'BU_JV',
	'BU_Dept',
	'BU_Dept_JV'
)

--insert data
insert [db-au-workspace].dbo.tmp_glout_export
(
	[Unique Key],
	Business_Unit_Code,
	JV_Client_Code,
	Channel_Code,
	Department_Code,
	Product_Code,
	State_Code,
	Project_Code,
	Account_Code,
	Scenario,
	Journal_Type,
	Source_Business_Unit_Code,
	[Period],
	[Month],
	GL_Amount,
	BU_JV,
	BU_Dept,
	BU_Dept_JV
)
select
    [Unique Key],
    [Business_Unit_Code],
    [JV_Client_Code],
    [Channel_Code],
    [Department_Code],
    [Product_Code],
    [State_Code],
	[Project_Code],
    [Account_Code],
    [Scenario],
    [Journal_Type],
    [Source_Business_Unit_Code],
    convert(varchar(10), Period),
    [Month],
    convert(varchar(50), isnull([GL_Amount], 0)),
	BU_JV,
	BU_Dept,
	BU_Dept_JV
from
    [db-au-workspace].dbo.tmp_glout

/**************************************************************/
--Export Data and Compress Files
/**************************************************************/

declare @QueryGL varchar(8000)
declare @QueryAccount varchar(8000)
declare @QueryProduct varchar(8000)
declare @QueryBUJVMap varchar(8000)
declare @QueryBUDepMap varchar(8000)
declare @QueryBUDepJVMap varchar(8000)

declare @SQL varchar(8000)
declare @Path varchar(1000)
declare @ZipCommand varchar(500)
declare @FileNameGL varchar(200)
declare @FileNameAccount varchar(200)
declare @FileNameProduct varchar(200)
declare @FileNameBuJVMap varchar(200)
declare @FileNameBuDepMap varchar(200)
declare @FileNameBuDepJVMap varchar(200)

declare @ExtZip varchar(4)
declare @ExtTxt varchar(4)

select @ExtTxt = '.txt'
select @ExtZip = '.zip'
select @QueryGL = 'select [Unique Key],Business_Unit_Code,JV_Client_Code,Channel_Code,Department_Code,Product_Code,State_Code,Project_Code,Account_Code,Scenario,Journal_Type,Source_Business_Unit_Code,[Period],[Month],GL_Amount from [db-au-workspace].dbo.tmp_glout_export order by BIRowID'
select @QueryAccount = 'select Account_ID, Account_Description from [db-au-workspace].dbo.fpa_gl_anaplan_account order by BIRowID'
select @QueryProduct = 'select Product_ID, Product_Description from [db-au-workspace].dbo.fpa_gl_anaplan_product order by BIRowID'
select @QueryBUJVMap = 'select BU_JV_Map, BU_JV_Display from [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap order by BIRowID'
select @QueryBUDepMap = 'select BU_Dept_Map, BU_Dept_Display from [db-au-workspace].dbo.fpa_gl_anaplan_budepmap order by BIRowID'
select @QueryBUDepJVMap = 'select BU_Dept_JV_Map, BU_Dept_JV_Display from [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap order by BIRowID'

--select @Path = '\\aust.covermore.com.au\data\NorthSydney_data\North Sydney Common Share\Finance Reports\Anaplan Data\'
select @Path = '\\bhanaplan01\Anaplan Data\'
select @FilenameGL = @ParentGroup + '_GL_' + @DateRange
select @FilenameAccount = @ParentGroup + '_Account'
select @FileNameProduct = @ParentGroup + '_Product'
select @FileNameBuJVMap = @ParentGroup + '_BUJVMap'
select @FileNameBuDepMap = @ParentGroup + '_BUDepMap'
select @FileNameBuDepJVMap = @ParentGroup + '_BUDepJVMap'
select @ZipCommand = 'E:\ETL\Tool\7z.exe a -sdel -y '


--build SQL statement and export GL file
select @SQL = 'bcp "' + @QueryGL + '" queryout "' + @Path + @FileNameGL + @ExtTxt + '"' + ' -S localhost -T -w'
exec xp_cmdshell @SQL

--build SQL statement and zip file
select @SQL = @ZipCommand + '"' + @Path + @FileNameGL + @ExtZip + '"' + ' "' + @Path + @FileNameGL + @ExtTxt + '"'
exec xp_cmdshell @SQL	


if @DateRange = 'History'
begin

	--Account
	if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_account') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_account

	create table [db-au-workspace].dbo.fpa_gl_anaplan_account
	(
		BIRowID bigint identity(1,1) not null,
		Account_ID varchar(50) not null,
		Account_Description nvarchar(255) null
	)

	insert [db-au-workspace].dbo.fpa_gl_anaplan_account(Account_ID,Account_Description) values('Account_ID','Account_Description')

	insert [db-au-workspace].dbo.fpa_gl_anaplan_account
	select distinct
		a.Account_Code as Account_ID,
		b.Account_Description as Account_Description
	from
		[db-au-workspace].dbo.tmp_glout a
		cross apply
		(
			select top 1 AccountDescription as Account_Description
			from [db-au-cmdwh].dbo.glAccounts 
			where AccountCode = a.Account_Code
		) b
	order by 1,2


	--product
	if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_product') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_product

	create table [db-au-workspace].dbo.fpa_gl_anaplan_product
	(
		BIRowID bigint identity(1,1) not null,
		Product_ID varchar(50) not null,
		Product_Description nvarchar(255) null
	)

	insert [db-au-workspace].dbo.fpa_gl_anaplan_product(Product_ID,Product_Description) values('Product_ID','Product_Description')
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_product
	select distinct
		a.Product_Code as Product_ID,
		b.Product_Description as Product_Description
	from
		[db-au-workspace].dbo.tmp_glout a
		cross apply
		(	select top 1 ProductDescription as Product_Description
			from [db-au-cmdwh].dbo.glProducts
			where ProductCode = a.Product_Code
		) b
	order by 1,2


	--business unit joint venture
	if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_bujvmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap
	
	create table [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap
	(
		BIRowID bigint identity(1,1) not null,
		BU_JV_Map varchar(50) not null,
		BU_JV_Display nvarchar(255) null
	)
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap(BU_JV_Map,BU_JV_Display) values('BU_JV_Map','BU_JV_Display')
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap
	select distinct
		convert(varchar,a.Business_Unit_Code) + '_' + convert(varchar,a.JV_Client_Code) as BU_JV_Map,
		b.BusinessUnit_Description + '_' + c.JV_Description as BU_JV_Display
	from
		[db-au-workspace].dbo.tmp_glout a
		cross apply
		(
			select top 1 BusinessUnitDescription as BusinessUnit_Description
			from [db-au-cmdwh].dbo.glBusinessUnits
			where BusinessUnitCode = a.Business_Unit_Code
		) b
		cross apply
		(
			select top 1 JVDescription as JV_Description
			from [db-au-cmdwh].dbo.glJointVentures
			where
				JVCode = JV_Client_Code
		) c
	order by 1,2

	--business unit department
	if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_budepmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_budepmap
	
	create table [db-au-workspace].dbo.fpa_gl_anaplan_budepmap
	(
		BIRowID bigint identity(1,1) not null,
		BU_Dept_Map varchar(50) not null,
		BU_Dept_Display nvarchar(255) null
	)
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_budepmap(BU_Dept_Map,BU_Dept_Display) values('BU_Dept_Map','BU_Dept_Display')
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_budepmap
	select distinct
		convert(varchar,a.Business_Unit_Code) + '_' + convert(varchar,a.Department_Code) as BU_Dept_Map,
		b.BusinessUnit_Description + '_' + c.Department_Description as BU_Dept_Display
	from
		[db-au-workspace].dbo.tmp_glout a
		cross apply
		(
			select top 1 BusinessUnitDescription as BusinessUnit_Description
			from [db-au-cmdwh].dbo.glBusinessUnits
			where BusinessUnitCode = a.Business_Unit_Code
		) b
		cross apply
		(
			select top 1 DepartmentDescription as Department_Description
			from [db-au-cmdwh].dbo.glDepartments
			where DepartmentCode = a.Department_Code
		) c
	order by 1,2


	--Business Unit Department Joint Venture
	if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap
	
	create table [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap
	(
		BIRowID bigint identity(1,1) not null,
		BU_Dept_JV_Map varchar(50) not null,
		BU_Dept_JV_Display nvarchar(255) null
	)

	insert [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap(BU_Dept_JV_Map,BU_Dept_JV_Display) values('BU_Dept_JV_Map','BU_Dept_JV_Display')
	
	insert [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap
	select distinct
		convert(varchar,a.Business_Unit_Code) + '_' + convert(varchar,a.Department_Code) + '_' + convert(varchar,a.JV_Client_Code) as BU_Dept_JV_Map,
		b.BusinessUnit_Description + '_' + c.Department_Description + '_' + d.JV_Description as  BU_Dept_JV_Display
	from
		[db-au-workspace].dbo.tmp_glout a
		cross apply
		(
			select top 1 BusinessUnitDescription as BusinessUnit_Description
			from [db-au-cmdwh].dbo.glBusinessUnits
			where BusinessUnitCode = a.Business_Unit_Code
		) b
		cross apply
		(
			select top 1 DepartmentDescription as Department_Description
			from [db-au-cmdwh].dbo.glDepartments
			where DepartmentCode = a.Department_Code
		) c
		cross apply
		(
			select top 1 JVDescription as JV_Description
			from [db-au-cmdwh].dbo.glJointVentures
			where JVCode = a.JV_Client_Code
		) d
	order by 1,2

	--build SQL statement and export dimension files
	select @SQL = 'bcp "' + @QueryAccount + '" queryout "' + @Path + @FileNameAccount + @ExtTxt + '"' + ' -S localhost -T -w'
	exec xp_cmdshell @SQL

	select @SQL = 'bcp "' + @QueryProduct + '" queryout "' + @Path + @FileNameProduct + @ExtTxt + '"' + ' -S localhost -T -w'
	exec xp_cmdshell @SQL
	
	select @SQL = 'bcp "' + @QueryBUJVMap + '" queryout "' + @Path + @FileNameBuJVMap + @ExtTxt + '"' + ' -S localhost -T -w'
	exec xp_cmdshell @SQL
	
	select @SQL = 'bcp "' + @QueryBUDepMap + '" queryout "' + @Path + @FileNameBuDepMap + @ExtTxt + '"' + ' -S localhost -T -w'
	exec xp_cmdshell @SQL
	
	select @SQL = 'bcp "' + @QueryBUDepJVMap + '" queryout "' + @Path + @FileNameBuDepJVMap + @ExtTxt + '"' + ' -S localhost -T -w'
	exec xp_cmdshell @SQL

				
	--build SQL statement and zip file
	select @SQL = @ZipCommand + '"' + @Path + @FileNameAccount + @ExtZip + '"' + ' "' + @Path + @FileNameAccount + @ExtTxt + '"'
	exec xp_cmdshell @SQL	

	select @SQL = @ZipCommand + '"' + @Path + @FileNameProduct + @ExtZip + '"' + ' "' + @Path + @FileNameProduct + @ExtTxt + '"'
	exec xp_cmdshell @SQL	
	
	select @SQL = @ZipCommand + '"' + @Path + @FileNameBuJVMap + @ExtZip + '"' + ' "' + @Path + @FileNameBuJVMap + @ExtTxt + '"'
	exec xp_cmdshell @SQL	
	
	select @SQL = @ZipCommand + '"' + @Path + @FileNameBuDepMap + @ExtZip + '"' + ' "' + @Path + @FileNameBuDepMap + @ExtTxt + '"'
	exec xp_cmdshell @SQL	
	
	select @SQL = @ZipCommand + '"' + @Path + @FileNameBuDepJVMap + @ExtZip + '"' + ' "' + @Path + @FileNameBuDepJVMap + @ExtTxt + '"'
	exec xp_cmdshell @SQL					

end


--drop working tables
if object_id('[db-au-workspace].dbo.tmp_glout') is not null drop table [db-au-workspace].dbo.tmp_glout
if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_account') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_account
if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_product') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_product
if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_bujvmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_bujvmap
if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_budepmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_budepmap
if object_id('[db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap') is not null drop table [db-au-workspace].dbo.fpa_gl_anaplan_budepjvmap
if object_id('[db-au-workspace].dbo.tmp_glout_export') is not null drop table [db-au-workspace].dbo.tmp_glout_export
GO
