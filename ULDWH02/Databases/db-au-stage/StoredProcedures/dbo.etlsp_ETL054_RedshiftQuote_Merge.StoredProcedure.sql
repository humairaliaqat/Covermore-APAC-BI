USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Merge]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL054_RedshiftQuote_Merge]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    merge quote data to RedShift's tables
Parameters:     
Change History:
                20160201 - LS - create

*************************************************************************************************************************************/

    set nocount on

    execute
    (
    '
    delete from innate_quote
    using staging_cdgquote
    where 
        innate_quote.analyticssessionid = staging_cdgquote.analyticssessionid and
        innate_quote.PlatformVersion = staging_cdgquote.PlatformVersion
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    insert into innate_quote
    select * 
    from 
        staging_cdgquote 
    where 
        isDeleted = 0
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    delete from penguin_quote
    using staging_penquote
    where 
        penguin_quote.quotekey = staging_penquote.quotekey
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    insert into penguin_quote
    select * 
    from 
        staging_penquote 
    '
    ) at [CMDWH-REDSHIFT-PROD]

end
GO
