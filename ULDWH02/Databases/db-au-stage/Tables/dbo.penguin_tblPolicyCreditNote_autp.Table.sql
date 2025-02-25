USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyCreditNote_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyCreditNote_autp](
	[Id] [int] NOT NULL,
	[CreditNoteNumber] [nvarchar](15) NOT NULL,
	[OriginalPolicyId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[RedeemPolicyId] [int] NULL,
	[RedeemAmount] [money] NULL,
	[Status] [varchar](15) NOT NULL,
	[DomainId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Commission] [money] NULL,
	[RedeemedCommission] [money] NULL,
	[TripStartDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[Comments] [nvarchar](max) NULL,
	[CNStatusID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyCreditNote_autp_ID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyCreditNote_autp_ID] ON [dbo].[penguin_tblPolicyCreditNote_autp]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
