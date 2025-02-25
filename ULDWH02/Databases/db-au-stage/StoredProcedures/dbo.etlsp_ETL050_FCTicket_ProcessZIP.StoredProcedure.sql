USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL050_FCTicket_ProcessZIP]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL050_FCTicket_ProcessZIP]

--declare
    @DropPath varchar(max) = '\\BHDWH03\Interchange\FC\EDW\'
as
begin

    set nocount on

    declare 
        @sql varchar(max),
        @err varchar(max)

    --get file list
    if object_id('tempdb..#filelist') is not null
        drop table #filelist

    create table #filelist
    (
        filenames varchar(max)
    )

    set @sql = 'exec xp_cmdshell ''dir "' + @droppath + '*.7z" /b'''

    insert into #filelist (filenames)
    exec (@sql)

    declare
        c_files cursor local for
            select 
                FileNames
            from
                #filelist
            where
                filenames is not null and
                filenames <> 'File Not Found'
            order by
                convert(date, right(left(filenames, charindex('.', filenames) - 1), 8))

    declare @filename varchar(max)

    if
        exists
        (
            select 
                null
            from
                #filelist
            where
                filenames is not null and
                filenames <> 'File Not Found'
        )

    begin

        open c_files

        fetch next from c_files into @filename

        while @@fetch_status = 0
        begin

            print @filename

            --extract
            set @sql = 'exec xp_cmdshell ''E:\ETL\Tool\7z.exe e -o"E:\ETL\Data\Flight Centre\Process" -pcover123 -y "' + @droppath + @filename + '"'''
            print @sql

            exec (@sql)

            --archive drop folder
            set @sql = 'exec xp_cmdshell ''move /y "' + @droppath + @filename + '" "' + @droppath + 'Archive\"'''
            print @sql

            exec (@sql)

            fetch next from c_files into @filename

        end

        close c_files
        deallocate c_files

        return 0

    end

    else
    begin

        return 100

    end

end
GO
