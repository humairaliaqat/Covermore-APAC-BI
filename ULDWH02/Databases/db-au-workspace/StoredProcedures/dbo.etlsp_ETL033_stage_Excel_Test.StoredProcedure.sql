USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_Excel_Test]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL033_stage_Excel_Test]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160422
Prerequisite:   GL master data excel file available @ E:\ETL\Data\GL_Master_Data.xlsx
                The file shouldn't be open by any other process
Description:    stage GL master excel file
Change History:
                20160422 - LL - created
                20180521 - LL - Zurich SAP master
				20210303 - HL - Adding code to load new dimension CCA Teams as per INC0189611 
    
*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    --exec syssp_getrunningbatch
    --    @SubjectArea = 'SUN GL',
    --    @BatchID = @batchid out,
    --    @StartDate = @start out,
    --    @EndDate = @end out

    --if @batchid = -1
    --    raiserror('prevent running without batch', 15, 1) with nowait

    --select
    --    @name = object_name(@@procid)

    --exec syssp_genericerrorhandler
    --    @LogToTable = 1,
    --    @ErrorCode = '0',
    --    @BatchID = @batchid,
    --    @PackageID = @name,
    --    @LogStatus = 'Running'

    --begin transaction
    
    --begin try

        --COA
        --if object_id('sungl_excel_account') is not null
        --    drop table sungl_excel_account

        --select 
        --    [Parent Account Code],
        --    [Child Account Code],
        --    [Child Account Description],
        --    [Account Category],
        --    [Account Hierarchy Type],
        --    [Account Operator],
        --    [Account Order]
        --into sungl_excel_account
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Account_Dimension$]
        --        '
        --    )

        --Zurich SAP master
        --if object_id('sungl_excel_sap') is not null
        --    drop table sungl_excel_sap

        --select distinct
        --    F1 [SAP PE3 Account],
        --    F2 [SAP PE3 Account Description],
        --    F7 [Group account number]
        --into sungl_excel_sap
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [SAP PE3 Account$]
        --        '
        --    )
        --where
        --    F1 <> 'SAP PE3 Account'

        ----Zurich TOM SET
        --if object_id('sungl_excel_tom') is not null
        --    drop table sungl_excel_tom

        --select distinct
        --    [TOM KEY],
        --    [TOM SET],
        --    [TOM],
        --    [TOM Description]
        --into sungl_excel_tom
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [TOM SET$]
        --        '
        --    )


        ----Business Unit
        --if object_id('sungl_excel_businessunit') is not null
        --    drop table sungl_excel_businessunit

        --select 
        --    [Business Unit Code],
        --    [Business Unit Description],
        --    [Currency Code],
        --    [Source System Code],
        --    [Domain ID],
        --    [Parent Business Unit Code],
        --    [Country Code],
        --    [Country Description],
        --    [Region Code],
        --    [Region Description],
        --    [Type of Entity Code],
        --    [Type of Entity Description],
        --    [Type of Business Code],
        --    [Type of Business Description]
        --into sungl_excel_businessunit
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Business_Unit_Dimension$]
        --        '
        --    )

        ----Currency
        --if object_id('sungl_excel_currency') is not null
        --    drop table sungl_excel_currency

        --select 
        --    [Currency Code],
        --    [Currency Description]
        --into sungl_excel_currency
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Currency_Dimension$]
        --        '
        --    )

        ----Scenario
        --if object_id('sungl_excel_scenario') is not null
        --    drop table sungl_excel_scenario

        --select 
        --    [Scenario Code],
        --    [Scenario Description],
        --    [Scenario GL Code]
        --into sungl_excel_scenario
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Scenario_Dimension$]
        --        '
        --    )

        ----JV
        --if object_id('sungl_excel_jv') is not null
        --    drop table sungl_excel_jv

        --select 
        --    [Type of JV Code],
        --    [Type of JV Description],
        --    [Distribution Type Code],
        --    [Distribution Type Description],
        --    [Super Group Code],
        --    [Super Group Description],
        --    [JV Code],
        --    [JV Description]
        --into sungl_excel_jv
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [JV_Dimension$]
        --        '
        --    )

        ----Department
        --if object_id('sungl_excel_department') is not null
        --    drop table sungl_excel_department

        --select 
        --    [Parent Dept Code],
        --    [Parent Dept Description],
        --    [Child Dept Code],
        --    [Child Dept Description],
        --    [Department Type Code],
        --    [Department Type Description],
        --    [Department Entity Code],
        --    [Department Entity Description]
        --into sungl_excel_department
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Department_Dimension$]
        --        '
        --    )

        ----State
        --if object_id('sungl_excel_state') is not null
        --    drop table sungl_excel_state

        --select 
        --    [Parent State Code],
        --    [Parent State Description],
        --    [State Code],
        --    [State Description]
        --into sungl_excel_state
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [State_Dimension$]
        --        '
        --    )

        ----Product
        --if object_id('sungl_excel_product') is not null
        --    drop table sungl_excel_product

        --select 
        --    [Product Parent Code],
        --    [Product Parent Description],
        --    [Product Type Code],
        --    [Product Type Description],
        --    [Product Code],
        --    [Product Description]
        --into sungl_excel_product
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Product_Dimension$]
        --        '
        --    )

        ----Project
        --if object_id('sungl_excel_project') is not null
        --    drop table sungl_excel_project

        --select 
        --    [Parent Project Code],
        --    [Parent Project Code Description],
        --    [Project Owner Code],
        --    [Project Owner Description],
        --    [Project Code],
        --    [Project Description]
        --into sungl_excel_project
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Project_Codes_Dimension$]
        --        '
        --    )

			--CCA Teams
        if object_id('sungl_excel_project_Test') is not null
            drop table sungl_excel_project_Test

        select 
            [Parent CCA Teams Code],
            [Parent CCA Teams Code Description],
            [CCA Teams Owner Code],
            [CCA Teams Owner Description],
            [CCA Teams Code],
            [CCA Teams Description]
        into sungl_excel_project_Test
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data - Copy.xlsx',
                '
                select 
                    *
                from 
                    [CCA_Teams_Dimension$]
                '
            )

        ----Client
        --if object_id('sungl_excel_client') is not null
        --    drop table sungl_excel_client

        --select 
        --    [Parent Client Code],
        --    [Parent Client Description],
        --    [Client Code],
        --    [Client Description]
        --into sungl_excel_client
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Client_Dimension$]
        --        '
        --    )

        ----Journal Type
        --if object_id('sungl_excel_journaltype') is not null
        --    drop table sungl_excel_journaltype

        --select 
        --    [Journal Type Code],
        --    [Journal Type Description]
        --into sungl_excel_journaltype
        --from 
        --    openrowset
        --    (
        --        'Microsoft.ACE.OLEDB.12.0',
        --        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --        '
        --        select 
        --            *
        --        from 
        --            [Journal_Type_Dimension$]
        --        '
        --    )

        ----ETL Meta
        --if object_id('sungl_excel_meta') is not null
        --    drop table sungl_excel_meta

        --select 
        --    [BusinessUnit],
        --    [ServerName],
        --    [DatabaseName],
        --    [BusinessUnit] + '_' + [TableName] [TableName],
        --    [TableType]
        --into sungl_excel_meta
        --from
        --    (
        --        select
        --            rtrim([BusinessUnit]) [BusinessUnit],
        --            rtrim([ServerName]) [ServerName],
        --            rtrim([DatabaseName]) [DatabaseName]
        --        from 
        --            openrowset
        --            (
        --                'Microsoft.ACE.OLEDB.12.0',
        --                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --                '
        --                select 
        --                    *
        --                from 
        --                    [ETL_BusinessUnit$]
        --                '
        --            )
        --        where
        --            rtrim(isnull([BusinessUnit], '')) <> ''
        --    ) bu
        --    inner join
        --    (
        --        select
        --            rtrim([TableName]) [TableName],
        --            [TableType]
        --        from 
        --            openrowset
        --            (
        --                'Microsoft.ACE.OLEDB.12.0',
        --                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data.xlsx',
        --                '
        --                select 
        --                    *
        --                from 
        --                    [ETL_Tables$]
        --                '
        --            )
        --    ) t on 1 = 1

        --exec syssp_genericerrorhandler
        --    @LogToTable = 1,
        --    @ErrorCode = '0',
        --    @BatchID = @batchid,
        --    @PackageID = @name,
        --    @LogStatus = 'Finished'


   -- end try

    --begin catch

    --    if @@trancount > 0
    --        rollback transaction

    --    exec syssp_genericerrorhandler
    --        @SourceInfo = 'data refresh failed',
    --        @LogToTable = 1,
    --        @ErrorCode = '-100',
    --        @BatchID = @batchid,
    --        @PackageID = @name,
    --        @LogStatus = 'Error'

    --end catch

   -- if @@trancount > 0
     --   commit transaction

end
GO
