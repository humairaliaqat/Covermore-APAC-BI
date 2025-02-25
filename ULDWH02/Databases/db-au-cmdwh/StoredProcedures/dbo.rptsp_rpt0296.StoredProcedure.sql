USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0296]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0296]
	@SFTPGroups varchar(max) = 'AP,MB',
    @SFTPPath varchar(1024)
  
as
begin

    --declare @SFTPPath varchar(1024)
    declare @dirCmd varchar(1024)
    declare @output table (id int identity (1, 1), string varchar(1024))
    declare @groups table (groupcode varchar(max))
    declare @groupcode varchar(max)
    declare ccodes cursor local for 
		select 
			groupcode
		from
			@groups
    
    if @SFTPGroups is null
    begin
    
		set @dirCmd = 'dir /B ' + @SFTPPath

		insert into @groups (groupcode)
		exec master.dbo.xp_cmdshell @dirCmd
    
    end
    
    insert into @groups
    select item
    from
		dbo.fn_DelimitedSplit8K(@SFTPGroups, ',')

	open ccodes		
	
	fetch next from ccodes into @groupcode

    while @@fetch_status = 0
    begin

		set @dirCmd = 'dir /od ' + @SFTPPath + '\' + @groupcode + '\backup\' + replace(convert(varchar(10), getdate(), 120), '-', '')

		insert into @output (string)
		exec master.dbo.xp_cmdshell @dirCmd
		
		fetch next from ccodes into @groupcode
		
	end

	close ccodes
	deallocate ccodes
	
	select 
		left(string, 21) [TimeStamp],
		ltrim(substring(string, 25, 14)) Size,
		substring(string, 40, len(string) - 40 + 1) [FileName]
	from 
		@output
	where 
		string like '%.txt' or
		string like '%.csv' or
		string like '%.xls' or
		string like '%MAS%'

end


GO
