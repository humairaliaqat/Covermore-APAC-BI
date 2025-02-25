USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmPayment]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmPayment](
	[CountryKey] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NULL,
	[PaymentKey] [varchar](40) NULL,
	[AddresseeKey] [varchar](40) NULL,
	[ProviderKey] [varchar](40) NULL,
	[EventKey] [varchar](40) NULL,
	[SectionKey] [varchar](40) NULL,
	[PayeeKey] [varchar](40) NULL,
	[ChequeKey] [varchar](40) NULL,
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
	[DAMOutcome] [money] NULL,
	[ITCOutcome] [money] NULL,
	[ITCAdjustedAmount] [money] NULL,
	[Supply] [int] NULL,
	[Invoice] [nvarchar](100) NULL,
	[Taxable] [bit] NULL,
	[GSTOutcome] [money] NULL,
	[PayMethod_ID] [int] NULL,
	[GSTPercentage] [numeric](18, 0) NULL,
	[isDeleted] [bit] NOT NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[ModifiedDateTimeUTC] [datetime] NULL,
	[PropDateTimeUTC] [datetime] NULL,
	[CreatedDateTimeUTC] [datetime] NULL,
	[UTRNumber] [varchar](16) NULL,
	[CHQDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmPayment_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmPayment_BIRowID] ON [dbo].[clmPayment]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_ClaimKey] ON [dbo].[clmPayment]
(
	[ClaimKey] ASC
)
INCLUDE([SectionKey],[PayeeKey],[PaymentID],[PaymentStatus],[PaymentAmount],[ModifiedDate],[CreatedDate],[isDeleted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_CountryKey] ON [dbo].[clmPayment]
(
	[CountryKey] ASC,
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_CreatedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_CreatedDate] ON [dbo].[clmPayment]
(
	[CreatedDate] ASC,
	[PaymentStatus] ASC
)
INCLUDE([CountryKey],[ClaimKey],[SectionKey],[PayeeKey],[PaymentAmount],[isDeleted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_EventKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_EventKey] ON [dbo].[clmPayment]
(
	[EventKey] ASC
)
INCLUDE([ClaimKey],[PaymentStatus],[PaymentAmount],[ModifiedDate],[isDeleted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_ModifiedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_ModifiedDate] ON [dbo].[clmPayment]
(
	[ModifiedDate] ASC,
	[PaymentStatus] ASC
)
INCLUDE([CountryKey],[ClaimKey],[SectionKey],[PayeeKey],[PaymentAmount],[isDeleted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_PaymentKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_PaymentKey] ON [dbo].[clmPayment]
(
	[PaymentKey] ASC
)
INCLUDE([ClaimKey],[PayeeKey],[TPLoc],[GoodServ],[CreatedByName],[AuthorisedOfficerName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmPayment_SectionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmPayment_SectionKey] ON [dbo].[clmPayment]
(
	[SectionKey] ASC,
	[isDeleted] ASC
)
INCLUDE([ClaimKey],[PayeeKey],[PaymentID],[PaymentStatus],[PaymentAmount],[ModifiedDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clmPayment] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
