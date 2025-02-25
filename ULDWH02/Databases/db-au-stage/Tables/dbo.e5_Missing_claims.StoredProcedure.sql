USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[e5_Missing_claims]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[e5_Missing_claims] --'2024-07-01','2025-01-09'

@StartDate datetime,
@EndDate datetime
as
begin

if object_id('#workevent_') is not null                  
        drop table #workevent_    

select  * into #workevent_  from [covermoresql.e5workflow.com,60500].[e5_content_covermore].[dbo].[workevent] with(nolock)  where work_id in (
 select Original_Work_ID from  [db-au-cmdwh].[dbo].e5Work_v3 as c with(nolock) where ClaimNumber is null and convert(date,c.CreationDate,103) >= convert(date,@StartDate,103)
 and CompletionDate is null and convert(date,c.CreationDate,103) < convert(date,@EndDate,103) )



select distinct work_id,event_id,claimnumber from (
select work_id,id,event_id,linetitle as claimnumber,linecategorycode from  (          
select * from (          
select  *  from #workevent_         
as a with(nolock) cross apply openjson(a.metadata)          
   ) as a        
where           
[key]='PropertyChanges'          
) as a outer apply          
openjson (          
     json_query(          
        value,          
        '$'          
     )          
   )          
  with (          
      linetitle varchar(255) '$.PreviousValue',          
      linecategorycode varchar(255) '$.PropertyId'         
   ) as r  ) as a  where linecategorycode='ClaimNumber' and claimnumber is not null




 end
GO
