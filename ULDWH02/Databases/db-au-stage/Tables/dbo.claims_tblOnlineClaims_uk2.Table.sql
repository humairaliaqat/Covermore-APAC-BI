USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_tblOnlineClaims_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_tblOnlineClaims_uk2](
	[OnlineClaimId] [int] NOT NULL,
	[ClaimId] [int] NULL,
	[PrimaryClaimantId] [int] NULL,
	[ClaimCauseId] [int] NULL,
	[ClaimFormDetailId] [int] NULL,
	[DeclarationId] [int] NULL,
	[LatestStep] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[UserId] [int] NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[ConsultantName] [nvarchar](50) NULL,
	[KLDOMAINID] [int] NOT NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[IsMoreDocument] [bit] NULL,
	[DocumentDescription] [varchar](500) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_tblOnlineClaims_uk2_eid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_tblOnlineClaims_uk2_eid] ON [dbo].[claims_tblOnlineClaims_uk2]
(
	[ClaimCauseId] ASC
)
INCLUDE([OnlineClaimId],[ClaimId],[KLDOMAINID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_tblOnlineClaims_uk2_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_tblOnlineClaims_uk2_id] ON [dbo].[claims_tblOnlineClaims_uk2]
(
	[ClaimId] ASC
)
INCLUDE([AlphaCode],[ConsultantName],[OnlineClaimId],[ClaimCauseId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
