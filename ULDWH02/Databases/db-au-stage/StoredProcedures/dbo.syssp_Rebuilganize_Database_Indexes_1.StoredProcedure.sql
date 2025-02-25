USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_Rebuilganize_Database_Indexes_1]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-07-14
-- Description:	
-- =============================================
create PROCEDURE [dbo].[syssp_Rebuilganize_Database_Indexes_1] 
	@DatabaseName varchar(100), 
	@FragmentationPercentageOver int = 15, 
	@PageCountOver int = 1000
AS
BEGIN

	SET NOCOUNT ON;

	declare @Table varchar(100), @Index varchar(300), @Frag_Perc float 
	declare @sql varchar(max)


	if object_id('tempdb..##index_physical_stats') is not null
		drop table ##index_physical_stats

	set @sql = 
	'use [' + replace(replace(@DatabaseName, '[', ''), ']', '') + ']' + 
	'select 
		object_name(a.object_id) TableName, 
		i.[name] IndexName, 
		a.avg_fragmentation_in_percent 
	into ##index_physical_stats 
	from 
		sys.dm_db_index_physical_stats(db_id(), null, null, null, null) a 
		inner join sys.indexes i 
			on a.index_id = i.index_id and a.object_id = i.object_id
	where 
		i.[name] is not null 
		and object_name(a.object_id) is not null 
		and a.avg_fragmentation_in_percent > ' + convert(varchar(10), @FragmentationPercentageOver) + 
		'and a.page_count > ' + convert(varchar(100), @PageCountOver)

	exec(@sql)

	
	declare cIndexes cursor for 
	select * from ##index_physical_stats

	open cIndexes
	fetch next from cIndexes into @Table, @Index, @Frag_Perc 

	while @@fetch_status = 0 
	begin 
		if @Frag_Perc > 40 
			set @sql = 'use [' + replace(replace(@DatabaseName, '[', ''), ']', '') + '] alter index ' + @Index + ' on ' + @Table + ' rebuild'
		else 
			set @sql = 'use [' + replace(replace(@DatabaseName, '[', ''), ']', '') + '] alter index ' + @Index + ' on ' + @Table + ' reorganize'

		exec(@sql)

		fetch next from cIndexes into @Table, @Index, @Frag_Perc 
	end 

	close cIndexes 
	deallocate cIndexes 


END


GO
