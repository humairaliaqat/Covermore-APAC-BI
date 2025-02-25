USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_dashboard_livecarebase]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_dashboard_livecarebase]
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
        c.STATUS,
        c.CASETYPE_ID,
        c.CLI_CODE collate database_default ClientCode,
        c.RISKLEVEL_ID,
        it.IncidentType,
		c.CREATED_DT,		
		c.RiskReason_ID,	
		rs.Description as RiskReason,	
        case
            when c.CREATED_DT >= @starttoday then 1
            else 0
        end CreatedToday,
		case
            when c.CREATED_DT >= @startmtd then 1
            else 0
        end CreatedMTD,
        con.CNTRY_CODE collate database_default CountryCode
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
    where
       ((c.DELETED <> 'Y' 
		and c.CREATED_DT >= '2014-07-01' 
		and c.CREATED_DT < @startmtd
		and c.STATUS = 'O'
		)
		
		or
		(c.DELETED <> 'Y' and c.CREATED_DT >= @startmtd)
		)
		and 
		c.CLI_CODE IN (
			select 
				tc.CLI_CODE
			from 
				[db-au-penguinsharp.aust.covermore.com.au].Carebase.dbo.teams_client as tc
			where 
				team_id = '15') 
			
/*--Add this for Medical or Technical 
	        case
            when PROB_TYPE = 'M' then 'Medical'
            when PROB_TYPE = 'T' then 'Technical'
            else 'Undefined'
        end Protocol,

*/
    select 
        cc.ClientName,
        co.Country,
        sum(case when STATUS = 'O' then 1 else 0 end) TotalActiveCases,
		sum(case when STATUS = 'O' and RiskReason = 'Medical Case: CHILD UNDER 5YRS - IN OR OUTPATIENT' then 1 else 0 end) ActiveChild,
		sum(case when STATUS = 'O' and RiskReason = 'Medical Case: ICU/CCU/HDU ' then 1 else 0 end) ActiveICU,
		sum(case when STATUS = 'O' and RiskReason = 'Medical Case: REPATRIATION ' then 1 else 0 end) ActiveRepatration,
		sum(case when STATUS = 'O' and RiskReason = 'Medical Case: URGENT EVACUATION ' then 1 else 0 end) ActiveEVAC,
		sum(case when STATUS = 'O' and RiskReason = 'Medical Case: DEATH' then 1 else 0 end) ActiveDeath,
		sum(case when CreatedToday = 1 and RiskReason = 'Medical Case: DEATH' and STATUS = 'O' then 1 else 0 end) ActiveDeathToday, 
		sum(Case when CreatedToday = 1 then 1 else 0 end) OpenedToday, 
		sum(Case when CreatedMTD = 1 then 1 else 0 end) OpenedMTD
      
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

--select * from #livecarebase where CountryCode = '300'

--select top 100  CountryCode, * from cbAddress where CountryName like '%UNITED KIN%'

--select * from cbAddress WHERE CountryCode = '309'
GO
