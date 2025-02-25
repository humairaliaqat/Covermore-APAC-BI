USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_BigQueryQuote_Merge]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--create 
CREATE procedure [dbo].[etlsp_ETL054_BigQueryQuote_Merge]
as
begin
/************************************************************************************************************************************
Author:         Ratnesh
Date:           20180420
Description:    merge quote data to BigQuery's tables
Parameters:     
Change History:
                20180420 - RS - create

*************************************************************************************************************************************/
    declare @cmdexecresult integer
    set nocount on

	--	declare @execution_status integer
	execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\bq.cmd" query --destination_table=cmdwh_bq_prod.penguin_quote --replace --allow_large_results --use_legacy_sql=false select * from cmdwh_bq_prod.penguin_quote where quotekey not in (select quotekey from cmdwh_bq_prod.staging_penquote) union all select * from cmdwh_bq_prod.staging_penquote'
	if @cmdexecresult <> 0 
     raiserror('Error occurred during penguin data merging.',20,-1) with log
	else
	 print('Penguin data merging is successfully complete.')

--	declare @execution_status integer
    /*********************************** IMPORTANT DEBUGGING TIPS*****************************************************************/
	--DEBUGGING TIP -- Convert double quotes to single quotes from the below query when executing on bigquery prompt for debugging.
	--DISBALBE LEGACY SQL else the query will not run.
	/***************************************IMPORTANT DEBUGGING TIPS*************************************************************/
	execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\bq.cmd" query --destination_table=cmdwh_bq_prod.innate_quote --replace --allow_large_results --use_legacy_sql=false select * from cmdwh_bq_prod.innate_quote where concat(cast(analyticssessionid as string),''-'',cast(platformversion as string)) not in (select concat(cast(analyticssessionid as string),''-'',cast(platformversion as string)) from cmdwh_bq_prod.staging_cdgquote) union all select * from cmdwh_bq_prod.staging_cdgquote  where isDeleted = 0'
	if @cmdexecresult <> 0 
     raiserror('Error occurred during innage cdg data merging.',20,-1) with log
	else
	 print('Innate data merging is successfully complete.')


end


GO
