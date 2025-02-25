USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[tbl_RPT520_CN_Status_20240930]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_RPT520_CN_Status_20240930](
	[PolicyID] [int] NOT NULL,
	[OriginalPolicyNumber] [varchar](50) NULL,
	[Area] [nvarchar](100) NULL,
	[TripStart] [date] NULL,
	[TripEnd] [date] NULL,
	[PolicyIssueDate AEST] [date] NULL,
	[CreditNoteNumber] [nvarchar](15) NOT NULL,
	[CNCreatedDate AEST] [date] NULL,
	[CNStatus] [varchar](15) NOT NULL,
	[CreditNoteOriginalValue] [money] NOT NULL,
	[AmountRedeemed] [money] NULL,
	[CommissionEarned] [money] NULL,
	[CommissionRedeemed] [money] NULL,
	[AlphaCode] [nvarchar](60) NULL,
	[DomainID] [int] NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[RedeemPolicyId] [int] NULL,
	[NewPolicyNumber] [varchar](50) NULL,
	[NewAlphaCode] [nvarchar](60) NULL,
	[NewPolicyStatus] [varchar](15) NULL,
	[NewPolicyIssueDate] [datetime] NULL,
	[NewPolicyCancelDate] [datetime] NULL,
	[New_Issued_Policy_Number] [varchar](50) NULL,
	[Active_Credit_Note] [varchar](3) NOT NULL,
	[Redeemed_Policy_Number] [varchar](50) NULL,
	[Redeemed_Credit_Note] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
