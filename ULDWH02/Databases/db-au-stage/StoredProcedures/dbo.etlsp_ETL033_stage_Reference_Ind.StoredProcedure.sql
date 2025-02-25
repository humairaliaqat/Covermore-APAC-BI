USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_Reference_Ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_ETL033_stage_Reference_Ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   etlsp_ETL033_stage_Excel_Ind had been successfully run to load the server meta data.
                linked servers for source(s) are available.
Description:    stage GL reference tables
Change History:
                20160422 - LL - created
				20180423 - LT - created for SUN GL India
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

        declare
            @sql varchar(max),
            @bu varchar(5),
            @server varchar(64),
            @database varchar(64),
            @table varchar(64)

        --ANL_ENT_DEFN_ind
        declare
            c_meta_ANL_ENT_DEFN_ind cursor local for
                select 
                    BusinessUnit,
                    ServerName,
                    DatabaseName,
                    TableName
                from
                    sungl_excel_meta_ind
                where
                    TableType = 'ANL_ENT_DEFN'

        if object_id('sungl_ANL_ENT_DEFN_ind') is null
        begin

            create table sungl_ANL_ENT_DEFN_ind
            (
                BusinessUnit varchar(50),
                ANL_ENT_ID int,
                ANL_CAT_ID varchar(50),
                UPDATE_COUNT int,
                LAST_CHANGE_USER_ID varchar(50),
                LAST_CHANGE_DATETIME datetime,
                ENTRY_NUM int,
                VALIDATE_IND int,
                S_HEAD varchar(50)
            )

            create clustered index cidx_ind on sungl_ANL_ENT_DEFN_ind (BusinessUnit,ANL_ENT_ID)
            create index idx_ind on sungl_ANL_ENT_DEFN_ind (BusinessUnit,S_HEAD) include (ENTRY_NUM)

        end

        truncate table sungl_ANL_ENT_DEFN_ind

        open c_meta_ANL_ENT_DEFN_ind

        fetch next from c_meta_ANL_ENT_DEFN_ind into 
            @bu,
            @server,
            @database,
            @table

        while @@fetch_status = 0 
        begin

            set @sql =
                '
                select
                    ''' + @bu + ''',
                    ANL_ENT_ID,
                    ANL_CAT_ID,
                    UPDATE_COUNT,
                    LAST_CHANGE_USER_ID,
                    LAST_CHANGE_DATETIME,
                    ENTRY_NUM,
                    VALIDATE_IND,
                    S_HEAD
                from 
                    ' +
                @server + '.' + @database + '.dbo.' + @table + ' with(nolock)'

            --print @sql
            insert into sungl_ANL_ENT_DEFN_ind with(tablock)
            (
                BusinessUnit,
                ANL_ENT_ID,
                ANL_CAT_ID,
                UPDATE_COUNT,
                LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,
                ENTRY_NUM,
                VALIDATE_IND,
                S_HEAD
            )
            exec(@sql)

            fetch next from c_meta_ANL_ENT_DEFN_ind into 
                @bu,
                @server,
                @database,
                @table

        end

        close c_meta_ANL_ENT_DEFN_ind
        deallocate c_meta_ANL_ENT_DEFN_ind

        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --ANL_CAT
        declare
            c_meta_ANL_CAT_ind cursor local for
                select 
                    BusinessUnit,
                    ServerName,
                    DatabaseName,
                    TableName
                from
                    sungl_excel_meta_ind
                where
                    TableType = 'ANL_CAT'

        if object_id('sungl_ANL_CAT_ind') is null
        begin

            create table sungl_ANL_CAT_ind
            (
                BusinessUnit varchar(50),
                ANL_CAT_ID varchar(50),
                UPDATE_COUNT int,
                LAST_CHANGE_USER_ID varchar(50),
                LAST_CHANGE_DATETIME datetime,
                STATUS int,
                LOOKUP varchar(50),
                USEABLE_ANL_ENT_ID int,
                S_HEAD varchar(50),
                DESCR varchar(50),
                DAG_CODE varchar(50),
                AMEND_CODE int,
                VALIDATE_IND int,
                LNGTH int,
                LINKED int,
                IBUS_CODE_DIM_ID int
            ) 

            create clustered index cidx_ind on sungl_ANL_CAT_ind (BusinessUnit,ANL_CAT_ID)

        end

        truncate table sungl_ANL_CAT_ind

        open c_meta_ANL_CAT_ind

        fetch next from c_meta_ANL_CAT_ind into 
            @bu,
            @server,
            @database,
            @table

        while @@fetch_status = 0 
        begin

            set @sql =
                '
                select
                    ''' + @bu + ''',
                    ANL_CAT_ID,
                    UPDATE_COUNT,
                    LAST_CHANGE_USER_ID,
                    LAST_CHANGE_DATETIME,
                    STATUS,
                    LOOKUP,
                    USEABLE_ANL_ENT_ID,
                    S_HEAD,
                    DESCR,
                    DAG_CODE,
                    AMEND_CODE,
                    VALIDATE_IND,
                    LNGTH,
                    LINKED,
                    IBUS_CODE_DIM_ID
                from 
                    ' +
                @server + '.' + @database + '.dbo.' + @table + ' with(nolock)'

            --print @sql

            insert into [db-au-stage]..sungl_ANL_CAT_ind with(tablock)
            (
                BusinessUnit,
                ANL_CAT_ID,
                UPDATE_COUNT,
                LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,
                STATUS,
                LOOKUP,
                USEABLE_ANL_ENT_ID,
                S_HEAD,
                DESCR,
                DAG_CODE,
                AMEND_CODE,
                VALIDATE_IND,
                LNGTH,
                LINKED,
                IBUS_CODE_DIM_ID
            )
            exec(@sql)

            fetch next from c_meta_ANL_CAT_ind into 
                @bu,
                @server,
                @database,
                @table

        end

        close c_meta_ANL_CAT_ind
        deallocate c_meta_ANL_CAT_ind

        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --ANL_CODE_ind
        declare
            c_meta_ANL_CODE_ind cursor local for
                select 
                    BusinessUnit,
                    ServerName,
                    DatabaseName,
                    TableName
                from
                    sungl_excel_meta_ind
                where
                    TableType = 'ANL_CODE'

        if object_id('sungl_ANL_CODE_ind') is null
        begin

            create table sungl_ANL_CODE_ind
            (
                BusinessUnit varchar(50),
                ANL_CAT_ID varchar(50),
                ANL_CODE varchar(50),
                UPDATE_COUNT int,
                LAST_CHANGE_USER_ID varchar(50),
                LAST_CHANGE_DATETIME datetime,
                STATUS int,
                LOOKUP varchar(50),
                NAME varchar(50),
                DAG_CODE varchar(50),
                BDGT_CHECK int,
                BDGT_STOP int,
                PROHIBIT_POSTING int,
                NAVIGATION_OPTION int,
                COMBINED_BDGT_CHCK int
            ) 

            create clustered index cidx_ind on sungl_ANL_CODE_ind (BusinessUnit,ANL_CODE) 

        end

        truncate table sungl_ANL_CODE_ind

        open c_meta_ANL_CODE_ind

        fetch next from c_meta_ANL_CODE_ind into 
            @bu,
            @server,
            @database,
            @table

        while @@fetch_status = 0 
        begin

            set @sql =
                '
                select
                    ''' + @bu + ''',
                    ANL_CAT_ID,
                    ANL_CODE,
                    UPDATE_COUNT,
                    LAST_CHANGE_USER_ID,
                    LAST_CHANGE_DATETIME,
                    STATUS,
                    LOOKUP,
                    NAME,
                    DAG_CODE,
                    BDGT_CHECK,
                    BDGT_STOP,
                    PROHIBIT_POSTING,
                    NAVIGATION_OPTION,
                    COMBINED_BDGT_CHCK
                from 
                    ' +
                @server + '.' + @database + '.dbo.' + @table + ' with(nolock)'

            --print @sql

            insert into [db-au-stage]..sungl_ANL_CODE_ind with(tablock)
            (
                BusinessUnit,
                ANL_CAT_ID,
                ANL_CODE,
                UPDATE_COUNT,
                LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,
                STATUS,
                LOOKUP,
                NAME,
                DAG_CODE,
                BDGT_CHECK,
                BDGT_STOP,
                PROHIBIT_POSTING,
                NAVIGATION_OPTION,
                COMBINED_BDGT_CHCK
            )
            exec(@sql)

            fetch next from c_meta_ANL_CODE_ind into 
                @bu,
                @server,
                @database,
                @table

        end

        close c_meta_ANL_CODE_ind
        deallocate c_meta_ANL_CODE_ind


        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --ANL_HRCHY_CODE_ind
        declare
            c_meta_ANL_HRCHY_CODE_ind cursor local for
                select 
                    BusinessUnit,
                    ServerName,
                    DatabaseName,
                    TableName
                from
                    sungl_excel_meta_ind
                where
                    TableType = 'ANL_HRCHY_CODE'

        if object_id('sungl_ANL_HRCHY_CODE_ind') is null
        begin

            create table sungl_ANL_HRCHY_CODE_ind
            (
                BusinessUnit varchar(50),
                ANL_CAT_ID varchar(50),
                ANL_HRCHY_LAB varchar(50),
                ANL_HRCHY_CODE varchar(50),
                UPDATE_COUNT int,
                LAST_CHANGE_USER_ID varchar(50),
                LAST_CHANGE_DATETIME datetime,
                STATUS int,
                LOOKUP varchar(50),
                S_HEAD varchar(50),
                DESCR varchar(50)
            )

            create clustered index cidx_ind on sungl_ANL_HRCHY_CODE_ind (BusinessUnit,ANL_HRCHY_CODE)

        end

        truncate table sungl_ANL_HRCHY_CODE_ind

        open c_meta_ANL_HRCHY_CODE_ind

        fetch next from c_meta_ANL_HRCHY_CODE_ind into 
            @bu,
            @server,
            @database,
            @table

        while @@fetch_status = 0 
        begin

            set @sql =
                '
                select
                    ''' + @bu + ''',
                    ANL_CAT_ID,
                    ANL_HRCHY_LAB,
                    ANL_HRCHY_CODE,
                    UPDATE_COUNT,
                    LAST_CHANGE_USER_ID,
                    LAST_CHANGE_DATETIME,
                    STATUS,
                    LOOKUP,
                    S_HEAD,
                    DESCR
                from 
                    ' +
                @server + '.' + @database + '.dbo.' + @table + ' with(nolock)'

            --print @sql
            insert into sungl_ANL_HRCHY_CODE_ind with(tablock)
            (
                BusinessUnit,
                ANL_CAT_ID,
                ANL_HRCHY_LAB,
                ANL_HRCHY_CODE,
                UPDATE_COUNT,
                LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,
                STATUS,
                LOOKUP,
                S_HEAD,
                DESCR
            )
            exec(@sql)

            fetch next from c_meta_ANL_HRCHY_CODE_ind into 
                @bu,
                @server,
                @database,
                @table

        end

        close c_meta_ANL_HRCHY_CODE_ind
        deallocate c_meta_ANL_HRCHY_CODE_ind

        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

        --ANL_HRCHY_LINK_ind
        declare
            c_meta_ANL_HRCHY_LINK_ind cursor local for
                select 
                    BusinessUnit,
                    ServerName,
                    DatabaseName,
                    TableName
                from
                    sungl_excel_meta_ind
                where
                    TableType = 'ANL_HRCHY_LINK'

        if object_id('sungl_ANL_HRCHY_LINK_ind') is null
        begin

            create table sungl_ANL_HRCHY_LINK_ind
            (
                BusinessUnit varchar(50),
                ANL_CAT_ID varchar(50),
                ANL_HRCHY_LAB varchar(50),
                ANL_HRCHY_CODE varchar(50),
                ANL_CODE varchar(50),
                UPDATE_COUNT int,
                LAST_CHANGE_USER_ID varchar(50),
                LAST_CHANGE_DATETIME datetime,
                USEABLE_ANL_ENT_ID int
            )

            create clustered index cidx_ind on sungl_ANL_HRCHY_LINK_ind (BusinessUnit,ANL_HRCHY_CODE)

        end

        truncate table sungl_ANL_HRCHY_LINK_ind

        open c_meta_ANL_HRCHY_LINK_ind

        fetch next from c_meta_ANL_HRCHY_LINK_ind into 
            @bu,
            @server,
            @database,
            @table

        while @@fetch_status = 0 
        begin

            set @sql =
                '
                select
                    ''' + @bu + ''',
                    ANL_CAT_ID,
                    ANL_HRCHY_LAB,
                    ANL_HRCHY_CODE,
                    ANL_CODE,
                    UPDATE_COUNT,
                    LAST_CHANGE_USER_ID,
                    LAST_CHANGE_DATETIME,
                    USEABLE_ANL_ENT_ID
                from 
                    ' +
                @server + '.' + @database + '.dbo.' + @table + ' with(nolock)'

            --print @sql
            insert into sungl_ANL_HRCHY_LINK_ind with(tablock)
            (
                BusinessUnit,
                ANL_CAT_ID,
                ANL_HRCHY_LAB,
                ANL_HRCHY_CODE,
                ANL_CODE,
                UPDATE_COUNT,
                LAST_CHANGE_USER_ID,
                LAST_CHANGE_DATETIME,
                USEABLE_ANL_ENT_ID
            )
            exec(@sql)

            fetch next from c_meta_ANL_HRCHY_LINK_ind into 
                @bu,
                @server,
                @database,
                @table

        end

        close c_meta_ANL_HRCHY_LINK_ind
        deallocate c_meta_ANL_HRCHY_LINK_ind


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
