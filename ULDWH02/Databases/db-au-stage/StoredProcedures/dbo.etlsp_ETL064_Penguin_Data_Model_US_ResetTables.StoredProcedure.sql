USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL064_Penguin_Data_Model_US_ResetTables]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL064_Penguin_Data_Model_US_ResetTables]
as

set nocount on

--the purpose of this SP is to reset _uscm penguin tables if ETL064_Penguin_Data_Model_US SSIS package fails during processing

--get sql create table definitions
if object_id('tempdb..#createtabledef') is not null drop table #createtabledef
select SQL_CreateTableDef
into #createtabledef
from 
	etl_meta_data 
where 
	SourceDatabaseName like '%AU_PenguinSharp_Active%' and 
	Country = 'AU' and
	isActive = 1
	
--replace _aucm tables to _uscm
update #createtabledef
set SQL_CreateTableDef = REPLACE(SQL_CreateTableDef,'_aucm','_uscm')

--create cursor and execute @SQL until complete.
declare @SQL varchar(8000)
declare CUR_SQL cursor for 
	select SQL_CreateTableDef        
	from #createtabledef

open CUR_SQL
fetch NEXT from CUR_SQL into @SQL

while @@fetch_status = 0
begin
	execute(@SQL)
    fetch NEXT from CUR_SQL into @SQL    
end

close CUR_SQL
deallocate CUR_SQL

drop table #createtabledef
            
GO
