USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_etl_dbcopy]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[syssp_etl_dbcopy]
  @SourceServer varchar(256) = 'TestDataWH01',
  @SourceDB varchar(256) = 'db-au-cmdwh',
  @Filter varchar(1000) = '',
  @DestinationDB varchar(256) = 'db-au-cmdwh',
  @Mode varchar(20) = 'ALL',
  @Debug bit = 0

as
begin
/*****************************************************************************************************************/
--  Name:           dbo.syssp_etl_dbcopy
--  Author:         Leonardus Setyabudi
--  Date Created:   20120719
--  Description:    This stored procedure copy tables (by default) from TestDataWH01
--  Parameters:     @SourceServer: FQDN of source server, e.g. bhdwh01.aust.covermore.com.au
--                  @SourceDB: database name, e.g. db-au-cmdwh
--                  @Filter: free text, filter the table names, e.g. table_name like 'pen%'
--                  @DestinationDB: destination database name, e.g. db-cmdauwh-Test01
--                  @Mode: which step to execute, ALL to execute all steps
--
--  Change History: 20120719 - LS - Created
--                  20121105 - LS - bug fix on index columns order
--
/*****************************************************************************************************************/
--uncomment to debug
/*
--FileFormat,DropTables,CreateTables,Export,Import,DropIndexes,CreateIndexes

declare @SourceServer varchar(256)
declare @SourceDB varchar(256)
declare @DestinationDB varchar(256)
declare @Filter varchar(1000)
declare @Mode varchar(20)
declare @Debug bit

select
  @SourceServer = 'TESTDATAWH01',
  @SourceDB = 'db-au-cmdwh',  
  @Filter = 'table_name like '''',
  @DestinationDB = 'db-au-cmdwh',
  @Mode = 'ALL',
  @Debug = 1
*/

  set nocount on

  declare @sql varchar(8000)
  declare @penTables table 
  (
    TableName varchar(256),
    IndexName varchar(256),
    Script varchar(4000)
  )
  declare cPenTables cursor local for select distinct TableName from @penTables
  declare cPenIndexs cursor local for select TableName, IndexName, Script from @penTables
  declare @table varchar(256)
  declare @index varchar(256)
  declare @script varchar(256)

  set @sql =
    '
    with 
    cte_index as
    (
      select distinct 
        i.index_id, 
        i.name, 
        i.type_desc,
        i.object_id,
        o.name table_name
      from 
        [' + @SourceServer + '].[' + @SourceDB + '].sys.indexes i 
        inner join [' + @SourceServer + '].[' + @SourceDB + '].sys.index_columns ic on 
          i.index_id = ic.index_id and 
          i.object_id = ic.object_id
        inner join [' + @SourceServer + '].[' + @SourceDB + '].sys.objects o on o.object_id = i.object_id
    ), 
    cte_indexcolumns as
    (
      select 
        idx.name index_name, 
        idx.table_name,
        lower(type_desc) collate database_default indextype, 
        (
          select c.name + '',''
          from 
            [' + @SourceServer + '].[' + @SourceDB + '].sys.columns c 
            inner join [' + @SourceServer + '].[' + @SourceDB + '].sys.index_columns ic on 
              c.object_id = ic.object_id and 
              ic.column_id = c.column_id and 
              ic.is_included_column = 0
          where
            idx.object_id = ic.object_id and 
            idx.index_id = ic.index_id 
          for xml path('''')
        ) indexcolumns,
        isnull(
          (
            select c.name + '',''
            from 
              [' + @SourceServer + '].[' + @SourceDB + '].sys.columns c 
              inner join [' + @SourceServer + '].[' + @SourceDB + '].sys.index_columns ic on 
                c.object_id = ic.object_id and 
                ic.column_id = c.column_id and 
                ic.is_included_column = 1
            where
              idx.object_id = ic.object_id and 
              idx.index_id = ic.index_id 
            for xml path('''')
          ), 
          ''''
        ) includecolumns
      from cte_index idx
    ) 
    select 
      t.name table_name,
      index_name,
      ''create '' + indextype + '' index '' + index_name + '' on [' + @DestinationDB + '].dbo.'' + table_name + 
      ''('' + substring(indexcolumns, 1, len(indexcolumns) - 1) + 
      case len(includecolumns)
        when 0 then '')''
        else '') include ('' + substring(includecolumns, 1, len(includecolumns) - 1) + '')''
      end script
    from   
      [' + @SourceServer + '].[' + @SourceDB + '].sys.tables t
      left join cte_indexcolumns i on i.table_name = t.name
    where 
      type = ''U'' and '+
      @filter + '
    order by 
      table_name, 
      indextype,
      index_name
    '

  insert into @penTables
  exec (@SQL)

  open cPenTables

  fetch next from cPenTables into @table

  while @@fetch_status = 0 
  begin

    --File Format
    if @Mode in ('FileFormat', 'ALL')
    begin

      set @sql = 
        'bcp [' + @SourceDB + '].dbo.[' + @table + '] ' +
        'format nul -n ' +
        '-e "e:\etl\error files\DBCopy\errff_' + @table + '.txt" ' +
        '-f "e:\etl\file formats\DBCopy\ff_' + @table + '.fmt" ' +
        '-T -S ' + @SourceServer
        
      if @debug = 1 
        print @sql
      
      else
        exec master.dbo.xp_cmdshell @sql
    
    end
    
    --Drop Tables
    if @Mode in ('DropTables', 'ALL')
    begin

      set @sql = 
        '
        if object_id(''[' + @DestinationDB + '].dbo.[' + @table + ']'') is not null 
          drop table [' + @DestinationDB + '].dbo.[' + @table + ']
        '  

      if @debug = 1 
        print @sql
      
      else
        exec (@sql)
        
    end
    
    --Create Tables
    if @Mode in ('CreateTables', 'ALL')
    begin

      set @sql = 
        '
        if object_id(''[' + @DestinationDB + '].dbo.[' + @table + ']'') is null 
          select * 
          into [' + @DestinationDB + '].dbo.[' + @table + ']
          from [' + @SourceServer + '].[' + @SourceDB + '].dbo.[' + @table + '] 
          where 1 = 0
        '  

      if @debug = 1 
        print @sql
      
      else
        exec (@sql)
        
    end

    --Export Data
    if @Mode in ('Export', 'ALL')
    begin

      set @sql = 
        'bcp "select * from [' + @SourceDB + '].dbo.[' + @table + ']" ' +
        'queryout "e:\etl\data\DBCopy\out_' + @table + '.txt" ' +
        '-e "e:\etl\error files\DBCopy\errout_' + @table + '.txt" ' +
        '-k -f "e:\etl\file formats\DBCopy\ff_' + @table + '.fmt" ' +
        '-T -S ' + @SourceServer

      print @table

      if @debug = 1 
        print @sql
      
      else
        exec master.dbo.xp_cmdshell @sql

    end
    
    --Import Data
    if @Mode in ('Import', 'ALL')
    begin

      set @sql = 
        'bcp [' + @DestinationDB + '].dbo.[' + @table + '] ' +
        'in "e:\etl\data\DBCopy\out_' + @table + '.txt" ' +
        '-e "e:\etl\error files\DBCopy\errin_' + @table + '.txt" ' +
        '-f "e:\etl\file formats\DBCopy\ff_' + @table + '.fmt" ' +
        '-T -S BHDWH01'

      print @table

      if @debug = 1 
        print @sql
      
      else
        exec master.dbo.xp_cmdshell @sql

    end
    
    --

    fetch next from cPenTables into @table

  end

  close cPenTables
  deallocate cPenTables

  open cPenIndexs

  fetch next from cPenIndexs into @table, @index, @script

  while @@fetch_status = 0 
  begin

    --Drop Indexes
    if @Mode in ('DropIndexes', 'ALL')
    begin

      set @sql = 
        '
        if exists 
        (
          select null
          from 
            [' + @DestinationDB + '].sys.indexes i
            inner join [' + @DestinationDB + '].sys.objects o on o.object_id = i.object_id
          where 
            i.name = ''' + @index + ''' and
            o.name = ''' + @table + '''
        )
          drop index ' + @index + ' on [' + @DestinationDB + '].dbo.' + @table

      if @debug = 1 
        print @sql
      
      else
        exec (@sql)
        
    end
    
    --Create Indexes
    if @Mode in ('CreateIndexes', 'ALL')
    begin

      set @sql = @script

      if @debug = 1 
        print @sql
      
      else
        exec (@sql)
        
    end

    fetch next from cPenIndexs into @table, @index, @script

  end

  close cPenIndexs
  deallocate cPenIndexs

end

GO
