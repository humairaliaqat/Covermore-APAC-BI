USE [db-au-star]
GO
/****** Object:  Table [dbo].[factPolicyTransactionAddons_deleted_records_dated20191223]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTransactionAddons_deleted_records_dated20191223](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NOT NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicySK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[PromotionSK] [int] NOT NULL,
	[LeadTime] [int] NOT NULL,
	[PolicyTransactionKey] [nvarchar](50) NULL,
	[AddonGroup] [nvarchar](50) NOT NULL,
	[AddonCount] [int] NULL,
	[SellPrice] [decimal](15, 2) NULL,
	[UnadjustedSellPrice] [decimal](15, 2) NULL,
	[PolicyIssueDate] [date] NULL,
	[DepartureDate] [date] NULL,
	[ReturnDate] [date] NULL,
	[UnderwriterCode] [varchar](100) NULL,
	[DepartureDateSK] [date] NULL,
	[ReturnDateSK] [date] NULL,
	[IssueDateSK] [date] NULL
) ON [PRIMARY]
GO
