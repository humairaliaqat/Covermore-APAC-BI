USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_livecarebase_case]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_livecarebase_case]
as


begin

    declare @starttoday datetime
	declare @startmtd datetime
    set 
        @starttoday = [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(convert(date, getdate()), 'AUS Eastern Standard Time')
	set
		@startmtd = [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(convert(date, DATEADD(DAY,1,EOMONTH(getdate(),-1))), 'AUS Eastern Standard Time')

    if object_id('tempdb..#livecarebase') is not null
        drop table #livecarebase

    select 
        c.CASE_NO,
        c.STATUS as CaseStatus,
        c.CASETYPE_ID,
        c.CLI_CODE collate database_default ClientCode,
        c.RISKLEVEL_ID,
		case 
			when c.RISKLEVEL_ID = '1' then 'HighRisk'
			when c.RISKLEVEL_ID = '2' then 'MediumRisk'
			when c.RISKLEVEL_ID = '3' then 'LowRisk'
			when c.RISKLEVEL_ID = '4' then 'VeryHighRisk'
			else 'Undefined'
		end RiskLevel,
        it.IncidentType,
		c.CREATED_DT as CreatedDate,		
        case
            when c.CREATED_DT >= @starttoday then 1
            else 0
        end CreatedToday,
		case
            when c.CREATED_DT >= @startmtd then 1
            else 0
        end CreatedMTD,
		case
            when c.CLOSE_DATE >= @starttoday then 1
            else 0
        end ClosedToday,
		case
            when c.CLOSE_DATE >= @startmtd then 1
            else 0
        end ClosedMTD,
		case
            when c.PROB_TYPE = 'M' then 'Medical'
            when c.PROB_TYPE = 'T' then 'Technical'
            else 'Undefined'
		end Protocol,
		c.RiskReason_ID,	
		rs.Description as RiskReason,	
		con.CNTRY_CODE collate database_default CountryCode,
		pl.ACTION_AC,
		pl.NoOfPlan,
		case
            when c.CLI_CODE in (select tc.CLI_CODE
								from 
									[db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.teams_client as tc
								where 
								team_id in ('03', '11', '14')) then 'Covermore Group'
			when c.CLI_CODE in (select tc.CLI_CODE
								from 
									[db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.teams_client as tc
								where 
								team_id in ('06'))  then 'Inbound'
            else 'External'
		end TeamName,
		datediff(day, c.OPEN_DATE, [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(getdate(), 'AUS Eastern Standard Time')) 
			as AgeOfCase

    into #livecarebase
    from
       [db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.CMN_MAIN c with(nolock)
		left join [db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.tblriskreasons as rs on (c.RiskReason_ID = rs.RiskReason_ID)
        outer apply
        (
            select
                a.CNTRY_CODE
            from
                [db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.CAD_ADDRESS a with(nolock)
            where
                --a.TYPE = 'INCD' and
				a.IsCurrentLocation = '1' and
                a.case_no = c.case_no
        ) con
        outer apply
        (
            select top 1
                it.INCIDENT_TYPE IncidentType
            from
                [db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.NIT_INCIDENTTYPE it
            where
                it.ID = c.INCIDENTTYPE_ID
        ) it
		outer apply 
		( 
			select 
				p.CASE_NO,
				p.ACTION_AC,
				count(ROWID) as NoOfPlan
			from 
				[db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.CPL_PLAN as p
			where 
				p.CASE_NO =c.CASE_NO
				and p.COMP_DATE is null
				and convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(P.TODO_DATE, 'AUS Eastern Standard Time')) 
					<= convert(date, getdate())
			group by 
				p.CASE_NO,
				p.ACTION_AC

		) pl
    where
       ((c.DELETED <> 'Y' 
		and c.CREATED_DT >= '2014-07-01' 
		and c.CREATED_DT < @startmtd
		and c.STATUS = 'O'
		)
		
		or
		(c.DELETED <> 'Y' and c.CREATED_DT >= @startmtd)

		or
		(c.DELETED <> 'Y' and c.CLOSE_DATE >= @startmtd)
		)
		and 
		c.CLI_CODE IN (
			select 
				tc.CLI_CODE
			from 
				[db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.teams_client as tc
			where 
				team_id = '15') 
			
--select * from #livecarebase
select 
        cc.ClientName,
        co.Country,
        count(distinct case when CaseStatus = 'O' then CASE_NO else null end) TotalActiveCases,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID  = '40' then CASE_NO else null end) ActiveChild,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID  = '27' then CASE_NO else null end) ActiveICU,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID  = '34' then CASE_NO else null end) ActiveRepatration,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID  = '33' then CASE_NO else null end) ActiveEVAC,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID  = '9' then CASE_NO else null end) ActiveDeath,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID = '41' then CASE_NO else null end) ActiveInpatient20K,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID = '43' then CASE_NO else null end) ActiveHighRisk200K,
		count(distinct case when CaseStatus = 'O' and RiskReason_ID = '44' then CASE_NO else null end) ActiveDental,
		count(distinct Case when CreatedToday = 1 then CASE_NO else null end) OpenedToday, 
		count(distinct Case when CreatedMTD = 1 then CASE_NO else null end) OpenedMTD,
		count(distinct Case when ClosedToday = 1 then CASE_NO else null end) CloseedToday, 
		count(distinct Case when ClosedMTD = 1 then CASE_NO else null end) ClosedMTD,
		count(distinct case when CaseStatus = 'O' and Protocol = 'Medical' then CASE_NO else null end) ActiveMedical,
		count(distinct case when CaseStatus = 'O' and Protocol = 'Technical' then CASE_NO else null end) ActiveTechnical,
		count(distinct case when CaseStatus = 'O' and RiskLevel = 'HighRisk' then CASE_NO else null end) ActiveHighRisk,
		count(distinct case when CaseStatus = 'O' and RiskLevel = 'MediumRisk' then CASE_NO else null end) ActiveMediumRisk,
		count(distinct case when CaseStatus = 'O' and RiskLevel = 'LowRisk' then CASE_NO else null end) ActiveLowRisk,
		count(distinct case when CaseStatus = 'O' and RiskLevel = 'VeryHighRisk' then CASE_NO else null end) ActiveVeryHighRisk,
		sum(case when CaseStatus = 'O' then NoOfPlan else 0 end) ActivePlan,
		sum(case when CaseStatus = 'O' and ACTION_AC = 'CM' then NoOfPlan else 0 end) ActivePlanCM,
		sum(case when CaseStatus = 'O' and ACTION_AC = 'RN' then NoOfPlan else 0 end) ActivePlanRN,
		sum(case when CaseStatus = 'O' and ACTION_AC = 'TL' then NoOfPlan else 0 end) ActivePlanTL,
		sum(case when CaseStatus = 'O' and TeamName = 'Covermore Group' then NoOfPlan else 0 end) ActivePlanCG,
		sum(case when CaseStatus = 'O' and TeamName = 'Inbound' then NoOfPlan else 0 end) ActivePlanIB,
		sum(case when CaseStatus = 'O' and TeamName = 'External' then NoOfPlan else 0 end) ActivePlanEX,
		count(distinct case when CaseStatus = 'O' and AgeOfCase between 0 and 7 then CASE_NO else null end) Active0To7,
		count(distinct case when CaseStatus = 'O' and AgeOfCase between 8 and 14 then CASE_NO else null end) Active8To14,
		count(distinct case when CaseStatus = 'O' and AgeOfCase between 15 and 30 then CASE_NO else null end) Active15To30,
		count(distinct case when CaseStatus = 'O' and AgeOfCase > 30 then CASE_NO else null end) ActiveOver30

    from    
        #livecarebase t
        outer apply
        (
            select top 1 
                cc.ClientName
            from
                cbCase cc
            where
                cc.ClientCode = t.ClientCode
        ) cc
        outer apply
        (
            select top 1 
                left(con.CountryName, len(con.CountryName) - 2) Country
            from
                cbAddress co
                cross apply
                (
                    select
                        replace(co.CountryName, '*RHA*', '') CountryName
                ) con
            where
                co.CountryCode = t.CountryCode
        ) co
group by
       cc.ClientName,
       co.Country

end
GO
