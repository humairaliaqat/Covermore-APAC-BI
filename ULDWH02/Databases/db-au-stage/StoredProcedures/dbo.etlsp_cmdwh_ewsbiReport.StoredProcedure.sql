USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ewsbiReport]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_ewsbiReport]  @DateRange varchar(30),
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
	select @DateRange = '_User Defined', @StartDate = '2014-11-01', @EndDate = '2015-07-15'
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


      
    if object_id('tempdb..#ewsbiReport') is not null
        drop table #ewsbiReport

	 --split email addresss into individual rows
	;with cte_tmp 
	(
		Sender,
		SentDateTime, 
		Report, 
		Recipient, 
		ToAddress
	)
	as 
	(
		select 
			SenderAddress as Sender,
			SentDateTime,
			case when replace(Subject,'Re: ','') like '%- ____-__-__-__-__-__' then substring(replace(Subject,'Re: ',''),1,len(replace(Subject,'Re: ',''))-len('- ____-__-__-__-__-__'))	--remove timestamp
				 else replace(Subject,'Re: ','')
			end as Report,
			LEFT(ToAddress, CHARINDEX(',',ToAddress+',')-1) as Recipient,
			STUFF(ToAddress, 1, CHARINDEX(',',ToAddress+','), '') as ToAddress
		from 
			[db-au-cmdwh].dbo.ewsbiEmail
		where
			SentDateTime >= @rptStartDate and
			SentDateTime < dateadd(d,1,@rptEndDate)
	
		union all
		
		select			--recursive query
			Sender,
			SentDateTime,
			case when replace(Report,'Re: ','') like '%- ____-__-__-__-__-__' then substring(replace(Report,'Re: ',''),1,len(replace(Report,'Re: ',''))-len('- ____-__-__-__-__-__'))
				 else replace(Report,'Re: ','')
			end as Report,
			LEFT(ToAddress, CHARINDEX(',',ToAddress+',')-1) as Recipient,
			STUFF(ToAddress, 1, CHARINDEX(',',ToAddress+','), '') as ToAddress
		from 
			cte_tmp
		where 
			ToAddress > ''
	)
	select distinct 
		lower(case when Sender like 'CoverMore%Report%' then 'CovermoreReport@covermore.com.au'
			      when Sender like 'Cover-More%' then 'CovermoreReport@covermore.com.au'
				  else Sender 
			 end) as Sender,
		SentDateTime, 
		replace(Report,'Re:','') as Report, 
		Recipient,
		case when (Recipient like '%covermore%' or Recipient like '%Medical%') then 'Internal'
			 else 'External'
		end as RecipientType
	into #ewsbiReport
	from cte_tmp
	where
		(
			Report not like '%SQL Server Job%'
		) and
		Recipient <> ''


	if object_id('tempdb..#ewsbiReportCC') is not null drop table #ewsbiReportCC		 
	 --split CC email addresss into individual rows
	;with cte_tmp 
	(
		Sender,
		SentDateTime, 
		Report, 
		Recipient, 
		ToAddress
	)
	as 
	(
		select 
			SenderAddress as Sender,
			SentDateTime,
			case when replace(Subject,'Re: ','') like '%- ____-__-__-__-__-__' then substring(replace(Subject,'Re: ',''),1,len(replace(Subject,'Re: ',''))-len('- ____-__-__-__-__-__'))	--remove timestamp
				 else replace(Subject,'Re: ','')
			end as Report,
			LEFT(CCAddress, CHARINDEX(';',CCAddress+';')-1) as Recipient,
			STUFF(CCAddress, 1, CHARINDEX(';',CCAddress+';'), '') as ToAddress
		from 
			[db-au-cmdwh].dbo.ewsbiEmail
		where
			SentDateTime >= @rptStartDate and
			SentDateTime < dateadd(d,1,@rptEndDate)
								
		union all
		
		select			--recursive query
			Sender,
			SentDateTime,
			case when replace(Report,'Re: ','') like '%- ____-__-__-__-__-__' then substring(replace(Report,'Re: ',''),1,len(replace(Report,'Re: ',''))-len('- ____-__-__-__-__-__'))
				 else replace(Report,'Re: ','')
			end as Report,
			LEFT(ToAddress, CHARINDEX(';',ToAddress+';')-1) as Recipient,
			STUFF(ToAddress, 1, CHARINDEX(';',ToAddress+';'), '') as ToAddress
		from 
			cte_tmp
		where 
			ToAddress > ''
	)
	select distinct 
		lower(case when Sender like 'CoverMore%Report%' then 'CovermoreReport@covermore.com.au'
			      when Sender like 'Cover-More%' then 'CovermoreReport@covermore.com.au'
				  else Sender 
			 end) as Sender,
		SentDateTime, 
		replace(Report,'Re:','') as Report, 
		ltrim(rtrim(Recipient)) as Recipient,
		case when Recipient like '%@%' and (Recipient like '%covermore%' or Recipient like '%Medical%') then 'Internal'
			 when Recipient like '%@%' and not(Recipient like '%covermore%' or Recipient like '%Medical%') then 'External'
			 else 'Internal'
		end as RecipientType
	into #ewsbiReportCC
	from cte_tmp
	where
		(
			Report not like '%SQL Server Job%'
		) and
		Recipient <> ''



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
		create nonclustered index idx_ewsbiReport_Sender on [db-au-cmdwh].dbo.ewsbiReport(Sender)
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
			inner join #ewsbiReport b on
				a.Sender = b.Sender and
				convert(date,a.SentDateTime) = convert(date,b.SentDateTime) and
				a.Report = b.Report and
				a.Recipient = b.Recipient

		delete a
		from
			[db-au-cmdwh].dbo.ewsbiReport a
			inner join #ewsbiReportCC b on
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
            #ewsbiReport

		union all

        select 
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			RecipientType
        from
            #ewsbiReportCC
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
