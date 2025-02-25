USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Claim_Tbl_Missing]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Claim_Tbl_Missing](
	[Policy_Number] [varchar](50) NULL,
	[Claim_Number] [int] NULL,
	[Claim_Key] [varchar](40) NULL,
	[Section_ID] [int] NULL,
	[Section_Code] [varchar](25) NULL,
	[Incident_Date] [datetime] NULL,
	[Reported_Date] [datetime] NULL,
	[Closed_Date] [datetime] NULL,
	[Claim_Status] [varchar](50) NULL,
	[Claim_Denial_Reasons] [nvarchar](400) NULL,
	[Claim_Withdrawal_Reasons] [nvarchar](400) NULL,
	[Claim_Benefit] [nvarchar](50) NULL,
	[Peril_Code] [varchar](3) NULL,
	[Peril_Description] [nvarchar](65) NULL,
	[Event_Description] [nvarchar](60) NULL,
	[Cost_Type] [varchar](50) NULL,
	[Traveller_Sequence_No] [varchar](1) NULL,
	[Luggage_Flag] [varchar](2) NULL,
	[Snow_Sports_Flag] [varchar](2) NULL,
	[PEMC_Flag] [varchar](2) NULL,
	[Covid_Flag] [varchar](2) NULL,
	[Cruise_Flag] [varchar](2) NULL,
	[Motorbike_Flag] [varchar](2) NULL,
	[Adventure_Activities_Flag] [varchar](2) NULL,
	[Incident_Country] [nvarchar](45) NULL,
	[Reserve_Amount] [numeric](20, 6) NULL,
	[Paid_Amount] [money] NULL,
	[Recovery_Amount] [numeric](20, 6) NULL,
	[Movement_Sequence] [bigint] NULL,
	[First_Movement_In_Day] [bit] NULL,
	[Assessment_Outcome_Description] [nvarchar](400) NULL,
	[Excess_Amount] [money] NULL,
	[Payment_Date] [nvarchar](600) NULL,
	[Is_Assistance_Case] [varchar](1) NULL,
	[Loss_Description] [nvarchar](100) NULL,
	[Agency_Code] [varchar](7) NULL
) ON [PRIMARY]
GO
