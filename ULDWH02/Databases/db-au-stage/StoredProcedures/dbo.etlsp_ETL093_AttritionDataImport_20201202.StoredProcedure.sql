USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL093_AttritionDataImport_20201202]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL093_AttritionDataImport_20201202]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180613
Prerequisite:   Data file must exist in '\\uldwh02\etl\data\preceda\AttritionData.xlsx'
Description:    Import Attrition data into staging [db-au-stage].[dbo].[etl_attritiondata], then transform and load into [db-au-cmdwh].dbo.usrAttrition
Parameters:		
				
Change History:
                20180613 - LT - Procedure created
				20181003 - LT - Added State column
                20200124 - EV - “ID Number” and “Date of Birth” maches then update else insert
*************************************************************************************************************************************/


if object_id('tempdb..#tmpEmp') is not null drop table #tmpEmp

select
	left([Status],50) as [Status],
	[ID Number] as EmpID,
	left([Level 1],50) as Level1,
	left([Full Name],200) as EmployeeName,
	left([Gender],5) as Gender,
	convert(datetime,[Date of Birth]) as DOB,
	[Full Title] as JobTitle,
	left([Seniority Level],100) as SeniorityLevel,
	left([Employment Type],100) as EmploymentType,
	left([Personnel Type],100) as PersonnelType,
	convert(float,[Weekly Hours]) as WeeklyHours,
	convert(float,[FTE]) as FTE,
	convert(datetime,[Hire Date]) as HireDate,
	convert(datetime,[Term Date]) as TerminationDate,
	left([Country],100) as Country,
	left([Division],200) as Division,
	left([Dept Description],200) as DepartmentName,
	left([Term Reason],100) as LeaveType,
	left([AU State],200) as State,
	convert(binary,null) as HashKey
into #tmpEmp
from
	openrowset
	(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\Preceda\AttritionData.xlsx',
		'
		select 
			*
		from 
			[Sheet1$]
		'
	)

if object_id('tempdb..#tmpEmp2') is not null drop table #tmpEmp2
select
	Row_Number() over(partition by EmployeeName, EmpID order by EmployeeName ) as RowID,
	*
into #tmpEmp2
from #tmpEmp


if object_id('[db-au-stage].dbo.etl_attritiondata') is not null drop table [db-au-stage].dbo.etl_attritiondata

create table [db-au-stage].dbo.etl_attritiondata
(
	[Status] [nvarchar](255) NULL,
	[ID Number] bigint NULL,
	[Level 1] [nvarchar](255) NULL,
	[Full Name] [nvarchar](255) NULL,
	[Gender] [nvarchar](255) NULL,
	[Date of Birth] datetime NULL,
	[Full Title] [nvarchar](255) NULL,
	[Seniority Level] [nvarchar](255) NULL,
	[Employment Type] [nvarchar](255) NULL,
	[Personnel Type] [nvarchar](255) NULL,
	[Weekly Hours] [nvarchar](255) NULL,
	[FTE] [nvarchar](255) NULL,
	[Hire Date] datetime NULL,
	[Term Date] datetime NULL,
	[Country] [nvarchar](255) NULL,
	[Division] [nvarchar](255) NULL,
	[Dept Description] [nvarchar](255) NULL,
	[Term Reason] [nvarchar](255) NULL,
	[State] [nvarchar](200) NULL,
	HashKey [binary](30) NULL
)


insert into [db-au-stage].dbo.etl_attritiondata
(
	[Status],
	[ID Number],
	[Level 1],
	[Full Name],
	[Gender],
	[Date of Birth],
	[Full Title],
	[Seniority Level],
	[Employment Type],
	[Personnel Type],
	[Weekly Hours],
	[FTE],
	[Hire Date],
	[Term Date],
	[Country],
	[Division],
	[Dept Description],
	[Term Reason],
	HashKey
)
select
	[Status],
	EmpID as EmpID,
	Level1,
	ltrim(rtrim(EmployeeName)) as EmployeeName,
	Gender,
	convert(datetime,DOB) as DOB,
	ltrim(rtrim(JobTitle)) as JobTitle,
	ltrim(rtrim(SeniorityLevel)) as SeniorityLevel,
	ltrim(rtrim(EmploymentType)) as EmploymentType,
	case when PersonnelType = 'Full-Time' then 'FULL TIME' else PersonnelType end as PersonnelType,
	WeeklyHours,
	FTE,
	convert(datetime,HireDate) as HireDate,
	convert(datetime,TerminationDate) as TerminationDate,
	case when Division in ('Asia Pacific','DTC','Benestar','Finance','FitSense','Global Digital & FinTech','Risk, Legal and Acquisitions','Management','People & Culture','Risk, Legal and Acquisitions','WTP AU','Europe, Middle East and Africa') then 'Australia' 
		when Division = 'NZ' then 'New Zealand'
		when Division in ('WTP CA','WTP US') then 'Canada'
		when Division in ('USA','Innate') then 'United States of America'
		when Division like '%travelex%' then 'United States of America'
		when Division in ('UK','Halo') then 'United Kingdom'
		when Division = 'India' then 'India'
		when Division = 'China' then 'China'
		when Division = 'Malaysia' then 'Malaysia'
		when Division = 'Latin America' then 'Latin America'
		else 'Unknown'
	end as Country,
	case when Division = 'USA' and DepartmentName like '%Travelex%' then 'Travelex Insurance Services' 
		 when Division like 'Travelex%' then 'Travelex Insurance Services'
		 when Division in ('DTC','Benestar') then 'Benestar'
		 when Division = 'WTP US' then 'WTP CA'
		 else Division end as Division,
	case when DepartmentName in ('DTC','Benestar') then 'Benestar'
		 when DepartmentName = 'COVER-MORE ASIA' then 'Malaysia'
		 when DepartmentName like 'Travelex%' then 'Travelex Insurance Services'
		 when DepartmentName = 'WTP US' then 'WTP CA'
		 else DepartmentName
	end as DepartmentName,
	case when LeaveType like 'VOL%' then 'Voluntary'
		 when LeaveType like 'INVOL%' then 'Involuntary'
		 when LeaveType is null then NULL
		 else 'Unknown'
	end,
	HashKey
from #tmpEmp2
where RowID = 1
order by Country, Division, DepartmentName, EmployeeName


update [db-au-stage].dbo.etl_attritiondata
set HashKey = binary_checksum
			  (
				[Status],
				[ID Number],
				[Level 1],
				[Full Name],
				[Gender],
				[Date of Birth],
				[Full Title],
				[Seniority Level],
				[Employment Type],
				[Personnel Type],
				[Weekly Hours],
				[FTE],
				[Hire Date],
				[Term Date],
				[Country],
				[Division],
				[Dept Description],
				[Term Reason],
				[State]
			  )	


if object_id('[db-au-cmdwh].dbo.usrAttrition') is null
begin
	create table [db-au-cmdwh].dbo.usrAttrition
	(
		[Status] nvarchar(50) null,
		EmpID int null,
		[Level1] nvarchar(50) null,
		EmployeeName nvarchar(200) null,
		Gender nvarchar(5) null,
		DOB datetime null,
		JobTitle nvarchar(255) null,		
		SeniorityLevel nvarchar(100) null,
		EmploymentType nvarchar(100) null,
		PersonnelType nvarchar(100) null,
		WeeklyHours float null,
		FTE float null,
		HireDate datetime null,
		TerminationDate datetime null,
		Country nvarchar(100) null,
		Division nvarchar(200) null,
		DepartmentName nvarchar(200) null,
		LeaveType nvarchar(100) null,
		HashKey binary(30) null,
		LoadDate datetime null,
		UpdateDate datetime null,
		State nvarchar(200) null
	)
	create clustered index idx_usrAttrition_EmpID on [db-au-cmdwh].dbo.usrAttrition(EmpID)
	create nonclustered index idx_usrAttrition_EmployeeName on [db-au-cmdwh].dbo.usrAttrition(EmployeeName)
end

        merge into [db-au-cmdwh].dbo.usrAttrition with(tablock) t
        using [db-au-stage].dbo.etl_attritiondata s on
            s.[ID Number] = t.EmpID-- and s.[Date of Birth] = t.DOB

        when matched then
            update
            set t.[Status] = case when t.[Status] <>  s.[Status] then  s.[Status] else t.[Status] end,
		    t.[Level1] = case when t.[Level1] <>  s.[Level 1] then  s.[Level 1] else t.[Level1] end,
		    t.JobTitle = case when t.[JobTitle] <>  s.[Full Title] then  s.[Full Title] else t.[JobTitle] end,
		    t.SeniorityLevel = case when t.[SeniorityLevel] <>  s.[Seniority Level] then  s.[Seniority Level] else t.[SeniorityLevel] end,
		    t.EmploymentType = case when t.[EmploymentType] <>  s.[Employment Type] then  s.[Employment Type] else t.[EmploymentType] end,
		    t.PersonnelType = case when t.PersonnelType <>  s.[Personnel Type] then  s.[Personnel Type] else t.[PersonnelType] end,
		    t.WeeklyHours = case when t.[WeeklyHours] <>  s.[Weekly Hours] then  s.[Weekly Hours] else t.[WeeklyHours] end,
		    t.FTE = case when t.FTE <>  s.[FTE] then  s.[FTE] else t.FTE end,
		    t.HireDate = case when t.HireDate <>  s.[Hire Date] then  s.[Hire date] else t.HireDate end,
		    t.TerminationDate = case when  s.[Term Date] is not null then  s.[Term Date] else t.TerminationDate end,
		    t.Country = case when t.Country <>  s.[Country] then  s.[Country] else t.Country end,
		    t.Division = case when t.[Division] <>  s.[Division] then  s.[Division] else t.[Division] end,
		    t.DepartmentName = case when t.DepartmentName <>  s.[Dept Description] then  s.[Dept Description] else t.[DepartmentName] end,
		    t.LeaveType = case when  s.[Term Reason] is not null then  s.[Term Reason] else t.LeaveType end,
		    t.HashKey = case when  s.HashKey is not null then  s.HashKey else t.HashKey end, 
            t.UpdateDate = getdate()

        when not matched by target then 
            insert
            (
            [Status],
	        EmpID,
	        [Level1],
	        EmployeeName,
	        Gender,
	        DOB,
	        JobTitle,	
	        SeniorityLevel,
	        EmploymentType,
	        PersonnelType,
	        WeeklyHours,
	        FTE,
	        HireDate,
	        TerminationDate,
	        Country,
	        Division,
	        DepartmentName,
	        LeaveType,
	        HashKey,
	        LoadDate,
	        UpdateDate,
	        [State]
            )
             values
            (
                s.[Status],
                s.[ID Number],
                s.[Level 1],
                s.[Full Name],
                s.[Gender],
                s.[Date of Birth],
                s.[Full Title],
                s.[Seniority Level],
                s.[Employment Type],
                s.[Personnel Type],
                s.[Weekly Hours],
                s.[FTE],
                s.[Hire Date],
                s.[Term Date],
                s.[Country],
                s.[Division],
                s.[Dept Description],
                s.[Term Reason],
                s.HashKey,
                getdate(),
                null,
                s.[State]
            )
        ;

/*
--insert new records if any
insert [db-au-cmdwh].dbo.usrAttrition with(tablockx)
(
	[Status],
	EmpID,
	[Level1],
	EmployeeName,
	Gender,
	DOB,
	JobTitle,	
	SeniorityLevel,
	EmploymentType,
	PersonnelType,
	WeeklyHours,
	FTE,
	HireDate,
	TerminationDate,
	Country,
	Division,
	DepartmentName,
	LeaveType,
	HashKey,
	LoadDate,
	UpdateDate,
	State
)
select
	[Status],
	[ID Number] as EmpID,
	[Level 1] as Level1,
	[Full Name] as EmployeeName,
	[Gender],
	[Date of Birth] as DOB,
	[Full Title] as JobTitle,
	[Seniority Level] as SeniorityLevel,
	[Employment Type] as EmployeeType,
	[Personnel Type] as PersonnelType,
	[Weekly Hours] as WeeklyHours,
	[FTE],
	[Hire Date] as HireDate,
	[Term Date] as TerminationDate,
	[Country],
	[Division],
	[Dept Description] as DepartmentName,
	[Term Reason] as LeaveType,
	HashKey,
	getdate() as LoadDate,
	null as UpdateDate,
	State
from
	[db-au-stage].dbo.etl_attritiondata
where
	isnull([ID Number],'') > '' and
	convert(varchar,isnull([ID Number],'')) + '-' + ltrim(rtrim([Full Name])) not in (select convert(varchar,isnull(EmpID,'')) + '-' + ltrim(rtrim([EmployeeName])) from [db-au-cmdwh].dbo.usrAttrition)


 --update existing records
update a
	set a.[Status] = case when a.[Status] <> b.[Status] then b.[Status] else a.[Status] end,
		a.[Level1] = case when a.[Level1] <> b.[Level 1] then b.[Level 1] else a.[Level1] end,
		a.JobTitle = case when a.[JobTitle] <> b.[Full Title] then b.[Full Title] else a.[JobTitle] end,
		a.SeniorityLevel = case when a.[SeniorityLevel] <> b.[Seniority Level] then b.[Seniority Level] else a.[SeniorityLevel] end,
		a.EmploymentType = case when a.[EmploymentType] <> b.[Employment Type] then b.[Employment Type] else a.[EmploymentType] end,
		a.PersonnelType = case when a.PersonnelType <> b.[Personnel Type] then b.[Personnel Type] else a.[PersonnelType] end,
		a.WeeklyHours = case when a.[WeeklyHours] <> b.[Weekly Hours] then b.[Weekly Hours] else a.[WeeklyHours] end,
		a.FTE = case when a.FTE <> b.[FTE] then b.[FTE] else a.FTE end,
		a.HireDate = case when a.HireDate <> b.[Hire Date] then b.[Hire date] else a.HireDate end,
		a.TerminationDate = case when b.[Term Date] is not null then b.[Term Date] else a.TerminationDate end,
		a.Country = case when a.Country <> b.[Country] then b.[Country] else a.Country end,
		a.Division = case when a.[Division] <> b.[Division] then b.[Division] else a.[Division] end,
		a.DepartmentName = case when a.DepartmentName <> b.[Dept Description] then b.[Dept Description] else a.[DepartmentName] end,
		a.LeaveType = case when b.[Term Reason] is not null then b.[Term Reason] else a.LeaveType end,
		a.UpdateDate = getdate()
from 
	[db-au-cmdwh].dbo.usrAttrition a
	inner join [db-au-stage].dbo.etl_attritiondata b on a.EmployeeName = b.[Full Name] and a.EmpID = b.[ID Number]
--where
	--a.HashKey <> b.HashKey and
	--convert(varchar,isnull([ID Number],'')) + '-' + ltrim(rtrim([Full Name])) in (select convert(varchar,isnull(EmpID,'')) + '-' + ltrim(rtrim([EmployeeName])) from [db-au-cmdwh].dbo.usrAttrition)
	
*/	

--drop tables
drop table #tmpEmp
drop table #tmpEmp2
drop table etl_attritiondata



GO
