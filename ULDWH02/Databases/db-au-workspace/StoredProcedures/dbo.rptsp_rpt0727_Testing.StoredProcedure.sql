USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0727_Testing]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  


CREATE  procedure [dbo].[rptsp_rpt0727_Testing] --'_User Defined','2024-07-01','2025-01-09'

       @ReportingPeriod varchar(30),      
          @StartDate varchar(10),      
          @EndDate varchar(10)      
as      
      
SET NOCOUNT ON      
      
      
/****************************************************************************************************/      
-- Name:   dbo.rptsp_rpt0727      
-- Author:   Atit Wajanasomboonkul      
-- Date Created: 20151208      
-- Description: This stored procedure list missing claims from e5.      
--     Reporting period is based on job StartTime      
-- Parameters:  @ReportingPeriod: Value is valid date range      
--     @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01      
--     @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01      
--       
-- Change History: 20151208 - AW - Created      
--      
/****************************************************************************************************/      
      
--uncomment to debug      
/*      
declare @ReportingPeriod varchar(30)      
declare @StartDate varchar(10)      
declare @EndDate varchar(10)      
select @ReportingPeriod = 'Yesterday', @StartDate = null, @EndDate = null      
*/      
      
declare @rptStartDate smalldatetime      
declare @rptEndDate smalldatetime      
      
/* get reporting dates */      
if @ReportingPeriod = '_User Defined'      
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)      
else      
  select @rptStartDate = StartDate, @rptEndDate = EndDate      
  from [db-au-cmdwh].dbo.vDateRange      
  where DateRange = @ReportingPeriod      
        
      
if object_id('tempdb..#rpt0727_missingclaims') is not null drop table #rpt0727_missingclaims      
select      
 ol.OnlineClaimID,      
 [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(ol.OnlineCreateDate,'AUS Eastern Standard Time') OnlineClaimCreateDate,      
 c.ClaimNo,      
 c.CreateDate,      
 c.PolicyNo,      
 c.DomainID,      
 e.e5Reference,      
 e.e5CreateDate,      
 e.e5Status,      
 case when c.ClaimNo is not null then 'Y' else 'N' end as inNet,      
 case when e.e5Reference is not null then 'Y' else 'N' end as ine5,
 e.e5WorkID
       
into #rpt0727_missingclaims      
from       
 [db-au-cmdwh].dbo.clmClaim c      
 outer apply      
 (      
  select OnlineClaimID, UpdatedOn as OnlineCreateDate      
  from [db-au-penguinsharp.aust.covermore.com.au].claims.dbo.tblOnlineClaims      
  where      
   ClaimID = c.ClaimNo and      
   DomainID = c.DomainID      
 ) ol      
 outer apply      
 (      
  select       
   Reference as e5Reference,      
   CreationDate as e5CreateDate,      
   StatusName as e5Status,
   Original_Work_ID AS e5WorkID      
  from      
   [db-au-cmdwh].[dbo].e5Work_v3      
  where      
   ClaimKey = c.ClaimKey      
 ) e      
where       
 c.CreateDate >= @rptStartDate and      
 c.CreateDate < dateadd(day,1,@rptEndDate) --and      
 --c.OnlineClaim = 1       
-- and e.e5Reference is null   -- This logic commented because of INC0162507     
      
      
if (select count(*) from #rpt0727_MissingClaims) = 0       
 select      
  convert(int,null) as OnlineClaimID,      
  convert(datetime,null) as OnlineClaimCreateDate,      
  convert(int,null) as ClaimNo,      
  convert(datetime,null) as CreateDate,      
  convert(varchar(50),null) as PolicyNo,      
  convert(int,null) as DomainID,      
  convert(int,null) as e5Reference,      
  convert(datetime,null) as e5CreateDate,      
  convert(varchar(100),null) as e5Status,
  convert(varchar(100),null) as e5WorkID,      
  convert(varchar(1),null) as inNet,      
  convert(varchar(1),null) as ine5,        
  @rptStartDate as StartDate,      
  @rptEndDate as EndDate       
else      
 select      
  OnlineClaimID,      
  OnlineClaimCreateDate,      
  ClaimNo,      
  CreateDate,      
  PolicyNo,      
  DomainID,      
  e5Reference,      
  e5CreateDate,      
  e5Status,
  e5WorkID,      
  inNet,      
  ine5,         
  @rptStartDate as StartDate,      
  @rptEndDate as EndDate       
 from      
  #RPT0727_MissingClaims      
  WHERE ISNULL(inNet,'Y')='Y' AND ISNULL(ine5,'N')='N'  -- This logic added because of INC0162507   
GO
