USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[ClaimData_Proc_temp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimData_Proc_temp](
	[Policy_Number] [varchar](100) NULL,
	[Claim_Number] [varchar](100) NULL,
	[Claim_Key] [varchar](100) NULL,
	[Section_ID] [varchar](100) NULL,
	[Section_Code] [varchar](100) NULL,
	[Incident_Date] [varchar](100) NULL,
	[Reported_Date] [varchar](100) NULL,
	[Closed_Date] [varchar](100) NULL,
	[Claim_Status] [varchar](100) NULL,
	[Claim_Denial_Reasons] [varchar](100) NULL,
	[Claim_Withdrawal_Reasons] [varchar](100) NULL,
	[Claim_Benefit] [varchar](100) NULL,
	[Peril_Code] [varchar](100) NULL,
	[Peril_Description] [varchar](100) NULL,
	[Event_Description] [varchar](100) NULL,
	[Cost_Type] [varchar](100) NULL,
	[Traveller_Sequence_No] [varchar](100) NULL,
	[Luggage_Flag] [varchar](100) NULL,
	[Snow_Sports_Flag] [varchar](100) NULL,
	[PEMC_Flag] [varchar](100) NULL,
	[Covid_Flag] [varchar](100) NULL,
	[Cruise_Flag] [varchar](100) NULL,
	[Motorbike_Flag] [varchar](100) NULL,
	[Adventure_Activities_Flag] [varchar](100) NULL,
	[Incident_Country] [varchar](100) NULL,
	[Reserve_Amount] [varchar](100) NULL,
	[Paid_Amount] [varchar](100) NULL,
	[Recovery_Amount] [varchar](100) NULL,
	[Movement_Sequence] [varchar](100) NULL,
	[First_Movement_In_Day] [varchar](100) NULL,
	[Assessment_Outcome_Description] [varchar](100) NULL,
	[Excess_Amount] [varchar](100) NULL,
	[Payment_Date] [varchar](100) NULL,
	[Is_Assistance_Case] [varchar](100) NULL,
	[Loss_Description] [varchar](100) NULL,
	[Agency_Code] [varchar](100) NULL
) ON [PRIMARY]
GO
