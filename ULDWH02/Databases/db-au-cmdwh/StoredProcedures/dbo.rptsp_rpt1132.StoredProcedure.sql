USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1132]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Shantanu Pardeshi>
-- Create date: <30/07/2021>
-- Description:	<To create report that showed first assessment date, user and last assessment date from e5>
-- =============================================


/****** Object:  StoredProcedure [dbo].[rptsp_rpt1132]   ******/


CREATE PROCEDURE [dbo].[rptsp_rpt1132]   
@Country varchar(2),
@DateRange varchar(30),  
@StartDate datetime,   
@EndDate datetime    
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  declare
	@PeriodStartDate datetime ,  
	@PeriodEndDate datetime  
  /* initialise dates */  
 if @DateRange = '_User Defined'  
  select @PeriodStartDate = @StartDate, @PeriodEndDate = @EndDate  
 else  
  select @PeriodStartDate = StartDate, @PeriodEndDate = EndDate  
  from [db-au-cmdwh].dbo.vDateRange  
  where DateRange = @DateRange  
  
select ew.Country,
ew.ClaimNumber,
ew.PolicyNumber,
ew.CreationDate,
b.FirstAssessmentDate,
b.FirstAssessmentBy,
b.FirstAssessmentOutcome,
b.LastAssessmentDate,
b.LastAssessmentBy,
b.LastAssessmentOutcome,
@PeriodStartDate as Startdate,
@PeriodEndDate as EndDate

from [db-au-cmdwh].dbo.e5Work ew
inner join [db-au-cmdwh].dbo.ve5Assessments b
on ew.Work_ID = b.Work_ID
where
ew.Country = @Country
and
ew.CreationDate > @PeriodStartDate
and
ew.CreationDate < dateadd(day,1,@PeriodEndDate)
END  


GO
