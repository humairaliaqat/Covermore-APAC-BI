USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PenPolicyCreditNote_BKP20200520_ASP150]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PenPolicyCreditNote_BKP20200520_ASP150](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NOT NULL,
	[CreditNotePolicyKey] [varchar](71) NOT NULL,
	[ID] [int] NOT NULL,
	[CreditNoteNumber] [nvarchar](15) NOT NULL,
	[OriginalPolicyId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[RedeemPolicyId] [int] NULL,
	[RedeemAmount] [money] NULL,
	[Status] [varchar](15) NOT NULL,
	[DomainId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
