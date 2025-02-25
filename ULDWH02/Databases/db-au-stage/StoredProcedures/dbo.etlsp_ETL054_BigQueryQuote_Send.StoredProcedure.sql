USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_BigQueryQuote_Send]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE 
CREATE
procedure [dbo].[etlsp_ETL054_BigQueryQuote_Send]
as
begin
/************************************************************************************************************************************
Author:         Ratnesh
Date:           20180416
Description:    Without compressing send quote data to GCP Storage bucket
Parameters:
Change History:
                20180416 - RS - create


*************************************************************************************************************************************/
 declare @cmdexecresult integer
    set nocount on
	
    --delete existing zips
    --execute master..xp_cmdshell 'del e:\etl\data\bigquery\out\*.gz'

	--execute master..xp_cmdshell 'whoami'
	
    --zip
    --execute master..xp_cmdshell '"e:\etl\tool\7z.exe" a -tgzip e:\etl\data\bigquery\out\cdgQuote.csv.gz e:\etl\data\bigquery\out\cdgQuote.csv'
    --execute master..xp_cmdshell '"e:\etl\tool\7z.exe" a -tgzip e:\etl\data\bigquery\out\penQuote.csv.gz e:\etl\data\bigquery\out\penQuote.csv'
	
    --delete files from GCP bucket if exists
    --execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil.cmd" rm gs://cmbi-au/prod/in/cdgQuote.csv'
	--execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil.cmd" rm gs://cmbi-au/prod/in/penQuote.csv'
	
    --upload(replace if exist) files on GCP
    execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil.cmd" -o GSUtil:parallel_composite_upload_threshold=250M cp e:\etl\data\bigquery\out\penQuote.csv gs://cmbi-au/prod/in/'
	if @cmdexecresult <> 0 
     raiserror('Error occurred during penguin file upload.',20,-1) with log
	else
	 print('Penguin file uploaded successfully.')

	execute @cmdexecresult = master..xp_cmdshell '"C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gsutil.cmd" -o GSUtil:parallel_composite_upload_threshold=250M cp e:\etl\data\bigquery\out\cdgQuote.csv gs://cmbi-au/prod/in/'
	if @cmdexecresult <> 0 
     raiserror('Error occurred during cdgQuote file upload.',20,-1) with log
    else
	 print('cdg file uploaded successfully.')

end



GO
