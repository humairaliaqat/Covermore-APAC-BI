USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1087]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[rptsp_rpt1087] 
@DateRange varchar(30),
@StartDate varchar(10), 
@EndDate varchar(10),
@Country varchar(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
SET NOCOUNT ON;


-- ================================================
----  Name:	rptsp_rpt1087
----  Description:	Claim Recovery Report
----  Author:	Molly Ma
----  Date Created:	20190918
----  Description: This stored procedure extract the claim related payments
----  Parameters:  @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd	
----  Change History:	20190923 - adding column of country to make it as a prompt
--						20191120 - changing the formula of calculating claimamount and include the column of 'RecoveryDemandDate' 
--						20191127 requested by Kelsey to include the Recovery records only	
-- ================================================


declare @dataStartDate datetime
declare @dataEndDate datetime
declare @Countrykey varchar(5)

/* initialise dates */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

select @countrykey=@country
	
select 																	
		ClaimNumber
		,WorkType															
		,PaidPayment															
		,RecoveredPayment															
		,EstimateValue
		,TotalPayment															
		--,RecoveryEstimateValue															
		--,ClaimValue															
		,max(case when tr.workType = 'Recovery' then AnticipatedLegalCosts else 0 end) 
		,RecoveryDemandDate --cast(max(case when wwp.Property_ID = 'ExpectedRecoveryDate' then wwp.PropertyValue else 0 end) as datetime) RecoveryDemandDate  --20191120 include the RecoveryDemandDate
		,max(case when tr.workType = 'Recovery' then ExpectedRecoveryAmount else 0 end) ExpectedRecoveryAmount --20191120 include the ExpectedRecoveryAmount
		,@dataStartDate
		,@dataEndDate
		,@Countrykey															
from (																	
		select															
			w.ClaimNumber
			,wp.AnticipatedLegalCosts
			,cp.PaidPayment
			,cp.RecoveredPayment
			,cp.EstimateValue
			,wp.ExpectedRecoveryAmount  --20191120 cp.RecoveryEstimateValue
			,cp.PaidPayment+cp.RecoveredPayment TotalPayment														
			,w.WorkType
			,wp.RecoveryDemandDate  --20191120cp.PaidPayment + cp.RecoveredPayment + cp.EstimateValue - cp.RecoveryEstimateValue ClaimValue,w.WorkType 														
		from 															
			[db-au-cmdwh].[dbo].[e5Work_v3] w with(nolock) 														
			outer apply  (select														
		            sum(															
		                case															
		                    when cp.PaymentStatus = 'PAID' then cp.PaymentAmount															
		                    else 0															
		                end		*(1 - cs.isDeleted) 													
		            ) PaidPayment,															
		            sum(															
		                case															
		                    when cp.PaymentStatus = 'RECY' then cp.PaymentAmount															
		                    else 0															
		                end		*(1 - cs.isDeleted)													
		            )  RecoveredPayment,															
			sum(distinct isnull(cs.EstimateValue, 0) * (1 - cs.isDeleted)) EstimateValue														
			--sum(distinct isnull(cs.RecoveryEstimateValue, 0) * (1 - cs.isDeleted)) RecoveryEstimateValue														
		        from															
		        [db-au-cmdwh].dbo.clmSection cs with(nolock)															
				Left Join [db-au-cmdwh].dbo.clmPayment cp with(nolock)													
		          on															
		              cp.SectionKey = cs.SectionKey and															
		              cp.isDeleted = 0															
					where cs.ClaimKey = w.ClaimKey												
					) cp												
			outer apply (														
					select 												
						max(case when wwp.Property_ID = 'AnticipatedLegalCosts' then try_convert(int, wwp.PropertyValue) else 0 end) AnticipatedLegalCosts,
						cast(max(case when wwp.Property_ID = 'ExpectedRecoveryDate' then wwp.PropertyValue else 0 end) as datetime) RecoveryDemandDate,  --20191120 include RecoveryDemandDate
						max(case when wwp.Property_ID = 'ExpectedRecoveryAmount' then try_convert(money,isnull(wwp.PropertyValue,0))  else 0 end) ExpectedRecoveryAmount --20191120 include the ExpectedRecoveryAmount
											
					from [dbo].[e5WorkProperties_v3] wwp 	with(nolock)											
					where workType = 'recovery' and wwp.Work_ID=w.Work_ID												
		) wp															
where 																	

		 w.CreationDate >=@dataStartDate and 															
		 w.Creationdate < @dataEndDate and 															
		 w.claimnumber is not null 	and w.Claimkey <>'AU-1'														
		 and w.workType in('Recovery')--,'Claim')	20191127 requested by Kelsey to include the Recovery records only			
		 and w.Country=@Countrykey
		 and cp.PaidPayment is not NULL	
	) tr							 									
group by ClaimNumber,PaidPayment,RecoveredPayment,EstimateValue,TotalPayment,WorkType,RecoveryDemandDate
															

END
GO
