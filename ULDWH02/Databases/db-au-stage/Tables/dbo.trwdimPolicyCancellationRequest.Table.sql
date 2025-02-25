USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimPolicyCancellationRequest]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimPolicyCancellationRequest](
	[PolicyCancellationRequestSK] [int] IDENTITY(1,1) NOT NULL,
	[PolicyCancellationRequestID] [int] NOT NULL,
	[PolicyID] [int] NULL,
	[RequesterEntityID] [int] NULL,
	[Documentfile] [nvarchar](500) NULL,
	[Reason] [nvarchar](1000) NULL,
	[Charges] [numeric](18, 2) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[ProcessedByEntityID] [int] NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_PolicyCancellationRequestSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimPolicyCancellationRequest_PolicyCancellationRequestSK] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[PolicyCancellationRequestSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyCancellationRequest_HashKey] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_PolicyCancellationRequestID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyCancellationRequest_PolicyCancellationRequestID] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[PolicyCancellationRequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_PolicyID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyCancellationRequest_PolicyID] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_ProcessedByEntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyCancellationRequest_ProcessedByEntityID] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[ProcessedByEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimPolicyCancellationRequest_RequesterEntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimPolicyCancellationRequest_RequesterEntityID] ON [dbo].[trwdimPolicyCancellationRequest]
(
	[RequesterEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
