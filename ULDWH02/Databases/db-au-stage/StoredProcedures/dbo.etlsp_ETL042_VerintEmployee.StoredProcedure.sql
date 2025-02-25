USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintEmployee]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL042_VerintEmployee]
as
begin
/************************************************************************************************************************************
Author:         Philip Wong
Date:           20140910
Prerequisite:   Requires Verint database.                
Description:    populates verEmployee table in [db-au-cmdwh]
Parameters:        
Change History:
                20140910 - PW - Procedure created
                20141015 - LS - Refactoring
                                Use batch logging
                20141202 - LS - add in username (LDAP)
                
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
        @SubjectArea = 'VERINT ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)
    
    exec syssp_genericerrorhandler 
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'
    
    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.verEmployee') is null
    begin
    
        create table [db-au-cmdwh].dbo.verEmployee
        (
            [BIRowID] bigint not null identity(1,1),
            [EmployeeKey] int not null,
            [EmployeeName] nvarchar(100) not null,
            [EmployeeFirstName] nvarchar(50) not null,
            [EmployeeLastName] nvarchar(50) not null,
            [EmployeeStartTime] datetime null,
            [EmployeeEndTime] datetime null,
            [UserName] varchar(50) null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        ) 
        
        create clustered index idx_verEmployee_BIRowID on [db-au-cmdwh].dbo.verEmployee(BIRowID)
        create nonclustered index idx_verEmployee_EmployeeKey on [db-au-cmdwh].dbo.verEmployee(EmployeeKey)
        
        --populate agent with default unknown values
        insert [db-au-cmdwh].dbo.verEmployee
        (
            EmployeeKey,
            EmployeeName,
            EmployeeFirstName,
            EmployeeLastName,
            UserName
        )
        values
        (
            -1,
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown'
        )
        
    end    

    if object_id('etl_verEmployee') is not null
        drop table etl_verEmployee

    select 
        EMPLOYEE.ID EmployeeKey,     
        LTRIM(RTRIM(isnull(PERSON.FIRSTNAME,''))) + ' ' + LTRIM(RTRIM(isnull(PERSON.LASTNAME,''))) EmployeeName,                
        isnull(PERSON.FIRSTNAME,'') EmployeeFirstName,
        isnull(PERSON.LASTNAME,'') EmployeeLastName,
        EMPLOYEE.STARTTIME EmployeeStartTime,
        EMPLOYEE.ENDTIME EmployeeEndTime,
        PERSON.BIRTHDATE EmployeeDOB,
        BPUSER.USERNAME
    into etl_verEmployee
    from 
        [ULWFM01].[BPMAINDB].dbo.EMPLOYEEAM EMPLOYEE
        left join [ULWFM01].[BPMAINDB].dbo.PERSON on 
            PERSON.ID = EMPLOYEE.PERSONID
        left join [ULWFM01].[BPMAINDB].dbo.BPUSER on
            BPUSER.EMPLOYEEID = EMPLOYEE.ID
            
    select 
        @sourcecount = count(*)
    from
        etl_verEmployee

    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.verEmployee with(tablock) t
        using etl_verEmployee s on 
            s.EmployeeKey = t.EmployeeKey
            
        when matched then
        
            update
            set
                EmployeeName = s.EmployeeName,
                EmployeeFirstName = s.EmployeeFirstName,
                EmployeeLastName = s.EmployeeLastName,
                EmployeeStartTime = s.EmployeeStartTime,
                EmployeeEndTime = s.EmployeeEndTime,
                UserName = s.UserName,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                EmployeeKey,
                EmployeeName,
                EmployeeFirstName,
                EmployeeLastName,
                EmployeeStartTime,
                EmployeeEndTime,
                UserName,
                CreateBatchID
            )
            values
            (
                s.EmployeeKey,
                s.EmployeeName,
                s.EmployeeFirstName,
                s.EmployeeLastName,
                s.EmployeeStartTime,
                s.EmployeeEndTime,
                s.UserName,
                @batchid
            )

        output $action into @mergeoutput
        ;

        select 
            @insertcount = 
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount = 
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

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
            @SourceInfo = 'verEmployee data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction
    
end
GO
