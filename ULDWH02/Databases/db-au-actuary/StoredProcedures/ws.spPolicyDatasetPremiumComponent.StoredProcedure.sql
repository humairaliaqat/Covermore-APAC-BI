USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[spPolicyDatasetPremiumComponent]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Create 
CREATE
PROCEDURE [ws].[spPolicyDatasetPremiumComponent] @StartDate date,
@EndDate date

AS
BEGIN
  --Drop table if already exists
  --drop TABLE [db-au-actuary].[ws].[DWHDataSetPremiumComponents];

  IF OBJECT_ID('ws.DWHBasePolicyDataset') IS NULL
  BEGIN
    CREATE TABLE [db-au-actuary].[ws].[DWHBasePolicyDataset] (
      [PolicyKey] [varchar](41) NULL,
	  [PolicyNumber] [varchar](50) NULL,
	  [PolicyIssueDate] [datetime] NULL,
      [PolicyStart] [datetime] NOT NULL,
      [PolicyEnd] [datetime] NOT NULL,
	  [TripStart] [datetime] NOT NULL,
      [TripEnd] [datetime] NOT NULL,
	  [MaxDuration] [Int] NULL,
	  Destination nvarchar(max),
      [PolicyTransactionKey] [varchar](41) NULL,
	  [TransactionNumber] [varchar](50) NULL,
      [TripCost] [varchar](50) NULL,
      [RunningTotalTripCost] [Int] NULL,
	  GrossPremium money null,
	  RunningTotalGrossPremium money null,
      [TransactionIssueDate] [datetime] NULL,
	  [TransactionDateTime] [datetime] NULL,--no null values post 29-nov-2013
      [AutoComments] [nvarchar](2000) NULL,
      /*[PolicyTravellerKey] [varchar](41) NULL,
	  [Title] [nvarchar](50) NULL,
      [TravellerName] [nvarchar](201) NULL,
      [DOB] [datetime] NULL,
      [Gender] [nchar](2) NULL,
      [isAdult] [bit] NULL,
      [EmailAddress] [nvarchar](255) NULL,
	  [PrimaryTravellerPostCode] [nvarchar](50) NULL,
      [PolicyTravellerTransactionKey] [varchar](41) NULL,
      [PolicyEMCKey] [varchar](41) NULL,
      [PolicyHasEMC] [varchar](1) NULL,
      [EMCRef] [varchar](100) NULL,
      [EMCScore] [numeric](10, 4) NULL,*/
      [CommentProcessed] [varchar](2) NULL,
	  [CommentProcessedDatetime] [datetime] NULL,
	  [CancellationProcessed] [varchar](2) NULL,
	  [CancellationProcessedDatetime] [datetime] NULL/*,
	  [PolicyAddonName]  [nvarchar](50) NULL,
	  PolicyAddonValueDesc nvarchar(50) Null,
	  [PolicyAddonCoverIncrease] [money] NULL,
	  [TravellerAddonName]  [nvarchar](50) NULL,
	  TravellerAddonValueDesc nvarchar(50) Null,
	  [TravellerAddonCoverIncrease] [money] NULL,
      [HasMotorcycle] [varchar](100) NULL,
      [HasWintersport] [varchar](100) NULL,
	  [HasCruise] [varchar](100) NULL,
	  --[HasLuggage] [varchar](100) NULL,
	  [HasNewforOld] [varchar](100) NULL,
	  [OptionalLuggageCover] [varchar](100) NULL,
	  [IncreaseLuggageItemLimits] [varchar](100) NULL,
	  [CancelForAnyReason] [varchar](100) NULL,
	  [HasRentalCar] [varchar](100) NULL,
	  [HasAdventureActivities] [varchar](100) NULL*/
    ) ON [PRIMARY]


    CREATE NONCLUSTERED INDEX [DWHBasePolicyDataset_IDX1] ON [ws].[DWHBasePolicyDataset] ([PolicyKey] ASC, [TransactionIssueDate] ASC, [PolicyTransactionKey] ASC--, [PolicyTravellerKey] ASC, [PolicyTravellerTransactionKey] ASC
	);

    CREATE NONCLUSTERED INDEX [DWHBasePolicyDataset_IDX2] ON [ws].[DWHBasePolicyDataset] ([PolicyTransactionKey] ASC--, [PolicyTravellerTransactionKey] ASC
	);

    CREATE CLUSTERED INDEX [DWHBasePolicyDataset_IDX3] ON [ws].[DWHBasePolicyDataset] ([CommentProcessed] ASC);

  END;

  /*************************************************/


IF OBJECT_ID('ws.DWHTravellerDataset') IS NULL
  BEGIN

	CREATE TABLE [ws].[DWHTravellerDataset](
		[PolicyKey] [varchar](41) NULL,
		[PolicyNumber] [varchar](50) NULL,
		[PolicyTransactionKey] [varchar](41) NULL,
		[TransactionNumber] [varchar](50) NULL,
		[TransactionIssueDate] [datetime] NULL,
		[TransactionDateTime] [datetime] NULL,
		[AutoComments] [nvarchar](2000) NULL,
		[CommentProcessed] [varchar](2) NULL,
		  [CommentProcessedDatetime] [datetime] NULL,
		  [CancellationProcessed] [varchar](2) NULL,
		  [CancellationProcessedDatetime] [datetime] NULL,
		[PolicyTravellerKey] [varchar](41) NULL,
		[Title] [nvarchar](50) NULL,
		[TravellerName] [nvarchar](201) NULL,
		[DOB] [datetime] NULL,
		[Gender] [nchar](2) NULL,
		[isAdult] [bit] NULL,
		[EmailAddress] [nvarchar](255) NULL,
		[PrimaryTravellerPostCode] [nvarchar](50) NULL,
		[PolicyTravellerTransactionKey] [varchar](41) NULL
	) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [DWHTravellerDataset_IDX1] ON [ws].[DWHTravellerDataset] ([PolicyKey] ASC, [TransactionIssueDate] ASC, [PolicyTransactionKey] ASC--, [PolicyTravellerKey] ASC, [PolicyTravellerTransactionKey] ASC
	);

    CREATE NONCLUSTERED INDEX [DWHTravellerDataset_IDX2] ON [ws].[DWHTravellerDataset] ([PolicyTransactionKey] ASC--, [PolicyTravellerTransactionKey] ASC
	);

	CREATE NONCLUSTERED INDEX [DWHTravellerDataset_IDX3] ON [ws].[DWHTravellerDataset] ([PolicyTravellerTransactionKey] ASC--, [PolicyTravellerTransactionKey] ASC
	);

	end;

  /************************************************************/





  DELETE FROM [db-au-actuary].ws.DWHBasePolicyDataset
  WHERE policykey IN (SELECT policykey FROM [db-au-cmdwh]..penPolicyTransaction WHERE TransactionDateTime >= @StartDate
																							AND TransactionDateTime < DATEADD(DAY, 1, @EndDate)
																							Union 
																							select policykey from [db-au-actuary]..PolicyDatasetTestCases
																							 )
  --and policykey in ('AU-CM7-1000047','AU-CM7-100027','AU-CM7-8956027')
																							;
	
	
	--delete from [db-au-actuary].ws.TravellerPremiumComponentMovemen where PolicyKey='AU-CM7-10002865'

  INSERT INTO [db-au-actuary].ws.DWHBasePolicyDataset  WITH (TABLOCK)
    ( PolicyKey,
      PolicyNumber,
	  PolicyIssueDate,
      PolicyStart,
      PolicyEnd,
	  TripStart,
      TripEnd,
	  MaxDuration,
	  Destination,
      PolicyTransactionKey,
	  TransactionNumber,
      TripCost,
      RunningTotalTripCost,
	  GrossPremium,
	  RunningTotalGrossPremium,
      TransactionIssueDate,
	  TransactionDateTime,
      AutoComments,
      /*PolicyTravellerKey,
	  Title,
      TravellerName,
      DOB,
      Gender,
      isAdult,
      EmailAddress,
	  PrimaryTravellerPostCode,
      PolicyTravellerTransactionKey,
      PolicyEMCKey,
      PolicyHasEMC,
      EMCRef,
      EMCScore,*/
      CommentProcessed,
	  CancellationProcessed/*,
	  [PolicyAddonName],
	  PolicyAddonValueDesc,
	  [PolicyAddonCoverIncrease],
	  [TravellerAddonName],
	  TravellerAddonValueDesc,
	  [TravellerAddonCoverIncrease],
      [HasMotorcycle],
      [HasWintersport],
	  [HasCruise],
	  --[HasLuggage],
	  [HasNewforOld],
	  [OptionalLuggageCover],
	  [IncreaseLuggageItemLimits],
	  [CancelForAnyReason],
	  [HasRentalCar],
	  [HasAdventureActivities]*/
	  )
   SELECT --top 100
      penPolicyAndTransaction.policykey,
	  penPolicyAndTransaction.PolicyNumber,
	  penPolicyAndTransaction.PolicyIssueDate,
      penPolicyAndTransaction.PolicyStart,
      penPolicyAndTransaction.PolicyEnd,
	  penPolicyAndTransaction.TripStart,
      penPolicyAndTransaction.TripEnd,
	  penPolicyAndTransaction.MaxDuration,
	  --penPolicy.PrimaryCountry Destination,--changed by Ratnesh on 11jan19
	  penPolicyAndTransaction.Destination,
      penPolicyAndTransaction.PolicyTransactionKey,
	  penPolicyAndTransaction.TransactionNumber,
      penPolicyAndTransaction.TripCost,
      --SUM(CAST(
      --REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(penPolicyTransaction.TripCost, '$', ''), ',', ''), 'Unlimited', 9999999), 'Nil', 0), '[object Object]', ''), 'DA-', ''), 'DC-', ''), 'DE-', ''), 'FD-', ''), 'init', ''), 'More than', ''), 'null', ''), 'Please Select', ''), 'SD-', ''), ' ', ''), 'S', ''), 'C-', ''), 'D-', '')
      --AS int)*(case when penPolicyTransaction.AutoComments like '%Transaction number%cancelled%' then -1 else 1 end )) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalTripCost,
	  penPolicyAndTransaction.RunningTotalTripCost,
	  penPolicyAndTransaction.GrossPremium,
	  --SUM(penPolicyTransaction.GrossPremium) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalGrossPremium,
	  penPolicyAndTransaction.RunningTotalGrossPremium,
      penPolicyAndTransaction.IssueDate TransactionIssueDate,
	  penPolicyAndTransaction.TransactionDateTime,
      penPolicyAndTransaction.AutoComments,
	  /*penPolicyTraveller.PolicyTravellerKey,
	  penPolicyTraveller.Title,
	  penpolicytraveller.FirstName + ' ' + penpolicytraveller.LastName TravellerName,
      penpolicytraveller.DOB,
	        penpolicytraveller.Gender,
      penpolicytraveller.isAdult,
	  penpolicytraveller.EmailAddress,
	  case when penpolicytraveller.isPrimary = 1 then penpolicytraveller.PostCode else null end PrimaryTravellerPostCode,
	   penPolicyTravellerTransaction.PolicyTravellerTransactionKey,
      penPolicyEMC.PolicyEMCKey,
      CASE
        WHEN penPolicyEMC.PolicyEMCKey IS NOT NULL THEN 'Y'
        ELSE 'N'
      END PolicyHasEMC,
      penPolicyEMC.EMCRef,
      penPolicyEMC.EMCScore,*/
      --'N' CommentProcessed,
	  case when penPolicyAndTransaction.AutoComments in ('Base Policy Issued','Policy Cancelled.','Policy Cancelled with override.','') then 'NA'
	       when penPolicyAndTransaction.AutoComments is null then 'NA'
		   when penPolicyAndTransaction.AutoComments like 'Policy Extended from %' then 'NA' 
		   else 'N'
		   end CommentProcessed,
	  case when penPolicyAndTransaction.AutoComments like '%Transaction number (%) cancelled%' and penPolicyAndTransaction.AutoComments not like 'Transaction number () cancelled%' then 'N' else 'NA' end  [CancellationProcessed]/*,
	  penPolicyAddOn.AddonName PolicyAddonName,
	  penPolicyAddOn.AddonValueDesc PolicyAddonValueDesc,
	  penPolicyAddOn.CoverIncrease PolicyAddonCoverIncrease,
	  penPolicyTravellerAddOn.AddonName TravellerAddonName,
	  penPolicyTravellerAddOn.AddonValueDesc TravellerAddonValueDesc,
	  penPolicyTravellerAddOn.CoverIncrease TravellerAddonCoverIncrease,
      case when penPolicyAddOn.AddonName like '%motorcycle%' then penPolicyAddOn.AddonName else 'N' end [HasMotorcycle],
      case when penPolicyTravellerAddOn.AddonName like '%snow%' then penPolicyTravellerAddOn.AddonName else 'N' end  [HasWintersport],
	  case when penPolicyAddOn.AddonName like '%Cruise Cover%' then penPolicyAddOn.AddonName 
	       when penPolicyTravellerAddOn.AddonName like '%Cruise Cover%' then penPolicyTravellerAddOn.AddonName 
	  else 'N' end [HasCruise],
	  --'N' [HasLuggage],
	  case when penPolicyAddOn.AddonName like '%Premium Luggage Cover%' then 'Y' else 'N' end  [HasNewforOld],
      case when penPolicyAddOn.AddonName like '%Optional Luggage Cover%' then 'Y' else 'N' end [OptionalLuggageCover],
	  case when penPolicyTravellerAddOn.AddonName like '%Increase Luggage Item Limits%' then str(penPolicyTravellerAddOn.CoverIncrease) else 'N' end  [IncreaseLuggageItemLimits],
	  case when penPolicyTravellerAddOn.AddonName like '%Cancel For Any Reason%' then penPolicyTravellerAddOn.AddonName else 'N' end [CancelForAnyReason],
	  case when penPolicyAddOn.AddonName like '%Increase Rental Car Insurance Excess Cover%' then str(penPolicyAddOn.CoverIncrease) else 'N' end [HasRentalCar],
	  case when penPolicyAddOn.AddonName like '%Adventure Activities%' then penPolicyAddOn.AddonName 
	       when penPolicyTravellerAddOn.AddonName like '%Adventure Activities%' then penPolicyTravellerAddOn.AddonName else 'N' end  [HasAdventureActivities]--TBD*/
    FROM 
	(
	select  
	  penPolicy.policykey,
	  penPolicy.PolicyNumber,
	  penPolicy.IssueDate PolicyIssueDate,
      penPolicy.PolicyStart,
      penPolicy.PolicyEnd,
	  penPolicy.TripStart,
      penPolicy.TripEnd,
	  penPolicy.MaxDuration,
	  --penPolicy.PrimaryCountry Destination,--changed by Ratnesh on 11jan19
	  penPolicy.MultiDestination Destination,
	  --penPolicyTransaction.policykey,
	  penPolicyTransaction.PolicyTransactionKey,
	  penPolicyTransaction.PolicyNumber as TransactionNumber,
      penPolicyTransaction.TripCost,
      SUM(CAST(
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(penPolicyTransaction.TripCost,'','0'), '$', ''), ',', ''), 'Unlimited', 9999999), 'Nil', 0), '[object Object]', ''), 'DA-', ''), 'DC-', ''), 'DE-', ''), 'FD-', ''), 'init', ''), 'More than', ''), 'null', ''), 'Please Select', ''), 'SD-', ''), ' ', ''), 'S', ''), 'C-', ''), 'D-', '')
      AS float)*(case when penPolicyTransaction.AutoComments like '%Transaction number%cancelled%' then -1 else 1 end )) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalTripCost,
	  penPolicyTransaction.GrossPremium,
	  SUM(penPolicyTransaction.GrossPremium) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalGrossPremium,
      penPolicyTransaction.IssueDate TransactionIssueDate,
	  penPolicyTransaction.TransactionDateTime,
      penPolicyTransaction.AutoComments,
	  penPolicyTransaction.IssueDate
	from [db-au-cmdwh]..penPolicy
    left outer join [db-au-cmdwh]..penPolicyTransaction
	on penPolicy.PolicyKey = penPolicyTransaction.PolicyKey
	where penPolicy.policykey IN (SELECT policykey FROM [db-au-cmdwh]..penPolicyTransaction WHERE TransactionDateTime > '20140101'--'20111001'--DATEADD(YEAR, -1, GETDATE())
																							AND TransactionDateTime >= @StartDate
																							AND TransactionDateTime < DATEADD(DAY, 1, @EndDate)
																							Union 
																							select policykey from [db-au-actuary]..PolicyDatasetTestCases
																							)
	and penPolicy.CountryKey IN ('AU', 'NZ')
	) as penPolicyAndTransaction
	/*left outer join [db-au-cmdwh]..penpolicytraveller
    on penPolicyAndTransaction.PolicyKey = penpolicytraveller.PolicyKey
    LEFT outer JOIN [db-au-cmdwh]..penPolicyTravellerTransaction
      ON (penpolicytraveller.PolicyTravellerKey = penPolicyTravellerTransaction.PolicyTravellerKey AND penPolicyAndTransaction.PolicyTransactionKey = penPolicyTravellerTransaction.PolicyTransactionKey)
    LEFT outer JOIN [db-au-cmdwh]..penPolicyEMC
      ON (penPolicyEMC.PolicyTravellerTransactionKey = penPolicyTravellerTransaction.policytravellertransactionkey)
	LEFT outer JOIN [db-au-cmdwh]..penPolicyAddOn
      ON (penPolicyAndTransaction.PolicyTransactionKey = penPolicyAddOn.PolicyTransactionKey)
	LEFT outer JOIN [db-au-cmdwh]..penPolicyTravellerAddOn
      ON (penPolicyTravellerAddOn.PolicyTravellerTransactionKey = penPolicyTravellerTransaction.policytravellertransactionkey)*/
    ORDER BY --pptt.PolicyTravellerTransactionKey
    penPolicyAndTransaction.policykey, TransactionIssueDate;


	   --replace ; to , in case of multiple destinations list since ; is used as comment separator also (Shannon this happens only for CBA policies.)
	   update [ws].[DWHBasePolicyDataset]
	   set AutoComments=replace(AutoComments,';',',')
		where AutoComments like 'Destination changed from %'
		and AutoComments not like '%Traveller%'
		and AutoComments not like '%policy%'
		and AutoComments not like '%motorcycle%'
		and AutoComments not like '%adventure%'
		and AutoComments not like '%rental car%'
		and AutoComments not like '%snow %'
		and AutoComments not like '%luggage%'
		and AutoComments not like '%duration%'
		--and AutoComments not like '%destination%'
		and AutoComments not like '%postcode%'
		and AutoComments not like '%policy date%'
		and AutoComments not like '%return date%'
		and AutoComments not like '%partial refund%'
		and len(AutoComments)-len(replace(AutoComments,';','')) >1
		and CommentProcessed='N';

  UPDATE STATISTICS [db-au-actuary].ws.DWHBasePolicyDataset;



    DELETE FROM [db-au-actuary].ws.DWHTravellerDataset
  WHERE PolicyKey IN (SELECT policykey FROM [db-au-cmdwh]..penPolicyTransaction WHERE TransactionDateTime >= @StartDate
																							AND TransactionDateTime < DATEADD(DAY, 1, @EndDate)
																							Union 
																							select policykey from [db-au-actuary]..PolicyDatasetTestCases
																							 )
  --and policykey in ('AU-CM7-1000047','AU-CM7-100027','AU-CM7-8956027')
																							;

	INSERT INTO [db-au-actuary].ws.DWHTravellerDataset  WITH (TABLOCK)
    ( PolicyKey,
      PolicyNumber,
      PolicyTransactionKey,
	  TransactionNumber,
      TransactionIssueDate,
	  TransactionDateTime,
      AutoComments,
	  CommentProcessed,
	  CancellationProcessed,
      PolicyTravellerKey,
	  Title,
      TravellerName,
      DOB,
      Gender,
      isAdult,
      EmailAddress,
	  PrimaryTravellerPostCode,
      PolicyTravellerTransactionKey)  
   SELECT 
      penPolicyAndTransaction.PolicyKey,
	  penPolicyAndTransaction.PolicyNumber,
      penPolicyAndTransaction.PolicyTransactionKey,
	  penPolicyAndTransaction.TransactionNumber,
      penPolicyAndTransaction.IssueDate TransactionIssueDate,
	  penPolicyAndTransaction.TransactionDateTime,
      penPolicyAndTransaction.AutoComments,
	  case when penPolicyAndTransaction.AutoComments in ('Base Policy Issued','Policy Cancelled.','Policy Cancelled with override.','') then 'NA'
	       when penPolicyAndTransaction.AutoComments is null then 'NA'
		   when penPolicyAndTransaction.AutoComments like 'Policy Extended from %' then 'NA' 
		   else 'N'
		   end CommentProcessed,
	  case when penPolicyAndTransaction.AutoComments like '%Transaction number (%) cancelled%' and penPolicyAndTransaction.AutoComments not like 'Transaction number () cancelled%' then 'N' else 'NA' end  [CancellationProcessed],
	  penPolicyTraveller.PolicyTravellerKey,
	  penPolicyTraveller.Title,
	  penpolicytraveller.FirstName + ' ' + penpolicytraveller.LastName TravellerName,
      penpolicytraveller.DOB,
	        penpolicytraveller.Gender,
      penpolicytraveller.isAdult,
	  penpolicytraveller.EmailAddress,
	  case when penpolicytraveller.isPrimary = 1 then penpolicytraveller.PostCode else null end PrimaryTravellerPostCode,
	   penPolicyTravellerTransaction.PolicyTravellerTransactionKey
    FROM 
	(
	select  
	  penPolicy.policykey,
	  penPolicy.PolicyNumber,
	  penPolicy.IssueDate PolicyIssueDate,
      penPolicy.PolicyStart,
      penPolicy.PolicyEnd,
	  penPolicy.TripStart,
      penPolicy.TripEnd,
	  penPolicy.MaxDuration,
	  --penPolicy.PrimaryCountry Destination,--changed by Ratnesh on 11jan19
	  penPolicy.MultiDestination Destination,
	  --penPolicyTransaction.policykey,
	  penPolicyTransaction.PolicyTransactionKey,
	  penPolicyTransaction.PolicyNumber as TransactionNumber,
      penPolicyTransaction.TripCost,
      SUM(CAST(
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(penPolicyTransaction.TripCost,'','0'), '$', ''), ',', ''), 'Unlimited', 9999999), 'Nil', 0), '[object Object]', ''), 'DA-', ''), 'DC-', ''), 'DE-', ''), 'FD-', ''), 'init', ''), 'More than', ''), 'null', ''), 'Please Select', ''), 'SD-', ''), ' ', ''), 'S', ''), 'C-', ''), 'D-', '')
      AS float)*(case when penPolicyTransaction.AutoComments like '%Transaction number%cancelled%' then -1 else 1 end )) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalTripCost,
	  penPolicyTransaction.GrossPremium,
	  SUM(penPolicyTransaction.GrossPremium) OVER (PARTITION BY penPolicyTransaction.policykey ORDER BY penPolicyTransaction.issuedate) RunningTotalGrossPremium,
      penPolicyTransaction.IssueDate TransactionIssueDate,
	  penPolicyTransaction.TransactionDateTime,
      penPolicyTransaction.AutoComments,
	  penPolicyTransaction.IssueDate
	from [db-au-cmdwh]..penPolicy
    left outer join [db-au-cmdwh]..penPolicyTransaction
	on penPolicy.PolicyKey = penPolicyTransaction.PolicyKey
	where penPolicy.policykey IN (SELECT policykey FROM [db-au-cmdwh]..penPolicyTransaction WHERE TransactionDateTime > '20140101'--'20111001'--DATEADD(YEAR, -1, GETDATE())
																							AND TransactionDateTime >= @StartDate
																							AND TransactionDateTime < DATEADD(DAY, 1, @EndDate)
																							Union 
																							select policykey from [db-au-actuary]..PolicyDatasetTestCases
																							)
	and penPolicy.CountryKey IN ('AU', 'NZ')
	) as penPolicyAndTransaction
	--left outer 
	join [db-au-cmdwh]..penpolicytraveller
    on penPolicyAndTransaction.PolicyKey = penpolicytraveller.PolicyKey
    --LEFT outer 
	JOIN [db-au-cmdwh]..penPolicyTravellerTransaction
      ON (penpolicytraveller.PolicyTravellerKey = penPolicyTravellerTransaction.PolicyTravellerKey AND penPolicyAndTransaction.PolicyTransactionKey = penPolicyTravellerTransaction.PolicyTransactionKey)
    ORDER BY penPolicyAndTransaction.policykey, TransactionIssueDate,penPolicyTravellerTransaction.PolicyTravellerTransactionKey;

	update statistics [db-au-actuary].ws.DWHTravellerDataset;

END;


--exec [db-au-actuary].[ws].[spPolicyDatasetPremiumComponent] '20181001','20181008'
GO
