USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_GLTransaction]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
  
  
  
  
  
  
CREATE procedure [dbo].[etlsp_ETL033_ODS_GLTransaction]  
as  
begin  
/************************************************************************************************************************************  
Author:         Leo  
Date:           20160510  
Prerequisite:     
Description:    load transaction table  
Change History:  
                20160510 - LL - created  
    20210303 - HL - Adding code to load new dimension CCA Teams as per INC0189611  
                2022124  - AH - Ading code to update department code in GLtransaction table based on mappinh file provided by Finance  
      
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
  
    exec syssp_getrunningbatch  
        @SubjectArea = 'SUN GL',  
        @BatchID = @batchid out,  
        @StartDate = @start out,  
        @EndDate = @end out  
  
    if @batchid = -1  
        raiserror('prevent running without batch', 15, 1) with nowait  
  
    select  
        @name = object_name(@@procid)  
  
    exec syssp_genericerrorhandler  
        @LogToTable = 1,  
        @ErrorCode = '0',  
        @BatchID = @batchid,  
        @PackageID = @name,  
        @LogStatus = 'Running'  
  
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
        @paramBusinessUnit =  
            min(  
                case  
                    when Package_ID = '[PARAMETER_BUSINESSUNIT]' then Package_Status  
                    else null  
                end  
            ),  
        @paramScenario =  
            min(  
                case  
                    when Package_ID = '[PARAMETER_SCENARIO]' then Package_Status  
                    else null  
                end  
            )  
    from  
        [DB-AU-LOG]..Package_Run_Details  
    where  
        Batch_ID = @batchid and  
        Package_ID in ('[PARAMETER_BUSINESSUNIT]', '[PARAMETER_SCENARIO]')  
  
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
  
  
    if object_id('[db-au-cmdwh]..glTransactions') is null  
    begin  
  
        create table [db-au-cmdwh]..glTransactions  
        (  
            BIRowID bigint identity(1,1) not null,  
         BusinessUnit varchar(50),  
         ScenarioCode varchar(50),  
         AccountCode varchar(50),  
         Period int,  
         JournalNo int,  
         JournalLine int,  
         JournalType varchar(50),  
         JournalSource varchar(50),  
         TransactionDate date,  
         EntryDate date,  
         DueDate date,  
         PostingDate date,  
         OriginatedDate date,  
         AfterPostingDate date,  
         BaseRate numeric(18,9),  
         ConversionRate numeric(18,9),  
         ReversalFlag varchar(50),  
         GLAmount numeric(18,3),  
         OtherAmount numeric(18,3),  
         ReportAmount numeric(18,3),  
         DebitCreditFlag varchar(50),  
         AllocationFlag varchar(50),  
         TransactionReference varchar(50),  
         Description varchar(50),  
         ChannelCode varchar(50),  
         DepartmentCode varchar(50),  
         ProductCode varchar(50),  
         BDMCode varchar(50),  
         ProjectCode varchar(50),  
         StateCode varchar(50),  
         ClientCode varchar(50),  
         SourceCode varchar(50),  
         JointVentureCode varchar(50),  
         GSTCode varchar(50),  
         CaseNumber varchar(50),  
            CreateBatchID int,  
   CCATeamsCode varchar(50)  
  
        )  
  
        create clustered index cidx on [db-au-cmdwh]..glTransactions (BIRowID)  
        create index period on [db-au-cmdwh]..glTransactions (Period,BusinessUnit,ScenarioCode) include(AccountCode,JointVentureCode,ClientCode,SourceCode,DepartmentCode,GLAmount)  
        create index account on [db-au-cmdwh]..glTransactions (AccountCode) include (Period,BusinessUnit,ScenarioCode,GLAmount,ChannelCode,DepartmentCode,ProductCode,ProjectCode,StateCode,ClientCode,SourceCode,JointVentureCode,GSTCode)  
  
    end  
  
    begin transaction  
      
    begin try  
  
        delete   
        from  
            [db-au-cmdwh]..glTransactions  
        where  
            Period between @SunStart and @SunEnd and  
            (  
                isnull(@paramBusinessUnit, '*') like '%*%' or  
                BusinessUnit in (select BU from @businessunits)   
            ) and  
            (  
                isnull(@paramScenario, '*') like '%*%' or  
                ScenarioCode in (select Scenario from @scenarios)  
            )  
  
        insert into [db-au-cmdwh]..glTransactions with(tablock)  
        (  
         BusinessUnit,  
         ScenarioCode,  
         AccountCode,  
         Period,  
         JournalNo,  
         JournalLine,  
         JournalType,  
         JournalSource,  
         TransactionDate,  
         EntryDate,  
         DueDate,  
         PostingDate,  
         OriginatedDate,  
         AfterPostingDate,  
         BaseRate,  
         ConversionRate,  
         ReversalFlag,  
         GLAmount,  
         OtherAmount,  
         ReportAmount,  
         DebitCreditFlag,  
         AllocationFlag,  
         TransactionReference,  
         Description,  
         ChannelCode,  
         DepartmentCode,  
         ProductCode,  
         BDMCode,  
         ProjectCode,  
         StateCode,  
         ClientCode,  
         SourceCode,  
         JointVentureCode,  
         GSTCode,  
         CaseNumber,  
            CreateBatchID,  
   CCATeamsCode  
        )  
        select   
            BusinessUnit,  
            ScenarioCode,  
            ACCNT_CODE AccountCode,  
            PERIOD Period,  
            JRNAL_NO JournalNo,  
            JRNAL_LINE JournalLine,  
            JRNAL_TYPE JournalType,  
            JRNAL_SRCE JournalSource,  
            convert(date, TRANS_DATETIME) TransactionDate,  
            convert(date, ENTRY_DATETIME) EntryDate,  
            convert(date, DUE_DATETIME) DueDate,  
            convert(date, POSTING_DATETIME) PostingDate,  
            convert(date, ORIGINATED_DATETIME) OriginatedDate,  
            convert(date, AFTER_PSTG_DATETIME) AfterPostingDate,  
            BASE_RATE BaseRate,  
            CONV_RATE ConversionRate,  
            REVERSAL ReversalFlag,  
            AMOUNT GLAmount,  
            OTHER_AMT OtherAmount,  
            REPORT_AMT ReportAmount,  
            D_C DebitCreditFlag,  
            ALLOCATION AllocationFlag,  
            TREFERENCE TransactionReference,  
            DESCRIPTN Description,  
            case ChannelIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end ChannelCode,  
            case DepartmentIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end DepartmentCode,  
            case ProductIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end ProductCode,  
            case BDMIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end BDMCode,  
            case ProjectIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end ProjectCode,  
            case StateIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end StateCode,  
            case ClientIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end ClientCode,  
            case SourceIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end SourceCode,  
            case JVIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end JointVentureCode,  
            case GSTIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end GSTCode,  
            case CaseIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end CaseNumber,  
            @batchid,  
   case CCAIndex  
                when 99 then ''  
                when 0 then ANAL_T0  
                when 1 then ANAL_T1  
                when 2 then ANAL_T2  
                when 3 then ANAL_T3  
                when 4 then ANAL_T4  
                when 5 then ANAL_T5  
                when 6 then ANAL_T6  
                when 7 then ANAL_T7  
                when 8 then ANAL_T8  
                when 9 then ANAL_T9  
            end CCATeamsCode  
        from  
            sungl_SALFLDG f  
            cross apply  
            (  
                select   
                    min(  
                        case  
                            when S_HEAD = 'PROJECT CODES' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) ProjectIndex,  
                    min(  
                        case  
                            when S_HEAD = 'STATE' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) StateIndex,  
                    min(  
                        case  
                            when S_HEAD = 'SOURCE' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) SourceIndex,  
                    min(  
                        case  
                            when S_HEAD = 'GST' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) GSTIndex,  
                    min(  
                        case  
                            when S_HEAD = 'CASE NUMBER' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) CaseIndex,  
                    min(  
                        case  
                            when S_HEAD = 'PRODUCT' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) ProductIndex,  
                    min(  
                        case  
                            when S_HEAD = 'JV' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) JVIndex,  
                    min(  
                        case  
                            when S_HEAD = 'DEPT' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) DepartmentIndex,  
                    min(  
                        case  
                            when S_HEAD = 'CLIENT' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) ClientIndex,  
                    min(  
                        case  
                            when S_HEAD = 'BDM' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) BDMIndex,  
                    min(  
                        case  
                            when S_HEAD = 'CHANNEL' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) ChannelIndex,  
     min(  
                        case  
                            when S_HEAD = 'CCA TEAMS' then ENTRY_NUM - 1  
                            else 99  
                        end  
                    ) CCAIndex   
                from  
                    sungl_ANL_ENT_DEFN r  
                where  
                    r.BusinessUnit = f.BusinessUnit and  
                    S_HEAD in  
                    (  
                        'BDM',  
                        'CHANNEL',  
                        'CLIENT',  
                        'DEPT',  
                        'JV',  
                        'PRODUCT',  
                        'PROJECT CODES',  
                        'STATE',  
                        'SOURCE',  
                        'CASE NUMBER',  
                        'GST',  
      'CCA TEAMS'  
                    )  
            ) i  
  
        ---BEGIN - Department code update in GL Transactions table based on the mapping table  
  
        DECLARE   
            @OldDeptCode nvarchar(255),   
            @NewDeptCode   nvarchar(255);  
  
        DECLARE cursor_dept CURSOR  
        FOR SELECT   
                [Old Department Code],   
                [New Department Code]  
            FROM   
                sungl_departmentcode_mapping;  
  
        OPEN cursor_dept;  
  
        FETCH NEXT FROM cursor_dept INTO   
            @OldDeptCode,   
            @NewDeptCode;  
  
        WHILE @@FETCH_STATUS = 0  
            BEGIN  
               UPDATE [db-au-cmdwh]..glTransactions set departmentcode = @NewDeptCode  
                WHERE departmentcode = @OldDeptCode and [Period] >= 2019007 
                FETCH NEXT FROM cursor_dept INTO   
                    @OldDeptCode,   
                    @NewDeptCode;  
            END;  
  
        CLOSE cursor_dept;  
  
        DEALLOCATE cursor_dept;  
  
  
        ---END - Department code update in GL Transactions table based on the mapping table  
  
        exec syssp_genericerrorhandler  
            @LogToTable = 1,  
            @ErrorCode = '0',  
            @BatchID = @batchid,  
            @PackageID = @name,  
            @LogStatus = 'Finished',  
            @LogSourceCount = @sourcecount,  
            @LogInsertCount = @insertcount,  
            @LogUpdateCount = @updatecount  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction  
  
        exec syssp_genericerrorhandler  
            @SourceInfo = 'data refresh failed',  
            @LogToTable = 1,  
            @ErrorCode = '9900',  
            @BatchID = @batchid,  
            @PackageID = @name,  
            @LogStatus = 'Error'  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
  
  
GO
