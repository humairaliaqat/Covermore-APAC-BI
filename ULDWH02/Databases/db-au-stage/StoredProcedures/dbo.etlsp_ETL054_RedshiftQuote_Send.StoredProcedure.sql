USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Send]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL054_RedshiftQuote_Send]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    compress and send quote data to S3
Parameters:
Change History:
                20160201 - LS - create
                20170421 - LS - update 7z path

*************************************************************************************************************************************/

    set nocount on

    --delete existing zips
    execute master..xp_cmdshell 'del e:\etl\data\redshift\out\*.gz'

    --zip
    execute master..xp_cmdshell '"e:\etl\tool\7z.exe" a -tgzip e:\etl\data\redshift\out\cdgQuote.csv.gz e:\etl\data\redshift\out\cdgQuote.csv'
    execute master..xp_cmdshell '"e:\etl\tool\7z.exe" a -tgzip e:\etl\data\redshift\out\penQuote.csv.gz e:\etl\data\redshift\out\penQuote.csv'

    --delete s3 files if exists
    execute master..xp_cmdshell '"c:\program files\amazon\awscli\aws.exe" s3 rm s3://bi-redshift-bucket/prod/in/cdgQuote.csv.gz'
    execute master..xp_cmdshell '"c:\program files\amazon\awscli\aws.exe" s3 rm s3://bi-redshift-bucket/prod/in/penQuote.csv.gz'

    --copy zip files to s3
    execute master..xp_cmdshell '"c:\program files\amazon\awscli\aws.exe" s3 cp \\uldwh02\e$\etl\data\redshift\out\cdgQuote.csv.gz s3://bi-redshift-bucket/prod/in/'
    execute master..xp_cmdshell '"c:\program files\amazon\awscli\aws.exe" s3 cp \\uldwh02\e$\etl\data\redshift\out\penQuote.csv.gz s3://bi-redshift-bucket/prod/in/'

end

GO
