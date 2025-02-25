USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_LogShip_Apply]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[syssp_LogShip_Apply]
    @DBName varchar(max),
    @StandbyFile varchar(max),
    @LogPath varchar(max),
	@Debug bit = 0

as
begin

    --declare
       -- @DBName varchar(max),
    --    @StandbyFile varchar(max),
    --    @LogPath varchar(max)

    --select
    --    @DBName = 'Corporate',
    --    @StandbyFile = 'H:\LogShip\Standby\AU_Corporate_Standby.bak',
    --    @LogPath = '\\ulbackup02\sqlgold\MSSQLCL02$ULSQLAG06\Corporate\LOG\'

    declare
        @lastrestore varchar(max),
        @newrestore varchar(max),
        @cmd varchar(max)

    declare
        @backupset table (files varchar(max))

    --disconnect all users
    --set @cmd = 'alter database ' + @DBName + ' set single_user with rollback immediate'
    --exec (@cmd) at [BHDWH03\SNAPSHOT]

    while
        exists
        (
            select 
                null
            from
                openquery
                (
                    [BHDWH03\SNAPSHOT],
                    '
                    select 
                        sqltext.text,
                        req.session_id,
                        req.status,
                        req.command,
                        req.cpu_time,
                        req.total_elapsed_time 
                    from 
                        sys.dm_exec_requests req 
                        cross apply sys.dm_exec_sql_text(sql_handle) sqltext
                    '
                )
            where
                [text] like '%' + @DBName + '%'
        )
        waitfor delay '00:00:30'

    --get last restored log
    select top 1
        --[rs].[destination_database_name],
        --[rs].[restore_date],
        --[bs].[backup_start_date],
        --[bs].[backup_finish_date],
        --[bs].[database_name] [source_database_name],
        --[bmf].[physical_device_name] [backup_file_used_for_restore]
        @lastrestore = replace([bmf].[physical_device_name], @logPath, '')
    from
        [BHDWH03\SNAPSHOT].msdb.dbo.restorehistory rs
        inner join [BHDWH03\SNAPSHOT].msdb.dbo.backupset bs on
            [rs].[backup_set_id] = [bs].[backup_set_id]
        inner join [BHDWH03\SNAPSHOT].msdb.dbo.backupmediafamily bmf on
            [bs].[media_set_id] = [bmf].[media_set_id]
    where
        destination_database_name = @DBName
    order by
        [rs].[restore_date] desc

    print @lastrestore

    --get list of log files
    set @cmd = 'master.dbo.xp_cmdshell ''dir /b "' + @logPath + '"'''

    print @cmd

    insert into @backupset (files)
    exec (@cmd)

    declare cfiles cursor local for
        select --top 1
            --@newrestore = files
            files
        from
            @backupset
        where
            files > isnull(@lastrestore, '')
        order by
            files

    open cfiles

    fetch from cfiles into @newrestore

    while @@fetch_status = 0
    begin

        if isnull(@newrestore, '') <> ''
        begin

            set @cmd = 'restore log [' + @DBName + '] from  disk = ''' + @logPath + @newrestore + ''' with  file = 1,  standby = ''' + @standbyfile + ''',  nounload,  stats = 10'
            print @cmd

            --restore newr log files
            exec (@cmd) at [BHDWH03\SNAPSHOT]

			if @Debug = 1
				print @cmd

        end

        fetch from cfiles into @newrestore

    end

    close cfiles
    deallocate cfiles

    --allow connection
    --set @cmd = 'alter database ' + @DBName + ' set multi_user'
    --exec (@cmd) at [BHDWH03\SNAPSHOT]


end

GO
