USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_306_usrUserActiveDay]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-11-22
-- Description:	
-- =============================================
create PROCEDURE [dbo].[etlsp_ETL090_306_usrUserActiveDay] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc]..usrUserActiveDay') is null 
	create table [db-au-dtc]..usrUserActiveDay (
		UserSK int,
		ResourceCode nvarchar(50),
		dateId int,
		activityId int,
		activityCode nvarchar(50),
		activityDesc nvarchar(50),
		expectedHours float,
		FTE float,
		productivityTarget float,
		helper int,
		atRisk int,
		ActiveDay int,
		scenario int,
		index idx_idx_usrUserActiveDay_UserSK nonclustered (UserSK)
	) 


	if object_id('tempdb..#src') is not null drop table #src 

	select * 
	into #src 
	from openquery([DTCSYD03CL1],
	'SELECT 
		null UserSK,
		coalesce(mr.ResourceCode, r.resource_code) ResourceCode,
		d.dateId,
		a.activityId,
		a.activityCode,
		a.activityDesc,
		CASE WHEN dc.DaysInWeek = 0 OR dc.DaysInWeek IS NULL THEN null ELSE
		case when a.activityid = 225 
			then 
				F.FTE * 40 / dc.DaysInWeek * weekdayProportion * dc.ActiveDay
			when a.activityid = 107
			then
				F.FTE * 40 / dc.DaysInWeek * (weekdayProportion + leaveProportion) * dc.ActiveDay
			else
				F.FTE * 40 / dc.DaysInWeek * leaveProportion  * dc.ActiveDay
			end end as expectedHours,
		F.FTE,
		(mr.targetchargeablepercent / 100) as productivityTarget,
		1 as helper,
		CASE WHEN d.date <= COALESCE(atrisk.AtRiskDate, r.commenced_date,GetDate()) 
			OR (r.terminated_date IS NOT NULL AND D.date > R.terminated_date)
			THEN 0 ELSE 1 END as atRisk,
		case when a.activityid = 225 THEN dc.ActiveDay ELSE null END as ActiveDay,
		2 as scenario
	FROM 
		eFrontOfficeDW.dbo.paresrce R inner join 
		eFrontOfficeDW.dbo.MstResources mr on r.resource_code = mr.resourcecode inner join 
		eFrontOfficeDW.dbo.DimDate d on d.date between commenced_date and coalesce(terminated_date,getdate()+365*2) inner join
		eFrontOfficeDW.dbo.resourceFTE F ON mr.resourceCode = F.resourceCode AND d.date between F.fromdate and F.todate left join
		eFrontOfficeDW.dbo.PublicHolidays H ON d.date = convert(varchar(8),H.[date],112) inner join
		eFrontOfficeDW.dbo.MstActivities a ON a.activityid IN (225, 226, 107) cross apply
			(select 
				25/cast(count(*) as float) as leaveProportion, --annual leave + sick leave
				(cast(count(*) as float)-25)/cast(count(*) as float) as weekdayProportion -- including public holidays
			From 
				eFrontOfficeDW.dbo.DimDate cad
			where
				cad.cyear = d.cyear and
				datepart(weekday,cad.date) not in (1,7)
			) proportions
		left join eFrontOfficeDW.dbo.ResourceAtRiskDate atrisk on R.resource_code = atrisk.resource_code
		LEFT JOIN eFrontOfficeDW.dbo.MSTResourceTimesheetDays dc on mr.resourceID = dc.resourceid AND d.DateID = dc.dateid
	WHERE 
		department_code = ''STAFF'' and
		--datepart(weekday,d.date) not in (1,7) and
		--R.standard_weekly_hours <> 0 and
		d.date between getdate()-365*2 and getdate()+365*2 and	-- only back to last 2 years, not 2011-01-01 
		((H.[date] is not NULL and a.activityid = 107) OR
		(H.[date] is NULL and a.activityid IN (225, 226)))
	') 

	update a 
	set UserSK = u.UserSK 
	from #src a join [db-au-dtc]..pnpUser u on u.ClienteleResourceCode = a.ResourceCode 


	merge [db-au-dtc]..usrUserActiveDay tgt 
	using #src on #src.ResourceCode = tgt.ResourceCode and #src.dateId = tgt.dateId and #src.activityId = tgt.activityId 
	when not matched by target then 
		insert (
			UserSK,
			ResourceCode,
			dateId,
			activityId,
			activityCode,
			activityDesc,
			expectedHours,
			FTE,
			productivityTarget,
			helper,
			atRisk,
			ActiveDay,
			scenario
		) 
		values (
			#src.UserSK,
			#src.ResourceCode,
			#src.dateId,
			#src.activityId,
			#src.activityCode,
			#src.activityDesc,
			#src.expectedHours,
			#src.FTE,
			#src.productivityTarget,
			#src.helper,
			#src.atRisk,
			#src.ActiveDay,
			#src.scenario
		) 
	when matched then update 
		set 
			tgt.UserSK = #src.UserSK,
			tgt.activityCode = #src.activityCode,
			tgt.activityDesc = #src.activityDesc,
			tgt.expectedHours = #src.expectedHours,
			tgt.FTE = #src.FTE,
			tgt.productivityTarget = #src.productivityTarget,
			tgt.helper = #src.helper,
			tgt.atRisk = #src.atRisk,
			tgt.ActiveDay = #src.ActiveDay,
			tgt.scenario = #src.scenario
	;


END
GO
