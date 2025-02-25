USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Data_Reconciliation_Query]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[etlsp_Data_Reconciliation_Query] 
	-- Add the parameters for the stored procedure here
				@Domain varchar(10),
                @Companykey varchar(10),
				@Metric  varchar(50),  
				@Sourceserver varchar(50),
				@Sourcedatabase   varchar(50),
		        @Sourcetable  varchar(50),
				@Targetserver varchar(50),
				@Targetdatabase   varchar(50) ,
				@Targettable varchar(50) ,
				@ReconStartDate   datetime,
				@ReconEndDate     datetime,
				@Pen_QuerySql	 varchar(max) out,
				@Dwh_QuerySql  varchar(max) out,
				@message         varchar(max) out,
				@LocalStartDatetime datetime out ,
				@LocalEndDatetime datetime out	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/****************************************************************************************************/
-- Name  :      
-- Author:		Sri Sailesh Pandravada
-- Create date: 2019-01-08
-- Description:	Data Reconciliation Query Program
--               
-- Parameters:  @Domain - Country
--              @Companykey- Company E.g 'CM','TIP'
--				@Metric    - Aggregation
--				@Sourceserver
--		        @Sourcetable
--				@DestinationServer
--				@Destinationtable
--				@Sourcedatabase
--				@Targetdatabase
--				@Pen_QuerySql
--				Dwh_QuerySql
--              @ReconStartDate- Reconciliation Starting Date
--				@ReconEndDate  - Reconciliation Ending Date
-- Change History: 20190109 - Sri - Created
/****************************************************************************************************/
----Local Variable---
	declare @Timezone           varchar(50) = null	
--	declare @LocalStartDatetime datetime = null
--	declare @LocalEndDatetime   datetime  = null
	declare @schema             varchar(10) = '[dbo]'
--	declare @Pen_QuerySql       nvarchar(max) 
--	declare @Dwh_QuerySql       nvarchar(max)
	DECLARE @Dwh_count TABLE (cnt float)
	DECLARE @Pen_count TABLE (cnt1 float)
	declare @DomainKey          varchar(10) = null
	declare @DomainId           varchar(10) = null
	declare @Pen_cnt            int
	declare @Dwh_cnt		    int

-----Based on the Domain , get the Time Zone and Store it a local variable    
	select top 1
        @Timezone = TimeZoneCode,
		@DomainKey = DomainKey,
		@DomainId  = DomainID
    from
        [db-au-cmdwh].dbo.penDomain
    where
        CountryKey = @Domain	

   
    set @ReconStartDate = dateadd(MS, 1, dateadd(day, datediff(day, 0,@ReconStartDate ), 0)) 
    set @ReconEndDate   = dateadd(MS, 1, dateadd(day, datediff(day, 0, @ReconEndDate )+1, 0))

---Convert the UTC datetime to local date time 
	set @LocalStartDatetime = [db-au-stage].dbo.xfn_ConvertUTCtoLocal(@ReconStartDate, @Timezone) 
	set @LocalEndDatetime   = [db-au-stage].dbo.xfn_ConvertUTCtoLocal(@ReconEndDate, @Timezone)
	
	if @Metric = 'PolicyCount'
		     
			set @Pen_QuerySql = 'select sum(case when pt.TransactionType = 1 and pt.TransactionStatus = 1 then 1
												 when pt.TransactionType = 1 and pt.TransactionStatus = 2 then -1
                                          else 0
                                        end) PolicyCount
			             from' + ' ' + @Sourceserver +'.'+ @Sourcedatabase+'.'+@schema+'.'+ 'tblPolicyTransaction pt inner join ' + @Sourceserver +'.'+ @Sourcedatabase+'.'+@schema+'.'+ 
                       'tblPolicy pp on pt.PolicyID = pp.PolicyID  
						 where 
						 convert(date,TransactionDateTime) ' + '>= ' +'''' + convert(varchar,@ReconStartDate,120)  + '''' +' and ' + 
						 'convert(date,TransactionDateTime) ' +  '<= ' + '''' + convert(varchar,@ReconEndDate,120) +'''' + ' and ' +
						 'pp.domainid = ' + ''''+@DomainId+''''  

				
	       insert into @Pen_count
		         exec(@Pen_QuerySql) 
           
		   set @Pen_cnt =  ( select cnt1 from @Pen_count) 

           set @Dwh_QuerySql = 'select sum(case when pt.TransactionType = ''Base'' and pt.TransactionStatus = ''Active'' then 1
                                                when pt.TransactionType = ''Base'' and pt.TransactionStatus like ''Cancelled%'' then -1
                                                else 0
                                           end) PolicyCount
                                from' + ' ' + @Targetserver +'.'+ @Targetdatabase+'.'+@schema+'.'+ 'PenPolicyTransaction pt inner join ' + @Targetserver +'.'+ @Targetdatabase+'.'+@schema+'.'
								+ 'PenPolicy pp on pt.PolicyID = pp.PolicyID
                                where 
								    TransactionDateTime ' + '>= ' +'''' + convert(varchar,@LocalStartDatetime,120) + '''' +' and ' + 
									'TransactionDateTime ' +  '< ' + '''' +convert(varchar,@LocalEndDatetime,120)+'''' + ' and '  +
									'pp.DomainKey = ' + ''''+@DomainKey+''''
			
		   insert into @Dwh_count
		   exec(@Dwh_QuerySql) 
           
		   set @Dwh_cnt =  ( select cnt from @Dwh_count) 
	
	if isnull(@Metric,'') = '' 
		set @message = 'Cannotsendablankmetric'
			--------Write the Output to ReconOutputData--------

	if isnull(@Metric,'') <> ''
	  Insert into 
	       [ULDWH02].[db-au-workspace].[dbo].ReconOutputData
	  values (@Metric,
				@Pen_cnt,
				@Dwh_cnt,
				@ReconStartDate,
				@ReconEndDate,
				Getdate()
	       )


END


GO
