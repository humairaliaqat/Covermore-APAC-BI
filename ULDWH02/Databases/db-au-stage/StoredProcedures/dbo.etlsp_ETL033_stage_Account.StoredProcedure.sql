USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_Account]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL033_stage_Account]      
as      
begin      
/************************************************************************************************************************************      
Author:         Leo      
Date:           20170224      
Prerequisite:   GL master data excel file available @ E:\ETL\Data\GL_Master_Data.xlsx      
                The file shouldn't be open by any other process      
Description:    stage GL User COA      
Change History:      
                20170224 - LL - created      
                20180517 - LL - add Zurich mapping      
				20220814 - SS - Add collation for SUNGL migration 
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
      
    begin transaction      
          
    begin try      
      
        --COA      
        if object_id('sungl_excel_usercoa') is not null      
            drop table sungl_excel_usercoa      
      
        select       
            *      
        into sungl_excel_usercoa      
        from       
            openrowset      
            (      
                'Microsoft.ACE.OLEDB.12.0',      
                'Excel 12.0 Xml;HDR=YES;IMEX=1;Database=E:\ETL\Data\GL_Master_Data.xlsx',      
                '      
                select       
                    *      
                from       
                    [User COA$]      
                '      
            )      
      
        alter table sungl_excel_usercoa add ID bigint identity(1,1)      
      
        if object_id('sungl_excel_account') is not null      
            drop table sungl_excel_account      
      
        select       
            [Parent Account Code],      
            [Child Account Code],      
            [Child Account Description],      
            [Account Category],      
            [Account Hierarchy Type],      
            [Account Operator],      
            row_number() over (order by t.Account_Level, t.Account_Order) [Account Order],      
            r.[FIP Account],      
            r.[SAP PE3 Account],      
            r.[FIP TOB],      
            r.[SAP TOB],      
            r.[TOM],      
            r.[Account Type],      
            r.[Statutory Mapping],      
            r.[Internal Mapping],      
            r.[Technical],      
            r.[Intercompany]      
        into sungl_excel_account      
        from      
            (      
                select      
                    1 Account_Level,      
                    convert(varchar(255), '') [Parent Account Code],      
                    convert(varchar(255), replace([Level 1 Code], ' ', ' ')) [Child Account Code],      
                    convert(varchar(255), [Level 1]) [Child Account Description],      
                    'A' [Account Hierarchy Type],      
                    convert(varchar(255), [Level 1 Category]) [Account Category],       
                    convert(varchar(255), [Level 1 Operator]) [Account Operator],      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
              replace([Level 1 Code], ' ', ' '),      
                    [Level 1],      
                    [Level 1 Category],       
                    [Level 1 Operator]      
      
                union all      
          
           select      
                    2 Account_Level,      
                    convert(varchar(255), replace([Level 1 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 2 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 2]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 2 Category]) Account_Category,       
                    convert(varchar(255), [Level 2 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 1 Code], ' ', ' '),      
                    replace([Level 2 Code], ' ', ' '),      
                    [Level 2],      
                    [Level 2 Category],       
                    [Level 2 Operator]          
      
                union all      
      
                select      
                    3 Account_Level,      
                    convert(varchar(255), replace([Level 2 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 3 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 3]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 3 Category]) Account_Category,       
                    convert(varchar(255), [Level 3 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 2 Code], ' ', ' '),      
                    replace([Level 3 Code], ' ', ' '),      
                    [Level 3],      
                    [Level 3 Category],       
                    [Level 3 Operator]          
      
                union all      
      
                select      
                    4 Account_Level,      
                    convert(varchar(255), replace([Level 3 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 4 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 4]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 4 Category]) Account_Category,       
                    convert(varchar(255), [Level 4 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 3 Code], ' ', ' '),      
                    replace([Level 4 Code], ' ', ' '),      
                    [Level 4],      
                    [Level 4 Category],       
                    [Level 4 Operator]          
      
                union all      
      
                select      
                    5 Account_Level,      
                    convert(varchar(255), replace([Level 4 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 5 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 5]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 5 Category]) Account_Category,       
                    convert(varchar(255), [Level 5 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by                          replace([Level 4 Code], ' ', ' '),      
                    replace([Level 5 Code], ' ', ' '),      
                    [Level 5],      
                    [Level 5 Category],       
                    [Level 5 Operator]      
              
                union all      
      
                select      
                    6 Account_Level,      
                    convert(varchar(255), replace([Level 5 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 6 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 6]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 6 Category]) Account_Category,       
   convert(varchar(255), [Level 6 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 5 Code], ' ', ' '),      
                    replace([Level 6 Code], ' ', ' '),      
                    [Level 6],      
                    [Level 6 Category],       
                    [Level 6 Operator]      
      
                union all      
      
                select      
                    7 Account_Level,      
                    convert(varchar(255), replace([Level 6 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 7 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 7]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 7 Category]) Account_Category,       
                    convert(varchar(255), [Level 7 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 6 Code], ' ', ' '),      
                    replace([Level 7 Code], ' ', ' '),      
                    [Level 7],      
                    [Level 7 Category],       
                    [Level 7 Operator]      
      
                union all      
      
                select      
                    8 Account_Level,      
                    convert(varchar(255), replace([Level 7 Code], ' ', ' ')) Parent_Account_Code,      
                    convert(varchar(255), replace([Level 8 Code], ' ', ' ')) Child_Account_Code,      
                    convert(varchar(255), [Level 8]) Child_Account_Desc,      
                    'A' Account_Hierarchy_Type,      
                    convert(varchar(255), [Level 8 Category]) Account_Category,       
                    convert(varchar(255), [Level 8 Operator]) Account_Operator,      
                    min(ID) Account_Order      
                from      
                    sungl_excel_usercoa      
                group by      
                    replace([Level 7 Code], ' ', ' '),      
                    replace([Level 8 Code], ' ', ' '),      
                    [Level 8],      
                    [Level 8 Category],       
                    [Level 8 Operator]      
            ) t      
            left join      
            (      
                select       
                    [Level 8 Code] [Account Code],      
                    [FIP Account],      
                    [SAP PE3 Account],      
                    [FIP TOB],      
                    [SAP TOB],      
                    [TOM],      
                    [Account Type],      
                    [Statutory Mapping],      
                    [Internal Mapping],      
                    [Technical],      
                    [Intercompany]      
                from      
                    test_sungl_excel_usercoa      
                where      
                    [Level 8 Code] is not null      
      
       union      
      
                select       
                    [Level 5 Code],      
                    [FIP Account],      
                    [SAP PE3 Account],      
                    [FIP TOB],      
                    [SAP TOB],      
                    [TOM],      
                    [Account Type],      
                    [Statutory Mapping],      
                    [Internal Mapping],      
                    [Technical],      
                    [Intercompany]      
                from      
                    test_sungl_excel_usercoa      
           where      
                    [Level 8 Code] is null and      
                    [Level 5 Code] is not null      
            ) r on      
                t.[Child Account Code] collate database_default = r.[Account Code] collate database_default     
        where      
            [Child Account Code] is not null      
        order by       
            t.Account_Level,       
            t.Account_Order      
      
        --select *      
        --from      
        --    sungl_excel_account      
      
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
