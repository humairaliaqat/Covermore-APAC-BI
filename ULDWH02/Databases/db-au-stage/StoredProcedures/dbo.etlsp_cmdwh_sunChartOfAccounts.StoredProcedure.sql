USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_sunChartOfAccounts]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_sunChartOfAccounts]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.sunChartOfAccounts') is null
begin
    create table [db-au-cmdwh].[dbo].sunChartOfAccounts
    (
        AccountKey [varchar](19) NOT NULL,
        BusinessUnit [varchar](3) NOT NULL,
        AccountCode [varchar](15) NOT NULL,
        UpdateCount [smallint] NOT NULL,
        LastChangeUserID [varchar](3) NOT NULL,
        LastChangeDateTime [datetime] NOT NULL,
        [Description] [varchar](50) NOT NULL,
        [ShortHeading] [varchar](15) NULL,
        LookupCode [varchar](15) NOT NULL,
        DataAccessGroupCode [varchar](5) NULL,
        AccountType [smallint] NOT NULL,
        BalanceType [smallint] NOT NULL,
        [Status] [smallint] NOT NULL,
        SuppressRevaluation [smallint] NOT NULL,
        LongDescription [varchar](255) NULL,
        ConversionCodeControl [smallint] NOT NULL,
        DefaultCurrencyCode [varchar](5) NULL,
        AllocationInProgress [smallint] NOT NULL,
        LinkAccountCode [varchar](15) NOT NULL,
        ReportConversionControl [smallint] NOT NULL,
        UserArea [varchar](30) NULL,
        CreditLimit [numeric](18, 0) NULL,
        EnterAnalysis1 [smallint] NOT NULL,
        EnterAnalysis2 [smallint] NOT NULL,
        EnterAnalysis3 [smallint] NOT NULL,
        EnterAnalysis4 [smallint] NOT NULL,
        EnterAnalysis5 [smallint] NOT NULL,
        EnterAnalysis6 [smallint] NOT NULL,
        EnterAnalysis7 [smallint] NOT NULL,
        EnterAnalysis8 [smallint] NOT NULL,
        EnterAnalysis9 [smallint] NOT NULL,
        EnterAnalysis10 [smallint] NOT NULL,
        OverdueInvoiceLimit [numeric](18, 0) NULL,
        CV4DefaultCurrencyCode [varchar](5) NULL,
        CV4ConversionCodeControl [smallint] NOT NULL,
        CV5DefaultCurrencyCode [varchar](5) NULL,
        CV5ConversionCodeControl [smallint] NOT NULL,
        BankCurrencyRequired [smallint] NOT NULL,
        AccountLinkAllowed [smallint] NOT NULL,
        PayAsPaidAccountType [smallint] NOT NULL
    )

    if exists(select name from sys.indexes where name = 'idx_sunChartOfAccounts_AccountKey')
    drop index idx_sunChartOfAccounts_AccountKey on sunChartOfAccounts.AccountKey

    if exists(select name from sys.indexes where name = 'idx_sunChartOfAccounts_BusinessUnit')
    drop index idx_sunChartOfAccounts_BusinessUnit on sunChartOfAccounts.BusinessUnit

    if exists(select name from sys.indexes where name = 'idx_sunChartOfAccounts_AccountCode')
    drop index idx_sunChartOfAccounts_AccountCode on sunChartOfAccounts.AccountCode

    if exists(select name from sys.indexes where name = 'idx_sunChartOfAccounts_DataAccessGroupCode')
    drop index idx_sunChartOfAccounts_DataAccessGroupCode on sunChartOfAccounts.DataAccessGroupCode

    create index idx_sunChartOfAccounts_AccountKey on [db-au-cmdwh].dbo.sunChartOfAccounts(AccountKey)
    create index idx_sunChartOfAccounts_BusinessUnit on [db-au-cmdwh].dbo.sunChartOfAccounts(BusinessUnit)
    create index idx_sunChartOfAccounts_AccountCode on [db-au-cmdwh].dbo.sunChartOfAccounts(AccountCode)
    create index idx_sunChartOfAccounts_DataAccessGroupCode on [db-au-cmdwh].dbo.sunChartOfAccounts(DataAccessGroupCode)
end
else
    truncate table [db-au-cmdwh].dbo.sunChartOfAccounts



--For each BCP command records, execute BCP until no more records
declare @SQL varchar(max)
declare @TableName varchar(100)
declare @BusinessUnit varchar(3)
declare CUR_Table cursor for select
                                TargetTableName as TableName,
                                substring(TargetTableName,5,3) as BusinessUnit
                             from [db-au-stage].dbo.etl_meta_data
                             where SourceDatabaseName = 'SUNDB' and right(TargetTableName,len(TargetTableName)-8) = 'ACNT_au'

open CUR_Table
fetch NEXT from CUR_Table into @TableName, @BusinessUnit

while @@FETCH_STATUS = 0
begin
    select @SQL = 'insert into [db-au-cmdwh].dbo.sunChartOfAccounts with(tablock)
                (AccountKey,BusinessUnit,AccountCode,UpdateCount,LastChangeUserID,LastChangeDateTime,[Description],
                [ShortHeading],LookupCode,DataAccessGroupCode,AccountType,BalanceType,[Status],SuppressRevaluation,
                LongDescription,ConversionCodeControl,DefaultCurrencyCode,AllocationInProgress,LinkAccountCode,ReportConversionControl,
                UserArea,CreditLimit,EnterAnalysis1,EnterAnalysis2,EnterAnalysis3,EnterAnalysis4,EnterAnalysis5,EnterAnalysis6,
                EnterAnalysis7,EnterAnalysis8,EnterAnalysis9,EnterAnalysis10,OverdueInvoiceLimit,CV4DefaultCurrencyCode,CV4ConversionCodeControl,
                CV5DefaultCurrencyCode,CV5ConversionCodeControl,BankCurrencyRequired,AccountLinkAllowed,PayAsPaidAccountType)
                select ''' + @BusinessUnit + '-'' + ACNT_CODE as AccountKey, ''' + @BusinessUnit + ''' as BusinessUnit, ACNT_CODE,UPDATE_COUNT,LAST_CHANGE_USER_ID,LAST_CHANGE_DATETIME,DESCR,S_HEAD,LOOKUP,DAG_CODE,ACNT_TYPE,BAL_TYPE,
                    STATUS,SUPPRESS_REVAL,LONG_DESCR,CONV_CODE_CTRL,DFLT_CURR_CODE,ALLOCN_IN_PROGRESS,LINK_ACNT,RPT_CONV_CTRL,USER_AREA,
                    CR_LIMIT,ENTER_ANL_1,ENTER_ANL_2,ENTER_ANL_3,ENTER_ANL_4,ENTER_ANL_5,ENTER_ANL_6,ENTER_ANL_7,ENTER_ANL_8,ENTER_ANL_9,
                    ENTER_ANL_10,OIL,CV4_DFLT_CURR_CODE,CV4_CONV_CODE_CTRL,CV5_DFLT_CURR_CODE,CV5_CONV_CODE_CTRL,BANK_CURR_REQD,
                    ACNT_LINKS_ALLOWED,PASP_ACNT_TYPE
                from [db-au-stage].dbo.' + @TableName
    execute(@SQL)
    fetch NEXT from Cur_Table into @TableName, @BusinessUnit
end

close CUR_Table
deallocate CUR_Table

GO
