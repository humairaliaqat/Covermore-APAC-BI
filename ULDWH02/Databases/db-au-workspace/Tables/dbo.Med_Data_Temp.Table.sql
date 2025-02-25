USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Med_Data_Temp]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Med_Data_Temp](
	[Journey_name] [varchar](50) NULL,
	[Survey_channel] [varchar](50) NULL,
	[Unit_Id] [varchar](50) NULL,
	[Product_Type] [varchar](50) NULL,
	[Sales_Channel] [varchar](50) NULL,
	[Unique_ID] [varchar](50) NULL,
	[Intermediary_Type] [varchar](50) NULL,
	[Purchase_Outcome] [varchar](50) NULL,
	[Premium_Amount] [varchar](50) NULL,
	[Premium_Currency] [varchar](50) NULL,
	[Insurance_Type] [varchar](50) NULL,
	[Customer_Salutation] [varchar](50) NULL,
	[Customer_FirstName] [varchar](50) NULL,
	[Customer_LastName] [varchar](50) NULL,
	[Customer_Email] [varchar](50) NULL,
	[Customer_Phone] [varchar](50) NULL,
	[Policy_Renewal Expiration_Date] [varchar](50) NULL,
	[Claim_Outcome] [varchar](50) NULL,
	[Customer_JoinDate] [varchar](50) NULL,
	[Touchpoint_Date] [varchar](50) NULL,
	[QuoteID] [varchar](50) NULL,
	[PolicyNo] [varchar](50) NULL,
	[ClaimNo] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Brand_Outlet] [varchar](50) NULL,
	[GroupName] [varchar](50) NULL,
	[Sub_Group] [varchar](50) NULL,
	[Super_Group] [varchar](50) NULL,
	[Survey_Brand_Logo] [varchar](50) NULL
) ON [PRIMARY]
GO
