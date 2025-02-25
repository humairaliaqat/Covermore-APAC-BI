USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ClaimData_Tbl]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimData_Tbl](
	[Policy_Number] [varchar](50) NOT NULL,
	[Claim_Number] [int] NOT NULL,
	[Claim_Key] [varchar](40) NOT NULL,
	[Section_ID] [int] NULL,
	[Section_Code] [varchar](25) NOT NULL,
	[Incident_Date] [datetime] NULL,
	[Reported_Date] [datetime] NULL,
	[Closed_Date] [datetime] NULL,
	[Claim_Status] [varchar](50) NULL,
	[Claim_Denial_Reasons] [nvarchar](400) NOT NULL,
	[Claim_Withdrawal_Reasons] [nvarchar](400) NOT NULL,
	[Claim_Benefit] [nvarchar](50) NOT NULL,
	[Peril_Code] [varchar](3) NOT NULL,
	[Peril_Description] [nvarchar](65) NOT NULL,
	[Event_Description] [nvarchar](60) NOT NULL,
	[Cost_Type] [varchar](50) NOT NULL,
	[Traveller_Sequence_No] [varchar](1) NOT NULL,
	[Luggage_Flag] [varchar](2) NOT NULL,
	[Snow_Sports_Flag] [varchar](2) NOT NULL,
	[PEMC_Flag] [varchar](2) NOT NULL,
	[Covid_Flag] [varchar](2) NOT NULL,
	[Cruise_Flag] [varchar](2) NOT NULL,
	[Motorbike_Flag] [varchar](2) NOT NULL,
	[Adventure_Activities_Flag] [varchar](2) NOT NULL,
	[Incident_Country] [nvarchar](45) NOT NULL,
	[Reserve_Amount] [decimal](20, 6) NOT NULL,
	[Paid_Amount] [money] NOT NULL,
	[Recovery_Amount] [decimal](20, 6) NOT NULL,
	[Movement_Sequence] [bigint] NULL,
	[First_Movement_In_Day] [bit] NULL,
	[Assessment_Outcome_Description] [nvarchar](400) NOT NULL,
	[Excess_Amount] [money] NULL,
	[Payment_Date] [date] NULL,
	[Is_Assistance_Case] [varchar](1) NOT NULL,
	[Loss_Description] [nvarchar](100) NOT NULL,
	[Agency_Code] [varchar](7) NULL
) ON [PRIMARY]
GO
