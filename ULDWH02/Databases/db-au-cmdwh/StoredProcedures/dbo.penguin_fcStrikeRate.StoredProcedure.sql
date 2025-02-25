USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[penguin_fcStrikeRate]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Akanksha Khemka
-- Create date: 08/10/2012
-- Description:	Gets FC strike rate given the Alphacode and userid
-- =============================================
CREATE PROCEDURE [dbo].[penguin_fcStrikeRate] 	

	@AlphaCode varchar(33)
	, @DomainId int 

AS
BEGIN
	--SELECT  @AlphaCode='FLQ1859', @DomainId=7
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @OutletAlphaKey varchar(33)
		
		
select @OutletAlphaKey = penOutlet.OutletAlphaKey
from penOutlet 
where AlphaCode = @AlphaCode 
	  and OutletStatus = 'Current'
	  AND TradingStatus='Stocked'	  
	  and DomainId = @DomainId

if @OutletAlphaKey IS NULL
begin
	RAISERROR('Invalid Outlet or outlet not current.',10,4)
end	


DECLARE @PreviousMonth int, @CurrentYear int, @PreviousYear int
SET @PreviousMonth = DATEPART(mm, DATEADD(mm,-1,getdate()))
IF @PreviousMonth = 12
BEGIN
	SET @CurrentYear = DATEPART(yy, DATEADD(yy,-1,getdate()))
	SET @PreviousYear = DATEPART(yy, DATEADD(yy,-2,getdate()))
END
ELSE
BEGIN
	SET @CurrentYear = DATEPART(yy, GETDATE())
	SET @PreviousYear = DATEPART(yy, DATEADD(yy,-1,getdate()))
end
--http://stackoverflow.com/questions/266924/create-a-date-with-t-sql
DECLARE @LastMonthStartDate AS DATETIME = dateadd(mm, (@CurrentYear - 1900) * 12 + @PreviousMonth - 1 , 0)
--http://stackoverflow.com/questions/1051488/get-the-last-day-of-the-month-in-sql
DECLARE @LastMonthEndDate AS DATETIME = DATEADD(month, ((YEAR(@LastMonthStartDate) - 1900) * 12) + MONTH(@LastMonthStartDate), -1)

DECLARE @LastMonthLastYearStartDate AS DATETIME = dateadd(mm, (@PreviousYear - 1900) * 12 + @PreviousMonth - 1 , 0)
DECLARE @LastMonthLastYearEndDate AS DATETIME = DATEADD(month, ((YEAR(@LastMonthLastYearStartDate) - 1900) * 12) + MONTH(@LastMonthLastYearStartDate), -1)

declare @IntlTravellersCount int, @IntlTicketsCountCurrentYear int, @IntlTicketsCountPreviousYear int, @IntlPolicyCount int, @TravellersCount int

declare @IntlTravellersCountCurrentYear INT
, @IntlTravellersCountLastYear INT

SELECT
 @IntlTravellersCountCurrentYear  = SUM(pts.InternationalTravellersCount)
from
      penPolicyTransSummary pts       
where
      pts.OutletAlphaKey = @OutletAlphaKey and
      pts.IssueDate between @LastMonthStartDate and @LastMonthEndDate   

SELECT
 @IntlTravellersCountLastYear  = SUM(pts.InternationalTravellersCount)
from
      penPolicyTransSummary pts       
where
      pts.OutletAlphaKey = @OutletAlphaKey and
      pts.IssueDate between @LastMonthLastYearStartDate and @LastMonthLastYearEndDate   


select @IntlTicketsCountCurrentYear = sum(f.FLTicketCountINT)
from usrFLTicketData f
where f.OutletAlphaKey = @OutletAlphaKey 
and DATEPART(mm, f.IssuedDate) = @PreviousMonth AND DATEPART(yy, f.IssuedDate) = @CurrentYear

select @IntlTicketsCountPreviousYear = sum(f.FLTicketCountINT)
from usrFLTicketData f
where f.OutletAlphaKey = @OutletAlphaKey and DATEPART(mm, f.IssuedDate) = @PreviousMonth AND DATEPART(yy, f.IssuedDate) = @PreviousYear


declare @StoreStrikeRatePreviousYear float, @StoreStrikeRateCurrentYear float

select @StoreStrikeRateCurrentYear = case when @IntlTicketsCountCurrentYear = 0 then 0
								else round((@IntlTravellersCountCurrentYear/ cast( @IntlTicketsCountCurrentYear as float) * 100),1)
						 end		

select @StoreStrikeRatePreviousYear = case when @IntlTicketsCountPreviousYear = 0 then 0
								else round((@IntlTravellersCountLastYear / cast( @IntlTicketsCountPreviousYear as float) * 100),1)
						 end		

select  @StoreStrikeRateCurrentYear as StoreStrikeRateCurrentYear, @StoreStrikeRatePreviousYear AS StoreStrikeRatePreviousYear

END



GO
