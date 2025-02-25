USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ClaimData_Proc_temp_2]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimData_Proc_temp_2](
	[Policy_Number] [varchar](2000) NULL,
	[Claim_Number] [varchar](2000) NULL,
	[Claim_Key] [varchar](2000) NULL,
	[Section_ID] [varchar](2000) NULL,
	[Section_Code] [varchar](2000) NULL,
	[Incident_Date] [varchar](2000) NULL,
	[Reported_Date] [varchar](2000) NULL,
	[Closed_Date] [varchar](2000) NULL,
	[Claim_Status] [varchar](2000) NULL,
	[Claim_Denial_Reasons] [varchar](2000) NULL,
	[Claim_Withdrawal_Reasons] [varchar](2000) NULL,
	[Claim_Benefit] [varchar](2000) NULL,
	[Peril_Code] [varchar](2000) NULL,
	[Peril_Description] [varchar](2000) NULL,
	[Event_Description] [varchar](2000) NULL,
	[Cost_Type] [varchar](2000) NULL,
	[Traveller_Sequence_No] [varchar](2000) NULL,
	[Luggage_Flag] [varchar](2000) NULL,
	[Snow_Sports_Flag] [varchar](2000) NULL,
	[PEMC_Flag] [varchar](2000) NULL,
	[Covid_Flag] [varchar](2000) NULL,
	[Cruise_Flag] [varchar](2000) NULL,
	[Motorbike_Flag] [varchar](2000) NULL,
	[Adventure_Activities_Flag] [varchar](2000) NULL,
	[Incident_Country] [varchar](2000) NULL,
	[Reserve_Amount] [varchar](2000) NULL,
	[Paid_Amount] [varchar](2000) NULL,
	[Recovery_Amount] [varchar](2000) NULL,
	[Movement_Sequence] [varchar](2000) NULL,
	[First_Movement_In_Day] [varchar](2000) NULL,
	[Assessment_Outcome_Description] [varchar](2000) NULL,
	[Excess_Amount] [varchar](2000) NULL,
	[Payment_Date] [varchar](2000) NULL,
	[Is_Assistance_Case] [varchar](2000) NULL,
	[Loss_Description] [varchar](2000) NULL,
	[Agency_Code] [varchar](2000) NULL,
	[Plan_Type_Name] [varchar](2000) NULL
) ON [PRIMARY]
GO
