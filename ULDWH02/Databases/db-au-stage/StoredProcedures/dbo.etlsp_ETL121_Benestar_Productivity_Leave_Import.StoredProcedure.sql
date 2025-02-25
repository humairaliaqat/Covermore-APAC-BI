USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL121_Benestar_Productivity_Leave_Import]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE
procedure [dbo].[etlsp_ETL121_Benestar_Productivity_Leave_Import]
as

--SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Ratnesh Sharma
Date:           20190628
Prerequisite:   Data files must exist as '\\uldwh02\ETL\Data\BENESTAR_Absenteeism.xlsx' and '\\uldwh02\ETL\Data\BENESTAR_Hours_Paid.xlsx'
Description:    Import Attrition data into staging [db-au-stage].[dbo].[etl_BenestarAbsenteeism] and [db-au-stage].[dbo].[etl_BenestarHoursPaid], then transform and load leave data into [db-au-dtc].dbo.usr_PrecedaLeave and paid(work pattern) data into [db-au-dtc].dbo.usr_WorkerPrecedaInformation and [db-au-dtc].dbo.usr_WorkerPrecedaPositions and [db-au-dtc].dbo.usr_WorkerExpectedHours
Parameters:		
				
Change History:
                20190628 - RS - Procedure created
				20190729 - RS - Enabled termdate column update in merge [db-au-dtc].dbo.usr_WorkerPrecedaInformation
				

*************************************************************************************************************************************/


if object_id('[db-au-workspace].dbo.BENESTAR_Absenteeism') is not null drop table [db-au-workspace].dbo.BENESTAR_Absenteeism

select
	"ID Number" as IDNumber,
	"Full Name" as Fullname,
	"Leave Type" as LeaveType,
	"Leave Type Descripion" as LeaveTypeDescription,
	try_cast("Leave Start Date" as datetime) LeaveStartDate,
	try_cast("Leave End Date" as datetime) LeaveEndDate,
	try_cast("Hours Taken" as float) hoursTaken,
	"Leave Reason Description" as LeaveReasonDescription,
	try_cast("Date Paid" as datetime) DatePaid
into [db-au-workspace].dbo.BENESTAR_Absenteeism
from
	openrowset
	 (
        'Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0 Xml;Database=\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\BENESTAR FEED\BENESTAR_Absenteeism.xlsx',
        '
        select
            *
        from
            [Absent$]
        '
    ) t

	print('BENESTAR_Absenteeism file loaded to staging table')


if object_id('[db-au-dtc].dbo.usr_PrecedaLeave') is null 
	CREATE TABLE [dbo].[usr_PrecedaLeave](
		[BIRowID] [int] IDENTITY(1,1) NOT NULL,
		[IDNumber] [smallint] NULL,
		[LeaveType] [varchar](20) NULL,
		[LeaveStart] [datetime] NULL,
		[LeaveEnd] [datetime] NULL,
		[DatePaid] [datetime] NULL,
		[Hours] [real] NULL,
		[LeaveReason] [varchar](50) NULL
	)


--select * from [db-au-workspace].dbo.BENESTAR_Absenteeism


insert into [db-au-dtc].dbo.usr_PrecedaLeave(IDNumber, LeaveType, LeaveStart, LeaveEnd, Hours, LeaveReason, DatePaid)
select [IDNumber], A.LeaveTypeDescription, CONVERT(datetime,[LeaveStartDate],103), CONVERT(datetime,[LeaveEndDate],103), [HoursTaken], [LeaveReasonDescription], CONVERT(datetime,DatePaid,103)
from [db-au-workspace].dbo.BENESTAR_Absenteeism A
where not exists (select 1 
	from [db-au-dtc].dbo.usr_PrecedaLeave B 
	where A.IDNumber = B.IDNumber 
		AND CONVERT(datetime,A.[LeaveStartDate],103) = B.LeaveStart 
		AND CONVERT(datetime,A.[LeaveEndDate],103) = B.LeaveEnd 
		AND A.HoursTaken = B.Hours)

	print('BENESTAR_Absenteeism data loaded to DW table')

	/**************************************************************************************/

	if object_id('[db-au-workspace].dbo.BENESTAR_Paid') is not null drop table [db-au-workspace].dbo.BENESTAR_Paid


	select --DISTINCT
	"ID Number" as IDNumber,
	"Full Name" as FullName,
	"Position Title" as PositionTitle,
	"Base Hours Amount" as BaseHoursamount,
	"Work Pattern Code" as WorkPatternCode,
	"Work Pattern Description" as WorkPatternDescription,
	"Department Description" as DepartmentDescription,
	try_cast("Hire Date" as datetime) as Hiredate,
	try_cast("Term Date" as datetime) as TermDate
into [db-au-workspace].dbo.BENESTAR_Paid
from openrowset
    (
        'Microsoft.ACE.OLEDB.12.0',
        'Excel 12.0 Xml;Database=\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\BENESTAR FEED\BENESTAR_Hours_Paid.xlsx',
        '
        select
            *
        from
            [Paid$]
        '
    ) t

	print('BENESTAR_Hours_Paid file loaded to staging table')
	
	/*** Add new Workers ***/
	select  DISTINCT [IDNumber] as IDNumber, 
		CAST(null as varchar(255)) as Department, 
		DepartmentDescription as OrgUnitDescription, 
		PositionTitle as PositionTitle, 
		null as ReportsToTitle, 
		FullName as FullName, 
		null as FirstName, 
		null as Lastname,  
		CAST(HireDate as date) as HireDate, 
		TermDate as TermDate
INTO #Src
from [db-au-workspace].dbo.BENESTAR_Paid A
--where not exists (select 1 from [db-au-dtc].dbo.usr_WorkerPrecedaInformation B where A.IDNumber = B.IDNumber)

merge into [db-au-dtc].dbo.usr_WorkerPrecedaInformation as tgt
using #src as src
on tgt.IDNumber = src.IDNumber
WHEN matched then 
	UPDATE
		SET Department = src.Department,
			OrgUnitDescription = src.OrgUnitDescription,
			PositionTitle = src.PositionTitle,
			ReportsToTitle = src.ReportsToTitle,
			FullName = src.Fullname,
			FirstName = src.FirstName,
			LastName = src.Lastname,
			HireDate = src.HireDate,
			TermDate = src.TermDate--uncommented by Ratnesh on 20190729 based on email from Dane
WHEN not matched then
	insert (IDNumber, Department, OrgUnitDescription, PositionTitle, ReportsToTitle, FullName, FirstName, LastName, HireDate, TermDate)
	values (IDNumber, src.Department, src.OrgUnitDescription, src.PositionTitle, src.ReportsToTitle, src.FullName, src.FirstName, src.LastName, src.HireDate, src.TermDate)
	;

	print('BENESTAR_Hours_Paid workers details are merged to DW table.')

	/*** Insert new Positions ***/

INSERT INTO [db-au-dtc].dbo.usr_WorkerPrecedaPositions (PositionTitle, Clinical)
select DISTINCT PositionTitle, 0
from [db-au-dtc].dbo.usr_WorkerPrecedaInformation wpi
WHERE NOT EXISTS (select 1 from [db-au-dtc].dbo.usr_WorkerPrecedaPositions wpp where wpi.PositionTitle = wpp.PositionTitle)

print('BENESTAR_Hours_Paid new positions are added to DW table.')

/*** Load Work Patterns ***/

select IDNumber, FullName, PositionSK, PositionTitle, EffectiveDate, BaseHoursAmount, [Work Patter Detail], 
	[2] as Monday,
	[3] as Tuesday,
	[4] as Wednesday,
	[5] as Thursday,
	[6] as Friday,
	[7] as Saturday,
	[1] as Sunday,
	1 as Confirmed
into #PatternSrc
from (
	select DISTINCT e.IDNumber, E.FullName, wpp.BIRowID as PositionSK, wpp.PositionTitle, CONVERT(datetime, e.HireDate, 103) as EffectiveDate, E.BaseHoursAmount, wp.[Work Patter Detail],wp.[Day of the Week], wp.[Work Hours]
		--wp.Mon, wp.Tue, wp.Wed, wp.Thu, wp.Fri, wp.Sat, wp.Sun, 0
	from [db-au-workspace].dbo.BENESTAR_Paid e 
	join [db-au-workspace].dbo.Benestar_WorkPatterns wp on e.WorkPatternCode = wp.Code and wp.[Period of Work Pattern - in Weeks] = 1
	JOIN [db-au-dtc].dbo.usr_WorkerPrecedaPositions wpp on e.PositionTitle = wpp.PositionTitle
	--where not exists (select 1 from [db-au-dtc].dbo.usr_WorkerExpectedHours d where d.IDNumber = E.IDNumber)
	) as src
pivot (
	SUM([Work Hours])
	for [Day of the Week] IN ([1],[2],[3],[4],[5],[6],[7])
	) pvt

insert into [db-au-dtc].dbo.usr_WorkerExpectedHours (IDNumber, Name, PositionSK, Position, EffectiveDate, Hours, WorkPattern, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, Confirmed)
select e.IDNumber, E.FullName, E.PositionSK, E.PositionTitle,EffectiveDate, BaseHoursAmount, e.[Work Patter Detail], Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, Confirmed
from #PatternSrc e
where not exists (select 1 from [db-au-dtc].dbo.usr_WorkerExpectedHours d where d.IDNumber = E.IDNumber)

;with h as (
	select IDNumber, EffectiveDate, WorkPattern, row_number() over(partition by IDNumber order by effectiveDate desc) rnk
	from [db-au-dtc].dbo.usr_WorkerExpectedHours
	)
insert into [db-au-dtc].dbo.usr_WorkerExpectedHours (IDNumber, Name, PositionSK, Position, EffectiveDate, Hours, WorkPattern, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, Confirmed)
select P.IDNumber, P.FullName, P.PositionSK, P.PositionTitle, GetDate(), P.BaseHoursAmount, P.[Work Patter Detail], P.Monday, P.Tuesday, P.Wednesday, P.Thursday, P.Friday, P.Saturday, P.Sunday, 0 Confirmed
	--,h.WorkPattern
from #PatternSrc P
JOIN h on  p.IDNumber = h.IDNumber
where p.[Work Patter Detail] <> h.WorkPattern
and h.rnk = 1

print('BENESTAR_Hours_Paid new workers expected hours are added to DW table.')

	--archive processed files
    DECLARE @Command varchar(8000)

    --move files to archive
    SELECT
      @Command = 'move "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\BENESTAR FEED\BENESTAR_Absenteeism.xlsx" "e:\etl\data\Benestar\archive\BENESTAR_Absenteeism_' + CONVERT(varchar(10), GETDATE(), 112) + '.xlsx"'
    EXECUTE xp_cmdshell @Command

    SELECT
      @Command = 'move "\\aust.covermore.com.au\data\NorthSydney_data\Human Resources\PAYROLL\BENESTAR FEED\BENESTAR_Hours_Paid.xlsx" "e:\etl\data\Benestar\archive\BENESTAR_Hours_Paid_' + CONVERT(varchar(10), GETDATE(), 112) + '.xlsx"'
    EXECUTE xp_cmdshell @Command
GO
