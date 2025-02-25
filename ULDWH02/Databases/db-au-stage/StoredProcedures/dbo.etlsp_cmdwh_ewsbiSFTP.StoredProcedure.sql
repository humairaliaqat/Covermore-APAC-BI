USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ewsbiSFTP]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_ewsbiSFTP]  @DateRange varchar(30),
											   @StartDate varchar(10),
											   @EndDate varchar(10)
as
begin


/*
    20150617 - LT - created
	20150716 - LT - fixed bug with record deletion.
					added parameters to stores proc, and limit the data selection to the date range
*/

    set nocount on

--uncomment to debug
/*
	declare	@DateRange varchar(30)
	declare	@StartDate varchar(10)
	declare	@EndDate varchar(10)
	select @DateRange = 'Last Fiscal Month', @StartDate = null, @EndDate = null
*/

	declare @rptStartDate datetime
	declare @rptEndDate datetime


	/* get reporting dates */
	if @DateRange = '_User Defined'
	  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
	else
	  select @rptStartDate = StartDate, @rptEndDate = EndDate
	  from [db-au-cmdwh].dbo.vDateRange
	  where DateRange = @DateRange
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int,
        @deletetime datetime
        
    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'EWS BI',
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

	declare @SFTPDirectory varchar(255)
	select @SFTPDirectory = '\\ulwibs01.aust.dmz.local\sftpshares\'


	if object_id('tempdb..#DirTree') is not null drop table #DirTree
	create table #DirTree
	(
		ID int identity(1,1),
		SubDirectory nvarchar(255),
		Depth smallint,
		FileFlag bit,
		ParentDirectoryID int
	)

	insert #DirTree (SubDirectory, Depth, FileFlag)
	exec master..xp_dirtree @SFTPDirectory, 10, 1

	--update parent directory id
	update #DirTree
	set ParentDirectoryID = (select max(ID) 
							 from #DirTree d2
							 where Depth = d.Depth - 1 and d2.ID < d.ID
							)
	from #DirTree d


	if object_id('tempdb..#SFTP') is not null drop table #sftp
	;with cte_SFTP as
	(
		select distinct
			case when pd.Depth = 1 then pd.SubDirectory else '' end as ParentDirectory,
			sd.SubDirectory,
			cd.CreateDate,
			fn.[FileName]
		from
			#DirTree pd
			outer apply
			(
				select isnull(SubDirectory,'') as SubDirectory, ID
				from #DirTree
				where 
					Depth = 2 and 
					ParentDirectoryID = pd.ID
			) sd
			outer apply
			(
				select isnull(SubDirectory,'') as CreateDate, ID
				from #DirTree
				where 
					Depth = 3 and 
					ParentDirectoryID = sd.ID
			) cd
			outer apply
			(
				select isnull(SubDirectory,'') as [Filename]
				from #DirTree
				where
					Depth = 4 and
					ParentDirectoryID = cd.ID
			) fn
		where
			(case when pd.Depth = 1 then pd.SubDirectory else '' end) <> '' and
			fn.[FileName] not like '%transfer%' and
			sd.SubDirectory = 'Backup'
	)
	select
		'SFTP' as Sender,
		convert(datetime,CreateDate) as SentDateTime,	
		case when [FileName] like '%____-__-__-__-__-__.___' then substring([FileName],1,len([FileName])-len(' ____-__-__-__-__-__.___'))
			 when [FileName] like '%____-__-__-__-__-__.____' then substring([FileName],1,len([FileName])-len('--____-__-__-__-__-__.___'))
			 when [FileName] like 'CAS_%' then 'IAL Travel Data'
			 when [FileName] like 'IAG%' then 'IAG NZ Flybuy Exception Report'
			 when [FileName] like 'IAL.%' then 'IAL Policy Extract'
			 when [FileName] like 'MAS%' then 'Malaysia Airlines Policy Extract'
			 else [FileName]
		end as Report,
		case when ParentDirectory like 'AP%' then 'Australia Post'
			 when ParentDirectory like 'AZ%' then 'Air New Zealand'
			when ParentDirectory like 'IAG%' then 'IAG NZ'
			 when ParentDirectory like 'IA%' then 'IAL'
			 when ParentDirectory like 'MA%' then 'Malaysia Airlines'
			 when ParentDirectory like 'MB' then 'Medibank'
			 when ParentDirectory like 'PMA' then 'PMA'
			 when ParentDirectory like 'RACV%' then 'RACV'
			 else ParentDirectory
		end as Recipient,
		'External' as RecipientType
	into #sftp
	from
		cte_SFTP



  if object_id('[db-au-cmdwh].dbo.ewsbiReport') is null
    begin
    
        create table [db-au-cmdwh].dbo.ewsbiReport
        (
            [BIRowID] bigint not null identity(1,1),
			[Sender] nvarchar(320) null,
            [SentDateTime] datetime null,
            [Report] nvarchar(1024) null,
			[Recipient] nvarchar(1024) null,
			[RecipientType] nvarchar(50) null
        )

        create clustered index idx_ewsbiReport_BIRowID on [db-au-cmdwh].dbo.ewsbiReport(BIRowID)
        create nonclustered index idx_ewsbiReport_SendDateTime on [db-au-cmdwh].dbo.ewsbiReport(SendDateTime)
        create nonclustered index idx_ewsbiReport_Report on [db-au-cmdwh].dbo.ewsbiReport(Report)
        create nonclustered index idx_ewsbiReport_Recipient on [db-au-cmdwh].dbo.ewsbiReport(Recipient)
        create nonclustered index idx_ewsbiReport_RecipientType on [db-au-cmdwh].dbo.ewsbiReport(RecipientType)
    end
  else
	begin
		delete a
		from
			[db-au-cmdwh].dbo.ewsbiReport a
			inner join #sftp b on
				a.Sender = b.Sender and
				convert(date,a.SentDateTime) = convert(date,b.SentDateTime) and
				a.Report = b.Report and
				a.Recipient = b.Recipient
	end	


    begin transaction

    begin try
    
        insert into [db-au-cmdwh]..ewsbiReport
        (
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			RecipientType
        )
        select 
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			RecipientType
        from
            #sftp
		where
			SentDateTime >= @rptStartDate and
			SentDateTime < dateadd(d,1,@rptEndDate)

	end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction
            
        exec syssp_genericerrorhandler 
            @SourceInfo = 'ewsbiEmail data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
