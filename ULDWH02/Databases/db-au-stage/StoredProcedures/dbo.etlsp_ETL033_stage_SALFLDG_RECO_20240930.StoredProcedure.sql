USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_SALFLDG_RECO_20240930]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
CREATE procedure [dbo].[etlsp_ETL033_stage_SALFLDG_RECO_20240930]                
as                
begin                
/************************************************************************************************************************************                
Author:         Leo                
Date:           20160429                
Prerequisite:   etlsp_ETL033_stage_Excel had been successfully run to load the server meta data.                
                linked servers for source(s) are available.                
Description:    stage GL main tables                
Change History:                
                20160429 - LL - created                
                20160511 - LL - optimize                
                20160623 - LL - remove transaction, it's not reuired for staging                
                                cursor block inside transaction locks up everything due to batch logging calls            
    20220814 - SS - Add collation for SUNGL migration            
                    
*************************************************************************************************************************************/                
                
    set nocount on                
                
    declare                
        @batchid int,                
        @start date,                
        @end date,                
        @SunStart int,                
        @SunEnd int,                
        @name varchar(50),                
        @subname varchar(50),                
        @sourcecount int,                
        @insertcount int,                
        @updatecount int,                
        @paramBusinessUnit varchar(max),                
        @paramScenario varchar(max)                
                
    declare @businessunits table (BU varchar(10))                
    declare @scenarios table (Scenario varchar(10))                
    declare @mergeoutput table (MergeAction varchar(20))                
                
    --exec syssp_getrunningbatch                
    --    @SubjectArea = 'SUN GL',                
    --    @BatchID = @batchid out,                
    --    @StartDate = @start out,                
    --    @EndDate = @end out                
                
            
select         
    --start and end of FY        
    --@start = min(CurFiscalYearStart),        
    @start = min(LYFiscalYearStart),      
    @end =  max(CurFiscalYear)        
from        
    [db-au-cmdwh]..Calendar        
where        
    [Date] = convert(date, '2024-07-31') or        
    (        
        datepart(mm, '2024-07-31') = 7 and        
        [Date] = convert(date, dateadd(month, -1, '2024-07-31'))        
    )        
        
        
    --select Top 2 @batchid = Batch_ID,          
    --@start = Batch_Date,          
    --@end = Batch_To_Date          
    --from [db-au-log]..Batch_Run_Status where Subject_Area like 'SUN GL' and convert(varchar(20),Batch_Start_Time,23) = convert(varchar(20),getdate(),23) order by Batch_ID           
              
    --if @batchid = -1                
    --    raiserror('prevent running without batch', 15, 1) with nowait                
                
    select                
        @name = object_name(@@procid)                
                
    --exec syssp_genericerrorhandler                
    --    @LogToTable = 1,                
    --    @ErrorCode = '0',                
    --    @BatchID = @batchid,                
    --    @PackageID = @name,                
    --    @LogStatus = 'Running'                
                
    --get SUN periods                
    select top 1                
        @SunStart = SUNPeriod                
    from                
        [db-au-cmdwh]..Calendar                
    where                
        [Date] = @start                
                
    select top 1                
        @SunEnd = SUNPeriod                
    from                
        [db-au-cmdwh]..Calendar                
   where                
        [Date] = @end                
                
    --get paramaters                
    select                 
        @paramBusinessUnit =   '*',             
      --max(                
            --    case                
            --        when Package_ID = '[PARAMETER_BUSINESSUNIT]' then Package_Status                
            --        else null                
        --    end                
            --),                
        @paramScenario =   '*'             
            --max(                
            --    case                
            --        when Package_ID = '[PARAMETER_SCENARIO]' then Package_Status         
            --        else null                
            --    end                
            --)                
    from                
        [DB-AU-LOG]..Package_Run_Details                
    --where                
    --    Batch_ID = @batchid and                
    --    Package_ID in ('[PARAMETER_BUSINESSUNIT]', '[PARAMETER_SCENARIO]')                
                
    --parse parameters                
    insert into @businessunits (BU)                
    select distinct                
        rtrim(ltrim(Item))                
    from                
        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@paramBusinessUnit, ',')                
                
   insert into @scenarios (Scenario)                
    select distinct                
        rtrim(ltrim(Item))                
    from                
        [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@paramScenario, ',')                
                
    if object_id('sungl_SALFLDG_reco_20240926') is null                
    begin                
                
        create table sungl_SALFLDG_reco_20240926                
        (                
            BIRowID bigint identity(1,1) not null,                
            BusinessUnit varchar(50),                
            ScenarioCode varchar(50),                
            ACCNT_CODE varchar(50),                
            PERIOD int,                
            TRANS_DATETIME datetime,                
            JRNAL_NO int,                
            JRNAL_LINE int,                
            AMOUNT numeric(18, 3),                
            D_C varchar(50),                
            ALLOCATION varchar(50),                
            JRNAL_TYPE varchar(50),                
            JRNAL_SRCE varchar(50),                
            TREFERENCE varchar(50),                
            DESCRIPTN varchar(50),                
            ENTRY_DATETIME datetime,                
            ENTRY_PRD int,                
            DUE_DATETIME datetime,                
            ALLOC_REF int,                
            ALLOC_DATETIME datetime,                
            ALLOC_PERIOD int,                
            ASSET_IND varchar(50),                
            ASSET_CODE varchar(50),                
            ASSET_SUB varchar(50),                
            CONV_CODE varchar(50),                
            CONV_RATE numeric(18, 9),                
            OTHER_AMT numeric(18, 3),                
            OTHER_DP varchar(50),                
            CLEARDOWN varchar(50),                
            REVERSAL varchar(50),                
            LOSS_GAIN varchar(50),                
            ROUGH_FLAG varchar(50),                
            IN_USE_FLAG varchar(50),                
            ANAL_T0 varchar(50),                
            ANAL_T1 varchar(50),                
            ANAL_T2 varchar(50),                
            ANAL_T3 varchar(50),                
            ANAL_T4 varchar(50),                
            ANAL_T5 varchar(50),                
            ANAL_T6 varchar(50),                
            ANAL_T7 varchar(50),                
            ANAL_T8 varchar(50),                
            ANAL_T9 varchar(50),                
            POSTING_DATETIME datetime,                
            ALLOC_IN_PROGRESS varchar(50),                
            HOLD_REF int,                
            HOLD_OP_ID varchar(50),                
            BASE_RATE numeric(18, 9),                
            BASE_OPERATOR varchar(50),                
            CONV_OPERATOR varchar(50),                
            REPORT_RATE numeric(18, 9),                
            REPORT_OPERATOR varchar(50),                
            REPORT_AMT numeric(18, 3),                
            MEMO_AMT numeric(18, 5),                
            EXCLUDE_BAL varchar(50),                
            LE_DETAILS_IND varchar(50),                
            CONSUMED_BDGT_ID int,                
            CV4_CONV_CODE varchar(50),                
            CV4_AMT numeric(18, 3),                
            CV4_CONV_RATE numeric(18, 9),                
            CV4_OPERATOR varchar(50),                
            CV4_DP varchar(50),                
            CV5_CONV_CODE varchar(50),                
            CV5_AMT numeric(18, 3),                
            CV5_CONV_RATE numeric(18, 9),                
            CV5_OPERATOR varchar(50),                
            CV5_DP varchar(50),                
            LINK_REF_1 varchar(50),                
            LINK_REF_2 varchar(50),                
            LINK_REF_3 varchar(50),                
            ALLOCN_CODE varchar(50),                
            ALLOCN_STMNTS int,                
            OPR_CODE varchar(50),                
            SPLIT_ORIG_LINE int,                
            VAL_DATETIME datetime,                
            SIGNING_DETAILS varchar(50),                
            INSTLMT_DATETIME datetime,                
            PRINCIPAL_REQD int,                
            BINDER_STATUS varchar(50),                
            AGREED_STATUS int,                
            SPLIT_LINK_REF varchar(50),                
            PSTG_REF varchar(50),                
            TRUE_RATED int,                
            HOLD_DATETIME datetime,                
            HOLD_TEXT varchar(50),                
            INSTLMT_NUM int,                
            SUPPLMNTRY_EXTSN int,                
            APRVLS_EXTSN int,                
            REVAL_LINK_REF int,                
            SAVED_SET_NUM numeric(18, 0),                
            AUTHORISTN_SET_REF int,                
            PYMT_AUTHORISTN_SET_REF int,                
            MAN_PAY_OVER int,                
            PYMT_STAMP varchar(50),                
            AUTHORISTN_IN_PROGRESS int,                
            SPLIT_IN_PROGRESS int,                
            VCHR_NUM varchar(50),                
            JNL_CLASS_CODE varchar(50),                
            ORIGINATOR_ID varchar(50),                
            ORIGINATED_DATETIME datetime,                
            LAST_CHANGE_USER_ID varchar(50),                
            LAST_CHANGE_DATETIME datetime,                
            AFTER_PSTG_ID varchar(50),                
 AFTER_PSTG_DATETIME datetime,                
            POSTER_ID varchar(50),                
            ALLOC_ID varchar(50),                
            JNL_REVERSAL_TYPE int                
        )                
                
        create clustered index cidx on sungl_SALFLDG_reco_20240926 (BIRowID)                
        --create index idx on sungl_SALFLDG (BusinessUnit,ScenarioCode,JRNAL_NO,JRNAL_LINE)                
                
    end                
                
    declare                
        @sql varchar(max),                
        @bu varchar(5),                
        @server varchar(64),                
        @database varchar(64),                
        @table varchar(64)                
                
    declare                
        c_meta_SALFLDG cursor local for                
            select                 
                BusinessUnit,                
                ServerName,                
                DatabaseName,            
                TableName                
            from                
                sungl_excel_meta                
            where                
                TableType = 'SALFLDG' and                
                (                
                    isnull(@paramBusinessUnit, '*') like '%*%' or                
                    BusinessUnit in (select BU Collate Database_Default from @businessunits)               
                ) and                
                (                
                    isnull(@paramScenario, '*') like '%*%' or                
                    substring(TableName, 5, 1) in (select Scenario Collate Database_Default from @scenarios)                
                )                
                
    truncate table sungl_SALFLDG_reco_20240926                
                
    open c_meta_SALFLDG                
                
    fetch next from c_meta_SALFLDG into                 
        @bu,                
        @server,                
        @database,                
        @table                
                
    while @@fetch_status = 0                 
    begin                
                
        set @subname = @name + '_' + @bu + '_' + substring(@table, 5, 1)                
                
        --exec syssp_genericerrorhandler                
        --    @LogToTable = 1,                
        --    @ErrorCode = '0',                
        --    @BatchID = @batchid,                
        --    @PackageID = @subname,                
        --    @LogStatus = 'Running'                
                
        set @sql =                
            '                
            select                
                ''' + @bu + ''',                
                ''' + substring(@table, 5, 1) + ''',                
                ACCNT_CODE,                
                PERIOD,             
                TRANS_DATETIME,                
                JRNAL_NO,                
                JRNAL_LINE,                
                AMOUNT,                
                D_C,                
                ALLOCATION,                
                JRNAL_TYPE,                
                JRNAL_SRCE,                
                TREFERENCE,                
                DESCRIPTN,                
                ENTRY_DATETIME,                
                ENTRY_PRD,                
                DUE_DATETIME,                
                ALLOC_REF,                
                ALLOC_DATETIME,                
                ALLOC_PERIOD,                
                ASSET_IND,                
                ASSET_CODE,                
                ASSET_SUB,                
                CONV_CODE,                
                CONV_RATE,                
                OTHER_AMT,                
                OTHER_DP,                
                CLEARDOWN,                
                REVERSAL,                
                LOSS_GAIN,                
                ROUGH_FLAG,                        IN_USE_FLAG,                
                ANAL_T0,                
                ANAL_T1,                
                ANAL_T2,                
                ANAL_T3,                
                ANAL_T4,                
                ANAL_T5,                
                ANAL_T6,                
                ANAL_T7,                
                ANAL_T8,                
                ANAL_T9,                
                POSTING_DATETIME,                
                ALLOC_IN_PROGRESS,                
                HOLD_REF,                
                HOLD_OP_ID,                
                BASE_RATE,                
                BASE_OPERATOR,                
                CONV_OPERATOR,                
                REPORT_RATE,                
                REPORT_OPERATOR,                
                REPORT_AMT,                
                MEMO_AMT,                
                EXCLUDE_BAL,                
                LE_DETAILS_IND,                
                CONSUMED_BDGT_ID,                
                CV4_CONV_CODE,                
                CV4_AMT,                
                CV4_CONV_RATE,                
                CV4_OPERATOR,                
                CV4_DP,                
                CV5_CONV_CODE,                
                CV5_AMT,                
                CV5_CONV_RATE,                
                CV5_OPERATOR,                
                CV5_DP,                
                LINK_REF_1,                
                LINK_REF_2,                
                LINK_REF_3,                
                ALLOCN_CODE,                
                ALLOCN_STMNTS,                
                OPR_CODE,                
                SPLIT_ORIG_LINE,                
                VAL_DATETIME,                
                SIGNING_DETAILS,                
                INSTLMT_DATETIME,                
                PRINCIPAL_REQD,                
                BINDER_STATUS,                
                AGREED_STATUS,                
                SPLIT_LINK_REF,                
                PSTG_REF,                
                TRUE_RATED,                
              HOLD_DATETIME,                
                HOLD_TEXT,                
                INSTLMT_NUM,                
                SUPPLMNTRY_EXTSN,                
                APRVLS_EXTSN,                
                REVAL_LINK_REF,                
                SAVED_SET_NUM,                
          AUTHORISTN_SET_REF,                
                PYMT_AUTHORISTN_SET_REF,                
                MAN_PAY_OVER,                
                PYMT_STAMP,                
                AUTHORISTN_IN_PROGRESS,                
                SPLIT_IN_PROGRESS,                
                VCHR_NUM,                
                JNL_CLASS_CODE,                
                ORIGINATOR_ID,                
                ORIGINATED_DATETIME,                
                LAST_CHANGE_USER_ID,                
                LAST_CHANGE_DATETIME,                
                AFTER_PSTG_ID,                
                AFTER_PSTG_DATETIME,                
                POSTER_ID,                
                ALLOC_ID,                
               JNL_REVERSAL_TYPE                
            from                 
                ' +                
            @server + '.' + @database + '.dbo.' + @table + ' with(nolock)                 
            where                
                PERIOD between ' + convert(varchar(10), @SunStart) + ' and ' + convert(varchar(10), @SunEnd)                
                
                
                
        print @sql                
        insert into sungl_SALFLDG_reco_20240926 with(tablock)                
        (                
            BusinessUnit,                
            ScenarioCode,                
            ACCNT_CODE,                
            PERIOD,                
            TRANS_DATETIME,                
            JRNAL_NO,                
            JRNAL_LINE,                
            AMOUNT,                
            D_C,                
            ALLOCATION,                
            JRNAL_TYPE,                
            JRNAL_SRCE,                
            TREFERENCE,                
            DESCRIPTN,                
            ENTRY_DATETIME,                
            ENTRY_PRD,                
            DUE_DATETIME,                
            ALLOC_REF,                
            ALLOC_DATETIME,                
            ALLOC_PERIOD,                
            ASSET_IND,                
            ASSET_CODE,                
            ASSET_SUB,                
            CONV_CODE,                
            CONV_RATE,                
            OTHER_AMT,                
            OTHER_DP,                
           CLEARDOWN,                
            REVERSAL,               
            LOSS_GAIN,                
            ROUGH_FLAG,                
            IN_USE_FLAG,                
            ANAL_T0,                
            ANAL_T1,                
            ANAL_T2,                
            ANAL_T3,                
            ANAL_T4,                
            ANAL_T5,                
            ANAL_T6,                
            ANAL_T7,                
            ANAL_T8,                
            ANAL_T9,                
            POSTING_DATETIME,                
            ALLOC_IN_PROGRESS,                
            HOLD_REF,                
            HOLD_OP_ID,                
            BASE_RATE,                
            BASE_OPERATOR,                
            CONV_OPERATOR,                
            REPORT_RATE,                
            REPORT_OPERATOR,                
            REPORT_AMT,                
            MEMO_AMT,                
           EXCLUDE_BAL,                
            LE_DETAILS_IND,                
            CONSUMED_BDGT_ID,                
            CV4_CONV_CODE,                
            CV4_AMT,                
            CV4_CONV_RATE,                
            CV4_OPERATOR,                
            CV4_DP,                
            CV5_CONV_CODE,                
            CV5_AMT,                
            CV5_CONV_RATE,                
            CV5_OPERATOR,                
            CV5_DP,                
            LINK_REF_1,                
            LINK_REF_2,                
            LINK_REF_3,                
            ALLOCN_CODE,                
            ALLOCN_STMNTS,                
            OPR_CODE,                
            SPLIT_ORIG_LINE,                
            VAL_DATETIME,                
            SIGNING_DETAILS,                
            INSTLMT_DATETIME,                
            PRINCIPAL_REQD,                
            BINDER_STATUS,                
            AGREED_STATUS,                
            SPLIT_LINK_REF,                
            PSTG_REF,                
            TRUE_RATED,                
            HOLD_DATETIME,                
            HOLD_TEXT,                
            INSTLMT_NUM,                
            SUPPLMNTRY_EXTSN,                
            APRVLS_EXTSN,                
            REVAL_LINK_REF,                
            SAVED_SET_NUM,                
            AUTHORISTN_SET_REF,                
            PYMT_AUTHORISTN_SET_REF,                
            MAN_PAY_OVER,                
            PYMT_STAMP,                
            AUTHORISTN_IN_PROGRESS,                
            SPLIT_IN_PROGRESS,                
            VCHR_NUM,                
            JNL_CLASS_CODE,                
            ORIGINATOR_ID,                
            ORIGINATED_DATETIME,                
            LAST_CHANGE_USER_ID,                
            LAST_CHANGE_DATETIME,                
            AFTER_PSTG_ID,                
            AFTER_PSTG_DATETIME,                
            POSTER_ID,                
            ALLOC_ID,                
            JNL_REVERSAL_TYPE                
        )                
        exec(@sql)                
                
        --exec syssp_genericerrorhandler                
        --    @LogToTable = 1,                
        --    @ErrorCode = '0',                
        --    @BatchID = @batchid,                
        --    @PackageID = @subname,                
        --    @LogSourceCount = @@rowcount,                
        --    @LogStatus = 'Finished'                
                
        fetch next from c_meta_SALFLDG into                 
            @bu,                
            @server,                
            @database,                
            @table                
                
    end                
                
    close c_meta_SALFLDG                
    deallocate c_meta_SALFLDG                
                
    --exec syssp_genericerrorhandler                
    --    @LogToTable = 1,                
    --    @ErrorCode = '0',                
    --    @BatchID = @batchid,                
    --    @PackageID = @name,                
    --    @LogStatus = 'Finished'                
                
                
end 
GO
