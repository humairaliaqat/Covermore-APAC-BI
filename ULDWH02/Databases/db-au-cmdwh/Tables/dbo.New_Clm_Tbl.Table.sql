USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[New_Clm_Tbl]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[New_Clm_Tbl](
	[Policy_Number] [varchar](50) NULL,
	[Claim_Number] [varchar](50) NULL,
	[Claim_Key] [varchar](50) NULL,
	[Section_ID] [varchar](500) NULL,
	[Section_Code] [varchar](50) NULL,
	[Incident_Date] [varchar](50) NULL,
	[Reported_Date] [varchar](50) NULL,
	[Closed_Date] [datetime] NULL,
	[Claim_Status] [varchar](50) NULL,
	[Claim_Denial_Reasons] [varchar](500) NULL,
	[Claim_Withdrawal_Reasons] [varchar](500) NULL,
	[Claim_Benefit] [varchar](500) NULL,
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
	[First_Movement_In_Day] [bit] NULL,
	[Assessment_Outcome_Description] [varchar](50) NULL,
	[Excess_Amount] [varchar](50) NULL,
	[Payment_Date] [nvarchar](50) NULL,
	[Is_Assistance_Case] [varchar](50) NULL,
	[Loss_Description] [varchar](500) NULL,
	[Agency_Code] [varchar](50) NULL,
	[CreatedDate] [nvarchar](80) NULL,
	[Copy of Claim_Denial_Reasons] [nvarchar](500) NULL,
	[Copy of Claim_Withdrawal_Reasons] [nvarchar](500) NULL,
	[Copy of Claim_Benefit] [nvarchar](500) NULL,
	[Copy of Peril_Description] [nvarchar](500) NULL,
	[Copy of Event_Description] [nvarchar](500) NULL,
	[Copy of Incident_Country] [nvarchar](500) NULL,
	[Copy of Assessment_Outcome_Description] [nvarchar](500) NULL,
	[Copy of Loss_Description] [nvarchar](500) NULL,
	[Copy of First_Movement_In_Day] [bigint] NULL
) ON [PRIMARY]
GO
