USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_travelfile]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_travelfile]	@DateRange varchar(30),
												@StartDate date = null,
												@EndDate date = null   
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:          rawsp_travellerfile
--  Author:        Linus Tor
--  Date Created:  20150722
--  Description:   Output traveller data for Medibank
--  Parameters:    @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20150722 - LT - Created
--					20150807 - LT - Added TransactionNumber, TransactionDate, TransactionType,
--									TransactionStatus, SellPrice and Commission. 
--					20150813 - LT - Modified query to match RPT0313MB report business rules
--									
--
/****************************************************************************************************/
--uncomment to debug

/*
declare 
	@DateRange varchar(30),
	@StartDate date,
	@EndDate date
select 
	@DateRange = 'Last Month'
*/

declare @dataStartDate date
declare @dataEndDate date

/* get dates */
if @DateRange = '_User Defined'
    select 
        @dataStartDate = @StartDate,
        @dataEndDate = @EndDate

else
    select 
        @dataStartDate = StartDate, 
        @dataEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


SELECT 
  p.PolicyNumber,
  pts.PolicyNumber as TransactionNumber,
  pt.HomeState,
  isnull(pts.StoreCode,'') as SOC,
  convert(date,p.IssueDate) as IssueDate,
  convert(date,pts.PostingDate) as TransactionDate,
  pts.TransactionType,
  pts.TransactionStatus,
  pt.MembershipNumber,
  u.UserID,
  pt.isPrimary,
  sum(vp.[Sell Price (excl GST)]) as SellPrice,
  sum(vp.[Agency Commission]) as Commission,
  sum(pts.BasePolicyCount) as PolicyCount
FROM
  penPolicy p
  inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
  inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
  inner join vPenguinPolicyPremiums vp on pts.PolicyTransactionKey=vp.PolicyTransactionKey
  outer apply
  (
	select top 1 Login as UserID
	from penUser
	where 
		UserKey = pts.UserKey and 
		UserStatus = 'Current'
  ) u
  outer apply
  (
	select top 1
		[State] as HomeState, MemberNumber as MembershipNumber,
		isPrimary
	from
		penPolicyTraveller
	where
		PolicyKey = p.PolicyKey and
		isPrimary = 1
   ) pt
WHERE
   p.CountryKey  =  'AU' and
   o.SuperGroupName  =  'Medibank' and
   pts.PostingDate between @dataStartDate and @dataEndDate
group by
  p.PolicyNumber,
  pts.PolicyNumber,
  pt.HomeState,
  isnull(pts.StoreCode,''),
  convert(date,p.IssueDate),
  convert(date,pts.PostingDate),
  pts.TransactionType,
  pts.TransactionStatus,
  pt.MembershipNumber,
  u.UserID,
  pt.isPrimary
Order by 1,2
GO
