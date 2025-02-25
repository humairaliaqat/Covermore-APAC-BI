USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL120_ReconciliationEngine]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[etlsp_ETL120_ReconciliationEngine]
	-- Add the parameters for the stored procedure here
		@ReconStartDate date,                  --Optional. Format YYYY-MM-DD
		@ReconEndDate date                     --Optional. Format YYYY-MM-DD
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****************************************************************************************************/
-- Name  :      
-- Author:		Sri Sailesh Pandravada
-- Create date: 2019-01-08
-- Description:	Data Reconciliation Engine driver ETL. 
--				Reads the Reconciliation Meta Data.
--				Calls a procedure to define an Query.	
--               
-- Parameters:  @ReconStartDate- Reconciliation Starting Date
--				@ReconEndDate  - Reconciliation Ending Date
-- Change History: 20190109 - Sri - Created
/****************************************************************************************************/
    -- Local Variable
	declare @Pen_QuerySql  varchar(max)
	declare @message  varchar(max)
	declare @Dwh_QuerySql  varchar(max)
    declare @Domain        varchar(10)
	declare @Companykey    varchar(10)
	declare @Metric		   varchar(50)
	declare @Sourceserver  varchar(50)
	declare @Sourcedatabase  varchar(50)
	declare @Sourcetable   varchar(50)
	declare @Targetserver  varchar(50)
	declare @Targetdatabase  varchar(50)
	declare @Targettable     varchar(50)
	declare @Pen_cnt       int
	declare @Dwh_cnt       int
	declare @LocalStartDatetime datetime ,
			@LocalEndDatetime datetime 	
	
	if object_id('tempdb..#Recontbl') is not null 
        drop table #Recontbl
        
    create table #Recontbl
    (
        Domain     varchar(10) null,
		Companykey varchar(50) null,
		Metric     varchar(50) null,
		SourceServer varchar(50) null,
		SourceTable  varchar(50) null,
		SourceDataBase varchar(50) null,
		TargetServer varchar(50) null,
		TargetDataBase varchar(50) null, 
		TargetTable  varchar(50) null,
		
	 )

	 declare CUR_ReconCommand cursor for 
        select 
            Domain,
			Companykey,
		    Metric,
		    SourceServer,
		    SourceTable,
		    SourceDataBase,
		    TargetServer,
		    TargetDataBase,
		    TargetTable
        from 
            #Recontbl

	Insert #Recontbl
		( 
		  Domain,
		  Companykey,
		  Metric,
		  SourceServer,
		  SourceTable,
		  SourceDataBase,
		  TargetServer,
		  TargetDataBase,
		  TargetTable
		 )
		 Select 
		      Countrykey as Domain,
			  CompanyKey,
			  Metric,
			  SourceServer,
			  SourceTable,
			  SourceDataBase,
			  DestinationServer as  TargetServer,
			  DestinationDataBase as TargetDatabase,
			  DestinationTable   as Targettable
 		 from 
		     [ULDWH02].[db-au-workspace].[dbo].ReconInputData



	--For each Recon Meta data records, fetch data as per metric

    open CUR_ReconCommand
    fetch NEXT from CUR_ReconCommand into @Domain, @Companykey,@Metric,
	                                      @Sourceserver,@Sourcetable,@Sourcedatabase,
										  @Targetserver,@Targetdatabase,@Targettable
	while @@fetch_status = 0
    begin
	    
		 exec [ULDWH02].[db-au-workspace].[dbo].[etlsp_Data_Reconciliation_Query]  @Domain, @Companykey,@Metric,
	                                                                @Sourceserver,@Sourcedatabase,@Sourcetable,
										                            @Targetserver,@Targetdatabase,@Targettable,
																	@ReconStartDate,@ReconEndDate,
										                          @Pen_QuerySql out, @Dwh_QuerySql out,
																  @message out, @LocalStartDatetime  out,@LocalEndDatetime  out	
																 --Dwh_QuerySql,@Pen_cnt ,
																--	@Dwh_cnt  
		print(@Metric)
		print(@Pen_QuerySql)
		print(@Dwh_QuerySql)
		print(@LocalStartDatetime)
		print(@LocalEndDatetime)
		print(@message)

		fetch NEXT from CUR_ReconCommand into @Domain, @Companykey,@Metric,
	                                      @Sourceserver,@Sourcetable,@Sourcedatabase,
										  @Targetserver,@Targetdatabase,@Targettable

	 
	end
	    close CUR_ReconCommand   
	    deallocate CUR_ReconCommand
END

GO
