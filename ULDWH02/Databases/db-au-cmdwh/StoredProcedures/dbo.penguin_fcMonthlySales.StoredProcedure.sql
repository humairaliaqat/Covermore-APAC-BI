USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[penguin_fcMonthlySales]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Akanksha Khemka
-- Create date: 08/10/2012
-- Description:	Gets FC sales data given the Alphacode and userid
-- =============================================
create PROCEDURE [dbo].[penguin_fcMonthlySales]
	@AlphaCode varchar(33), 
	@ConsultantUserName varchar(50),
	@DomainId int
AS
BEGIN
	--SELECT  @AlphaCode='FLA0150',@ConsultantUserName='jacinta', @DomainId=7
	--SELECT  @AlphaCode='fln0200',@ConsultantUserName='laura', @DomainId=7
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   declare @OutletAlphaKey varchar(33)
   , @OutletKey varchar(33)
   , @ConsultantKey varchar(50)

declare @HistoricalDataExists bit
		, @CurrentMonth int
		, @CurrentYear int
		, @PreviousYear int
		, @Target_Consultant money
		, @Target_Store money
		, @NoOfActiveConsultants int
		, @TotalStoreSales money
		, @ActualSales_Consultant money
		, @GrossSales_Consultant money
		, @TotalPolicies_Consultant int
		, @Rank_Consultant int
		, @CurrentFCAreaId int
		, @TotalRanks_Consultant int
		, @ActualSales_Store money
		, @GrossSales_Store money
		, @TotalPolicies_Store int
		, @Rank_Store int
		, @TotalRanks_Store int

declare @SalesTable table(ConsultantKey varchar(50), PolicyTransactionId int, TransactionType varchar(50), GrossPremium money)
declare @TotalPolCountTable table (ConsultantKey varchar(50), OutletAlphaKey varchar(50), TotalPolCount int)
declare @ConsultantRankTable table(Id varchar(50), NoOfPolicies int, [Rank] int)
declare @StoreRankTable table(Id varchar(50), NoOfPolicies int, [Rank] int)


select @OutletAlphaKey = penOutlet.OutletAlphaKey
		, @OutletKey = penOutlet.OutletKey
		, @HistoricalDataExists = case when penOutlet.CommencementDate <= DATEADD(m, -12, getdate()) then 1 else 0 end 
		, @CurrentFCAreaId = penOutlet.FCAreaID
from penOutlet 
where AlphaCode = @AlphaCode and OutletStatus = 'Current' AND TradingStatus ='Stocked' and DomainId = @DomainId

if @OutletAlphaKey is null
begin
	RAISERROR('Invalid Outlet or outlet not current.',10,4)
END

select @ConsultantKey = penUser.UserKey
from penUser 	
where penUser.Login = @ConsultantUserName and penUser.OutletKey = @OutletKey	
and penUser.UserStatus = 'Current' AND InactiveDate IS NULL 

if isnull(@ConsultantKey,N'') = N''
begin
	RAISERROR('Invalid Consultant or consultant not current.',10,4)
end

--select @HistoricalDataExists

--select @CurrentFCAreaId
set @PreviousYear = datepart(yy, DATEADD(yy, -1, getdate()))
set @CurrentYear = datepart(yy, GETDATE())
set @CurrentMonth = DATEPART(m, getdate())

if @HistoricalDataExists = 1
begin
	select @TotalStoreSales = sum(s.GrossPremium) * 1.1
	from penPolicyTransSummary s
	where s.OutletAlphaKey = @OutletAlphaKey
	--and s.TransactionType in ('Base', 'Variation')
	and datepart(m,s.IssueDate) = @CurrentMonth and DATEPART(yy, s.IssueDate) = @PreviousYear
	
	IF isnull(@TotalStoreSales,0) = 0 
		BEGIN
			set @Target_Store = 8000	
			set @Target_Consultant = 2000	
		END
	ELSE
		BEGIN
			set @Target_Store = @TotalStoreSales

			select @NoOfActiveConsultants = count(penUser.UserId)
			from penUser 
			where penUser.OutletKey = @OutletKey and penUser.UserStatus = 'Current' AND InactiveDate IS null
				
			set @Target_Consultant = @TotalStoreSales / case when @NoOfActiveConsultants = 0 then 1 else @NoOfActiveConsultants end			
		END
end
else
begin
	
	set @Target_Store = 8000	
	set @Target_Consultant = 2000	
end

insert into @SalesTable(ConsultantKey,PolicyTransactionId, TransactionType,GrossPremium)
select distinct s.UserKey, s.PolicyTransactionID, s.TransactionType, s.GrossPremium
from penPolicyTransSummary s
where s.OutletAlphaKey = @OutletAlphaKey
--and s.TransactionType in ('Base', 'Variation')
and datepart(m, s.IssueDate) = @CurrentMonth 
and DATEPART(yy, s.IssueDate) = @CurrentYear


insert into @TotalPolCountTable(ConsultantKey, OutletAlphaKey, TotalPolCount)
(
select transactionDetails.ConsultantKey, transactionDetails.OutletAlphaKey, count(transactionDetails.PolicyKey) as TotalPolicyCount
from
	(select distinct activeConsultant.UserKey as ConsultantKey
	 , policy.OutletAlphaKey as OutletAlphaKey
	 , policy.PolicyKey as PolicyKey
	 FROM
	 (
	 	SELECT pu.UserKey,po.OutletAlphaKey
	 	FROM penUser pu 
		INNER JOIN penOutlet po ON  pu.OutletKey = po.OutletKey
	 	WHERE     
	 		po.OutletStatus = 'Current' and
			pu.UserStatus = 'Current' and
			pu.InactiveDate is NULL AND
			po.FCAreaID=@CurrentFCAreaId		
	 ) AS activeConsultant
	 LEFT OUTER JOIN 
	(
	 SELECT s.PolicyKey,s.UserKey,s.OutletAlphaKey
	 FROM 
	 penPolicyTransSummary s 
	 inner join penPolicy policy on policy.PolicyKey = s.PolicyKey
	 where 
		datepart(m, s.IssueDate) = @CurrentMonth 
		and DATEPART(yy, s.IssueDate) = @CurrentYear
		and s.TransactionType = 'Base'
		and s.ParentID is null 
		and policy.StatusDescription = 'ACTIVE'
		and s.OutletAlphaKey in (select distinct penOutlet.OutletAlphaKey 
									from penOutlet 
									where penOutlet.FCAreaID = @CurrentFCAreaId
									and OutletStatus = 'Current' AND penOutlet.TradingStatus = 'Stocked'
		)
	) AS policy ON policy.UserKey=activeConsultant.UserKey AND policy.OutletAlphaKey = activeConsultant.OutletAlphaKey
) transactionDetails
group by transactionDetails.ConsultantKey, transactionDetails.OutletAlphaKey							
)
insert into @StoreRankTable(Id, NoOfPolicies, [Rank])
(
	select groupedTransDetails.OutletAlphaKey
	, groupedTransDetails.TotalPolCount
	, RANK() over (order by groupedTransDetails.TotalPolCount desc) as 'RANK'
	from 
	(select t.OutletAlphaKey
	, sum(t.TotalPolCount) as TotalPolCount
	from 
	@TotalPolCountTable t
	group by t.OutletAlphaKey
	)groupedTransDetails
)

insert into @ConsultantRankTable(Id, NoOfPolicies, [Rank])
(
select groupedTransDetails.ConsultantKey
, groupedTransDetails.TotalPolCount
, RANK() over (order by groupedTransDetails.TotalPolCount desc) as 'RANK'
from @TotalPolCountTable groupedTransDetails
)

select @TotalRanks_Store = COUNT(r.Id) 
from @StoreRankTable r

select @TotalRanks_Consultant = COUNT(r.Id) 
from @ConsultantRankTable r

select @ActualSales_Store = SUM(isnull(t.GrossPremium,0))
from @SalesTable t
where t.TransactionType = 'Base' 

select @ActualSales_Consultant = SUM(isnull(t.GrossPremium,0))
from @SalesTable t
where t.ConsultantKey = @ConsultantKey and t.TransactionType = 'Base'

select @GrossSales_Store = SUM(isnull(t.GrossPremium,0))
from @SalesTable t

select @GrossSales_Consultant = SUM(isnull(t.GrossPremium,0))
from @SalesTable t
where t.ConsultantKey = @ConsultantKey 

select @TotalPolicies_Store = sum(t.TotalPolCount)
from @TotalPolCountTable t 
where t.OutletAlphaKey = @OutletAlphaKey
group by t.OutletAlphaKey

select @TotalPolicies_Consultant = t.TotalPolCount
from @TotalPolCountTable t 
where t.ConsultantKey = @ConsultantKey

select @Rank_Store = r.Rank from @StoreRankTable r
where r.Id = @OutletAlphaKey


select @Rank_Consultant = r.Rank from @ConsultantRankTable r
where r.Id = @ConsultantKey

set @Rank_Consultant = isnull(@Rank_Consultant,@TotalRanks_Consultant);

--return consultant data
select round(isnull(@Target_Consultant,0),0) as [Target]
, round(isnull(@ActualSales_Consultant,0),0) as Sales
, round(isnull(@GrossSales_Consultant,0),0) as GrossSales
, isnull(@TotalPolicies_Consultant,0) as PoliciesSold
, case when @Rank_Consultant = 0 then @TotalRanks_Consultant else @Rank_Consultant end [Rank]
, isnull(@TotalRanks_Consultant,0) as TotalRanks

set @Rank_Store = isnull(@Rank_Store,@TotalRanks_Store);

--return store data
select round(isnull(@Target_Store,0),0) as [Target]
, round(isnull(@ActualSales_Store,0),0) as Sales
, round(isnull(@GrossSales_Store,0),0) as GrossSales
, isnull(@TotalPolicies_Store,0) as PoliciesSold
, case when @Rank_Store = 0 then @TotalRanks_Store else @Rank_Store end as [Rank]
, isnull(@TotalRanks_Store,0) as TotalRanks
END
GO
