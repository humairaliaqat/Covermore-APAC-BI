USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimPayment]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimPayment](
	[PaymentSK] [int] IDENTITY(1,1) NOT NULL,
	[PaymentID] [int] NOT NULL,
	[PaymentNo] [numeric](18, 0) NULL,
	[PaymentDate] [datetime] NULL,
	[EntityID] [int] NULL,
	[Amount] [numeric](18, 2) NULL,
	[Narration] [nvarchar](max) NULL,
	[DocumentID] [int] NULL,
	[PaymentType] [nvarchar](100) NULL,
	[Drawnon] [datetime] NULL,
	[ChequeDate] [datetime] NULL,
	[BankAndBranch] [nvarchar](1000) NULL,
	[Status] [nvarchar](50) NULL,
	[BranchID] [int] NULL,
	[ByName] [nvarchar](50) NULL,
	[ByAddress1] [nvarchar](500) NULL,
	[ByAddress2] [nvarchar](500) NULL,
	[ByCity] [nvarchar](50) NULL,
	[ByDistrict] [nvarchar](50) NULL,
	[ByState] [nvarchar](50) NULL,
	[ByPinCode] [nvarchar](10) NULL,
	[ByCountry] [nvarchar](100) NULL,
	[AgentID] [int] NULL,
	[ToCompanyName] [nvarchar](500) NULL,
	[ToContactPerson] [nvarchar](50) NULL,
	[ToAddress1] [nvarchar](500) NULL,
	[ToAddress2] [nvarchar](500) NULL,
	[ToCity] [nvarchar](50) NULL,
	[ToDistrict] [nvarchar](50) NULL,
	[ToState] [nvarchar](50) NULL,
	[ToPinCode] [nvarchar](10) NULL,
	[ToCountry] [nvarchar](100) NULL,
	[ToPhoneNo] [nvarchar](50) NULL,
	[ToMobileNo] [nvarchar](50) NULL,
	[ToEmailAddress] [nvarchar](50) NULL,
	[ReferenceType] [nvarchar](100) NULL,
	[ReferenceNo] [numeric](18, 0) NULL,
	[TemplateId] [int] NULL,
	[CollectionEmployeeID] [int] NULL,
	[DepositBY] [nvarchar](200) NULL,
	[DepositDate] [datetime] NULL,
	[ClearedBy] [nvarchar](200) NULL,
	[ClearedDate] [datetime] NULL,
	[BankID] [int] NULL,
	[checkno] [nvarchar](200) NULL,
	[Agentbranchid] [int] NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_PaymentSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimPayment_PaymentSK] ON [dbo].[trwdimPayment]
(
	[PaymentSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_Agentbranchid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_Agentbranchid] ON [dbo].[trwdimPayment]
(
	[Agentbranchid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_AgentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_AgentID] ON [dbo].[trwdimPayment]
(
	[AgentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_BranchID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_BranchID] ON [dbo].[trwdimPayment]
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_CollectionEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_CollectionEmployeeID] ON [dbo].[trwdimPayment]
(
	[CollectionEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_DocumentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_DocumentID] ON [dbo].[trwdimPayment]
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_EntityID] ON [dbo].[trwdimPayment]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimPayment_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_HashKey] ON [dbo].[trwdimPayment]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPayment_PaymentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPayment_PaymentID] ON [dbo].[trwdimPayment]
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
