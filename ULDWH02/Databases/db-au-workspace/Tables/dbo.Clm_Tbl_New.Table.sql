USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Clm_Tbl_New]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clm_Tbl_New](
	[Policy_Number] [varchar](50) NULL,
	[Claim_Number] [varchar](50) NULL,
	[Claim_Key] [varchar](50) NULL,
	[Section_ID] [varchar](50) NULL,
	[Section_Code] [varchar](50) NULL,
	[Incident_Date] [varchar](50) NULL,
	[Reported_Date] [varchar](50) NULL,
	[Closed_Date] [varchar](50) NULL,
	[Claim_Status] [varchar](50) NULL,
	[Claim_Denial_Reasons] [varchar](50) NULL,
	[Claim_Withdrawal_Reasons] [varchar](50) NULL,
	[Claim_Benefit] [varchar](50) NULL,
	[Peril_Code] [varchar](50) NULL,
	[Peril_Description] [varchar](50) NULL,
	[Event_Description] [varchar](50) NULL,
	[Cost_Type] [varchar](50) NULL,
	[Traveller_Sequence_No] [varchar](50) NULL,
	[Luggage_Flag] [varchar](50) NULL,
	[Snow_Sports_Flag] [varchar](50) NULL,
	[PEMC_Flag] [varchar](50) NULL,
	[Covid_Flag] [varchar](50) NULL,
	[Cruise_Flag] [varchar](50) NULL,
	[Motorbike_Flag] [varchar](50) NULL,
	[Adventure_Activities_Flag] [varchar](50) NULL,
	[Incident_Country] [varchar](50) NULL,
	[Reserve_Amount] [varchar](50) NULL,
	[Paid_Amount] [varchar](50) NULL,
	[Recovery_Amount] [varchar](50) NULL,
	[Movement_Sequence] [varchar](50) NULL,
	[First_Movement_In_Day] [varchar](50) NULL,
	[Assessment_Outcome_Description] [varchar](50) NULL,
	[Excess_Amount] [varchar](50) NULL,
	[Payment_Date] [varchar](50) NULL,
	[Is_Assistance_Case] [varchar](50) NULL,
	[Loss_Description] [varchar](50) NULL,
	[Agency_Code] [varchar](50) NULL,
	[AuditDate] [datetime] NULL
) ON [PRIMARY]
GO
