USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1117_WTPCase]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Neha Chopade, Capgemini
-- Create date: 17Apr2020
-- Description:	
/*
The report should run on 1st day of the month giving statistics of the previous month.
[For example, the report generated on 01April2020 will give the statistics 
for March2020 month.
Current Month = April2020
Previous Month = March2020
]

The query gives below demographics:
1. Cases Open as of first day of the previous month:
	[Column Name = Case_Open_asof_firstday]
	Open Date should be less that first day of the previous month and
	Close Date should either be blank or greater than first day of the previous month

2. Cases Opened in previous month:
	[Column Name = Case_Open_in_Month]
	Open Date should be within first day and last day of the previous month
	inclusive of first and last day

3. Cases Closed in pervious month:
	[Column Name = Case_Closed_in_Month]
	Close Date should be within first day and last day of the previous month
	inclusive of first and last day
	
4. Cases Open as of last day of the previous month:
	[Column Name = Case_Open_asof_lastday]
	Close date should either be blank or greater than last day of the previous month
	

The below formula should be true always:
[1] + [2] - [3] = [4]


5. ClientSubGroup: The groupping is hardcoaded in the report as provided by the report requester Cynthia.Chen@covermore.com

6. Task Number: This field gives count of Plan per case number whose Plan description starts with a number
*/
-- Change History:		17Apr2020 - Neha Chopade, Capgemini - Created

-- =============================================
CREATE PROCEDURE [dbo].[rptsp_rpt1117_WTPCase] 
@DateRange varchar(30),
@StartDate datetime, 
@EndDate datetime		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @PeriodStartDate datetime ,
		@PeiodEndDate datetime
		/* initialise dates */
	if @DateRange = '_User Defined'
		select @PeriodStartDate = @StartDate, @PeiodEndDate = @EndDate
	else
		select @PeriodStartDate = StartDate, @PeiodEndDate = EndDate
		from [db-au-cmdwh].dbo.vDateRange
		where DateRange = @DateRange

Select 
noncba.*
from 
(

select 

  vCBClientGroup.ClientCode,
  vCBClientGroup.ClientName,
  vCBClientGroup.ClientGroup,
  case when (vCBClientGroup.ClientGroup = 'Cover-More' and vCBClientGroup.ClientName ='BENESTAR') or vCBClientGroup.ClientGroup = 'BENESTAR'  then 'Benestar'
		when vCBClientGroup.ClientGroup in ( 'Cover-More', 'IAL','AIR NEW ZEALAND') then 'CoverMore Group'
		when vCBClientGroup.ClientGroup = 'Other' and vCBClientGroup.ClientCode in ('IC') then 'CoverMore Group'
		when vCBClientGroup.ClientGroup = 'IAG' then 'IAG'
		when vCBClientGroup.ClientGroup = 'Inbound' or vCBClientGroup.ClientCode in ('AV','BE','BR','BT','HT','MC','ML','VH','VV') then 'Inbound'
		when vCBClientGroup.ClientGroup = 'Concierge' or vCBClientGroup.ClientCode in ('AH','CC','CD','CP','CR','CU','WA') then 'Other'
		when vCBClientGroup.ClientGroup in ('Chubb','Zurich','BERKSHIRE','BEAZLEY','GO INSURANCE') or vCBClientGroup.ClientCode in ('AM','BG','BP','BU','PD') then 'Outbound'
  End ClientSubGroup,	
  cc.ProgramCode,
  cc.ProtocolCode,
  cc.Protocol,
  cc.CountryKey,
  cc.Country,
  cc.CaseType,
  cc.CaseNo,
  cc.OpenDate,
  cc.CloseDate,
  cc.Team,
  pd.TaskNumber,
	case when Convert(Date,cc.OpenDate) < @PeriodStartDate and
			  (Convert(Date,cc.CloseDate) >= @PeriodStartDate OR
			  cc.CloseDate Is NULL)
		then 1 else 0 end as Case_Open_asof_firstday,
	case when Convert(Date,cc.OpenDate) between @PeriodStartDate and 
									 @PeiodEndDate 
		then 1 else 0 end as Case_Open_in_Month,
	case when Convert(Date,cc.CloseDate) between @PeriodStartDate and 
									   @PeiodEndDate 
		then 1 else 0 end as Case_Closed_in_Month,
	case when (Convert(Date,cc.CloseDate) > @PeiodEndDate OR
			  cc.CloseDate Is NULL) and
			  Convert(Date,cc.OpenDate) <= @PeiodEndDate
		then 1 else 0 end as Case_Open_asof_lastday,


	case when Convert(Date,cc.OpenDate) < @PeriodStartDate and
			  (Convert(Date,cc.CloseDate) >= @PeriodStartDate OR
			  cc.CloseDate Is NULL)
	 then pd.TaskNumber else 0 end Tasks_asof_firstday,
	case when Convert(Date,cc.OpenDate) between @PeriodStartDate and 
									 @PeiodEndDate 
		then pd.TaskNumber else 0 end Tasks_Open_in_Month,
	case when Convert(Date,cc.CloseDate) between @PeriodStartDate and 
									   @PeiodEndDate 
		then pd.TaskNumber else 0 end Tasks_Closed_in_Month,
	case when (Convert(Date,cc.CloseDate) > @PeiodEndDate OR
			  cc.CloseDate Is NULL) and
			  Convert(Date,cc.OpenDate) <= @PeiodEndDate
		then pd.TaskNumber else 0 end Tasks_asof_lastday,
	@PeriodStartDate as PeriodStartDate,
	@PeiodEndDate as PeriodEndDate
from 
	[ULDWH02].[db-au-cmdwh].dbo.cbCase cc
		left join 
	[ULDWH02].[db-au-cmdwh].dbo.vCBClientGroup
		on (vCBClientGroup.ClientCode=cc.ClientCode)

	outer apply

	(select cp.CaseKey,
		sum(CASE WHEN ISNUMERIC(SUBSTRING(LTRIM(cp.PlanDetail), 1, 1)) = 1 
			 THEN 1 
			 ELSE 0 
			 END) as TaskNumber
	from  [ULDWH02].[db-au-cmdwh].[dbo].[cbPlan] cp
	where cc.CaseKey = cp.CaseKey
	Group by cp.CaseKey
	) pd
	
where 
		cc.IsDeleted = 0 and
		(cc.CountryKey ='AU' or cc.ClientCode in ('AW','IN','OP','TZ','UK','VN','WZ'))
		and cc.ClientName not in ('NRMA','WTP TRAINING','MBF','MALAYSIA AIR - AUSTRALIA')

) noncba
		
where 
noncba.Case_Open_asof_firstday =1 or
noncba.Case_Open_in_Month=1 or
noncba.Case_Closed_in_Month=1 or	
noncba.Case_Open_asof_lastday=1	


END
GO
