USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsResponse]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsResponse](
	[BIRowID] [bigint] NOT NULL,
	[SuperGroup] [nvarchar](255) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[ClaimKey] [varchar](40) NULL,
	[CaseKey] [nvarchar](20) NULL,
	[Overall Score] [int] NULL,
	[Score Comment] [nvarchar](max) NOT NULL,
	[Recommendation Score] [bigint] NULL,
	[Claim Score] [int] NULL,
	[Claim Comment] [nvarchar](max) NOT NULL,
	[MA Score] [numeric](33, 12) NULL,
	[MA Comment] [nvarchar](max) NOT NULL,
	[GlobalSIM Score] [bigint] NULL,
	[GlobalSIM Comment] [nvarchar](max) NOT NULL,
	[RecommendedScore] [int] NULL,
	[ClmSFScore_Response] [int] NULL,
	[ClmSFScore_Engagement] [int] NULL,
	[ClmSFScore_StaffKnowledge] [int] NULL,
	[ClmSFScore_Timing] [int] NULL,
	[GlobalSIMSFScore] [int] NULL,
	[GlobalSIMRecScore] [int] NULL,
	[ResponsiveSFScore] [int] NULL,
	[EngagementSFScore] [int] NULL,
	[OverallSFScore] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ncidx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [ncidx] ON [dbo].[npsResponse]
(
	[BIRowID] ASC
)
INCLUDE([SuperGroup],[PolicyTransactionKey],[ClaimKey],[CaseKey],[Overall Score],[Score Comment],[Recommendation Score],[Claim Score],[Claim Comment],[MA Score],[MA Comment],[GlobalSIM Score],[GlobalSIM Comment],[RecommendedScore],[ClmSFScore_Response],[ClmSFScore_Engagement],[ClmSFScore_StaffKnowledge],[ClmSFScore_Timing],[GlobalSIMSFScore],[GlobalSIMRecScore],[ResponsiveSFScore],[EngagementSFScore],[OverallSFScore]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
