USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_FactGL]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL033_STAR_FactGL]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160513
Prerequisite:   
Description:    load fact table
Change History:
                20160513 - LL - created
    
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
        
    if object_id('[db-au-star]..Fact_GL') is null
    begin

        create table [db-au-star]..Fact_GL
        (
            [Fact_GL_ID] bigint not null identity(1,1),
            [Account_SID] int null,
            [Business_Unit_SK] int null,
            [Channel_SK] int null,
            [Currency_SK] int null,
            [Joint_Venture_SK] int null,
            [Department_SK] int null,
            [Date_SK] int null,
            [Fiscal_Period_Code] int not null,
            [Scenario_SK] int null,
            [Source_Business_Unit_SK] int null,
            [Client_SK] int null,
            [GL_Product_SK] int null,
            [Project_Codes_SK] int null,
            [State_SK] int null,
            [Journal_Type_SK] int null,
            [GST_SK] int null,
            [General_Ledger_Amount] numeric(18,3) null,
            [Report_Amount] numeric(18,3) null,
            [Other_Amount] numeric(18,3) null,
            [Create_Date] datetime not null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null,
        )

        create clustered index PK_Fact_GL on [db-au-star].dbo.Fact_GL(Fact_GL_ID)
        create index period on [db-au-star].dbo.Fact_GL(Fiscal_Period_Code,Business_Unit_SK,Scenario_SK)

    end

    begin transaction
    
    begin try

        delete 
        from
            [db-au-star]..Fact_GL
        where
            Fiscal_Period_Code between @SunStart and @SunEnd and
            (
                isnull(@paramBusinessUnit, '*') like '%*%' or
                Business_Unit_SK in 
                (
                    select 
                        dbu.Business_Unit_SK
                    from
                        @businessunits bu
                        inner join [db-au-star]..Dim_Business_Unit dbu on
                            dbu.Business_Unit_Code = bu.BU
                )
            ) and
            (
                isnull(@paramScenario, '*') like '%*%' or
                Scenario_SK in 
                (
                    select 
                        ds.Scenario_SK
                    from 
                        @scenarios s
                        inner join [db-au-star]..Dim_Scenario ds on
                            ds.Scenario_Code = s.Scenario
                )
            )

        ;with cte_transaction
        as
        (
            select 
                isnull(da.[Account_SID], -1) [Account_SID],
                isnull(dbu.[Business_Unit_SK], -1) [Business_Unit_SK],
                isnull(dch.[Channel_SK], -1) [Channel_SK],
                isnull(dcr.[Currency_SK], -1) [Currency_SK],
                isnull(djv.[Joint_Venture_SK], -1) [Joint_Venture_SK],
                isnull(ddp.[Department_SK], -1) [Department_SK],
                isnull(dd.[Date_SK], -1) [Date_SK],
                t.Period [Fiscal_Period_Code],
                isnull(dsc.[Scenario_SK], -1) [Scenario_SK],
                isnull(dsbu.[Business_Unit_SK], -1) [Source_Business_Unit_SK],
                isnull(dcl.[Client_SK], -1) [Client_SK],
                isnull(dp.[Product_SK], -1) [GL_Product_SK],
                isnull(dpj.[Project_Codes_SK], -1) [Project_Codes_SK],
                isnull(ds.[State_SK], -1) [State_SK],
                isnull(djt.[Journal_Type_SK], -1) [Journal_Type_SK],
                isnull(dg.[GST_SK], -1) [GST_SK],
                t.GLAmount,
                t.ReportAmount,
                t.OtherAmount
            from
                [db-au-cmdwh]..glTransactions t
                outer apply
                (
                    select top 1 
                        CurrencyCode
                    from
                        [db-au-cmdwh]..glBusinessUnits bu
                    where
                        bu.BusinessUnitCode = t.BusinessUnit
                ) bu
                outer apply
                (
                    select 
                        Account_SID
                    from
                        [db-au-star]..Dim_Account da
                    where
                        rtrim(da.Account_CODE) = rtrim(t.AccountCode)
                ) da
                outer apply
                (
                    select top 1
                        dbu.Business_Unit_SK
                    from
                        [db-au-star]..Dim_Business_Unit dbu
                    where
                        dbu.Business_Unit_Code = t.BusinessUnit
                ) dbu
                outer apply
                (
                    select top 1
                        dch.Channel_SK
                    from
                        [db-au-star]..Dim_Channel dch
                    where
                        dch.Channel_Code = t.ChannelCode
                ) dch
                outer apply
                (
                    select top 1
                        dcr.Currency_SK
                    from
                        [db-au-star]..Dim_Currency dcr
                    where
                        dcr.Currency_Code = bu.CurrencyCode
                ) dcr
                outer apply
                (
                    select top 1
                        djv.Joint_Venture_SK
                    from
                        [db-au-star]..Dim_Joint_Venture djv
                    where
                        djv.Joint_Venture_Code = t.JointVentureCode
                ) djv
                outer apply
                (
                    select top 1
                        ddp.Department_SK
                    from
                        [db-au-star]..Dim_Department ddp
                    where
                        ddp.Department_Code = t.DepartmentCode
                ) ddp
                outer apply
                (
                    select top 1
                        Date_SK
                    from
                        [db-au-star]..Dim_Date dd
                    where
                        dd.Fiscal_Month_Of_Year = t.Period
                    order by
                        Date_SK desc
                ) dd
                outer apply
                (
                    select top 1
                        dsc.Scenario_SK
                    from
                        [db-au-star]..Dim_Scenario dsc
                    where
                        dsc.Scenario_Code = t.ScenarioCode
                ) dsc
                outer apply
                (
                    select top 1
                        dsbu.Business_Unit_SK
                    from
                        [db-au-star]..Dim_Business_Unit dsbu
                    where
                        dsbu.Business_Unit_Code = t.SourceCode
                ) dsbu
                outer apply
                (
                    select top 1
                        dcl.Client_SK
                    from
                        [db-au-star]..Dim_Client dcl
                    where
                        dcl.Client_Code = t.ClientCode
                ) dcl
                outer apply
                (
                    select top 1
                        dp.Product_SK
                    from
                        [db-au-star]..Dim_GL_Product dp
                    where
                        dp.Product_Code = t.ProductCode
                ) dp
                outer apply
                (
                    select top 1
                        dpj.Project_Codes_SK
                    from
                        [db-au-star]..Dim_Project_Codes dpj
                    where
                        dpj.Project_Code = t.ProjectCode
                ) dpj
                outer apply
                (
                    select top 1
                        ds.State_SK
                    from
                        [db-au-star]..Dim_State ds
                    where
                        ds.State_Code = t.StateCode
                ) ds
                outer apply
                (
                    select top 1
                        djt.Journal_Type_SK
                    from
                        [db-au-star]..Dim_Journal_Type djt
                    where
                        djt.Journal_Type_Code = t.JournalType
                ) djt
                outer apply
                (
                    select top 1
                        dg.GST_SK
                    from
                        [db-au-star]..Dim_GST dg
                    where
                        dg.GST_Code = t.GSTCode
                ) dg
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
        )
        insert into [db-au-star]..Fact_GL with(tablock)
        (
            [Account_SID],
            [Business_Unit_SK],
            [Channel_SK],
            [Currency_SK],
            [Joint_Venture_SK],
            [Department_SK],
            [Date_SK],
            [Fiscal_Period_Code],
            [Scenario_SK],
            [Source_Business_Unit_SK],
            [Client_SK],
            [GL_Product_SK],
            [Project_Codes_SK],
            [State_SK],
            [Journal_Type_SK],
            [GST_SK],
            [General_Ledger_Amount],
            [Report_Amount],
            [Other_Amount],
            [Create_Date],
            [Insert_Batch_ID]
        )
        select
            [Account_SID],
            [Business_Unit_SK],
            [Channel_SK],
            [Currency_SK],
            [Joint_Venture_SK],
            [Department_SK],
            [Date_SK],
            [Fiscal_Period_Code],
            [Scenario_SK],
            [Source_Business_Unit_SK],
            [Client_SK],
            [GL_Product_SK],
            [Project_Codes_SK],
            [State_SK],
            [Journal_Type_SK],
            [GST_SK],
            sum(isnull(GLAmount, 0)) [General_Ledger_Amount],
            sum(isnull(ReportAmount, 0)) [Report_Amount],
            sum(isnull(OtherAmount, 0)) [Other_Amount],
            getdate() [Create_Date],
            @batchid [Insert_Batch_ID]
        from
            cte_transaction
        group by
            [Account_SID],
            [Business_Unit_SK],
            [Channel_SK],
            [Currency_SK],
            [Joint_Venture_SK],
            [Department_SK],
            [Date_SK],
            [Fiscal_Period_Code],
            [Scenario_SK],
            [Source_Business_Unit_SK],
            [Client_SK],
            [GL_Product_SK],
            [Project_Codes_SK],
            [State_SK],
            [Journal_Type_SK],
            [GST_SK]


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
