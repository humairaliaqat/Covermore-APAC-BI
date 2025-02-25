USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL091_Penelope_Approved_Exception]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_ETL091_Penelope_Approved_Exception]  
as  
begin  
  
 --20180131, LL, pull approved exceptions  
  
--Uncommented below batch file execution part as a part of change CHG0032818  
 execute  
 (  
  'exec xp_cmdshell "E:\ETL\Script\dtc_exception.bat"'  
 )   
  
 if object_id('tempdb..#ae') is not null  
  drop table #ae  
  
 create table #ae  
 (  
  [LineID] bigint identity(1,1),  
  [Report No] varchar(100),  
  [ID] varchar(100),  
  [Combined ID] varchar(100),  
  [Comment] varchar(250)  
 )  
  
 insert into #ae  
 (  
  [Report No],  
  [ID],  
  [Combined ID],  
  [Comment]  
 )  
 select  
  [Report No],  
  --isnull(convert(varchar(max), [ID]), substring([Combined ID], charindex('-', [Combined ID]) + 1, 100)) [ID], --Commented this as a part of CHG0032818 and added below Case statement to derive ID field
  Case when [ID] IS NOT NULL THEN CAST(convert(int,[ID]) AS varchar(max))
  ELSE    Convert(varchar(max),(substring([Combined ID], charindex('-', [Combined ID]) + 1, 100)))
  END AS    [ID],
  [Combined ID],  
  [Comment]  
 from  
  openrowset  
  (  
   'Microsoft.ACE.OLEDB.12.0',  
   'Excel 12.0 Xml;Database=E:\ETL\Data\dtc_exceptions.xlsx',  
   '  
   select   
    *  
   from   
    [Exceptions$]  
   '  
  )  
  
 --select *  
 --from  
 -- #ae  
 --where  
 -- [Combined ID] like '6-77074%'  
 -- --[Report No] = 6 and  
 -- --[iD] like '%77074%'  
  
    if object_id('[db-au-dtc].[dbo].[EctnApproved]') is null  
    begin  
  
        create table [db-au-dtc].[dbo].[EctnApproved]  
        (  
         [ReportNo] [int] not null,  
         [ID] [int] not null,  
         [CombinedID] [varchar](50) not null,  
         [Comment] [varchar](50) not null,  
        )  
  
        create nonclustered index idx on [db-au-dtc].[dbo].[EctnApproved] ([ID],[ReportNo]) include ([Comment],[CombinedID])  
  
    end  
    else  
     truncate table [db-au-dtc]..EctnApproved  
  
 insert into [db-au-dtc]..EctnApproved  
 select   
  [Report No],  
  [ID],  
  [Combined ID],  
  isnull([Comment], '')  
 from  
  (  
   select   
    *,   
    row_number() over (partition by [Report No],[ID] order by LineID desc) Idx  
   from  
    #ae  
   where  
    try_convert(int, [Report No]) <> 0 and  
    try_convert(int, [ID]) <> 0  
  ) t  
 where  
  Idx = 1  
  
  
  
end  
GO
