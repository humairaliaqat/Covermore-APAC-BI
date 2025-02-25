USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmAuditPayment_BKP_20200131]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmAuditPayment_BKP_20200131](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[AuditUserName] [nvarchar](150) NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditAction] [char](1) NOT NULL,
	[PaymentKey] [varchar](40) NULL,
	[EventKey] [varchar](40) NULL,
	[SectionKey] [varchar](40) NULL,
	[PaymentID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[AddresseeID] [int] NULL,
	[ProviderID] [int] NULL,
	[ChequeID] [int] NULL,
	[EventID] [int] NULL,
	[SectionID] [int] NULL,
	[InvoiceID] [int] NULL,
	[AuthorisedID] [int] NULL,
	[CheckedOfficerID] [int] NULL,
	[AuthorisedOfficerName] [nvarchar](150) NULL,
	[CheckedOfficerName] [nvarchar](150) NULL,
	[WordingID] [int] NULL,
	[Method] [varchar](3) NULL,
	[CreatedByID] [int] NULL,
	[CreatedByName] [nvarchar](150) NULL,
	[Number] [smallint] NULL,
	[BillAmount] [money] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[Rate] [float] NULL,
	[AUDAmount] [money] NULL,
	[DEPR] [float] NULL,
	[DEPV] [money] NULL,
	[Other] [money] NULL,
	[OtherDesc] [nvarchar](50) NULL,
	[PaymentStatus] [varchar](4) NULL,
	[GST] [money] NULL,
	[MaxPay] [money] NULL,
	[PaymentAmount] [money] NULL,
	[Payee] [nvarchar](200) NULL,
	[ModifiedByName] [nvarchar](150) NULL,
	[ModifiedDate] [datetime] NULL,
	[PropDate] [datetime] NULL,
	[PayeeID] [int] NULL,
	[BatchNo] [int] NULL,
	[DFTPayeeID] [int] NULL,
	[GSTAdjustedAmount] [money] NULL,
	[ExcessAmount] [money] NULL,
	[CreatedDate] [datetime] NULL,
	[GoodServ] [varchar](1) NULL,
	[TPLoc] [varchar](3) NULL,
	[GSTInc] [bit] NOT NULL,
	[PayeeType] [varchar](1) NULL,
	[ChequeNo] [bigint] NULL,
	[ChequeStatus] [varchar](4) NULL,
	[BankRef] [int] NULL,
	[DAMOutcome] [money] NULL,
	[ITCOutcome] [money] NULL,
	[ITCAdjustedAmount] [money] NULL,
	[Supply] [int] NULL,
	[Invoice] [nvarchar](100) NULL,
	[Taxable] [bit] NULL,
	[GSTOutcome] [money] NULL,
	[PayMethod_ID] [int] NULL,
	[GSTPercentage] [numeric](18, 0) NULL,
	[FirstOccurrenceIndicator] [bit] NULL,
	[ValidTransactionsIndicator] [bit] NULL,
	[PayeeKey] [varchar](40) NULL,
	[ChequeKey] [varchar](40) NULL,
	[BIRowID] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[AuditDateTimeUTC] [datetime] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL,
	[PropDateTimeUTC] [datetime] NULL,
	[CreatedDateTimeUTC] [datetime] NULL,
	[UTRNumber] [varchar](16) NULL,
	[CHQDate] [datetime] NULL
) ON [PRIMARY]
GO
