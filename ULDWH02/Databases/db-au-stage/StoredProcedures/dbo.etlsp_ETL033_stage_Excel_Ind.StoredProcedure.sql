USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_Excel_Ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_stage_Excel_Ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   GL master data excel file available @ E:\ETL\Data\GL_Master_Data_IND.xlsx
                The file shouldn't be open by any other process
Description:    stage GL master excel file for India
Change History:
                20160422 - LL - created
				20181804 - LT - based on SUN GL Australi. Created for SUN GL India system   

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

    exec syssp_getrunningbatch
        @SubjectArea = 'SUN GL INDIA',
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

    begin transaction
    
    begin try

        --Business Unit
        if object_id('sungl_excel_businessunit_ind') is not null
            drop table sungl_excel_businessunit_ind

        select 
            [Business Unit Code],
            [Business Unit Description],
            [Currency Code],
            [Source System Code],
            [Domain ID],
            [Parent Business Unit Code],
            [Country Code],
            [Country Description],
            [Region Code],
            [Region Description],
            [Type of Entity Code],
            [Type of Entity Description],
            [Type of Business Code],
            [Type of Business Description]
        into sungl_excel_businessunit_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_IND.xlsx',
                '
                select 
                    *
                from 
                    [Business_Unit_Dimension$]
                '
            )

        --Currency
        if object_id('sungl_excel_currency_ind') is not null
            drop table sungl_excel_currency_ind

        select 
            [Currency Code],
            [Currency Description]
        into sungl_excel_currency_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_IND.xlsx',
                '
                select 
                    *
                from 
                    [Currency_Dimension$]
                '
            )

        --Scenario
        if object_id('sungl_excel_scenario_ind') is not null
            drop table sungl_excel_scenario_ind

        select 
            [Scenario Code],
            [Scenario Description],
            [Scenario GL Code]
        into sungl_excel_scenario_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_IND.xlsx',
                '
                select 
                    *
                from 
                    [Scenario_Dimension$]
                '
            )

        --JV
        if object_id('sungl_excel_jv_ind') is not null
            drop table sungl_excel_jv_ind

        select 
            [Type of JV Code],
            [Type of JV Description],
            [Distribution Type Code],
            [Distribution Type Description],
            [Super Group Code],
            [Super Group Description],
            [JV Code],
            [JV Description]
        into sungl_excel_jv_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_IND.xlsx',
                '
                select 
                    *
                from 
                    [JV_Dimension$]
                '
            )

        --Department
        if object_id('sungl_excel_department_ind') is not null
            drop table sungl_excel_department_ind

        select 
            [Parent Dept Code],
            [Parent Dept Description],
            [Child Dept Code],
            [Child Dept Description],
            [Department Type Code],
            [Department Type Description],
            [Department Entity Code],
            [Department Entity Description]
        into sungl_excel_department_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_IND.xlsx',
                '
                select 
                    *
                from 
                    [Department_Dimension$]
                '
            )

        --State
        if object_id('sungl_excel_state_ind') is not null
            drop table sungl_excel_state_ind

        select 
            [Parent State Code],
            [Parent State Description],
            [State Code],
            [State Description]
        into sungl_excel_state_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                '
                select 
                    *
                from 
                    [State_Dimension$]
                '
            )

        --Product
        if object_id('sungl_excel_product_ind') is not null
            drop table sungl_excel_product_ind

        select 
            [Product Parent Code],
            [Product Parent Description],
            [Product Type Code],
            [Product Type Description],
            [Product Code],
            [Product Description]
        into sungl_excel_product_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                '
                select 
                    *
                from 
                    [Product_Dimension$]
                '
            )

        --Project
        if object_id('sungl_excel_project_ind') is not null
            drop table sungl_excel_project_ind

        select 
            [Parent Project Code],
            [Parent Project Code Description],
            [Project Owner Code],
            [Project Owner Description],
            [Project Code],
            [Project Description]
        into sungl_excel_project_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                '
                select 
                    *
                from 
                    [Project_Codes_Dimension$]
                '
            )

        --Client
        if object_id('sungl_excel_client_ind') is not null
            drop table sungl_excel_client_ind

        select 
            [Parent Client Code],
            [Parent Client Description],
            [Client Code],
            [Client Description]
        into sungl_excel_client_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                '
                select 
                    *
                from 
                    [Client_Dimension$]
                '
            )

        --Journal Type
        if object_id('sungl_excel_journaltype_ind') is not null
            drop table sungl_excel_journaltype_ind

        select 
            [Journal Type Code],
            [Journal Type Description]
        into sungl_excel_journaltype_ind
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                '
                select 
                    *
                from 
                    [Journal_Type_Dimension$]
                '
            )

        --ETL Meta
        if object_id('sungl_excel_meta_ind') is not null
            drop table sungl_excel_meta_ind

        select 
            [BusinessUnit],
            [ServerName],
            [DatabaseName],
            [BusinessUnit] + '_' + [TableName] [TableName],
            [TableType]
        into sungl_excel_meta_ind
        from
            (
                select
                    rtrim([BusinessUnit]) [BusinessUnit],
                    rtrim([ServerName]) [ServerName],
                    rtrim([DatabaseName]) [DatabaseName]
                from 
                    openrowset
                    (
                        'Microsoft.ACE.OLEDB.12.0',
                        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                        '
                        select 
                            *
                        from 
                            [ETL_BusinessUnit$]
                        '
                    )
                where
                    rtrim(isnull([BusinessUnit], '')) <> ''
            ) bu
            inner join
            (
                select
                    rtrim([TableName]) [TableName],
                    [TableType]
                from 
                    openrowset
                    (
                        'Microsoft.ACE.OLEDB.12.0',
                        'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\GL_Master_Data_ind.xlsx',
                        '
                        select 
                            *
                        from 
                            [ETL_Tables$]
                        '
                    )
            ) t on 1 = 1

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished'


    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Error'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
