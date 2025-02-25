USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[e5_Missingclaims_ReferenceNUmber_WorkEvent]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[e5_Missingclaims_ReferenceNUmber_WorkEvent] --'2024-07-01','2025-01-09'  
@startdate datetime,  
@enddate datetime  
  
as  
begin  
  
if object_id('#E5workevent_New') is not null                      
        drop table #E5workevent_New      
  
select * into #E5workevent_New  from (select c.Work_id,c.event_id,c.eventuser,Metadata,a.Reference from [covermoresql.e5workflow.com,60500].[e5_content_covermore].[dbo].[work] as a inner join   
(  
select Original_Work_ID,Reference from [db-au-cmdwh].dbo.e5Work_v3 as a  where Reference is not null and   
ClaimKey is null and convert(date,a.CreationDate,103)>=convert(date,@startdate,103) and convert(date,@startdate,103)<convert(date,@enddate,103) and StatusName='Active'   
) as b on a.Reference=b.Reference and a.id=b.Original_Work_ID  
inner join [covermoresql.e5workflow.com,60500].[e5_content_covermore].[dbo].[workevent] as c on a.id=c.Work_Id  
and Event_Id='420') as a  
  
  
select distinct work_id,event_id,claimnumber,Reference from (    
select work_id,event_id,linetitle as claimnumber,linecategorycode,Reference from  (              
select * from (              
select  *  from #E5workevent_New             
as a with(nolock) cross apply openjson(a.Metadata)              
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
  
ENd
GO
