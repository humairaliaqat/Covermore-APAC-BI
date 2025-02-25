USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[penguin_fcHighAchievers]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Akanksha Khemka
-- Create date: 08/10/2012
-- Description:	Gets FC sales data given the Alphacode and userid
-- =============================================
create PROCEDURE [dbo].[penguin_fcHighAchievers] 	

	@AlphaCode varchar(33)
	, @DomainId int 

AS
BEGIN
	--SELECT  @AlphaCode='FLQ1859', @DomainId=7
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @OutletAlphaKey varchar(33)
		,@CurrentMonth INT
		,@CurrentYear INT
		,@CurrentFCAreaId int
		

declare @SalesTable table (ConsultantKey varchar(50), OutletAlphaKey varchar(50),  GrossSales money)

select @OutletAlphaKey = penOutlet.OutletAlphaKey
, @CurrentFCAreaId = penOutlet.FCAreaID
from penOutlet 
where AlphaCode = @AlphaCode 
	  and OutletStatus = 'Current'
	  AND TradingStatus='Stocked'	  
	  and DomainId = @DomainId

if @OutletAlphaKey IS NULL
begin
	RAISERROR('Invalid Outlet or outlet not current.',10,4)
end	

--select @HistoricalDataExists

--select @CurrentFCAreaId

set @CurrentYear = datepart(yy, GETDATE())
set @CurrentMonth = DATEPART(m, getdate())

insert into @SalesTable(ConsultantKey, OutletAlphaKey, GrossSales)
(
	select transactionDetails.ConsultantKey, transactionDetails.OutletAlphaKey, round(sum(transactionDetails.GrossPremium),0) as GrossPremium
	from
		(
			select isnull(s.UserKey,N'') as ConsultantKey
			, s.OutletAlphaKey as OutletAlphaKey
			, sum(s.GrossPremium) AS GrossPremium
			from penPolicyTransSummary s
			where datepart(m, s.IssueDate) = @CurrentMonth 
					and DATEPART(yy, s.IssueDate) = @CurrentYear
					and s.TransactionType in ('Base', 'Variation')
					and s.OutletAlphaKey in (
										select distinct penOutlet.OutletAlphaKey 
										from penOutlet 
										where penOutlet.FCAreaID = @CurrentFCAreaId
										and OutletStatus = 'Current' AND penOutlet.TradingStatus='Stocked'
					)
			GROUP BY s.UserKey,s.OutletAlphaKey
		) transactionDetails
	group by transactionDetails.ConsultantKey, transactionDetails.OutletAlphaKey							
)


			
--Get the top 3 in AREA for consultant view
select distinct penUser.FirstName + ' ' + penUser.LastName as ConsultantName
, highAchievers.GrossSales
, highAchievers.[Rank]
from penUser 
inner join 
(
	select top 3 salesTable.ConsultantKey
	, salesTable.GrossSales
	, RANK() over (order by salesTable.GrossSales desc) as [Rank]
	from @SalesTable salesTable
) as highAchievers on highAchievers.ConsultantKey = penUser.UserKey 
order by highAchievers.[Rank]

--Get the top 3 in STORE for Store view
select distinct penUser.FirstName + ' ' + penUser.LastName  as ConsultantName
, highAchievers.GrossSales
, highAchievers.[Rank]
from penUser 
inner join 
(
select top 3 salesTable.ConsultantKey
, salesTable.GrossSales
, RANK() over (order by salesTable.GrossSales desc) as [Rank]
from @SalesTable salesTable
where salesTable.OutletAlphaKey = @OutletAlphaKey
) 
as highAchievers on highAchievers.ConsultantKey = penUser.UserKey 
order by highAchievers.[Rank]

END


GO
