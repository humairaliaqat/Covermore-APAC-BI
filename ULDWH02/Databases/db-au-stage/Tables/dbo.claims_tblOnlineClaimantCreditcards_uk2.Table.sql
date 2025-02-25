USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_tblOnlineClaimantCreditcards_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_tblOnlineClaimantCreditcards_uk2](
	[CardId] [int] NOT NULL,
	[ClaimantId] [int] NOT NULL,
	[CardDetails] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_tblOnlineClaimantCreditCards_uk2_id]    Script Date: 24/02/2025 5:08:03 PM ******/
CREATE CLUSTERED INDEX [idx_claims_tblOnlineClaimantCreditCards_uk2_id] ON [dbo].[claims_tblOnlineClaimantCreditcards_uk2]
(
	[ClaimantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
