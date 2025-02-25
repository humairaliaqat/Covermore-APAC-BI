USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_start_job_and_wait]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[syssp_start_job_and_wait]
(
	@job_name sysname,
	@initial_wait_time datetime, 
	@recurring_wait_time datetime = '00:00:05'
)
as

begin 

	--  0 = Failed 
	--  1 = Succeeded 
	--  2 = Retry 
	--  3 = Canceled 
	--  4 = In progress 

	declare @status int     

	set @status = [msdb].dbo.fn_GetJobStatus(@job_name)


	-- start the job if it's not currently running
	if @status not in (2, 4) 
		execute msdb.dbo.sp_start_job @job_name = @job_name


	waitfor delay @initial_wait_time


	set @status = [msdb].dbo.fn_GetJobStatus(@job_name)

	
	while @status in (2, 4) 
	begin
		waitfor delay @recurring_wait_time 
		set @status = [msdb].dbo.fn_GetJobStatus(@job_name)
	end


	declare @error varchar(1000) = ''

	if @status = 0 
		set @error = 'Job ''' + @job_name + ''' failed'

	if @status = 3 
		set @error = 'Job ''' + @job_name + ''' was cancelled'


	if @error <> ''
		raiserror(@error, 16, 1)

end 




GO
