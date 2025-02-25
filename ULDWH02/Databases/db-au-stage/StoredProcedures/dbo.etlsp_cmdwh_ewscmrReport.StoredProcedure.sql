USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ewscmrReport]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_ewscmrReport]  @DateRange varchar(30),
												  @StartDate varchar(10),
												  @EndDate varchar(10)
as
begin


/*
	20150818 - LT - created
*/

    set nocount on
    
--uncomment to debug
/*
	declare	@DateRange varchar(30)
	declare	@StartDate varchar(10)
	declare	@EndDate varchar(10)
	select @DateRange = '_User Defined', @StartDate = '2015-05-01', @EndDate = '2015-08-17'
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
        @SubjectArea = 'EWS CovermoreReport',
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


      
    if object_id('tempdb..#ewscmrReport') is not null
        drop table #ewscmrReport

	 --split email addresss into individual rows
	;with cte_tmp 
	(
		Sender,
		SentDateTime, 
		Report, 
		Recipient, 
		ToAddress,
		ReplyToAddress
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
			STUFF(ToAddress, 1, CHARINDEX(',',ToAddress+','), '') as ToAddress,
			ReplyToAddress
		from 
			[db-au-cmdwh].dbo.ewscmrEmail
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
			STUFF(ToAddress, 1, CHARINDEX(',',ToAddress+','), '') as ToAddress,
			ReplyToAddress
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
		case when Recipient like '%covermorereport@covermore.com.au%' then ltrim(rtrim(ReplyToAddress))
		     else ltrim(rtrim(Recipient))
		end as Recipient,
		case when Report like '%undeliverable%' then 1 else 0 end as isUndeliverable,
		case when Report like '%out%of%office%' then 1 else 0 end as isOutOfOffice,
		case when Report like '%Automatic%reply%' or (Report not like '%undeliverable%' or Report not like '%out%of%office') then 1 else 0 end as isAutomaticReply
	into #ewscmrReport
	from cte_tmp
	where
		(
			Report not like '%SQL Server Job%'
		) and
		Recipient <> ''


	if object_id('tempdb..#ewscmrReportCC') is not null drop table #ewscmrReportCC		 
	 --split CC email addresss into individual rows
	;with cte_tmp 
	(
		Sender,
		SentDateTime, 
		Report, 
		Recipient, 
		ToAddress,
		ReplyToAddress
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
			STUFF(CCAddress, 1, CHARINDEX(';',CCAddress+';'), '') as ToAddress,
			ReplyToAddress
		from 
			[db-au-cmdwh].dbo.ewscmrEmail
		where
			SentDateTime >= @rptStartDate and
			SentDateTime < dateadd(d,1,@rptEndDate) and
			ToAddress not like '%covermorereport@covermore.com.au'	--exclude bounce emails with CC as these are not originally CC'd recipients
								
		union all
		
		select			--recursive query
			Sender,
			SentDateTime,
			case when replace(Report,'Re: ','') like '%- ____-__-__-__-__-__' then substring(replace(Report,'Re: ',''),1,len(replace(Report,'Re: ',''))-len('- ____-__-__-__-__-__'))
				 else replace(Report,'Re: ','')
			end as Report,
			LEFT(ToAddress, CHARINDEX(';',ToAddress+';')-1) as Recipient,
			STUFF(ToAddress, 1, CHARINDEX(';',ToAddress+';'), '') as ToAddress,
			ReplyToAddress
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
		case when Report like '%undeliverable%' then 1 else 0 end as isUndeliverable,
		case when Report like '%out%of%office%' then 1 else 0 end as isOutOfOffice,
		case when Report like '%Automatic%reply%' or (Report not like '%undeliverable%' or Report not like '%out%of%office') then 1 else 0 end as isAutomaticReply
	into #ewscmrReportCC
	from cte_tmp
	where
		(
			Report not like '%SQL Server Job%'
		) and
		Recipient <> ''


  if object_id('[db-au-cmdwh].dbo.ewscmrReport') is null
    begin
    
        create table [db-au-cmdwh].dbo.ewscmrReport
        (
            [BIRowID] bigint not null identity(1,1),
			[Sender] nvarchar(320) null,
            [SentDateTime] datetime null,
            [Report] nvarchar(1024) null,
			[Recipient] nvarchar(1024) null,
			[RecipientType] nvarchar(50) null,
			[isUndeliverable] bit null,
			[isOutOfOffice] bit null,
			[isAutomaticReply] bit null
        )

        create clustered index idx_ewscmrReport_BIRowID on [db-au-cmdwh].dbo.ewscmrReport(BIRowID)
		create nonclustered index idx_ewscmrReport_Sender on [db-au-cmdwh].dbo.ewscmrReport(Sender)
        create nonclustered index idx_ewscmrReport_SendDateTime on [db-au-cmdwh].dbo.ewscmrReport(SendDateTime)
        create nonclustered index idx_ewscmrReport_Report on [db-au-cmdwh].dbo.ewscmrReport(Report)
        create nonclustered index idx_ewscmrReport_Recipient on [db-au-cmdwh].dbo.ewscmrReport(Recipient)
        create nonclustered index idx_ewscmrReport_RecipientType on [db-au-cmdwh].dbo.ewscmrReport(RecipientType)
    end
  else
	begin
		delete a
		from
			[db-au-cmdwh].dbo.ewscmrReport a
			inner join #ewscmrReport b on
				a.Sender = b.Sender and
				convert(date,a.SentDateTime) = convert(date,b.SentDateTime) and
				a.Report = b.Report and
				a.Recipient = b.Recipient

		delete a
		from
			[db-au-cmdwh].dbo.ewscmrReport a
			inner join #ewscmrReportCC b on
				a.Sender = b.Sender and
				convert(date,a.SentDateTime) = convert(date,b.SentDateTime) and
				a.Report = b.Report and
				a.Recipient = b.Recipient
	end

       
    begin transaction

    begin try
    
        insert into [db-au-cmdwh]..ewscmrReport
        (
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			RecipientType,
			isUndeliverable,
			isOutOfOffice,
			isAutomaticReply
        )
        select 
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			case when (Recipient like '%covermore%' or Recipient like '%Medical%') then 'Internal'
				 else 'External'
			end as RecipientType,
			isUndeliverable,
			isOutOfOffice,
			case when isOutOfOffice = 1 and isAutomaticReply = 1 then 0
				 else isAutomaticReply
			end as isAutomaticReply
        from
            #ewscmrReport

		union all

        select 
			Sender,
			SentDateTime, 
			Report, 
			Recipient,
			case when Recipient like '%@%' and (Recipient like '%covermore%' or Recipient like '%Medical%') then 'Internal'
				 when Recipient like '%@%' and not(Recipient like '%covermore%' or Recipient like '%Medical%') then 'External'
				 else 'Internal'
			end as RecipientType,
			isUndeliverable,
			isOutOfOffice,
			0 as AutomaticReply
        from
            #ewscmrReportCC
	end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction
            
        exec syssp_genericerrorhandler 
            @SourceInfo = 'ewscmrEmail data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
