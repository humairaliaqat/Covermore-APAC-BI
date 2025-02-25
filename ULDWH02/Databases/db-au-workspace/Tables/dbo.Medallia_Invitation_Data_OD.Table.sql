USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Medallia_Invitation_Data_OD]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_Invitation_Data_OD](
	[Journey_name] [varchar](19) NULL,
	[Survey_channel] [varchar](5) NULL,
	[Unit_Id] [varchar](500) NULL,
	[Product_Type] [varchar](6) NULL,
	[Sales_Channel] [varchar](6) NULL,
	[Unique_ID] [varchar](43) NULL,
	[Intermediary_Type] [nvarchar](100) NULL,
	[Purchase_Outcome] [varchar](12) NULL,
	[Premium_Amount] [money] NULL,
	[Premium_Currency] [varchar](3) NULL,
	[Insurance_Type] [varchar](6) NULL,
	[Customer_Salutation] [varchar](4000) NULL,
	[Customer_FirstName] [varchar](4000) NULL,
	[Customer_LastName] [varchar](4000) NULL,
	[Customer_Email] [nvarchar](255) NULL,
	[Customer_Phone] [varchar](50) NULL,
	[Policy_Renewal/Expiration_Date] [varchar](8000) NULL,
	[Claim_Outcome] [nvarchar](400) NULL,
	[Customer_JoinDate] [varchar](8000) NULL,
	[Touchpoint_Date] [date] NULL,
	[QuoteID] [varchar](60) NULL,
	[PolicyNo] [varchar](50) NULL,
	[ClaimNo] [varchar](60) NULL,
	[Country] [varchar](2) NULL,
	[Brand_Outlet] [nvarchar](4000) NULL,
	[GroupName] [nvarchar](50) NULL,
	[Sub_Group] [nvarchar](4000) NULL,
	[Super_Group] [nvarchar](4000) NULL,
	[Survey_Brand_Logo] [varchar](200) NULL,
	[age] [int] NULL
) ON [PRIMARY]
GO
