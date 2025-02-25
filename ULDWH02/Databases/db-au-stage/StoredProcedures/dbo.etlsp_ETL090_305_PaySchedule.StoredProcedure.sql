USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_305_PaySchedule]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-11-22
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_305_PaySchedule] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('tempdb..#src') is not null drop table #src 

    select 
		'CLI_SCH_' + ps.trx_ctrl_num ServiceEventActivityID,
		ps.debtor_code DebtorCode,
		ps.company_code CompanyCode,
		ps.posting_code PostingCode,
		psm.Schedule_Start_Date ScheduleStartDate,
		psm.Schedule_End_Date ScheduleEndDate 
	into #src 
	from 
		[db-au-stage]..dtc_cli_papaysch ps 
		left join [db-au-stage]..dtc_cli_papaysch_more psm on psm.trx_ctrl_num = ps.trx_ctrl_num 

	update tgt  
	set ScheduleStartDate = #src.ScheduleStartDate,
		ScheduleEndDate = #src.ScheduleEndDate,
		DebtorCode = #src.DebtorCode,
		CompanyCode = #src.CompanyCode,
		PostingCode = #src.PostingCode 
	from 
		[db-au-dtc]..pnpServiceEventActivity tgt 
		join #src on #src.ServiceEventActivityID = tgt.ServiceEventActivityID collate database_default

END
GO
